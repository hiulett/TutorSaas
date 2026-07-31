import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/lesson_catalog.dart';

class LessonPreviewSheet extends StatelessWidget {
  final LessonData lesson;

  const LessonPreviewSheet({
    super.key,
    required this.lesson,
  });

  static void show(BuildContext context, LessonData lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LessonPreviewSheet(lesson: lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: AppColors.runeViolet,
                width: 1.5,
              ),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Grabber Handle
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

                // Header Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.runeViolet.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'NIVEL ${lesson.level} • ${lesson.category.toUpperCase()}',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.manaCyan,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4),
                        Text(
                          '~15 min',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  lesson.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lesson.description,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Roles Card
                GlassCard(
                  blur: 20,
                  opacity: 0.06,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '👤 Tu Rol:',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lesson.userRole,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 35, color: Colors.white12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🤖 Rol del Tutor AI:',
                              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lesson.assistantRole,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.manaCyan,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 5 Goals Section
                Text(
                  'Metas Conversacionales (${lesson.goals.length}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),

                ...lesson.goals.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final g = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.runeViolet.withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: Text(
                              '$idx',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.runeViolet,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (g.examplePhrase.isNotEmpty)
                                Text(
                                  'Ej: "${g.examplePhrase}"',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Useful Phrases Section
                Text(
                  'Frases Útiles Preparatorias (${lesson.usefulPhrases.length}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: lesson.usefulPhrases.take(4).map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.phrase,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              p.translation,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Start Voice Call Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                        '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.runeViolet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mic_rounded, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Iniciar Conversación de Voz',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
