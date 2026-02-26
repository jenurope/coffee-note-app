import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../models/community_post.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/community_service.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit({CommunityService? service, AuthCubit? authCubit})
    : _service = service ?? getIt<CommunityService>(),
      _authCubit = authCubit,
      super(const PostDetailState.initial());

  static const int _defaultCommentPageSize = 20;

  final CommunityService _service;
  final AuthCubit? _authCubit;

  Future<void> load(String postId) async {
    emit(const PostDetailState.loading());
    try {
      final authState = _authCubit?.state;
      if (authState != null && authState is! AuthAuthenticated) {
        emit(const PostDetailState.error(message: 'requiredLogin'));
        return;
      }

      final post = await _service.getPost(postId, includeComments: false);
      if (post != null) {
        if (post.isDeletedContent) {
          emit(const PostDetailState.error(message: 'errPostDeleted'));
          return;
        }
        final comments = await _service.getComments(
          postId: postId,
          limit: _defaultCommentPageSize,
          offset: 0,
          ascending: false,
        );
        final threadedComments = _buildThreadedComments(comments);
        final postWithComments = post.copyWith(comments: threadedComments);
        emit(
          PostDetailState.loaded(
            post: postWithComments,
            hasMoreComments: _hasMoreComments(
              totalCount: post.commentCount,
              loadedCount: threadedComments.length,
              fetchedCount: comments.length,
            ),
          ),
        );
      } else {
        emit(const PostDetailState.error(message: 'errPostNotFound'));
      }
    } catch (e) {
      debugPrint('PostDetailCubit.load error: $e');
      emit(
        PostDetailState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadPostDetail'),
        ),
      );
    }
  }

  Future<void> loadMoreComments() async {
    final currentState = state;
    if (currentState is! PostDetailLoaded) return;
    if (currentState.isLoadingMoreComments || !currentState.hasMoreComments) {
      return;
    }

    final currentComments =
        currentState.post.comments ?? const <CommunityComment>[];
    emit(currentState.copyWith(isLoadingMoreComments: true));

    try {
      final nextComments = await _service.getComments(
        postId: currentState.post.id,
        limit: _defaultCommentPageSize,
        offset: currentComments.length,
        ascending: false,
      );
      final mergedMap = <String, CommunityComment>{
        for (final comment in currentComments) comment.id: comment,
      };
      for (final comment in nextComments) {
        mergedMap[comment.id] = comment;
      }
      final mergedComments = _buildThreadedComments(mergedMap.values.toList());

      emit(
        currentState.copyWith(
          post: currentState.post.copyWith(comments: mergedComments),
          isLoadingMoreComments: false,
          hasMoreComments: _hasMoreComments(
            totalCount: currentState.post.commentCount,
            loadedCount: mergedComments.length,
            fetchedCount: nextComments.length,
          ),
        ),
      );
    } catch (e) {
      debugPrint('PostDetailCubit.loadMoreComments error: $e');
      emit(currentState.copyWith(isLoadingMoreComments: false));
    }
  }

  bool _hasMoreComments({
    required int? totalCount,
    required int loadedCount,
    required int fetchedCount,
  }) {
    if (totalCount != null) {
      return loadedCount < totalCount;
    }
    return fetchedCount == _defaultCommentPageSize;
  }

  List<CommunityComment> _buildThreadedComments(
    List<CommunityComment> comments,
  ) {
    if (comments.isEmpty) {
      return comments;
    }

    final commentById = <String, CommunityComment>{
      for (final comment in comments) comment.id: comment,
    };
    final roots = <CommunityComment>[];
    final repliesByParentId = <String, List<CommunityComment>>{};

    for (final comment in comments) {
      final parentId = comment.parentId;
      if (parentId == null) {
        roots.add(comment);
        continue;
      }

      final parent = commentById[parentId];
      if (parent != null && parent.parentId == null) {
        repliesByParentId
            .putIfAbsent(parentId, () => <CommunityComment>[])
            .add(comment);
        continue;
      }

      // 부모 댓글이 아직 로드되지 않았거나 부모 자체가 대댓글이면 단독 댓글처럼 표시합니다.
      roots.add(comment);
    }

    roots.sort(_sortByCreatedAtDesc);
    for (final replies in repliesByParentId.values) {
      replies.sort(_sortByCreatedAtAsc);
    }

    final ordered = <CommunityComment>[];
    for (final root in roots) {
      ordered.add(root);
      final replies = repliesByParentId[root.id];
      if (replies != null && replies.isNotEmpty) {
        ordered.addAll(replies);
      }
    }

    return ordered;
  }

  int _sortByCreatedAtDesc(CommunityComment a, CommunityComment b) {
    final createdAtCompare = b.createdAt.compareTo(a.createdAt);
    if (createdAtCompare != 0) {
      return createdAtCompare;
    }
    return b.id.compareTo(a.id);
  }

  int _sortByCreatedAtAsc(CommunityComment a, CommunityComment b) {
    final createdAtCompare = a.createdAt.compareTo(b.createdAt);
    if (createdAtCompare != 0) {
      return createdAtCompare;
    }
    return a.id.compareTo(b.id);
  }
}
