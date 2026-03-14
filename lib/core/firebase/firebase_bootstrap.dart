import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthApiException, AuthException;

import '../../config/app_environment.dart';

enum CrashReportDisposition { fatal, nonFatal }

enum UnhandledErrorSource { flutter, platform, zone }

class UnhandledCrashReport {
  const UnhandledCrashReport({
    required this.error,
    required this.stackTrace,
    required this.disposition,
    required this.source,
    required this.classification,
    this.authErrorCode,
    this.reason,
    this.information = const <Object>[],
  });

  final Object error;
  final StackTrace stackTrace;
  final CrashReportDisposition disposition;
  final UnhandledErrorSource source;
  final String classification;
  final String? authErrorCode;
  final String? reason;
  final Iterable<Object> information;
}

abstract class CrashReporter {
  Future<void> record(UnhandledCrashReport report);
}

class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> record(UnhandledCrashReport report) async {
    await _crashlytics.setCustomKey('error_source', report.source.name);
    await _crashlytics.setCustomKey('classification', report.classification);
    await _crashlytics.setCustomKey(
      'auth_error_code',
      report.authErrorCode ?? '',
    );
    await _crashlytics.log(
      'unhandled:${report.source.name}:${report.classification}:'
      '${report.disposition.name}',
    );
    await _crashlytics.recordError(
      report.error,
      report.stackTrace,
      fatal: report.disposition == CrashReportDisposition.fatal,
      reason: report.reason,
      information: report.information,
      printDetails: false,
    );
  }
}

class FirebaseBootstrap {
  FirebaseBootstrap({
    required this.environment,
    CrashReporter? crashReporter,
    Future<Object?> Function()? initializeFirebaseApp,
    Future<void> Function(bool enabled)? setAnalyticsCollectionEnabled,
    Future<void> Function(bool enabled)? setCrashlyticsCollectionEnabled,
  }) : _configuredCrashReporter = crashReporter,
       _initializeFirebaseApp = initializeFirebaseApp ?? Firebase.initializeApp,
       _setAnalyticsCollectionEnabled =
           setAnalyticsCollectionEnabled ??
           _defaultSetAnalyticsCollectionEnabled,
       _setCrashlyticsCollectionEnabled =
           setCrashlyticsCollectionEnabled ??
           _defaultSetCrashlyticsCollectionEnabled;

  factory FirebaseBootstrap.fromEnvironment() {
    return FirebaseBootstrap(environment: AppEnvironment.current);
  }

  final AppEnvironment environment;

  bool get _analyticsCollectionEnabled => environment == AppEnvironment.prod;
  bool get _crashlyticsCollectionEnabled => environment == AppEnvironment.prod;

  final CrashReporter? _configuredCrashReporter;
  final Future<Object?> Function() _initializeFirebaseApp;
  final Future<void> Function(bool enabled) _setAnalyticsCollectionEnabled;
  final Future<void> Function(bool enabled) _setCrashlyticsCollectionEnabled;
  CrashReporter? _resolvedCrashReporter;

  CrashReporter get _crashReporter => _resolvedCrashReporter ??=
      _configuredCrashReporter ?? FirebaseCrashReporter();

  static bool _errorHandlersInstalled = false;
  static FlutterExceptionHandler? _previousFlutterErrorHandler;
  static ErrorCallback? _previousPlatformErrorHandler;

  static const List<String> _recoverableAuthErrorPatterns = <String>[
    'refresh_token_already_used',
    'invalid refresh token',
    'refresh token not found',
    'session not found',
    'auth session missing',
    'jwt expired',
    'token expired',
    'already used',
  ];

  static Future<void> _defaultSetAnalyticsCollectionEnabled(bool enabled) {
    return FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
  }

  static Future<void> _defaultSetCrashlyticsCollectionEnabled(bool enabled) {
    return FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      enabled,
    );
  }

  Future<bool> initialize({
    TargetPlatform? platformOverride,
    bool? isWebOverride,
    void Function(String message)? log,
  }) async {
    final logger = log ?? debugPrint;
    final platform = platformOverride ?? defaultTargetPlatform;
    final isWeb = isWebOverride ?? kIsWeb;

    final supportsMobile =
        !isWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
    if (!supportsMobile) {
      logger('Firebase 초기화 건너뜀: 지원 대상(iOS/Android)이 아닙니다.');
      return false;
    }

    try {
      // google-services.json / GoogleService-Info.plist 기반 초기화
      await _initializeFirebaseApp();

      await _setAnalyticsCollectionEnabled(_analyticsCollectionEnabled);
      await _setCrashlyticsCollectionEnabled(_crashlyticsCollectionEnabled);

      _installGlobalErrorHandlers(logger);

      logger(
        'Firebase 초기화 완료 '
        '(analytics=$_analyticsCollectionEnabled, '
        'crashlytics=$_crashlyticsCollectionEnabled)',
      );
      return true;
    } catch (e, st) {
      logger('Firebase 초기화 실패(앱은 계속 실행): $e');
      logger(st.toString());
      return false;
    }
  }

  Future<void> recordZoneError(
    Object error,
    StackTrace stackTrace, {
    void Function(String message)? log,
  }) async {
    await _recordUnhandledError(
      error,
      stackTrace,
      source: UnhandledErrorSource.zone,
      log: log,
    );
  }

  void _installGlobalErrorHandlers(void Function(String message) logger) {
    if (_errorHandlersInstalled) return;
    _errorHandlersInstalled = true;

    _previousFlutterErrorHandler = FlutterError.onError;
    _previousPlatformErrorHandler = PlatformDispatcher.instance.onError;

    FlutterError.onError = (details) {
      _previousFlutterErrorHandler?.call(details);
      unawaited(
        _recordUnhandledError(
          details.exception,
          details.stack ?? StackTrace.current,
          source: UnhandledErrorSource.flutter,
          reason: details.context
              ?.toStringDeep(minLevel: DiagnosticLevel.info)
              .trim(),
          information: details.informationCollector?.call() ?? const <Object>[],
          log: logger,
        ),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        _recordUnhandledError(
          error,
          stack,
          source: UnhandledErrorSource.platform,
          log: logger,
        ),
      );
      _previousPlatformErrorHandler?.call(error, stack);
      return true;
    };
  }

  Future<void> _recordUnhandledError(
    Object error,
    StackTrace stackTrace, {
    required UnhandledErrorSource source,
    String? reason,
    Iterable<Object> information = const <Object>[],
    void Function(String message)? log,
  }) async {
    final logger = log ?? debugPrint;
    final report = _classifyUnhandledError(
      error,
      stackTrace,
      source: source,
      reason: reason,
      information: information,
    );

    if (!_crashlyticsCollectionEnabled) {
      logger(
        '${source.name} error captured (Crashlytics disabled): '
        '${report.error} [${report.classification}]',
      );
      return;
    }

    try {
      await _crashReporter.record(report);
    } catch (e, st) {
      logger('Crashlytics ${source.name} error 기록 실패: $e');
      logger(st.toString());
    }
  }

  UnhandledCrashReport _classifyUnhandledError(
    Object error,
    StackTrace stackTrace, {
    required UnhandledErrorSource source,
    String? reason,
    Iterable<Object> information = const <Object>[],
  }) {
    final authErrorCode = _extractAuthErrorCode(error);
    final normalizedMessage = _normalizeErrorMessage(error);
    final isRecoverableAuth =
        error is AuthException &&
        _matchesRecoverableAuthError(
          normalizedMessage: normalizedMessage,
          authErrorCode: authErrorCode,
        );

    return UnhandledCrashReport(
      error: error,
      stackTrace: stackTrace,
      disposition: isRecoverableAuth
          ? CrashReportDisposition.nonFatal
          : CrashReportDisposition.fatal,
      source: source,
      classification: isRecoverableAuth
          ? 'recoverable_auth_session'
          : 'unhandled',
      authErrorCode: authErrorCode,
      reason: reason,
      information: information,
    );
  }

  bool _matchesRecoverableAuthError({
    required String normalizedMessage,
    required String? authErrorCode,
  }) {
    if (authErrorCode != null &&
        _recoverableAuthErrorPatterns.contains(authErrorCode)) {
      return true;
    }

    return _recoverableAuthErrorPatterns.any(normalizedMessage.contains);
  }

  String _normalizeErrorMessage(Object error) {
    if (error is AuthException) {
      return error.message.toLowerCase();
    }
    return error.toString().toLowerCase();
  }

  String? _extractAuthErrorCode(Object error) {
    if (error case AuthApiException(code: final code?)) {
      final normalized = code.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  @visibleForTesting
  static void resetForTesting() {
    if (_errorHandlersInstalled) {
      FlutterError.onError = _previousFlutterErrorHandler;
      PlatformDispatcher.instance.onError = _previousPlatformErrorHandler;
    }
    _errorHandlersInstalled = false;
    _previousFlutterErrorHandler = null;
    _previousPlatformErrorHandler = null;
  }
}
