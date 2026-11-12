import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/lesson_catalog.dart';
import '../../domain/models/recommended_path.dart';
import '../providers/dashboard_providers.dart';

/// #312 — tarjeta dominante de práctica del dashboard.
///
/// El diseño de referencia (`docs/product-audit/stitch/stitch_dashboard.png`)
/// deja una sola acción evidente: entrar a la siguiente mazmorra. Esta tarjeta
/// toma el primer paso de la ruta recomendada (la calcula el servidor) y lo
/// convierte en la CTA primaria de MAZMORRAS.
///
/// Si la ruta del servidor no llega (sin red, RPC caída o usuario nuevo), cae
/// al primer escenario del catálogo para su nivel: la pantalla nunca se queda
/// sin un siguiente paso.
class ContinueAdventureCard extends ConsumerWidget {
  const ContinueAdventureCard({super.key, this.levelCode = ''});

  final String levelCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pathAsync = ref.watch(recommendedPathProvider);
    final adventure = _resolve(pathAsync.valueOrNull);
    if (adventure == null) return const SizedBox.shrink();

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(18),
      onTap: () => _start(context, adventure),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.manaCyan,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  adventure.level.isEmpty
                      ? (l10n?.adventure_next_step ?? 'SIGUIENTE PASO')
                      : '${l10n?.adventure_next_step ?? 'SIGUIENTE PASO'} · ${adventure.level}',
                  style: const TextStyle(
                    color: AppColors.manaCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            adventure.title,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (adventure.goals > 0) _chip('${adventure.goals} objetivos'),
              if (adventure.minutes > 0) _chip('~${adventure.minutes} min'),
              if (adventure.level.isNotEmpty) _chip(adventure.level),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _start(context, adventure),
              icon: const Icon(Icons.mic_rounded, size: 22),
              label: Text(
                l10n?.adventure_speak_now ?? 'HABLAR AHORA',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaCyan,
                foregroundColor: AppColors.voidBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ruta del servidor si llega; si no, primer escenario del nivel.
  _Adventure? _resolve(List<RecommendedPathStep>? steps) {
    if (steps != null && steps.isNotEmpty) {
      final step = steps.first;
      final lesson = LessonCatalog.getLessonById(step.key, title: step.title);
      return _Adventure(
        key: step.key,
        title: step.title,
        level: step.level.isNotEmpty ? step.level : (lesson?.level ?? ''),
        goals: lesson?.goals.length ?? 0,
        minutes: step.estimatedMinutes,
      );
    }

    final fallback = _firstLessonOfLevel();
    if (fallback == null) return null;
    return _Adventure(
      key: fallback.id,
      title: fallback.title,
      level: fallback.level,
      goals: fallback.goals.length,
      minutes: 0,
    );
  }

  LessonData? _firstLessonOfLevel() {
    final catalog = LessonCatalog.catalog;
    if (catalog.isEmpty) return null;
    if (levelCode.isEmpty) return catalog.first;
    for (final lesson in catalog) {
      if (lesson.level.toUpperCase() == levelCode.toUpperCase()) return lesson;
    }
    return catalog.first;
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  void _start(BuildContext context, _Adventure adventure) {
    if (adventure.key.isEmpty) return;
    context.push(
      '/conversation?scenarioId=${Uri.encodeComponent(adventure.key)}'
      '&scenarioTitle=${Uri.encodeComponent(adventure.title)}',
    );
  }
}

class _Adventure {
  const _Adventure({
    required this.key,
    required this.title,
    required this.level,
    required this.goals,
    required this.minutes,
  });

  final String key;
  final String title;
  final String level;
  final int goals;
  final int minutes;
}
