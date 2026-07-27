import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/utils/latency_benchmark.dart';

void main() {
  test('LatencyBenchmark mock pipeline test runs successfully', () async {
    final metrics = await LatencyBenchmark.runPipelineBenchmark();

    // Verify all steps are included
    expect(metrics.length, 5);
    expect(metrics[0].stepName, 'Audio Capture & Encoding');
    expect(metrics[1].stepName, 'STT (Faster Whisper)');
    expect(metrics[2].stepName, 'LLM TTFT (DeepSeek-V3 Caching)');
    expect(metrics[3].stepName, 'TTS (Edge TTS)');
    expect(metrics[4].stepName, 'TOTAL ROUNDTRIP LATENCY');

    // Verify all steps succeeded
    for (final metric in metrics) {
      expect(metric.success, isTrue);
    }

    // Verify times are reasonable (simulated delays total ~1000ms)
    // In test environments it might run slightly faster/slower depending on event loop virtualization,
    // but total duration should be less than 1350ms.
    final totalMetric = metrics.last;
    expect(totalMetric.milliseconds, lessThan(1350.0));
  });
}
