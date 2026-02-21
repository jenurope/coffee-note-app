import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/coffee_log.dart';
import 'image_upload_service.dart';

class CoffeeLogService {
  final SupabaseClient _client;
  static const int _signedUrlExpiresInSeconds = 60 * 60;

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
        final sanitizedQuery = _sanitizeSearchQuery(searchQuery);
        if (sanitizedQuery.isNotEmpty) {
          final pattern = '%$sanitizedQuery%';
          query = query.or(
            'coffee_name.ilike.$pattern,cafe_name.ilike.$pattern,notes.ilike.$pattern',
          );
        }
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

      final logs = (response as List)
          .map((e) => CoffeeLog.fromJson(e as Map<String, dynamic>))
          .toList();
      return _resolveLogImageUrls(logs);
    } catch (e) {
      debugPrint('Get logs error: $e');
      rethrow;
    }
  }

  // 커피 로그 상세 조회
  Future<CoffeeLog?> getLog(String id) async {
    try {
      final response = await _client
          .from('coffee_logs')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        final log = CoffeeLog.fromJson(response);
        return _resolveLogImageUrl(log);
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

      final createdLog = CoffeeLog.fromJson(response);
      return _resolveLogImageUrl(createdLog);
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

      final updatedLog = CoffeeLog.fromJson(response);
      return _resolveLogImageUrl(updatedLog);
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
          ? logs.fold<double>(0, (sum, l) => sum + (l['rating'] as num)) / count
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

  String _sanitizeSearchQuery(String query) {
    final withoutControl = query.replaceAll(RegExp(r'[\r\n\t]'), ' ');
    final withoutOperators = withoutControl.replaceAll(
      RegExp(r'''[,()"';]'''),
      ' ',
    );
    final normalized = withoutOperators.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 100) {
      return normalized;
    }
    return normalized.substring(0, 100);
  }

  Future<List<CoffeeLog>> _resolveLogImageUrls(List<CoffeeLog> logs) {
    return Future.wait(logs.map(_resolveLogImageUrl));
  }

  Future<CoffeeLog> _resolveLogImageUrl(CoffeeLog log) async {
    final resolvedUrl = await _createSignedImageUrl(
      bucket: 'logs',
      imageReference: log.imageUrl,
    );
    if (resolvedUrl == null || resolvedUrl == log.imageUrl) {
      return log;
    }
    return log.copyWith(imageUrl: resolvedUrl);
  }

  Future<String?> _createSignedImageUrl({
    required String bucket,
    String? imageReference,
  }) async {
    final trimmed = imageReference?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return imageReference;
    }

    final filePath = ImageUploadService.extractFilePathFromReference(
      bucket: bucket,
      imageReference: trimmed,
    );
    if (filePath == null || filePath.isEmpty) {
      return imageReference;
    }

    try {
      return await _client.storage
          .from(bucket)
          .createSignedUrl(filePath, _signedUrlExpiresInSeconds);
    } catch (e) {
      debugPrint('Create signed image url error($bucket): $e');
      return imageReference;
    }
  }
}
