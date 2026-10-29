/// P-30 (#115) — Comprensión auditiva.
///
/// Modelos del banco de ítems (`public.listening_exercises`) y del intento
/// corregido por el servidor (`submit_listening_attempt`). Son modelos puros:
/// no dependen de Flutter ni de Supabase para poder probarse sin entorno.
library;

class ListeningLine {
  const ListeningLine({required this.speaker, required this.text});

  final String speaker;
  final String text;

  factory ListeningLine.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return ListeningLine(
      speaker: (map['speaker'] as String?)?.trim() ?? '',
      text: (map['text'] as String?)?.trim() ?? '',
    );
  }

  /// Texto que se envía al TTS: nombre del hablante + frase. Sin el nombre, el
  /// alumno no puede atribuir cada intervención en un diálogo.
  String get spoken => speaker.isEmpty ? text : '$speaker says: $text';
}

class ListeningOption {
  const ListeningOption({required this.id, required this.text});

  final String id;
  final String text;

  factory ListeningOption.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return ListeningOption(
      id: (map['id'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
    );
  }
}

class ListeningQuestion {
  const ListeningQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    this.explanation = '',
  });

  final String id;
  final String prompt;
  final List<ListeningOption> options;

  /// Respuesta correcta que publica el servidor. La corrección autoritativa la
  /// hace `submit_listening_attempt`; aquí solo sirve para el feedback
  /// inmediato y para validar el contenido sembrado en los tests.
  final String correctOptionId;
  final String explanation;

  factory ListeningQuestion.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    final options = (map['options'] as List? ?? const [])
        .map(ListeningOption.fromMap)
        .where((o) => o.id.isNotEmpty)
        .toList(growable: false);
    return ListeningQuestion(
      id: (map['id'] as String?) ?? '',
      prompt: (map['prompt'] as String?) ?? '',
      options: options,
      correctOptionId: (map['correct'] as String?) ?? '',
      explanation: (map['explanation'] as String?) ?? '',
    );
  }

  /// El ítem sembrado es jugable: tiene al menos dos opciones y la respuesta
  /// correcta existe entre ellas.
  bool get isWellFormed =>
      id.isNotEmpty &&
      prompt.isNotEmpty &&
      options.length >= 2 &&
      options.any((o) => o.id == correctOptionId);

  String get correctOptionText {
    for (final option in options) {
      if (option.id == correctOptionId) return option.text;
    }
    return '';
  }
}

class ListeningExercise {
  const ListeningExercise({
    required this.id,
    required this.slug,
    required this.level,
    required this.title,
    this.context = '',
    this.lines = const [],
    this.questions = const [],
    this.sortOrder = 0,
  });

  final String id;
  final String slug;
  final String level;
  final String title;
  final String context;
  final List<ListeningLine> lines;
  final List<ListeningQuestion> questions;
  final int sortOrder;

  factory ListeningExercise.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return ListeningExercise(
      id: (map['id'] as String?) ?? '',
      slug: (map['slug'] as String?) ?? '',
      level: ((map['level'] as String?) ?? '').toUpperCase(),
      title: (map['title'] as String?) ?? '',
      context: (map['context'] as String?) ?? '',
      lines: (map['lines'] as List? ?? const [])
          .map(ListeningLine.fromMap)
          .where((l) => l.text.isNotEmpty)
          .toList(growable: false),
      questions: (map['questions'] as List? ?? const [])
          .map(ListeningQuestion.fromMap)
          .toList(growable: false),
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isPlayable =>
      id.isNotEmpty &&
      slug.isNotEmpty &&
      lines.isNotEmpty &&
      questions.isNotEmpty &&
      questions.every((q) => q.isWellFormed);

  /// Texto completo del diálogo para la transcripción opcional y para el TTS
  /// cuando el motor no admite lecturas encadenadas.
  String get transcript => lines.map((l) => l.text).join(' ');

  /// Identificador con el que el servidor registra el progreso en
  /// `lesson_progress` (mismo formato que `submit_listening_attempt`).
  String get lessonId => 'listening:$slug';
}

/// Resultado de una pregunta según el servidor (incluye la respuesta correcta
/// solo después de corregir).
class ListeningQuestionResult {
  const ListeningQuestionResult({
    required this.id,
    required this.isCorrect,
    required this.correctOptionId,
    this.explanation = '',
  });

  final String id;
  final bool isCorrect;
  final String correctOptionId;
  final String explanation;

  factory ListeningQuestionResult.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return ListeningQuestionResult(
      id: (map['id'] as String?) ?? '',
      isCorrect: map['correct'] == true,
      correctOptionId: (map['answer'] as String?) ?? '',
      explanation: (map['explanation'] as String?) ?? '',
    );
  }
}

/// Respuesta de `submit_listening_attempt`.
class ListeningAttemptResult {
  const ListeningAttemptResult({
    required this.ok,
    this.reason,
    this.score = 0,
    this.total = 0,
    this.passed = false,
    this.results = const [],
    this.missionsAdvanced = 0,
    this.minutesAdded = 0,
    this.practiceAlreadyRegistered = false,
  });

  final bool ok;
  final String? reason;
  final int score;
  final int total;
  final bool passed;
  final List<ListeningQuestionResult> results;
  final int missionsAdvanced;
  final int minutesAdded;
  final bool practiceAlreadyRegistered;

  factory ListeningAttemptResult.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    final practice = map['practice'] is Map
        ? Map<String, dynamic>.from(map['practice'] as Map)
        : const <String, dynamic>{};
    return ListeningAttemptResult(
      ok: map['ok'] == true,
      reason: map['reason'] as String?,
      score: (map['score'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
      passed: map['passed'] == true,
      results: (map['results'] as List? ?? const [])
          .map(ListeningQuestionResult.fromMap)
          .toList(growable: false),
      missionsAdvanced: (map['missions_advanced'] as num?)?.toInt() ?? 0,
      minutesAdded: (practice['minutes_added'] as num?)?.toInt() ?? 0,
      practiceAlreadyRegistered: practice['already_registered'] == true,
    );
  }

  /// El servidor respondió pero rechazó el intento (ejercicio inexistente,
  /// inactivo o vacío). El progreso no se guardó.
  String get reasonMessage {
    switch (reason) {
      case 'unauthorized':
        return 'Tu sesión no está autenticada: vuelve a iniciar sesión para guardar el progreso.';
      case 'exercise_not_found':
        return 'Este ejercicio ya no está disponible. Vuelve a la Ruta y elige otro.';
      case 'exercise_empty':
        return 'Este ejercicio no tiene preguntas configuradas. Avisa al equipo de contenido.';
      default:
        return 'El servidor no pudo corregir el intento. Inténtalo de nuevo.';
    }
  }
}

/// Mejor marca del jugador en un ejercicio (derivada de `listening_attempts`).
class ListeningExerciseProgress {
  const ListeningExerciseProgress({
    required this.exerciseId,
    required this.bestScore,
    required this.total,
    required this.passed,
    required this.attempts,
  });

  final String exerciseId;
  final int bestScore;
  final int total;
  final bool passed;
  final int attempts;
}

/// Progreso agregado por ejercicio. Se calcula con las filas devueltas por la
/// política `listening_attempts_select_own` (solo las del propio usuario).
class ListeningProgress {
  const ListeningProgress({this.byExerciseId = const {}});

  final Map<String, ListeningExerciseProgress> byExerciseId;

  factory ListeningProgress.fromAttempts(List<Map<String, dynamic>> rows) {
    final best = <String, ListeningExerciseProgress>{};
    for (final row in rows) {
      final exerciseId = (row['exercise_id'] as String?) ?? '';
      if (exerciseId.isEmpty) continue;
      final score = (row['score'] as num?)?.toInt() ?? 0;
      final total = (row['total'] as num?)?.toInt() ?? 0;
      final passed = row['passed'] == true;
      final previous = best[exerciseId];
      if (previous == null) {
        best[exerciseId] = ListeningExerciseProgress(
          exerciseId: exerciseId,
          bestScore: score,
          total: total,
          passed: passed,
          attempts: 1,
        );
      } else {
        best[exerciseId] = ListeningExerciseProgress(
          exerciseId: exerciseId,
          bestScore: score > previous.bestScore ? score : previous.bestScore,
          total: total > previous.total ? total : previous.total,
          passed: previous.passed || passed,
          attempts: previous.attempts + 1,
        );
      }
    }
    return ListeningProgress(byExerciseId: Map.unmodifiable(best));
  }

  bool isPassed(String exerciseId) => byExerciseId[exerciseId]?.passed ?? false;

  ListeningExerciseProgress? forExercise(String exerciseId) =>
      byExerciseId[exerciseId];

  /// Ejercicios del nivel ya superados (para la tarjeta de la Ruta).
  int passedCount(Iterable<ListeningExercise> exercises) =>
      exercises.where((e) => isPassed(e.id)).length;

  /// Siguiente ejercicio recomendado: el primero no superado; si ya están
  /// todos, el primero (repaso).
  ListeningExercise? nextOf(Iterable<ListeningExercise> exercises) {
    final ordered = exercises.toList(growable: false);
    if (ordered.isEmpty) return null;
    for (final exercise in ordered) {
      if (!isPassed(exercise.id)) return exercise;
    }
    return ordered.first;
  }
}
