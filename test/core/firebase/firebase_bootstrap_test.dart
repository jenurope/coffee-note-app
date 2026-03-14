import 'package:coffee_note_app/config/app_environment.dart';
import 'package:coffee_note_app/core/firebase/firebase_bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeCrashReporter implements CrashReporter {
  final List<UnhandledCrashReport> reports = <UnhandledCrashReport>[];

  @override
  Future<void> record(UnhandledCrashReport report) async {
    reports.add(report);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FirebaseBootstrap.resetForTesting();
  });

  tearDown(() {
    FirebaseBootstrap.resetForTesting();
  });

  test('생성자에서 Firebase 인스턴스를 즉시 참조하지 않는다', () {
    expect(
      () => FirebaseBootstrap(environment: AppEnvironment.prod),
      returnsNormally,
    );
  });

  test('인증 세션 예외는 zone에서 non-fatal로 기록한다', () async {
    final reporter = _FakeCrashReporter();
    final bootstrap = FirebaseBootstrap(
      environment: AppEnvironment.prod,
      crashReporter: reporter,
      initializeFirebaseApp: () async => Object(),
      setAnalyticsCollectionEnabled: (_) async {},
      setCrashlyticsCollectionEnabled: (_) async {},
    );

    await bootstrap.initialize(
      platformOverride: TargetPlatform.android,
      isWebOverride: false,
    );

    await bootstrap.recordZoneError(
      AuthApiException(
        'Invalid Refresh Token: Already Used',
        statusCode: '400',
        code: 'refresh_token_already_used',
      ),
      StackTrace.current,
    );

    expect(reporter.reports, hasLength(1));
    expect(
      reporter.reports.single.disposition,
      CrashReportDisposition.nonFatal,
    );
    expect(reporter.reports.single.source, UnhandledErrorSource.zone);
    expect(reporter.reports.single.classification, 'recoverable_auth_session');
    expect(reporter.reports.single.authErrorCode, 'refresh_token_already_used');
  });

  test('일반 예외는 zone에서 fatal로 기록한다', () async {
    final reporter = _FakeCrashReporter();
    final bootstrap = FirebaseBootstrap(
      environment: AppEnvironment.prod,
      crashReporter: reporter,
      initializeFirebaseApp: () async => Object(),
      setAnalyticsCollectionEnabled: (_) async {},
      setCrashlyticsCollectionEnabled: (_) async {},
    );

    await bootstrap.initialize(
      platformOverride: TargetPlatform.android,
      isWebOverride: false,
    );

    await bootstrap.recordZoneError(Exception('boom'), StackTrace.current);

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.disposition, CrashReportDisposition.fatal);
    expect(reporter.reports.single.source, UnhandledErrorSource.zone);
    expect(reporter.reports.single.classification, 'unhandled');
    expect(reporter.reports.single.authErrorCode, isNull);
  });

  test('인증 세션 예외는 FlutterError 경로에서도 non-fatal로 기록한다', () async {
    final reporter = _FakeCrashReporter();
    final bootstrap = FirebaseBootstrap(
      environment: AppEnvironment.prod,
      crashReporter: reporter,
      initializeFirebaseApp: () async => Object(),
      setAnalyticsCollectionEnabled: (_) async {},
      setCrashlyticsCollectionEnabled: (_) async {},
    );

    FlutterError.onError = (_) {};
    await bootstrap.initialize(
      platformOverride: TargetPlatform.android,
      isWebOverride: false,
    );

    FlutterError.onError?.call(
      FlutterErrorDetails(
        exception: AuthApiException(
          'Invalid Refresh Token: Already Used',
          statusCode: '400',
          code: 'refresh_token_already_used',
        ),
        stack: StackTrace.current,
      ),
    );

    await _flushAsync();

    expect(reporter.reports, hasLength(1));
    expect(
      reporter.reports.single.disposition,
      CrashReportDisposition.nonFatal,
    );
    expect(reporter.reports.single.source, UnhandledErrorSource.flutter);
  });

  test('인증 세션 예외는 platform 경로에서도 non-fatal로 기록한다', () async {
    final reporter = _FakeCrashReporter();
    final bootstrap = FirebaseBootstrap(
      environment: AppEnvironment.prod,
      crashReporter: reporter,
      initializeFirebaseApp: () async => Object(),
      setAnalyticsCollectionEnabled: (_) async {},
      setCrashlyticsCollectionEnabled: (_) async {},
    );

    await bootstrap.initialize(
      platformOverride: TargetPlatform.android,
      isWebOverride: false,
    );

    final handled = PlatformDispatcher.instance.onError?.call(
      AuthApiException(
        'Invalid Refresh Token: Already Used',
        statusCode: '400',
        code: 'refresh_token_already_used',
      ),
      StackTrace.current,
    );

    await _flushAsync();

    expect(handled, isTrue);
    expect(reporter.reports, hasLength(1));
    expect(
      reporter.reports.single.disposition,
      CrashReportDisposition.nonFatal,
    );
    expect(reporter.reports.single.source, UnhandledErrorSource.platform);
  });

  test('Crashlytics 비활성 환경에서는 기록 대신 로그만 남긴다', () async {
    final reporter = _FakeCrashReporter();
    final logs = <String>[];
    final bootstrap = FirebaseBootstrap(
      environment: AppEnvironment.dev,
      crashReporter: reporter,
      initializeFirebaseApp: () async => Object(),
      setAnalyticsCollectionEnabled: (_) async {},
      setCrashlyticsCollectionEnabled: (_) async {},
    );

    await bootstrap.initialize(
      platformOverride: TargetPlatform.android,
      isWebOverride: false,
      log: logs.add,
    );
    await bootstrap.recordZoneError(
      Exception('boom'),
      StackTrace.current,
      log: logs.add,
    );

    expect(reporter.reports, isEmpty);
    expect(
      logs.any((message) => message.contains('Crashlytics disabled')),
      isTrue,
    );
  });
}

Future<void> _flushAsync() async {
  await Future<void>.delayed(Duration.zero);
}
