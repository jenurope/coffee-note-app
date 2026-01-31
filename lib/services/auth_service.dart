import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

class AuthService {
  final _client = SupabaseConfig.client;
  final _auth = SupabaseConfig.auth;

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;

  // 로그인 상태 스트림
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // 이메일/비밀번호 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
      );

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

  // 이메일/비밀번호 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithPassword(
        email: email,
        password: password,
      );
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
          .select()
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
  Future<void> updateProfile({
    required String userId,
    String? nickname,
  }) async {
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
