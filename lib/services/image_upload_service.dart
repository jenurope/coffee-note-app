import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ImageUploadService {
  final SupabaseClient _client;
  final _imagePicker = ImagePicker();

  ImageUploadService(this._client);

  /// 갤러리에서 이미지 선택
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Pick image from gallery error: $e');
      return null;
    }
  }

  /// 카메라로 이미지 촬영
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('Pick image from camera error: $e');
      return null;
    }
  }

  /// Supabase Storage에 이미지 업로드
  /// [bucket] - 스토리지 버킷 이름 ('beans', 'logs', 'avatars')
  /// [userId] - 사용자 ID (폴더 구분용)
  /// [file] - 업로드할 파일
  Future<String?> uploadImage({
    required String bucket,
    required String userId,
    required XFile file,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '$userId/$timestamp.$extension';

      final bytes = await file.readAsBytes();
      
      await _client.storage.from(bucket).uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          contentType: 'image/$extension',
          upsert: true,
        ),
      );

      // 공개 URL 반환
      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload image error: $e');
      return null;
    }
  }

  /// 이미지 삭제
  Future<bool> deleteImage({
    required String bucket,
    required String imageUrl,
  }) async {
    try {
      // URL에서 파일 경로 추출
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // storage/v1/object/public/bucket/path 형식에서 path 추출
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex == -1) return false;
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      
      await _client.storage.from(bucket).remove([filePath]);
      return true;
    } catch (e) {
      debugPrint('Delete image error: $e');
      return false;
    }
  }

  /// 이미지 선택 다이얼로그 (갤러리/카메라 선택)
  Future<XFile?> showImageSourceDialog(
    Future<XFile?> Function() onGallery,
    Future<XFile?> Function() onCamera,
  ) async {
    // 이 메서드는 UI에서 호출 시 다이얼로그를 표시하고
    // 선택에 따라 적절한 메서드를 호출합니다
    // 실제 다이얼로그는 UI 위젯에서 구현
    return null;
  }
}
