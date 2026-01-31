import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_upload_service.dart';

import '../config/supabase_config.dart';

final imageUploadServiceProvider =
    Provider<ImageUploadService>((ref) => ImageUploadService(SupabaseConfig.client));
