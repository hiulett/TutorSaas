# Fase 10 — Microinteracciones · Change_Log

> Registro de cambios de la Fase 10 (Microinteracciones).

## 2026-07-30

### Tarea 35 — Auditoría de animaciones
- `docs/10_Animations/Analysis.md`: inventario de animaciones, 8 hallazgos (AN-01..AN-08), plan de tokens.

### Implementación

**AN-A · Tokens de animación (P0)**
- Nuevo `lib/core/theme/app_motion.dart`: `AppMotion` con duraciones (micro 150ms / fast 300ms / standard 600ms / reward 1200ms / ambient 2000ms), curvas (curveStandard/curveSpring/curvePress) y helpers de accesibilidad (`reduceMotion`, `scaled`).

**AN-B · Migración de widgets core a tokens (P0)**
- `animated_counter.dart`: 600ms → `AppMotion.standard`.
- `floating_reward.dart`: 1200ms → `AppMotion.reward`; curva → `curveStandard`.
- `glass_card.dart`: 120ms → `AppMotion.micro`; 2000ms loop → `AppMotion.ambient`; curva → `curvePress`. Corregido nombre `_scaleAnimation`.

**AN-C · Migración de widgets de conversación (P1)**
- `live_goals_tracker_bar.dart` (`_GoalChip`): 600ms → `standard`; easeOutBack → `curveSpring`.
- `conversation_screen.dart` (`_AnimatedMessage`): 400ms → `fast`; easeOutCubic → `curveStandard`.

**AN-D · Micro-interacción en botones (P1)**
- Nuevo `lib/core/widgets/runic_button.dart`: `RunicButton` con escala al presionar (150ms), respeta reduce-motion, glow, radio 4px (estilo PlantillasHTML).
- Aplicado al botón "DISTRIBUIR PUNTOS" en `hunter_status_screen.dart`.

**AN-E · Efecto de subida de nivel (P1)**
- `hunter_hud_header.dart` → `ConsumerStatefulWidget`; detecta cambio de nivel (XP/1000) y muestra `FloatingReward` "¡SUBIDA DE NIVEL!".

**AN-F · Efecto de misión completada (P1)**
- `mission_board_widget.dart` (`_MissionCard`): estado completado → borde dorado + glow + etiqueta "COMPLETADA".

**AN-G · Accesibilidad reduce-motion (P2)**
- Soportado en `AppMotion.reduceMotion/scaled` y `RunicButton` (escala desactivada con reduce-motion).

### Verificación
- `flutter analyze`: 0 errores (64 infos/warnings) · `flutter test`: 13/13 · build apk OK.

### Pendiente
- Aplicar `RunicButton` al resto de botones primarios (onboarding, paywall, salón) — progresivo.
