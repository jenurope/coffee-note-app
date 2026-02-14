import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../../services/community_service.dart';
import '../../services/guest_sample_service.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit({
    CommunityService? service,
    AuthCubit? authCubit,
    GuestSampleService? sampleService,
  }) : _service = service ?? getIt<CommunityService>(),
       _authCubit = authCubit,
       _sampleService = sampleService ?? getIt<GuestSampleService>(),
       super(const PostDetailState.initial());

  final CommunityService _service;
  final AuthCubit? _authCubit;
  final GuestSampleService _sampleService;

  Future<void> load(String postId) async {
    emit(const PostDetailState.loading());
    try {
      final authState = _authCubit?.state;
      if (authState is AuthGuest) {
        final post = await _sampleService.getPost(postId);
        if (post != null) {
          emit(PostDetailState.loaded(post: post));
        } else {
          emit(const PostDetailState.error(message: '샘플 게시글을 찾을 수 없습니다.'));
        }
        return;
      }

      if (authState != null && authState is! AuthAuthenticated) {
        emit(const PostDetailState.error(message: '로그인이 필요합니다.'));
        return;
      }

      final post = await _service.getPost(postId);
      if (post != null) {
        emit(PostDetailState.loaded(post: post));
      } else {
        emit(const PostDetailState.error(message: '게시글을 찾을 수 없습니다.'));
      }
    } catch (e) {
      debugPrint('PostDetailCubit.load error: $e');
      emit(PostDetailState.error(message: e.toString()));
    }
  }
}
