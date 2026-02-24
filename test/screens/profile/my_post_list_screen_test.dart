import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_filters.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/screens/profile/my_post_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockPostListCubit extends MockCubit<PostListState>
    implements PostListCubit {}

void main() {
  group('MyPostListScreen', () {
    late _MockAuthCubit authCubit;
    late _MockPostListCubit postListCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      postListCubit = _MockPostListCubit();

      when(() => postListCubit.loadForUser(any())).thenAnswer((_) async {});
      when(() => postListCubit.loadMore()).thenAnswer((_) async {});
      when(() => postListCubit.reload()).thenAnswer((_) async {});
    });

    tearDown(() async {
      await authCubit.close();
      await postListCubit.close();
    });

    testWidgets('인증 사용자는 내 게시글 목록을 로드하고 렌더링한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('my-user'));
      final now = DateTime(2026, 2, 24, 10);
      final postState = PostListState.loaded(
        posts: [
          CommunityPost(
            id: 'post-1',
            userId: 'my-user',
            title: '내 글 제목',
            content: '내 글 내용',
            createdAt: now,
            updatedAt: now,
            commentCount: 1,
          ),
        ],
        filters: const PostFilters(),
        hasMore: false,
      );

      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        authState: authState,
        postState: postState,
      );

      await _pumpMyPostListScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('내 글 제목'), findsOneWidget);
      verify(() => postListCubit.loadForUser('my-user')).called(1);
    });

    testWidgets('목록 아이템 탭 시 해당 게시글 상세 경로로 이동한다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('my-user'));
      final now = DateTime(2026, 2, 24, 10);
      final postState = PostListState.loaded(
        posts: [
          CommunityPost(
            id: 'post-1',
            userId: 'my-user',
            title: '내 글 제목',
            content: '내 글 내용',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        filters: const PostFilters(),
        hasMore: false,
      );

      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        authState: authState,
        postState: postState,
      );

      await _pumpMyPostListScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      await tester.tap(find.text('내 글 제목'));
      await tester.pumpAndSettle();

      expect(find.text('DETAIL post-1'), findsOneWidget);
    });

    testWidgets('비인증 상태에서는 로그인 유도 UI를 노출한다', (tester) async {
      const authState = AuthState.guest();
      const postState = PostListState.initial();

      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        authState: authState,
        postState: postState,
      );

      await _pumpMyPostListScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('로그인이 필요합니다.'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
      verifyNever(() => postListCubit.loadForUser(any()));
    });
  });
}

void _bindStates({
  required _MockAuthCubit authCubit,
  required _MockPostListCubit postListCubit,
  required AuthState authState,
  required PostListState postState,
}) {
  when(() => authCubit.state).thenReturn(authState);
  when(() => postListCubit.state).thenReturn(postState);

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    postListCubit,
    Stream<PostListState>.fromIterable([postState]),
    initialState: postState,
  );
}

Future<void> _pumpMyPostListScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required PostListCubit postListCubit,
}) async {
  final router = GoRouter(
    initialLocation: '/profile/posts',
    routes: [
      GoRoute(
        path: '/profile/posts',
        builder: (context, state) => const MyPostListScreen(),
      ),
      GoRoute(
        path: '/community/:id',
        builder: (context, state) => Scaffold(
          body: Center(child: Text('DETAIL ${state.pathParameters['id']}')),
        ),
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
        BlocProvider<PostListCubit>.value(value: postListCubit),
      ],
      child: MaterialApp.router(
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
    createdAt: '2026-02-24T00:00:00.000Z',
  );
}
