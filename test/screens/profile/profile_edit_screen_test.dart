import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/community/post_list_cubit.dart';
import 'package:coffee_note_app/cubits/community/post_list_state.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_cubit.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/screens/profile/profile_edit_screen.dart';
import 'package:coffee_note_app/services/auth_service.dart';
import 'package:coffee_note_app/services/image_upload_service.dart';
import 'package:coffee_note_app/widgets/common/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class _MockPostListCubit extends MockCubit<PostListState>
    implements PostListCubit {}

class _MockAuthService extends Mock implements AuthService {}

class _MockImageUploadService extends Mock implements ImageUploadService {}

void main() {
  group('ProfileEditScreen', () {
    late _MockAuthCubit authCubit;
    late _MockDashboardCubit dashboardCubit;
    late _MockPostListCubit postListCubit;
    late _MockAuthService authService;
    late _MockImageUploadService imageUploadService;

    setUp(() async {
      authCubit = _MockAuthCubit();
      dashboardCubit = _MockDashboardCubit();
      postListCubit = _MockPostListCubit();
      authService = _MockAuthService();
      imageUploadService = _MockImageUploadService();

      await getIt.reset();
      getIt.allowReassignment = true;
      getIt.registerSingleton<AuthService>(authService);
      getIt.registerSingleton<ImageUploadService>(imageUploadService);

      when(() => dashboardCubit.refresh()).thenAnswer((_) async {});
      when(() => postListCubit.reload()).thenAnswer((_) async {});
      when(
        () => authService.updateProfile(
          userId: any(named: 'userId'),
          nickname: any(named: 'nickname'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => imageUploadService.deleteImage(
          bucket: any(named: 'bucket'),
          imageUrl: any(named: 'imageUrl'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => imageUploadService.pickAvatarFromGallery(),
      ).thenAnswer((_) async => null);
      when(
        () => imageUploadService.pickAvatarFromCamera(),
      ).thenAnswer((_) async => null);

      whenListen(
        postListCubit,
        Stream<PostListState>.fromIterable([const PostListState.initial()]),
        initialState: const PostListState.initial(),
      );
    });

    tearDown(() async {
      await authCubit.close();
      await dashboardCubit.close();
      await postListCubit.close();
      await getIt.reset();
    });

    testWidgets('초기 진입 시 기존 닉네임과 아바타를 표시한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        nickname: '테스터',
        avatarUrl: 'https://example.com/avatar.png',
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.controller?.text, '테스터');
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('닉네임이 공백이면 저장되지 않는다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      await tester.enterText(find.byType(TextFormField), '   ');
      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(find.text('닉네임을 입력해주세요.'), findsOneWidget);
      verifyNever(
        () => authService.updateProfile(
          userId: any(named: 'userId'),
          nickname: any(named: 'nickname'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      );
    });

    testWidgets('닉네임 길이가 2~20자를 벗어나면 저장되지 않는다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(find.text('닉네임은 2~20자여야 합니다.'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField),
        'abcdefghijklmnopqrstu',
      );
      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(find.text('닉네임은 2~20자여야 합니다.'), findsOneWidget);
    });

    testWidgets('중복 닉네임(23505) 저장 시 전용 에러 메시지를 노출한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );
      when(
        () => authService.updateProfile(
          userId: any(named: 'userId'),
          nickname: any(named: 'nickname'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenThrow(
        const PostgrestException(
          message: 'duplicate key value violates unique constraint',
          code: '23505',
        ),
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      await tester.enterText(find.byType(TextFormField), '새닉네임');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      expect(find.text('이미 사용 중인 닉네임입니다.'), findsOneWidget);
    });

    testWidgets('사진 삭제 후 저장하면 avatarUrl을 null로 저장한다', (tester) async {
      final user = _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        avatarUrl: 'https://example.com/avatar-old.png',
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      await tester.tap(find.text('프로필 사진 변경'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('사진 삭제'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      verify(
        () => authService.updateProfile(
          userId: user.id,
          nickname: any(named: 'nickname'),
          avatarUrl: null,
        ),
      ).called(1);
    });

    testWidgets('저장 성공 시 Dashboard/PostList를 갱신한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      await tester.enterText(find.byType(TextFormField), '업데이트닉네임');
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      verify(() => dashboardCubit.refresh()).called(1);
      verify(() => postListCubit.reload()).called(1);
    });

    testWidgets('갤러리 선택 시 아바타 크롭 선택 경로를 호출한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileEditScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        postListCubit: postListCubit,
      );

      await tester.tap(find.text('프로필 사진 변경').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('갤러리에서 선택'));
      await tester.pumpAndSettle();

      verify(() => imageUploadService.pickAvatarFromGallery()).called(1);
      verifyNever(() => imageUploadService.pickImageFromGallery());
    });
  });
}

Future<void> _pumpProfileEditScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required DashboardCubit dashboardCubit,
  required PostListCubit postListCubit,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DashboardCubit>.value(value: dashboardCubit),
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
        home: ProfileEditScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

User _stubAuthenticatedState({
  required _MockAuthCubit authCubit,
  required _MockDashboardCubit dashboardCubit,
  String nickname = '테스터',
  String? avatarUrl,
}) {
  final user = _testUser('profile-edit-user');
  final authState = AuthState.authenticated(user: user);
  final now = DateTime(2026, 2, 18, 9);
  final dashboardState = DashboardState.loaded(
    totalBeans: 3,
    averageBeanRating: 4.2,
    totalLogs: 4,
    averageLogRating: 4.3,
    coffeeTypeCount: const {},
    recentBeans: const <CoffeeBean>[],
    recentLogs: const <CoffeeLog>[],
    userProfile: UserProfile(
      id: user.id,
      nickname: nickname,
      email: user.email,
      avatarUrl: avatarUrl,
      createdAt: now,
      updatedAt: now,
    ),
  );

  whenListen(
    authCubit,
    Stream<AuthState>.fromIterable([authState]),
    initialState: authState,
  );
  whenListen(
    dashboardCubit,
    Stream<DashboardState>.fromIterable([dashboardState]),
    initialState: dashboardState,
  );

  return user;
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-18T00:00:00.000Z',
  );
}
