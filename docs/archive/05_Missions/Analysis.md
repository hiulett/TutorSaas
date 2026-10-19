# Fase 5 — Analysis

> Análisis del estado actual del Sistema de Misiones.

## 1. Modelos de dominio (`mission_models.dart`)

| Modelo | Propósito | Campos clave |
|---|---|---|
| `MissionTemplate` | Plantilla reutilizable | missionType, objectiveType, targetValue, xp/gemReward, itemReward, min/maxCefrLevel, cooldownHours |
| `MissionInstance` | Misión activa del jugador | status (active/completed/...), currentValue, isRewardClaimed, expiresAt, progress getter |
| `EmergencyMission` | Misión por tiempo limitado global | startsAt/expiresAt, recompensas altas (200xp/50g) |
| `RewardHistory` | Registro de recompensas | sourceType, xpEarned, gemsEarned, itemCode |

Helpers: `missionScenarioContext` (mapa de títulos → contexto real de conversación),
`missionTypeIcon` (emojis por tipo), `missionTypeColor` (colores por tipo).

## 2. Repositorio (`mission_repository.dart`, 358 líneas)

Capacidades:
- **Cleanup**: borra misiones completadas >14 días, expiradas, secretas vencidas/completadas,
  reward history >50 entradas.
- **Cuotas**: `maxActiveMissions=10`, `maxSecretMissions=3` (reutiliza slots).
- **CRUD**: getTemplates (filtro por tipo/CEFR), getActive/Completed, acceptMission (respeta
  cuotas), updateProgress (marca completed), claimReward (RPC `add_xp`/`add_gems` + history).
- **Secretas**: get/create con sobrescritura de la más antigua al llegar al límite.
- **Emergencias**: getActiveEmergencies (ventana starts_at/expires_at).
- **Generación diaria**: `generateDailyMissions` asigna hasta llenar slots (sin duplicar template).
- **Purge**: `purgeAllOldMissions` (reset).

## 3. Providers (`mission_providers.dart`)

6 `FutureProvider.autoDispose`: active, completed, dailyTemplates, secret, emergency, rewards.
Todos dependen de `currentUserProvider` y `supabaseClientProvider`.

## 4. Widget

`mission_board_widget.dart` → usa `SegmentedBar` (core widget). No verificado en esta iteración
si está conectado al dashboard.

## 5. Tipos de misión cubiertos

| Tipo | Requisito de Fase 5 | Estado |
|---|---|---|
| Principales (weekly/secondary) | ✅ | Templates + instancias |
| Recomendadas | ✅ | Por CEFR (`min/max_cefr_level`) |
| Misiones IA / Secretas | ✅ | `secret_missions` + trigger_data |
| Del gremio | ✅ (DB) | `guild_collaborative_missions` (sin repo/UI) |
| Temporales / Eventos | ✅ (DB) | `global_events` + `player_event_progress` (sin repo/UI) |
| Diarias | ✅ | `generateDailyMissions` |
| De emergencia | ✅ | `emergency_missions` + provider |

## 6. Conclusión

El motor está **muy avanzado** (~80%). Gaps:
1. `guild_collaborative_missions` y `global_events`/`player_event_progress` tienen tablas pero
   **no** tienen repositorio/providers/UI.
2. `updateProgress` marca `completed` directamente; no hay progresión parcial (siempre status
   final al llegar al target).
3. No hay pantalla completa de "Mission Board" verificada/integrada en dashboard.
4. Timers/rotación automática dependen de cron/edge function no implementada.
