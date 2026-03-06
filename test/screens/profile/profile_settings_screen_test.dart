import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/core/di/service_locator.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_cubit.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/screens/profile/profile_settings_screen.dart';
import 'package:coffee_note_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class _MockAuthService extends Mock implements AuthService {}

void main() {
  group('ProfileSettingsScreen', () {
    late _MockAuthCubit authCubit;
    late _MockDashboardCubit dashboardCubit;
    late _MockAuthService authService;

    setUp(() async {
      authCubit = _MockAuthCubit();
      dashboardCubit = _MockDashboardCubit();
      authService = _MockAuthService();

      await getIt.reset();
      getIt.allowReassignment = true;
      getIt.registerSingleton<AuthService>(authService);
      when(
        () => authService.updateFeatureVisibilitySettings(
          userId: any(named: 'userId'),
          isBeanRecordsEnabled: any(named: 'isBeanRecordsEnabled'),
          isCoffeeRecordsEnabled: any(named: 'isCoffeeRecordsEnabled'),
        ),
      ).thenAnswer((_) async {});
      when(() => authService.getProfile(any())).thenAnswer((_) async => null);
    });

    tearDown(() async {
      await authCubit.close();
      await dashboardCubit.close();
      await getIt.reset();
    });

    testWidgets('초기 진입 시 기존 설정값을 스위치에 반영한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        isBeanRecordsEnabled: false,
        isCoffeeRecordsEnabled: true,
      );

      await _pumpProfileSettingsScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isFalse);
      expect(switches[1].value, isTrue);
    });

    testWidgets('저장 시 설정값을 저장하고 현재 화면에서 상태를 직접 갱신하지 않는다', (tester) async {
      final user = _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await _pumpProfileSettingsScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      verify(
        () => authService.updateFeatureVisibilitySettings(
          userId: user.id,
          isBeanRecordsEnabled: false,
          isCoffeeRecordsEnabled: true,
        ),
      ).called(1);
      verifyNever(
        () => dashboardCubit.updateFeatureVisibility(
          isBeanRecordsEnabled: any(named: 'isBeanRecordsEnabled'),
          isCoffeeRecordsEnabled: any(named: 'isCoffeeRecordsEnabled'),
        ),
      );
      verifyNever(() => dashboardCubit.refresh());
    });

    testWidgets('모든 기록 기능을 끄면 안내 문구를 노출한다', (tester) async {
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
        isBeanRecordsEnabled: false,
        isCoffeeRecordsEnabled: false,
      );

      await _pumpProfileSettingsScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      expect(
        find.text('모든 기록 기능이 꺼져 있습니다. 프로필 탭의 설정에서 다시 켤 수 있습니다.'),
        findsOneWidget,
      );
    });

    testWidgets('저장 버튼을 빠르게 두 번 눌러도 저장은 한 번만 호출된다', (tester) async {
      final completer = Completer<void>();
      _stubAuthenticatedState(
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );
      when(
        () => authService.updateFeatureVisibilitySettings(
          userId: any(named: 'userId'),
          isBeanRecordsEnabled: any(named: 'isBeanRecordsEnabled'),
          isCoffeeRecordsEnabled: any(named: 'isCoffeeRecordsEnabled'),
        ),
      ).thenAnswer((_) => completer.future);

      await _pumpProfileSettingsScreen(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      await tester.tap(find.text('저장'));
      await tester.pump();
      await tester.tap(find.text('저장'), warnIfMissed: false);
      await tester.pump();

      verify(
        () => authService.updateFeatureVisibilitySettings(
          userId: any(named: 'userId'),
          isBeanRecordsEnabled: any(named: 'isBeanRecordsEnabled'),
          isCoffeeRecordsEnabled: any(named: 'isCoffeeRecordsEnabled'),
        ),
      ).called(1);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}

Future<void> _pumpProfileSettingsScreen(
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
      child: MaterialApp(
        home: const ProfileSettingsScreen(),
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

User _stubAuthenticatedState({
  required _MockAuthCubit authCubit,
  required _MockDashboardCubit dashboardCubit,
  bool isBeanRecordsEnabled = true,
  bool isCoffeeRecordsEnabled = true,
}) {
  final user = _testUser('settings-user');
  final authState = AuthState.authenticated(user: user);
  final now = DateTime(2026, 2, 18, 9);
  final dashboardState = DashboardState.loaded(
    totalBeans: 0,
    averageBeanRating: 0,
    totalLogs: 0,
    averageLogRating: 0,
    coffeeTypeCount: const {},
    recentBeans: const <CoffeeBean>[],
    recentLogs: const <CoffeeLog>[],
    userProfile: UserProfile(
      id: user.id,
      nickname: '테스터',
      email: user.email ?? '',
      isBeanRecordsEnabled: isBeanRecordsEnabled,
      isCoffeeRecordsEnabled: isCoffeeRecordsEnabled,
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
