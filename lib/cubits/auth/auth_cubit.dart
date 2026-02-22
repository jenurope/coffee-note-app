import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    as supa
    show AuthState, User;

import '../../core/di/service_locator.dart';
import '../../models/terms/term_policy.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthService? authService}) : super(const AuthState.initial()) {
    try {
      _authService = authService ?? getIt<AuthService>();
      _init();
    } catch (e) {
      debugPrint('AuthCubit failed to resolve AuthService: $e');
    }
  }

  /// 테스트 전용: AuthService 없이 초기 상태만 지정.
  @visibleForTesting
  AuthCubit.test(super.initialState) : _authService = null;

  AuthService? _authService;
  StreamSubscription<supa.AuthState>? _authSubscription;

  /// AuthService.authStateChanges 스트림 구독 (P0: 세션 만료/외부 로그아웃 감지)
  void _init() {
    final service = _authService;
    if (service == null) return;

    _hydrateAuthState(service);

    _authSubscription = service.authStateChanges.listen(
      (authState) {
        final user = authState.session?.user;
        if (user != null) {
          if (state is! AuthGuest) {
            unawaited(_emitAuthenticatedState(user));
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

  Future<void> _hydrateAuthState(AuthService service) async {
    try {
      final validatedUser = await service.getValidatedCurrentUser();
      if (state is AuthGuest) return;

      if (validatedUser != null) {
        await _emitAuthenticatedState(validatedUser);
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      debugPrint('Auth bootstrap error: $e');
      if (state is! AuthGuest) {
        emit(const AuthState.unauthenticated());
      }
    }
  }

  /// Google 로그인
  Future<void> signInWithGoogle() async {
    final service = _authService;
    if (service == null) return;

    emit(const AuthState.loading());
    try {
      final response = await service.signInWithGoogle();
      if (response.user != null) {
        await _emitAuthenticatedState(response.user!);
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      final message = service.getSignInErrorMessage(e);
      emit(AuthState.error(message: message));
    }
  }

  Future<List<TermPolicy>> fetchActiveTerms({
    required String localeCode,
  }) async {
    final service = _authService;
    if (service == null) return const <TermPolicy>[];
    return service.fetchActiveTerms(localeCode: localeCode);
  }

  Future<void> acceptTermsConsents(Map<String, bool> decisions) async {
    final service = _authService;
    if (service == null) return;
    final currentState = state;
    if (currentState is! AuthTermsRequired) {
      return;
    }

    emit(const AuthState.loading());

    try {
      await service.saveTermsConsents(
        userId: currentState.user.id,
        decisions: decisions,
      );
      await _emitAuthenticatedState(currentState.user);
    } catch (e) {
      final message = service.getTermsErrorMessage(e);
      emit(AuthState.error(message: message));
    }
  }

  Future<void> declineTerms() async {
    await signOut();
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _authService?.signOut();
    emit(const AuthState.unauthenticated());
  }

  /// 회원 탈퇴
  Future<void> withdraw() async {
    await _authService?.withdrawAccount();
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

  Future<void> _emitAuthenticatedState(supa.User user) async {
    final service = _authService;
    if (service == null) return;
    try {
      final hasPendingTerms = await service.hasPendingRequiredTerms(user.id);
      if (state is AuthGuest) return;
      if (hasPendingTerms) {
        emit(AuthState.termsRequired(user: user));
        return;
      }
      emit(AuthState.authenticated(user: user));
    } catch (e) {
      debugPrint('Auth terms resolution error: $e');
      if (state is! AuthGuest) {
        emit(const AuthState.error(message: 'errTermsLoadFailed'));
      }
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
