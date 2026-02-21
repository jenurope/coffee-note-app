import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_filters.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
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
      child: const MaterialApp(
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

PostListState _loadedState({String? searchQuery}) {
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
