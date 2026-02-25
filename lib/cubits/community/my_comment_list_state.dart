import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/community_post.dart';

part 'my_comment_list_state.freezed.dart';

@freezed
sealed class MyCommentListState with _$MyCommentListState {
  const factory MyCommentListState.initial() = MyCommentListInitial;
  const factory MyCommentListState.loading() = MyCommentListLoading;
  const factory MyCommentListState.loaded({
    required List<CommunityComment> comments,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
  }) = MyCommentListLoaded;
  const factory MyCommentListState.error({required String message}) =
      MyCommentListError;
}
