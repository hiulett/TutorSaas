import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../providers/dashboard_providers.dart';

/// Mapa de Calor de Práctica Diaria (4 semanas).
/// Extraído de dashboard_screen (REF-01).
class PracticeHeatmap extends ConsumerWidget {
  const PracticeHeatmap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(practiceHeatmapProvider);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_view_week_rounded, color: AppColors.royalGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consistencia de Práctica (4 Semanas)',
                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          heatmapAsync.when(
            data: (heatmapList) {
              final Map<String, int> dateToMinutes = {};
              for (final row in heatmapList) {
                final dateStr = (row['date'] as String? ?? '').split('T').first;
                final mins = (row['minutes_practiced'] as num? ?? 0).toInt();
                if (dateStr.isNotEmpty) {
                  dateToMinutes[dateStr] = mins;
                }
              }

              final now = DateTime.now();

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(28, (index) {
                      final dayDate = now.subtract(Duration(days: 27 - index));
                      final dayStr = "${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}";
                      final minutes = dateToMinutes[dayStr] ?? 0;

                      Color cellColor;
                      if (minutes == 0) {
                        cellColor = AppColors.onSurface.withValues(alpha: 0.05);
                      } else if (minutes < 10) {
                        cellColor = AppColors.runeViolet.withValues(alpha: 0.3);
                      } else if (minutes < 20) {
                        cellColor = AppColors.runeViolet;
                      } else {
                        cellColor = AppColors.manaCyan;
                      }

                      return Expanded(
                        child: Tooltip(
                          message: '$dayStr: $minutes min',
                          child: Container(
                            height: 24,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.chart_4weeks, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                      Text(AppLocalizations.of(context)!.chart_today, style: TextStyle(color: AppColors.manaCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.runeViolet)),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
