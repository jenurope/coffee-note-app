import '../config/app_environment.dart';
import 'ad_placement.dart';

class AdsConfig {
  const AdsConfig({
    required this.environment,
    required this.androidAppId,
    required this.beanListBannerAdUnitId,
    required this.coffeeLogListBannerAdUnitId,
    required this.communityNativeAdUnitId,
    required this.usesSampleAds,
    required this.isEnabled,
    this.disabledReason,
  });

  const AdsConfig.disabled({
    required this.environment,
    required this.disabledReason,
  }) : androidAppId = '',
       beanListBannerAdUnitId = '',
       coffeeLogListBannerAdUnitId = '',
       communityNativeAdUnitId = '',
       usesSampleAds = false,
       isEnabled = false;

  static const String sampleAndroidAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String sampleBannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String sampleNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';

  static const String _prodAndroidAppId = String.fromEnvironment(
    'ADMOB_APP_ID_ANDROID',
    defaultValue: '',
  );
  static const String _prodBeanListBannerAdUnitId = String.fromEnvironment(
    'ADMOB_BEAN_LIST_BANNER_ANDROID',
    defaultValue: '',
  );
  static const String _prodCoffeeLogListBannerAdUnitId = String.fromEnvironment(
    'ADMOB_COFFEE_LOG_LIST_BANNER_ANDROID',
    defaultValue: '',
  );
  static const String _prodCommunityNativeAdUnitId = String.fromEnvironment(
    'ADMOB_COMMUNITY_NATIVE_ANDROID',
    defaultValue: '',
  );

  final AppEnvironment environment;
  final String androidAppId;
  final String beanListBannerAdUnitId;
  final String coffeeLogListBannerAdUnitId;
  final String communityNativeAdUnitId;
  final bool usesSampleAds;
  final bool isEnabled;
  final String? disabledReason;

  factory AdsConfig.fromEnvironment({
    AppEnvironment? environment,
    String? androidAppId,
    String? beanListBannerAdUnitId,
    String? coffeeLogListBannerAdUnitId,
    String? communityNativeAdUnitId,
  }) {
    final resolvedEnvironment = environment ?? AppEnvironment.current;
    if (resolvedEnvironment == AppEnvironment.dev) {
      return const AdsConfig(
        environment: AppEnvironment.dev,
        androidAppId: sampleAndroidAppId,
        beanListBannerAdUnitId: sampleBannerAdUnitId,
        coffeeLogListBannerAdUnitId: sampleBannerAdUnitId,
        communityNativeAdUnitId: sampleNativeAdUnitId,
        usesSampleAds: true,
        isEnabled: true,
      );
    }

    final resolvedAppId = androidAppId ?? _prodAndroidAppId;
    final resolvedBeanBannerId =
        beanListBannerAdUnitId ?? _prodBeanListBannerAdUnitId;
    final resolvedCoffeeBannerId =
        coffeeLogListBannerAdUnitId ?? _prodCoffeeLogListBannerAdUnitId;
    final resolvedCommunityNativeId =
        communityNativeAdUnitId ?? _prodCommunityNativeAdUnitId;

    final missingKeys = <String>[
      if (resolvedAppId.isEmpty) 'ADMOB_APP_ID_ANDROID',
      if (resolvedBeanBannerId.isEmpty) 'ADMOB_BEAN_LIST_BANNER_ANDROID',
      if (resolvedCoffeeBannerId.isEmpty)
        'ADMOB_COFFEE_LOG_LIST_BANNER_ANDROID',
      if (resolvedCommunityNativeId.isEmpty) 'ADMOB_COMMUNITY_NATIVE_ANDROID',
    ];

    if (missingKeys.isNotEmpty) {
      return AdsConfig.disabled(
        environment: resolvedEnvironment,
        disabledReason: 'missing_keys:${missingKeys.join(",")}',
      );
    }

    return AdsConfig(
      environment: resolvedEnvironment,
      androidAppId: resolvedAppId,
      beanListBannerAdUnitId: resolvedBeanBannerId,
      coffeeLogListBannerAdUnitId: resolvedCoffeeBannerId,
      communityNativeAdUnitId: resolvedCommunityNativeId,
      usesSampleAds: false,
      isEnabled: true,
    );
  }

  String adUnitIdFor(AdPlacement placement) {
    return switch (placement) {
      AdPlacement.beanListBanner => beanListBannerAdUnitId,
      AdPlacement.coffeeLogListBanner => coffeeLogListBannerAdUnitId,
      AdPlacement.communityNative => communityNativeAdUnitId,
    };
  }
}
