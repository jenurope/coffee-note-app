import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/auth/auth_state.dart';
import 'cubits/bean/bean_list_cubit.dart';
import 'cubits/community/post_list_cubit.dart';
import 'cubits/dashboard/dashboard_cubit.dart';
import 'cubits/log/log_list_cubit.dart';
import 'router/app_router.dart';

class CoffeeNoteApp extends StatefulWidget {
  const CoffeeNoteApp({super.key});

  @override
  State<CoffeeNoteApp> createState() => _CoffeeNoteAppState();
}

class _CoffeeNoteAppState extends State<CoffeeNoteApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();
    _router = createRouterFromCubit(authCubit);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        final typeChanged = previous.runtimeType != current.runtimeType;
        if (typeChanged) return true;
        if (previous is AuthAuthenticated && current is AuthAuthenticated) {
          return previous.user.id != current.user.id;
        }
        return false;
      },
      listener: (context, authState) {
        context.read<BeanListCubit>().onAuthStateChanged(authState);
        context.read<LogListCubit>().onAuthStateChanged(authState);
        context.read<PostListCubit>().onAuthStateChanged(authState);
        context.read<DashboardCubit>().onAuthStateChanged(authState);
      },
      child: MaterialApp.router(
        title: '커피로그',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('ko'), Locale('en')],
        routerConfig: _router,
      ),
    );
  }
}
