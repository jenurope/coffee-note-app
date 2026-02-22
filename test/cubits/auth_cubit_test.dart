import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa show User;

class _MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthCubit', () {
    late _MockAuthService authService;

    setUp(() {
      authService = _MockAuthService();
      when(
        () => authService.authStateChanges,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => authService.hasPendingRequiredTerms(any()),
      ).thenAnswer((_) async => false);
    });

    test('시작 시 검증된 사용자가 있으면 authenticated 상태가 된다', () async {
      final user = _testUser('validated-user');
      when(
        () => authService.getValidatedCurrentUser(),
      ).thenAnswer((_) async => user);

      final cubit = AuthCubit(authService: authService);

      await untilCalled(() => authService.getValidatedCurrentUser());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthAuthenticated>());
      expect((cubit.state as AuthAuthenticated).user.id, user.id);
      verify(() => authService.getValidatedCurrentUser()).called(1);
      verify(() => authService.hasPendingRequiredTerms(user.id)).called(1);

      await cubit.close();
    });

    test('시작 시 검증된 사용자가 없으면 unauthenticated 상태가 된다', () async {
      when(
        () => authService.getValidatedCurrentUser(),
      ).thenAnswer((_) async => null);

      final cubit = AuthCubit(authService: authService);

      await untilCalled(() => authService.getValidatedCurrentUser());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthUnauthenticated>());
      verify(() => authService.getValidatedCurrentUser()).called(1);

      await cubit.close();
    });

    test('필수 약관 동의가 필요하면 termsRequired 상태가 된다', () async {
      final user = _testUser('terms-required-user');
      when(
        () => authService.getValidatedCurrentUser(),
      ).thenAnswer((_) async => user);
      when(
        () => authService.hasPendingRequiredTerms(user.id),
      ).thenAnswer((_) async => true);

      final cubit = AuthCubit(authService: authService);

      await untilCalled(() => authService.getValidatedCurrentUser());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthTermsRequired>());
      expect((cubit.state as AuthTermsRequired).user.id, user.id);

      await cubit.close();
    });

    test('필수 약관 동의 저장 성공 시 authenticated 상태가 된다', () async {
      final user = _testUser('terms-submit-user');
      when(
        () => authService.getValidatedCurrentUser(),
      ).thenAnswer((_) async => user);
      var pendingChecks = 0;
      when(
        () => authService.hasPendingRequiredTerms(user.id),
      ).thenAnswer((_) async {
        pendingChecks += 1;
        return pendingChecks == 1;
      });
      when(
        () => authService.saveTermsConsents(
          userId: user.id,
          decisions: any(named: 'decisions'),
        ),
      ).thenAnswer((_) async {});

      final cubit = AuthCubit(authService: authService);

      await untilCalled(() => authService.getValidatedCurrentUser());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<AuthTermsRequired>());

      await cubit.acceptTermsConsents(const <String, bool>{
        'service_terms': true,
        'privacy_policy': true,
      });

      expect(cubit.state, isA<AuthAuthenticated>());

      await cubit.close();
    });

    test('필수 약관 상태 조회 실패 시 error 상태가 된다', () async {
      final user = _testUser('terms-error-user');
      when(
        () => authService.getValidatedCurrentUser(),
      ).thenAnswer((_) async => user);
      when(
        () => authService.hasPendingRequiredTerms(user.id),
      ).thenThrow(Exception('terms query failed'));

      final cubit = AuthCubit(authService: authService);

      await untilCalled(() => authService.getValidatedCurrentUser());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthError>());
      expect((cubit.state as AuthError).message, 'errTermsLoadFailed');

      await cubit.close();
    });

    test('withdraw 호출 시 회원탈퇴를 수행하고 unauthenticated 상태가 된다', () async {
      final user = _testUser('withdraw-user');
      when(
        () => authService.getValidatedCurrentUser(),
      ).thenAnswer((_) async => user);
      when(() => authService.withdrawAccount()).thenAnswer((_) async {});

      final cubit = AuthCubit(authService: authService);

      await untilCalled(() => authService.getValidatedCurrentUser());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<AuthAuthenticated>());

      await cubit.withdraw();

      expect(cubit.state, isA<AuthUnauthenticated>());
      verify(() => authService.withdrawAccount()).called(1);

      await cubit.close();
    });
  });
}

supa.User _testUser(String id) {
  return supa.User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-20T00:00:00.000Z',
  );
}
