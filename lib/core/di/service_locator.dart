import 'package:get_it/get_it.dart';

import '../../config/supabase_config.dart';
import '../../services/auth_service.dart';
import '../../services/coffee_bean_service.dart';
import '../../services/coffee_log_service.dart';
import '../../services/community_service.dart';
import '../../services/image_upload_service.dart';

final getIt = GetIt.instance;

/// Service Locator 초기화
///
/// **호출 순서 규칙**: 반드시 `SupabaseConfig.initialize()` 완료 후 호출할 것.
///
/// **테스트 격리 규칙**:
/// ```dart
/// setUp(() {
///   GetIt.I.reset();
///   // mock 서비스 등록
/// });
/// ```
void setupServiceLocator() {
  // Hot restart 시 재등록 허용
  getIt.allowReassignment = true;

  final client = SupabaseConfig.client;

  // Auth
  getIt.registerLazySingleton<AuthService>(() => AuthService(client));

  // Coffee Bean
  getIt.registerLazySingleton<CoffeeBeanService>(
    () => CoffeeBeanService(client),
  );

  // Coffee Log
  getIt.registerLazySingleton<CoffeeLogService>(() => CoffeeLogService(client));

  // Community
  getIt.registerLazySingleton<CommunityService>(() => CommunityService(client));

  // Image Upload
  getIt.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(client),
  );
}
