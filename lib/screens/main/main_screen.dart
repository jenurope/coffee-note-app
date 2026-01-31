import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: '대시보드',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.coffee_outlined),
      activeIcon: Icon(Icons.coffee),
      label: '원두 기록',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_cafe_outlined),
      activeIcon: Icon(Icons.local_cafe),
      label: '커피 기록',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.forum_outlined),
      activeIcon: Icon(Icons.forum),
      label: '커뮤니티',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: '프로필',
    ),
  ];

  final _routes = ['/', '/beans', '/logs', '/community', '/profile'];

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      context.go(_routes[index]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 현재 경로에 따라 인덱스 업데이트
    final location = GoRouterState.of(context).matchedLocation;
    int newIndex = 0;
    if (location.startsWith('/beans')) {
      newIndex = 1;
    } else if (location.startsWith('/logs')) {
      newIndex = 2;
    } else if (location.startsWith('/community')) {
      newIndex = 3;
    } else if (location.startsWith('/profile')) {
      newIndex = 4;
    }
    if (_currentIndex != newIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestModeProvider);

    // 대시보드 경로인 경우 DashboardScreen을 직접 렌더링
    final location = GoRouterState.of(context).matchedLocation;
    final Widget bodyContent =
        location == '/' ? const DashboardScreen() : widget.child;

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 게스트 모드 안내 배너
          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
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
            items: _navItems,
          ),
        ],
      ),
    );
  }
}
