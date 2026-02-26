import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/my_comment_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/my_comment_list_state.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockCommunityService extends Mock implements CommunityService {}

void main() {
  group('MyCommentListCubit', () {
    late _MockCommunityService communityService;

    setUp(() {
      communityService = _MockCommunityService();
    });

    test('게스트 모드에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.guest());
      final cubit = MyCommentListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser('guest-user');

      final state = cubit.state;
      expect(state, isA<MyCommentListLoaded>());
      expect((state as MyCommentListLoaded).comments, isEmpty);
      verifyZeroInteractions(communityService);
    });

    test('비로그인 상태에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.unauthenticated());
      final cubit = MyCommentListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser('anonymous-user');

      final state = cubit.state;
      expect(state, isA<MyCommentListLoaded>());
      expect((state as MyCommentListLoaded).comments, isEmpty);
      verifyZeroInteractions(communityService);
    });

    test('인증 사용자에서는 내 댓글 목록을 조회한다', () async {
      final user = _testUser('auth-comment-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 25, 11);
      final comment = _buildComment(
        id: 'comment-1',
        postId: 'post-1',
        userId: user.id,
        createdAt: now,
      );

      when(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 0,
          ascending: false,
          includeDeleted: false,
        ),
      ).thenAnswer((_) async => [comment]);

      final cubit = MyCommentListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser(user.id);

      final state = cubit.state;
      expect(state, isA<MyCommentListLoaded>());
      expect((state as MyCommentListLoaded).comments.single.id, 'comment-1');
      verify(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 0,
          ascending: false,
          includeDeleted: false,
        ),
      ).called(1);
    });

    test('loadForUser 이후 loadMore/reload도 동일한 userId를 유지한다', () async {
      final user = _testUser('auth-comment-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 25, 11);
      final firstPageComments = List.generate(
        20,
        (index) => _buildComment(
          id: 'comment-$index',
          postId: 'post-$index',
          userId: user.id,
          createdAt: now.add(Duration(minutes: index)),
        ),
      );
      final secondPageComments = [
        _buildComment(
          id: 'comment-20',
          postId: 'post-20',
          userId: user.id,
          createdAt: now.add(const Duration(minutes: 20)),
        ),
      ];

      when(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 0,
          ascending: false,
          includeDeleted: false,
        ),
      ).thenAnswer((_) async => firstPageComments);
      when(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 20,
          ascending: false,
          includeDeleted: false,
        ),
      ).thenAnswer((_) async => secondPageComments);

      final cubit = MyCommentListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser(user.id);
      await cubit.loadMore();
      await cubit.reload();

      final state = cubit.state;
      expect(state, isA<MyCommentListLoaded>());
      final loaded = state as MyCommentListLoaded;
      expect(loaded.comments, hasLength(20));
      verify(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 0,
          ascending: false,
          includeDeleted: false,
        ),
      ).called(2);
      verify(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 20,
          ascending: false,
          includeDeleted: false,
        ),
      ).called(1);
    });

    test('부모 댓글이 삭제된 대댓글은 내 댓글 목록에서 제외한다', () async {
      final user = _testUser('auth-comment-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 25, 11);
      final rootComment = _buildComment(
        id: 'comment-root',
        postId: 'post-1',
        userId: user.id,
        createdAt: now,
      );
      final visibleReply = _buildComment(
        id: 'comment-visible-reply',
        postId: 'post-1',
        userId: user.id,
        parentId: 'parent-visible',
        createdAt: now.add(const Duration(minutes: 1)),
      );
      final hiddenReply = _buildComment(
        id: 'comment-hidden-reply',
        postId: 'post-1',
        userId: user.id,
        parentId: 'parent-deleted',
        createdAt: now.add(const Duration(minutes: 2)),
      );

      when(
        () => communityService.getCommentsByUser(
          userId: user.id,
          limit: 20,
          offset: 0,
          ascending: false,
          includeDeleted: false,
        ),
      ).thenAnswer((_) async => [rootComment, visibleReply, hiddenReply]);
      when(
        () => communityService.getCommentDeletionStatusByIds(
          commentIds: any(named: 'commentIds'),
        ),
      ).thenAnswer(
        (_) async => {'parent-visible': false, 'parent-deleted': true},
      );

      final cubit = MyCommentListCubit(
        service: communityService,
        authCubit: authCubit,
      );

      await cubit.loadForUser(user.id);

      final state = cubit.state;
      expect(state, isA<MyCommentListLoaded>());
      final loaded = state as MyCommentListLoaded;
      expect(loaded.comments.map((comment) => comment.id).toList(), [
        'comment-root',
        'comment-visible-reply',
      ]);
      verify(
        () => communityService.getCommentDeletionStatusByIds(
          commentIds: any(named: 'commentIds'),
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
    createdAt: '2026-02-25T00:00:00.000Z',
  );
}

CommunityComment _buildComment({
  required String id,
  required String postId,
  required String userId,
  required DateTime createdAt,
  String? parentId,
}) {
  return CommunityComment(
    id: id,
    postId: postId,
    userId: userId,
    content: '댓글 $id',
    parentId: parentId,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
