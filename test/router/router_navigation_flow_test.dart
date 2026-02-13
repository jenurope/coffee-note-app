import 'package:coffee_note_app/providers/auth_provider.dart';
import 'package:coffee_note_app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('App navigation flow', () {
    testWidgets('splash route does not remain in the back stack', (
      WidgetTester tester,
    ) async {
      final authController = _TestAuthController(AppAuthSnapshot.resolving);
      final router = createAppRouter(
        authSnapshot: () => authController.snapshot,
        refreshListenable: authController,
        routeBuilders: _TestRouteBuilders(authController),
      );

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.text('SPLASH'), findsOneWidget);

      authController.update(AppAuthSnapshot.unauthenticated);
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('SPLASH'), findsNothing);
    });

    testWidgets('login can remain in stack for guest flow', (
      WidgetTester tester,
    ) async {
      final authController = _TestAuthController(
        AppAuthSnapshot.unauthenticated,
      );
      final router = createAppRouter(
        authSnapshot: () => authController.snapshot,
        refreshListenable: authController,
        routeBuilders: _TestRouteBuilders(authController),
      );

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await tester.tap(find.byKey(const Key('guest-login-button')));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('login does not remain in stack after authenticated go', (
      WidgetTester tester,
    ) async {
      final authController = _TestAuthController(
        AppAuthSnapshot.unauthenticated,
      );
      final router = createAppRouter(
        authSnapshot: () => authController.snapshot,
        refreshListenable: authController,
        routeBuilders: _TestRouteBuilders(authController),
      );

      await tester.pumpWidget(_buildTestApp(router));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);

      await tester.tap(find.byKey(const Key('auth-login-button')));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsNothing);
      expect(find.text('DASHBOARD'), findsOneWidget);
    });

    testWidgets(
      'guest back pops tab page stack then moves to login at tab root',
      (WidgetTester tester) async {
        final authController = _TestAuthController(AppAuthSnapshot.guest);
        final router = createAppRouter(
          authSnapshot: () => authController.snapshot,
          refreshListenable: authController,
          routeBuilders: _TestRouteBuilders(authController),
        );

        await tester.pumpWidget(_buildTestApp(router, isGuestMode: true));
        await tester.pumpAndSettle();

        expect(find.text('DASHBOARD'), findsOneWidget);

        await tester.tap(find.text('원두 기록'));
        await tester.pumpAndSettle();

        expect(find.text('BEANS_ROOT'), findsOneWidget);

        await tester.tap(find.byKey(const Key('open-bean-new-button')));
        await tester.pumpAndSettle();

        expect(find.text('BEAN_NEW'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('BEANS_ROOT'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('LOGIN'), findsOneWidget);
      },
    );

    testWidgets('guest back at non-dashboard tab root moves to login', (
      WidgetTester tester,
    ) async {
      final authController = _TestAuthController(AppAuthSnapshot.guest);
      final router = createAppRouter(
        authSnapshot: () => authController.snapshot,
        refreshListenable: authController,
        routeBuilders: _TestRouteBuilders(authController),
      );

      await tester.pumpWidget(_buildTestApp(router, isGuestMode: true));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);

      await tester.tap(find.text('커피 기록'));
      await tester.pumpAndSettle();

      expect(find.text('LOGS_ROOT'), findsOneWidget);

      await tester.tap(find.text('커뮤니티'));
      await tester.pumpAndSettle();

      expect(find.text('COMMUNITY_ROOT'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('LOGS_ROOT'), findsNothing);
    });

    testWidgets('tab switch preserves each tab stack history', (
      WidgetTester tester,
    ) async {
      final authController = _TestAuthController(AppAuthSnapshot.guest);
      final router = createAppRouter(
        authSnapshot: () => authController.snapshot,
        refreshListenable: authController,
        routeBuilders: _TestRouteBuilders(authController),
      );

      await tester.pumpWidget(_buildTestApp(router, isGuestMode: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('원두 기록'));
      await tester.pumpAndSettle();
      expect(find.text('BEANS_ROOT'), findsOneWidget);

      await tester.tap(find.byKey(const Key('open-bean-new-button')));
      await tester.pumpAndSettle();
      expect(find.text('BEAN_NEW'), findsOneWidget);

      await tester.tap(find.text('커피 기록'));
      await tester.pumpAndSettle();
      expect(find.text('LOGS_ROOT'), findsOneWidget);

      await tester.tap(find.text('원두 기록'));
      await tester.pumpAndSettle();

      expect(find.text('BEAN_NEW'), findsOneWidget);
    });
  });
}

Widget _buildTestApp(GoRouter router, {bool isGuestMode = false}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => null),
      isGuestModeProvider.overrideWith(
        () => _TestGuestModeNotifier(isGuestMode),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _TestGuestModeNotifier extends GuestModeNotifier {
  _TestGuestModeNotifier(this.initialValue);

  final bool initialValue;

  @override
  bool build() => initialValue;
}

class _TestAuthController extends ChangeNotifier {
  _TestAuthController(this.snapshot);

  AppAuthSnapshot snapshot;

  void update(AppAuthSnapshot next) {
    snapshot = next;
    notifyListeners();
  }
}

class _TestRouteBuilders extends AppRouteBuilders {
  const _TestRouteBuilders(this.authController);

  final _TestAuthController authController;

  @override
  Widget buildSplash(BuildContext context, GoRouterState state) {
    return const _LabelScreen('SPLASH');
  }

  @override
  Widget buildLogin(BuildContext context, GoRouterState state) {
    return _LoginTestScreen(authController: authController);
  }

  @override
  Widget buildDashboard(BuildContext context, GoRouterState state) {
    return const _LabelScreen('DASHBOARD');
  }

  @override
  Widget buildBeans(BuildContext context, GoRouterState state) {
    return const _BeansRootScreen();
  }

  @override
  Widget buildBeanForm(
    BuildContext context,
    GoRouterState state, {
    String? beanId,
  }) {
    return const _LabelScreen('BEAN_NEW');
  }

  @override
  Widget buildBeanDetail(
    BuildContext context,
    GoRouterState state, {
    required String beanId,
  }) {
    return const _LabelScreen('BEAN_DETAIL');
  }

  @override
  Widget buildLogs(BuildContext context, GoRouterState state) {
    return const _LabelScreen('LOGS_ROOT');
  }

  @override
  Widget buildLogForm(
    BuildContext context,
    GoRouterState state, {
    String? logId,
  }) {
    return const _LabelScreen('LOG_NEW');
  }

  @override
  Widget buildLogDetail(
    BuildContext context,
    GoRouterState state, {
    required String logId,
  }) {
    return const _LabelScreen('LOG_DETAIL');
  }

  @override
  Widget buildCommunity(BuildContext context, GoRouterState state) {
    return const _LabelScreen('COMMUNITY_ROOT');
  }

  @override
  Widget buildPostForm(
    BuildContext context,
    GoRouterState state, {
    String? postId,
  }) {
    return const _LabelScreen('POST_NEW');
  }

  @override
  Widget buildPostDetail(
    BuildContext context,
    GoRouterState state, {
    required String postId,
  }) {
    return const _LabelScreen('POST_DETAIL');
  }

  @override
  Widget buildProfile(BuildContext context, GoRouterState state) {
    return const _LabelScreen('PROFILE_ROOT');
  }
}

class _LoginTestScreen extends StatelessWidget {
  const _LoginTestScreen({required this.authController});

  final _TestAuthController authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('LOGIN'),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('guest-login-button'),
              onPressed: () {
                authController.update(AppAuthSnapshot.guest);
                context.push(AppRoutePath.dashboard);
              },
              child: const Text('Guest Login'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('auth-login-button'),
              onPressed: () {
                authController.update(AppAuthSnapshot.authenticated);
                context.go(AppRoutePath.dashboard);
              },
              child: const Text('Auth Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeansRootScreen extends StatelessWidget {
  const _BeansRootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('BEANS_ROOT'),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('open-bean-new-button'),
              onPressed: () => context.push('/beans/new'),
              child: const Text('Open Bean New'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelScreen extends StatelessWidget {
  const _LabelScreen(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}
