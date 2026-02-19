import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _client;
  late final GoTrueClient _auth;

  // iOS 클라이언트 ID
  static const String _iosClientId =
      '8081750780-m14ad4segdpjfcdve6tk62489eqqkd6u.apps.googleusercontent.com';
  // Web 클라이언트 ID (Supabase용)
  static const String _webClientId =
      '8081750780-scf0av9f4beqnb2in0p2sshqava1us8h.apps.googleusercontent.com';

  AuthService(this._client) {
    _auth = _client.auth;
  }

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 로그인 상태 스트림
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // 앱 시작 시 로컬 세션을 클레임 기반으로 검증
  Future<User?> getValidatedCurrentUser() async {
    final localUser = _auth.currentUser;
    if (localUser == null) return null;

    try {
      final claimsResponse = await _auth.getClaims();
      final claimsSub = claimsResponse.claims.sub;

      if (claimsSub == null || claimsSub.isEmpty) {
        debugPrint('Validate current user failed: claims.sub is empty');
        await _clearLocalSession();
        return null;
      }

      if (claimsSub != localUser.id) {
        debugPrint(
          'Validate current user failed: claims.sub mismatch '
          '(claims: $claimsSub, local: ${localUser.id})',
        );
        await _clearLocalSession();
        return null;
      }

      final algorithm = claimsResponse.header.alg;
      final kid = claimsResponse.header.kid;
      final likelyServerFallback = algorithm.startsWith('HS') || kid == null;

      if (likelyServerFallback) {
        debugPrint(
          'Validate current user via getClaims fallback(server): '
          'alg=$algorithm, kid=$kid',
        );
      } else {
        debugPrint(
          'Validate current user via getClaims local verification success: '
          'alg=$algorithm, kid=$kid',
        );
      }

      return localUser;
    } on AuthException catch (e) {
      if (_shouldForceSignOutForValidationError(e.message)) {
        debugPrint(
          'Validate current user via getClaims failed and session cleared: '
          '${e.message}',
        );
        await _clearLocalSession();
        return null;
      }

      // 네트워크 등 일시 오류 시에는 로컬 세션을 유지
      debugPrint(
        'Validate current user via getClaims skipped (transient): ${e.message}',
      );
      return localUser;
    } catch (e) {
      debugPrint('Validate current user via getClaims unexpected error: $e');
      return localUser;
    }
  }

  // 구글 로그인
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다.');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }

      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 프로필이 없으면 생성
      if (response.user != null) {
        await _ensureProfileExists(response.user!);
      }

      return response;
    } catch (e) {
      debugPrint('SignInWithGoogle error: $e');
      rethrow;
    }
  }

  // 프로필 존재 확인 및 생성
  Future<void> _ensureProfileExists(User user) async {
    try {
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        // 프로필이 없으면 생성
        final email = user.email ?? '';
        final nickname =
            user.userMetadata?['name'] ??
            user.userMetadata?['full_name'] ??
            email.split('@').first;

        await _client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'nickname': nickname,
        });
      }
    } catch (e) {
      debugPrint('Ensure profile exists error: $e');
      // 프로필 생성 실패해도 로그인은 성공으로 처리
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('SignOut error: $e');
      rethrow;
    }
  }

  // 사용자 프로필 가져오기
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, nickname, email, avatar_url, created_at, updated_at')
          .eq('id', userId)
          .maybeSingle();

      return response == null ? null : UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile({
    required String userId,
    required String nickname,
    required String? avatarUrl,
  }) async {
    try {
      final normalizedNickname = nickname.trim();
      final now = DateTime.now().toIso8601String();
      final existing = await _client
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('profiles').insert({
          'id': userId,
          'email': _auth.currentUser?.email ?? '',
          'nickname': normalizedNickname,
          'avatar_url': avatarUrl,
          'updated_at': now,
        });
        return;
      }

      final updates = <String, dynamic>{
        'nickname': normalizedNickname,
        'avatar_url': avatarUrl,
        'updated_at': now,
      };

      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  // 로그인 에러 메시지 한글 변환
  String getSignInErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('cancel')) {
      return 'errGoogleLoginCanceled';
    }
    if (message.contains('token')) {
      return 'errGoogleTokenUnavailable';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout')) {
      return 'errNetwork';
    }

    return 'errLoginFailed';
  }

  Future<void> _clearLocalSession() async {
    try {
      await _auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint('Clear local session error: $e');
    }
  }

  bool _shouldForceSignOutForValidationError(String message) {
    final normalized = message.toLowerCase();
    const patterns = <String>[
      'user not found',
      'does not exist',
      'invalid claim',
      'invalid jwt',
      'jwt expired',
      'token expired',
      'invalid signature',
      'invalid refresh token',
      'refresh token not found',
      'session not found',
      'auth session missing',
    ];
    return patterns.any(normalized.contains);
  }
}
