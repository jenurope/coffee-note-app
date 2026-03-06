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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
