# Fase 10 — Microinteracciones · Auditoría de Animaciones (tarea 35)

> Fuente de verdad: `/docs`. Auditoría basada en código real (2026-07-30).

## 1. Inventario de animaciones existentes

| Widget/Archivo | Animación | Duración | Curva |
|---|---|---|---|
| `GlassCard` | Scale al tocar (hover) | 120ms | easeInOut |
| `GlassCard` | Glow rúnico (loop) | 2000ms | repeat(reverse) |
| `AnimatedCounter` | Contador con easing | 600ms | easeOutCubic |
| `FloatingReward` | Slide + fade (+XP) | 1200ms | easeOutCubic |
| `DraggableMonster` | Flotación/bob | 1600-2200ms | — |
| `LiveGoalsTrackerBar._GoalChip` | Scale + glow al completar meta | 600ms | easeOutBack + easeOut |
| `ConversationScreen._AnimatedMessage` | Slide + fade mensaje | — | — |
| `VoiceWaveformVisualizer` | Waveform animado | — | — |
| `VoiceRoomScreen._pulseController` | Pulso del mic | 2000ms | repeat(reverse) |
| `CyberManhwaBackground` | Fondo manhwa animado | — | — |

## 2. Problemas detectados (tarea 35)

### P0 — Consistencia
| ID | Problema | Evidencia |
|---|---|---|
| AN-01 | **Duraciones sin sistema**: 120ms / 600ms / 1200ms / 2000ms / 2200ms sin tokens compartidos | `glass_card.dart:46,50`, `animated_counter.dart`, `floating_reward.dart` |
| AN-02 | **Curvas inconsistentes**: mezcla `easeInOut`, `easeOutCubic`, `easeOutBack` sin regla | multi-archivo |

### P1 — Calidad percibida
| ID | Problema |
|---|---|
| AN-03 | **Sin recompensa visual al subir de nivel/XP** (solo FloatingReward para metas) |
| AN-04 | **Sin efecto al completar misión** (MissionBoard estático) |
| AN-05 | **Sin microinteracción en botones primarios** (solo GlassCard escala; ElevatedButtons no) |
| AN-06 | **Achievements/cofres sin celebración** |

### P2 — Rendimiento / accesibilidad
| ID | Problema |
|---|---|
| AN-07 | `_runicController` repite infinito en GlassCard → **todas** las cards tienen un loop continuo (puede afectar rendimiento y batería en listas largas) |
| AN-08 | Sin `MediaQuery.disableAnimations` / preferencia reduce-motion para accesibilidad |

## 3. Plan de estandarización — Tokens de animación

Crear `lib/core/theme/app_motion.dart` con tokens centralizados:

| Token | Valor | Uso |
|---|---|---|
| `micro` | 150ms | Hover/press de cards y botones |
| `fast` | 300ms | Cambios de estado, switchers |
| `standard` | 600ms | Contadores, completar metas |
| `reward` | 1200ms | Recompensas (+XP, cofres) |
| `ambient` | 2000ms | Loops ambientales (glow, pulso) |
| `curveStandard` | easeOutCubic | Entradas/salidas |
| `curveSpring` | easeOutBack | "Pop" de logros |
| `reduceMotion` | bool | respeta `MediaQuery.disableAnimations` |

### Tareas atómicas
| # | Tarea | Prioridad |
|---|---|---|
| AN-A | Crear `app_motion.dart` con tokens | P0 |
| AN-B | Migrar `GlassCard`, `AnimatedCounter`, `FloatingReward` a tokens | P0 |
| AN-C | Migrar `_GoalChip` y `_AnimatedMessage` a tokens | P1 |
| AN-D | Añadir micro-interacción a botones primarios (scale on press) | P1 |
| AN-E | Efecto de nivel/XP subida (reutilizar FloatingReward) | P1 |
| AN-F | Efecto de misión completada en MissionBoard | P1 |
| AN-G | Respeta `disableAnimations` (accesibilidad) | P2 |

## 4. Conclusión
La base de microinteracciones es **buena** (ya hay FloatingReward, counter, goal chips animados, waveform, monster). El principal problema es la **falta de sistema** (duraciones/curvas dispersas). La estandarización (AN-A..C) + microinteracciones en botones y logros (AN-D..F) elevarán la calidad percibida sin tocar el pipeline de voz.
