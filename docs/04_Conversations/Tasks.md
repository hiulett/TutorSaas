# Fase 4 — Tasks

> Lista de tareas y estado. ⬜ pendiente · 🔄 en curso · ✅ completado · ❌ bloqueado

## P0 — Header y HUD definitivos
- ⬜ Header del Oráculo (avatar, nombre, rango).
- ⬜ HUD de conversación (mana, objetivos, táctica activa).
- ⬜ Integrar `ManaMeterWidget` + `SegmentedBar`.

## P0 — Barra de progreso
- ⬜ Unificar barra con `SegmentedBar` (10 segmentos) + contador.
- ✅ `LiveGoalsTrackerBar` existente (chips M1..Mn + glow).

## P1 — Microinteracciones y recompensas
- ⬜ `FloatingReward` al completar objetivos.
- ⬜ Celebration overlay de logros (sin tocar pipeline).
- ✅ `_AnimatedMessage` slide+fade en mensajes.

## P1 — Coherencia
- ⬜ Integrar tácticas → summary → recompensas.
- ⬜ Preparar "Oráculo definitivo" como mentor.

## QA
- ⬜ `flutter analyze` 0 errores; `flutter test` verde.
- ⬜ Validación visual vs `combat_system_english_battle`.
- ⬜ Verificación pipeline de voz intacto.
