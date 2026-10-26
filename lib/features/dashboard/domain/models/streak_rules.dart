/// Reglas puras de racha (testeables sin Flutter ni red).
///
/// La fuente de verdad es el servidor (`register_practice`); estas reglas solo
/// deciden qué mostrar en la interfaz.
class StreakRules {
  StreakRules._();

  /// Cuenta como práctica del día con ≥1 objetivo o ≥3 minutos.
  static bool countsAsPractice({required int minutes, required int objectives}) {
    return objectives >= 1 || minutes >= 3;
  }

  /// Próxima racha esperada al cerrar una práctica (espejo de la RPC).
  static int nextStreak({
    required int current,
    required DateTime? lastPractice,
    required DateTime today,
  }) {
    final t = DateTime(today.year, today.month, today.day);
    if (lastPractice == null) return 1;
    final last = DateTime(lastPractice.year, lastPractice.month, lastPractice.day);
    final diff = t.difference(last).inDays;
    if (diff == 1) return current + 1;
    if (diff <= 0) return current > 0 ? current : 1;
    return 1;
  }

  /// ¿Mostrar el aviso de "racha en riesgo"?
  ///
  /// Solo si hay racha, la última práctica fue ayer y quedan menos de
  /// [hoursBeforeMidnight] horas para medianoche local.
  static bool shouldRemind({
    required int streak,
    required DateTime? lastPractice,
    required DateTime now,
    int hoursBeforeMidnight = 6,
  }) {
    if (streak <= 0 || lastPractice == null) return false;

    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
      lastPractice.year,
      lastPractice.month,
      lastPractice.day,
    );
    if (!last.isBefore(today)) return false;
    if (today.difference(last).inDays != 1) return false;

    final midnight = today.add(const Duration(days: 1));
    final hoursLeft = midnight.difference(now).inMinutes / 60.0;
    return hoursLeft < hoursBeforeMidnight;
  }
}
