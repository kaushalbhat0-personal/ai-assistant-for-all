import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [widget] in a MaterialApp for widget testing.
/// Usage:
///   await tester.pumpApp(MyWidget());
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        home: widget,
      ),
    );
  }
}
