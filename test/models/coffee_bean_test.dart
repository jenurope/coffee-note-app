import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoffeeBean', () {
    test('brew_method/recipe 필드를 직렬화한다', () {
      final json = <String, dynamic>{
        'id': 'bean-1',
        'user_id': 'user-1',
        'name': '에티오피아',
        'roastery': '테스트',
        'purchase_date': '2026-02-27',
        'rating': 4.5,
        'tasting_notes': 'floral',
        'roast_level': 'light',
        'brew_method': 'pour_over',
        'recipe': '16g / 250ml, 2:30',
        'price': 19000,
        'purchase_location': '공식몰',
        'image_url': null,
        'created_at': '2026-02-27T09:00:00.000Z',
        'updated_at': '2026-02-27T09:00:00.000Z',
      };

      final bean = CoffeeBean.fromJson(json);
      expect(bean.brewMethod, 'pour_over');
      expect(bean.recipe, '16g / 250ml, 2:30');

      final insertJson = bean.toInsertJson();
      expect(insertJson['brew_method'], 'pour_over');
      expect(insertJson['recipe'], '16g / 250ml, 2:30');
    });

    test('빈 recipe 문자열은 상위 레이어에서 null 처리 가능하다', () {
      final bean = CoffeeBean(
        id: 'bean-2',
        userId: 'user-1',
        name: '콜롬비아',
        roastery: '테스트',
        purchaseDate: DateTime(2026, 2, 27),
        rating: 4.0,
        brewMethod: 'french_press',
        recipe: null,
        createdAt: DateTime(2026, 2, 27),
        updatedAt: DateTime(2026, 2, 27),
      );

      expect(bean.toInsertJson()['recipe'], isNull);
    });
  });
}
