# Inventario del esquema en producción

Generado el 2026-10-18 leyendo la base viva (`sipiumfdpvnszthykyog`).

Este documento es una **fotografía**, no la fuente de verdad. La fuente sigue siendo Postgres; para un baseline reproducible ejecuta `scripts/dump_schema.ps1` con Docker en marcha.

## Totales

| Métrica | Valor |
|---|---|
| Tablas en `public` | **75** |
| Tablas con RLS habilitada | **75** (100 %) |
| Políticas RLS | **119** |
| Funciones | **51** |
| Triggers (no internos) | **32** |
| Índices | **182** |
| Migraciones registradas | **38** |
| Extensiones | `pg_cron`, `pg_net`, `pg_stat_statements`, `pgcrypto`, `plpgsql`, `supabase_vault`, `uuid-ossp` |

## Tablas

| Tabla | Columnas | RLS | Políticas |
|---|---|---|---|
| `achievements` | 9 | ✅ | 1 |
| `ai_action_costs` | 7 | ✅ | 3 |
| `ai_usage_logs` | 9 | ✅ | 1 |
| `analytics_events` | 5 | ✅ | 2 |
| `api_request_logs` | 4 | ✅ | 1 |
| `aura_session_awards` | 4 | ✅ | 1 |
| `cefr_levels` | 9 | ✅ | 3 |
| `cefr_recommendation_rules` | 6 | ✅ | 1 |
| `chat_room_messages` | 6 | ✅ | 2 |
| `chat_room_participants` | 9 | ✅ | 3 |
| `chat_rooms` | 17 | ✅ | 2 |
| `conversations` | 10 | ✅ | 1 |
| `corrections` | 8 | ✅ | 1 |
| `cosmetic_catalog` | 15 | ✅ | 3 |
| `daily_challenges` | 10 | ✅ | 1 |
| `daily_fluency_stats` | 9 | ✅ | 1 |
| `daily_stats` | 9 | ✅ | 1 |
| `emergency_missions` | 12 | ✅ | 1 |
| `global_events` | 9 | ✅ | 1 |
| `guild_announcements` | 6 | ✅ | 1 |
| `guild_battle_pass` | 7 | ✅ | 2 |
| `guild_collaborative_missions` | 13 | ✅ | 1 |
| `guild_quest_pool` | 17 | ✅ | 1 |
| `hunter_classes` | 40 | ✅ | 1 |
| `hunter_collection_catalog` | 7 | ✅ | 1 |
| `hunter_collections` | 4 | ✅ | 1 |
| `hunter_titles` | 7 | ✅ | 1 |
| `languages` | 6 | ✅ | 2 |
| `lesson_progress` | 6 | ✅ | 2 |
| `livekit_token_requests` | 3 | ✅ | **0** |
| `llm_quota_events` | 3 | ✅ | **0** (por diseño: solo `service_role`) |
| `mana_gems` | 11 | ✅ | 3 |
| `mana_items` | 10 | ✅ | 4 |
| `mana_potions` | 11 | ✅ | 3 |
| `mana_transactions` | 7 | ✅ | 1 |
| `messages` | 8 | ✅ | 1 |
| `mission_instances` | 20 | ✅ | 3 |
| `mission_templates` | 15 | ✅ | 1 |
| `oracle_assessments` | 23 | ✅ | 3 |
| `oracle_questions` | 9 | ✅ | 1 |
| `oracle_turns` | 18 | ✅ | 2 |
| `payments` | 9 | ✅ | 1 |
| `player_completed_quests` | 5 | ✅ | 2 |
| `player_daily_state` | 10 | ✅ | 3 |
| `player_event_progress` | 6 | ✅ | 2 |
| `player_inventory` | 9 | ✅ | 1 |
| `player_pergaminos` | 6 | ✅ | 1 |
| `player_streaks` | 7 | ✅ | 3 |
| `prestige_ladder` | 14 | ✅ | 3 |
| `pronunciation_assessments` | 13 | ✅ | 1 |
| `reward_history` | 8 | ✅ | 2 |
| `scenario_goals` | 7 | ✅ | 1 |
| `scenario_objectives` | 5 | ✅ | 1 |
| `scenario_phrases` | 6 | ✅ | 1 |
| `scenarios` | 29 | ✅ | 2 |
| `seat_requests` | 5 | ✅ | 3 |
| `secret_missions` | 12 | ✅ | 1 |
| `session_reward_ledger` | 9 | ✅ | 1 |
| `speech_dna_metrics` | 7 | ✅ | 1 |
| `stripe_events` | 3 | ✅ | **0** |
| `subscription_plans` | 18 | ✅ | 2 |
| `system_ai_settings` | 7 | ✅ | 3 |
| `user_achievements` | 5 | ✅ | 1 |
| `user_ai_profiles` | 9 | ✅ | 1 |
| `user_language_profiles` | 32 | ✅ | 2 |
| `user_scenario_fluency` | 7 | ✅ | 1 |
| `user_scenario_goals` | 8 | ✅ | 1 |
| `user_scenario_phrases` | 9 | ✅ | 1 |
| `user_settings` | 15 | ✅ | 1 |
| `user_subscriptions` | 17 | ✅ | 1 |
| `user_titles` | 6 | ✅ | 2 |
| `user_vocabulary` | 17 | ✅ | 1 |
| `users` | 17 | ✅ | 4 |
| `vocabulary_items` | 9 | ✅ | 2 |
| `weekly_stats` | 8 | ✅ | 1 |

## Diferencias conocidas entre repo y producción

1. **Cinco tablas no existían en `supabase/migrations/`** y ahora sí, en `20261018000010_baseline_missing_tables.sql`: `daily_fluency_stats`, `user_scenario_goals`, `user_scenario_phrases`, `user_scenario_fluency`, `cefr_recommendation_rules`.
2. **`user_progress` no existe** ni se consulta: solo aparece en el modelo Dart `UserProgress`, sin uso en runtime.
3. **`messages`** usa `sender_role`/`text`; el `init.sql` del repo declara `role`/`content_text`. Desde 2026-10-18 ambas existen (las segundas son columnas generadas).
4. **Numeración de migraciones**: solo los archivos con prefijo de 14 dígitos se aplican con `supabase db push`. El resto del histórico se aplicó a mano desde el SQL Editor.
5. **`livekit_token_requests` y `stripe_events`** tienen RLS activa y cero políticas: solo son accesibles con `service_role`. Es intencional, pero conviene documentarlo para que no se lea como un olvido.
