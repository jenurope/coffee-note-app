import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_cubit.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/screens/dashboard/dashboard_screen.dart';
import 'package:coffee_note_app/widgets/bean_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

void main() {
  group('DashboardScreen', () {
    late _MockAuthCubit authCubit;
    late _MockDashboardCubit dashboardCubit;

    setUp(() {
      authCubit = _MockAuthCubit();
      dashboardCubit = _MockDashboardCubit();
    });

    tearDown(() async {
      await authCubit.close();
      await dashboardCubit.close();
    });

    testWidgets('모든 기록 기능이 꺼져 있으면 기록 섹션 대신 안내 문구를 노출한다', (tester) async {
      final user = _testUser('dashboard-user');
      final authState = AuthState.authenticated(user: user);
      final now = DateTime(2026, 3, 6, 9);
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
          isBeanRecordsEnabled: false,
          isCoffeeRecordsEnabled: false,
          createdAt: now,
          updatedAt: now,
        ),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => dashboardCubit.state).thenReturn(dashboardState);

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

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          ],
          child: MaterialApp(
            home: const DashboardScreen(),
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

      expect(find.text('최근 원두'), findsNothing);
      expect(find.text('최근 커피 기록'), findsNothing);
      expect(
        find.text('모든 기록 기능이 꺼져 있습니다. 프로필 탭의 설정에서 다시 켤 수 있습니다.'),
        findsOneWidget,
      );
    });

    testWidgets('최근 원두는 카드 대신 리스트 타일로 노출한다', (tester) async {
      final user = _testUser('dashboard-user');
      final authState = AuthState.authenticated(user: user);
      final now = DateTime(2026, 3, 6, 9);
      final dashboardState = DashboardState.loaded(
        totalBeans: 1,
        averageBeanRating: 4.5,
        totalLogs: 0,
        averageLogRating: 0,
        coffeeTypeCount: const {},
        recentBeans: [
          CoffeeBean(
            id: 'bean-1',
            userId: user.id,
            name: '에티오피아 예가체프',
            roastery: '테스트 로스터리',
            purchaseDate: now,
            rating: 4.5,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        recentLogs: const <CoffeeLog>[],
        userProfile: UserProfile(
          id: user.id,
          nickname: '테스터',
          email: user.email ?? '',
          isBeanRecordsEnabled: true,
          isCoffeeRecordsEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => dashboardCubit.state).thenReturn(dashboardState);

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

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          ],
          child: MaterialApp(
            home: const DashboardScreen(),
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

      expect(find.byType(BeanListTile), findsOneWidget);
      expect(find.text('에티오피아 예가체프'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('첫 원두/커피 등록 카드는 좌우로 꽉 차게 노출한다', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final user = _testUser('dashboard-user');
      final authState = AuthState.authenticated(user: user);
      final now = DateTime(2026, 3, 6, 9);
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
          isBeanRecordsEnabled: true,
          isCoffeeRecordsEnabled: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      when(() => authCubit.state).thenReturn(authState);
      when(() => dashboardCubit.state).thenReturn(dashboardState);

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

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          ],
          child: MaterialApp(
            home: const DashboardScreen(),
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

      expect(
        tester
            .getSize(find.byKey(const ValueKey('dashboardEmptyBeanCard')))
            .width,
        moreOrLessEquals(358),
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('dashboardEmptyCoffeeCard')))
            .width,
        moreOrLessEquals(358),
      );
    });
  });
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-03-06T00:00:00.000Z',
  );
}
