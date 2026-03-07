import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/ads/ad_placement.dart';
import 'package:coffee_note_app/ads/ads_slot_factory.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
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
      getIt.allowReassignment = true;

      when(() => postListCubit.updateFilters(any())).thenAnswer((_) async {});
    });

    tearDown(() async {
      await authCubit.close();
      await postListCubit.close();
      await getIt.reset();
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

    testWidgets('커뮤니티 목록에서는 좋아요 수만 표시하고 버튼은 노출하지 않는다', (tester) async {
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: _loadedState(likeCount: 7),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Card).first,
          matching: find.byType(IconButton),
        ),
        findsNothing,
      );
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
          hasMore: false,
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
          hasMore: false,
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

    testWidgets('게시글이 5개 이상이면 첫 native ad 슬롯을 5번째 뒤에 삽입한다', (tester) async {
      _setTallViewport(tester);
      getIt.registerSingleton<AdsSlotFactory>(const _FakeAdsSlotFactory());
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: PostListState.loaded(
          posts: _posts(5),
          filters: const PostFilters(),
          hasMore: false,
        ),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(
        find.byKey(const ValueKey('fake-community-native-0')),
        findsOneWidget,
      );
    });

    testWidgets('게시글이 많은 목록에서도 native ad 슬롯을 유지한다', (tester) async {
      _setTallViewport(tester);
      getIt.registerSingleton<AdsSlotFactory>(const _FakeAdsSlotFactory());
      _bindStates(
        authCubit: authCubit,
        postListCubit: postListCubit,
        postState: PostListState.loaded(
          posts: _posts(13),
          filters: const PostFilters(),
          hasMore: false,
        ),
      );

      await _pumpCommunityScreen(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
      );

      expect(
        find.byKey(const ValueKey('fake-community-native-0')),
        findsOneWidget,
      );
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.text('게시글 12'), findsOneWidget);
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

PostListState _loadedState({
  String? searchQuery,
  int? commentCount,
  int likeCount = 0,
  String userId = 'community-user',
}) {
  final now = DateTime(2026, 2, 21, 14);
  return PostListState.loaded(
    posts: [
      CommunityPost(
        id: 'post-1',
        userId: userId,
        title: '테스트 게시글',
        content: '테스트 내용',
        createdAt: now,
        updatedAt: now,
        commentCount: commentCount,
        likeCount: likeCount,
      ),
    ],
    filters: PostFilters(searchQuery: searchQuery),
    hasMore: false,
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

void _setTallViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 2200);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

class _FakeAdsSlotFactory extends AdsSlotFactory {
  const _FakeAdsSlotFactory();

  @override
  Widget buildBannerSlot({Key? key, required AdPlacement placement}) {
    return SizedBox(
      key: ValueKey('fake-banner-${placement.slotName}'),
      height: 50,
    );
  }

  @override
  Widget buildCommunityNativeSlot({Key? key, required int slotIndex}) {
    return SizedBox(key: ValueKey('fake-community-native-$slotIndex'));
  }
}

List<CommunityPost> _posts(int count) {
  final now = DateTime(2026, 2, 21, 14);
  return List.generate(
    count,
    (index) => CommunityPost(
      id: 'post-$index',
      userId: 'community-user',
      title: '게시글 $index',
      content: '내용 $index',
      createdAt: now.add(Duration(minutes: index)),
      updatedAt: now.add(Duration(minutes: index)),
    ),
  );
}
