import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/core/di/get_it.dart';
import 'package:screenfix_ai/features/overlay/integration/overlay_service.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_result.dart';
import 'package:screenfix_ai/features/screen_capture/integration/screen_capture_service.dart';

class DebugLogEntry {
  final String message;
  final String type;
  final DateTime timestamp;

  const DebugLogEntry({
    required this.message,
    required this.type,
    required this.timestamp,
  });
}

class DebugState {
  final bool overlayPermissionGranted;
  final bool permissionAvailable;
  final bool sessionActive;
  final ScreenCaptureResult? lastCapture;
  final Duration captureDuration;
  final bool isOverlayChecking;
  final bool isOverlayRequesting;
  final bool isCaptureChecking;
  final bool isCaptureRequesting;
  final bool isSessionStarting;
  final bool isSessionStopping;
  final bool isCapturing;
  final List<DebugLogEntry> logs;

  const DebugState({
    this.overlayPermissionGranted = false,
    this.permissionAvailable = false,
    this.sessionActive = false,
    this.lastCapture,
    this.captureDuration = Duration.zero,
    this.isOverlayChecking = false,
    this.isOverlayRequesting = false,
    this.isCaptureChecking = false,
    this.isCaptureRequesting = false,
    this.isSessionStarting = false,
    this.isSessionStopping = false,
    this.isCapturing = false,
    this.logs = const [],
  });

  DebugState copyWith({
    bool? overlayPermissionGranted,
    bool? permissionAvailable,
    bool? sessionActive,
    ScreenCaptureResult? lastCapture,
    Duration? captureDuration,
    bool? isOverlayChecking,
    bool? isOverlayRequesting,
    bool? isCaptureChecking,
    bool? isCaptureRequesting,
    bool? isSessionStarting,
    bool? isSessionStopping,
    bool? isCapturing,
    List<DebugLogEntry>? logs,
  }) {
    return DebugState(
      overlayPermissionGranted:
          overlayPermissionGranted ?? this.overlayPermissionGranted,
      permissionAvailable: permissionAvailable ?? this.permissionAvailable,
      sessionActive: sessionActive ?? this.sessionActive,
      lastCapture: lastCapture ?? this.lastCapture,
      captureDuration: captureDuration ?? this.captureDuration,
      isOverlayChecking: isOverlayChecking ?? this.isOverlayChecking,
      isOverlayRequesting: isOverlayRequesting ?? this.isOverlayRequesting,
      isCaptureChecking: isCaptureChecking ?? this.isCaptureChecking,
      isCaptureRequesting: isCaptureRequesting ?? this.isCaptureRequesting,
      isSessionStarting: isSessionStarting ?? this.isSessionStarting,
      isSessionStopping: isSessionStopping ?? this.isSessionStopping,
      isCapturing: isCapturing ?? this.isCapturing,
      logs: logs ?? this.logs,
    );
  }
}

final debugProvider = StateNotifierProvider<DebugNotifier, DebugState>(
  (ref) => DebugNotifier(),
);

class DebugNotifier extends StateNotifier<DebugState> {
  final OverlayService _overlayService;
  final ScreenCaptureService _captureService;

  DebugNotifier()
      : _overlayService = getIt<OverlayService>(),
        _captureService = getIt<ScreenCaptureService>(),
        super(const DebugState());

  void _addLog(String message, String type) {
    state = state.copyWith(
      logs: [
        ...state.logs,
        DebugLogEntry(
          message: message,
          type: type,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> checkOverlayPermission() async {
    state = state.copyWith(isOverlayChecking: true);
    try {
      final granted = await _overlayService.checkOverlayPermission();
      state = state.copyWith(
        overlayPermissionGranted: granted,
        isOverlayChecking: false,
      );
      _addLog(
        granted ? 'Overlay permission: granted' : 'Overlay permission: denied',
        granted ? 'success' : 'info',
      );
    } catch (e) {
      state = state.copyWith(isOverlayChecking: false);
      _addLog('Overlay check failed: $e', 'error');
    }
  }

  Future<void> requestOverlayPermission() async {
    state = state.copyWith(isOverlayRequesting: true);
    try {
      final granted = await _overlayService.requestOverlayPermission();
      state = state.copyWith(
        overlayPermissionGranted: granted,
        isOverlayRequesting: false,
      );
      _addLog(
        granted
            ? 'Overlay permission: granted'
            : 'Overlay permission: denied',
        granted ? 'success' : 'info',
      );
    } catch (e) {
      state = state.copyWith(isOverlayRequesting: false);
      _addLog('Overlay request failed: $e', 'error');
    }
  }

  Future<void> checkCapturePermission() async {
    state = state.copyWith(isCaptureChecking: true);
    try {
      final status = await _captureService.hasPermission();
      state = state.copyWith(
        permissionAvailable: status.isGranted,
        isCaptureChecking: false,
      );
      _addLog(
        status.isGranted
            ? 'Permission token: available'
            : 'Permission token: not available',
        status.isGranted ? 'success' : 'info',
      );
    } catch (e) {
      state = state.copyWith(isCaptureChecking: false);
      _addLog('Permission check failed: $e', 'error');
    }
  }

  Future<void> requestCapturePermission() async {
    state = state.copyWith(isCaptureRequesting: true);
    try {
      final status = await _captureService.requestPermission();
      state = state.copyWith(
        permissionAvailable: status.isGranted,
        isCaptureRequesting: false,
      );
      _addLog(
        status.isGranted
            ? 'Permission token: granted'
            : 'Permission token: $status',
        status.isGranted ? 'success' : 'info',
      );
      if (status.isGranted) {
        await startSession();
      }
    } catch (e) {
      state = state.copyWith(isCaptureRequesting: false);
      _addLog('Permission request failed: $e', 'error');
    }
  }

  Future<void> startSession() async {
    state = state.copyWith(isSessionStarting: true);
    try {
      final ok = await _captureService.startSession();
      state = state.copyWith(
        sessionActive: ok,
        permissionAvailable: ok ? false : state.permissionAvailable,
        isSessionStarting: false,
      );
      _addLog(
        ok ? 'projectionSessionStarted' : 'Projection session: failed to start',
        ok ? 'success' : 'error',
      );
    } catch (e) {
      state = state.copyWith(isSessionStarting: false);
      _addLog('Start session failed: $e', 'error');
    }
  }

  Future<void> stopSession() async {
    state = state.copyWith(isSessionStopping: true);
    try {
      final ok = await _captureService.stopSession();
      state = state.copyWith(
        sessionActive: !ok,
        isSessionStopping: false,
      );
      _addLog(
        ok ? 'projectionSessionStopped' : 'Projection session: failed to stop',
        ok ? 'success' : 'error',
      );
    } catch (e) {
      state = state.copyWith(isSessionStopping: false);
      _addLog('Stop session failed: $e', 'error');
    }
  }

  Future<void> captureScreen() async {
    state = state.copyWith(isCapturing: true);
    final captureSw = Stopwatch()..start();
    try {
      final result = await _captureService.captureScreen();
      captureSw.stop();
      if (result != null) {
        state = state.copyWith(
          lastCapture: result,
          captureDuration: captureSw.elapsed,
          isCapturing: false,
        );
        _addLog(
          'Screen captured: ${result.width}x${result.height} '
              '(${result.bytes.length} bytes, ${captureSw.elapsed.inMilliseconds}ms)',
          'success',
        );
      } else {
        state = state.copyWith(isCapturing: false);
        _addLog('Screen capture returned null', 'error');
      }
    } catch (e) {
      captureSw.stop();
      state = state.copyWith(isCapturing: false);
      _addLog('Screen capture failed: $e', 'error');
    }
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }
}
