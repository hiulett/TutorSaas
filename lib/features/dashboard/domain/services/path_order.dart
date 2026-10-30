/// P-40a (#220) — Orden de la Ruta según la ruta recomendada del servidor.
///
/// Función pura: recibe las lecciones que la pantalla ya tiene y los pasos que
/// devolvió `refresh_recommended_path`, y devuelve la misma lista ordenada.
/// Si la ruta viene vacía o no reconoce ninguna lección, devuelve el orden
/// original (fallback explícito, sin inventar contenido).
///
/// No muta la lista de entrada y mantiene el orden relativo del catálogo para
/// las lecciones que la ruta no mencione.
library;

import '../../data/models/lesson_catalog.dart';
import '../models/recommended_path.dart';

class PathOrder {
  const PathOrder._();

  /// Posición de las lecciones que la ruta no menciona: siempre después de las
  /// reconocidas y conservando su orden original.
  static const int _unranked = 1 << 20;

  /// Aplica [path] sobre [lessons].
  ///
  /// Reconoce la lección por `id` (cuando coincide con `lesson_key`) y por
  /// `level` + `title` (los títulos del catálogo y de `scenarios` coinciden 1:1,
  /// verificado en producción).
  static List<LessonData> apply(
    List<LessonData> lessons,
    List<RecommendedPathStep> path,
  ) {
    if (lessons.isEmpty || path.isEmpty) {
      return List<LessonData>.of(lessons);
    }

    final byId = <String, int>{};
    final byTitle = <String, int>{};
    for (final step in path) {
      final key = step.lessonKey?.trim();
      if (key != null && key.isNotEmpty) {
        byId.putIfAbsent(key.toLowerCase(), () => step.position);
      }
      byTitle.putIfAbsent(
        _titleKey(step.level, step.title),
        () => step.position,
      );
    }

    final ranked = lessons.asMap().entries.toList();
    ranked.sort((a, b) {
      final rankA = _rank(a.value, byId, byTitle);
      final rankB = _rank(b.value, byId, byTitle);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return a.key.compareTo(b.key);
    });
    return List<LessonData>.unmodifiable(ranked.map((e) => e.value));
  }

  /// Posición del primer paso recomendado que aún no está superado, o `null`
  /// si la ruta está vacía. La usa la CTA de "continuar aventura".
  static LessonData? firstRecommended(
    List<LessonData> lessons,
    List<RecommendedPathStep> path, {
    bool Function(LessonData lesson)? isCompleted,
  }) {
    if (lessons.isEmpty || path.isEmpty) return null;
    final ordered = apply(lessons, path);
    for (final lesson in ordered) {
      final done = isCompleted?.call(lesson) ?? false;
      if (!done) return lesson;
    }
    return ordered.isEmpty ? null : ordered.first;
  }

  static int _rank(
    LessonData lesson,
    Map<String, int> byId,
    Map<String, int> byTitle,
  ) {
    final id = lesson.id.trim().toLowerCase();
    final byLessonId = byId[id];
    if (byLessonId != null) return byLessonId;
    final byLessonTitle = byTitle[_titleKey(lesson.level, lesson.title)];
    if (byLessonTitle != null) return byLessonTitle;
    return _unranked;
  }

  static String _titleKey(String level, String title) =>
      '${level.trim().toUpperCase()}|${title.trim().toLowerCase()}';
}
