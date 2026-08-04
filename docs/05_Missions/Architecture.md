# Fase 5 — Architecture

> Arquitectura del Sistema de Misiones.

## Módulos

```
lib/features/missions/
├── data/repositories/mission_repository.dart
├── domain/models/mission_models.dart
└── presentation/
    ├── providers/mission_providers.dart
    └── widgets/mission_board_widget.dart
```

## Capa de datos

- Acceso directo a Supabase vía `MissionRepository(client)` (no hay capa `domain/repositories`
  abstracta; el repo es concreto).
- RPCs de economía: `add_xp(p_user_id, p_amount)`, `add_gems(p_user_id, p_amount)`.
- Tablas: mission_templates, mission_instances, secret_missions, emergency_missions,
  global_events, player_event_progress, guild_collaborative_missions, reward_history.

## Flujo principal

```
generateDailyMissions(userId)
   └─ cleanupOldMissions → getActive → slots → getTemplates(daily) → acceptMission
acceptMission → canAcceptMission (cuotas) → insert mission_instances
updateProgress → current_value + status=completed + completed_at
claimReward → is_reward_claimed=true → rpc add_xp/add_gems → insert reward_history
```

## Secretas / Emergencias

- Secretas: `createSecretMission` (reutiliza slot sobrescribiendo la más antigua).
- Emergencias: `getActiveEmergencies` por ventana de tiempo.

## Decisiones

- Feature-first; estado con `FutureProvider.autoDispose`.
- Lógica de negocio de rotación en el repositorio (no en UI).
- RLS por usuario (`auth.uid() = user_id`) en instancias/rewards/secretas; lectura pública
  para templates/emergencias/eventos.

## Gaps

1. `guild_collaborative_missions` y `global_events` sin capa de acceso en Flutter.
2. Repositorio concreto sin interfaz `domain/repositories` (menor, seguirá patrón del proyecto).
