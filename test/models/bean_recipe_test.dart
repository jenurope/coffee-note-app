import 'package:coffee_note_app/models/bean_recipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeanRecipe', () {
    test('fromJson/toInsertJson 직렬화가 정상 동작한다', () {
      final json = <String, dynamic>{
        'id': 'recipe-1',
        'user_id': 'user-1',
        'name': '아침 핸드드립',
        'brew_method': 'pour_over',
        'recipe': '16g / 250ml, 2:30',
        'created_at': '2026-02-27T10:00:00.000Z',
        'updated_at': '2026-02-27T10:00:00.000Z',
      };

      final recipe = BeanRecipe.fromJson(json);
      expect(recipe.id, 'recipe-1');
      expect(recipe.brewMethod, 'pour_over');

      expect(recipe.toInsertJson(), <String, dynamic>{
        'user_id': 'user-1',
        'name': '아침 핸드드립',
        'brew_method': 'pour_over',
        'recipe': '16g / 250ml, 2:30',
      });
    });
  });
}
