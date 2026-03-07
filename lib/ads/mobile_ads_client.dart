import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class MobileAdsClient {
  Future<InitializationStatus> initialize();
}

class GoogleMobileAdsClient implements MobileAdsClient {
  @override
  Future<InitializationStatus> initialize() {
    return MobileAds.instance.initialize();
  }
}
