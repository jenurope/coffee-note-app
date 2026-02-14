import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthState;

import '../../core/di/service_locator.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthService? authService})
    : _authService = authService ?? getIt<AuthService>(),
      super(const AuthState.initial()) {
    _init();
  }

  /// 테스트 전용: AuthService 없이 초기 상태만 지정.
  @visibleForTesting
  AuthCubit.test(AuthState initialState)
    : _authService = null,
      super(initialState);

  final AuthService? _authService;
  StreamSubscription<supa.AuthState>? _authSubscription;

  /// AuthService.authStateChanges 스트림 구독 (P0: 세션 만료/외부 로그아웃 감지)
  void _init() {
    final service = _authService;
    if (service == null) return;

    // 현재 사용자가 이미 있는 경우 즉시 반영
    final currentUser = service.currentUser;
    if (currentUser != null) {
      emit(AuthState.authenticated(user: currentUser));
    }

    _authSubscription = service.authStateChanges.listen(
      (authState) {
        final user = authState.session?.user;
        if (user != null) {
          if (state is! AuthGuest) {
            emit(AuthState.authenticated(user: user));
          }
        } else {
          if (state is! AuthGuest) {
            emit(const AuthState.unauthenticated());
          }
        }
      },
      onError: (error) {
        debugPrint('Auth stream error: $error');
      },
    );
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    final service = _authService;
    if (service == null) return;

    emit(const AuthState.loading());
    try {
      final response = await service.signInWithGoogle();
      if (response.user != null) {
        emit(AuthState.authenticated(user: response.user!));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      final message = service.getErrorMessage(e);
      emit(AuthState.error(message: message));
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _authService?.signOut();
    emit(const AuthState.unauthenticated());
  }

  /// 게스트 모드 진입
  void enterGuestMode() {
    emit(const AuthState.guest());
  }

  /// 게스트 모드 종료
  void exitGuestMode() {
    emit(const AuthState.unauthenticated());
  }

  /// 현재 게스트 모드 여부
  bool get isGuest => state is AuthGuest;

  /// 현재 인증된 사용자 여부
  bool get isAuthenticated => state is AuthAuthenticated;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
