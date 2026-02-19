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

  // 이메일/비밀번호 회원가입 (레거시 - 참조용 유지)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final response = await _auth.signUp(email: email, password: password);

      // 프로필 생성
      if (response.user != null) {
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'nickname': nickname,
        });
      }

      return response;
    } catch (e) {
      debugPrint('SignUp error: $e');
      rethrow;
    }
  }

  // 이메일/비밀번호 로그인 (레거시 - 참조용 유지)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      debugPrint('SignIn error: $e');
      rethrow;
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

  // 비밀번호 재설정 이메일 발송
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  // 사용자 프로필 가져오기
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, nickname, created_at, updated_at')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserProfile.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  // 프로필 업데이트
  Future<void> updateProfile({required String userId, String? nickname}) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (nickname != null) updates['nickname'] = nickname;

      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  // 에러 메시지 한글 변환
  String getErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (message.contains('email not confirmed')) {
      return '이메일 인증이 필요합니다. 이메일을 확인해주세요.';
    }
    if (message.contains('user already registered')) {
      return '이미 가입된 이메일입니다.';
    }
    if (message.contains('password')) {
      return '비밀번호는 10자 이상이어야 합니다.';
    }
    if (message.contains('email')) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    if (message.contains('network')) {
      return '네트워크 연결을 확인해주세요.';
    }

    return '오류가 발생했습니다. 다시 시도해주세요.';
  }
}
