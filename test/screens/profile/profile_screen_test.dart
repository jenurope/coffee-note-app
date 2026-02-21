import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_cubit.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_state.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  group('ProfileScreen', () {
    late _MockAuthCubit authCubit;
    late _MockDashboardCubit dashboardCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      dashboardCubit = _MockDashboardCubit();
      PackageInfo.setMockInitialValues(
        appName: 'Coffee Note',
        packageName: 'com.example.coffee_note_app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    });

    tearDown(() async {
      await authCubit.close();
      await dashboardCubit.close();
    });

    testWidgets('로그인 사용자 화면에서 메뉴와 앱 버전 정보가 노출된다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      expect(find.text('문의/제보하기'), findsOneWidget);
      expect(find.text('앱 정보'), findsOneWidget);
      expect(find.text('버전 1.0.0'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      expect(find.text('내 원두 기록'), findsNothing);
      expect(find.text('내 커피 기록'), findsNothing);
      expect(find.text('원두 기록'), findsNothing);
      expect(find.text('커피 기록'), findsNothing);
      expect(find.text('도움말'), findsNothing);
      expect(find.text('라이선스'), findsNothing);
    });

    testWidgets('문의/제보하기 탭 시 준비중 스낵바를 표시한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await tester.tap(find.text('문의/제보하기'));
      await tester.pump();

      expect(find.text('문의/제보 기능은 준비 중입니다.'), findsOneWidget);
    });

    testWidgets('앱 정보는 다이얼로그 없이 고정 표시된다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await tester.tap(find.text('앱 정보'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialog), findsNothing);
      expect(find.text('당신의 커피 여정을 기록하세요.'), findsNothing);
      expect(find.text('버전 1.0.0'), findsOneWidget);
    });

    testWidgets('게스트 모드 화면은 기존 UI를 유지한다', (tester) async {
      const guestState = AuthState.guest();
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([guestState]),
        initialState: guestState,
      );
      whenListen(
        dashboardCubit,
        Stream<DashboardState>.fromIterable([const DashboardState.initial()]),
        initialState: const DashboardState.initial(),
      );

      await _pumpProfileScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      expect(find.text('게스트 모드'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('회원탈퇴는 2단계 확인 다이얼로그를 표시한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );
      when(() => authCubit.withdraw()).thenAnswer((_) async {});

      await _pumpProfileScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      expect(find.text('회원탈퇴'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('회원탈퇴'),
        200,
        scrollable: find.byType(Scrollable),
      );

      await tester.tap(find.text('회원탈퇴'));
      await tester.pumpAndSettle();

      expect(find.text('회원탈퇴 안내'), findsOneWidget);
      expect(find.textContaining('커피/원두/게시글/댓글 원문 데이터가 즉시 삭제'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('회원탈퇴'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('정말 탈퇴하시겠습니까?'), findsOneWidget);
      expect(find.textContaining('탈퇴 후에는 되돌릴 수 없습니다'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('취소'),
        ),
      );
      await tester.pumpAndSettle();

      verifyNever(() => authCubit.withdraw());
    });
  });
}

Future<void> _pumpProfileScreen(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required DashboardCubit dashboardCubit,
}) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DashboardCubit>.value(value: dashboardCubit),
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
        home: ProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _stubAuthenticatedState({
  required _MockAuthCubit authCubit,
  required _MockDashboardCubit dashboardCubit,
}) {
  final user = _testUser('profile-user');
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
      nickname: '테스터',
      email: user.email ?? '',
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
