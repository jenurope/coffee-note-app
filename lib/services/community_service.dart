import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/community_post.dart';

class CommunityService {
  final _client = SupabaseConfig.client;

  // 게시글 목록 조회
  Future<List<CommunityPost>> getPosts({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('community_posts').select('''
        *,
        profiles!community_posts_user_id_fkey(id, nickname, avatar_url)
      ''');

      // 검색어 필터
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,content.ilike.%$searchQuery%',
        );
      }

      // 정렬 및 페이지네이션
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
          .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get posts error: $e');
      rethrow;
    }
  }

  // 게시글 상세 조회 (댓글 포함)
  Future<CommunityPost?> getPost(String id) async {
    try {
      final response = await _client.from('community_posts').select('''
        *,
        profiles!community_posts_user_id_fkey(id, nickname, avatar_url),
        community_comments(
          *,
          profiles!community_comments_user_id_fkey(id, nickname, avatar_url)
        )
      ''').eq('id', id).maybeSingle();

      if (response != null) {
        return CommunityPost.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Get post error: $e');
      rethrow;
    }
  }

  // 게시글 추가
  Future<CommunityPost> createPost(CommunityPost post) async {
    try {
      final response = await _client
          .from('community_posts')
          .insert(post.toInsertJson())
          .select()
          .single();

      return CommunityPost.fromJson(response);
    } catch (e) {
      debugPrint('Create post error: $e');
      rethrow;
    }
  }

  // 게시글 수정
  Future<CommunityPost> updatePost(CommunityPost post) async {
    try {
      final response = await _client
          .from('community_posts')
          .update({
            ...post.toInsertJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', post.id)
          .select()
          .single();

      return CommunityPost.fromJson(response);
    } catch (e) {
      debugPrint('Update post error: $e');
      rethrow;
    }
  }

  // 게시글 삭제
  Future<void> deletePost(String id) async {
    try {
      // 댓글 먼저 삭제
      await _client.from('community_comments').delete().eq('post_id', id);
      // 게시글 삭제
      await _client.from('community_posts').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete post error: $e');
      rethrow;
    }
  }

  // 댓글 추가
  Future<CommunityComment> createComment(CommunityComment comment) async {
    try {
      final response = await _client
          .from('community_comments')
          .insert(comment.toInsertJson())
          .select()
          .single();

      return CommunityComment.fromJson(response);
    } catch (e) {
      debugPrint('Create comment error: $e');
      rethrow;
    }
  }

  // 댓글 삭제
  Future<void> deleteComment(String id) async {
    try {
      await _client.from('community_comments').delete().eq('id', id);
    } catch (e) {
      debugPrint('Delete comment error: $e');
      rethrow;
    }
  }
}
