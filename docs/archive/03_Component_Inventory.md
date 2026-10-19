# 03 — Component Inventory

> Fase 0/1 · Inventario de componentes reutilizables · Fecha: 2026-07-30
> Ubicación: `lib/core/widgets/`.

## 1. Widgets core verificados

| Widget | Archivo | Uso / Capacidades |
|---|---|---|
| `GlassCard` | `lib/core/widgets/glass_card.dart` | Contenedor flotante con `borderColor`, `showRunicCorners`, `runicColor`. Base de todas las "ventanas del sistema". |
| `SegmentedBar` | `lib/core/widgets/segmented_bar.dart` | Barra de progreso de 10 segmentos (estilo sistema HUD). Usada por `mission_board_widget`. |
| `AnimatedCounter` | `lib/core/widgets/animated_counter.dart` | Contador con easing (para gemas/mana/XP). |
| `FloatingReward` | `lib/core/widgets/floating_reward.dart` | Recompensa flotante "+XP" / "+gems". |
| `RpgAvatar` | `lib/core/widgets/` | Avatar/orbe con radio completo (único radio >20px permitido). |
| `CyberManhwaBackground` | `lib/core/widgets/` | Fondo manhwa con 13 `CyberBgMode`s. Usar `AppColors`, no hex hardcodeados. |

## 2. Componentes de pantallas (reusables de facto)

| Componente | Dónde vive | Notas |
|---|---|---|
| Mana orb / botón hold-to-talk | `conversation_screen.dart` | Botón de mic con gesture `record` package |
| Quest card con letra de rango | — | **NO existe como widget estándar** (candidato a crear en Fase 2) |
| Chip de goal / keyword | `conversation_screen.dart` | Chips de objetivos por escenario |
| `_AnimatedMessage` | `conversation_screen.dart` | Mensaje con slide+fade; top-level (corregido el error de clase anidada) |
| Tab bar del dashboard | `dashboard_screen.dart` | 4 tabs (MAZMORRAS/GUILD/ESTADO/CONFIG) |

## 3. Módulos feature reutilizables (untracked, compilan)

| Módulo | Contenido |
|---|---|
| `lib/features/economy/` | Repositorios/providers de invocaciones, gemas, rachas |
| `lib/features/missions/` | Motor de misiones + `mission_board_widget` (usa `SegmentedBar`) |
| `lib/core/i18n/language_settings.dart` | `UserLanguageSettings` provider (UI/learning/explain languages) |
| `lib/l10n/` | `app_en/es/pt.arb` + localizaciones generadas |

## 4. Faltantes (a construir en Fase 2)

- `QuestCard` / `RankCard` (letra de rango + barra) — estándar para misiones y guild.
- `StatTile` / `StatRow` para la pantalla de Estado del Cazador.
- `RunicButton` / botones primarios estilizados con acento cyan.
- `SystemWindow` (wrapper `GlassCard` + header de sistema) para unificar ventanas.
- `ErrorScreen` siguiendo `system_mana_disruption_error`.
- `DangerToken` (color `#FF1744`) para errores/estados críticos.

## 5. Notas

- Mantener la convención: clases `PascalCase`, archivos `snake_case`, providers terminan en `Provider`, `const` constructors, sin `setState` para lógica de negocio.
- `flutter analyze` = barra 0 errores (≈56 infos/warnings tolerados).
