import '../models/listening_exercise.dart';
import '../services/listening_grading.dart';

/// Fase del reproductor de comprensión auditiva.
enum ListeningSessionPhase { answering, submitting, graded, failed }

/// Máquina de estados del ejercicio (lógica pura, sin widgets).
///
/// Secuencia: `answering` → (todas respondidas) → `submitting` →
/// `graded` | `failed`. Un fallo de red deja el intento intacto para reintentar
/// sin perder las respuestas.
class ListeningSession {
  const ListeningSession({
    required this.exercise,
    this.index = 0,
    this.answers = const {},
    this.phase = ListeningSessionPhase.answering,
    this.result,
    this.error,
  });

  final ListeningExercise exercise;
  final int index;
  final Map<String, String> answers;
  final ListeningSessionPhase phase;
  final ListeningAttemptResult? result;
  final String? error;

  int get total => exercise.questions.length;

  ListeningQuestion? get current =>
      index >= 0 && index < total ? exercise.questions[index] : null;

  bool get isFirst => index <= 0;

  bool get isLast => index >= total - 1;

  int get answeredCount => answers.length;

  String? answerFor(String questionId) => answers[questionId];

  /// Todas las preguntas tienen respuesta: se puede enviar.
  bool get isComplete =>
      total > 0 &&
      exercise.questions.every((q) => (answers[q.id] ?? '').trim().isNotEmpty);

  bool get isEditing => phase == ListeningSessionPhase.answering;

  bool get canSubmit => isEditing && isComplete;

  ListeningGrade get localGrade =>
      ListeningGrading.evaluate(exercise: exercise, answers: answers);

  ListeningSession select(String optionId) {
    final question = current;
    if (!isEditing || question == null || optionId.isEmpty) return this;
    return _copyWith(answers: {...answers, question.id: optionId});
  }

  ListeningSession next() {
    if (!isEditing || isLast) return this;
    if ((answers[current?.id ?? ''] ?? '').isEmpty) return this;
    return _copyWith(index: index + 1);
  }

  ListeningSession previous() {
    if (!isEditing || isFirst) return this;
    return _copyWith(index: index - 1);
  }

  ListeningSession startSubmitting() {
    if (!canSubmit) return this;
    return _copyWith(phase: ListeningSessionPhase.submitting, clearError: true);
  }

  ListeningSession resolve(ListeningAttemptResult attempt) {
    if (attempt.ok) {
      return _copyWith(phase: ListeningSessionPhase.graded, result: attempt);
    }
    return _copyWith(
      phase: ListeningSessionPhase.failed,
      result: attempt,
      error: attempt.reasonMessage,
    );
  }

  /// Error de red (la RPC no respondió): se puede reintentar con las mismas
  /// respuestas.
  ListeningSession fail(String message) {
    return _copyWith(phase: ListeningSessionPhase.failed, error: message);
  }

  /// Vuelve a `answering`. `keepAnswers` conserva las respuestas del intento
  /// fallido (solo se usa tras un error de red).
  ListeningSession retry({bool keepAnswers = true}) {
    return ListeningSession(
      exercise: exercise,
      index: keepAnswers ? index.clamp(0, total > 0 ? total - 1 : 0) : 0,
      answers: keepAnswers ? answers : const {},
      phase: ListeningSessionPhase.answering,
    );
  }

  ListeningSession _copyWith({
    int? index,
    Map<String, String>? answers,
    ListeningSessionPhase? phase,
    ListeningAttemptResult? result,
    String? error,
    bool clearError = false,
  }) {
    return ListeningSession(
      exercise: exercise,
      index: index ?? this.index,
      answers: answers ?? this.answers,
      phase: phase ?? this.phase,
      result: result ?? this.result,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
