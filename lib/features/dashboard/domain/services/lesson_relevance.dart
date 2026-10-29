/// P-40 (#125) — Relevancia de una lección para el alumno.
///
/// El catálogo llega filtrado por nivel e idioma; este orden decide cuál se
/// ofrece primero. Antes solo miraba `category` y únicamente cuando
/// `user_settings.interests` tenía datos (que en producción está vacío), así
/// que la personalización nunca llegaba a la pantalla.
///
/// Función pura y sin red para poder compararse en tests.
library;

class LessonRelevance {
  const LessonRelevance._();

  /// Cuántos intereses del alumno aparecen en la categoría, el título o la
  /// descripción del escenario.
  static int interestHits(
    Map<String, dynamic> scenario,
    List<String> interests,
  ) {
    if (interests.isEmpty) return 0;
    final haystack = [
      scenario['category'],
      scenario['title'],
      scenario['description'],
    ].whereType<String>().join(' ').toLowerCase();
    if (haystack.trim().isEmpty) return 0;
    return interests
        .map((i) => i.trim().toLowerCase())
        .where((i) => i.isNotEmpty && haystack.contains(i))
        .length;
  }

  /// Ordena `scenarios` in place: primero los que tocan más intereses y, a
  /// igualdad, los que se acercan más a la meta diaria de minutos.
  ///
  /// El desempate final por título lo hace determinista (los tests y la UI no
  /// dependen del orden de llegada de PostgREST).
  static void sortForUser(
    List<Map<String, dynamic>> scenarios, {
    required List<String> interests,
    required int dailyGoalMinutes,
  }) {
    scenarios.sort((a, b) {
      final byInterest = interestHits(
        b,
        interests,
      ).compareTo(interestHits(a, interests));
      if (byInterest != 0) return byInterest;

      final aMins = (a['estimated_minutes'] as num?)?.toInt() ?? 15;
      final bMins = (b['estimated_minutes'] as num?)?.toInt() ?? 15;
      final byMinutes = (aMins - dailyGoalMinutes).abs().compareTo(
        (bMins - dailyGoalMinutes).abs(),
      );
      if (byMinutes != 0) return byMinutes;

      final aTitle = (a['title'] as String?) ?? '';
      final bTitle = (b['title'] as String?) ?? '';
      return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
    });
  }
}
