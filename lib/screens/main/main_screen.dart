import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  final _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      activeIcon: Icon(Icons.dashboard),
      label: '대시보드',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.coffee),
      activeIcon: Icon(Icons.coffee),
      label: '원두 기록',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_cafe),
      activeIcon: Icon(Icons.local_cafe),
      label: '커피 기록',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.forum),
      activeIcon: Icon(Icons.forum),
      label: '커뮤니티',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      activeIcon: Icon(Icons.person),
      label: '프로필',
    ),
  ];

  void _onItemTapped(int index) {
    if (index == navigationShell.currentIndex) {
      navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestModeProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '게스트 모드입니다. 로그인하면 모든 기능을 사용할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).exitGuestMode();
                      context.go('/auth/login');
                    },
                    child: const Text('로그인'),
                  ),
                ],
              ),
            ),
          BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onItemTapped,
            items: _navItems,
          ),
        ],
      ),
    );
  }
}
