import 'package:coffee_note_app/ads/ads_bootstrap.dart';
import 'package:coffee_note_app/ads/ads_config.dart';
import 'package:coffee_note_app/ads/ads_controller.dart';
import 'package:coffee_note_app/ads/consent_manager.dart';
import 'package:coffee_note_app/ads/mobile_ads_client.dart';
import 'package:coffee_note_app/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  group('AdsBootstrap', () {
    test('동의 완료 시 광고 요청 가능 상태로 전환한다', () async {
      final controller = AdsController();
      final bootstrap = AdsBootstrap(
        config: _prodConfig(),
        controller: controller,
        consentManager: _FakeConsentManager(
          const ConsentSnapshot(
            canRequestAds: true,
            consentStatus: ConsentStatus.obtained,
            privacyOptionsRequirementStatus:
                PrivacyOptionsRequirementStatus.notRequired,
          ),
        ),
        mobileAdsClient: _FakeMobileAdsClient(),
      );

      await bootstrap.initialize();

      expect(controller.value.availability, AdsAvailability.ready);
      expect(controller.value.nonPersonalizedAds, isFalse);
      expect(controller.createAdRequest().nonPersonalizedAds, isFalse);
    });

    test('제한된 동의 상태면 non-personalized 요청으로 전환한다', () async {
      final controller = AdsController();
      final bootstrap = AdsBootstrap(
        config: _prodConfig(),
        controller: controller,
        consentManager: _FakeConsentManager(
          const ConsentSnapshot(
            canRequestAds: true,
            consentStatus: ConsentStatus.required,
            privacyOptionsRequirementStatus:
                PrivacyOptionsRequirementStatus.required,
          ),
        ),
        mobileAdsClient: _FakeMobileAdsClient(),
      );

      await bootstrap.initialize();

      expect(controller.value.availability, AdsAvailability.ready);
      expect(controller.value.nonPersonalizedAds, isTrue);
      expect(controller.createAdRequest().nonPersonalizedAds, isTrue);
    });

    test('광고 요청이 불가능하면 blocked 상태로 유지한다', () async {
      final controller = AdsController();
      final bootstrap = AdsBootstrap(
        config: _prodConfig(),
        controller: controller,
        consentManager: _FakeConsentManager(
          const ConsentSnapshot(
            canRequestAds: false,
            consentStatus: ConsentStatus.required,
            privacyOptionsRequirementStatus:
                PrivacyOptionsRequirementStatus.required,
          ),
        ),
        mobileAdsClient: _FakeMobileAdsClient(),
      );

      await bootstrap.initialize();

      expect(controller.value.availability, AdsAvailability.blocked);
    });
  });
}

AdsConfig _prodConfig() {
  return AdsConfig.fromEnvironment(
    environment: AppEnvironment.prod,
    androidAppId: 'app-id',
    beanListBannerAdUnitId: 'bean-banner',
    coffeeLogListBannerAdUnitId: 'log-banner',
    communityNativeAdUnitId: 'community-native',
  );
}

class _FakeConsentManager implements ConsentManager {
  const _FakeConsentManager(this.snapshot);

  final ConsentSnapshot snapshot;

  @override
  Future<ConsentSnapshot> gatherConsent({void Function(String message)? log}) {
    return Future.value(snapshot);
  }

  @override
  Future<void> showPrivacyOptionsForm() async {}
}

class _FakeMobileAdsClient implements MobileAdsClient {
  @override
  Future<InitializationStatus> initialize() async {
    return InitializationStatus(const <String, AdapterStatus>{});
  }
}
