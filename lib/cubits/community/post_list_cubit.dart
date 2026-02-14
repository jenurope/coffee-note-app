import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../services/community_service.dart';
import 'post_filters.dart';
import 'post_list_state.dart';

class PostListCubit extends Cubit<PostListState> {
  PostListCubit({CommunityService? service})
    : _service = service ?? getIt<CommunityService>(),
      super(const PostListState.initial());

  final CommunityService _service;

  Future<void> load([PostFilters filters = const PostFilters()]) async {
    emit(PostListState.loading(filters: filters));
    try {
      final posts = await _service.getPosts(
        searchQuery: filters.searchQuery,
        sortBy: filters.sortBy,
        ascending: filters.ascending,
        limit: filters.limit,
        offset: filters.offset,
      );
      emit(PostListState.loaded(posts: posts, filters: filters));
    } catch (e) {
      debugPrint('PostListCubit.load error: $e');
      emit(PostListState.error(message: e.toString(), filters: filters));
    }
  }

  Future<void> reload() async {
    final currentFilters = switch (state) {
      PostListLoading(filters: final f) => f,
      PostListLoaded(filters: final f) => f,
      PostListError(filters: final f) => f,
      _ => const PostFilters(),
    };
    await load(currentFilters);
  }

  Future<void> updateFilters(PostFilters filters) async {
    await load(filters);
  }
}
