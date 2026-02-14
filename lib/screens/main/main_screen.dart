import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class MainScreen extends StatefulWidget {
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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.navigationShell.currentIndex;
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = widget.navigationShell.currentIndex;
    if (_activeIndex != nextIndex) {
      _activeIndex = nextIndex;
    }
  }

  StatefulNavigationShell get _navigationShell => widget.navigationShell;

  int get _currentIndex => _activeIndex;

  NavigatorState? get _currentBranchNavigator =>
      widget.branchNavigatorKeys[_currentIndex].currentState;

  void _onItemTapped(int index) {
    // Prevent hidden form fields from keeping focus and consuming the first back gesture.
    FocusManager.instance.primaryFocus?.unfocus();

    if (index == _currentIndex) {
      _navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    setState(() {
      _activeIndex = index;
    });
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is AuthGuest;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            _onBackPressed(context, isGuest);
          },
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
                            context.read<AuthCubit>().exitGuestMode();
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
      },
    );
  }
}
