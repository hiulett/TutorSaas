# Fase 4 — Implementation_Plan

> Plan de implementación (PRIORIZADO). Sin implementación realizada aún — documentación.

## Objetivo

Conversaciones definitivas: Oráculo, HUD, barra de progreso, objetivos dinámicos,
animaciones, logros y recompensas visuales, coherentes con el resto del sistema.

## Pasos

### 4.1 Header y HUD definitivos (P0)
1. Header del Oráculo: avatar + nombre + rango, acorde a `combat_system_english_battle`.
2. HUD de conversación: mana/energía, objetivos, tácticas activas.
3. Reutilizar `ManaMeterWidget`, `SegmentedBar`, `GlassCard` rúnico.

### 4.2 Barra de progreso y objetivos (P0)
1. Unificar barra de progreso con `SegmentedBar` (10 segmentos) + contador.
2. Objetivos dinámicos: indicar completados con glow (ya en `LiveGoalsTrackerBar`).

### 4.3 Microinteracciones y recompensas (P1)
1. `FloatingReward` ("+XP") al completar objetivos.
2. Añadir animaciones de logro (celebration overlay) sin tocar el pipeline de voz.

### 4.4 Coherencia (P1)
1. Asegurar que el flujo conversacional integra tácticas, summary y recompensas.
2. Preparar "Oráculo definitivo" para servir también como mentor (`ai_mentor_chat_system`).

## Criterios de terminación

- `flutter analyze` 0 errores; `flutter test` verde.
- Pipeline de voz intacto (regla AGENTS.md).
- Paridad visual con `combat_system_english_battle`.
