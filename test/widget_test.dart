import 'package:coffee_note_app/cubits/auth/auth_cubit.dart';
import 'package:coffee_note_app/cubits/auth/auth_state.dart';
import 'package:coffee_note_app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('App router renders without crashing', (
    WidgetTester tester,
  ) async {
    final authState = ValueNotifier<AppAuthSnapshot>(AppAuthSnapshot.guest);
    final router = createAppRouter(
      authSnapshot: () => authState.value,
      refreshListenable: authState,
      routeBuilders: const _SmokeRouteBuilders(),
    );

    await tester.pumpWidget(
      BlocProvider<AuthCubit>(
        create: (_) => AuthCubit.test(const AuthState.guest()),
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('SMOKE_DASHBOARD'), findsOneWidget);
  });
}

class _SmokeRouteBuilders extends AppRouteBuilders {
  const _SmokeRouteBuilders();

  @override
  Widget buildSplash(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_SPLASH')));
  }

  @override
  Widget buildDashboard(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_DASHBOARD')));
  }

  @override
  Widget buildBeans(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_BEANS')));
  }

  @override
  Widget buildLogs(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_LOGS')));
  }

  @override
  Widget buildCommunity(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_COMMUNITY')));
  }

  @override
  Widget buildProfile(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_PROFILE')));
  }

  @override
  Widget buildLogin(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('SMOKE_LOGIN')));
  }
}
