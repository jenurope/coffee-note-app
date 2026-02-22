import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.termsRequired({required User user}) =
      AuthTermsRequired;
  const factory AuthState.authenticated({required User user}) =
      AuthAuthenticated;
  const factory AuthState.guest() = AuthGuest;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error({required String message}) = AuthError;
}
