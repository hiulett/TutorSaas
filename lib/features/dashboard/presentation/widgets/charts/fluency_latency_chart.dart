import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../providers/dashboard_providers.dart';

/// Curva Neón de Fluidez & Latencia (fl_chart).
/// Extraído de dashboard_screen (REF-01).
class FluencyLatencyChart extends ConsumerWidget {
  const FluencyLatencyChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(fluencyTrendsProvider);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.show_chart_rounded, color: AppColors.manaCyan, size: 20),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: const Text(
                      'Evolución de Fluidez & Latencia',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.manaCyan, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('WPM', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.manaCyan, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.chart_latency, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: trendsAsync.when(
              data: (dataList) {
                final list = dataList.isEmpty
                    ? [
                        {'avg_response_latency_seconds': 3.2, 'avg_speaking_wpm': 88},
                        {'avg_response_latency_seconds': 2.7, 'avg_speaking_wpm': 104},
                        {'avg_response_latency_seconds': 2.2, 'avg_speaking_wpm': 118},
                        {'avg_response_latency_seconds': 1.8, 'avg_speaking_wpm': 130},
                      ]
                    : dataList;

                final wpmSpots = list.asMap().entries.map((e) {
                  final wpm = (e.value['avg_speaking_wpm'] as num? ?? 100).toDouble();
                  return FlSpot(e.key.toDouble(), wpm);
                }).toList();

                final latencySpots = list.asMap().entries.map((e) {
                  final lat = (e.value['avg_response_latency_seconds'] as num? ?? 2.0).toDouble();
                  return FlSpot(e.key.toDouble(), lat * 25);
                }).toList();

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 160,
                    lineBarsData: [
                      LineChartBarData(
                        spots: wpmSpots,
                        isCurved: true,
                        color: AppColors.manaCyan,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.manaCyan.withValues(alpha: 0.15),
                        ),
                      ),
                      LineChartBarData(
                        spots: latencySpots,
                        isCurved: true,
                        color: AppColors.manaCyan,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.runeViolet)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
