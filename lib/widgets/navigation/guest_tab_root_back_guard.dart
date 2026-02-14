import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class GuestTabRootBackGuard extends StatelessWidget {
  const GuestTabRootBackGuard({
    super.key,
    required this.child,
    this.loginPath = '/auth/login',
  });

  final Widget child;
  final String loginPath;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isGuest = state is AuthGuest;

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
      },
    );
  }
}
