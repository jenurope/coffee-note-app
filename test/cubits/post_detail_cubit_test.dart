import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_detail_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_detail_state.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockCommunityService extends Mock implements CommunityService {}

void main() {
  group('PostDetailCubit', () {
    late _MockCommunityService communityService;

    setUp(() {
      communityService = _MockCommunityService();
    });

    test('인증 사용자에서 게시글과 댓글 첫 페이지를 로드한다', () async {
      final user = _testUser('detail-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final post = _buildPost(id: 'post-1', userId: user.id, commentCount: 21);
      final firstPageComments = List.generate(
        20,
        (index) => _buildComment(id: 'comment-$index', postId: post.id),
      );

      when(
        () => communityService.getPost(post.id, includeComments: false),
      ).thenAnswer((_) async => post);
      when(
        () => communityService.getComments(
          postId: post.id,
          limit: 20,
          offset: 0,
          ascending: false,
        ),
      ).thenAnswer((_) async => firstPageComments);

      final cubit = PostDetailCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.load(post.id);

      final state = cubit.state;
      expect(state, isA<PostDetailLoaded>());
      final loaded = state as PostDetailLoaded;
      expect(loaded.post.comments, hasLength(20));
      expect(loaded.hasMoreComments, isTrue);
      expect(loaded.isLoadingMoreComments, isFalse);
    });

    test('댓글 다음 페이지를 이어 붙이고 마지막 페이지에서 hasMore를 false로 바꾼다', () async {
      final user = _testUser('detail-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final post = _buildPost(id: 'post-1', userId: user.id, commentCount: 21);
      final firstPageComments = List.generate(
        20,
        (index) => _buildComment(id: 'comment-$index', postId: post.id),
      );
      final secondPageComments = [
        _buildComment(id: 'comment-20', postId: post.id),
      ];

      when(
        () => communityService.getPost(post.id, includeComments: false),
      ).thenAnswer((_) async => post);
      when(
        () => communityService.getComments(
          postId: post.id,
          limit: 20,
          offset: 0,
          ascending: false,
        ),
      ).thenAnswer((_) async => firstPageComments);
      when(
        () => communityService.getComments(
          postId: post.id,
          limit: 20,
          offset: 20,
          ascending: false,
        ),
      ).thenAnswer((_) async => secondPageComments);

      final cubit = PostDetailCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.load(post.id);
      await cubit.loadMoreComments();

      final state = cubit.state;
      expect(state, isA<PostDetailLoaded>());
      final loaded = state as PostDetailLoaded;
      expect(loaded.post.comments, hasLength(21));
      expect(loaded.hasMoreComments, isFalse);
      expect(loaded.isLoadingMoreComments, isFalse);
      expect(
        loaded.post.comments?.any((comment) => comment.id == 'comment-20'),
        isTrue,
      );
    });

    test('댓글을 최신 부모 우선 + 대댓글 시간순으로 재구성한다', () async {
      final user = _testUser('detail-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final post = _buildPost(id: 'post-1', userId: user.id, commentCount: 4);
      final comments = [
        _buildComment(
          id: 'reply-orphan',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 13),
          parentId: 'missing-parent',
        ),
        _buildComment(
          id: 'reply-1',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 12),
          parentId: 'parent-1',
        ),
        _buildComment(
          id: 'parent-2',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 11),
        ),
        _buildComment(
          id: 'parent-1',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 10),
        ),
      ];

      when(
        () => communityService.getPost(post.id, includeComments: false),
      ).thenAnswer((_) async => post);
      when(
        () => communityService.getComments(
          postId: post.id,
          limit: 20,
          offset: 0,
          ascending: false,
        ),
      ).thenAnswer((_) async => comments);

      final cubit = PostDetailCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.load(post.id);

      final loaded = cubit.state as PostDetailLoaded;
      expect(loaded.post.comments?.map((comment) => comment.id).toList(), [
        'reply-orphan',
        'parent-2',
        'parent-1',
        'reply-1',
      ]);
    });

    test('부모가 다음 페이지에 로드되면 대댓글을 부모 아래로 재결합한다', () async {
      final user = _testUser('detail-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final post = _buildPost(id: 'post-1', userId: user.id, commentCount: 3);

      final firstPageComments = [
        _buildComment(
          id: 'reply-1',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 13),
          parentId: 'parent-1',
        ),
        _buildComment(
          id: 'parent-2',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 12),
        ),
      ];
      final secondPageComments = [
        _buildComment(
          id: 'parent-1',
          postId: post.id,
          createdAt: DateTime(2026, 2, 14, 11),
        ),
      ];

      when(
        () => communityService.getPost(post.id, includeComments: false),
      ).thenAnswer((_) async => post);
      when(
        () => communityService.getComments(
          postId: post.id,
          limit: 20,
          offset: 0,
          ascending: false,
        ),
      ).thenAnswer((_) async => firstPageComments);
      when(
        () => communityService.getComments(
          postId: post.id,
          limit: 20,
          offset: 2,
          ascending: false,
        ),
      ).thenAnswer((_) async => secondPageComments);

      final cubit = PostDetailCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.load(post.id);
      await cubit.loadMoreComments();

      final loaded = cubit.state as PostDetailLoaded;
      expect(loaded.post.comments?.map((comment) => comment.id).toList(), [
        'parent-2',
        'parent-1',
        'reply-1',
      ]);
      expect(loaded.hasMoreComments, isFalse);
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
  required int commentCount,
}) {
  final now = DateTime(2026, 2, 14, 12);
  return CommunityPost(
    id: id,
    userId: userId,
    title: '게시글',
    content: '내용',
    createdAt: now,
    updatedAt: now,
    commentCount: commentCount,
  );
}

CommunityComment _buildComment({
  required String id,
  required String postId,
  DateTime? createdAt,
  String? parentId,
}) {
  final now = createdAt ?? DateTime(2026, 2, 14, 12);
  return CommunityComment(
    id: id,
    postId: postId,
    userId: 'user',
    content: '댓글',
    parentId: parentId,
    createdAt: now,
    updatedAt: now,
  );
}
