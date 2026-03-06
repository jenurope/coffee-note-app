import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../core/locale/community_visibility_policy.dart';
import '../../l10n/l10n.dart';
import '../../router/app_feature_visibility.dart';

Locale? _defaultDeviceLocaleProvider() => PlatformDispatcher.instance.locale;

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.navigationShell,
    required this.branchNavigatorKeys,
    this.featureVisibility = const AppFeatureVisibility(),
    this.loginPath = '/auth/login',
    this.deviceLocaleProvider = _defaultDeviceLocaleProvider,
  });

  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> branchNavigatorKeys;
  final AppFeatureVisibility featureVisibility;
  final String loginPath;
  final DeviceLocaleProvider deviceLocaleProvider;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const int _dashboardBranchIndex = 0;
  static const int _beanBranchIndex = 1;
  static const int _logBranchIndex = 2;
  static const int _communityBranchIndex = 3;
  static const int _profileBranchIndex = 4;

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

  NavigatorState? get _currentBranchNavigator {
    if (_currentIndex < 0 ||
        _currentIndex >= widget.branchNavigatorKeys.length) {
      return null;
    }
    return widget.branchNavigatorKeys[_currentIndex].currentState;
  }

  bool _isCommunityVisible(BuildContext context) {
    return isCommunityVisible(
      appLocale: Localizations.maybeLocaleOf(context),
      deviceLocale: widget.deviceLocaleProvider(),
    );
  }

  AppFeatureVisibility _effectiveFeatureVisibility(BuildContext context) {
    final dashboardState = context.select<DashboardCubit?, DashboardState?>(
      (cubit) => cubit?.state,
    );

    if (dashboardState is! DashboardLoaded) {
      return widget.featureVisibility;
    }

    final userProfile = dashboardState.userProfile;
    return AppFeatureVisibility(
      beanRecordsVisible: userProfile?.isBeanRecordsEnabled ?? true,
      coffeeRecordsVisible: userProfile?.isCoffeeRecordsEnabled ?? true,
    );
  }

  List<int> _visibleBranchIndices({
    required bool communityVisible,
    required AppFeatureVisibility featureVisibility,
  }) {
    final indices = <int>[_dashboardBranchIndex];
    if (featureVisibility.beanRecordsVisible) {
      indices.add(_beanBranchIndex);
    }
    if (featureVisibility.coffeeRecordsVisible) {
      indices.add(_logBranchIndex);
    }
    if (communityVisible) {
      indices.add(_communityBranchIndex);
    }
    indices.add(_profileBranchIndex);
    return indices;
  }

  int _toDisplayIndex(List<int> visibleBranchIndices, int branchIndex) {
    final displayIndex = visibleBranchIndices.indexOf(branchIndex);
    return displayIndex == -1 ? 0 : displayIndex;
  }

  int _toBranchIndex(List<int> visibleBranchIndices, int displayIndex) {
    if (displayIndex < 0 || displayIndex >= visibleBranchIndices.length) {
      return _dashboardBranchIndex;
    }
    return visibleBranchIndices[displayIndex];
  }

  void _syncHiddenBranch(List<int> visibleBranchIndices) {
    if (visibleBranchIndices.contains(_currentIndex)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _activeIndex = _dashboardBranchIndex;
      });
      _navigationShell.goBranch(_dashboardBranchIndex);
    });
  }

  List<BottomNavigationBarItem> _navItems(
    BuildContext context, {
    required bool communityVisible,
    required AppFeatureVisibility featureVisibility,
  }) {
    final l10n = context.l10n;
    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard),
        activeIcon: const Icon(Icons.dashboard),
        label: l10n.dashboard,
      ),
    ];

    if (featureVisibility.beanRecordsVisible) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.coffee),
          activeIcon: const Icon(Icons.coffee),
          label: l10n.beanRecords,
        ),
      );
    }

    if (featureVisibility.coffeeRecordsVisible) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_cafe),
          activeIcon: const Icon(Icons.local_cafe),
          label: l10n.coffeeRecords,
        ),
      );
    }

    if (communityVisible) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.forum),
          activeIcon: const Icon(Icons.forum),
          label: l10n.community,
        ),
      );
    }

    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        activeIcon: const Icon(Icons.person),
        label: l10n.profile,
      ),
    );

    return items;
  }

  void _onItemTapped(int displayIndex, List<int> visibleBranchIndices) {
    // Prevent hidden form fields from keeping focus and consuming the first back gesture.
    FocusManager.instance.primaryFocus?.unfocus();
    final branchIndex = _toBranchIndex(visibleBranchIndices, displayIndex);

    if (branchIndex == _currentIndex) {
      _navigationShell.goBranch(branchIndex, initialLocation: true);
      return;
    }

    setState(() {
      _activeIndex = branchIndex;
    });
    _navigationShell.goBranch(branchIndex);
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
        final communityVisible = _isCommunityVisible(context);
        final featureVisibility = _effectiveFeatureVisibility(context);
        final visibleBranchIndices = _visibleBranchIndices(
          communityVisible: communityVisible,
          featureVisibility: featureVisibility,
        );
        _syncHiddenBranch(visibleBranchIndices);
        final currentDisplayIndex = _toDisplayIndex(
          visibleBranchIndices,
          _currentIndex,
        );

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
                  currentIndex: currentDisplayIndex,
                  onTap: (index) => _onItemTapped(index, visibleBranchIndices),
                  items: _navItems(
                    context,
                    communityVisible: communityVisible,
                    featureVisibility: featureVisibility,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
