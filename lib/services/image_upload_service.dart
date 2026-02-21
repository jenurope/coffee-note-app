import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const int _photoUploadMaxBytes = 1024 * 1024;
const Set<String> _unsupportedResizeExtensions = {'heic', 'heif'};

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => 'ImageUploadException: $message';
}

@visibleForTesting
Uint8List resizePhotoToMaxBytesIfNeeded(
  Uint8List sourceBytes, {
  int maxBytes = _photoUploadMaxBytes,
}) {
  if (maxBytes <= 0) {
    throw ArgumentError.value(maxBytes, 'maxBytes', 'must be positive');
  }

  if (sourceBytes.lengthInBytes <= maxBytes) {
    return sourceBytes;
  }

  final decodedImage = img.decodeImage(sourceBytes);
  if (decodedImage == null) {
    throw Exception('Invalid photo image');
  }

  var working = img.bakeOrientation(decodedImage);
  var quality = 90;
  var encoded = Uint8List.fromList(img.encodeJpg(working, quality: quality));

  const minQuality = 35;
  const minDimension = 128;
  const resizeFactor = 0.9;

  while (encoded.lengthInBytes > maxBytes) {
    if (quality > minQuality) {
      quality = max(minQuality, quality - 5);
    } else {
      final nextWidth = max(
        minDimension,
        (working.width * resizeFactor).round(),
      );
      final nextHeight = max(
        minDimension,
        (working.height * resizeFactor).round(),
      );

      if (nextWidth == working.width && nextHeight == working.height) {
        break;
      }

      working = img.copyResize(
        working,
        width: nextWidth,
        height: nextHeight,
        interpolation: img.Interpolation.average,
      );
    }

    encoded = Uint8List.fromList(img.encodeJpg(working, quality: quality));
  }

  if (encoded.lengthInBytes <= maxBytes) {
    return encoded;
  }

  while (encoded.lengthInBytes > maxBytes &&
      (working.width > 16 || working.height > 16)) {
    final fallbackWidth = max(16, (working.width * 0.8).round());
    final fallbackHeight = max(16, (working.height * 0.8).round());

    if (fallbackWidth == working.width && fallbackHeight == working.height) {
      break;
    }

    working = img.copyResize(
      working,
      width: fallbackWidth,
      height: fallbackHeight,
      interpolation: img.Interpolation.average,
    );
    encoded = Uint8List.fromList(img.encodeJpg(working, quality: minQuality));
  }

  return encoded;
}

class _ProcessedImage {
  const _ProcessedImage({required this.bytes, required this.extension});

  final Uint8List bytes;
  final String extension;
}

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

  /// 프로필용: 이미지 선택 후 정사각형 크롭 UI 제공
  Future<XFile?> pickAvatarFromGallery() async {
    return pickImageFromGallery();
  }

  /// 프로필용: 카메라 촬영 후 정사각형 크롭 UI 제공
  Future<XFile?> pickAvatarFromCamera() async {
    return pickImageFromCamera();
  }

  /// Supabase Storage에 이미지 업로드
  /// [bucket] - 스토리지 버킷 이름 ('beans', 'logs', 'community', 'avatars')
  /// [userId] - 사용자 ID (폴더 구분용)
  /// [file] - 업로드할 파일
  Future<String?> uploadImage({
    required String bucket,
    required String userId,
    required XFile file,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalExtension = file.path.split('.').last.toLowerCase();
      final originalBytes = await file.readAsBytes();

      _ProcessedImage? processedImage;
      if (bucket == 'avatars') {
        processedImage = _processAvatarImage(originalBytes);
      } else if (_isPhotoBucket(bucket)) {
        processedImage = _processPhotoImage(
          bytes: originalBytes,
          originalExtension: originalExtension,
        );
      }

      final extension = processedImage?.extension ?? originalExtension;
      final fileName = '$userId/$timestamp.$extension';
      final bytes = processedImage?.bytes ?? originalBytes;
      final contentType = _resolveContentType(extension);

      await _client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      // 공개 URL 반환
      final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload image error: $e');
      rethrow;
    }
  }

  _ProcessedImage _processAvatarImage(Uint8List bytes) {
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception('Invalid avatar image');
    }

    final oriented = img.bakeOrientation(decodedImage);
    final squareSize = min(oriented.width, oriented.height);
    final offsetX = (oriented.width - squareSize) ~/ 2;
    final offsetY = (oriented.height - squareSize) ~/ 2;

    final cropped = img.copyCrop(
      oriented,
      x: offsetX,
      y: offsetY,
      width: squareSize,
      height: squareSize,
    );

    final normalized = squareSize > 512
        ? img.copyResize(
            cropped,
            width: 512,
            height: 512,
            interpolation: img.Interpolation.average,
          )
        : cropped;

    return _ProcessedImage(
      bytes: Uint8List.fromList(img.encodeJpg(normalized, quality: 90)),
      extension: 'jpg',
    );
  }

  _ProcessedImage _processPhotoImage({
    required Uint8List bytes,
    required String originalExtension,
  }) {
    if (bytes.lengthInBytes > _photoUploadMaxBytes &&
        _unsupportedResizeExtensions.contains(originalExtension)) {
      throw const ImageUploadException(
        'Unsupported image format for resize. Please use JPG, PNG, or WEBP.',
      );
    }

    final processedBytes = resizePhotoToMaxBytesIfNeeded(bytes);
    final isResized = !identical(bytes, processedBytes);

    return _ProcessedImage(
      bytes: processedBytes,
      extension: isResized ? 'jpg' : originalExtension,
    );
  }

  @visibleForTesting
  static bool isPhotoBucket(String bucket) => _isPhotoBucket(bucket);

  static bool _isPhotoBucket(String bucket) {
    return bucket == 'beans' || bucket == 'logs' || bucket == 'community';
  }

  String _resolveContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'application/octet-stream';
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
