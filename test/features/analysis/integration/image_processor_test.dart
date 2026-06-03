import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:screenfix_ai/features/analysis/integration/image_processor.dart';

/// Generates a 4K PNG (3840×2160) with photo-like random blocks to simulate
/// a realistic screenshot that PNG cannot highly compress.
Uint8List _generate4kPng() {
  final image = img.Image(width: 3840, height: 2160, numChannels: 4);
  final rng = Random(42);
  // Fill with 16×16 random-colored blocks to simulate a real UI screenshot.
  const block = 16;
  for (var y = 0; y < 2160; y += block) {
    for (var x = 0; x < 3840; x += block) {
      final r = rng.nextInt(256);
      final g = rng.nextInt(256);
      final b = rng.nextInt(256);
      for (var dy = 0; dy < block && y + dy < 2160; dy++) {
        for (var dx = 0; dx < block && x + dx < 3840; dx++) {
          image.setPixelRgba(x + dx, y + dy, r, g, b, 255);
        }
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('ImageProcessor - 4K resize (processInIsolate)', () {
    late Uint8List rawPng;
    late int rawWidth;
    late int rawHeight;

    setUp(() {
      rawPng = _generate4kPng();
      rawWidth = 3840;
      rawHeight = 2160;
    });

    test('resizes 3840×2160 to ≤1080px longest side', () {
      final args = ProcessArgs(
        rawBytes: rawPng,
        width: rawWidth,
        height: rawHeight,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.width, lessThanOrEqualTo(1080));
      expect(result.height, lessThanOrEqualTo(1080));
      expect(result.width, 1080);
      expect(result.height, 608);
    });

    test('output is valid JPEG', () {
      final args = ProcessArgs(
        rawBytes: rawPng,
        width: rawWidth,
        height: rawHeight,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.bytes[0], 0xFF);
      expect(result.bytes[1], 0xD8);
    });

    test('keeps original size bytes metadata', () {
      final args = ProcessArgs(
        rawBytes: rawPng,
        width: rawWidth,
        height: rawHeight,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.originalSizeBytes, rawPng.length);
    });

    test('no-op when image is already smaller than maxDimension', () {
      final smallImage = img.Image(width: 800, height: 600, numChannels: 4);
      for (var y = 0; y < 600; y++) {
        for (var x = 0; x < 800; x++) {
          smallImage.setPixelRgba(x, y, 0, 0, 0, 255);
        }
      }
      final smallPng = Uint8List.fromList(img.encodePng(smallImage));

      final args = ProcessArgs(
        rawBytes: smallPng,
        width: 800,
        height: 600,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.width, 800);
      expect(result.height, 600);
    });

    test('throws on invalid image data', () {
      final args = ProcessArgs(
        rawBytes: Uint8List.fromList([0, 1, 2, 3]),
        width: 1,
        height: 1,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      expect(
        () => ImageProcessor.processInIsolate(args),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ImageProcessor - performance', () {
    late Uint8List rawPng;

    setUp(() {
      rawPng = _generate4kPng();
    });

    test('processes 4K image under 1500ms', () {
      final args = ProcessArgs(
        rawBytes: rawPng,
        width: 3840,
        height: 2160,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final stopwatch = Stopwatch()..start();
      ImageProcessor.processInIsolate(args);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(1500),
          reason: '4K → 1080 JPEG should complete under 1500ms in debug mode');
    });

    test('output is under 500KB', () {
      final args = ProcessArgs(
        rawBytes: rawPng,
        width: 3840,
        height: 2160,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.bytes.length, lessThan(500 * 1024),
          reason: '4K → 1080 JPEG q70 should be under 500KB');
    });
  });

  group('ImageProcessor - edge cases', () {
    test('handles perfect square 4K image', () {
      final image = img.Image(width: 3840, height: 3840, numChannels: 4);
      for (var y = 0; y < 3840; y++) {
        for (var x = 0; x < 3840; x++) {
          image.setPixelRgba(x, y, 255, 0, 0, 255);
        }
      }
      final png = Uint8List.fromList(img.encodePng(image));

      final args = ProcessArgs(
        rawBytes: png,
        width: 3840,
        height: 3840,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.width, 1080);
      expect(result.height, 1080);
    });

    test('handles portrait 4K image (2160×3840)', () {
      final image = img.Image(width: 2160, height: 3840, numChannels: 4);
      for (var y = 0; y < 3840; y++) {
        for (var x = 0; x < 2160; x++) {
          image.setPixelRgba(x, y, 0, 255, 0, 255);
        }
      }
      final png = Uint8List.fromList(img.encodePng(image));

      final args = ProcessArgs(
        rawBytes: png,
        width: 2160,
        height: 3840,
        maxDimension: ImageProcessor.defaultMaxDimension,
        quality: ImageProcessor.defaultQuality,
      );

      final result = ImageProcessor.processInIsolate(args);

      expect(result.width, 608);
      expect(result.height, 1080);
    });
  });
}
