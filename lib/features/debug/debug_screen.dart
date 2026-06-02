import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/features/debug/debug_notifier.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_result.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debugProvider);
    final notifier = ref.read(debugProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Validation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              unawaited(notifier.checkOverlayPermission());
              unawaited(notifier.checkCapturePermission());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Overlay',
              children: [
                _StatusRow(
                  label: 'Status',
                  value: state.overlayPermissionGranted ? 'Granted' : 'Denied',
                  isSuccess: state.overlayPermissionGranted,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Check Permission',
                        isLoading: state.isOverlayChecking,
                        onPressed: () => unawaited(notifier.checkOverlayPermission()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Request Permission',
                        isLoading: state.isOverlayRequesting,
                        onPressed: () => unawaited(notifier.requestOverlayPermission()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Screen Capture Permission',
              children: [
                _StatusRow(
                  label: 'Token',
                  value: state.permissionAvailable
                      ? 'Available'
                      : 'Not Available',
                  isSuccess: state.permissionAvailable,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Check Token',
                        isLoading: state.isCaptureChecking,
                        onPressed: () => unawaited(notifier.checkCapturePermission()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Request Permission',
                        isLoading: state.isCaptureRequesting,
                        onPressed: state.sessionActive
                            ? null
                            : () => unawaited(notifier.requestCapturePermission()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Projection Session',
              children: [
                _StatusRow(
                  label: 'Status',
                  value: state.sessionActive ? 'Active' : 'Inactive',
                  isSuccess: state.sessionActive,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (state.sessionActive)
                      Expanded(
                        child: _ActionButton(
                          label: 'Stop Session',
                          isLoading: state.isSessionStopping,
                          onPressed: () => unawaited(notifier.stopSession()),
                        ),
                      ),
                    if (!state.sessionActive && state.permissionAvailable)
                      Expanded(
                        child: _ActionButton(
                          label: 'Start Session',
                          isLoading: state.isSessionStarting,
                          onPressed: () => unawaited(notifier.startSession()),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Capture',
              children: [
                _ActionButton(
                  label: 'Capture Screen',
                  isLoading: state.isCapturing,
                  onPressed: state.sessionActive
                      ? () => unawaited(notifier.captureScreen())
                      : null,
                ),
                if (state.lastCapture != null) ...[
                  const SizedBox(height: 12),
                  _CapturePreview(result: state.lastCapture!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Logs',
              children: [
                SizedBox(
                  height: 300,
                  child: state.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.logs.length,
                          itemBuilder: (_, index) {
                            final entry = state.logs[index];
                            final icon = switch (entry.type) {
                              'success' => Icons.check_circle,
                              'error' => Icons.error,
                              _ => Icons.info,
                            };
                            final color = switch (entry.type) {
                              'success' => Colors.green,
                              'error' => Colors.red,
                              _ => Colors.blue,
                            };
                            final time =
                                '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
                                '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
                                '${entry.timestamp.second.toString().padLeft(2, '0')}';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(icon, size: 16, color: color),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '$time ${entry.message}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: notifier.clearLogs,
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Clear Logs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSuccess;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Icon(
          isSuccess ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: isSuccess ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: isSuccess ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}

class _CapturePreview extends StatelessWidget {
  final ScreenCaptureResult result;

  const _CapturePreview({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Width: ${result.width}'),
        Text('Height: ${result.height}'),
        Text('Timestamp: ${result.timestamp}'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            result.bytes,
            width: double.infinity,
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
