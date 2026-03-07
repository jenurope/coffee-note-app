import 'package:coffee_note_app/ads/community_feed_ad_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('community feed ad layout', () {
    test('5개 미만 게시글에는 광고를 삽입하지 않는다', () {
      expect(communityFeedAdCount(4), 0);
    });

    test('5개 게시글이면 첫 광고를 5번째 뒤에 삽입한다', () {
      expect(communityFeedAdCount(5), 1);
      expect(isCommunityFeedAdDisplayIndex(5), isTrue);
      expect(communityFeedAdSlotIndexForDisplayIndex(5), 0);
    });

    test('13개 게시글이면 두 번째 광고를 8개 간격으로 삽입한다', () {
      expect(communityFeedAdCount(13), 2);
      expect(isCommunityFeedAdDisplayIndex(14), isTrue);
      expect(communityFeedAdSlotIndexForDisplayIndex(14), 1);
    });

    test('display index를 organic index로 올바르게 역매핑한다', () {
      expect(communityFeedOrganicIndexForDisplayIndex(0), 0);
      expect(communityFeedOrganicIndexForDisplayIndex(4), 4);
      expect(communityFeedOrganicIndexForDisplayIndex(6), 5);
      expect(communityFeedOrganicIndexForDisplayIndex(13), 12);
    });
  });
}
