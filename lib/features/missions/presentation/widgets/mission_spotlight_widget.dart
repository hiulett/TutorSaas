import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/mission_providers.dart';
import 'mission_card.dart';

/// Bloque "Misión del día" de Home (issue #109).
///
/// 1 misión principal destacada + 2 secundarias, con barra de progreso real y
/// recompensa visible. Tocar el bloque abre la pantalla de misiones; el
/// reclamo se hace desde el botón de cada tarjeta.
class MissionSpotlightWidget extends ConsumerWidget {
  /// Racha para el pill del header (solo se muestra si se pasa).
  final int? streakDays;

  const MissionSpotlightWidget({super.key, this.streakDays});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spotlightAsync = ref.watch(missionSpotlightProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.manaCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.missions_spotlight ?? 'MISIÓN DEL DÍA',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (streakDays != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.royalGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.royalGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.royalGold,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$streakDays',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.royalGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                InkWell(
                  onTap: () => context.push('/missions'),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Text(
                      l10n?.missions_see_all ?? 'VER TODAS',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.manaCyan,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        spotlightAsync.when(
          data: (spotlight) {
            if (spotlight.isEmpty) {
              return GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                padding: const EdgeInsets.all(18),
                onTap: () => context.push('/missions'),
                child: Text(
                  l10n?.missions_empty_daily ??
                      'Aún no tienes misiones diarias. Llegan cada día a las 00:05 UTC.',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              );
            }
            final primary = spotlight.primary!;
            return Column(
              children: [
                MissionCard(mission: primary, featured: true),
                if (spotlight.secondary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final mission in spotlight.secondary) ...[
                    MissionCard(mission: mission, compact: true),
                    const SizedBox(height: 8),
                  ],
                ],
              ],
            );
          },
          loading: () => const GlassCard(
            blur: 20,
            opacity: AppColors.glassOpacity,
            padding: EdgeInsets.symmetric(vertical: 26),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.runeViolet,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (error, stack) {
            debugPrint('No se pudieron cargar las misiones: $error');
            return GlassCard(
              blur: 20,
              opacity: AppColors.glassOpacity,
              padding: const EdgeInsets.all(16),
              onTap: () => ref.invalidate(activeMissionsProvider),
              child: Text(
                l10n?.missions_load_error ??
                    'No pudimos cargar tus misiones. Toca para reintentar.',
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
