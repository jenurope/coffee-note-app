import 'package:coffee_note_app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _TestableAuthService extends AuthService {
  _TestableAuthService(
    super.client, {
    required this.onInvokeWithdrawRpc,
    required this.onCleanupWithdrawStorage,
  });

  final Future<void> Function() onInvokeWithdrawRpc;
  final Future<void> Function(String userId) onCleanupWithdrawStorage;

  @override
  Future<void> invokeWithdrawRpc() => onInvokeWithdrawRpc();

  @override
  Future<void> cleanupWithdrawStorageBestEffort(String userId) {
    return onCleanupWithdrawStorage(userId);
  }
}

class _TermsAwareAuthService extends AuthService {
  _TermsAwareAuthService(
    super.client, {
    this.onFetchActiveRequiredTermVersions,
    this.onFetchUserAgreedTermsConsents,
    this.onFetchActiveTermsWithContents,
    this.onFetchActiveTermsMeta,
    this.onUpsertUserTermsConsents,
  });

  final Future<List<Map<String, dynamic>>> Function()?
  onFetchActiveRequiredTermVersions;
  final Future<List<Map<String, dynamic>>> Function(String userId)?
  onFetchUserAgreedTermsConsents;
  final Future<List<Map<String, dynamic>>> Function()?
  onFetchActiveTermsWithContents;
  final Future<List<Map<String, dynamic>>> Function()? onFetchActiveTermsMeta;
  final Future<void> Function(List<Map<String, dynamic>> rows)?
  onUpsertUserTermsConsents;

  @override
  Future<List<Map<String, dynamic>>> fetchActiveRequiredTermVersions() {
    final handler = onFetchActiveRequiredTermVersions;
    if (handler == null) {
      return super.fetchActiveRequiredTermVersions();
    }
    return handler();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchUserAgreedTermsConsents(
    String userId,
  ) {
    final handler = onFetchUserAgreedTermsConsents;
    if (handler == null) {
      return super.fetchUserAgreedTermsConsents(userId);
    }
    return handler(userId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchActiveTermsWithContents() {
    final handler = onFetchActiveTermsWithContents;
    if (handler == null) {
      return super.fetchActiveTermsWithContents();
    }
    return handler();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchActiveTermsMeta() {
    final handler = onFetchActiveTermsMeta;
    if (handler == null) {
      return super.fetchActiveTermsMeta();
    }
    return handler();
  }

  @override
  Future<void> upsertUserTermsConsents(List<Map<String, dynamic>> rows) {
    final handler = onUpsertUserTermsConsents;
    if (handler == null) {
      return super.upsertUserTermsConsents(rows);
    }
    return handler(rows);
  }
}

void main() {
  group('AuthService.signOut', () {
    late _MockSupabaseClient client;
    late _MockGoTrueClient authClient;
    late AuthService authService;

    setUp(() {
      client = _MockSupabaseClient();
      authClient = _MockGoTrueClient();
      when(() => client.auth).thenReturn(authClient);
      authService = AuthService(client);
    });

    test('로컬 로그아웃을 수행하고 예외 없이 종료한다', () async {
      when(
        () => authClient.signOut(scope: SignOutScope.local),
      ).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => authClient.signOut(scope: SignOutScope.local)).called(1);
    });

    test('서버 로그아웃 실패가 발생해도 예외를 전파하지 않는다', () async {
      when(
        () => authClient.signOut(scope: SignOutScope.local),
      ).thenThrow(Exception('network offline'));

      await expectLater(authService.signOut(), completes);

      verify(() => authClient.signOut(scope: SignOutScope.local)).called(1);
    });
  });

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

    test('getClaims null-check 오류 시 getUser fallback으로 검증한다', () async {
      when(() => authClient.currentUser).thenReturn(localUser);
      when(
        () => authClient.getClaims(),
      ).thenThrow(Exception('Null check operator used on a null value'));
      when(
        () => authClient.getUser(),
      ).thenAnswer((_) async => _userResponse(localUser));

      final result = await authService.getValidatedCurrentUser();

      expect(result?.id, localUser.id);
      verify(() => authClient.getUser()).called(1);
      verifyNever(() => authClient.signOut(scope: SignOutScope.local));
    });
  });

  group('AuthService.withdrawAccount', () {
    late _MockSupabaseClient client;
    late _MockGoTrueClient authClient;
    late User localUser;

    setUp(() {
      client = _MockSupabaseClient();
      authClient = _MockGoTrueClient();
      localUser = _testUser('withdraw-user');

      when(() => client.auth).thenReturn(authClient);
      when(() => authClient.currentUser).thenReturn(localUser);
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
        onCleanupWithdrawStorage: (_) async {},
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
        onCleanupWithdrawStorage: (_) async {},
      );

      await expectLater(authService.withdrawAccount(), throwsException);

      verifyNever(() => authClient.signOut(scope: SignOutScope.local));
    });

    test('스토리지 정리 실패가 있어도 회원탈퇴를 계속 진행한다', () async {
      var rpcCalled = false;
      final authService = _TestableAuthService(
        client,
        onInvokeWithdrawRpc: () async {
          rpcCalled = true;
        },
        onCleanupWithdrawStorage: (_) async {
          throw Exception('storage cleanup failed');
        },
      );

      await authService.withdrawAccount();

      expect(rpcCalled, isTrue);
      verify(() => authClient.signOut(scope: SignOutScope.local)).called(1);
    });
  });

  group('AuthService terms consent', () {
    late _MockSupabaseClient client;
    late _MockGoTrueClient authClient;

    setUp(() {
      client = _MockSupabaseClient();
      authClient = _MockGoTrueClient();
      when(() => client.auth).thenReturn(authClient);
    });

    test('활성 필수 약관 동의가 누락되면 pending=true를 반환한다', () async {
      final service = _TermsAwareAuthService(
        client,
        onFetchActiveRequiredTermVersions: () async => <Map<String, dynamic>>[
          <String, dynamic>{'code': 'service_terms', 'current_version': 1},
          <String, dynamic>{'code': 'privacy_policy', 'current_version': 2},
        ],
        onFetchUserAgreedTermsConsents: (_) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'term_code': 'service_terms',
            'version': 1,
            'agreed': true,
          },
        ],
      );

      final pending = await service.hasPendingRequiredTerms('user-1');

      expect(pending, isTrue);
    });

    test('활성 필수 약관 최신 버전에 모두 동의했으면 pending=false를 반환한다', () async {
      final service = _TermsAwareAuthService(
        client,
        onFetchActiveRequiredTermVersions: () async => <Map<String, dynamic>>[
          <String, dynamic>{'code': 'service_terms', 'current_version': 1},
          <String, dynamic>{'code': 'privacy_policy', 'current_version': 2},
        ],
        onFetchUserAgreedTermsConsents: (_) async => <Map<String, dynamic>>[
          <String, dynamic>{
            'term_code': 'service_terms',
            'version': 1,
            'agreed': true,
          },
          <String, dynamic>{
            'term_code': 'privacy_policy',
            'version': 2,
            'agreed': true,
          },
        ],
      );

      final pending = await service.hasPendingRequiredTerms('user-2');

      expect(pending, isFalse);
    });

    test('fetchActiveTerms는 locale과 current_version에 맞는 본문을 반환한다', () async {
      final service = _TermsAwareAuthService(
        client,
        onFetchActiveTermsWithContents: () async => <Map<String, dynamic>>[
          <String, dynamic>{
            'code': 'service_terms',
            'is_required': true,
            'current_version': 2,
            'sort_order': 10,
            'terms_contents': <Map<String, dynamic>>[
              <String, dynamic>{
                'locale': 'ko',
                'version': 2,
                'title': '서비스 이용약관',
                'content': 'ko-content',
              },
              <String, dynamic>{
                'locale': 'en',
                'version': 2,
                'title': 'Terms of Service',
                'content': 'en-content',
              },
            ],
          },
        ],
      );

      final terms = await service.fetchActiveTerms(localeCode: 'en');

      expect(terms, hasLength(1));
      expect(terms.first.code, 'service_terms');
      expect(terms.first.version, 2);
      expect(terms.first.title, 'Terms of Service');
      expect(terms.first.content, 'en-content');
    });

    test('saveTermsConsents는 활성 약관을 버전 단위로 upsert한다', () async {
      List<Map<String, dynamic>>? savedRows;
      final service = _TermsAwareAuthService(
        client,
        onFetchActiveTermsMeta: () async => <Map<String, dynamic>>[
          <String, dynamic>{
            'code': 'service_terms',
            'is_required': true,
            'current_version': 1,
            'sort_order': 10,
          },
          <String, dynamic>{
            'code': 'privacy_policy',
            'is_required': true,
            'current_version': 2,
            'sort_order': 20,
          },
          <String, dynamic>{
            'code': 'marketing_opt_in',
            'is_required': false,
            'current_version': 1,
            'sort_order': 30,
          },
        ],
        onUpsertUserTermsConsents: (rows) async {
          savedRows = rows;
        },
      );

      await service.saveTermsConsents(
        userId: 'user-3',
        decisions: const <String, bool>{
          'service_terms': true,
          'privacy_policy': true,
          'marketing_opt_in': false,
        },
      );

      expect(savedRows, isNotNull);
      expect(savedRows, hasLength(3));
      expect(savedRows![0]['term_code'], 'service_terms');
      expect(savedRows![0]['version'], 1);
      expect(savedRows![0]['agreed'], true);
      expect(savedRows![1]['term_code'], 'privacy_policy');
      expect(savedRows![1]['version'], 2);
      expect(savedRows![2]['term_code'], 'marketing_opt_in');
      expect(savedRows![2]['agreed'], false);
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

UserResponse _userResponse(User user) {
  return UserResponse.fromJson({
    'id': user.id,
    'aud': user.aud,
    'email': user.email,
    'app_metadata': user.appMetadata,
    'user_metadata': user.userMetadata,
    'created_at': user.createdAt,
  });
}
