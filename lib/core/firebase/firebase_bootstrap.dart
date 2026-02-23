import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_environment.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap({required this.environment});

  factory FirebaseBootstrap.fromEnvironment() {
    return FirebaseBootstrap(environment: AppEnvironment.current);
  }

  final AppEnvironment environment;

  bool get _analyticsCollectionEnabled => environment == AppEnvironment.prod;
  bool get _crashlyticsCollectionEnabled => environment == AppEnvironment.prod;

  static bool _errorHandlersInstalled = false;
  static FlutterExceptionHandler? _previousFlutterErrorHandler;
  static ErrorCallback? _previousPlatformErrorHandler;

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
      await Firebase.initializeApp();

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        _analyticsCollectionEnabled,
      );
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _crashlyticsCollectionEnabled,
      );

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
    final logger = log ?? debugPrint;

    if (!_crashlyticsCollectionEnabled) {
      logger('Zone error captured (Crashlytics disabled): $error');
      return;
    }

    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: true,
      );
    } catch (e, st) {
      logger('Crashlytics zone error 기록 실패: $e');
      logger(st.toString());
    }
  }

  void _installGlobalErrorHandlers(void Function(String message) logger) {
    if (_errorHandlersInstalled) return;
    _errorHandlersInstalled = true;

    final crashlyticsEnabled = _crashlyticsCollectionEnabled;
    _previousFlutterErrorHandler = FlutterError.onError;
    _previousPlatformErrorHandler = PlatformDispatcher.instance.onError;

    FlutterError.onError = (details) {
      _previousFlutterErrorHandler?.call(details);
      if (crashlyticsEnabled) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        return;
      }
      logger(
        'FlutterError captured (Crashlytics disabled): '
        '${details.exceptionAsString()}',
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (crashlyticsEnabled) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        logger('Platform error captured (Crashlytics disabled): $error');
      }

      _previousPlatformErrorHandler?.call(error, stack);
      return true;
    };
  }
}
