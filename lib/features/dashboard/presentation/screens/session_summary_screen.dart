import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/lesson_catalog.dart';
import '../../domain/models/session_learned_summary.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../../../economy/presentation/widgets/session_drop_controller.dart';
import '../../../notifications/presentation/widgets/notification_permission_prompt.dart';
import '../../../vocabulary/presentation/widgets/srs_flashcard_modal.dart';
import '../providers/dashboard_providers.dart';

/// Resumen post-sesión de conversación (issue #113, P-28).
///
/// Todo lo que se muestra viene de datos reales:
/// * Recompensa: `apply_session_rewards` (XP/oro/fragmentos) con estados de
///   confirmación y error accionable.
/// * «Qué aprendiste»: RPC `get_session_learned_summary` (palabras nuevas y
///   repasadas, correcciones y foco recomendado). Si no hay datos, lo dice.
/// * Metas cumplidas/total, duración y turnos de la propia sesión.
///
/// No se calculan porcentajes locales: si falta un dato se muestra «—» o el
/// mensaje explícito de «sin datos suficientes».
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final convState = ref.watch(conversationStateProvider);
    final sessionAsync = ref.watch(sessionResultProvider);
    final sessionResult = sessionAsync.valueOrNull;

    final userMsgs = convState.messages
        .where((m) => m.sender == 'user')
        .toList();
    final wordCount = userMsgs.fold(
      0,
      (sum, m) =>
          sum +
          m.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    );

    // Conversación de esta sesión. `session_id` es el id real cuando la sesión
    // dejó recompensa; si no, se usa el id activo de la conversación.
    final conversationId =
        _uuidOrNull(sessionResult?['session_id']) ??
        _uuidOrNull(ref.watch(activeConversationIdProvider));
    final since = _sessionStart(sessionResult);
    final learnedKey = conversationId == null
        ? null
        : (conversationId: conversationId, since: since);

    final learnedAsync = learnedKey == null
        ? const AsyncValue<LearnedSummaryData>.data(LearnedSummaryData.empty)
        : ref.watch(sessionLearnedSummaryProvider(learnedKey));

    final lesson = LessonCatalog.getLessonById(
      convState.activeScenarioId,
      title: convState.activeScenarioName,
    );

    final view = SessionSummaryView.from(
      sessionResult: sessionResult,
      learned: learnedAsync.valueOrNull ?? LearnedSummaryData.empty,
      inMemoryGoalsCompleted: convState.goalEvaluationResults.values
          .where((v) => v)
          .length,
      inMemoryTurns: userMsgs.length,
      inMemoryWords: wordCount,
      catalogGoalsTotal: lesson?.goals.length,
    );

    void goHome() {
      ref.read(dashboardRefreshProvider.notifier).state++;
      ref.invalidate(userProgressProvider);
      ref.invalidate(skillsRadarProvider);
      ref.invalidate(practiceHeatmapProvider);
      ref.invalidate(fluencyTrendsProvider);
      ref.invalidate(weeklyPracticeProvider);
      ref.invalidate(learnedVocabularyProvider);
      context.go('/home');
    }

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -160,
            left: -160,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            right: -160,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Drop sorpresa de fin de sesión (aplica XP + notificación épica).
          SessionDropController(completedGoals: view.goalsCompleted),

          // Issue #106: tras la primera lecciÃ³n completada se ofrece el
          // recordatorio diario (pantalla previa del permiso Android 13+).
          const NotificationPermissionPrompt(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Cabecera compacta ─────────────────────────────────────
                  Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: goHome,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.session_title,
                          style: AppTypography.title(context),
                        ),
                      ),
                      _StatusPill(
                        label: l10n.session_completed,
                        color: AppColors.runeViolet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Hero: metas cumplidas + resumen real ──────────────────
                  GlassCard(
                    blur: 16,
                    opacity: AppColors.glassOpacity,
                    borderColor: AppColors.manaCyan.withValues(alpha: 0.25),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _CompactRing(
                          value: view.goalsRatio,
                          color: AppColors.emeraldGreen,
                          size: 76,
                          label: view.goalsTotal > 0 ? view.goalsLabel : '—',
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.session_good_job,
                                style: AppTypography.subtitle(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                view.hasSessionData
                                    ? l10n.session_words_spoken(wordCount)
                                    : l10n.session_ready,
                                style: AppTypography.bodyMuted(context),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _MiniTag(
                                    icon: Icons.record_voice_over_rounded,
                                    color: AppColors.runeViolet,
                                    text: l10n.summary_turns_value(
                                      userMsgs.length,
                                    ),
                                  ),
                                  _MiniTag(
                                    icon: Icons.gps_fixed_rounded,
                                    color: AppColors.emeraldGreen,
                                    text: view.goalsTotal > 0
                                        ? view.goalsLabel
                                        : '—',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Cuadrícula 2×2 de métricas reales ─────────────────────
                  _buildMetricsGrid(context, l10n, view),
                  const SizedBox(height: 16),

                  // ── Qué aprendiste ────────────────────────────────────────
                  _buildLearnedCard(
                    context,
                    l10n,
                    view,
                    learnedAsync,
                    onRetry: learnedKey == null
                        ? null
                        : () => ref.invalidate(
                            sessionLearnedSummaryProvider(learnedKey),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ── Recompensas + acciones ────────────────────────────────
                  _buildRewardsCard(
                    context,
                    ref,
                    l10n,
                    view,
                    sessionAsync,
                    onDone: goHome,
                  ),
                  const SizedBox(height: 12),
                  // Continuar con la siguiente lección del nivel (si existe).
                  _buildNextLessonButton(context, l10n, convState),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Metas y métricas ────────────────────────────────────────────────────────

  Widget _buildMetricsGrid(
    BuildContext context,
    AppLocalizations l10n,
    SessionSummaryView view,
  ) {
    final rows = view.metricRows;
    Widget cell(SummaryMetric metric) {
      return Expanded(
        child: _MetricCell(
          icon: _metricIcon(metric.kind),
          color: _metricColor(metric.kind),
          value: _metricValue(l10n, view, metric),
          label: _metricLabel(l10n, metric.kind),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [cell(rows[0]), const SizedBox(width: 10), cell(rows[1])],
        ),
        const SizedBox(height: 10),
        Row(
          children: [cell(rows[2]), const SizedBox(width: 10), cell(rows[3])],
        ),
      ],
    );
  }

  IconData _metricIcon(SummaryMetricKind kind) => switch (kind) {
    SummaryMetricKind.duration => Icons.timer_outlined,
    SummaryMetricKind.words => Icons.abc_rounded,
    SummaryMetricKind.goals => Icons.gps_fixed_rounded,
    SummaryMetricKind.turns => Icons.record_voice_over_rounded,
  };

  Color _metricColor(SummaryMetricKind kind) => switch (kind) {
    SummaryMetricKind.duration => AppColors.manaCyan,
    SummaryMetricKind.words => AppColors.runeViolet,
    SummaryMetricKind.goals => AppColors.emeraldGreen,
    SummaryMetricKind.turns => AppColors.royalGold,
  };

  String _metricLabel(AppLocalizations l10n, SummaryMetricKind kind) =>
      switch (kind) {
        SummaryMetricKind.duration => l10n.session_duration,
        SummaryMetricKind.words => l10n.session_words,
        SummaryMetricKind.goals => l10n.summary_goals,
        SummaryMetricKind.turns => l10n.summary_turns,
      };

  String _metricValue(
    AppLocalizations l10n,
    SessionSummaryView view,
    SummaryMetric metric,
  ) {
    if (metric.kind == SummaryMetricKind.duration && view.minutes > 0) {
      return l10n.summary_learned_minutes_value(view.minutes);
    }
    return metric.value;
  }

  // ── Qué aprendiste ──────────────────────────────────────────────────────────

  Widget _buildLearnedCard(
    BuildContext context,
    AppLocalizations l10n,
    SessionSummaryView view,
    AsyncValue<LearnedSummaryData> learnedAsync, {
    required VoidCallback? onRetry,
  }) {
    return GlassCard(
      blur: 16,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.manaCyan.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.school_rounded,
            color: AppColors.manaCyan,
            text: l10n.summary_learned_title,
          ),
          const SizedBox(height: 14),
          if (learnedAsync.isLoading)
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.summary_learned_loading,
                    style: AppTypography.bodyMuted(context),
                  ),
                ),
              ],
            )
          else if (learnedAsync.hasError)
            _ErrorRow(
              message: l10n.summary_learned_error,
              retryLabel: l10n.summary_retry,
              onRetry: onRetry,
            )
          else
            ..._buildLearnedBody(context, l10n, view),
        ],
      ),
    );
  }

  List<Widget> _buildLearnedBody(
    BuildContext context,
    AppLocalizations l10n,
    SessionSummaryView view,
  ) {
    final words = view.learned.words;
    final corrections = view.learned.corrections;

    return [
      _Label(l10n.summary_learned_words),
      const SizedBox(height: 8),
      if (words.isEmpty)
        Text(
          l10n.summary_learned_no_words,
          style: AppTypography.bodyMuted(context),
        )
      else
        ...words.map((word) => _wordRow(context, l10n, word)),
      const SizedBox(height: 14),
      _divider(),
      const SizedBox(height: 12),
      _Label(l10n.summary_learned_corrections),
      const SizedBox(height: 8),
      if (corrections.isEmpty)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.emeraldGreen,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.summary_learned_no_corrections,
                style: AppTypography.bodyMuted(context),
              ),
            ),
          ],
        )
      else
        ...corrections.map(
          (correction) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildCorrectionCard(context, l10n, correction),
          ),
        ),
      const SizedBox(height: 4),
      _divider(),
      const SizedBox(height: 12),
      _Label(l10n.summary_learned_focus),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            view.learned.hasFocus
                ? Icons.my_location_rounded
                : Icons.hourglass_empty_rounded,
            color: view.learned.hasFocus
                ? AppColors.royalGold
                : AppColors.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              view.learned.hasFocus
                  ? view.learned.focus!
                  : l10n.summary_learned_no_focus,
              style: view.learned.hasFocus
                  ? AppTypography.body(context)
                  : AppTypography.bodyMuted(context),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _wordRow(
    BuildContext context,
    AppLocalizations l10n,
    LearnedWord word,
  ) {
    final color = word.isNew ? AppColors.emeraldGreen : AppColors.manaCyan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.translate_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  word.translation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMuted(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _MiniTag(
            icon: word.isNew ? Icons.add_rounded : Icons.refresh_rounded,
            color: color,
            text: word.isNew
                ? l10n.summary_learned_word_new
                : l10n.summary_learned_word_review,
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionCard(
    BuildContext context,
    AppLocalizations l10n,
    SessionCorrection correction,
  ) {
    return GlassCard(
      blur: 14,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.runeViolet.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _RoundIconButton(
                icon: Icons.close_rounded,
                color: AppColors.errorRed,
                size: 24,
                iconSize: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  correction.original,
                  style: AppTypography.bodyMuted(
                    context,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const _RoundIconButton(
                icon: Icons.arrow_forward_rounded,
                color: AppColors.manaCyan,
                size: 24,
                iconSize: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  correction.corrected,
                  style: AppTypography.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (correction.explanation != null) ...[
            const SizedBox(height: 10),
            Text(
              correction.explanation!,
              style: AppTypography.bodyMuted(context),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _Tag(text: l10n.session_correction, color: AppColors.runeViolet),
              const SizedBox(width: 8),
              Flexible(
                child: _Tag(
                  text: correction.errorType ?? l10n.session_grammar,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recompensa + acciones ───────────────────────────────────────────────────

  Widget _buildRewardsCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    SessionSummaryView view,
    AsyncValue<Map<String, dynamic>?> sessionAsync, {
    required VoidCallback onDone,
  }) {
    final hasWords = view.learned.hasWords;

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.royalGold.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 16,
            runSpacing: 10,
            children: [
              _RewardChip(
                icon: Icons.star_rounded,
                color: AppColors.runeViolet,
                value: view.xpLabel,
                label: 'XP',
              ),
              _RewardChip(
                icon: Icons.monetization_on_rounded,
                color: AppColors.royalGold,
                value: view.goldLabel,
                label: l10n.summary_reward_gold,
              ),
              _RewardChip(
                icon: Icons.auto_awesome_rounded,
                color: AppColors.emeraldGreen,
                value: view.fragmentsLabel,
                label: l10n.summary_reward_fragments,
              ),
            ],
          ),
          if (sessionAsync.isLoading) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.summary_reward_loading,
                    style: AppTypography.bodyMuted(context),
                  ),
                ),
              ],
            ),
          ] else if (sessionAsync.hasError) ...[
            const SizedBox(height: 12),
            _ErrorRow(
              message: l10n.summary_reward_error,
              retryLabel: l10n.summary_retry,
              onRetry: () => ref.read(sessionResultProvider.notifier).retry(),
            ),
          ] else if (!view.rewardApplied) ...[
            const SizedBox(height: 12),
            Text(
              l10n.summary_reward_pending,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted(context),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(l10n.summary_retry),
                onPressed: () =>
                    ref.read(sessionResultProvider.notifier).retry(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: Text(
                    l10n.summary_review_words,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Sin palabras reales no se abre un repaso vacío.
                  onPressed: hasWords
                      ? () => SrsFlashcardModal.show(context, view.srsItems)
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.runeViolet,
                    side: BorderSide(
                      color: AppColors.runeViolet.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(l10n.summary_done),
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.runeViolet,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Botón "Siguiente lección": navega a la próxima lección del mismo nivel
  /// CEFR. Si no existe, no se pinta (criterio del issue #113).
  Widget _buildNextLessonButton(
    BuildContext context,
    AppLocalizations l10n,
    dynamic convState,
  ) {
    final scenarioId = convState?.activeScenarioId as String?;
    if (scenarioId == null || scenarioId.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = LessonCatalog.getLessonById(
      scenarioId,
      title: convState?.activeScenarioName as String?,
    );
    if (current == null) return const SizedBox.shrink();

    final levelLessons = LessonCatalog.catalog
        .where((l) => l.level.toUpperCase() == current.level.toUpperCase())
        .toList();
    final idx = levelLessons.indexWhere((l) => l.id == current.id);
    if (idx < 0 || idx >= levelLessons.length - 1) {
      return const SizedBox.shrink();
    }

    final next = levelLessons[idx + 1];

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(
          '${l10n.summary_next_lesson}: ${next.title}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () => context.push(
          '/conversation?scenarioId=${next.id}&scenarioTitle=${Uri.encodeComponent(next.title)}',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldGreen,
          foregroundColor: AppColors.voidBg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(color: AppColors.onSurface.withValues(alpha: 0.08), height: 1);
}

/// Inicio de la sesión: lo persiste el cierre de la conversación. Si el resumen
/// se abrió sin sesión previa, se usa una ventana conservadora de 3 horas.
DateTime _sessionStart(Map<String, dynamic>? sessionResult) {
  final raw = sessionResult?['started_at'];
  if (raw is String) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;
  }
  return DateTime.now().subtract(const Duration(hours: 3));
}

/// Solo se consulta la RPC con un id de conversación real (uuid). Las sesiones
/// locales (`local_...`) y los ids sintéticos de recompensa no existen en BD.
String? _uuidOrNull(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  final isUuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(trimmed);
  return isUuid ? trimmed : null;
}

// ── Sub-widgets compactos ─────────────────────────────────────────────────────

/// Título de sección (icono + texto).
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _SectionTitle({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTypography.title(context))),
      ],
    );
  }
}

/// Etiqueta mono en mayúsculas.
class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.label(context));
  }
}

/// Fila de error accionable con botón de reintento.
class _ErrorRow extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  const _ErrorRow({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.errorRed,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: AppTypography.bodyMuted(context))),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text(retryLabel)),
      ],
    );
  }
}

/// Pill de etiqueta pequeño.
class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      constraints: const BoxConstraints(maxWidth: 220),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.tiny(
          context,
        ).copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Botón redondo compacto para cabeceras y chips.
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;

  const _RoundIconButton({
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: AppColors.onSurface.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              color: color ?? AppColors.onSurface,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill compacto de estado (p.ej. "SESIÓN COMPLETADA").
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.tiny(context).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Anillo compacto de progreso (hero).
class _CompactRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final String label;

  const _CompactRing({
    required this.value,
    required this.color,
    required this.size,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: NeonProgressPainter(progress: value, color: color),
        child: Center(
          child: Text(
            label,
            style: AppTypography.stat(
              context,
            ).copyWith(color: color, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

/// Celda de métrica compacta (icono pequeño + valor + etiqueta).
class _MetricCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _MetricCell({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppRadius.sm,
      borderColor: color.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(context).copyWith(
                    color: AppColors.onSurface,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.tiny(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip compacto de recompensa.
class _RewardChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _RewardChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.subtitle(context).copyWith(fontSize: 15),
            ),
            Text(label, style: AppTypography.tiny(context)),
          ],
        ),
      ],
    );
  }
}

/// Mini etiqueta con icono (hero).
class _MiniTag extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _MiniTag({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: AppTypography.tiny(context).copyWith(color: color)),
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
      ..strokeWidth = 6;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
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
