import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
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
        emit(
          MyCommentListState.loaded(
            comments: comments,
            hasMore: comments.length == _defaultPageSize,
          ),
        );
        return;
      }

      emit(const MyCommentListState.loaded(comments: [], hasMore: false));
    } catch (e) {
      debugPrint('MyCommentListCubit.loadForUser error: $e');
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
        offset: currentState.comments.length,
        ascending: false,
        includeDeleted: false,
      );

      emit(
        currentState.copyWith(
          comments: [...currentState.comments, ...nextComments],
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
    emit(const MyCommentListState.initial());
  }

  String? _normalizeUserId(String? userId) {
    final normalized = userId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
