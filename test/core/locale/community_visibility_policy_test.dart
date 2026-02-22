import 'dart:ui';

import 'package:coffee_note_app/core/locale/community_visibility_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isCommunityVisible', () {
    test('ko + US 조합은 커뮤니티를 노출한다', () {
      final visible = isCommunityVisible(
        appLocale: const Locale('ko'),
        deviceLocale: const Locale('en', 'US'),
      );

      expect(visible, isTrue);
    });

    test('en + KR 조합은 커뮤니티를 노출한다', () {
      final visible = isCommunityVisible(
        appLocale: const Locale('en'),
        deviceLocale: const Locale('en', 'KR'),
      );

      expect(visible, isTrue);
    });

    test('ja + JP 조합은 커뮤니티를 숨긴다', () {
      final visible = isCommunityVisible(
        appLocale: const Locale('ja'),
        deviceLocale: const Locale('ja', 'JP'),
      );

      expect(visible, isFalse);
    });

    test('app locale 이 null 이어도 device 국가가 KR 이면 노출한다', () {
      final visible = isCommunityVisible(
        appLocale: null,
        deviceLocale: const Locale('en', 'KR'),
      );

      expect(visible, isTrue);
    });

    test('en + 국가코드 없음 조합은 커뮤니티를 숨긴다', () {
      final visible = isCommunityVisible(
        appLocale: const Locale('en'),
        deviceLocale: const Locale('en'),
      );

      expect(visible, isFalse);
    });
  });

  group('isCommunityPath', () {
    test('/community 경로를 커뮤니티 경로로 판단한다', () {
      expect(isCommunityPath('/community'), isTrue);
    });

    test('/community/new 경로를 커뮤니티 경로로 판단한다', () {
      expect(isCommunityPath('/community/new'), isTrue);
    });

    test('비커뮤니티 경로는 false 를 반환한다', () {
      expect(isCommunityPath('/beans'), isFalse);
      expect(isCommunityPath('/auth/login'), isFalse);
    });
  });
}
