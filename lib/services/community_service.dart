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
  Future<CommunityPost?> getPost(
    String id, {
    bool includeComments = true,
  }) async {
    try {
      final response = await _getPostInternal(
        id: id,
        includeAvatar: true,
        includeProfiles: true,
        includeComments: includeComments,
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
          includeComments: includeComments,
        );
        return fallback == null ? null : CommunityPost.fromJson(fallback);
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        final noProfile = await _getPostInternal(
          id: id,
          includeAvatar: false,
          includeProfiles: false,
          includeComments: includeComments,
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

  Future<List<CommunityComment>> getComments({
    required String postId,
    int limit = 20,
    int offset = 0,
    bool ascending = false,
  }) async {
    try {
      return await _getCommentsInternal(
        postId: postId,
        includeAvatar: true,
        includeProfiles: true,
        limit: limit,
        offset: offset,
        ascending: ascending,
      );
    } on PostgrestException catch (e) {
      if (!_shouldRetryWithoutAvatar(e)) {
        debugPrint('Get comments error: $e');
        rethrow;
      }

      try {
        return await _getCommentsInternal(
          postId: postId,
          includeAvatar: false,
          includeProfiles: true,
          limit: limit,
          offset: offset,
          ascending: ascending,
        );
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        return _getCommentsInternal(
          postId: postId,
          includeAvatar: false,
          includeProfiles: false,
          limit: limit,
          offset: offset,
          ascending: ascending,
        );
      }
    } catch (e) {
      debugPrint('Get comments error: $e');
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
      final sanitizedQuery = _sanitizeSearchQuery(searchQuery);
      if (sanitizedQuery.isNotEmpty) {
        final pattern = '%$sanitizedQuery%';
        query = query.or('title.ilike.$pattern,content.ilike.$pattern');
      }
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

  Future<Map<String, dynamic>?> _getPostInternal({
    required String id,
    required bool includeAvatar,
    required bool includeProfiles,
    required bool includeComments,
  }) {
    return _client
        .from('community_posts')
        .select(
          _postDetailSelect(
            includeAvatar,
            includeProfiles,
            includeComments: includeComments,
          ),
        )
        .eq('id', id)
        .maybeSingle();
  }

  Future<List<CommunityComment>> _getCommentsInternal({
    required String postId,
    required bool includeAvatar,
    required bool includeProfiles,
    required int limit,
    required int offset,
    required bool ascending,
  }) async {
    final response = await _client
        .from('community_comments')
        .select(_commentSelect(includeAvatar, includeProfiles))
        .eq('post_id', postId)
        .order('created_at', ascending: ascending)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
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

  String _postDetailSelect(
    bool includeAvatar,
    bool includeProfiles, {
    required bool includeComments,
  }) {
    if (!includeProfiles) {
      if (!includeComments) return '*';
      return '''
        *,
        community_comments(*)
      ''';
    }

    if (!includeComments) {
      return '''
        *,
        profiles!community_posts_user_id_fkey(
          ${_profileColumns(includeAvatar)}
        )
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

  String _commentSelect(bool includeAvatar, bool includeProfiles) {
    if (!includeProfiles) return '*';

    return '''
      *,
      profiles!community_comments_user_id_fkey(
        ${_profileColumns(includeAvatar)}
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
