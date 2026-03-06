import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/community_post.dart';
import 'package:coffee_note_app/screens/community/post_form_screen.dart';
import 'package:coffee_note_app/services/community_service.dart';
import 'package:coffee_note_app/services/image_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockPostListCubit extends MockCubit<PostListState>
    implements PostListCubit {}

class _MockCommunityService extends Mock implements CommunityService {}

class _MockImageUploadService extends Mock implements ImageUploadService {}

void main() {
  const policyMessage = '욕설, 폭언, 성적 묘사 등 정책에 맞지 않는 글은 삭제될 수 있습니다. 저장하시겠습니까?';

  setUpAll(() {
    registerFallbackValue(
      CommunityPost(
        id: 'fallback-post',
        userId: 'fallback-user',
        title: 'fallback',
        content: 'fallback content',
        createdAt: DateTime(2026, 2, 21),
        updatedAt: DateTime(2026, 2, 21),
      ),
    );
  });

  group('PostFormScreen', () {
    late _MockAuthCubit authCubit;
    late _MockPostListCubit postListCubit;
    late _MockCommunityService communityService;
    late _MockImageUploadService imageUploadService;

    setUp(() async {
      authCubit = _MockAuthCubit();
      postListCubit = _MockPostListCubit();
      communityService = _MockCommunityService();
      imageUploadService = _MockImageUploadService();

      await getIt.reset();
      getIt.allowReassignment = true;
      getIt.registerSingleton<CommunityService>(communityService);
      getIt.registerSingleton<ImageUploadService>(imageUploadService);

      when(() => postListCubit.state).thenReturn(const PostListState.initial());
      when(() => postListCubit.reload()).thenAnswer((_) async {});
      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );
    });

    tearDown(() async {
      await authCubit.close();
      await postListCubit.close();
      await getIt.reset();
    });

    testWidgets('앱바 우측 저장 액션만 노출한다', (tester) async {
      _stubAuthenticatedState(authCubit);

      await _pumpFormRoute(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
        form: const PostFormScreen(),
      );

      expect(find.widgetWithText(TextButton, '저장'), findsOneWidget);
      expect(find.text('작성완료'), findsNothing);
    });

    testWidgets('변경 후 뒤로가기 시 경고 팝업이 표시되고 나가기로 pop 된다', (tester) async {
      _stubAuthenticatedState(authCubit);

      await _pumpFormRoute(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
        form: const PostFormScreen(),
      );

      await tester.enterText(find.byType(TextFormField).first, '테스트 게시글');
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('작성 중인 내용이 사라집니다. 나가시겠습니까?'), findsOneWidget);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(find.text('새 게시글'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('나가기'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('수정 저장 안내 팝업에서 취소하면 게시글을 저장하지 않는다', (tester) async {
      final existingPost = _buildExistingPost();
      _stubAuthenticatedState(authCubit);
      when(
        () => communityService.getPost('post-1'),
      ).thenAnswer((_) async => existingPost);

      await _pumpFormRoute(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
        form: const PostFormScreen(postId: 'post-1'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '수정된 제목');
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, '저장'));
      await tester.pumpAndSettle();

      expect(find.text(policyMessage), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('취소'),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => communityService.updatePost(any()));
      expect(find.text('게시글 수정'), findsOneWidget);
    });

    testWidgets('수정 저장 안내 팝업에서 저장을 누르면 기존 저장 흐름을 이어간다', (tester) async {
      final existingPost = _buildExistingPost();
      _stubAuthenticatedState(authCubit);
      when(
        () => communityService.getPost('post-1'),
      ).thenAnswer((_) async => existingPost);
      when(() => communityService.updatePost(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as CommunityPost,
      );

      await _pumpFormRoute(
        tester,
        authCubit: authCubit,
        postListCubit: postListCubit,
        form: const PostFormScreen(postId: 'post-1'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '수정된 제목');
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, '저장'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('저장'),
        ),
      );
      await tester.pumpAndSettle();

      final capturedPost =
          verify(
                () => communityService.updatePost(captureAny()),
              ).captured.single
              as CommunityPost;

      expect(capturedPost.title, '수정된 제목');
      verify(() => postListCubit.reload()).called(1);
      expect(find.text('HOME'), findsOneWidget);
    });
  });
}

Future<void> _pumpFormRoute(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required PostListCubit postListCubit,
  required Widget form,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('HOME'))),
      ),
      GoRoute(path: '/form', builder: (context, state) => form),
    ],
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<PostListCubit>.value(value: postListCubit),
      ],
      child: MaterialApp.router(
        locale: const Locale('ko'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  router.push('/form');
  await tester.pumpAndSettle();
}

AuthState _stubAuthenticatedState(_MockAuthCubit authCubit) {
  final authState = AuthState.authenticated(user: _testUser('writer'));
  when(() => authCubit.state).thenReturn(authState);
  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  return authState;
}

CommunityPost _buildExistingPost() {
  return CommunityPost(
    id: 'post-1',
    userId: 'writer',
    title: '기존 제목',
    content: '기존 본문',
    createdAt: DateTime(2026, 2, 21, 10),
    updatedAt: DateTime(2026, 2, 21, 10),
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
