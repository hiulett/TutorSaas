import '../../../dashboard/domain/models/lesson_completion.dart';
import '../models/listening_exercise.dart';

/// Puntuación de un intento de comprensión auditiva.
class ListeningGrade {
  const ListeningGrade({
    required this.score,
    required this.total,
    required this.correctness,
  });

  final int score;
  final int total;

  /// `questionId -> acertada`. Las preguntas sin responder no aparecen.
  final Map<String, bool> correctness;

  double get ratio => LessonCompletion.ratio(score, total);

  /// Misma regla que el resto de lecciones (P-38 / #123). El servidor usa
  /// `lesson_completion_passed` con los mismos números.
  bool get passed => LessonCompletion.isPassed(score, total);

  /// 0 si no se supera; 3 con todo correcto; 2 desde el 75 %.
  int get stars {
    if (!passed) return 0;
    if (total > 0 && score >= total) return 3;
    if (ratio >= LessonCompletion.passThreshold) return 2;
    return 1;
  }

  bool isCorrect(String questionId) => correctness[questionId] ?? false;
}

/// Corrección local del intento.
///
/// Es la misma regla que aplica `public.submit_listening_attempt` en el
/// servidor: una respuesta cuenta si existe y coincide exactamente con
/// `questions[].correct`; las preguntas sin responder cuentan como falladas.
/// El servidor es la fuente autoritativa del progreso: si su resultado difiere
/// (contenido actualizado entre la descarga y el envío), la UI muestra el del
/// servidor, porque es el que queda registrado en `listening_attempts` y
/// `lesson_progress`.
class ListeningGrading {
  const ListeningGrading._();

  static ListeningGrade evaluate({
    required ListeningExercise exercise,
    required Map<String, String> answers,
  }) {
    final correctness = <String, bool>{};
    var score = 0;
    for (final question in exercise.questions) {
      final given = answers[question.id]?.trim();
      final isCorrect =
          given != null &&
          given.isNotEmpty &&
          given == question.correctOptionId;
      correctness[question.id] = isCorrect;
      if (isCorrect) score++;
    }
    return ListeningGrade(
      score: score,
      total: exercise.questions.length,
      correctness: Map.unmodifiable(correctness),
    );
  }
}
