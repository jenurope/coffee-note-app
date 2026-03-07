enum AdPlacement { beanListBanner, coffeeLogListBanner, communityNative }

extension AdPlacementX on AdPlacement {
  bool get isBanner => this != AdPlacement.communityNative;

  String get slotName => switch (this) {
    AdPlacement.beanListBanner => 'beanListBanner',
    AdPlacement.coffeeLogListBanner => 'coffeeLogListBanner',
    AdPlacement.communityNative => 'communityNative',
  };
}
