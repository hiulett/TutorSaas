/// Helper puro que mapea niveles CEFR ↔ rangos del juego (System HUD).
///
/// La escala de rangos es: F (iniciado) → E (novato) → D → C → B → A → S →
/// SS → SSS (élite). El nivel Pre-A1 (fundacional) corresponde al rango F.
class CefrRank {
  CefrRank._();

  /// Orden canónico de niveles CEFR (el más bajo primero). Fuente única para
  /// progresión, desbloqueo y gating de contenido por nivel.
  static const List<String> cefrOrder = ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  /// Mapeo canónico CEFR → rango del juego.
  static const Map<String, String> _cefrToRank = {
    'PRE-A1': 'F',
    'A1': 'E',
    'A2': 'D',
    'B1': 'C',
    'B2': 'B',
    'C1': 'A',
    'C2': 'S',
  };

  /// Mapeo inverso rango del juego → CEFR (más permisivo: también admite
  /// los rangos extendidos SS/SSS que se usan para C1+/C2).
  static const Map<String, String> _rankToCefr = {
    'F': 'PRE-A1',
    'E': 'A1',
    'D': 'A2',
    'C': 'B1',
    'B': 'B2',
    'A': 'C1',
    'S': 'C2',
    'SS': 'C2',
    'SSS': 'C2',
  };

  /// Descripciones cortas estilo juego para cada rango.
  static const Map<String, String> _rankDescriptions = {
    'F': 'Iniciado — el viaje empieza con una sola palabra.',
    'E': 'Novato — cada aventura empieza con un primer paso.',
    'D': 'Aprendiz — los básicos ya no te frenan.',
    'C': 'Aventurero — te desenvuelves en mazmorras cotidianas.',
    'B': 'Guerrero — conversaciones firmes y con recursos.',
    'A': 'Campeón — lideras la conversación con soltura.',
    'S': 'Leyenda — casi imposible de igualar.',
    'SS': 'Leyenda Suprema — dominio casi perfecto.',
    'SSS': 'Deidad del Idioma — maestría absoluta.',
  };

  /// Devuelve el rango del juego correspondiente a un nivel CEFR.
  ///
  /// Devuelve 'E' como rango por defecto para niveles desconocidos.
  static String gameRankFromCefr(String cefr) {
    final level = cefr.trim().toUpperCase();
    return _cefrToRank[level] ?? 'E';
  }

  /// Devuelve el nivel CEFR correspondiente a un rango del juego.
  ///
  /// Devuelve 'A1' como nivel por defecto para rangos desconocidos.
  static String cefrFromGameRank(String rank) {
    final normalized = rank.trim().toUpperCase();
    return _rankToCefr[normalized] ?? 'A1';
  }

  /// Descripción corta estilo juego para un rango.
  static String rankDescription(String rank) {
    final normalized = rank.trim().toUpperCase();
    return _rankDescriptions[normalized] ?? 'Rango misterioso — sigue entrenando.';
  }

  /// Orden de rangos del gremio (F más bajo → SSS más alto).
  static const List<String> _rankOrder = ['F', 'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS'];

  /// Índice de un rango en la escala; -1 si no se reconoce.
  static int rankIndex(String rank) {
    return _rankOrder.indexOf(rank.trim().toUpperCase());
  }

  /// ¿El rango [player] es suficiente para aceptar una misión que exige
  /// [requiredRank]? Devuelve true si no hay rango requerido o el jugador
  /// tiene un rango igual o superior.
  static bool canAcceptRank(String playerRank, String? requiredRank) {
    if (requiredRank == null || requiredRank.trim().isEmpty) return true;
    final p = rankIndex(playerRank);
    final r = rankIndex(requiredRank);
    if (p < 0) return false; // rango de jugador desconocido → no permite
    if (r < 0) return true;  // rango requerido desconocido → no restringe
    return p >= r;
  }
}
