import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/community_post.dart';

part 'post_detail_state.freezed.dart';

@freezed
sealed class PostDetailState with _$PostDetailState {
  const factory PostDetailState.initial() = PostDetailInitial;
  const factory PostDetailState.loading() = PostDetailLoading;
  const factory PostDetailState.loaded({
    required CommunityPost post,
    @Default(false) bool isLoadingMoreComments,
    @Default(true) bool hasMoreComments,
  }) = PostDetailLoaded;
  const factory PostDetailState.error({required String message}) =
      PostDetailError;
}
