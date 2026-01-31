import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/image_upload_service.dart';

final imageUploadServiceProvider =
    Provider<ImageUploadService>((ref) => ImageUploadService());
