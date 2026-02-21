import 'package:coffee_note_app/core/image/app_image_cache_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppImageCachePolicy.cacheKeyFor', () {
    test('signed url은 query와 fragment를 제거한 key를 반환한다', () {
      const signedUrl =
          'https://abc.supabase.co/storage/v1/object/sign/logs/user1/123.jpg'
          '?token=foo&expires=123#section';

      final key = AppImageCachePolicy.cacheKeyFor(signedUrl);

      expect(
        key,
        'https://abc.supabase.co/storage/v1/object/sign/logs/user1/123.jpg',
      );
    });

    test('public url은 null을 반환한다', () {
      const publicUrl =
          'https://abc.supabase.co/storage/v1/object/public/community/post.jpg';

      final key = AppImageCachePolicy.cacheKeyFor(publicUrl);

      expect(key, isNull);
    });

    test('빈 문자열과 비정상 url은 null을 반환한다', () {
      expect(AppImageCachePolicy.cacheKeyFor(''), isNull);
      expect(AppImageCachePolicy.cacheKeyFor('   '), isNull);
      expect(AppImageCachePolicy.cacheKeyFor('not-a-signed-url'), isNull);
    });
  });
}
