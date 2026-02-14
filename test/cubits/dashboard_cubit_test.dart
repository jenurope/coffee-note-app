import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_cubit.dart';
import 'package:coffee_note_app/cubits/dashboard/dashboard_state.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/models/user_profile.dart';
import 'package:coffee_note_app/services/auth_service.dart';
import 'package:coffee_note_app/services/coffee_bean_service.dart';
import 'package:coffee_note_app/services/coffee_log_service.dart';
import 'package:coffee_note_app/services/guest_sample_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockAuthService extends Mock implements AuthService {}

class _MockCoffeeBeanService extends Mock implements CoffeeBeanService {}

class _MockCoffeeLogService extends Mock implements CoffeeLogService {}

void main() {
  group('DashboardCubit', () {
    late _MockAuthService authService;
    late _MockCoffeeBeanService beanService;
    late _MockCoffeeLogService logService;
    late GuestSampleService sampleService;

    setUp(() {
      authService = _MockAuthService();
      beanService = _MockCoffeeBeanService();
      logService = _MockCoffeeLogService();
      sampleService = GuestSampleService();
    });

    test('게스트 모드에서는 로컬 샘플 대시보드를 로드한다', () async {
      final authCubit = AuthCubit.test(const AuthState.guest());
      final cubit = DashboardCubit(
        authCubit: authCubit,
        authService: authService,
        beanService: beanService,
        logService: logService,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<DashboardLoaded>());
      final loaded = state as DashboardLoaded;
      expect(loaded.totalBeans, greaterThan(0));
      expect(loaded.totalLogs, greaterThan(0));
      expect(loaded.recentBeans, isNotEmpty);
      expect(loaded.recentLogs, isNotEmpty);
      verifyZeroInteractions(authService);
      verifyZeroInteractions(beanService);
      verifyZeroInteractions(logService);
    });

    test('인증 사용자에서는 서버 데이터로 대시보드를 로드한다', () async {
      final user = _testUser('auth-dashboard-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 14, 12);

      when(() => authService.getProfile(user.id)).thenAnswer(
        (_) async => UserProfile(
          id: user.id,
          nickname: '로그인유저',
          email: user.email ?? '',
          createdAt: now,
          updatedAt: now,
        ),
      );
      when(
        () => beanService.getUserBeanStats(user.id),
      ).thenAnswer((_) async => {'totalCount': 2, 'averageRating': 4.4});
      when(() => logService.getUserLogStats(user.id)).thenAnswer(
        (_) async => {
          'totalCount': 3,
          'averageRating': 4.3,
          'typeCount': {'아메리카노': 2, '라떼': 1},
        },
      );
      when(
        () => beanService.getBeans(
          userId: user.id,
          sortBy: 'created_at',
          ascending: false,
          limit: 5,
        ),
      ).thenAnswer(
        (_) async => [
          CoffeeBean(
            id: 'server-bean-1',
            userId: user.id,
            name: '서버 원두',
            roastery: '서버 로스터리',
            purchaseDate: now,
            rating: 4.4,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      when(
        () => logService.getLogs(
          userId: user.id,
          sortBy: 'created_at',
          ascending: false,
          limit: 5,
        ),
      ).thenAnswer(
        (_) async => [
          CoffeeLog(
            id: 'server-log-1',
            userId: user.id,
            cafeVisitDate: now,
            coffeeType: '아메리카노',
            coffeeName: '서버 커피',
            cafeName: '서버 카페',
            rating: 4.3,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final cubit = DashboardCubit(
        authCubit: authCubit,
        authService: authService,
        beanService: beanService,
        logService: logService,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<DashboardLoaded>());
      final loaded = state as DashboardLoaded;
      expect(loaded.totalBeans, 2);
      expect(loaded.totalLogs, 3);
      expect(loaded.recentBeans.single.id, 'server-bean-1');
      expect(loaded.recentLogs.single.id, 'server-log-1');
    });

    test('로그아웃 상태 전환 시 대시보드 데이터를 초기화한다', () async {
      final user = _testUser('auth-dashboard-user-2');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final now = DateTime(2026, 2, 14, 12);

      when(() => authService.getProfile(user.id)).thenAnswer(
        (_) async => UserProfile(
          id: user.id,
          nickname: '로그인유저',
          email: user.email ?? '',
          createdAt: now,
          updatedAt: now,
        ),
      );
      when(
        () => beanService.getUserBeanStats(user.id),
      ).thenAnswer((_) async => {'totalCount': 1, 'averageRating': 4.0});
      when(() => logService.getUserLogStats(user.id)).thenAnswer(
        (_) async => {
          'totalCount': 1,
          'averageRating': 4.0,
          'typeCount': {'아메리카노': 1},
        },
      );
      when(
        () => beanService.getBeans(
          userId: user.id,
          sortBy: 'created_at',
          ascending: false,
          limit: 5,
        ),
      ).thenAnswer((_) async => []);
      when(
        () => logService.getLogs(
          userId: user.id,
          sortBy: 'created_at',
          ascending: false,
          limit: 5,
        ),
      ).thenAnswer((_) async => []);

      final cubit = DashboardCubit(
        authCubit: authCubit,
        authService: authService,
        beanService: beanService,
        logService: logService,
        sampleService: sampleService,
      );

      await cubit.load();
      expect(cubit.state, isA<DashboardLoaded>());

      await cubit.onAuthStateChanged(const AuthState.unauthenticated());
      expect(cubit.state, isA<DashboardInitial>());
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
    createdAt: '2026-02-14T00:00:00.000Z',
  );
}
