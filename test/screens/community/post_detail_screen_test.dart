import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_detail_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_detail_state.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/screens/community/post_detail_screen.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockPostDetailCubit extends MockCubit<PostDetailState>
    implements PostDetailCubit {}

class _MockPostListCubit extends MockCubit<PostListState>
    implements PostListCubit {}

class _MockCommunityService extends Mock implements CommunityService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CommunityComment(
        id: 'fallback-comment',
        postId: 'fallback-post',
        userId: 'fallback-user',
        content: 'fallback',
        createdAt: DateTime(2026, 2, 21, 14),
        updatedAt: DateTime(2026, 2, 21, 14),
      ),
    );
  });

  group('PostDetailScreen', () {
    late _MockAuthCubit authCubit;
    late _MockPostDetailCubit postDetailCubit;
    late _MockPostListCubit postListCubit;
    late _MockCommunityService communityService;

    setUp(() async {
      authCubit = _MockAuthCubit();
      postDetailCubit = _MockPostDetailCubit();
      postListCubit = _MockPostListCubit();
      communityService = _MockCommunityService();

      await getIt.reset();
      getIt.allowReassignment = true;
      getIt.registerSingleton<CommunityService>(communityService);

      when(() => postListCubit.reload()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await authCubit.close();
      await postDetailCubit.close();
      await postListCubit.close();
      await getIt.reset();
    });

    testWidgets('댓글 작성 성공 시 상세와 목록을 함께 갱신한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('writer'));
      final postState = PostDetailState.loaded(
        post: _buildActivePost(userId: 'writer'),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      when(() => postDetailCubit.load(any())).thenAnswer((_) async {});
      when(() => communityService.createComment(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as CommunityComment,
      );
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '새 댓글');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      verify(() => communityService.createComment(any())).called(1);
      verify(() => postDetailCubit.load('post-1')).called(1);
      verify(() => postListCubit.reload()).called(1);
    });

    testWidgets('일반 댓글에 답글 작성 시 parent_id를 포함해 등록한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final postState = PostDetailState.loaded(
        post: _buildPostWithReplyTarget(commentOwnerId: 'comment-owner'),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      when(() => postDetailCubit.load(any())).thenAnswer((_) async {});
      when(() => communityService.createComment(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as CommunityComment,
      );
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-with-reply-target'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('replyActionButton-comment-parent')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('replyInputField-comment-parent')),
        '대댓글입니다.',
      );
      await tester.tap(
        find.byKey(const ValueKey('replySendButton-comment-parent')),
      );
      await tester.pumpAndSettle();

      final capturedComment =
          verify(
                () => communityService.createComment(captureAny()),
              ).captured.single
              as CommunityComment;
      expect(capturedComment.parentId, 'comment-parent');
      expect(capturedComment.content, '대댓글입니다.');
      verify(() => postDetailCubit.load('post-with-reply-target')).called(1);
      verify(() => postListCubit.reload()).called(1);
    });

    testWidgets('삭제/탈퇴/대댓글에는 답글 액션을 노출하지 않는다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final postState = PostDetailState.loaded(
        post: _buildPostForReplyActionVisibility(),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-reply-action-visibility'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('replyActionButton-comment-parent')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('replyActionButton-comment-reply')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('replyActionButton-comment-deleted')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('replyActionButton-comment-withdrawn')),
        findsNothing,
      );
    });

    testWidgets('탈퇴 사용자 글/댓글은 안내 문구로만 표시한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final postState = PostDetailState.loaded(post: _buildWithdrawnPost());

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-withdrawn'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('탈퇴한 사용자'), findsWidgets);
      expect(find.text('탈퇴한 사용자의 게시글입니다.'), findsOneWidget);
      expect(find.text('탈퇴한 사용자의 댓글입니다.'), findsOneWidget);
      expect(find.text('원문 제목'), findsNothing);
      expect(find.text('원문 본문'), findsNothing);
      expect(find.text('원문 댓글'), findsNothing);
    });

    testWidgets('삭제 댓글은 안내 문구만 표시하고 메뉴를 노출하지 않는다', (tester) async {
      final authState = AuthState.authenticated(
        user: _testUser('comment-owner'),
      );
      final postState = PostDetailState.loaded(
        post: _buildPostWithDeletedComment(commentOwnerId: 'comment-owner'),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-deleted-comment'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('삭제된 댓글입니다.'), findsOneWidget);
      expect(find.text('삭제 전 원문 댓글'), findsNothing);
      expect(find.text('댓글작성자닉'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets('타인 게시글 신고 성공 시 신고를 등록한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final postState = PostDetailState.loaded(
        post: _buildActivePost(userId: 'post-owner'),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      when(
        () => communityService.reportPost(
          postId: any(named: 'postId'),
          userId: any(named: 'userId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('postReportButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('reportReasonField')),
        '광고성 게시글입니다.',
      );
      await tester.tap(find.text('신고하기'));
      await tester.pumpAndSettle();

      verify(
        () => communityService.reportPost(
          postId: 'post-1',
          userId: 'viewer',
          reason: '광고성 게시글입니다.',
        ),
      ).called(1);
      expect(find.text('신고가 접수되었습니다.'), findsOneWidget);
    });

    testWidgets('타인 댓글 신고 메뉴를 통해 신고를 등록한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final postState = PostDetailState.loaded(
        post: _buildPostWithReportableComment(
          postOwnerId: 'post-owner',
          commentOwnerId: 'comment-owner',
        ),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      when(
        () => communityService.reportComment(
          commentId: any(named: 'commentId'),
          userId: any(named: 'userId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-with-reportable-comment'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton<String>).first);
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
          commentId: 'comment-reportable',
          userId: 'viewer',
          reason: '욕설이 포함되어 있습니다.',
        ),
      ).called(1);
    });

    testWidgets('본인 게시글/댓글에는 신고 액션을 노출하지 않는다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('owner'));
      final postState = PostDetailState.loaded(
        post: _buildPostWithReportableComment(
          postOwnerId: 'owner',
          commentOwnerId: 'owner',
        ),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-with-reportable-comment'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('postReportButton')), findsNothing);
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();

      expect(find.text('삭제'), findsOneWidget);
      expect(find.text('신고'), findsNothing);
    });

    testWidgets('중복 신고(23505) 시 전용 안내를 노출한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('viewer'));
      final postState = PostDetailState.loaded(
        post: _buildActivePost(userId: 'post-owner'),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => postDetailCubit.state).thenReturn(postState);
      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      when(
        () => communityService.reportPost(
          postId: any(named: 'postId'),
          userId: any(named: 'userId'),
          reason: any(named: 'reason'),
        ),
      ).thenThrow(
        const PostgrestException(
          message: 'duplicate key value violates unique constraint',
          code: '23505',
        ),
      );
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        postDetailCubit,
        Stream<PostDetailState>.fromIterable([postState]),
        initialState: postState,
      );
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<PostDetailCubit>.value(value: postDetailCubit),
            BlocProvider<PostListCubit>.value(value: postListCubit),
          ],
          child: const MaterialApp(
            locale: Locale('ko'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
            home: PostDetailScreen(postId: 'post-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('postReportButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('reportReasonField')),
        '중복 신고 테스트',
      );
      await tester.tap(find.text('신고하기'));
      await tester.pumpAndSettle();

      expect(find.text('이미 신고한 대상입니다.'), findsOneWidget);
    });
  });
}

CommunityPost _buildWithdrawnPost() {
  final now = DateTime(2026, 2, 21, 14);
  final author = UserProfile(
    id: 'withdrawn-author',
    nickname: '원래닉네임',
    email: 'withdrawn@example.com',
    isWithdrawn: true,
    createdAt: now,
    updatedAt: now,
  );

  return CommunityPost(
    id: 'post-withdrawn',
    userId: author.id,
    title: '원문 제목',
    content: '원문 본문',
    createdAt: now,
    updatedAt: now,
    isWithdrawnContent: true,
    author: author,
    comments: [
      CommunityComment(
        id: 'comment-withdrawn',
        postId: 'post-withdrawn',
        userId: author.id,
        content: '원문 댓글',
        createdAt: now,
        updatedAt: now,
        isWithdrawnContent: true,
        author: author,
      ),
    ],
    commentCount: 1,
  );
}

CommunityPost _buildActivePost({required String userId}) {
  final now = DateTime(2026, 2, 21, 14);

  return CommunityPost(
    id: 'post-1',
    userId: userId,
    title: '일반 게시글 제목',
    content: '일반 게시글 본문',
    createdAt: now,
    updatedAt: now,
    commentCount: 0,
  );
}

CommunityPost _buildPostWithDeletedComment({required String commentOwnerId}) {
  final now = DateTime(2026, 2, 21, 14);
  final commentAuthor = UserProfile(
    id: commentOwnerId,
    nickname: '댓글작성자닉',
    email: '$commentOwnerId@example.com',
    createdAt: now,
    updatedAt: now,
  );

  return CommunityPost(
    id: 'post-deleted-comment',
    userId: 'post-owner',
    title: '일반 게시글 제목',
    content: '일반 게시글 본문',
    createdAt: now,
    updatedAt: now,
    comments: [
      CommunityComment(
        id: 'comment-deleted',
        postId: 'post-deleted-comment',
        userId: commentOwnerId,
        content: '삭제 전 원문 댓글',
        createdAt: now,
        updatedAt: now,
        isDeletedContent: true,
        author: commentAuthor,
      ),
    ],
    commentCount: 1,
  );
}

CommunityPost _buildPostWithReportableComment({
  required String postOwnerId,
  required String commentOwnerId,
}) {
  final now = DateTime(2026, 2, 21, 14);
  final commentAuthor = UserProfile(
    id: commentOwnerId,
    nickname: '댓글작성자닉',
    email: '$commentOwnerId@example.com',
    createdAt: now,
    updatedAt: now,
  );

  return CommunityPost(
    id: 'post-with-reportable-comment',
    userId: postOwnerId,
    title: '일반 게시글 제목',
    content: '일반 게시글 본문',
    createdAt: now,
    updatedAt: now,
    comments: [
      CommunityComment(
        id: 'comment-reportable',
        postId: 'post-with-reportable-comment',
        userId: commentOwnerId,
        content: '신고 가능한 댓글',
        createdAt: now,
        updatedAt: now,
        author: commentAuthor,
      ),
    ],
    commentCount: 1,
  );
}

CommunityPost _buildPostWithReplyTarget({required String commentOwnerId}) {
  final now = DateTime(2026, 2, 21, 14);
  final commentAuthor = UserProfile(
    id: commentOwnerId,
    nickname: '댓글작성자닉',
    email: '$commentOwnerId@example.com',
    createdAt: now,
    updatedAt: now,
  );

  return CommunityPost(
    id: 'post-with-reply-target',
    userId: 'post-owner',
    title: '일반 게시글 제목',
    content: '일반 게시글 본문',
    createdAt: now,
    updatedAt: now,
    comments: [
      CommunityComment(
        id: 'comment-parent',
        postId: 'post-with-reply-target',
        userId: commentOwnerId,
        content: '답글 대상 댓글',
        createdAt: now,
        updatedAt: now,
        author: commentAuthor,
      ),
    ],
    commentCount: 1,
  );
}

CommunityPost _buildPostForReplyActionVisibility() {
  final now = DateTime(2026, 2, 21, 14);
  final commentAuthor = UserProfile(
    id: 'comment-owner',
    nickname: '댓글작성자닉',
    email: 'comment-owner@example.com',
    createdAt: now,
    updatedAt: now,
  );

  return CommunityPost(
    id: 'post-reply-action-visibility',
    userId: 'post-owner',
    title: '일반 게시글 제목',
    content: '일반 게시글 본문',
    createdAt: now,
    updatedAt: now,
    comments: [
      CommunityComment(
        id: 'comment-parent',
        postId: 'post-reply-action-visibility',
        userId: 'comment-owner',
        content: '답글 가능한 부모 댓글',
        createdAt: now,
        updatedAt: now,
        author: commentAuthor,
      ),
      CommunityComment(
        id: 'comment-reply',
        postId: 'post-reply-action-visibility',
        userId: 'comment-owner',
        content: '대댓글',
        parentId: 'comment-parent',
        createdAt: now.add(const Duration(minutes: 1)),
        updatedAt: now.add(const Duration(minutes: 1)),
        author: commentAuthor,
      ),
      CommunityComment(
        id: 'comment-deleted',
        postId: 'post-reply-action-visibility',
        userId: 'comment-owner',
        content: '삭제 댓글',
        isDeletedContent: true,
        createdAt: now.add(const Duration(minutes: 2)),
        updatedAt: now.add(const Duration(minutes: 2)),
        author: commentAuthor,
      ),
      CommunityComment(
        id: 'comment-withdrawn',
        postId: 'post-reply-action-visibility',
        userId: 'comment-owner',
        content: '탈퇴 댓글',
        isWithdrawnContent: true,
        createdAt: now.add(const Duration(minutes: 3)),
        updatedAt: now.add(const Duration(minutes: 3)),
        author: commentAuthor,
      ),
    ],
    commentCount: 4,
  );
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-21T00:00:00.000Z',
  );
}
