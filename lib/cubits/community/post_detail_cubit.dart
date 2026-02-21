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
        final comments = await _service.getComments(
          postId: postId,
          limit: _defaultCommentPageSize,
          offset: 0,
          ascending: false,
        );
        final postWithComments = post.copyWith(comments: comments);
        emit(
          PostDetailState.loaded(
            post: postWithComments,
            hasMoreComments: _hasMoreComments(
              totalCount: post.commentCount,
              loadedCount: comments.length,
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
      final mergedComments = [...currentComments, ...nextComments];

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
}
