# Fase 6 — Known_Issues

> Problemas conocidos de la Economía.

## Bugs

| # | Issue | Impacto |
|---|---|---|
| K6-1 | `claimDailyReward` asigna una `Future` como valor de `pergaminos_max` en el update | El RPC `increment_pergaminos_max` no se ejecuta correctamente; pergaminos máx no sube |
| K6-2 | `player_completed_quests.quest_id` VARCHAR vs `guild_quest_pool.id` UUID | Inconsistencia de tipos; joins fallan |

## Funcionalidad incompleta

| # | Issue | Impacto |
|---|---|---|
| K6-3 | Oro (`total_gold`) sin lógica de gasto | Recurso muerto |
| K6-4 | Battle pass (`guild_battle_pass`) sin repo/UI | Sin monetización de pase |
| K6-5 | Inventario sin pantalla | No se pueden equipar/desequipar items desde UI |
| K6-6 | Invocaciones no conectadas al inicio de conversación | El límite de IA no se aplica |
| K6-7 | `generateDailyPergaminos` genera placeholders | Contenido offline real pendiente |
| K6-8 | Sin drops/loot automático al completar conversaciones | Falta gratificación |
| K6-9 | "Fragmentos" no definidos como recurso | Requisito sin resolver |

## QA / Tests

| # | Issue | Impacto |
|---|---|---|
| K6-10 | Sin test dedicado de economía | Riesgo de regresión no detectada |
