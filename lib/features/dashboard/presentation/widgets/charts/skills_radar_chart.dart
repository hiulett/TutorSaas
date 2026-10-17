import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../providers/dashboard_providers.dart';
import '../../../../../l10n/app_localizations.dart';

/// Radar Holográfico 6-D de Habilidades (fl_chart).
/// Extraído de dashboard_screen (REF-01). Usa datos reales del Oráculo
/// (oracle_turns) con fallback a métricas diarias.
class SkillsRadarChart extends ConsumerWidget {
  const SkillsRadarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
                  l10n?.radar_title ?? 'Radar Holográfico de Habilidades',
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: radarAsync.when(
              data: (radarMap) {
                final fluency = (radarMap['fluency'] ?? 0).toDouble();
                final vocab = (radarMap['vocab'] ?? 0).toDouble();
                final phonetics = (radarMap['phonetics'] ?? 0).toDouble();
                final grammar = (radarMap['grammar'] ?? 0).toDouble();
                final comprehension = (radarMap['comprehension'] ?? 0).toDouble();
                final naturalness = (radarMap['naturalness'] ?? 0).toDouble();

                return RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    radarBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.15)),
                    gridBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.08), width: 1),
                    radarBackgroundColor: Colors.transparent,
                    ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
                    tickBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.05)),
                    titlePositionPercentageOffset: 0.38,
                    getTitle: (index, angle) {
                      final labels = [
                        ('${l10n?.radar_fluency ?? 'Fluidez'}', fluency),
                        ('${l10n?.radar_vocab ?? 'Vocabulario'}', vocab),
                        ('${l10n?.radar_phonetics ?? 'Fonética'}', phonetics),
                        ('${l10n?.radar_grammar ?? 'Gramática'}', grammar),
                        ('${l10n?.radar_comprehension ?? 'Comprensión'}', comprehension),
                        ('${l10n?.radar_naturalness ?? 'Naturalidad'}', naturalness),
                      ];
                      final idx = index % labels.length;
                      return RadarChartTitle(
                        text: '${labels[idx].$1}\n${labels[idx].$2.round()}%',
                      );
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
                          RadarEntry(value: comprehension),
                          RadarEntry(value: naturalness),
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
