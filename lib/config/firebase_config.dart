import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'app_environment.dart';

class FirebaseDefineValues {
  const FirebaseDefineValues({
    required this.projectId,
    required this.messagingSenderId,
    required this.androidApiKey,
    required this.androidAppId,
    required this.iosApiKey,
    required this.iosAppId,
  });

  static const fromEnvironment = FirebaseDefineValues(
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    androidApiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: '',
    ),
    androidAppId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '',
    ),
    iosApiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: ''),
    iosAppId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
  );

  final String projectId;
  final String messagingSenderId;
  final String androidApiKey;
  final String androidAppId;
  final String iosApiKey;
  final String iosAppId;
}

class FirebaseConfig {
  const FirebaseConfig({required this.values, required this.environment});

  factory FirebaseConfig.fromEnvironment() {
    return FirebaseConfig(
      values: FirebaseDefineValues.fromEnvironment,
      environment: AppEnvironment.current,
    );
  }

  final FirebaseDefineValues values;
  final AppEnvironment environment;

  bool get analyticsCollectionEnabled => environment == AppEnvironment.prod;
  bool get crashlyticsCollectionEnabled => environment == AppEnvironment.prod;

  bool supportsPlatform({
    required TargetPlatform platform,
    bool isWeb = kIsWeb,
  }) {
    if (isWeb) return false;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  FirebaseOptions buildOptions({
    required TargetPlatform platform,
    bool isWeb = kIsWeb,
  }) {
    if (!supportsPlatform(platform: platform, isWeb: isWeb)) {
      throw UnsupportedError('Firebase는 iOS/Android 플랫폼에서만 초기화합니다.');
    }

    final missingKeys = _missingKeys(platform);
    if (missingKeys.isNotEmpty) {
      throw Exception(_missingKeysMessage(missingKeys));
    }

    if (platform == TargetPlatform.android) {
      return FirebaseOptions(
        apiKey: values.androidApiKey,
        appId: values.androidAppId,
        messagingSenderId: values.messagingSenderId,
        projectId: values.projectId,
      );
    }

    return FirebaseOptions(
      apiKey: values.iosApiKey,
      appId: values.iosAppId,
      messagingSenderId: values.messagingSenderId,
      projectId: values.projectId,
    );
  }

  List<String> _missingKeys(TargetPlatform platform) {
    final missing = <String>[];
    if (values.projectId.isEmpty) missing.add('FIREBASE_PROJECT_ID');
    if (values.messagingSenderId.isEmpty) {
      missing.add('FIREBASE_MESSAGING_SENDER_ID');
    }

    if (platform == TargetPlatform.android) {
      if (values.androidApiKey.isEmpty) missing.add('FIREBASE_ANDROID_API_KEY');
      if (values.androidAppId.isEmpty) missing.add('FIREBASE_ANDROID_APP_ID');
    }

    if (platform == TargetPlatform.iOS) {
      if (values.iosApiKey.isEmpty) missing.add('FIREBASE_IOS_API_KEY');
      if (values.iosAppId.isEmpty) missing.add('FIREBASE_IOS_APP_ID');
    }

    return missing;
  }

  String _missingKeysMessage(List<String> missingKeys) {
    final env = environment.value;
    final flags = missingKeys.map((key) => '--dart-define=$key=...').join(' ');
    return 'Firebase 설정이 누락되었습니다. '
        '(APP_ENV=$env) '
        '누락 키: ${missingKeys.join(', ')} '
        '$flags';
  }
}
