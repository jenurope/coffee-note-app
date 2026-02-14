import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:coffee_note_app/services/guest_sample_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockCommunityService extends Mock implements CommunityService {}

void main() {
  group('PostListCubit', () {
    late _MockCommunityService communityService;
    late GuestSampleService sampleService;

    setUp(() {
      communityService = _MockCommunityService();
      sampleService = GuestSampleService();
    });

    test('게스트 모드에서는 로컬 샘플 게시글을 로드한다', () async {
      final authCubit = AuthCubit.test(const AuthState.guest());
      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<PostListLoaded>());
      expect((state as PostListLoaded).posts, isNotEmpty);
      verifyZeroInteractions(communityService);
    });

    test('비로그인 상태에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.unauthenticated());
      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<PostListLoaded>());
      expect((state as PostListLoaded).posts, isEmpty);
      verifyZeroInteractions(communityService);
    });

    test('인증 사용자에서는 서버 게시글을 로드한다', () async {
      final user = _testUser('auth-post-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 14, 12);
      final post = CommunityPost(
        id: 'server-post-1',
        userId: user.id,
        title: '서버 게시글',
        content: '서버에서 가져온 데이터',
        createdAt: now,
        updatedAt: now,
        author: UserProfile(
          id: user.id,
          nickname: '서버유저',
          email: user.email ?? '',
          createdAt: now,
          updatedAt: now,
        ),
        commentCount: 0,
      );
      when(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          limit: null,
          offset: null,
        ),
      ).thenAnswer((_) async => [post]);

      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<PostListLoaded>());
      expect((state as PostListLoaded).posts.single.id, 'server-post-1');
      verify(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });
  });
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-14T00:00:00.000Z',
  );
}
