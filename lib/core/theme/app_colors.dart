import 'package:flutter/material.dart';

class AppColors {
  static const Color voidBg = Color(0xFF05070E);
  static const Color background = Color(0xFF11131B);
  static const Color surface = Color(0xFF11131B);
  static const Color surfaceDim = Color(0xFF11131B);
  static const Color surfaceBright = Color(0xFF373942);
  static const Color surfaceContainerLowest = Color(0xFF0B0E16);
  static const Color surfaceContainerLow = Color(0xFF191B23);
  static const Color surfaceContainer = Color(0xFF1D1F27);
  static const Color surfaceContainerHigh = Color(0xFF272A32);
  static const Color surfaceContainerHighest = Color(0xFF32343D);
  static const Color surfaceVariant = Color(0xFF32343D);

  // ── Tokens de superficie glass (DS-S01) ───────────────────────────────────
  // Única identidad de tarjeta: fondo de vidrio oscuro + blur + borde sutil.
  // Coincide con la plantilla HTML (background #11131b, radius 4px).
  static const Color surfaceGlass = Color(0xFF11131B);
  static const double glassOpacity = 0.94;
  static const double glassBlur = 4.0;
  static const double glassBorderAlpha = 0.8;

  static const Color manaCyan = Color(0xFF00E5FF);
  static const Color manaCyanDim = Color(0xFF00DAF3);
  static const Color manaCyanLight = Color(0xFF9CF0FF);
  static const Color manaCyanText = Color(0xFFC3F5FF);

  static const Color royalGold = Color(0xFFFFC700);
  static const Color royalGoldDim = Color(0xFFF5BF00);
  static const Color royalGoldLight = Color(0xFFFFDF94);

  static const Color runeViolet = Color(0xFF9D4EDD);
  static const Color runeVioletContainer = Color(0xFFE6C3FF);
  static const Color runeVioletText = Color(0xFFF8E7FF);

  static const Color crimsonRed = Color(0xFFFF1744);
  static const Color errorRed = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);

  static const Color emeraldGreen = Color(0xFF00E676);
  static const Color emeraldGreenDim = Color(0xFF3CDDC7);
  static const Color successGreen = Color(0xFF00E676);

  static const Color onBackground = Color(0xFFE1E2ED);
  static const Color onSurface = Color(0xFFE1E2ED);
  static const Color onSurfaceVariant = Color(0xFFBAC9CC);
  static const Color outline = Color(0xFF849396);
  static const Color outlineVariant = Color(0xFF3B494C);

  // RPG HUD additional colors
  static const Color bossRed = Color(0xFFD50000);
  static const Color hpBarRed = Color(0xFFFF1744);
  static const Color xpBarGreen = Color(0xFF00E676);

  // Rarity colors
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityUncommon = Color(0xFF4CAF50);
  static const Color rarityRare = Color(0xFF2196F3);
  static const Color rarityEpic = Color(0xFF9C27B0);
  static const Color rarityLegendary = Color(0xFFFF9800);

  // ── Tokens añadidos por MV-07 (colores de UI/misiones/gremio) ─────────────

  // Misión: tipos
  static const Color guildAmber = Color(0xFFFFAB00);
  static const Color collabBlue = Color(0xFF42A5F5);

  // Misión: gemas de recompensa
  static const Color gemPurple = Color(0xFFE0B6FF);

  // Alertas / onboarding
  static const Color alertRed = Color(0xFFEF4444);

  // Superficie de fondo profunda (dropdowns, sheets, inputs)
  static const Color surfaceDeep = Color(0xFF0F172A);

  // Arena / fondo de examen
  static const Color arenaVoid = Color(0xFF04060C);

  // Pantalla de fondo del salón
  static const Color screenBg = Color(0xFF090D16);
  static const Color statusWindowBg = Color(0xFF060A14);

  // Barras de progreso / estados
  static const Color progressYellow = Color(0xFFF1C40F);

  // Modo "blind listening"
  static const Color blindMagenta = Color(0xFFFF00FF);

  // Burbuja del tutor
  static const Color tutorBubbleBlue = Color(0xFF1E60FF);

  // Trofeos / medallas (league)
  static const Color trophyGold = Color(0xFFFFD700);
  static const Color trophySilver = Color(0xFFC0C0C0);
  static const Color trophyBronze = Color(0xFFCD7F32);

  // Verde de acento (éxito suave, héroes)
  static const Color accentGreen = Color(0xFF10B981);

  // Atributos del cazador (radar/estadísticas)
  static const Color vocabularyBlue = Color(0xFF64B5F6);
  static const Color presencePink = Color(0xFFE91E63);

  // Fondo de avatar/monster
  static const Color monsterPillBg = Color(0xFF060B16);

  // ── Alias (consolidación de tokens duplicados de MV-07) ───────────────────
  static const Color aiGold = trophyGold;
  static const Color triumphGold = trophyGold;
  static const Color rankGold = trophyGold;
  static const Color deepSlate = surfaceDeep;
  static const Color sheetBackground = surfaceDeep;
  static const Color monsterAvatarBg = surfaceDeep;
  static const Color easyGreen = accentGreen;
  static const Color liveGreen = accentGreen;
  static const Color rankMagenta = blindMagenta;
  static const Color hostingAmber = guildAmber;
  static const Color chatBlue = collabBlue;

  // ── Niveles CEFR (mapa de mazmorras / backgrounds) ────────────────────────
  static const Color cefrA1 = Color(0xFF10B981);
  static const Color cefrA2 = Color(0xFFF59E0B);
  static const Color cefrB1 = Color(0xFF06B6D4);
  static const Color cefrB2 = Color(0xFF8B5CF6);
  static const Color cefrC1 = Color(0xFFEC4899);
  static const Color cefrC2 = Color(0xFFFF4500);

  // ── Tema Isekai / Medieval Fantasy (Create Your Character) ────────────────
  // Paleta apagada: negro, piedra, hierro, madera oscura, dorado envejecido,
  // azul mágico, púrpura arcano, rojo oscuro. Sin fluorescentes.
  static const Color medievalBg = Color(0xFF0B0E16);
  static const Color medievalStone = Color(0xFF1A1E28);
  static const Color medievalIron = Color(0xFF2A2F3A);
  static const Color medievalDarkWood = Color(0xFF1B1512);
  static const Color medievalAgedGold = Color(0xFFB8860B);
  static const Color medievalAgedGoldDim = Color(0xFF8A6A2F);
  static const Color medievalAgedGoldLight = Color(0xFFD4A93F);
  static const Color medievalMagicBlue = Color(0xFF4C6EF5);
  static const Color medievalArcanePurple = Color(0xFF6D4C9F);
  static const Color medievalBloodRed = Color(0xFF8B1A1A);
  static const Color medievalText = Color(0xFFD8CBB0);
  static const Color medievalTextDim = Color(0xFF9A8F7A);
}
