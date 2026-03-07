import 'package:coffee_note_app/ads/ad_placement.dart';
import 'package:coffee_note_app/ads/ads_config.dart';
import 'package:coffee_note_app/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdsConfig', () {
    test('dev 환경은 sample ads를 사용한다', () {
      final config = AdsConfig.fromEnvironment(environment: AppEnvironment.dev);

      expect(config.isEnabled, isTrue);
      expect(config.usesSampleAds, isTrue);
      expect(config.androidAppId, AdsConfig.sampleAndroidAppId);
      expect(
        config.adUnitIdFor(AdPlacement.communityNative),
        AdsConfig.sampleNativeAdUnitId,
      );
    });

    test('prod 환경은 전달된 실제 광고 식별자를 사용한다', () {
      final config = AdsConfig.fromEnvironment(
        environment: AppEnvironment.prod,
        androidAppId: 'app-id',
        beanListBannerAdUnitId: 'bean-banner',
        coffeeLogListBannerAdUnitId: 'log-banner',
        communityNativeAdUnitId: 'community-native',
      );

      expect(config.isEnabled, isTrue);
      expect(config.usesSampleAds, isFalse);
      expect(config.androidAppId, 'app-id');
      expect(config.adUnitIdFor(AdPlacement.beanListBanner), 'bean-banner');
      expect(config.adUnitIdFor(AdPlacement.coffeeLogListBanner), 'log-banner');
      expect(
        config.adUnitIdFor(AdPlacement.communityNative),
        'community-native',
      );
    });

    test('prod 환경에서 키가 빠지면 광고를 비활성화한다', () {
      final config = AdsConfig.fromEnvironment(
        environment: AppEnvironment.prod,
        androidAppId: 'app-id',
        beanListBannerAdUnitId: 'bean-banner',
      );

      expect(config.isEnabled, isFalse);
      expect(config.disabledReason, contains('missing_keys'));
    });
  });
}
