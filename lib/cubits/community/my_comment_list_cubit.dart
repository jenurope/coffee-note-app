import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import 'my_comment_list_state.dart';

class MyCommentListCubit extends Cubit<MyCommentListState> {
  MyCommentListCubit({CommunityService? service, AuthCubit? authCubit})
    : _service = service ?? getIt<CommunityService>(),
      _authCubit = authCubit,
      super(const MyCommentListState.initial());

  static const int _defaultPageSize = 20;

  final CommunityService _service;
  final AuthCubit? _authCubit;
  String? _activeUserId;
  int _nextOffset = 0;

  Future<void> loadForUser(String userId) async {
    await _loadScoped(userId: userId);
  }

  Future<void> _loadScoped({required String? userId}) async {
    _activeUserId = _normalizeUserId(userId);
    emit(const MyCommentListState.loading());

    try {
      final authState = _authCubit?.state;
      final targetUserId = _activeUserId;
      if (authState is AuthAuthenticated && targetUserId != null) {
        final comments = await _service.getCommentsByUser(
          userId: targetUserId,
          limit: _defaultPageSize,
          offset: 0,
          ascending: false,
          includeDeleted: false,
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
      final nextComments = await _service.getCommentsByUser(
        userId: targetUserId,
        limit: _defaultPageSize,
        offset: _nextOffset,
        ascending: false,
        includeDeleted: false,
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
    await _loadScoped(userId: _activeUserId);
  }

  void reset() {
    _activeUserId = null;
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
}
