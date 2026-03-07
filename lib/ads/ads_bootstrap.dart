import 'package:flutter/foundation.dart';

import 'ads_config.dart';
import 'ads_controller.dart';
import 'consent_manager.dart';
import 'mobile_ads_client.dart';

class AdsBootstrap {
  AdsBootstrap({
    required this.config,
    required this.controller,
    required this.consentManager,
    required this.mobileAdsClient,
  });

  final AdsConfig config;
  final AdsController controller;
  final ConsentManager consentManager;
  final MobileAdsClient mobileAdsClient;

  Future<void>? _initializationFuture;

  Future<void> initialize({void Function(String message)? log}) {
    return _initializationFuture ??= _initialize(log: log);
  }

  Future<void> _initialize({void Function(String message)? log}) async {
    final logger = log ?? debugPrint;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      controller.setDisabled(message: 'unsupported_platform');
      logger('AdMob 초기화 건너뜀: Android 전용 광고 설정입니다.');
      return;
    }

    if (!config.isEnabled) {
      controller.setDisabled(message: config.disabledReason);
      logger('AdMob 초기화 건너뜀: ${config.disabledReason ?? "disabled"}');
      return;
    }

    controller.setLoading();

    try {
      await mobileAdsClient.initialize();
      final consentSnapshot = await consentManager.gatherConsent(log: logger);

      if (consentSnapshot.canRequestAds) {
        controller.setReady(consentSnapshot);
        logger(
          'AdMob 초기화 완료 '
          '(env=${config.environment.value}, '
          'sample=${config.usesSampleAds}, '
          'npa=${consentSnapshot.shouldUseNonPersonalizedAds})',
        );
        return;
      }

      controller.setBlocked(consentSnapshot);
      logger('AdMob 광고 요청 차단: consent unavailable');
    } catch (error, stackTrace) {
      controller.setError('$error');
      logger('AdMob 초기화 실패: $error');
      logger(stackTrace.toString());
    }
  }
}
