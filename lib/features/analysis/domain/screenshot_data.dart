import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ScreenshotData extends Equatable {
  final Uint8List bytes;
  final int width;
  final int height;
  final int originalSizeBytes;
  final DateTime timestamp;

  const ScreenshotData({
    required this.bytes,
    required this.width,
    required this.height,
    required this.originalSizeBytes,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [bytes, width, height, originalSizeBytes, timestamp];
}
