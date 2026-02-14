import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/community_post.dart';
import 'post_filters.dart';

part 'post_list_state.freezed.dart';

@freezed
sealed class PostListState with _$PostListState {
  const factory PostListState.initial() = PostListInitial;
  const factory PostListState.loading({required PostFilters filters}) =
      PostListLoading;
  const factory PostListState.loaded({
    required List<CommunityPost> posts,
    required PostFilters filters,
  }) = PostListLoaded;
  const factory PostListState.error({
    required String message,
    required PostFilters filters,
  }) = PostListError;
}
