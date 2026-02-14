import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
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

  try {
    // Supabase 초기화 (환경변수에서 설정 로드)
    await SupabaseConfig.initialize();
    // GetIt 서비스 등록 (Supabase 초기화 후)
    setupServiceLocator();
  } catch (e) {
    debugPrint('초기화 실패: $e');
  } finally {
    // 초기화 성공/실패와 관계없이 스플래시 제거
    FlutterNativeSplash.remove();
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => BeanListCubit()),
        BlocProvider(create: (_) => LogListCubit()),
        BlocProvider(create: (_) => PostListCubit()),
        BlocProvider(create: (_) => DashboardCubit()),
      ],
      child: const CoffeeNoteApp(),
    ),
  );
}
