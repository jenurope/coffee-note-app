import 'package:coffee_note_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _TestableAuthService extends AuthService {
  _TestableAuthService(super.client, {required this.onInvokeWithdrawRpc});

  final Future<void> Function() onInvokeWithdrawRpc;

  @override
  Future<void> invokeWithdrawRpc() => onInvokeWithdrawRpc();
}

void main() {
  group('AuthService.getValidatedCurrentUser', () {
    late _MockSupabaseClient client;
    late _MockGoTrueClient authClient;
    late AuthService authService;
    late User localUser;

    setUp(() {
      client = _MockSupabaseClient();
      authClient = _MockGoTrueClient();
      localUser = _testUser('local-user');

      when(() => client.auth).thenReturn(authClient);
      when(
        () => authClient.signOut(scope: SignOutScope.local),
      ).thenAnswer((_) async {});

      authService = AuthService(client);
    });

    test('claims.sub가 현재 사용자 id와 같으면 인증을 유지한다', () async {
      when(() => authClient.currentUser).thenReturn(localUser);
      when(() => authClient.getClaims()).thenAnswer(
        (_) async => _claimsResponse(
          sub: localUser.id,
          alg: 'ES256',
          kid: 'signing-key',
        ),
      );

      final result = await authService.getValidatedCurrentUser();

      expect(result?.id, localUser.id);
      verifyNever(() => authClient.signOut(scope: SignOutScope.local));
    });

    test('claims.sub가 불일치하면 로컬 세션을 정리하고 null을 반환한다', () async {
      when(() => authClient.currentUser).thenReturn(localUser);
      when(() => authClient.getClaims()).thenAnswer(
        (_) async => _claimsResponse(
          sub: 'another-user',
          alg: 'ES256',
          kid: 'signing-key',
        ),
      );

      final result = await authService.getValidatedCurrentUser();

      expect(result, isNull);
      verify(() => authClient.signOut(scope: SignOutScope.local)).called(1);
    });

    test('일시 네트워크 오류면 로컬 세션을 유지한다', () async {
      when(() => authClient.currentUser).thenReturn(localUser);
      when(
        () => authClient.getClaims(),
      ).thenThrow(const AuthException('SocketException: Failed host lookup'));

      final result = await authService.getValidatedCurrentUser();

      expect(result?.id, localUser.id);
      verifyNever(() => authClient.signOut(scope: SignOutScope.local));
    });
  });

  group('AuthService.withdrawAccount', () {
    late _MockSupabaseClient client;
    late _MockGoTrueClient authClient;

    setUp(() {
      client = _MockSupabaseClient();
      authClient = _MockGoTrueClient();

      when(() => client.auth).thenReturn(authClient);
      when(
        () => authClient.signOut(scope: SignOutScope.local),
      ).thenAnswer((_) async {});
    });

    test('RPC 호출 성공 시 로컬 세션을 정리한다', () async {
      var rpcCalled = false;
      final authService = _TestableAuthService(
        client,
        onInvokeWithdrawRpc: () async {
          rpcCalled = true;
        },
      );

      await authService.withdrawAccount();

      expect(rpcCalled, isTrue);
      verify(() => authClient.signOut(scope: SignOutScope.local)).called(1);
    });

    test('RPC 호출 실패 시 에러를 전파하고 로컬 세션은 유지한다', () async {
      final authService = _TestableAuthService(
        client,
        onInvokeWithdrawRpc: () async {
          throw Exception('rpc failed');
        },
      );

      await expectLater(authService.withdrawAccount(), throwsException);

      verifyNever(() => authClient.signOut(scope: SignOutScope.local));
    });
  });
}

GetClaimsResponse _claimsResponse({
  required String sub,
  required String alg,
  String? kid,
}) {
  return GetClaimsResponse(
    claims: JwtPayload(sub: sub, claims: <String, dynamic>{'sub': sub}),
    header: JwtHeader(alg: alg, kid: kid, typ: 'JWT'),
    signature: const <int>[],
  );
}

User _testUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    email: '$id@example.com',
    createdAt: '2026-02-20T00:00:00.000Z',
  );
}
