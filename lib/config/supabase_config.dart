import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_environment.dart';

class SupabaseConfig {
  // 실행 시:
  // --dart-define=APP_ENV=dev|prod
  // --dart-define=SUPABASE_URL=...
  // --dart-define=SUPABASE_PUBLISHABLE_KEY=...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static Future<void> initialize() async {
    final environment = AppEnvironment.currentValue;

    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw Exception(
        'Supabase 설정이 누락되었습니다. '
        '(APP_ENV=$environment) '
        '--dart-define=APP_ENV=dev|prod '
        '--dart-define=SUPABASE_URL=... '
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=... '
        '옵션을 사용하여 실행해주세요.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabasePublishableKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}
