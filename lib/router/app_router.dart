import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/beans/bean_list_screen.dart';
import '../screens/beans/bean_detail_screen.dart';
import '../screens/beans/bean_form_screen.dart';
import '../screens/logs/coffee_log_list_screen.dart';
import '../screens/logs/coffee_log_detail_screen.dart';
import '../screens/logs/coffee_log_form_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/community/post_detail_screen.dart';
import '../screens/community/post_form_screen.dart';
import '../screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen(currentUserProvider, (previous, next) {
    refreshNotifier.value++;
  });
  ref.listen(isGuestModeProvider, (previous, next) {
    refreshNotifier.value++;
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final currentUser = ref.read(currentUserProvider);
      final isGuest = ref.read(isGuestModeProvider);
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (currentUser == null && !isGuest && !isAuthRoute) {
        return '/auth/login';
      }

      if (currentUser != null && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // 메인 화면 (Bottom Navigation 포함)
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardContent()),
          ),
          GoRoute(
            path: '/beans',
            name: 'beans',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BeanListScreen()),
            routes: [
              GoRoute(
                path: 'new',
                name: 'bean-new',
                builder: (context, state) => const BeanFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'bean-detail',
                builder: (context, state) =>
                    BeanDetailScreen(beanId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'bean-edit',
                    builder: (context, state) =>
                        BeanFormScreen(beanId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/logs',
            name: 'logs',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CoffeeLogListScreen()),
            routes: [
              GoRoute(
                path: 'new',
                name: 'log-new',
                builder: (context, state) => const CoffeeLogFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'log-detail',
                builder: (context, state) =>
                    CoffeeLogDetailScreen(logId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'log-edit',
                    builder: (context, state) =>
                        CoffeeLogFormScreen(logId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CommunityScreen()),
            routes: [
              GoRoute(
                path: 'new',
                name: 'post-new',
                builder: (context, state) => const PostFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'post-detail',
                builder: (context, state) =>
                    PostDetailScreen(postId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'post-edit',
                    builder: (context, state) =>
                        PostFormScreen(postId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // 인증 관련 라우트
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});

// 대시보드 placeholder (MainScreen에서 실제 DashboardScreen 렌더링)
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
