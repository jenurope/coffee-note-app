import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_cubit.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_state.dart';
import 'package:coffee_note_app/l10n/app_localizations.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

    testWidgets('인증 사용자에게 레시피 관리 카드가 최근 원두 기록 위에 노출되고 이동된다', (tester) async {
      final authState = AuthState.authenticated(user: _testUser('dash-user'));
      final dashState = _loadedState();
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        dashboardCubit,
        Stream<DashboardState>.fromIterable([dashState]),
        initialState: dashState,
      );

      await _pumpDashboard(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      expect(find.text('레시피 관리'), findsOneWidget);
      final recipeTop = tester.getTopLeft(find.text('레시피 관리')).dy;
      final recentBeanTop = tester.getTopLeft(find.text('최근 원두 기록')).dy;
      expect(recipeTop < recentBeanTop, isTrue);

      await tester.tap(find.text('레시피 관리'));
      await tester.pumpAndSettle();

      expect(find.text('레시피 관리 화면'), findsOneWidget);
    });

    testWidgets('게스트 사용자에게 레시피 관리 카드는 노출되지 않는다', (tester) async {
      const authState = AuthState.guest();
      final dashState = _loadedState();
      whenListen(
        authCubit,
        Stream<AuthState>.fromIterable([authState]),
        initialState: authState,
      );
      whenListen(
        dashboardCubit,
        Stream<DashboardState>.fromIterable([dashState]),
        initialState: dashState,
      );

      await _pumpDashboard(
        tester,
        authCubit: authCubit,
        dashboardCubit: dashboardCubit,
      );

      expect(find.text('레시피 관리'), findsNothing);
    });
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required AuthCubit authCubit,
  required DashboardCubit dashboardCubit,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
      GoRoute(
        path: '/beans/recipes',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('레시피 관리 화면'))),
      ),
      GoRoute(
        path: '/beans',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('원두 화면'))),
      ),
      GoRoute(
        path: '/logs',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('커피 화면'))),
      ),
      GoRoute(
        path: '/beans/new',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('원두 신규'))),
      ),
      GoRoute(
        path: '/logs/new',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('커피 신규'))),
      ),
    ],
  );

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DashboardCubit>.value(value: dashboardCubit),
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
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

DashboardState _loadedState() {
  return const DashboardState.loaded(
    totalBeans: 0,
    averageBeanRating: 0,
    totalLogs: 0,
    averageLogRating: 0,
    coffeeTypeCount: <String, int>{},
    recentBeans: <CoffeeBean>[],
    recentLogs: <CoffeeLog>[],
  );
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {'name': '테스트'},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-27T00:00:00.000Z',
  );
}
