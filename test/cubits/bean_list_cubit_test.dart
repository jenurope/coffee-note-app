import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/cubits/bean/bean_list_cubit.dart';
import 'package:coffee_note_app/cubits/bean/bean_list_state.dart';
import 'package:coffee_note_app/models/coffee_bean.dart';
import 'package:coffee_note_app/services/coffee_bean_service.dart';
import 'package:coffee_note_app/services/guest_sample_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class _MockCoffeeBeanService extends Mock implements CoffeeBeanService {}

void main() {
  group('BeanListCubit', () {
    late _MockCoffeeBeanService beanService;
    late GuestSampleService sampleService;

    setUp(() {
      beanService = _MockCoffeeBeanService();
      sampleService = GuestSampleService();
    });

    test('게스트 모드에서는 로컬 샘플 데이터를 로드한다', () async {
      final authCubit = AuthCubit.test(const AuthState.guest());
      final cubit = BeanListCubit(
        service: beanService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<BeanListLoaded>());
      expect((state as BeanListLoaded).beans, isNotEmpty);
      verifyZeroInteractions(beanService);
    });

    test('비로그인 상태에서는 빈 목록을 반환하고 서버를 호출하지 않는다', () async {
      final authCubit = AuthCubit.test(const AuthState.unauthenticated());
      final cubit = BeanListCubit(
        service: beanService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<BeanListLoaded>());
      expect((state as BeanListLoaded).beans, isEmpty);
      verifyZeroInteractions(beanService);
    });

    test('인증 사용자에서는 서버 데이터를 로드한다', () async {
      final user = _testUser('auth-user-1');
      final serverBean = _testBean(id: 'server-bean-1', userId: user.id);
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      when(
        () => beanService.getBeans(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          roastLevel: null,
          limit: null,
          offset: null,
        ),
      ).thenAnswer((_) async => [serverBean]);

      final cubit = BeanListCubit(
        service: beanService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<BeanListLoaded>());
      expect((state as BeanListLoaded).beans.single.id, 'server-bean-1');
      verify(
        () => beanService.getBeans(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          roastLevel: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('로그아웃 후 게스트 진입 시 이전 데이터가 유지되지 않는다', () async {
      final user = _testUser('auth-user-2');
      final serverBean = _testBean(id: 'server-bean-old', userId: user.id);
      final authCubit = AuthCubit.test(AuthState.authenticated(user: user));
      when(
        () => beanService.getBeans(
          userId: user.id,
          searchQuery: null,
          sortBy: null,
          ascending: false,
          minRating: null,
          roastLevel: null,
          limit: null,
          offset: null,
        ),
      ).thenAnswer((_) async => [serverBean]);

      final cubit = BeanListCubit(
        service: beanService,
        authCubit: authCubit,
        sampleService: sampleService,
      );

      await cubit.load();
      expect(
        (cubit.state as BeanListLoaded).beans.single.id,
        'server-bean-old',
      );

      await cubit.onAuthStateChanged(const AuthState.unauthenticated());
      expect(cubit.state, isA<BeanListInitial>());

      authCubit.enterGuestMode();
      await cubit.onAuthStateChanged(const AuthState.guest());
      final reloaded = cubit.state as BeanListLoaded;
      expect(reloaded.beans, isNotEmpty);
      expect(
        reloaded.beans.any((bean) => bean.id == 'server-bean-old'),
        isFalse,
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
    createdAt: '2026-02-14T00:00:00.000Z',
  );
}

CoffeeBean _testBean({required String id, required String userId}) {
  final now = DateTime(2026, 2, 14, 12);
  return CoffeeBean(
    id: id,
    userId: userId,
    name: '테스트 원두',
    roastery: '테스트 로스터리',
    purchaseDate: now,
    rating: 4.2,
    createdAt: now,
    updatedAt: now,
  );
}
