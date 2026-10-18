/// Issue #28: curva de nivel del cazador.
///
/// Antes el XP solo servía para el leaderboard: no existía ninguna función
/// XP→nivel y el "nivel" que veía el usuario era en realidad su CEFR.
///
/// Se mantiene el umbral que ya usaba el HUD para el aviso de subida de nivel
/// (1000 XP), de modo que no cambia el comportamiento existente y el XP pasa a
/// tener una lectura visible.
class HunterLevel {
  const HunterLevel._();

  /// XP necesarios para subir un nivel.
  static const int xpPerLevel = 1000;

  /// Nivel visible (empieza en 1).
  static int levelFor(int xp) {
    if (xp <= 0) return 1;
    return 1 + (xp ~/ xpPerLevel);
  }

  /// XP acumulados dentro del nivel actual.
  static int xpIntoLevel(int xp) {
    if (xp <= 0) return 0;
    return xp % xpPerLevel;
  }

  /// Progreso 0..1 hacia el siguiente nivel.
  static double progressFor(int xp) {
    return xpIntoLevel(xp) / xpPerLevel;
  }
}
