import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:meta/meta.dart';

import 'package:screenfix_ai/features/analysis/domain/screenshot_data.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_result.dart';

@visibleForTesting
class ProcessArgs {
  final Uint8List rawBytes;
  final int width;
  final int height;
  final int maxDimension;
  final int quality;

  const ProcessArgs({
    required this.rawBytes,
    required this.width,
    required this.height,
    required this.maxDimension,
    required this.quality,
  });
}

class ImageProcessor {
  ImageProcessor._();

  static const int defaultMaxDimension = 1080;
  static const int defaultQuality = 70;

  static Future<ScreenshotData> process(
    ScreenCaptureResult raw, {
    int maxDimension = defaultMaxDimension,
    int quality = defaultQuality,
  }) async {
    final args = ProcessArgs(
      rawBytes: raw.bytes,
      width: raw.width,
      height: raw.height,
      maxDimension: maxDimension,
      quality: quality,
    );
    return compute(processInIsolate, args);
  }

  @visibleForTesting
  static ScreenshotData processInIsolate(ProcessArgs args) {
    final originalSize = args.rawBytes.length;
    final image = _decodeSafe(args.rawBytes);
    if (image == null) {
      throw Exception('ImageProcessor: failed to decode image');
    }

    img.Image target = image;

    final scale = _calculateScale(args.width, args.height, args.maxDimension);
    if (scale < 1.0) {
      final newWidth = (args.width * scale).round();
      final newHeight = (args.height * scale).round();
      target = img.copyResize(image, width: newWidth, height: newHeight);
    }

    final jpegBytes = img.encodeJpg(target, quality: args.quality);

    return ScreenshotData(
      bytes: Uint8List.fromList(jpegBytes),
      width: target.width,
      height: target.height,
      originalSizeBytes: originalSize,
      timestamp: DateTime.now(),
    );
  }

  static double _calculateScale(int width, int height, int maxDimension) {
    if (width <= maxDimension && height <= maxDimension) return 1.0;
    return maxDimension / (width > height ? width : height);
  }

  static img.Image? _decodeSafe(Uint8List bytes) {
    try {
      return img.decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }
}
