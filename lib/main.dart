import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/supabase_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase 초기화 (환경변수에서 설정 로드)
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: CoffeeNoteApp(),
    ),
  );
}
