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
  String _currentPath = '/';
  int _currentIndex = 0;
  final List<int> _tabHistory = [0];
  GoRouter? _router;

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

  final _routes = ['/', '/beans', '/logs', '/community', '/profile'];

  String _normalizePath(String location) {
    if (location.length > 1 && location.endsWith('/')) {
      return location.substring(0, location.length - 1);
    }
    return location;
  }

  void _syncFromRouter({bool resetHistory = false}) {
    final router = _router;
    if (router == null) return;

    final path = _normalizePath(router.routeInformationProvider.value.uri.path);
    final index = _locationToIndex(path);
    final locationChanged = path != _currentPath || index != _currentIndex;

    if (locationChanged) {
      setState(() {
        _currentPath = path;
        _currentIndex = index;
      });
    } else {
      _currentPath = path;
      _currentIndex = index;
    }

    if (_isRootTabLocation(path)) {
      if (resetHistory) {
        _tabHistory
          ..clear()
          ..add(index);
      } else {
        _recordTabVisit(index);
      }
    } else if (resetHistory) {
      _tabHistory
        ..clear()
        ..add(index);
    }
  }

  void _onRouteInfoChanged() {
    _syncFromRouter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final router = GoRouter.of(context);
    if (!identical(_router, router)) {
      _router?.routeInformationProvider.removeListener(_onRouteInfoChanged);
      _router = router;
      _router?.routeInformationProvider.addListener(_onRouteInfoChanged);
      _syncFromRouter(resetHistory: true);
    }
  }

  @override
  void dispose() {
    _router?.routeInformationProvider.removeListener(_onRouteInfoChanged);
    super.dispose();
  }

  int _locationToIndex(String location) {
    final normalized = _normalizePath(location);
    if (normalized.startsWith('/beans')) {
      return 1;
    }
    if (normalized.startsWith('/logs')) {
      return 2;
    }
    if (normalized.startsWith('/community')) {
      return 3;
    }
    if (normalized.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  bool _isRootTabLocation(String location) =>
      _routes.contains(_normalizePath(location));

  void _recordTabVisit(int index) {
    if (_tabHistory.isNotEmpty && _tabHistory.last == index) {
      return;
    }
    _tabHistory.remove(index);
    _tabHistory.add(index);
  }

  void _goToPreviousTabFromHistory() {
    final previousIndex = _tabHistory[_tabHistory.length - 2];
    _tabHistory.removeLast();

    setState(() {
      _currentIndex = previousIndex;
      _currentPath = _routes[previousIndex];
    });
    Future.microtask(() {
      if (!mounted) return;
      context.go(_routes[previousIndex]);
    });
  }

  Future<bool> _handleBackAction() async {
    if (!_isRootTabLocation(_currentPath)) {
      return false;
    }

    if (_tabHistory.length > 1) {
      _goToPreviousTabFromHistory();
      return true;
    }

    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _currentPath = '/';
      });
      _tabHistory
        ..clear()
        ..add(0);
      Future.microtask(() {
        if (!mounted) return;
        context.go('/');
      });
      return true;
    }

    final isGuest = ref.read(isGuestModeProvider);
    final currentUser = ref.read(currentUserProvider);
    if (isGuest && currentUser == null) {
      Future.microtask(() {
        if (!mounted) return;
        context.go('/auth/login');
      });
      return true;
    }

    return false;
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    _recordTabVisit(index);
    setState(() {
      _currentIndex = index;
      _currentPath = _routes[index];
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestModeProvider);
    final currentUser = ref.watch(currentUserProvider);

    final Widget bodyContent = _currentPath == '/'
        ? const DashboardScreen()
        : widget.child;
    final shouldInterceptBack =
        _isRootTabLocation(_currentPath) &&
        (_tabHistory.length > 1 ||
            _currentIndex != 0 ||
            (isGuest && currentUser == null));

    return BackButtonListener(
      onBackButtonPressed: _handleBackAction,
      child: PopScope(
        canPop: !shouldInterceptBack,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleBackAction();
        },
        child: Scaffold(
          body: bodyContent,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 게스트 모드 안내 배너
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
                          ref
                              .read(authNotifierProvider.notifier)
                              .exitGuestMode();
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
        ),
      ),
    );
  }
}
