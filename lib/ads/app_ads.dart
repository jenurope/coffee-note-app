import '../core/di/service_locator.dart';
import 'ads_config.dart';
import 'ads_controller.dart';
import 'ads_slot_factory.dart';

final AdsController _fallbackAdsController = AdsController();
const NoopAdsSlotFactory _fallbackAdsSlotFactory = NoopAdsSlotFactory();
final AdsConfig _fallbackAdsConfig = AdsConfig.fromEnvironment();

AdsController appAdsController() {
  if (getIt.isRegistered<AdsController>()) {
    return getIt<AdsController>();
  }

  final currentState = _fallbackAdsController.value;
  if (currentState.availability != AdsAvailability.disabled ||
      currentState.message != 'ads_not_registered') {
    _fallbackAdsController.setDisabled(message: 'ads_not_registered');
  }
  return _fallbackAdsController;
}

AdsSlotFactory appAdsSlotFactory() {
  if (getIt.isRegistered<AdsSlotFactory>()) {
    return getIt<AdsSlotFactory>();
  }

  return _fallbackAdsSlotFactory;
}

AdsConfig appAdsConfig() {
  if (getIt.isRegistered<AdsConfig>()) {
    return getIt<AdsConfig>();
  }

  return _fallbackAdsConfig;
}
