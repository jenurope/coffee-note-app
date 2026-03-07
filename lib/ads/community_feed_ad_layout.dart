const int communityFeedFirstAdDisplayIndex = 5;
const int communityFeedOrganicInterval = 8;
const int communityFeedDisplayStride = communityFeedOrganicInterval + 1;

int communityFeedAdCount(int organicPostCount) {
  if (organicPostCount < communityFeedFirstAdDisplayIndex) {
    return 0;
  }

  return 1 +
      ((organicPostCount - communityFeedFirstAdDisplayIndex) ~/
          communityFeedOrganicInterval);
}

bool isCommunityFeedAdDisplayIndex(int displayIndex) {
  if (displayIndex < communityFeedFirstAdDisplayIndex) {
    return false;
  }

  return (displayIndex - communityFeedFirstAdDisplayIndex) %
          communityFeedDisplayStride ==
      0;
}

int communityFeedAdSlotIndexForDisplayIndex(int displayIndex) {
  assert(isCommunityFeedAdDisplayIndex(displayIndex));
  return (displayIndex - communityFeedFirstAdDisplayIndex) ~/
      communityFeedDisplayStride;
}

int communityFeedOrganicIndexForDisplayIndex(int displayIndex) {
  assert(!isCommunityFeedAdDisplayIndex(displayIndex));
  if (displayIndex < communityFeedFirstAdDisplayIndex) {
    return displayIndex;
  }

  final adsBeforeDisplayIndex =
      1 +
      ((displayIndex - communityFeedFirstAdDisplayIndex - 1) ~/
          communityFeedDisplayStride);
  return displayIndex - adsBeforeDisplayIndex;
}
