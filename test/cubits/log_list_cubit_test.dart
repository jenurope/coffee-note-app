import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/log/log_list_cubit.dart';
import 'package:coffee_note_app/cubits/log/log_list_state.dart';
import 'package:coffee_note_app/models/coffee_log.dart';
import 'package:coffee_note_app/services/coffee_log_service.dart';
import 'package:coffee_note_app/services/guest_sample_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockCoffeeLogService extends Mock implements CoffeeLogService {}

void main() {
  group('LogListCubit', () {
    late _MockCoffeeLogService logService;
    late GuestSampleService sampleService;

    setUp(() {
      logService = _MockCoffeeLogService();
      sampleService = GuestSampleService();
    });

    test('게스트 모드에서는 로컬 샘플 로그를 로드한다', () async {
      final authCubit = AuthCubit.test(const AuthState.guest());
      final cubit = LogListCubit(
        service: logService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<LogListLoaded>());
      expect((state as LogListLoaded).logs, isNotEmpty);
      verifyZeroInteractions(logService);
    });

    test('비로그인 상태에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.unauthenticated());
      final cubit = LogListCubit(
        service: logService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<LogListLoaded>());
      expect((state as LogListLoaded).logs, isEmpty);
      verifyZeroInteractions(logService);
    });

    test('인증 사용자에서는 서버 로그를 로드한다', () async {
      final user = _testUser('auth-log-user');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final serverLog = _testLog(id: 'server-log-1', userId: user.id);
      when(
        () => logService.getLogs(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          coffeeType: null,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer((_) async => [serverLog]);

      final cubit = LogListCubit(
        service: logService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<LogListLoaded>());
      expect((state as LogListLoaded).logs.single.id, 'server-log-1');
      verify(
        () => logService.getLogs(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          coffeeType: null,
          limit: 20,
          offset: 0,
        ),
      ).called(1);
    });

    test('인증 사용자에서 loadMore 호출 시 다음 페이지를 이어서 로드한다', () async {
      final user = _testUser('auth-log-page');
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      final firstPage = List.generate(
        20,
        (index) => _testLog(id: 'log-$index', userId: user.id),
      );
      final nextPage = <CoffeeLog>[_testLog(id: 'log-20', userId: user.id)];
      when(
        () => logService.getLogs(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          coffeeType: null,
          limit: 20,
          offset: 0,
        ),
      ).thenAnswer((_) async => firstPage);
      when(
        () => logService.getLogs(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          coffeeType: null,
          limit: 20,
          offset: 20,
        ),
      ).thenAnswer((_) async => nextPage);

      final cubit = LogListCubit(
        service: logService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();
      await cubit.loadMore();

      final state = cubit.state as LogListLoaded;
      expect(state.logs.length, 21);
      expect(state.logs.last.id, 'log-20');
      verify(
        () => logService.getLogs(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          coffeeType: null,
          limit: 20,
          offset: 0,
        ),
      ).called(1);
      verify(
        () => logService.getLogs(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          coffeeType: null,
          limit: 20,
          offset: 20,
        ),
      ).called(1);
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

CoffeeLog _testLog({required String id, required String userId}) {
  final now = DateTime(2026, 2, 14, 12);
  return CoffeeLog(
    id: id,
    userId: userId,
    cafeVisitDate: now,
    coffeeType: '아메리카노',
    coffeeName: '테스트 커피',
    cafeName: '테스트 카페',
    rating: 4.1,
    notes: '테스트 노트',
    createdAt: now,
    updatedAt: now,
  );
}
