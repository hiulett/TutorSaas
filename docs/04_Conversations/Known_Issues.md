# Fase 4 — Known_Issues

> Problemas conocidos del Sistema de Conversaciones.

## Funcionalidad

| # | Issue | Impacto |
|---|---|---|
| K4-1 | HUD/header de conversación no alcanza paridad con `combat_system_english_battle` | Experiencia visual inferior |
| K4-2 | `FloatingReward` no integrado en el flujo de logros | Sin recompensas visuales durante la conversación |
| K4-3 | Tácticas (fluency/grammar/hints) son estado local de UI; el bonus XP no se persiste | Incoherencia con economía (Fase 6) |
| K4-4 | "Oráculo definitivo" como mentor/coach no implementado | Falta `ai_mentor_chat_system` |

## QA / Tests

| # | Issue | Impacto |
|---|---|---|
| K4-5 | Sin test dedicado del módulo de conversación | Riesgo de regresión no detectada |
