import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/skill_band.dart';
import '../../providers/dashboard_providers.dart';

/// Radar de habilidades (fl_chart) con honestidad de métricas (P-35 / #120).
///
/// Las puntuaciones salen de la evaluación del Oráculo (un modelo de lenguaje),
/// no de un evaluador de voz: son una **estimación**. Por eso:
/// - no se muestran porcentajes con precisión falsa: nivel Bajo/Medio/Alto;
/// - la pronunciación no se pinta, porque hoy no se mide de verdad (se deriva
///   de la transcripción, no del audio).
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
              const Icon(
                Icons.radar_rounded,
                color: AppColors.runeViolet,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.radar_title ?? 'Radar de Habilidades',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tooltip(
                message:
                    l10n?.radar_estimated_tooltip ??
                    'Estimación basada en tu conversación',
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.radar_estimated_note ??
                'Estimación basada en tu conversación',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: radarAsync.when(
              data: (radarMap) {
                // Cinco ejes: la pronunciación se omite hasta tener un
                // evaluador de voz real (#120, opción larga).
                final entries = <(String, double)>[
                  (
                    l10n?.radar_fluency ?? 'Fluidez',
                    _score(radarMap['fluency']),
                  ),
                  (
                    l10n?.radar_vocab ?? 'Vocabulario',
                    _score(radarMap['vocab']),
                  ),
                  (
                    l10n?.radar_grammar ?? 'Gramática',
                    _score(radarMap['grammar']),
                  ),
                  (
                    l10n?.radar_comprehension ?? 'Comprensión',
                    _score(radarMap['comprehension']),
                  ),
                  (
                    l10n?.radar_naturalness ?? 'Naturalidad',
                    _score(radarMap['naturalness']),
                  ),
                ];

                return RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    radarBorderData: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.15),
                    ),
                    gridBorderData: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    radarBackgroundColor: Colors.transparent,
                    ticksTextStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                    ),
                    tickBorderData: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.05),
                    ),
                    titlePositionPercentageOffset: 0.38,
                    getTitle: (index, angle) {
                      final entry = entries[index % entries.length];
                      final band = SkillBand.fromScore(entry.$2);
                      return RadarChartTitle(
                        text: '${entry.$1}\n${_bandLabel(band, l10n)}',
                        angle: 0,
                      );
                    },
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppColors.runeViolet.withValues(alpha: 0.25),
                        borderColor: AppColors.runeViolet,
                        entryRadius: 3,
                        borderWidth: 2,
                        dataEntries: entries
                            .map((entry) => RadarEntry(value: entry.$2))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.runeViolet),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.mic_off_rounded,
                color: AppColors.onSurfaceVariant,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n?.radar_pronunciation_unmeasured ??
                      'Pronunciación: sin medición real todavía',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static double _score(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static String _bandLabel(SkillBand band, AppLocalizations? l10n) {
    switch (band) {
      case SkillBand.high:
        return l10n?.band_high ?? 'Alto';
      case SkillBand.medium:
        return l10n?.band_medium ?? 'Medio';
      case SkillBand.low:
        return l10n?.band_low ?? 'Bajo';
      case SkillBand.unknown:
        return '—';
    }
  }
}
