import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/l10n.dart';

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

  List<BottomNavigationBarItem> _navItems(BuildContext context) {
    final l10n = context.l10n;
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard),
        activeIcon: const Icon(Icons.dashboard),
        label: l10n.dashboard,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.coffee),
        activeIcon: const Icon(Icons.coffee),
        label: l10n.beanRecords,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.local_cafe),
        activeIcon: const Icon(Icons.local_cafe),
        label: l10n.coffeeRecords,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.forum),
        activeIcon: const Icon(Icons.forum),
        label: l10n.community,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        activeIcon: const Icon(Icons.person),
        label: l10n.profile,
      ),
    ];
  }

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
                            context.l10n.guestBanner,
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
                          child: Text(context.l10n.login),
                        ),
                      ],
                    ),
                  ),
                BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onItemTapped,
                  items: _navItems(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
