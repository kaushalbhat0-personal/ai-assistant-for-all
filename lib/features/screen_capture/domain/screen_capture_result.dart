import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ScreenCaptureResult extends Equatable {
  final int width;
  final int height;
  final Uint8List bytes;
  final DateTime timestamp;

  const ScreenCaptureResult({
    required this.width,
    required this.height,
    required this.bytes,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [width, height, bytes, timestamp];
}
