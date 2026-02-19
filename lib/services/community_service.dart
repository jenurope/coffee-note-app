import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_post.dart';

class CommunityService {
  final SupabaseClient _client;

  CommunityService(this._client);

  // 게시글 목록 조회
  Future<List<CommunityPost>> getPosts({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    try {
      return await _getPostsInternal(
        includeAvatar: true,
        includeProfiles: true,
        searchQuery: searchQuery,
        sortBy: sortBy,
        ascending: ascending,
        limit: limit,
        offset: offset,
      );
    } on PostgrestException catch (e) {
      if (!_shouldRetryWithoutAvatar(e)) {
        debugPrint('Get posts error: $e');
        rethrow;
      }

      try {
        return await _getPostsInternal(
          includeAvatar: false,
          includeProfiles: true,
          searchQuery: searchQuery,
          sortBy: sortBy,
          ascending: ascending,
          limit: limit,
          offset: offset,
        );
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        return _getPostsInternal(
          includeAvatar: false,
          includeProfiles: false,
          searchQuery: searchQuery,
          sortBy: sortBy,
          ascending: ascending,
          limit: limit,
          offset: offset,
        );
      }
    } catch (e) {
      debugPrint('Get posts error: $e');
      rethrow;
    }
  }

  // 게시글 상세 조회 (댓글 포함)
  Future<CommunityPost?> getPost(String id) async {
    try {
      final response = await _getPostInternal(
        id: id,
        includeAvatar: true,
        includeProfiles: true,
      );
      return response == null ? null : CommunityPost.fromJson(response);
    } on PostgrestException catch (e) {
      if (!_shouldRetryWithoutAvatar(e)) {
        debugPrint('Get post error: $e');
        rethrow;
      }

      try {
        final fallback = await _getPostInternal(
          id: id,
          includeAvatar: false,
          includeProfiles: true,
        );
        return fallback == null ? null : CommunityPost.fromJson(fallback);
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        final noProfile = await _getPostInternal(
          id: id,
          includeAvatar: false,
          includeProfiles: false,
        );
        return noProfile == null ? null : CommunityPost.fromJson(noProfile);
      }
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

  Future<List<CommunityPost>> _getPostsInternal({
    required bool includeAvatar,
    required bool includeProfiles,
    String? searchQuery,
    String? sortBy,
    required bool ascending,
    int? limit,
    int? offset,
  }) async {
    var query = _client
        .from('community_posts')
        .select(_postListSelect(includeAvatar, includeProfiles));

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'title.ilike.%$searchQuery%,content.ilike.%$searchQuery%',
      );
    }

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
  }

  Future<Map<String, dynamic>?> _getPostInternal({
    required String id,
    required bool includeAvatar,
    required bool includeProfiles,
  }) {
    return _client
        .from('community_posts')
        .select(_postDetailSelect(includeAvatar, includeProfiles))
        .eq('id', id)
        .maybeSingle();
  }

  String _postListSelect(bool includeAvatar, bool includeProfiles) {
    if (!includeProfiles) return '*';

    return '''
      *,
      profiles!community_posts_user_id_fkey(
        ${_profileColumns(includeAvatar)}
      )
    ''';
  }

  String _postDetailSelect(bool includeAvatar, bool includeProfiles) {
    if (!includeProfiles) {
      return '''
        *,
        community_comments(*)
      ''';
    }

    return '''
      *,
      profiles!community_posts_user_id_fkey(
        ${_profileColumns(includeAvatar)}
      ),
      community_comments(
        *,
        profiles!community_comments_user_id_fkey(
          ${_profileColumns(includeAvatar)}
        )
      )
    ''';
  }

  String _profileColumns(bool includeAvatar) {
    return includeAvatar
        ? '''
          id,
          nickname,
          avatar_url,
          created_at,
          updated_at
        '''
        : '''
          id,
          nickname,
          created_at,
          updated_at
        ''';
  }

  bool _shouldRetryWithoutAvatar(PostgrestException e) {
    if (e.code == '42501' || e.code == '42703') {
      return true;
    }

    final message = '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'
        .toLowerCase();
    return message.contains('avatar_url') || message.contains('permission');
  }

  bool _shouldRetryWithoutProfiles(PostgrestException e) {
    if (e.code == '42501' || e.code == 'PGRST108') {
      return true;
    }

    final message = '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'
        .toLowerCase();
    return message.contains('profiles') && message.contains('permission');
  }
}
