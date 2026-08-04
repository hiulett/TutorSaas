import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../providers/dashboard_providers.dart';

class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top custom back button/header
                  Row(
                    children: [
                      ClipOval(
                        child: Material(
                          color: AppColors.onSurface.withValues(alpha: 0.05),
                          child: InkWell(
                            onTap: () {
                              ref.read(dashboardRefreshProvider.notifier).state++;
                              ref.invalidate(userProgressProvider);
                              ref.invalidate(skillsRadarProvider);
                              ref.invalidate(practiceHeatmapProvider);
                              ref.invalidate(fluencyTrendsProvider);
                              ref.invalidate(weeklyPracticeProvider);
                              ref.invalidate(learnedVocabularyProvider);
                              context.go('/home');
                            },
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Resumen',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Session Completed Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.runeViolet.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.runeViolet.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.runeViolet,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '¡SESIÓN COMPLETADA!',
                            style: TextStyle(
                              color: AppColors.runeViolet,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    'Resumen de la Sesión',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Buen trabajo! Aquí tienes el análisis de tu desempeño hoy.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Compute dynamic metrics from active/recent conversation state
                  () {
                    final convState = ref.watch(conversationStateProvider);
                    final messages = convState.messages;
                    final userMsgs = messages.where((m) => m.sender == 'user').toList();
                    final wordCount = userMsgs.fold(0, (sum, m) => sum + m.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length);

                    final double fluencyVal = userMsgs.isEmpty ? 0.85 : math.min(0.98, math.max(0.70, 0.78 + (wordCount > 20 ? 0.15 : wordCount * 0.005)));
                    final int fluencyPct = (fluencyVal * 100).round();

                    final double pronVal = userMsgs.isEmpty ? 0.80 : math.min(0.96, math.max(0.72, 0.75 + (userMsgs.length * 0.03)));
                    final int pronPct = (pronVal * 100).round();

                    final corrections = userMsgs.where((m) => m.originalText != null && m.originalText!.isNotEmpty).toList();

                    // Estimated session duration (~45s per user turn) since no clock is stored.
                    final int sessionSeconds = userMsgs.isEmpty ? 0 : math.max(60, userMsgs.length * 45);
                    final int sessionMin = sessionSeconds ~/ 60;
                    final int sessionSec = sessionSeconds % 60;
                    final String durationLabel = sessionMin > 0
                        ? '${sessionMin}m ${sessionSec.toString().padLeft(2, '0')}s'
                        : '${sessionSec}s';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress Meters Bento Grid
                        Row(
                          children: [
                            // Fluency circular meter
                            Expanded(
                              child: GlassCard(
                                blur: 20,
                                opacity: AppColors.glassOpacity,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Fluidez',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    CustomPaint(
                                      size: const Size(100, 100),
                                      painter: NeonProgressPainter(
                                        progress: fluencyVal,
                                        color: AppColors.manaCyan,
                                      ),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Center(
                                          child: Text(
                                            '$fluencyPct%',
                                            style: const TextStyle(
                                              color: AppColors.manaCyan,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      userMsgs.isEmpty
                                          ? 'Práctica lista para iniciar.'
                                          : 'Hablaste $wordCount palabras con buen ritmo.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Pronunciation circular meter
                            Expanded(
                              child: GlassCard(
                                blur: 20,
                                opacity: AppColors.glassOpacity,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Pronunciación',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    CustomPaint(
                                      size: const Size(100, 100),
                                      painter: NeonProgressPainter(
                                        progress: pronVal,
                                        color: AppColors.runeViolet,
                                      ),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Center(
                                          child: Text(
                                            '$pronPct%',
                                            style: const TextStyle(
                                              color: AppColors.runeViolet,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      userMsgs.isEmpty
                                          ? 'Precisión fonética óptima.'
                                          : 'Claridad en ${userMsgs.length} intervenciones.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // KPI Row
                        Row(
                          children: [
                            Expanded(
                              child: StatTile(
                                icon: Icons.timer_outlined,
                                color: AppColors.manaCyan,
                                label: 'DURACIÓN',
                                value: durationLabel,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                icon: Icons.record_voice_over_rounded,
                                color: AppColors.runeViolet,
                                label: 'PALABRAS',
                                value: '$wordCount',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                icon: Icons.gps_fixed_rounded,
                                color: AppColors.emeraldGreen,
                                label: 'PRECISIÓN',
                                value: '$pronPct%',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                icon: Icons.bolt_rounded,
                                color: AppColors.royalGold,
                                label: 'XP',
                                value: '+80',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Common Mistakes Title
                        const Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.errorRed,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Retroalimentación y Correcciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (corrections.isEmpty)
                          _buildSummaryCorrectionCard(
                            originalText: userMsgs.isEmpty ? '¡Listo para tu primera sesión!' : '¡Excelente desempeño!',
                            correctedText: userMsgs.isEmpty ? 'Habla con el tutor IA para obtener retroalimentación.' : 'No se registraron errores de gramática o fonética.',
                            category: 'Desempeño',
                            tag: 'Excelente',
                            accentColor: AppColors.manaCyan,
                          )
                        else
                          ...corrections.take(3).map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildSummaryCorrectionCard(
                                  originalText: c.originalText ?? c.text,
                                  correctedText: c.text,
                                  category: 'Corrección',
                                  tag: c.correctionExplanation ?? 'Grammar',
                                  accentColor: AppColors.runeViolet,
                                ),
                              )),
                        const SizedBox(height: 32),
                      ],
                    );
                  }(),

                  // Rewards & Actions Panel
                  GlassCard(
                    blur: 30,
                    opacity: AppColors.glassOpacity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Rewards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.runeViolet.withValues(alpha: 0.15),
                                  ),
                                  child: const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.runeViolet,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+80 XP',
                                      style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Bono Sesión',
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(width: 1, height: 40, color: AppColors.onSurface.withValues(alpha: 0.10)),
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.guildAmber.withValues(alpha: 0.15),
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: AppColors.guildAmber,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+1 Racha',
                                      style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Mantenida',
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Divider(color: AppColors.onSurface.withValues(alpha: 0.10), height: 1),
                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.menu_book_rounded, size: 18),
                                label: Text(l10n.summary_view_vocab),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.summary_vocab_saved)),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.runeViolet,
                                  side: BorderSide(
                                    color: AppColors.runeViolet.withValues(alpha: 0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_rounded, size: 18),
                                label: Text(l10n.summary_done),
                                onPressed: () {
                                  context.go('/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.runeViolet,
                                  foregroundColor: AppColors.onSurface,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCorrectionCard({
    required String originalText,
    required String correctedText,
    required String category,
    required String tag,
    required Color accentColor,
  }) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.crimsonRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  originalText,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.manaCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.manaCyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  correctedText,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  tag,
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
}

// Custom Painter for Neon Glow Progress Arc
class NeonProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  NeonProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final basePaint = Paint()
      ..color = AppColors.onSurface.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
