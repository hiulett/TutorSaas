# Fase 3 — Known_Issues

> Problemas conocidos del Dashboard.

## Funcionalidad

| # | Issue | Impacto |
|---|---|---|
| K3-1 | Tab GUILD/ESTADO/CONFIG empujan rutas en lugar de mostrar contenido inline | No hay "unificación Dashboard+Guild" real |
| K3-2 | `user_progress.equipped_title_code` depende de columna que debe verificarse en DB | Puede fallar el título equipado |
| K3-3 | Stats persistidos en `bio` (formato regex frágil) | Riesgo de corrupción de datos |

## Diseño / Convenciones

| # | Issue | Impacto |
|---|---|---|
| K3-4 | `GoogleFonts.orbitron` en HunterStatusScreen (fuera de estándar SpaceGrotesk/Inter/JetBrainsMono) | Inconsistencia tipográfica |
| K3-5 | Paridad media con `hunter_control_center_dashboard` (falta HUD central) | Desviación visual |

## QA

| # | Issue | Impacto |
|---|---|---|
| K3-6 | `overflow_test.dart`: LeagueLeaderboard `pumpAndSettle timed out` | 1 test falla (preexistente) |
