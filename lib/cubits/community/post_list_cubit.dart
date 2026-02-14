import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
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

  final CommunityService _service;
  final AuthCubit? _authCubit;

  Future<void> load([PostFilters filters = const PostFilters()]) async {
    emit(PostListState.loading(filters: filters));
    try {
      final authState = _authCubit?.state;
      if (authState is AuthAuthenticated) {
        final posts = await _service.getPosts(
          searchQuery: filters.searchQuery,
          sortBy: filters.sortBy,
          ascending: filters.ascending,
          limit: filters.limit,
          offset: filters.offset,
        );
        emit(PostListState.loaded(posts: posts, filters: filters));
        return;
      }

      emit(PostListState.loaded(posts: const [], filters: filters));
    } catch (e) {
      debugPrint('PostListCubit.load error: $e');
      emit(PostListState.error(message: e.toString(), filters: filters));
    }
  }

  Future<void> onAuthStateChanged(AuthState authState) async {
    if (authState is AuthGuest || authState is AuthAuthenticated) {
      await load(_currentFilters());
      return;
    }

    reset();
  }

  void reset() {
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
    await load(_currentFilters());
  }

  Future<void> updateFilters(PostFilters filters) async {
    await load(filters);
  }
}
