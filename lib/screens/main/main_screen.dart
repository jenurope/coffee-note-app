import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    super.key,
    required this.navigationShell,
    required this.branchNavigatorKeys,
    this.loginPath = '/auth/login',
  });

  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> branchNavigatorKeys;
  final String loginPath;

  static const _navItems = [
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

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  StatefulNavigationShell get _navigationShell => widget.navigationShell;

  int get _currentIndex => _navigationShell.currentIndex;

  NavigatorState? get _currentBranchNavigator =>
      widget.branchNavigatorKeys[_currentIndex].currentState;

  void _onItemTapped(int index) {
    if (index == _currentIndex) {
      _navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    _navigationShell.goBranch(index);
  }

  Future<bool> _onBackPressed(BuildContext context, bool isGuest) async {
    final branchNavigator = _currentBranchNavigator;
    if (branchNavigator?.canPop() ?? false) {
      branchNavigator!.pop();
      return true;
    }

    if (isGuest) {
      context.go(widget.loginPath);
      return true;
    }

    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestModeProvider);

    return BackButtonListener(
      onBackButtonPressed: () => _onBackPressed(context, isGuest),
      child: Scaffold(
        body: _navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isGuest)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
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
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              items: MainScreen._navItems,
            ),
          ],
        ),
      ),
    );
  }
}
