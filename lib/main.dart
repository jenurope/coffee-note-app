import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/errors/user_error_message.dart';
import 'config/supabase_config.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/bean/bean_list_cubit.dart';
import 'cubits/community/post_list_cubit.dart';
import 'cubits/dashboard/dashboard_cubit.dart';
import 'cubits/log/log_list_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // BLoC 옵저버 (개발 시 디버그 로그)
  Bloc.observer = const AppBlocObserver();
  String? initializationError;

  try {
    // Supabase 초기화 (환경변수에서 설정 로드)
    await SupabaseConfig.initialize();
    // GetIt 서비스 등록 (Supabase 초기화 후)
    setupServiceLocator();
  } catch (e, st) {
    initializationError = UserErrorMessage.from(
      e,
      fallback: '앱을 시작할 수 없습니다. 잠시 후 다시 시도해주세요.',
    );
    debugPrint('초기화 실패: $e');
    debugPrint(st.toString());
  } finally {
    // 초기화 성공/실패와 관계없이 스플래시 제거
    FlutterNativeSplash.remove();
  }

  final errorMessage = initializationError;
  if (errorMessage != null) {
    runApp(_InitializationErrorApp(message: errorMessage));
    return;
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(
          create: (context) =>
              BeanListCubit(authCubit: context.read<AuthCubit>()),
        ),
        BlocProvider(
          create: (context) =>
              LogListCubit(authCubit: context.read<AuthCubit>()),
        ),
        BlocProvider(
          create: (context) =>
              PostListCubit(authCubit: context.read<AuthCubit>()),
        ),
        BlocProvider(
          create: (context) =>
              DashboardCubit(authCubit: context.read<AuthCubit>()),
        ),
      ],
      child: const CoffeeNoteApp(),
    ),
  );
}

class _InitializationErrorApp extends StatelessWidget {
  const _InitializationErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '커피로그',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('ko'), Locale('en')],
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    '앱 초기화에 실패했습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      await SystemNavigator.pop();
                    },
                    child: const Text('앱 종료'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
