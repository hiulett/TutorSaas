import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../missions/presentation/providers/mission_providers.dart';
import '../../data/listening_repository.dart';
import '../../data/listening_tts.dart';
import '../../domain/models/listening_exercise.dart';
import '../../domain/models/listening_session.dart';
import '../providers/listening_providers.dart';

/// P-30 (#115) — Comprensión auditiva.
///
/// El alumno escucha un diálogo generado con `flutter_tts` (coste de IA 0) y
/// responde preguntas de opción múltiple. Las respuestas se envían a la RPC
/// `submit_listening_attempt`, que corrige, guarda el intento, escribe
/// `lesson_progress` y avanza la misión `listening_items`. El cliente nunca
/// escribe progreso.
class ListeningQuizScreen extends ConsumerStatefulWidget {
  const ListeningQuizScreen({super.key, required this.exerciseId});

  /// `slug` del ejercicio (`listening_exercises.slug`).
  final String exerciseId;

  @override
  ConsumerState<ListeningQuizScreen> createState() =>
      _ListeningQuizScreenState();
}

class _ListeningQuizScreenState extends ConsumerState<ListeningQuizScreen> {
  final Stopwatch _stopwatch = Stopwatch();

  ListeningAudio _audio = const _SilentAudio();
  ListeningExercise? _exercise;
  ListeningSession? _session;
  String? _loadError;
  bool _isLoading = true;
  bool _showTranscript = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(listeningAudioProvider);
    _load();
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final exercise = await ref
          .read(listeningRepositoryProvider)
          .loadBySlug(widget.exerciseId);
      if (!mounted) return;
      if (exercise == null) {
        setState(() {
          _isLoading = false;
          _loadError = _fallbackLoadError();
          _exercise = null;
          _session = null;
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _exercise = exercise;
        _session = ListeningSession(exercise: exercise);
      });
      _stopwatch
        ..reset()
        ..start();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e is ListeningException ? e.message : _fallbackLoadError();
      });
    }
  }

  String _fallbackLoadError() =>
      AppLocalizations.of(context)?.listening_error_load ??
      'We could not load this exercise. Check your connection and try again.';

  Future<void> _toggleAudio() async {
    final exercise = _exercise;
    if (exercise == null) return;
    if (_isPlaying) {
      await _audio.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _audio.play(exercise.lines);
    if (mounted) setState(() => _isPlaying = false);
  }

  void _select(String optionId) {
    final session = _session;
    if (session == null) return;
    setState(() => _session = session.select(optionId));
  }

  void _goNext() {
    final session = _session;
    if (session == null) return;
    setState(() => _session = session.next());
  }

  void _goPrevious() {
    final session = _session;
    if (session == null) return;
    setState(() => _session = session.previous());
  }

  Future<void> _submit() async {
    final current = _session;
    if (current == null) return;
    if (current.phase == ListeningSessionPhase.submitting) return;

    // Tras un fallo se conservan las respuestas y se reenvía el mismo intento.
    final ready = current.phase == ListeningSessionPhase.failed
        ? current.retry()
        : current;
    if (!ready.isComplete) return;

    setState(() => _session = ready.startSubmitting());
    final pending = _session;
    if (pending == null) return;

    final minutes = _stopwatch.elapsed.inMinutes < 1
        ? 1
        : _stopwatch.elapsed.inMinutes;
    try {
      final result = await ref
          .read(listeningRepositoryProvider)
          .submit(
            exerciseId: pending.exercise.id,
            answers: pending.answers,
            minutes: minutes,
            tzOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
          );
      if (!mounted) return;
      setState(() => _session = pending.resolve(result));
      if (result.ok) {
        // El progreso y las misiones ya cambiaron en el servidor: refresca las
        // tarjetas que lo muestran al volver a la Ruta.
        ref.invalidate(listeningProgressProvider);
        ref.invalidate(activeMissionsProvider);
        ref.invalidate(dailyMissionsProvider);
        ref.invalidate(missionSpotlightProvider);
      }
    } catch (e) {
      if (!mounted) return;
      final message = e is ListeningException
          ? e.message
          : 'No pudimos guardar el resultado: $e';
      setState(() => _session = pending.fail(message));
    }
  }

  void _retry() {
    final session = _session;
    if (session == null) return;
    setState(() {
      _session = session.retry(keepAnswers: false);
      _showTranscript = false;
    });
    _stopwatch
      ..reset()
      ..start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exercise = _exercise;
    final session = _session;

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(listeningAudioProvider).stop();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.medievalText,
                        size: 18,
                      ),
                      tooltip: l10n?.back ?? 'Back',
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n?.listening_path_title ?? 'LISTENING',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.medievalText,
                        ),
                      ),
                    ),
                    if (exercise != null) _LevelChip(label: exercise.level),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.manaCyan,
                          strokeWidth: 2,
                        ),
                      )
                    : _loadError != null
                    ? _LoadErrorState(
                        message: _loadError!,
                        retryLabel: l10n?.my_errors_retry ?? 'RETRY',
                        onRetry: _load,
                      )
                    : (exercise == null || session == null)
                    ? Center(
                        child: Text(
                          l10n?.listening_empty ??
                              'No listening exercises for this level yet.',
                          style: const TextStyle(
                            color: AppColors.medievalTextDim,
                          ),
                        ),
                      )
                    : _buildBody(context, l10n, exercise, session),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations? l10n,
    ListeningExercise exercise,
    ListeningSession session,
  ) {
    final result = session.result;
    final isGraded =
        session.phase == ListeningSessionPhase.graded &&
        result != null &&
        result.ok;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text(
          exercise.title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        if (exercise.context.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            exercise.context,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: AppColors.medievalTextDim,
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Reproductor: el audio lo sintetiza el dispositivo (sin IA).
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RunicButton(
                label: _isPlaying
                    ? (l10n?.listening_stop ?? 'STOP')
                    : (isGraded
                          ? (l10n?.listening_play_again ?? 'LISTEN AGAIN')
                          : (l10n?.listening_play ?? 'PLAY DIALOGUE')),
                icon: _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                backgroundColor: _isPlaying
                    ? AppColors.crimsonRed
                    : AppColors.manaCyan,
                foregroundColor: AppColors.voidBg,
                onPressed: _toggleAudio,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _showTranscript = !_showTranscript),
                icon: Icon(
                  _showTranscript
                      ? Icons.visibility_off_rounded
                      : Icons.subtitles_rounded,
                  size: 16,
                  color: AppColors.medievalTextDim,
                ),
                label: Text(
                  _showTranscript
                      ? (l10n?.listening_transcript_hide ?? 'HIDE TRANSCRIPT')
                      : (l10n?.listening_transcript_show ?? 'SHOW TRANSCRIPT'),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.6,
                    color: AppColors.medievalTextDim,
                  ),
                ),
              ),
              if (_showTranscript) ...[
                const Divider(height: 12, color: AppColors.outlineVariant),
                ...exercise.lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: '${line.speaker}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.manaCyan,
                            ),
                          ),
                          TextSpan(text: line.text),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (session.phase == ListeningSessionPhase.failed)
          _NetworkErrorPanel(
            message:
                session.error ??
                result?.reasonMessage ??
                (l10n?.listening_error_load ??
                    'We could not save your result.'),
            retryLabel: l10n?.listening_retry_send ?? 'RETRY SEND',
            onRetry: _submit,
          )
        else if (isGraded)
          _ResultPanel(
            l10n: l10n,
            session: session,
            result: result,
            onRetry: _retry,
          )
        else
          _QuestionFlow(
            l10n: l10n,
            session: session,
            onSelect: _select,
            onNext: _goNext,
            onPrevious: _goPrevious,
            onSubmit: _submit,
          ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.runeViolet.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: AppColors.runeVioletText,
        ),
      ),
    );
  }
}

class _QuestionFlow extends StatelessWidget {
  const _QuestionFlow({
    required this.l10n,
    required this.session,
    required this.onSelect,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  final AppLocalizations? l10n;
  final ListeningSession session;
  final ValueChanged<String> onSelect;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final question = session.current;
    final isSubmitting = session.phase == ListeningSessionPhase.submitting;
    final selected = question == null ? null : session.answerFor(question.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n?.listening_question_counter(
                      session.index + 1,
                      session.total,
                    ) ??
                    'QUESTION ${session.index + 1} OF ${session.total}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppColors.manaCyan,
                ),
              ),
            ),
            Text(
              '${session.answeredCount}/${session.total}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.medievalTextDim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: session.total == 0
                ? 0
                : session.answeredCount / session.total,
            minHeight: 4,
            backgroundColor: AppColors.onSurface.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.manaCyan),
          ),
        ),
        const SizedBox(height: 16),
        if (question != null) ...[
          Text(
            question.prompt,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.map((option) {
            final isSelected = option.id == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.manaCyan
                      : AppColors.onSurface.withValues(alpha: 0.1),
                  width: isSelected ? 1.5 : 1,
                ),
                onTap: isSubmitting ? null : () => onSelect(option.id),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isSelected
                          ? AppColors.manaCyan
                          : AppColors.medievalTextDim,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: isSelected
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: session.isFirst || isSubmitting ? null : onPrevious,
                child: Text(
                  l10n?.listening_previous ?? 'BACK',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: session.isLast || isSubmitting
                  ? RunicButton(
                      label: isSubmitting
                          ? (l10n?.listening_submitting ?? 'CHECKING...')
                          : (l10n?.listening_submit ?? 'CHECK ANSWERS'),
                      icon: Icons.fact_check_rounded,
                      backgroundColor: AppColors.emeraldGreen,
                      foregroundColor: AppColors.voidBg,
                      isBusy: isSubmitting,
                      onPressed: session.canSubmit ? onSubmit : null,
                    )
                  : RunicButton(
                      label: l10n?.listening_next ?? 'NEXT',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: (selected == null || selected.isEmpty)
                          ? null
                          : onNext,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.l10n,
    required this.session,
    required this.result,
    required this.onRetry,
  });

  final AppLocalizations? l10n;
  final ListeningSession session;
  final ListeningAttemptResult result;
  final VoidCallback onRetry;

  static bool? _correctnessFor(
    ListeningAttemptResult result,
    String questionId,
  ) {
    for (final item in result.results) {
      if (item.id == questionId) return item.isCorrect;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final accent = result.passed ? AppColors.emeraldGreen : AppColors.royalGold;
    final headline = result.passed
        ? (l10n?.listening_result_passed ?? 'EXERCISE PASSED')
        : (l10n?.listening_result_failed ?? 'NOT YET');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
          child: Column(
            children: [
              Icon(
                result.passed
                    ? Icons.military_tech_rounded
                    : Icons.replay_rounded,
                color: accent,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n?.listening_result_score(result.score, result.total) ??
                    '${result.score} of ${result.total} correct',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (result.missionsAdvanced > 0) ...[
                const SizedBox(height: 6),
                Text(
                  l10n?.listening_result_missions(result.missionsAdvanced) ??
                      '+${result.missionsAdvanced} mission progress',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.manaCyan,
                  ),
                ),
              ],
              if (result.minutesAdded > 0) ...[
                const SizedBox(height: 2),
                Text(
                  l10n?.listening_result_practice(result.minutesAdded) ??
                      '${result.minutesAdded} min of practice registered',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.medievalTextDim,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...session.exercise.questions.map((question) {
          final isCorrect =
              _correctnessFor(result, question.id) ??
              session.localGrade.isCorrect(question.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 16,
                        color: isCorrect
                            ? AppColors.emeraldGreen
                            : AppColors.crimsonRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.prompt,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n?.listening_explanation(question.correctOptionText) ??
                          'Correct answer: ${question.correctOptionText}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.royalGold,
                      ),
                    ),
                    if (question.explanation.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        question.explanation,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: AppColors.medievalTextDim,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded, size: 16),
                label: Text(
                  l10n?.listening_result_retry ?? 'REPEAT',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RunicButton(
                label: l10n?.listening_back_path ?? 'BACK TO THE PATH',
                icon: Icons.map_rounded,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NetworkErrorPanel extends StatelessWidget {
  const _NetworkErrorPanel({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          RunicButton(
            label: retryLabel,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _LoadErrorState extends StatelessWidget {
  const _LoadErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.medievalTextDim,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            RunicButton(
              label: retryLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Doble neutro para el hueco entre `initState` y la lectura del provider:
/// nunca se usa en producción (el provider devuelve [ListeningTts]).
class _SilentAudio implements ListeningAudio {
  const _SilentAudio();

  @override
  Future<void> play(List<ListeningLine> lines) async {}

  @override
  Future<void> stop() async {}
}
