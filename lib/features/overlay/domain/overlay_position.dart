import 'package:equatable/equatable.dart';

class OverlayPosition extends Equatable {
  final double x;
  final double y;

  const OverlayPosition({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}
