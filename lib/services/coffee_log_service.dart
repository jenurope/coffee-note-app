import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/coffee_log.dart';

class CoffeeLogService {
  final SupabaseClient _client;

  CoffeeLogService(this._client);

  // 커피 로그 목록 조회
  Future<List<CoffeeLog>> getLogs({
    String? userId,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    double? minRating,
    String? coffeeType,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('coffee_logs').select();

      // 사용자 필터
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      // 검색어 필터
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'coffee_name.ilike.%$searchQuery%,cafe_name.ilike.%$searchQuery%,notes.ilike.%$searchQuery%',
        );
      }

      // 평점 필터
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      // 커피 종류 필터
      if (coffeeType != null) {
        query = query.eq('coffee_type', coffeeType);
      }

      // 정렬 및 페이지네이션
      final orderColumn = sortBy ?? 'cafe_visit_date';

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
          .map((e) => CoffeeLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get logs error: $e');
      rethrow;
    }
  }

  // 커피 로그 상세 조회
  Future<CoffeeLog?> getLog(String id) async {
    try {
      final response =
          await _client.from('coffee_logs').select().eq('id', id).maybeSingle();

      if (response != null) {
        return CoffeeLog.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Get log error: $e');
      rethrow;
    }
  }

  // 커피 로그 추가
  Future<CoffeeLog> createLog(CoffeeLog log) async {
    try {
      final response = await _client
          .from('coffee_logs')
          .insert(log.toInsertJson())
          .select()
          .single();

      return CoffeeLog.fromJson(response);
    } catch (e) {
      debugPrint('Create log error: $e');
      rethrow;
    }
  }

  // 커피 로그 수정
  Future<CoffeeLog> updateLog(CoffeeLog log) async {
    try {
      final response = await _client
          .from('coffee_logs')
          .update({
            ...log.toInsertJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', log.id)
          .select()
          .single();

      return CoffeeLog.fromJson(response);
    } catch (e) {
      debugPrint('Update log error: $e');
      rethrow;
    }
  }

  // 커피 로그 삭제
  Future<void> deleteLog(String id) async {
    try {
      await _client.from('coffee_logs').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete log error: $e');
      rethrow;
    }
  }

  // 사용자의 커피 로그 통계
  Future<Map<String, dynamic>> getUserLogStats(String userId) async {
    try {
      final logs = await _client
          .from('coffee_logs')
          .select('id, rating, coffee_type')
          .eq('user_id', userId);

      final count = (logs as List).length;
      final avgRating = count > 0
          ? logs.fold<double>(0, (sum, l) => sum + (l['rating'] as num))
                  / count
          : 0.0;

      // 커피 타입별 카운트
      final typeCount = <String, int>{};
      for (final log in logs) {
        final type = log['coffee_type'] as String;
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }

      return {
        'totalCount': count,
        'averageRating': avgRating,
        'typeCount': typeCount,
      };
    } catch (e) {
      debugPrint('Get user log stats error: $e');
      return {'totalCount': 0, 'averageRating': 0.0, 'typeCount': {}};
    }
  }
}
