import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/lesson_catalog.dart';

class NextRecommendedLessonHero extends StatelessWidget {
  final LessonData lesson;
  final double stageCompletionPercentage;

  const NextRecommendedLessonHero({
    super.key,
    required this.lesson,
    required this.stageCompletionPercentage,
  });

  IconData _getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'handshake':
        return Icons.handshake_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      case 'schedule':
        return Icons.access_time_filled_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'explore':
        return Icons.explore_rounded;
      case 'devices':
        return Icons.devices_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = _getIconData(lesson.iconKey);

    return GlassCard(
      blur: 25,
      opacity: 0.12,
      border: Border.all(
        color: AppColors.runeViolet.withValues(alpha: 0.4),
        width: 1.5,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                constraints: const BoxConstraints(maxWidth: 240),
                decoration: BoxDecoration(
                  color: AppColors.runeViolet.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.runeViolet.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.manaCyan,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'SIGUIENTE PASO • ETAPA ${lesson.level}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.manaCyan,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(stageCompletionPercentage * 100).toInt()}% de etapa superada',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.runeViolet.withValues(alpha: 0.4),
                      AppColors.manaCyan.withValues(alpha: 0.3),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => _showObjectivesModal(context, lesson),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.runeViolet.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.runeViolet.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.center_focus_strong_rounded,
                    color: AppColors.manaCyan,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Objetivo: ${lesson.mainObjective}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.manaCyan,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.runeViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: AppColors.runeViolet.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic_rounded, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Iniciar Lección de Voz Ahora',
                      style: GoogleFonts.hankenGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showObjectivesModal(BuildContext context, LessonData lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.center_focus_strong_rounded, color: AppColors.manaCyan, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Objetivo y Metas de la Lección',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.runeViolet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '🎯 ${lesson.mainObjective}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '📋 Metas Comunicativas (1 Estrella ⭐ para Aprobar):',
                style: const TextStyle(color: AppColors.manaCyan, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (lesson.goals.isEmpty)
                const Text('• Completar la conversación de rol exitosamente.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))
              else
                ...lesson.goals.map(
                  (g) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.manaCyan, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(g.text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                '💡 Frases Recomendadas (2 y 3 Estrellas ⭐⭐/⭐⭐⭐):',
                style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (lesson.usefulPhrases.isEmpty)
                const Text('• Vocabulario relevante al escenario.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12))
              else
                ...lesson.usefulPhrases.map(
                  (p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star_border_rounded, color: Colors.amberAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12),
                              children: [
                                TextSpan(text: '${p.phrase} ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                TextSpan(text: '(${p.translation})', style: const TextStyle(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.runeViolet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
