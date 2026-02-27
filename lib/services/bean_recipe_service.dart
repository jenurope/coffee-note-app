import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/bean_recipe.dart';

class BeanRecipeService {
  final SupabaseClient _client;

  BeanRecipeService(this._client);

  Future<List<BeanRecipe>> getRecipes(String userId) async {
    try {
      final response = await _client
          .from('bean_recipes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => BeanRecipe.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      debugPrint('Get bean recipes error: $e');
      rethrow;
    }
  }

  Future<BeanRecipe> createRecipe(BeanRecipe recipe) async {
    try {
      final response = await _client
          .from('bean_recipes')
          .insert(recipe.toInsertJson())
          .select()
          .single();

      return BeanRecipe.fromJson(response);
    } catch (e) {
      debugPrint('Create bean recipe error: $e');
      rethrow;
    }
  }

  Future<BeanRecipe> updateRecipe(BeanRecipe recipe) async {
    try {
      final response = await _client
          .from('bean_recipes')
          .update({
            ...recipe.toInsertJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recipe.id)
          .select()
          .single();

      return BeanRecipe.fromJson(response);
    } catch (e) {
      debugPrint('Update bean recipe error: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _client.from('bean_recipes').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete bean recipe error: $e');
      rethrow;
    }
  }
}
