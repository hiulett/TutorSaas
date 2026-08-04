import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/hunter_class_data.dart';

/// Radar de estadísticas de combate de una clase (6 ejes).
///
/// Usa `fl_chart` (mismo patrón que `skills_radar_chart.dart`) con tema
/// medieval: relleno atenuado del color de la clase, bordes gris/piedra.
class ClassStatsRadar extends StatelessWidget {
  final HunterClassData cls;
  final AppLocalizations l10n;

  const ClassStatsRadar({super.key, required this.cls, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = cls.color;
    final entries = [
      cls.statsAttack,
      cls.statsDefense,
      cls.statsMagic,
      cls.statsSpeed,
      cls.statsSupport,
      cls.statsSurvival,
    ];
    const labels = [
      'stat0', 'stat1', 'stat2', 'stat3', 'stat4', 'stat5',
    ];
    final labelMap = {
      'stat0': l10n.character_stat_attack,
      'stat1': l10n.character_stat_defense,
      'stat2': l10n.character_stat_magic,
      'stat3': l10n.character_stat_speed,
      'stat4': l10n.character_stat_support,
      'stat5': l10n.character_stat_survival,
    };

    return SizedBox(
      height: 205,
      width: double.infinity,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: AppColors.medievalIron, width: 1.5),
          gridBorderData: BorderSide(color: AppColors.outlineVariant, width: 1),
          radarBackgroundColor: Colors.transparent,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          titleTextStyle: TextStyle(
            color: AppColors.medievalText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          tickBorderData: BorderSide(color: AppColors.outlineVariant, width: 1),
          // 0.5 deja espacio para el título inferior (velocidad) sin pisar
          // la descripción que va debajo del radar.
          titlePositionPercentageOffset: 0.5,
          getTitle: (index, angle) {
            final idx = index % labels.length;
            return RadarChartTitle(
              text: '${labelMap[labels[idx]]}\n${entries[idx]}',
            );
          },
          dataSets: [
            RadarDataSet(
              fillColor: color.withValues(alpha: 0.22),
              borderColor: color,
              entryRadius: 3,
              borderWidth: 2,
              dataEntries: entries.map((e) => RadarEntry(value: e.toDouble())).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
