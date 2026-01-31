import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

import '../config/supabase_config.dart';

// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService(SupabaseConfig.client));

// 현재 인증 상태 Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// 현재 사용자 Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
    data: (state) => state.session?.user,
  );
});

// 게스트 모드 Notifier
class GuestModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enter() => state = true;
  void exit() => state = false;
}

final isGuestModeProvider = NotifierProvider<GuestModeNotifier, bool>(
  GuestModeNotifier.new,
);

// 로그인 여부 (게스트 모드 포함)
final isLoggedInProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final isGuest = ref.watch(isGuestModeProvider);
  return currentUser != null || isGuest;
});

// 현재 사용자 프로필 Provider
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;

  final authService = ref.watch(authServiceProvider);
  return await authService.getProfile(currentUser.id);
});

// 인증 상태 관리 Notifier
class AuthNotifier extends Notifier<AsyncValue<User?>> {
  late final AuthService _authService;

  @override
  AsyncValue<User?> build() {
    _authService = ref.watch(authServiceProvider);
    final user = _authService.currentUser;
    return AsyncValue.data(user);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      state = AsyncValue.data(response.user);
      ref.read(isGuestModeProvider.notifier).exit();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );
      state = AsyncValue.data(response.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    ref.read(isGuestModeProvider.notifier).exit();
    state = const AsyncValue.data(null);
  }

  void enterGuestMode() {
    ref.read(isGuestModeProvider.notifier).enter();
  }

  void exitGuestMode() {
    ref.read(isGuestModeProvider.notifier).exit();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<User?>>(
  AuthNotifier.new,
);
