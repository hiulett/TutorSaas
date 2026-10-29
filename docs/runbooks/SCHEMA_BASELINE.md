# Baseline del esquema (producción)

_Medido: 28-oct-2026 · proyecto `sipiumfdpvnszthykyog` · consultas de solo lectura._

Este documento es la foto de referencia contra la que comparar cualquier
entorno de staging o migración futura.

## Cifras

| Métrica | Valor |
|---|---|
| Tablas (`public`) | **80** |
| Vistas | 6 |
| Funciones | 70 |
| Políticas RLS | 126 |
| Tablas sin RLS | **0** |
| Triggers | 44 |
| Jobs de cron | 3 |
| Migraciones registradas | **74** |
| Archivos `.sql` en `supabase/migrations/` (raíz) | 134 (59 con prefijo válido, 75 sin él) |
| Archivos `.sql` en subcarpetas (`archive/`, `audit/`) | 40 |

## Por qué el repo no reproduce el esquema

1. Decenas de migraciones se aplicaron desde el SQL Editor y solo quedaron en
   `supabase_migrations.schema_migrations`.
2. 75 archivos no siguen la convención `<14 dígitos>_nombre.sql`, así que el CLI
   no los ve.
3. `supabase db push` está prohibido en este repo (ver `AGENTS.md`).

Detalle histórico: [MIGRATION_STATUS.md](MIGRATION_STATUS.md).

## Cómo regenerar el baseline

```sql
select
  (select count(*) from information_schema.tables
    where table_schema = 'public' and table_type = 'BASE TABLE') as tables,
  (select count(*) from information_schema.views
    where table_schema = 'public') as views,
  (select count(*) from pg_proc p
     join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.prokind = 'f') as functions,
  (select count(*) from pg_policies where schemaname = 'public') as policies,
  (select count(*) from pg_tables
    where schemaname = 'public' and not rowsecurity) as tables_without_rls,
  (select count(*) from pg_trigger t
     join pg_class c on c.oid = t.tgrelid
     join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and not t.tgisinternal) as triggers,
  (select count(*) from cron.job) as cron_jobs,
  (select count(*) from supabase_migrations.schema_migrations) as migrations;
```

## Tablas (79)

`achievements, ai_action_costs, ai_usage_logs, analytics_events,
api_request_logs, aura_session_awards, cefr_levels, cefr_recommendation_rules,
chat_room_messages, chat_room_participants, chat_rooms, conversations,
corrections, cosmetic_catalog, daily_challenges, daily_fluency_stats,
daily_stats, emergency_missions, global_events, guild_announcements,
guild_battle_pass, guild_collaborative_missions, guild_quest_pool,
hunter_classes, hunter_collection_catalog, hunter_collections, hunter_titles,
languages, lesson_progress, livekit_token_requests, llm_quota_events,
mana_gems, mana_items, mana_potions, mana_transactions, messages,
mission_instances, mission_templates, oracle_assessments, oracle_questions,
oracle_turns, payments, player_completed_quests, player_daily_state,
player_event_progress, player_inventory, player_pergaminos, player_streaks,
practice_sessions, prestige_ladder, pronunciation_assessments,
revenuecat_events, reward_history, scenario_goals, scenario_objectives,
scenario_phrases, scenario_progress, scenarios, seat_requests, secret_missions,
session_drops, session_reward_ledger, speech_dna_metrics, subscription_plans,
system_ai_settings, user_achievements, user_ai_profiles, user_language_profiles,
user_scenario_fluency, user_scenario_goals, user_scenario_phrases,
user_settings, user_subscriptions, user_titles, user_vocabulary, users,
vocabulary_items, vocabulary_reviews, weekly_stats`

## Staging: opciones y decisión pendiente

| Opción | Coste | Pros | Contras |
|---|---|---|---|
| **Supabase branch** | Compute por hora mientras está activo | Crea la BD desde las migraciones del proyecto; sirve para probar migraciones | No copia datos de producción; requiere aprobar coste |
| **Proyecto Supabase aparte** | Plan + compute mensual | Independiente y persistente | Duplicar secretos, cron y Edge Functions; deriva |
| **Local (`supabase start`)** | Gratis | Iteración rápida | No reproduce el esquema real (33 migraciones sin archivo) |

**Recomendación:** branch temporal para validar migraciones concretas +
este baseline para comparar recuentos. Requiere aprobación de coste antes de
crear nada.
