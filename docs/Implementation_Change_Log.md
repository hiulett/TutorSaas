# Plan de EjecuciÃ³n â€” Change_Log

> Registro de implementaciÃ³n del MASTER_IMPLEMENTATION_PLAN.md. Actualizado: 2026-07-30.

## Fase A â€” Cimientos

### IA-01 âœ… Â· API keys a --dart-define
- `api_constants.dart`: claves DeepSeek/Groq â†’ default `''` (dart-define).
- `conversation_repository_impl.dart`: eliminados fallbacks con clave real.
- `config.sample.json` + `.gitignore` (config.json/*.key/.env).
- Verificado: 0 secretos en `lib/` Â· build OK Â· tests 13/13.

### DS-01 âœ… Â· app_spacing.dart
- Tokens de grid 4px (xs..huge) + presets (screen/card/compact/button).

### DS-02 âœ… Â· app_typography.dart
- Wrapper sobre google_fonts: headline/title/body/label/stat/tiny (SpaceGrotesk/Inter/JetBrainsMono).

## Pendiente Fase A
- SEC-01 (RLS anon), SEC-02 (leaked-password), SEC-03 (CI), DS-03 (ThemeData unificado), DS-04 (AppRadius/AppElevation).

## Fase A/B — Avance

### DS-03 ? · ThemeData unificado
- pp_theme.dart usa AppSpacing.button en botones; textTheme con google_fonts consistentes (SpaceGrotesk/Inter/JetBrainsMono). AppTypography queda como tokens de uso en widgets.

### MV-01 ? · Migración de widgets core (Fase B)
- mana_meter_widget.dart: orbitron ? JetBrainsMono.
- system_mana_disruption_screen.dart: orbitron ? spaceGrotesk.
- status_window_modal.dart: 5 orbitron + 1 hanken ? spaceGrotesk.
- draggable_monster_widget.dart: orbitron + hanken ? spaceGrotesk.
- Verificado: 0 refs antiguas en lib/core/widgets/.

## SEC-01 ? · RLS restringida a authenticated (aplicada en live)
- 20260731_sec01_rls_authenticated.sql: 50 políticas de datos de usuario pasadas de PUBLIC (rol 0) a uthenticated vía ALTER POLICY.
- Verificado: 0 políticas de datos de usuario en PUBLIC; catálogos públicos intactos.

## MV-02 ? · Migración de onboarding (Fase B)
- onboarding_screen.dart: 18 refs hankenGrotesk ? spaceGrotesk.
- Verificado: 0 hanken en onboarding · build OK · tests 13/13.

## Ejecución en paralelo (5 subagentes)

### MV-04 ? · profile, session_summary, level_exam, conversation
- 10 refs antiguas (orbitron/hanken) ? spaceGrotesk.

### MV-05 ? · shop + voice_room
- shop: 1 orbitron ? spaceGrotesk; voice_room sin refs (ya migrado).

### MV-06 ? · 6 widgets de dashboard
- ai_pick_hero, daily_quests, league_leaderboard, lesson_preview, next_lesson_hero, recommended_hub: 12 hanken ? spaceGrotesk.

### MV-08 ? · META: grep orbitron|hankenGrotesk = 0 en TODO lib/
- Verificado: 0 refs antiguas en todo el árbol.

### DS-04 ? · app_radius.dart + app_elevation.dart
- Tokens de radio (4/8/12/999) y elevación (none/flat/accent/reward), const.

### SEC-03 ? · CI GitHub Actions
- .github/workflows/ci.yml: analyze + test + build apk (debug) con secrets.
- ?? Pendiente del usuario: definir los 4 secrets en Settings ? Secrets.

### Verificación central
- lutter analyze: 0 errores (63 issues) · lutter test: 13/13 · build apk OK.
- Limpieza: imports sin usar eliminados; const en AppElevation.

## MV-07 ? · Eliminación de hex hardcodeados (Fase B completa)
- 97 hex en 25 archivos reemplazados por tokens de AppColors (4 subagentes en paralelo + consolidación central).
- pp_colors.dart reconstruido: tokens canónicos + aliases para duplicados (0xFFFFD700?trophyGold, 0xFF0F172A?surfaceDeep, 0xFF10B981?accentGreen, 0xFF04060C?arenaVoid, etc.).
- Añadidos tokens CEFR (A1-C2) para cyber_manhwa_background.
- missionTypeColor ahora devuelve Color (usa tokens).
- Verificado: 0 hex fuera de AppColors · 0 refs orbitron/hanken · build OK · tests 13/13.
- ?? Lección: subagentes en paralelo NO deben editar el mismo archivo (app_colors.dart se corrompió; reconstruido).

## Fase C — UX (onboarding 3 pasos + paywall post-sesión)

### UX-01 ? · Onboarding 3 pasos
- PageView de 9 ? 3 pasos: (1) idioma nativo+país+idioma objetivo, (2) nivel CEFR + Examen del Oráculo, (3) creación de personaje.
- Barra de progreso y contador a 1/3. Eliminadas 6 páginas y sus métodos/estado sin uso (_goals, _interests, _correctionStyles, _obstacles, paywall screen, fetch plans).
- El guardado persiste los mismos datos (idioma, nivel, personaje, país).

### UX-02 ? · Paywall post-sesión
- El onboarding ya no compra (arranca en free).
- conversation_screen._maybeSuggestPremium(): al salir de una raid con metas completadas y usuario free, muestra diálogo suave "¡RAID COMPLETADA!" con CTA a /paywall.
- Verificado: build OK · tests 13/13 · analyze 0 errores.

## Fase C (continuación) — UX-03, UX-04, REF-01

### UX-03 ? · i18n completo del onboarding
- Traducidas descripciones restantes: niveles CEFR (A1-C2) al español, frase del switch de idioma, descripción de personalización.

### UX-04 ? · Estados vacíos motivantes
- MissionBoard vacío: ícono + texto motivador + botón "GENERAR MISIONES" (invalida provider ? generación lazy).

### REF-01 ?? (parcial) · Dividir dashboard
- Extraídos MicPulseButton y LessonCard a widgets/ (reutilizables, sin uso interno).
- Dashboard: 2040 ? 1774 líneas. División completa del tab de progreso queda como mejora futura.

## Dashboard — Unificación con Design System (DASHBOARD_DESIGN_AUDIT)

### Análisis
- docs/DASHBOARD_DESIGN_AUDIT.md: auditado el Dashboard contra hunter_control_center_dashboard. Hallazgo central: la plantilla es minimalista (URGENT QUEST ? ACTIVE QUESTS), el dashboard sobrecargaba el tab principal.

### Implementación
- D-01: BottomNav alineado (border-t-4 cyan + barra inferior, estilo plantilla).
- D-02: Hero envuelto en framing "SIGUIENTE RAID" (etiqueta dorada + runas + badge CEFR + GlassCard dorado).
- D-05: Historial de lecciones (vacío) eliminado del principal.
- D-06: Logros/fluidez/radar/heatmap movidos a _buildAdvancedAnalysis() en el tab ESTADO (charts ya no huérfanos).
- D-07: Colors.redAccent ? AppColors.crimsonRed.
- D-03 descartado con justificación (el acceso va a /dungeon-map real).
- Verificado: analyze 0 errores · tests 13/13 · build OK.
