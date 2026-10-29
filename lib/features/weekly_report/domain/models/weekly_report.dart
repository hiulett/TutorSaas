/// P-43 (#128) — informe semanal de progreso.
///
/// El informe lo calcula el servidor (`get_weekly_report`) con datos reales de
/// `user_vocabulary`, `vocabulary_reviews`, `corrections`, `practice_sessions`
/// y `lesson_progress`. Este modelo solo normaliza la respuesta y expone
/// derivados de presentación; nunca inventa ceros cuando la semana está vacía:
/// en ese caso `hasData` es `false` y la UI lo dice.
class WeeklyReportTotals {
  const WeeklyReportTotals({
    this.newWords = 0,
    this.corrections = 0,
    this.lessonsCompleted = 0,
    this.minutes = 0,
  });

  final int newWords;
  final int corrections;
  final int lessonsCompleted;
  final int minutes;

  factory WeeklyReportTotals.fromMap(Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return WeeklyReportTotals(
      newWords: _int(map['new_words']),
      corrections: _int(map['corrections']),
      lessonsCompleted: _int(map['lessons_completed']),
      minutes: _int(map['minutes']),
    );
  }
}

class WeeklyReport {
  const WeeklyReport({
    this.weekOffset = 0,
    this.startDate,
    this.endDate,
    this.hasData = false,
    this.newWords = 0,
    this.wordsReviewed = 0,
    this.wordsMastered = 0,
    this.corrections = 0,
    this.topErrorType,
    this.lessonsCompleted = 0,
    this.minutes = 0,
    this.sessions = 0,
    this.practiceDays = 0,
    this.level,
    this.levelName,
    this.levelAssessed = false,
    this.gameRank,
    this.previous = const WeeklyReportTotals(),
  });

  factory WeeklyReport.fromMap(Map<String, dynamic> map) {
    return WeeklyReport(
      weekOffset: _int(map['week_offset']),
      startDate: _date(map['start_date']),
      endDate: _date(map['end_date']),
      hasData: map['has_data'] == true,
      newWords: _int(map['new_words']),
      wordsReviewed: _int(map['words_reviewed']),
      wordsMastered: _int(map['words_mastered']),
      corrections: _int(map['corrections']),
      topErrorType: _text(map['top_error_type']),
      lessonsCompleted: _int(map['lessons_completed']),
      minutes: _int(map['minutes']),
      sessions: _int(map['sessions']),
      practiceDays: _int(map['practice_days']),
      level: _text(map['level']),
      levelName: _text(map['level_name']),
      levelAssessed: map['level_assessed'] == true,
      gameRank: _text(map['game_rank']),
      previous: WeeklyReportTotals.fromMap(map['previous']),
    );
  }

  final int weekOffset;
  final DateTime? startDate;
  final DateTime? endDate;

  /// `false` = la semana no tiene actividad registrada. No se muestran ceros
  /// como si fueran progreso real.
  final bool hasData;

  final int newWords;
  final int wordsReviewed;
  final int wordsMastered;
  final int corrections;

  /// Tipo de error más frecuente de la semana (`grammar`, `vocabulary`...).
  final String? topErrorType;

  final int lessonsCompleted;
  final int minutes;
  final int sessions;
  final int practiceDays;

  /// Nivel estimado actual. `null` cuando el nivel nunca se evaluó: un CEFR de
  /// relleno no se presenta como nivel asignado.
  final String? level;
  final String? levelName;
  final bool levelAssessed;
  final String? gameRank;

  final WeeklyReportTotals previous;

  /// Diferencia de minutos frente a la semana anterior. `null` si esta semana
  /// no tiene datos: no se inventa una caída del 100%.
  int? get minutesDelta => hasData ? minutes - previous.minutes : null;

  /// Diferencia de palabras nuevas frente a la semana anterior.
  int? get newWordsDelta => hasData ? newWords - previous.newWords : null;

  /// Diferencia de correcciones frente a la semana anterior. Menos errores
  /// corregidos no es "mejor" ni "peor": solo es un dato.
  int? get correctionsDelta =>
      hasData ? corrections - previous.corrections : null;

  /// Media de minutos por día practicado. `null` sin días registrados.
  double? get minutesPerPracticeDay {
    if (practiceDays <= 0) return null;
    return minutes / practiceDays;
  }

  /// Etiqueta del nivel: "B1 · Intermedio" o `null` si no hay nivel evaluado.
  String? get levelLabel {
    if (!levelAssessed || level == null || level!.isEmpty) return null;
    final name = levelName;
    if (name == null || name.isEmpty) return level;
    return '$level · $name';
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _date(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

int _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}
