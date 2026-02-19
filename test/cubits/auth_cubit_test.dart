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
