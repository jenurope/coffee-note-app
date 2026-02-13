import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Supabase 초기화 (환경변수에서 설정 로드)
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Supabase 초기화 실패: $e');
  } finally {
    // 초기화 성공/실패와 관계없이 스플래시 제거
    FlutterNativeSplash.remove();
  }

  runApp(const ProviderScope(child: CoffeeNoteApp()));
}
