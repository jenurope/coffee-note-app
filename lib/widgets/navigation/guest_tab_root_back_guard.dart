import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class GuestTabRootBackGuard extends ConsumerWidget {
  const GuestTabRootBackGuard({
    super.key,
    required this.child,
    this.loginPath = '/auth/login',
  });

  final Widget child;
  final String loginPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestModeProvider);

    if (!isGuest) {
      return child;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        context.go(loginPath);
      },
      child: child,
    );
  }
}
