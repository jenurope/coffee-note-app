import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/coffee_bean.dart';
import '../models/bean_detail.dart';
import '../models/brew_detail.dart';

class CoffeeBeanService {
  final _client = SupabaseConfig.client;

  // 원두 목록 조회 (검색, 정렬, 필터 지원)
  Future<List<CoffeeBean>> getBeans({
    String? userId,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    double? minRating,
    String? roastLevel,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('coffee_beans').select('''
        *,
        bean_details(*),
        brew_details(*)
      ''');

      // 사용자 필터
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      // 검색어 필터
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,roastery.ilike.%$searchQuery%,tasting_notes.ilike.%$searchQuery%',
        );
      }

      // 평점 필터
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      // 로스팅 레벨 필터
      if (roastLevel != null) {
        query = query.eq('roast_level', roastLevel);
      }

      // 정렬 및 페이지네이션을 위한 최종 쿼리 빌드
      final orderColumn = sortBy ?? 'created_at';
      
      dynamic response;
      if (limit != null && offset != null) {
        response = await query
            .order(orderColumn, ascending: ascending)
            .range(offset, offset + limit - 1);
      } else if (limit != null) {
        response = await query
            .order(orderColumn, ascending: ascending)
            .limit(limit);
      } else {
        response = await query.order(orderColumn, ascending: ascending);
      }

      return (response as List)
          .map((e) => CoffeeBean.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get beans error: $e');
      rethrow;
    }
  }

  // 원두 상세 조회
  Future<CoffeeBean?> getBean(String id) async {
    try {
      final response = await _client.from('coffee_beans').select('''
        *,
        bean_details(*),
        brew_details(*)
      ''').eq('id', id).maybeSingle();

      if (response != null) {
        return CoffeeBean.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Get bean error: $e');
      rethrow;
    }
  }

  // 원두 추가
  Future<CoffeeBean> createBean(CoffeeBean bean) async {
    try {
      final response = await _client
          .from('coffee_beans')
          .insert(bean.toInsertJson())
          .select()
          .single();

      return CoffeeBean.fromJson(response);
    } catch (e) {
      debugPrint('Create bean error: $e');
      rethrow;
    }
  }

  // 원두 수정
  Future<CoffeeBean> updateBean(CoffeeBean bean) async {
    try {
      final response = await _client
          .from('coffee_beans')
          .update({
            ...bean.toInsertJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bean.id)
          .select()
          .single();

      return CoffeeBean.fromJson(response);
    } catch (e) {
      debugPrint('Update bean error: $e');
      rethrow;
    }
  }

  // 원두 삭제
  Future<void> deleteBean(String id) async {
    try {
      // Supabase의 Cascade Delete가 설정되어 있으므로 원두만 삭제하면 됩니다.
      await _client.from('coffee_beans').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete bean error: $e');
      rethrow;
    }
  }

  // 원두 상세 정보 추가
  Future<BeanDetail> addBeanDetail(BeanDetail detail) async {
    try {
      final response = await _client
          .from('bean_details')
          .insert(detail.toInsertJson())
          .select()
          .single();

      return BeanDetail.fromJson(response);
    } catch (e) {
      debugPrint('Add bean detail error: $e');
      rethrow;
    }
  }

  // 원두 상세 정보 삭제
  Future<void> deleteBeanDetail(String id) async {
    try {
      await _client.from('bean_details').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete bean detail error: $e');
      rethrow;
    }
  }

  // 추출 기록 추가
  Future<BrewDetail> addBrewDetail(BrewDetail detail) async {
    try {
      final response = await _client
          .from('brew_details')
          .insert(detail.toInsertJson())
          .select()
          .single();

      return BrewDetail.fromJson(response);
    } catch (e) {
      debugPrint('Add brew detail error: $e');
      rethrow;
    }
  }

  // 추출 기록 삭제
  Future<void> deleteBrewDetail(String id) async {
    try {
      await _client.from('brew_details').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete brew detail error: $e');
      rethrow;
    }
  }

  // 사용자의 원두 통계
  Future<Map<String, dynamic>> getUserBeanStats(String userId) async {
    try {
      final beans = await _client
          .from('coffee_beans')
          .select('id, rating')
          .eq('user_id', userId);

      final count = (beans as List).length;
      final avgRating = count > 0
          ? beans.fold<double>(0, (sum, b) => sum + (b['rating'] as num))
                  / count
          : 0.0;

      return {
        'totalCount': count,
        'averageRating': avgRating,
      };
    } catch (e) {
      debugPrint('Get user bean stats error: $e');
      return {'totalCount': 0, 'averageRating': 0.0};
    }
  }
}
