import 'package:flutter/widgets.dart';

import 'ad_placement.dart';
import 'widgets/banner_ad_slot.dart';
import 'widgets/community_native_ad_slot.dart';

abstract class AdsSlotFactory {
  const AdsSlotFactory();

  Widget buildBannerSlot({Key? key, required AdPlacement placement});

  Widget buildCommunityNativeSlot({Key? key, required int slotIndex});
}

class GoogleMobileAdsSlotFactory extends AdsSlotFactory {
  const GoogleMobileAdsSlotFactory();

  @override
  Widget buildBannerSlot({Key? key, required AdPlacement placement}) {
    return BannerAdSlot(key: key, placement: placement);
  }

  @override
  Widget buildCommunityNativeSlot({Key? key, required int slotIndex}) {
    return CommunityNativeAdSlot(key: key, slotIndex: slotIndex);
  }
}

class NoopAdsSlotFactory extends AdsSlotFactory {
  const NoopAdsSlotFactory();

  @override
  Widget buildBannerSlot({Key? key, required AdPlacement placement}) {
    return SizedBox(key: key);
  }

  @override
  Widget buildCommunityNativeSlot({Key? key, required int slotIndex}) {
    return SizedBox(key: key);
  }
}
