import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/coffee_bean.dart';
import 'image_upload_service.dart';

class CoffeeBeanService {
  final SupabaseClient _client;
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  CoffeeBeanService(this._client);

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
      var query = _client.from('coffee_beans').select();

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
            'name.ilike.$pattern,roastery.ilike.$pattern,tasting_notes.ilike.$pattern',
          );
        }
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

      final beans = (response as List)
          .map((e) => CoffeeBean.fromJson(e as Map<String, dynamic>))
          .toList();
      return _resolveBeanImageUrls(beans);
    } catch (e) {
      debugPrint('Get beans error: $e');
      rethrow;
    }
  }

  // 원두 상세 조회
  Future<CoffeeBean?> getBean(String id) async {
    try {
      final response = await _client
          .from('coffee_beans')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        final bean = CoffeeBean.fromJson(response);
        return _resolveBeanImageUrl(bean);
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

      final createdBean = CoffeeBean.fromJson(response);
      return _resolveBeanImageUrl(createdBean);
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

      final updatedBean = CoffeeBean.fromJson(response);
      return _resolveBeanImageUrl(updatedBean);
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

  // 사용자의 원두 통계
  Future<Map<String, dynamic>> getUserBeanStats(String userId) async {
    try {
      final beans = await _client
          .from('coffee_beans')
          .select('id, rating')
          .eq('user_id', userId);

      final count = (beans as List).length;
      final avgRating = count > 0
          ? beans.fold<double>(0, (sum, b) => sum + (b['rating'] as num)) /
                count
          : 0.0;

      return {'totalCount': count, 'averageRating': avgRating};
    } catch (e) {
      debugPrint('Get user bean stats error: $e');
      return {'totalCount': 0, 'averageRating': 0.0};
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

  Future<List<CoffeeBean>> _resolveBeanImageUrls(List<CoffeeBean> beans) {
    return Future.wait(beans.map(_resolveBeanImageUrl));
  }

  Future<CoffeeBean> _resolveBeanImageUrl(CoffeeBean bean) async {
    final resolvedUrl = await _createSignedImageUrl(
      bucket: 'beans',
      imageReference: bean.imageUrl,
    );
    if (resolvedUrl == null || resolvedUrl == bean.imageUrl) {
      return bean;
    }
    return bean.copyWith(imageUrl: resolvedUrl);
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
