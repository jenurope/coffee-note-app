import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'cubits/auth/auth_cubit.dart';
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
    return MaterialApp.router(
      title: '커피로그',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
