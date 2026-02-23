import 'package:coffee_note_app/config/app_environment.dart';
import 'package:coffee_note_app/config/firebase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseConfig', () {
    const values = FirebaseDefineValues(
      projectId: 'coffee-note',
      messagingSenderId: '1234567890',
      androidApiKey: 'android-key',
      androidAppId: '1:1234567890:android:abc123',
      iosApiKey: 'ios-key',
      iosAppId: '1:1234567890:ios:def456',
    );

    test('prod 환경에서만 수집 플래그가 활성화된다', () {
      final prodConfig = FirebaseConfig(
        values: values,
        environment: AppEnvironment.prod,
      );
      final devConfig = FirebaseConfig(
        values: values,
        environment: AppEnvironment.dev,
      );

      expect(prodConfig.analyticsCollectionEnabled, isTrue);
      expect(prodConfig.crashlyticsCollectionEnabled, isTrue);
      expect(devConfig.analyticsCollectionEnabled, isFalse);
      expect(devConfig.crashlyticsCollectionEnabled, isFalse);
    });

    test('Android 옵션이 올바르게 생성된다', () {
      final config = FirebaseConfig(
        values: values,
        environment: AppEnvironment.prod,
      );

      final options = config.buildOptions(platform: TargetPlatform.android);

      expect(options.projectId, 'coffee-note');
      expect(options.messagingSenderId, '1234567890');
      expect(options.apiKey, 'android-key');
      expect(options.appId, '1:1234567890:android:abc123');
      expect(options.storageBucket, isNull);
    });

    test('iOS 옵션이 올바르게 생성된다', () {
      final config = FirebaseConfig(
        values: values,
        environment: AppEnvironment.prod,
      );

      final options = config.buildOptions(platform: TargetPlatform.iOS);

      expect(options.projectId, 'coffee-note');
      expect(options.messagingSenderId, '1234567890');
      expect(options.apiKey, 'ios-key');
      expect(options.appId, '1:1234567890:ios:def456');
      expect(options.storageBucket, isNull);
      expect(options.iosBundleId, isNull);
    });

    test('필수 키 누락 시 APP_ENV가 포함된 예외를 반환한다', () {
      const emptyValues = FirebaseDefineValues(
        projectId: '',
        messagingSenderId: '',
        androidApiKey: '',
        androidAppId: '',
        iosApiKey: '',
        iosAppId: '',
      );
      final config = FirebaseConfig(
        values: emptyValues,
        environment: AppEnvironment.prod,
      );

      expect(
        () => config.buildOptions(platform: TargetPlatform.android),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(
              contains('APP_ENV=prod'),
              contains('FIREBASE_PROJECT_ID'),
              contains('FIREBASE_ANDROID_APP_ID'),
            ),
          ),
        ),
      );
    });

    test('웹/미지원 플랫폼은 지원하지 않는다', () {
      final config = FirebaseConfig(
        values: values,
        environment: AppEnvironment.prod,
      );

      expect(
        config.supportsPlatform(platform: TargetPlatform.android, isWeb: true),
        isFalse,
      );
      expect(
        config.supportsPlatform(platform: TargetPlatform.macOS, isWeb: false),
        isFalse,
      );
    });
  });
}
