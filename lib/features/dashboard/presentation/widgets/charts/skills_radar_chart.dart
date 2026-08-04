import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../providers/dashboard_providers.dart';

/// Radar Holográfico 5-D de Habilidades (fl_chart).
/// Extraído de dashboard_screen (REF-01).
class SkillsRadarChart extends ConsumerWidget {
  const SkillsRadarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radarAsync = ref.watch(skillsRadarProvider);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: AppColors.runeViolet, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Radar Holográfico 5-D de Habilidades',
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: radarAsync.when(
              data: (radarMap) {
                final fluency = radarMap['fluency'] ?? 80;
                final vocab = radarMap['vocab'] ?? 75;
                final phonetics = radarMap['phonetics'] ?? 85;
                final grammar = radarMap['grammar'] ?? 82;
                final goals = radarMap['goals'] ?? 90;

                return RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    radarBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.15)),
                    gridBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.08), width: 1),
                    radarBackgroundColor: Colors.transparent,
                    ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                    tickBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.05)),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return RadarChartTitle(text: 'Fluidez\n${fluency.toInt()}%');
                        case 1:
                          return RadarChartTitle(text: 'Vocabulario\n${vocab.toInt()}%');
                        case 2:
                          return RadarChartTitle(text: 'Fonética\n${phonetics.toInt()}%');
                        case 3:
                          return RadarChartTitle(text: 'Gramática\n${grammar.toInt()}%');
                        case 4:
                          return RadarChartTitle(text: 'Metas\n${goals.toInt()}%');
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppColors.runeViolet.withValues(alpha: 0.25),
                        borderColor: AppColors.runeViolet,
                        entryRadius: 3,
                        borderWidth: 2,
                        dataEntries: [
                          RadarEntry(value: fluency),
                          RadarEntry(value: vocab),
                          RadarEntry(value: phonetics),
                          RadarEntry(value: grammar),
                          RadarEntry(value: goals),
                        ],
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
