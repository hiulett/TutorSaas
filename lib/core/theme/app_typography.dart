import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography tokens centralizados (DS-02).
/// Wrapper sobre google_fonts: SpaceGrotesk (headlines), Inter (cuerpo),
/// JetBrainsMono (stats/etiquetas). Usar SIEMPRE estos estilos en lugar de
/// llamar a GoogleFonts directamente, para garantizar consistencia.
class AppTypography {
  AppTypography._();

  // ── Headlines (SpaceGrotesk) ─────────────────────────────────────────────

  static TextStyle headline(BuildContext context) => GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );

  static TextStyle title(BuildContext context) => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle subtitle(BuildContext context) => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // ── Body (Inter) ─────────────────────────────────────────────────────────

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMuted(BuildContext context) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  // ── Mono (JetBrainsMono) — stats, etiquetas, HUD ────────────────────────

  static TextStyle label(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.manaCyan,
  );

  static TextStyle stat(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );

  static TextStyle tiny(BuildContext context) => GoogleFonts.jetBrainsMono(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.onSurfaceVariant,
  );
}
