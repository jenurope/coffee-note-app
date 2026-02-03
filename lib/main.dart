import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Supabase 초기화 (환경변수에서 설정 로드)
  await SupabaseConfig.initialize();

  // 초기화 완료 후 스플래시 제거
  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: CoffeeNoteApp()));
}
