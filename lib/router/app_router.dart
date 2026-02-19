import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../cubits/bean/bean_detail_cubit.dart';
import '../cubits/community/post_detail_cubit.dart';
import '../cubits/log/log_detail_cubit.dart';

import '../screens/auth/login_screen.dart';
import '../screens/beans/bean_detail_screen.dart';
import '../screens/beans/bean_form_screen.dart';
import '../screens/beans/bean_list_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/community/post_detail_screen.dart';
import '../screens/community/post_form_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/logs/coffee_log_detail_screen.dart';
import '../screens/logs/coffee_log_form_screen.dart';
import '../screens/logs/coffee_log_list_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/navigation/guest_tab_root_back_guard.dart';

abstract final class AppRoutePath {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const dashboard = '/';
  static const beans = '/beans';
  static const logs = '/logs';
  static const community = '/community';
  static const profile = '/profile';
}

enum AppAuthStatus { resolving, unauthenticated, guest, authenticated }

class AppAuthSnapshot {
  final AppAuthStatus status;

  const AppAuthSnapshot(this.status);

  static const resolving = AppAuthSnapshot(AppAuthStatus.resolving);
  static const unauthenticated = AppAuthSnapshot(AppAuthStatus.unauthenticated);
  static const guest = AppAuthSnapshot(AppAuthStatus.guest);
  static const authenticated = AppAuthSnapshot(AppAuthStatus.authenticated);

  bool get isResolving => status == AppAuthStatus.resolving;
  bool get isUnauthenticated => status == AppAuthStatus.unauthenticated;
  bool get isGuest => status == AppAuthStatus.guest;
  bool get isAuthenticated => status == AppAuthStatus.authenticated;
}

class AppRouteBuilders {
  const AppRouteBuilders();

  Widget buildSplash(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }

  Widget buildLogin(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }

  Widget buildDashboard(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }

  Widget buildBeans(BuildContext context, GoRouterState state) {
    return const BeanListScreen();
  }

  Widget buildBeanDetail(
    BuildContext context,
    GoRouterState state, {
    required String beanId,
  }) {
    final authCubit = context.read<AuthCubit>();
    return BlocProvider(
      create: (_) => BeanDetailCubit(authCubit: authCubit)..load(beanId),
      child: BeanDetailScreen(beanId: beanId),
    );
  }

  Widget buildBeanForm(
    BuildContext context,
    GoRouterState state, {
    String? beanId,
  }) {
    return BeanFormScreen(beanId: beanId);
  }

  Widget buildLogs(BuildContext context, GoRouterState state) {
    return const CoffeeLogListScreen();
  }

  Widget buildLogDetail(
    BuildContext context,
    GoRouterState state, {
    required String logId,
  }) {
    final authCubit = context.read<AuthCubit>();
    return BlocProvider(
      create: (_) => LogDetailCubit(authCubit: authCubit)..load(logId),
      child: CoffeeLogDetailScreen(logId: logId),
    );
  }

  Widget buildLogForm(
    BuildContext context,
    GoRouterState state, {
    String? logId,
  }) {
    return CoffeeLogFormScreen(logId: logId);
  }

  Widget buildCommunity(BuildContext context, GoRouterState state) {
    return const CommunityScreen();
  }

  Widget buildPostDetail(
    BuildContext context,
    GoRouterState state, {
    required String postId,
  }) {
    final authCubit = context.read<AuthCubit>();
    return BlocProvider(
      create: (_) => PostDetailCubit(authCubit: authCubit)..load(postId),
      child: PostDetailScreen(postId: postId),
    );
  }

  Widget buildPostForm(
    BuildContext context,
    GoRouterState state, {
    String? postId,
  }) {
    return PostFormScreen(postId: postId);
  }

  Widget buildProfile(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

@visibleForTesting
String? resolveAppRedirect({
  required AppAuthSnapshot authSnapshot,
  required String location,
}) {
  final isAuthRoute = location.startsWith('/auth');

  if (authSnapshot.isResolving) {
    return location == AppRoutePath.splash ? null : AppRoutePath.splash;
  }

  if (location == AppRoutePath.splash) {
    if (authSnapshot.isAuthenticated || authSnapshot.isGuest) {
      return AppRoutePath.dashboard;
    }
    return AppRoutePath.login;
  }

  if (authSnapshot.isUnauthenticated && !isAuthRoute) {
    return AppRoutePath.login;
  }

  if (authSnapshot.isAuthenticated && isAuthRoute) {
    return AppRoutePath.dashboard;
  }

  return null;
}

@visibleForTesting
GoRouter createAppRouter({
  required AppAuthSnapshot Function() authSnapshot,
  required Listenable refreshListenable,
  AppRouteBuilders routeBuilders = const AppRouteBuilders(),
  List<GlobalKey<NavigatorState>>? branchNavigatorKeys,
  GlobalKey<NavigatorState>? rootNavigatorKey,
  String initialLocation = AppRoutePath.splash,
}) {
  final branchKeys =
      branchNavigatorKeys ??
      List.generate(
        5,
        (index) => GlobalKey<NavigatorState>(debugLabel: 'branch-$index'),
      );

  if (branchKeys.length != 5) {
    throw ArgumentError.value(
      branchKeys.length,
      'branchNavigatorKeys.length',
      'Expected exactly 5 branch navigator keys',
    );
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: (context, state) => resolveAppRedirect(
      authSnapshot: authSnapshot(),
      location: state.uri.path,
    ),
    routes: [
      GoRoute(
        path: AppRoutePath.splash,
        name: 'splash',
        builder: (context, state) => routeBuilders.buildSplash(context, state),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainScreen(
          navigationShell: navigationShell,
          branchNavigatorKeys: branchKeys,
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: branchKeys[0],
            routes: [
              GoRoute(
                path: AppRoutePath.dashboard,
                name: 'dashboard',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: GuestTabRootBackGuard(
                    child: routeBuilders.buildDashboard(context, state),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[1],
            routes: [
              GoRoute(
                path: AppRoutePath.beans,
                name: 'beans',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: GuestTabRootBackGuard(
                    child: routeBuilders.buildBeans(context, state),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'bean-new',
                    builder: (context, state) =>
                        routeBuilders.buildBeanForm(context, state),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'bean-detail',
                    builder: (context, state) => routeBuilders.buildBeanDetail(
                      context,
                      state,
                      beanId: _requiredPathParameter(state, 'id'),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'bean-edit',
                        builder: (context, state) =>
                            routeBuilders.buildBeanForm(
                              context,
                              state,
                              beanId: _requiredPathParameter(state, 'id'),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[2],
            routes: [
              GoRoute(
                path: AppRoutePath.logs,
                name: 'logs',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: GuestTabRootBackGuard(
                    child: routeBuilders.buildLogs(context, state),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'log-new',
                    builder: (context, state) =>
                        routeBuilders.buildLogForm(context, state),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'log-detail',
                    builder: (context, state) => routeBuilders.buildLogDetail(
                      context,
                      state,
                      logId: _requiredPathParameter(state, 'id'),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'log-edit',
                        builder: (context, state) => routeBuilders.buildLogForm(
                          context,
                          state,
                          logId: _requiredPathParameter(state, 'id'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[3],
            routes: [
              GoRoute(
                path: AppRoutePath.community,
                name: 'community',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: GuestTabRootBackGuard(
                    child: routeBuilders.buildCommunity(context, state),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'post-new',
                    builder: (context, state) =>
                        routeBuilders.buildPostForm(context, state),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'post-detail',
                    builder: (context, state) => routeBuilders.buildPostDetail(
                      context,
                      state,
                      postId: _requiredPathParameter(state, 'id'),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'post-edit',
                        builder: (context, state) =>
                            routeBuilders.buildPostForm(
                              context,
                              state,
                              postId: _requiredPathParameter(state, 'id'),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKeys[4],
            routes: [
              GoRoute(
                path: AppRoutePath.profile,
                name: 'profile',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: GuestTabRootBackGuard(
                    child: routeBuilders.buildProfile(context, state),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePath.login,
        name: 'login',
        builder: (context, state) => routeBuilders.buildLogin(context, state),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              context.l10n.pageNotFound,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutePath.dashboard),
              child: Text(context.l10n.backToHome),
            ),
          ],
        ),
      ),
    ),
  );
}

String _requiredPathParameter(GoRouterState state, String key) {
  final value = state.pathParameters[key];
  if (value == null || value.isEmpty) {
    throw StateError('Missing required path parameter: $key');
  }
  return value;
}

/// AuthCubit 기반 라우터 생성 함수.
/// AuthCubit의 상태 변화를 listen하여 GoRouter를 자동 refresh.
GoRouter createRouterFromCubit(AuthCubit authCubit) {
  final refreshNotifier = _AuthCubitRefreshNotifier(authCubit);

  AppAuthSnapshot readAuthSnapshot() {
    final state = authCubit.state;

    if (state is AuthInitial) {
      return AppAuthSnapshot.resolving;
    }

    if (state is AuthAuthenticated) {
      return AppAuthSnapshot.authenticated;
    }

    if (state is AuthGuest) {
      return AppAuthSnapshot.guest;
    }

    return AppAuthSnapshot.unauthenticated;
  }

  return createAppRouter(
    authSnapshot: readAuthSnapshot,
    refreshListenable: refreshNotifier,
  );
}

/// AuthCubit의 상태 변화를 ChangeNotifier(Listenable)로 변환.
class _AuthCubitRefreshNotifier extends ChangeNotifier {
  _AuthCubitRefreshNotifier(AuthCubit cubit) {
    _subscription = cubit.stream.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
