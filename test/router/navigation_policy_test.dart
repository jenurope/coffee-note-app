import 'package:coffee_note_app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppRedirect', () {
    test('keeps splash while auth state is resolving', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.resolving,
        location: AppRoutePath.splash,
      );

      expect(redirect, isNull);
    });

    test('redirects to splash while auth state is resolving', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.resolving,
        location: AppRoutePath.dashboard,
      );

      expect(redirect, AppRoutePath.splash);
    });

    test('redirects splash to login for unauthenticated users', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.unauthenticated,
        location: AppRoutePath.splash,
      );

      expect(redirect, AppRoutePath.login);
    });

    test('redirects splash to dashboard for authenticated users', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.authenticated,
        location: AppRoutePath.splash,
      );

      expect(redirect, AppRoutePath.dashboard);
    });

    test('redirects private route to login for unauthenticated users', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.unauthenticated,
        location: AppRoutePath.beans,
      );

      expect(redirect, AppRoutePath.login);
    });

    test('allows guest users to stay on auth route', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.guest,
        location: AppRoutePath.login,
      );

      expect(redirect, isNull);
    });

    test('redirects authenticated users away from auth route', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.authenticated,
        location: AppRoutePath.login,
      );

      expect(redirect, AppRoutePath.dashboard);
    });

    test('redirects terms-required users to terms route', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.termsRequired,
        location: AppRoutePath.dashboard,
      );

      expect(redirect, AppRoutePath.terms);
    });

    test('allows terms-required users to stay on terms route', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.termsRequired,
        location: AppRoutePath.terms,
      );

      expect(redirect, isNull);
    });

    test('redirects unauthenticated users away from terms route', () {
      final redirect = resolveAppRedirect(
        authSnapshot: AppAuthSnapshot.unauthenticated,
        location: AppRoutePath.terms,
      );

      expect(redirect, AppRoutePath.login);
    });
  });
}
