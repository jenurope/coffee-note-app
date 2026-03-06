import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import 'my_comment_list_state.dart';

enum _MyCommentListScope { authored, liked }

class MyCommentListCubit extends Cubit<MyCommentListState> {
  MyCommentListCubit({CommunityService? service, AuthCubit? authCubit})
    : _service = service ?? getIt<CommunityService>(),
      _authCubit = authCubit,
      super(const MyCommentListState.initial());

  static const int _defaultPageSize = 20;

  final CommunityService _service;
  final AuthCubit? _authCubit;
  String? _activeUserId;
  _MyCommentListScope _activeScope = _MyCommentListScope.authored;
  int _nextOffset = 0;

  Future<void> loadForUser(String userId) async {
    await _loadScoped(userId: userId, scope: _MyCommentListScope.authored);
  }

  Future<void> loadLikedByUser(String userId) async {
    await _loadScoped(userId: userId, scope: _MyCommentListScope.liked);
  }

  Future<void> _loadScoped({
    required String? userId,
    required _MyCommentListScope scope,
  }) async {
    _activeScope = scope;
    _activeUserId = _normalizeUserId(userId);
    emit(const MyCommentListState.loading());

    try {
      final authState = _authCubit?.state;
      final targetUserId = _activeUserId;
      if (authState is AuthAuthenticated && targetUserId != null) {
        final comments = await _fetchComments(
          userId: targetUserId,
          limit: _defaultPageSize,
          offset: 0,
        );
        final filteredComments = await _filterCommentsForMyList(comments);
        _nextOffset = comments.length;
        emit(
          MyCommentListState.loaded(
            comments: filteredComments,
            hasMore: comments.length == _defaultPageSize,
          ),
        );
        return;
      }

      _nextOffset = 0;
      emit(const MyCommentListState.loaded(comments: [], hasMore: false));
    } catch (e) {
      debugPrint('MyCommentListCubit.loadForUser error: $e');
      _nextOffset = 0;
      emit(
        MyCommentListState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errRequestFailed'),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    final targetUserId = _activeUserId;
    if (currentState is! MyCommentListLoaded || targetUserId == null) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextComments = await _fetchComments(
        userId: targetUserId,
        limit: _defaultPageSize,
        offset: _nextOffset,
      );
      final filteredNextComments = await _filterCommentsForMyList(nextComments);
      _nextOffset += nextComments.length;

      emit(
        currentState.copyWith(
          comments: [...currentState.comments, ...filteredNextComments],
          isLoadingMore: false,
          hasMore: nextComments.length == _defaultPageSize,
        ),
      );
    } catch (e) {
      debugPrint('MyCommentListCubit.loadMore error: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> reload() async {
    await _loadScoped(userId: _activeUserId, scope: _activeScope);
  }

  void applyCommentLike({
    required String commentId,
    required bool isLikedByMe,
    required int likeCount,
  }) {
    final currentState = state;
    if (currentState is! MyCommentListLoaded) return;

    if (_activeScope == _MyCommentListScope.liked && !isLikedByMe) {
      final updatedComments = currentState.comments
          .where((comment) => comment.id != commentId)
          .toList(growable: false);
      if (updatedComments.length == currentState.comments.length) {
        return;
      }
      emit(currentState.copyWith(comments: updatedComments));
      return;
    }

    var updated = false;
    final updatedComments = currentState.comments
        .map((comment) {
          if (comment.id != commentId) {
            return comment;
          }
          updated = true;
          return comment.copyWith(
            isLikedByMe: isLikedByMe,
            likeCount: likeCount,
          );
        })
        .toList(growable: false);
    if (!updated) return;

    emit(currentState.copyWith(comments: updatedComments));
  }

  void reset() {
    _activeUserId = null;
    _activeScope = _MyCommentListScope.authored;
    _nextOffset = 0;
    emit(const MyCommentListState.initial());
  }

  String? _normalizeUserId(String? userId) {
    final normalized = userId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Future<List<CommunityComment>> _filterCommentsForMyList(
    List<CommunityComment> comments,
  ) async {
    final parentIds = comments
        .map((comment) => comment.parentId)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    if (parentIds.isEmpty) {
      return comments;
    }

    final parentDeletionStatus = await _service.getCommentDeletionStatusByIds(
      commentIds: parentIds,
    );
    return comments
        .where((comment) {
          final parentId = comment.parentId;
          if (parentId == null) return true;
          return parentDeletionStatus[parentId] != true;
        })
        .toList(growable: false);
  }

  Future<List<CommunityComment>> _fetchComments({
    required String userId,
    required int limit,
    required int offset,
  }) {
    if (_activeScope == _MyCommentListScope.liked) {
      return _service.getLikedCommentsByUser(
        userId: userId,
        limit: limit,
        offset: offset,
        ascending: false,
        includeDeleted: false,
      );
    }
    return _service.getCommentsByUser(
      userId: userId,
      limit: limit,
      offset: offset,
      ascending: false,
      includeDeleted: false,
    );
  }
}
