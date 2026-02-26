import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_filters.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/screens/community/community_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockPostListCubit extends MockCubit<PostListState>
    implements PostListCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const PostFilters());
  });

  group('CommunityScreen', () {
    late _MockAuthCubit authCubit;
    late _MockPostListCubit postListCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      postListCubit = _MockPostListCubit();

      when(() => postListCubit.updateFilters(any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await authCubit.close();
      await postListCubit.close();
    });

    testWidgets('검색이 적용된 상태면 전체보기 버튼이 노출된다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(searchQuery: '핸드드립'),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('전체보기'), findsOneWidget);
    });

    testWidgets('전체보기 탭 시 검색 필터를 해제하고 입력값을 비운다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(searchQuery: '핸드드립'),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '핸드드립');
      await tester.pump();

      await tester.tap(find.text('전체보기'));
      await tester.pump();

      final captured = verify(
        () => postListCubit.updateFilters(captureAny()),
      ).captured;
      expect(captured.single, isA<PostFilters>());
      expect((captured.single as PostFilters).searchQuery, isNull);

      final textField = tester.widget<TextField>(searchField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('검색이 적용되지 않은 상태면 전체보기 버튼이 노출되지 않는다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('전체보기'), findsNothing);
    });

    testWidgets('댓글이 0개인 게시글은 댓글 수를 표시하지 않는다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(commentCount: 0),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('댓글 0'), findsNothing);
    });

    testWidgets('댓글이 1개 이상인 게시글은 댓글 수를 표시한다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(commentCount: 1),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('댓글 1'), findsOneWidget);
    });

    testWidgets('댓글 수가 null이면 댓글 수를 표시하지 않는다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(commentCount: null),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.textContaining('댓글 '), findsNothing);
    });

    testWidgets('탈퇴 사용자 게시글은 작성자와 제목만 안내 문구로 표시한다', (tester) async {
      final now = DateTime(2026, 2, 21, 14);
      final withdrawnPost = CommunityPost(
        id: 'post-withdrawn',
        userId: 'withdrawn-user-id',
        title: '원문 제목',
        content: '원문 내용',
        createdAt: now,
        updatedAt: now,
        isWithdrawnContent: true,
        author: UserProfile(
          id: 'withdrawn-user-id',
          nickname: '원래 닉네임',
          email: 'withdrawn@example.com',
          isWithdrawn: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: PostListState.loaded(
          posts: [withdrawnPost],
          filters: const PostFilters(),
        ),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('탈퇴한 사용자'), findsOneWidget);
      expect(find.text('탈퇴한 사용자의 게시글입니다.'), findsOneWidget);
      expect(find.text('원문 제목'), findsNothing);
      expect(find.text('원문 내용'), findsNothing);
    });

    testWidgets('삭제된 게시글은 placeholder를 표시하고 상세 진입을 비활성화한다', (tester) async {
      final now = DateTime(2026, 2, 21, 14);
      final deletedPost = CommunityPost(
        id: 'post-deleted',
        userId: 'deleted-user-id',
        title: '삭제 전 제목',
        content: '삭제 전 내용',
        createdAt: now,
        updatedAt: now,
        isDeletedContent: true,
      );

      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: PostListState.loaded(
          posts: [deletedPost],
          filters: const PostFilters(),
        ),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.text('삭제된 게시글입니다.'), findsOneWidget);
      expect(find.text('삭제 전 제목'), findsNothing);
      expect(find.text('삭제 전 내용'), findsNothing);

      final postInkWell = tester.widget<InkWell>(
        find
            .descendant(
              of: find.byType(Card).first,
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(postInkWell.onTap, isNull);
    });
  });
}

Future<void> _pumpCommunityScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required PostListCubit postListCubit,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<PostListCubit>.value(value: postListCubit),
      ],
      child: MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        locale: Locale('ko'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ko'), Locale('en'), Locale('ja')],
        home: CommunityScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _bindStates({
  required _MockAuthCubit authCubit,
  required _MockPostListCubit postListCubit,
  required PostListState postState,
}) {
  final authState = AuthState.authenticated(user: _testUser('community-user'));
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

PostListState _loadedState({String? searchQuery, int? commentCount}) {
  final now = DateTime(2026, 2, 21, 14);
  return PostListState.loaded(
    posts: [
      CommunityPost(
        id: 'post-1',
        userId: 'community-user',
        title: '테스트 게시글',
        content: '테스트 내용',
        createdAt: now,
        updatedAt: now,
        commentCount: commentCount,
      ),
    ],
    filters: PostFilters(searchQuery: searchQuery),
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
