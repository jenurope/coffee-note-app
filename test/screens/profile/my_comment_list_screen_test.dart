import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/my_comment_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/my_comment_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/screens/profile/my_comment_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockMyCommentListCubit extends MockCubit<MyCommentListState>
    implements MyCommentListCubit {}

void main() {
  group('MyCommentListScreen', () {
    late _MockAuthCubit authCubit;
    late _MockMyCommentListCubit myCommentListCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      myCommentListCubit = _MockMyCommentListCubit();

      when(
        () => myCommentListCubit.loadForUser(any()),
      ).thenAnswer((_) async {});
      when(() => myCommentListCubit.loadMore()).thenAnswer((_) async {});
      when(() => myCommentListCubit.reload()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await authCubit.close();
      await myCommentListCubit.close();
    });

    testWidgets('인증 사용자는 내 댓글 목록을 로드하고 렌더링한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('my-user'));
      final now = DateTime(2026, 2, 25, 10);
      final commentState = MyCommentListState.loaded(
        comments: [
          CommunityComment(
            id: 'comment-1',
            postId: 'post-1',
            userId: 'my-user',
            content: '내 댓글 내용',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        hasMore: false,
      );

      _bindStates(
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
        authState: authState,
        commentState: commentState,
      );

      await _pumpMyCommentListScreen(
        tester,
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
      );

      expect(find.text('내 댓글 내용'), findsOneWidget);
      verify(() => myCommentListCubit.loadForUser('my-user')).called(1);
    });

    testWidgets('목록 아이템 탭 시 해당 게시글 상세 경로로 이동한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('my-user'));
      final now = DateTime(2026, 2, 25, 10);
      final commentState = MyCommentListState.loaded(
        comments: [
          CommunityComment(
            id: 'comment-1',
            postId: 'post-1',
            userId: 'my-user',
            content: '내 댓글 내용',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        hasMore: false,
      );

      _bindStates(
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
        authState: authState,
        commentState: commentState,
      );

      await _pumpMyCommentListScreen(
        tester,
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
      );

      await tester.tap(find.text('내 댓글 내용'));
      await tester.pumpAndSettle();

      expect(find.text('DETAIL post-1'), findsOneWidget);
    });

    testWidgets('상세 화면에서 뒤로가면 내 댓글 목록으로 복귀한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('my-user'));
      final now = DateTime(2026, 2, 25, 10);
      final commentState = MyCommentListState.loaded(
        comments: [
          CommunityComment(
            id: 'comment-1',
            postId: 'post-1',
            userId: 'my-user',
            content: '내 댓글 내용',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        hasMore: false,
      );

      _bindStates(
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
        authState: authState,
        commentState: commentState,
      );

      await _pumpMyCommentListScreen(
        tester,
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
      );

      await tester.tap(find.text('내 댓글 내용'));
      await tester.pumpAndSettle();
      expect(find.text('DETAIL post-1'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('내 댓글 내용'), findsOneWidget);
      expect(find.text('DETAIL post-1'), findsNothing);
    });

    testWidgets('대댓글 탭 시 댓글 상세로 이동하고 뒤로가면 게시글, 프로필 순으로 이동한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('my-user'));
      final now = DateTime(2026, 2, 25, 10);
      final commentState = MyCommentListState.loaded(
        comments: [
          CommunityComment(
            id: 'comment-reply-1',
            postId: 'post-1',
            userId: 'my-user',
            content: '내 대댓글 내용',
            parentId: 'comment-parent-1',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        hasMore: false,
      );

      _bindStates(
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
        authState: authState,
        commentState: commentState,
      );

      await _pumpMyCommentListScreen(
        tester,
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
      );

      await tester.tap(find.text('내 대댓글 내용'));
      await tester.pumpAndSettle();

      expect(find.text('COMMENT comment-reply-1'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('DETAIL post-1'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('내 대댓글 내용'), findsOneWidget);
      expect(find.text('DETAIL post-1'), findsNothing);
      expect(find.text('COMMENT comment-reply-1'), findsNothing);
    });

    testWidgets('비인증 상태에서는 로그인 유도 UI를 노출한다', (tester) async {
      const authState = AuthState.guest();
      const commentState = MyCommentListState.initial();

      _bindStates(
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
        authState: authState,
        commentState: commentState,
      );

      await _pumpMyCommentListScreen(
        tester,
        authCubit: authCubit,
        myCommentListCubit: myCommentListCubit,
      );

      expect(find.text('로그인이 필요합니다.'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
      verifyNever(() => myCommentListCubit.loadForUser(any()));
    });
  });
}

void _bindStates({
  required _MockAuthCubit authCubit,
  required _MockMyCommentListCubit myCommentListCubit,
  required AuthState authState,
  required MyCommentListState commentState,
}) {
  when(() => authCubit.state).thenReturn(authState);
  when(() => myCommentListCubit.state).thenReturn(commentState);

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    myCommentListCubit,
    Stream<MyCommentListState>.fromIterable([commentState]),
    initialState: commentState,
  );
}

Future<void> _pumpMyCommentListScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required MyCommentListCubit myCommentListCubit,
}) async {
  final router = GoRouter(
    initialLocation: '/profile/comments',
    routes: [
      GoRoute(
        path: '/profile/comments',
        builder: (context, state) => const MyCommentListScreen(),
        routes: [
          GoRoute(
            path: ':postId',
            builder: (context, state) => Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('DETAIL ${state.pathParameters['postId']}'),
              ),
            ),
            routes: [
              GoRoute(
                path: 'comments/:commentId',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(),
                  body: Center(
                    child: Text('COMMENT ${state.pathParameters['commentId']}'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LOGIN'))),
      ),
    ],
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<MyCommentListCubit>.value(value: myCommentListCubit),
      ],
      child: MaterialApp.router(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        routerConfig: router,
        locale: const Locale('ko'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
      ),
    ),
  );

  await tester.pumpAndSettle();
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
