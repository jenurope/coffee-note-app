import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // 환경변수를 통해 주입받는 Supabase 설정
  // 실행 시: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase 설정이 누락되었습니다. '
        '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... '
        '옵션을 사용하여 실행해주세요.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}
