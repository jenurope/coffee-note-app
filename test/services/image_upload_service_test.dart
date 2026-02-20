import 'dart:typed_data';

import 'package:coffee_note_app/services/image_upload_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('resizePhotoToMaxBytesIfNeeded', () {
    test('이미 제한 이하인 이미지는 그대로 반환한다', () {
      final source = Uint8List.fromList(
        img.encodeJpg(img.Image(width: 120, height: 120), quality: 85),
      );

      final result = resizePhotoToMaxBytesIfNeeded(
        source,
        maxBytes: source.lengthInBytes + 10,
      );

      expect(identical(result, source), isTrue);
      expect(result.lengthInBytes, source.lengthInBytes);
    });

    test('제한을 초과한 이미지는 제한 이하로 축소한다', () {
      final largeImage = _buildPatternImage(width: 1200, height: 1200);
      final source = Uint8List.fromList(img.encodePng(largeImage));
      const maxBytes = 50 * 1024;

      expect(source.lengthInBytes, greaterThan(maxBytes));

      final result = resizePhotoToMaxBytesIfNeeded(source, maxBytes: maxBytes);

      expect(result.lengthInBytes, lessThanOrEqualTo(maxBytes));
      expect(img.decodeImage(result), isNotNull);
    });

    test('유효하지 않은 이미지 바이트면 예외를 던진다', () {
      final invalid = Uint8List(2048);

      expect(
        () => resizePhotoToMaxBytesIfNeeded(invalid, maxBytes: 512),
        throwsException,
      );
    });

    test('maxBytes가 0 이하이면 ArgumentError를 던진다', () {
      expect(
        () => resizePhotoToMaxBytesIfNeeded(Uint8List(10), maxBytes: 0),
        throwsArgumentError,
      );
    });
  });
}

img.Image _buildPatternImage({required int width, required int height}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      image.setPixelRgb(
        x,
        y,
        (x * 17 + y * 31) % 256,
        (x * 7 + y * 13) % 256,
        (x * 3 + y * 5) % 256,
      );
    }
  }
  return image;
}
