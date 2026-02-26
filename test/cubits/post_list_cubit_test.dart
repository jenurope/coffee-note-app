import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockCommunityService extends Mock implements CommunityService {}

void main() {
  group('PostListCubit', () {
    late _MockCommunityService communityService;

    setUp(() {
      communityService = _MockCommunityService();
    });

    test('게스트 모드에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.guest());
      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<PostListLoaded>());
      expect((state as PostListLoaded).posts, isEmpty);
      verifyZeroInteractions(communityService);
    });

    test('비로그인 상태에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.unauthenticated());
      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
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
          userId: null,
          includeDeletedPosts: true,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer((_) async => [post]);

      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
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
          userId: null,
          includeDeletedPosts: true,
          limit: 20,
          offset: 0,
        ),
      ).called(1);
    });

    test('다음 페이지를 이어 로드하고 마지막 페이지에서 hasMore를 false로 바꾼다', () async {
      final user = _testUser('auth-post-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 14, 12);
      final firstPagePosts = List.generate(
        20,
        (index) => _buildPost(
          id: 'post-$index',
          userId: user.id,
          createdAt: now.add(Duration(minutes: index)),
        ),
      );
      final secondPagePosts = [
        _buildPost(
          id: 'post-20',
          userId: user.id,
          createdAt: now.add(const Duration(minutes: 20)),
        ),
      ];

      when(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: null,
          includeDeletedPosts: true,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer((_) async => firstPagePosts);
      when(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: null,
          includeDeletedPosts: true,
          limit: 20,
          offset: 20,
        ),
      ).thenAnswer((_) async => secondPagePosts);

      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.load();
      await cubit.loadMore();

      final state = cubit.state;
      expect(state, isA<PostListLoaded>());
      final loaded = state as PostListLoaded;
      expect(loaded.posts, hasLength(21));
      expect(loaded.posts.last.id, 'post-20');
      expect(loaded.hasMore, isFalse);
      expect(loaded.isLoadingMore, isFalse);
    });

    test('loadForUser는 userId 필터로 게시글을 로드한다', () async {
      final user = _testUser('auth-post-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 14, 12);
      final post = _buildPost(
        id: 'target-post',
        userId: 'target-user',
        createdAt: now,
      );

      when(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: 'target-user',
          includeDeletedPosts: false,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer((_) async => [post]);

      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser('target-user');

      final state = cubit.state;
      expect(state, isA<PostListLoaded>());
      expect((state as PostListLoaded).posts.single.userId, 'target-user');
      verify(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: 'target-user',
          includeDeletedPosts: false,
          limit: 20,
          offset: 0,
        ),
      ).called(1);
    });

    test('loadForUser 이후 loadMore/reload도 동일한 userId 필터를 유지한다', () async {
      final user = _testUser('auth-post-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 14, 12);
      final firstPagePosts = List.generate(
        20,
        (index) => _buildPost(
          id: 'target-post-$index',
          userId: 'target-user',
          createdAt: now.add(Duration(minutes: index)),
        ),
      );
      final secondPagePosts = [
        _buildPost(
          id: 'target-post-20',
          userId: 'target-user',
          createdAt: now.add(const Duration(minutes: 20)),
        ),
      ];

      when(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: 'target-user',
          includeDeletedPosts: false,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer((_) async => firstPagePosts);
      when(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: 'target-user',
          includeDeletedPosts: false,
          limit: 20,
          offset: 20,
        ),
      ).thenAnswer((_) async => secondPagePosts);

      final cubit = PostListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser('target-user');
      await cubit.loadMore();
      await cubit.reload();

      verify(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: 'target-user',
          includeDeletedPosts: false,
          limit: 20,
          offset: 0,
        ),
      ).called(2);
      verify(
        () => communityService.getPosts(
          searchQuery: null,
          sortBy: null,
          ascending: false,
          userId: 'target-user',
          includeDeletedPosts: false,
          limit: 20,
          offset: 20,
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

CommunityPost _buildPost({
  required String id,
  required String userId,
  required DateTime createdAt,
}) {
  return CommunityPost(
    id: id,
    userId: userId,
    title: '게시글 $id',
    content: '내용 $id',
    createdAt: createdAt,
    updatedAt: createdAt,
    commentCount: 0,
  );
}
