import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_post.dart';

class LikeToggleResult {
  final bool isLiked;
  final int likeCount;

  const LikeToggleResult({required this.isLiked, required this.likeCount});
}

class CommunityService {
  final SupabaseClient _client;
  static const int _maxReportReasonLength = 500;

  CommunityService(this._client);

  // 게시글 목록 조회
  Future<List<CommunityPost>> getPosts({
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
    String? userId,
    bool includeDeletedPosts = false,
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
        userId: userId,
        includeDeletedPosts: includeDeletedPosts,
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
          userId: userId,
          includeDeletedPosts: includeDeletedPosts,
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
          userId: userId,
          includeDeletedPosts: includeDeletedPosts,
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
      if (response == null) {
        return null;
      }
      return _attachPostAndCommentLikeMetadata(
        CommunityPost.fromJson(response),
      );
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
        if (fallback == null) {
          return null;
        }
        return _attachPostAndCommentLikeMetadata(
          CommunityPost.fromJson(fallback),
        );
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        final noProfile = await _getPostInternal(
          id: id,
          includeAvatar: false,
          includeProfiles: false,
          includeComments: includeComments,
        );
        if (noProfile == null) {
          return null;
        }
        return _attachPostAndCommentLikeMetadata(
          CommunityPost.fromJson(noProfile),
        );
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
      await _client.rpc(
        'soft_delete_community_post',
        params: {'p_post_id': id},
      );
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
      await _client
          .from('community_comments')
          .update({
            'content': '[deleted_comment]',
            'is_deleted_content': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('is_deleted_content', false);
    } catch (e) {
      debugPrint('Delete comment error: $e');
      rethrow;
    }
  }

  Future<LikeToggleResult> togglePostLike({required String postId}) async {
    final currentUserId = _requireCurrentUserId();

    try {
      final post = await _client
          .from('community_posts')
          .select('user_id,is_deleted_content,is_withdrawn_content')
          .eq('id', postId)
          .maybeSingle();

      if (post == null) {
        throw const FormatException('community_post_not_found');
      }

      final postOwnerId = post['user_id'] as String?;
      if (postOwnerId == null) {
        throw const FormatException('community_post_not_found');
      }

      if (postOwnerId == currentUserId) {
        throw const FormatException('community_post_like_own_forbidden');
      }

      if ((post['is_deleted_content'] as bool? ?? false) ||
          (post['is_withdrawn_content'] as bool? ?? false)) {
        throw const FormatException('community_post_like_unavailable');
      }

      final existingLike = await _client
          .from('community_post_likes')
          .select('post_id')
          .eq('post_id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      final isLiked = existingLike == null;
      if (isLiked) {
        await _client.from('community_post_likes').insert({
          'post_id': postId,
          'user_id': currentUserId,
        });
      } else {
        await _client
            .from('community_post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);
      }

      final likeCount = await _countPostLikes(postId);
      return LikeToggleResult(isLiked: isLiked, likeCount: likeCount);
    } catch (e) {
      debugPrint('Toggle post like error: $e');
      rethrow;
    }
  }

  Future<LikeToggleResult> toggleCommentLike({
    required String commentId,
  }) async {
    final currentUserId = _requireCurrentUserId();

    try {
      final comment = await _client
          .from('community_comments')
          .select('user_id,is_deleted_content,is_withdrawn_content')
          .eq('id', commentId)
          .maybeSingle();

      if (comment == null) {
        throw const FormatException('community_comment_not_found');
      }

      final commentOwnerId = comment['user_id'] as String?;
      if (commentOwnerId == null) {
        throw const FormatException('community_comment_not_found');
      }

      if (commentOwnerId == currentUserId) {
        throw const FormatException('community_comment_like_own_forbidden');
      }

      if ((comment['is_deleted_content'] as bool? ?? false) ||
          (comment['is_withdrawn_content'] as bool? ?? false)) {
        throw const FormatException('community_comment_like_unavailable');
      }

      final existingLike = await _client
          .from('community_comment_likes')
          .select('comment_id')
          .eq('comment_id', commentId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      final isLiked = existingLike == null;
      if (isLiked) {
        await _client.from('community_comment_likes').insert({
          'comment_id': commentId,
          'user_id': currentUserId,
        });
      } else {
        await _client
            .from('community_comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', currentUserId);
      }

      final likeCount = await _countCommentLikes(commentId);
      return LikeToggleResult(isLiked: isLiked, likeCount: likeCount);
    } catch (e) {
      debugPrint('Toggle comment like error: $e');
      rethrow;
    }
  }

  Future<void> reportPost({
    required String postId,
    required String userId,
    required String reason,
  }) {
    return _insertReport(
      userId: userId,
      reason: reason,
      targetType: 'post',
      postId: postId,
    );
  }

  Future<void> reportComment({
    required String commentId,
    required String userId,
    required String reason,
  }) {
    return _insertReport(
      userId: userId,
      reason: reason,
      targetType: 'comment',
      commentId: commentId,
    );
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

  Future<CommunityComment?> getCommentById({required String commentId}) async {
    try {
      return await _getCommentByIdInternal(
        commentId: commentId,
        includeAvatar: true,
        includeProfiles: true,
      );
    } on PostgrestException catch (e) {
      if (!_shouldRetryWithoutAvatar(e)) {
        debugPrint('Get comment by id error: $e');
        rethrow;
      }

      try {
        return await _getCommentByIdInternal(
          commentId: commentId,
          includeAvatar: false,
          includeProfiles: true,
        );
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        return _getCommentByIdInternal(
          commentId: commentId,
          includeAvatar: false,
          includeProfiles: false,
        );
      }
    } catch (e) {
      debugPrint('Get comment by id error: $e');
      rethrow;
    }
  }

  Future<List<CommunityComment>> getReplies({
    required String parentCommentId,
    int limit = 20,
    int offset = 0,
    bool ascending = true,
  }) async {
    try {
      return await _getRepliesInternal(
        parentCommentId: parentCommentId,
        includeAvatar: true,
        includeProfiles: true,
        limit: limit,
        offset: offset,
        ascending: ascending,
      );
    } on PostgrestException catch (e) {
      if (!_shouldRetryWithoutAvatar(e)) {
        debugPrint('Get replies error: $e');
        rethrow;
      }

      try {
        return await _getRepliesInternal(
          parentCommentId: parentCommentId,
          includeAvatar: false,
          includeProfiles: true,
          limit: limit,
          offset: offset,
          ascending: ascending,
        );
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        return _getRepliesInternal(
          parentCommentId: parentCommentId,
          includeAvatar: false,
          includeProfiles: false,
          limit: limit,
          offset: offset,
          ascending: ascending,
        );
      }
    } catch (e) {
      debugPrint('Get replies error: $e');
      rethrow;
    }
  }

  Future<List<CommunityComment>> getCommentsByUser({
    required String userId,
    int limit = 20,
    int offset = 0,
    bool ascending = false,
    bool includeDeleted = false,
  }) async {
    try {
      return await _getCommentsByUserInternal(
        userId: userId,
        includeAvatar: true,
        includeProfiles: true,
        limit: limit,
        offset: offset,
        ascending: ascending,
        includeDeleted: includeDeleted,
      );
    } on PostgrestException catch (e) {
      if (!_shouldRetryWithoutAvatar(e)) {
        debugPrint('Get comments by user error: $e');
        rethrow;
      }

      try {
        return await _getCommentsByUserInternal(
          userId: userId,
          includeAvatar: false,
          includeProfiles: true,
          limit: limit,
          offset: offset,
          ascending: ascending,
          includeDeleted: includeDeleted,
        );
      } on PostgrestException catch (fallbackError) {
        if (!_shouldRetryWithoutProfiles(fallbackError)) rethrow;

        return _getCommentsByUserInternal(
          userId: userId,
          includeAvatar: false,
          includeProfiles: false,
          limit: limit,
          offset: offset,
          ascending: ascending,
          includeDeleted: includeDeleted,
        );
      }
    } catch (e) {
      debugPrint('Get comments by user error: $e');
      rethrow;
    }
  }

  Future<Map<String, bool>> getCommentDeletionStatusByIds({
    required List<String> commentIds,
  }) async {
    if (commentIds.isEmpty) {
      return const <String, bool>{};
    }

    try {
      final response = await _client
          .from('community_comments')
          .select('id,is_deleted_content')
          .inFilter('id', commentIds);

      final statusById = <String, bool>{};
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final id = map['id'] as String?;
        if (id == null) continue;
        statusById[id] = map['is_deleted_content'] as bool? ?? false;
      }
      return statusById;
    } catch (e) {
      debugPrint('Get comment deletion status error: $e');
      rethrow;
    }
  }

  Future<List<CommunityPost>> _getPostsInternal({
    required bool includeAvatar,
    required bool includeProfiles,
    String? searchQuery,
    String? sortBy,
    required bool ascending,
    String? userId,
    required bool includeDeletedPosts,
    int? limit,
    int? offset,
  }) async {
    var query = _client
        .from('community_posts')
        .select(_postListSelect(includeAvatar, includeProfiles));

    if (userId != null && userId.isNotEmpty) {
      query = query.eq('user_id', userId);
    }
    if (!includeDeletedPosts) {
      query = query.eq('is_deleted_content', false);
    }

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

    final posts = (response as List)
        .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
        .toList();
    return _attachPostLikeMetadata(posts);
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

    final comments = (response as List)
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
    return _attachCommentLikeMetadata(comments);
  }

  Future<CommunityComment?> _getCommentByIdInternal({
    required String commentId,
    required bool includeAvatar,
    required bool includeProfiles,
  }) async {
    final response = await _client
        .from('community_comments')
        .select(_commentSelect(includeAvatar, includeProfiles))
        .eq('id', commentId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final comment = CommunityComment.fromJson(response);
    final comments = await _attachCommentLikeMetadata([comment]);
    return comments.first;
  }

  Future<List<CommunityComment>> _getRepliesInternal({
    required String parentCommentId,
    required bool includeAvatar,
    required bool includeProfiles,
    required int limit,
    required int offset,
    required bool ascending,
  }) async {
    final response = await _client
        .from('community_comments')
        .select(_commentSelect(includeAvatar, includeProfiles))
        .eq('parent_id', parentCommentId)
        .order('created_at', ascending: ascending)
        .range(offset, offset + limit - 1);

    final comments = (response as List)
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
    return _attachCommentLikeMetadata(comments);
  }

  Future<void> _insertReport({
    required String userId,
    required String reason,
    required String targetType,
    String? postId,
    String? commentId,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw const FormatException('report_reason_required');
    }
    if (trimmedReason.length > _maxReportReasonLength) {
      throw const FormatException('report_reason_too_long');
    }

    try {
      await _client.from('community_reports').insert({
        'user_id': userId,
        'target_type': targetType,
        'post_id': postId,
        'comment_id': commentId,
        'reason': trimmedReason,
      });
    } catch (e) {
      debugPrint('Create community report error: $e');
      rethrow;
    }
  }

  Future<List<CommunityComment>> _getCommentsByUserInternal({
    required String userId,
    required bool includeAvatar,
    required bool includeProfiles,
    required int limit,
    required int offset,
    required bool ascending,
    required bool includeDeleted,
  }) async {
    var query = _client
        .from('community_comments')
        .select(_commentSelect(includeAvatar, includeProfiles))
        .eq('user_id', userId);

    if (!includeDeleted) {
      query = query.eq('is_deleted_content', false);
    }

    final response = await query
        .order('created_at', ascending: ascending)
        .range(offset, offset + limit - 1);

    final comments = (response as List)
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
    return _attachCommentLikeMetadata(comments);
  }

  String _postListSelect(bool includeAvatar, bool includeProfiles) {
    if (!includeProfiles) {
      return '''
        *,
        comment_stats:community_comments(count)
      ''';
    }

    return '''
      *,
      profiles!community_posts_user_id_fkey(
        ${_profileColumns(includeAvatar)}
      ),
      comment_stats:community_comments(count)
    ''';
  }

  String _postDetailSelect(
    bool includeAvatar,
    bool includeProfiles, {
    required bool includeComments,
  }) {
    if (!includeProfiles) {
      if (!includeComments) {
        return '''
          *,
          comment_stats:community_comments(count)
        ''';
      }
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
        ),
        comment_stats:community_comments(count)
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
          is_withdrawn,
          avatar_url,
          created_at,
          updated_at
        '''
        : '''
          id,
          nickname,
          is_withdrawn,
          created_at,
          updated_at
        ''';
  }

  Future<CommunityPost> _attachPostAndCommentLikeMetadata(
    CommunityPost post,
  ) async {
    final postWithLike = (await _attachPostLikeMetadata([post])).first;
    final comments = postWithLike.comments;
    if (comments == null || comments.isEmpty) {
      return postWithLike;
    }

    final commentsWithLike = await _attachCommentLikeMetadata(comments);
    return postWithLike.copyWith(comments: commentsWithLike);
  }

  Future<List<CommunityPost>> _attachPostLikeMetadata(
    List<CommunityPost> posts,
  ) async {
    if (posts.isEmpty) {
      return posts;
    }

    final postIds = posts.map((post) => post.id).toSet().toList();
    final likeCountByPostId = await _loadPostLikeCountByPostIds(postIds);
    final likedPostIds = await _loadLikedPostIds(postIds);

    return posts
        .map(
          (post) => post.copyWith(
            likeCount: likeCountByPostId[post.id] ?? 0,
            isLikedByMe: likedPostIds.contains(post.id),
          ),
        )
        .toList(growable: false);
  }

  Future<List<CommunityComment>> _attachCommentLikeMetadata(
    List<CommunityComment> comments,
  ) async {
    if (comments.isEmpty) {
      return comments;
    }

    final commentIds = comments.map((comment) => comment.id).toSet().toList();
    final likeCountByCommentId = await _loadCommentLikeCountByCommentIds(
      commentIds,
    );
    final likedCommentIds = await _loadLikedCommentIds(commentIds);

    return comments
        .map(
          (comment) => comment.copyWith(
            likeCount: likeCountByCommentId[comment.id] ?? 0,
            isLikedByMe: likedCommentIds.contains(comment.id),
          ),
        )
        .toList(growable: false);
  }

  Future<Map<String, int>> _loadPostLikeCountByPostIds(
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) {
      return const <String, int>{};
    }

    try {
      final response = await _client
          .from('community_post_likes')
          .select('post_id')
          .inFilter('post_id', postIds);

      final countByPostId = <String, int>{};
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final postId = map['post_id'] as String?;
        if (postId == null) continue;
        countByPostId[postId] = (countByPostId[postId] ?? 0) + 1;
      }

      return countByPostId;
    } catch (e) {
      debugPrint('Load post like counts error: $e');
      return const <String, int>{};
    }
  }

  Future<Map<String, int>> _loadCommentLikeCountByCommentIds(
    List<String> commentIds,
  ) async {
    if (commentIds.isEmpty) {
      return const <String, int>{};
    }

    try {
      final response = await _client
          .from('community_comment_likes')
          .select('comment_id')
          .inFilter('comment_id', commentIds);

      final countByCommentId = <String, int>{};
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final commentId = map['comment_id'] as String?;
        if (commentId == null) continue;
        countByCommentId[commentId] = (countByCommentId[commentId] ?? 0) + 1;
      }

      return countByCommentId;
    } catch (e) {
      debugPrint('Load comment like counts error: $e');
      return const <String, int>{};
    }
  }

  Future<Set<String>> _loadLikedPostIds(List<String> postIds) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || postIds.isEmpty) {
      return const <String>{};
    }

    try {
      final response = await _client
          .from('community_post_likes')
          .select('post_id')
          .eq('user_id', currentUserId)
          .inFilter('post_id', postIds);

      final likedPostIds = <String>{};
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final postId = map['post_id'] as String?;
        if (postId == null) continue;
        likedPostIds.add(postId);
      }

      return likedPostIds;
    } catch (e) {
      debugPrint('Load liked post ids error: $e');
      return const <String>{};
    }
  }

  Future<Set<String>> _loadLikedCommentIds(List<String> commentIds) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || commentIds.isEmpty) {
      return const <String>{};
    }

    try {
      final response = await _client
          .from('community_comment_likes')
          .select('comment_id')
          .eq('user_id', currentUserId)
          .inFilter('comment_id', commentIds);

      final likedCommentIds = <String>{};
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        final commentId = map['comment_id'] as String?;
        if (commentId == null) continue;
        likedCommentIds.add(commentId);
      }

      return likedCommentIds;
    } catch (e) {
      debugPrint('Load liked comment ids error: $e');
      return const <String>{};
    }
  }

  Future<int> _countPostLikes(String postId) async {
    final response = await _client
        .from('community_post_likes')
        .select('post_id')
        .eq('post_id', postId);
    return (response as List).length;
  }

  Future<int> _countCommentLikes(String commentId) async {
    final response = await _client
        .from('community_comment_likes')
        .select('comment_id')
        .eq('comment_id', commentId);
    return (response as List).length;
  }

  String _requireCurrentUserId() {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw const FormatException('requiredLogin');
    }
    return currentUserId;
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
