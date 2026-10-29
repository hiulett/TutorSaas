/// Estado de la tarjeta "bienvenido de vuelta" (P-27 / #112).
///
/// Se muestra solo tras ≥3 días sin practicar y si hay una lección empezada.
/// El mensaje es positivo: no se culpa al jugador por la racha perdida.
class WelcomeBack {
  const WelcomeBack({
    required this.daysAway,
    required this.lessonId,
    required this.lessonTitle,
    required this.goalsRemaining,
    required this.totalGoals,
    required this.streak,
  });

  /// Días mínimos de inactividad para mostrar la tarjeta.
  static const int minimumDaysAway = 3;

  final int daysAway;
  final String lessonId;
  final String lessonTitle;
  final int goalsRemaining;
  final int totalGoals;
  final int streak;

  bool get shouldShow => lessonId.isNotEmpty && daysAway >= minimumDaysAway;

  /// La lección no tenía metas completadas pendientes.
  bool get lessonCompleted => totalGoals > 0 && goalsRemaining <= 0;

  /// La racha se perdió y conviene ofrecer empezar una nueva sin dramatizar.
  bool get streakReset => streak <= 0;
}
