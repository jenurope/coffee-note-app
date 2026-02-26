import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/screens/community/comment_detail_screen.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockCommunityService extends Mock implements CommunityService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CommunityComment(
        id: 'fallback-comment',
        postId: 'fallback-post',
        userId: 'fallback-user',
        content: 'fallback',
        createdAt: DateTime(2026, 2, 22, 10),
        updatedAt: DateTime(2026, 2, 22, 10),
      ),
    );
  });

  group('CommentDetailScreen', () {
    late _MockAuthCubit authCubit;
    late _MockCommunityService communityService;

    setUp(() async {
      authCubit = _MockAuthCubit();
      communityService = _MockCommunityService();

      await getIt.reset();
      getIt.allowReassignment = true;
      getIt.registerSingleton<CommunityService>(communityService);
    });

    tearDown(() async {
      await authCubit.close();
      await getIt.reset();
    });

    testWidgets('하위 댓글을 로드하고 답글을 작성한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('writer'));
      final parentComment = _comment(
        id: 'comment-parent',
        postId: 'post-1',
        content: '원댓글',
      );
      final childComment = _comment(
        id: 'comment-child',
        postId: 'post-1',
        content: '하위 댓글',
        parentId: 'comment-parent',
      );

      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(
        () => communityService.getCommentById(commentId: 'comment-parent'),
      ).thenAnswer((_) async => parentComment);
      when(
        () => communityService.getReplies(
          parentCommentId: 'comment-parent',
          limit: 20,
          offset: 0,
          ascending: true,
        ),
      ).thenAnswer((_) async => [childComment]);
      when(() => communityService.createComment(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as CommunityComment,
      );

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: _buildTestMaterialApp(
            home: const CommentDetailScreen(
              postId: 'post-1',
              commentId: 'comment-parent',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('원댓글'), findsOneWidget);
      expect(find.text('하위 댓글'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '새 답글');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      final capturedComment =
          verify(
                () => communityService.createComment(captureAny()),
              ).captured.single
              as CommunityComment;
      expect(capturedComment.parentId, 'comment-parent');
      expect(capturedComment.content, '새 답글');
    });

    testWidgets('삭제된 부모 댓글에서는 답글 입력창을 노출하지 않는다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('writer'));
      final deletedParent = _comment(
        id: 'comment-parent',
        postId: 'post-1',
        content: '[deleted_comment]',
        isDeletedContent: true,
      );

      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(
        () => communityService.getCommentById(commentId: 'comment-parent'),
      ).thenAnswer((_) async => deletedParent);
      when(
        () => communityService.getReplies(
          parentCommentId: 'comment-parent',
          limit: 20,
          offset: 0,
          ascending: true,
        ),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: _buildTestMaterialApp(
            home: const CommentDetailScreen(
              postId: 'post-1',
              commentId: 'comment-parent',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('삭제된 댓글입니다.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('본인 대댓글에서는 삭제 메뉴로 삭제할 수 있다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('user-1'));
      final parentComment = _comment(
        id: 'comment-parent',
        postId: 'post-1',
        content: '원댓글',
      );
      final childComment = _comment(
        id: 'comment-child',
        postId: 'post-1',
        content: '하위 댓글',
        parentId: 'comment-parent',
      );

      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(
        () => communityService.getCommentById(commentId: 'comment-parent'),
      ).thenAnswer((_) async => parentComment);
      when(
        () => communityService.getReplies(
          parentCommentId: 'comment-parent',
          limit: 20,
          offset: 0,
          ascending: true,
        ),
      ).thenAnswer((_) async => [childComment]);
      when(
        () => communityService.deleteComment(any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: _buildTestMaterialApp(
            home: const CommentDetailScreen(
              postId: 'post-1',
              commentId: 'comment-parent',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();

      verify(() => communityService.deleteComment('comment-child')).called(1);
    });

    testWidgets('타인 대댓글에서는 신고 메뉴로 신고할 수 있다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final parentComment = _comment(
        id: 'comment-parent',
        postId: 'post-1',
        content: '원댓글',
        userId: 'comment-owner',
      );
      final childComment = _comment(
        id: 'comment-child',
        postId: 'post-1',
        content: '하위 댓글',
        parentId: 'comment-parent',
        userId: 'comment-owner',
      );

      when(() => authCubit.state).thenReturn(authState);
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      when(
        () => communityService.getCommentById(commentId: 'comment-parent'),
      ).thenAnswer((_) async => parentComment);
      when(
        () => communityService.getReplies(
          parentCommentId: 'comment-parent',
          limit: 20,
          offset: 0,
          ascending: true,
        ),
      ).thenAnswer((_) async => [childComment]);
      when(
        () => communityService.reportComment(
          commentId: any(named: 'commentId'),
          userId: any(named: 'userId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: _buildTestMaterialApp(
            home: const CommentDetailScreen(
              postId: 'post-1',
              commentId: 'comment-parent',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('신고'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('reportReasonField')),
        '욕설이 포함되어 있습니다.',
      );
      await tester.tap(find.text('신고하기'));
      await tester.pumpAndSettle();

      verify(
        () => communityService.reportComment(
          commentId: 'comment-child',
          userId: 'viewer',
          reason: '욕설이 포함되어 있습니다.',
        ),
      ).called(1);
    });
  });
}

CommunityComment _comment({
  required String id,
  required String postId,
  required String content,
  String userId = 'user-1',
  String? parentId,
  bool isDeletedContent = false,
}) {
  final now = DateTime(2026, 2, 22, 10);
  return CommunityComment(
    id: id,
    postId: postId,
    userId: userId,
    content: content,
    parentId: parentId,
    createdAt: now,
    updatedAt: now,
    isDeletedContent: isDeletedContent,
  );
}

Widget _buildTestMaterialApp({required Widget home}) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    locale: const Locale('ko'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
    home: home,
  );
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-22T00:00:00.000Z',
  );
}
