import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../config/firebase_config.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap({required FirebaseConfig config}) : _config = config;

  factory FirebaseBootstrap.fromEnvironment() {
    return FirebaseBootstrap(config: FirebaseConfig.fromEnvironment());
  }

  final FirebaseConfig _config;

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

    if (!_config.supportsPlatform(platform: platform, isWeb: isWeb)) {
      logger('Firebase 초기화 건너뜀: 지원 대상(iOS/Android)이 아닙니다.');
      return false;
    }

    try {
      final options = _config.buildOptions(platform: platform, isWeb: isWeb);

      await Firebase.initializeApp(options: options);

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        _config.analyticsCollectionEnabled,
      );
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _config.crashlyticsCollectionEnabled,
      );

      _installGlobalErrorHandlers(logger);

      logger(
        'Firebase 초기화 완료 '
        '(analytics=${_config.analyticsCollectionEnabled}, '
        'crashlytics=${_config.crashlyticsCollectionEnabled})',
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

    if (!_config.crashlyticsCollectionEnabled) {
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

    final crashlyticsEnabled = _config.crashlyticsCollectionEnabled;
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
