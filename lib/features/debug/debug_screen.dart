import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:screenfix_ai/core/config/app_config.dart';
import 'package:screenfix_ai/features/analysis/domain/analysis_metrics.dart';
import 'package:screenfix_ai/features/analysis/integration/vision_health_check.dart';
import 'package:screenfix_ai/features/analysis/presentation/guidance_provider.dart';
import 'package:screenfix_ai/features/debug/debug_notifier.dart';
import 'package:screenfix_ai/features/screen_capture/domain/screen_capture_result.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugState = ref.watch(debugProvider);
    final debugNotifier = ref.read(debugProvider.notifier);
    final guidanceState = ref.watch(guidanceControllerProvider);
    final guidanceNotifier = ref.read(guidanceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Validation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              unawaited(debugNotifier.checkOverlayPermission());
              unawaited(debugNotifier.checkCapturePermission());
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
                  value: debugState.overlayPermissionGranted ? 'Granted' : 'Denied',
                  isSuccess: debugState.overlayPermissionGranted,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Check Permission',
                        isLoading: debugState.isOverlayChecking,
                        onPressed: () => unawaited(debugNotifier.checkOverlayPermission()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Request Permission',
                        isLoading: debugState.isOverlayRequesting,
                        onPressed: () => unawaited(debugNotifier.requestOverlayPermission()),
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
                  value: debugState.permissionAvailable
                      ? 'Available'
                      : 'Not Available',
                  isSuccess: debugState.permissionAvailable,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Check Token',
                        isLoading: debugState.isCaptureChecking,
                        onPressed: () => unawaited(debugNotifier.checkCapturePermission()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Request Permission',
                        isLoading: debugState.isCaptureRequesting,
                        onPressed: debugState.sessionActive
                            ? null
                            : () => unawaited(debugNotifier.requestCapturePermission()),
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
                  value: debugState.sessionActive ? 'Active' : 'Inactive',
                  isSuccess: debugState.sessionActive,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (debugState.sessionActive)
                      Expanded(
                        child: _ActionButton(
                          label: 'Stop Session',
                          isLoading: debugState.isSessionStopping,
                          onPressed: () => unawaited(debugNotifier.stopSession()),
                        ),
                      ),
                    if (!debugState.sessionActive && debugState.permissionAvailable)
                      Expanded(
                        child: _ActionButton(
                          label: 'Start Session',
                          isLoading: debugState.isSessionStarting,
                          onPressed: () => unawaited(debugNotifier.startSession()),
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
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Capture Screen',
                        isLoading: debugState.isCapturing,
                        onPressed: debugState.sessionActive
                            ? () => unawaited(debugNotifier.captureScreen())
                            : null,
                      ),
                    ),
                    if (debugState.lastCapture != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Analyze',
                          isLoading: guidanceState.isProcessing,
                          onPressed: guidanceState.isProcessing
                              ? null
                              : () => unawaited(guidanceNotifier.captureNow(
                                    debugState.lastCapture!,
                                    captureTime: debugState.captureDuration,
                                  )),
                        ),
                      ),
                    ],
                  ],
                ),
                if (debugState.lastCapture != null) ...[
                  const SizedBox(height: 12),
                  _CapturePreview(result: debugState.lastCapture!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Vision Diagnostics',
              children: [
                _InfoRow(label: 'Provider', value: VisionProvider.defaultProvider.displayName),
                _KeyStatusRow(hasKey: AppConfig.hasValidApiKey),
                _HealthStatusRow(metrics: guidanceState.metrics),
              ],
            ),
            if (guidanceState.metrics != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Analysis Metrics',
                children: [
                  _MetricRow(label: 'Capture', duration: guidanceState.metrics!.captureTime),
                  _MetricRow(label: 'Process', duration: guidanceState.metrics!.processTime),
                  _MetricRow(label: 'API', duration: guidanceState.metrics!.apiTime),
                  _MetricRow(label: 'Total', duration: guidanceState.metrics!.totalTime),
                  if (guidanceState.metrics!.jpegSizeBytes > 0) ...[
                    const SizedBox(height: 8),
                    _ByteRow(label: 'JPEG Size', bytes: guidanceState.metrics!.jpegSizeBytes),
                    _ByteRow(label: 'Original PNG', bytes: guidanceState.metrics!.originalPngSizeBytes),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const SizedBox(width: 80, child: Text('Compression:', style: TextStyle(fontWeight: FontWeight.w500))),
                          Text('${guidanceState.metrics!.compressionRatio.toStringAsFixed(1)}x'),
                        ],
                      ),
                    ),
                  ],
                  const Divider(),
                  _InfoRow(label: 'Model', value: guidanceState.metrics!.modelUsed),
                  _InfoRow(
                    label: 'Status',
                    value: guidanceState.metrics!.isSuccess ? 'Success' : 'Failed',
                    color: guidanceState.metrics!.isSuccess ? Colors.green : Colors.red,
                  ),
                  if (guidanceState.metrics!.promptTokens > 0)
                    _InfoRow(label: 'Prompt Tokens', value: '${guidanceState.metrics!.promptTokens}'),
                  if (guidanceState.metrics!.completionTokens > 0)
                    _InfoRow(label: 'Completion Tokens', value: '${guidanceState.metrics!.completionTokens}'),
                ],
              ),
            ],
            if (guidanceState.current != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Last Guidance',
                children: [
                  _InfoRow(label: 'Intent', value: guidanceState.current!.screenIntent.displayName),
                  _InfoRow(label: 'Summary', value: guidanceState.current!.summary),
                  ...guidanceState.current!.recommendations.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• ${r.title}: ${r.description}', style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Logs',
              children: [
                SizedBox(
                  height: 300,
                  child: debugState.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: debugState.logs.length,
                          itemBuilder: (_, index) {
                            final entry = debugState.logs[index];
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
                    onPressed: debugNotifier.clearLogs,
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

class _MetricRow extends StatelessWidget {
  final String label;
  final Duration duration;

  const _MetricRow({required this.label, required this.duration});

  @override
  Widget build(BuildContext context) {
    final ms = duration.inMilliseconds;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text('$ms ms'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: color != null ? TextStyle(color: color) : null),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '$bytes B';
}

class _ByteRow extends StatelessWidget {
  final String label;
  final int bytes;

  const _ByteRow({required this.label, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(_formatBytes(bytes)),
        ],
      ),
    );
  }
}

class _KeyStatusRow extends StatelessWidget {
  final bool hasKey;

  const _KeyStatusRow({required this.hasKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(
            width: 130,
            child: Text('API Key:', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Icon(
            hasKey ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: hasKey ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            hasKey ? 'Present' : 'Missing',
            style: TextStyle(
              color: hasKey ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthStatusRow extends StatelessWidget {
  final AnalysisMetrics? metrics;

  const _HealthStatusRow({this.metrics});

  @override
  Widget build(BuildContext context) {
    final health = VisionHealthCheck.run();
    final isHealthy = health == VisionHealthStatus.healthy;
    final label = health == VisionHealthStatus.healthy ? 'Healthy' : 'Misconfigured';
    final statusLabel = metrics?.isSuccess == true ? 'Connected' : label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(
            width: 130,
            child: Text('Health:', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            size: 18,
            color: isHealthy ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            statusLabel,
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
