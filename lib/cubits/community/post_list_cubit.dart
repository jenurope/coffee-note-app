import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/errors/user_error_message.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/community_service.dart';
import 'post_filters.dart';
import 'post_list_state.dart';

class PostListCubit extends Cubit<PostListState> {
  PostListCubit({CommunityService? service, AuthCubit? authCubit})
    : _service = service ?? getIt<CommunityService>(),
      _authCubit = authCubit,
      super(const PostListState.initial());

  static const int _defaultPageSize = 20;

  final CommunityService _service;
  final AuthCubit? _authCubit;
  String? _activeUserId;

  Future<void> load([PostFilters filters = const PostFilters()]) async {
    await _loadScoped(filters: filters, userId: null);
  }

  Future<void> loadForUser(
    String userId, [
    PostFilters filters = const PostFilters(),
  ]) async {
    await _loadScoped(filters: filters, userId: userId);
  }

  Future<void> _loadScoped({
    required PostFilters filters,
    required String? userId,
  }) async {
    _activeUserId = _normalizeUserId(userId);
    final pageSize = _resolvePageSize(filters);
    final initialFilters = filters.copyWith(limit: pageSize, offset: 0);
    emit(PostListState.loading(filters: initialFilters));
    try {
      final authState = _authCubit?.state;
      if (authState is AuthAuthenticated) {
        final posts = await _service.getPosts(
          searchQuery: initialFilters.searchQuery,
          sortBy: initialFilters.sortBy,
          ascending: initialFilters.ascending,
          userId: _activeUserId,
          limit: pageSize,
          offset: 0,
        );
        emit(
          PostListState.loaded(
            posts: posts,
            filters: initialFilters,
            hasMore: posts.length == pageSize,
          ),
        );
        return;
      }

      emit(
        PostListState.loaded(
          posts: const [],
          filters: initialFilters,
          hasMore: false,
        ),
      );
    } catch (e) {
      debugPrint('PostListCubit.load error: $e');
      emit(
        PostListState.error(
          message: UserErrorMessage.from(e, fallbackKey: 'errLoadPosts'),
          filters: initialFilters,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! PostListLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    final pageSize = _resolvePageSize(currentState.filters);
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPosts = await _service.getPosts(
        searchQuery: currentState.filters.searchQuery,
        sortBy: currentState.filters.sortBy,
        ascending: currentState.filters.ascending,
        userId: _activeUserId,
        limit: pageSize,
        offset: currentState.posts.length,
      );

      emit(
        currentState.copyWith(
          posts: [...currentState.posts, ...nextPosts],
          isLoadingMore: false,
          hasMore: nextPosts.length == pageSize,
        ),
      );
    } catch (e) {
      debugPrint('PostListCubit.loadMore error: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> onAuthStateChanged(AuthState authState) async {
    if (authState is AuthGuest) {
      await load(_currentFilters());
      return;
    }

    if (authState is AuthAuthenticated) {
      final currentFilters = _currentFilters();
      if (_activeUserId != null) {
        await loadForUser(authState.user.id, currentFilters);
        return;
      }
      await load(currentFilters);
      return;
    }

    reset();
  }

  void reset() {
    _activeUserId = null;
    emit(const PostListState.initial());
  }

  PostFilters _currentFilters() {
    return switch (state) {
      PostListLoading(filters: final f) => f,
      PostListLoaded(filters: final f) => f,
      PostListError(filters: final f) => f,
      _ => const PostFilters(),
    };
  }

  Future<void> reload() async {
    await _loadScoped(filters: _currentFilters(), userId: _activeUserId);
  }

  Future<void> updateFilters(PostFilters filters) async {
    await _loadScoped(filters: filters, userId: _activeUserId);
  }

  int _resolvePageSize(PostFilters filters) {
    final limit = filters.limit;
    if (limit == null || limit <= 0) {
      return _defaultPageSize;
    }
    return limit;
  }

  String? _normalizeUserId(String? userId) {
    final normalized = userId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
