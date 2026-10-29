# Modelo de datos

_Medido en producción el 18-oct-2026._

| Objeto | Cantidad |
|---|---|
| Tablas en `public` | **75** |
| Políticas RLS | **120** sobre 72 tablas |
| Funciones (`public`) | **52** |
| Trabajos `pg_cron` | 3 |
| Buckets de Storage | 1 |
| Vistas | 0 |

---

## 1. Grupos de tablas

### Identidad y perfil
`users`, `user_settings`, `user_language_profiles`, `user_ai_profiles`,
`languages`, `cefr_levels`, `cefr_recommendation_rules`, `hunter_classes`,
`prestige_ladder`, `hunter_titles`, `user_titles`

- `user_language_profiles` es el centro del progreso: nivel CEFR, rango, XP,
  racha, clase de cazador, equipo cosmético.
- `user_settings` guarda preferencias (meta diaria, intereses, estilo de
  corrección, personalidad del tutor).

### Aprendizaje
`scenarios` (500 filas sembradas), `scenario_goals`, `scenario_objectives`,
`scenario_phrases`, `conversations`, `messages`, `corrections`,
`oracle_assessments`, `oracle_turns`, `oracle_questions`,
`pronunciation_assessments`, `lesson_progress`, `vocabulary_items`,
`user_vocabulary`, `daily_stats`, `weekly_stats`, `daily_fluency_stats`,
`speech_dna_metrics`, `user_scenario_fluency`, `user_scenario_goals`,
`user_scenario_phrases`

- `conversations.scenario_id` es **`varchar`**, no UUID: guarda tanto UUIDs de
  escenario como claves del catálogo Dart (`a1_ordering_coffee_at_a_cafe`) y el
  literal `oracle-evaluation`.
- `oracle_turns` guarda las 6 dimensiones que pinta el radar del dashboard
  (pronunciation, fluency, grammar, vocabulary, comprehension, naturalness),
  rellenadas al cerrar el examen.
- `daily_stats` lo escribe `register_practice` (minutos y conversaciones del
  día) desde P-23; antes nadie lo alimentaba y el gráfico semanal salía vacío.
  La meta diaria se calcula sobre `practice_sessions` (el libro idempotente de
  P-03), no sobre `daily_stats`.

### Economía y progresión
`subscription_plans`, `user_subscriptions`, `payments`, `mana_transactions`,
`mana_potions`, `mana_gems`, `mana_items`, `player_inventory`,
`cosmetic_catalog`, `ai_action_costs`, `session_reward_ledger`, `reward_history`,
`player_streaks`, `aura_session_awards`, `achievements`, `user_achievements`,
`hunter_collection_catalog`, `hunter_collections`, `player_pergaminos`

- `user_subscriptions` es la fuente que lee la app para plan y maná.
  Columnas de tienda: `store`, `rc_product_id`, `rc_expires_at`,
  `last_event_id`, `cancel_at_period_end`.
- `subscription_plans` solo tiene lo que no vive en la tienda: `mana_allowance`,
  `features`, `badge_tag`, `class_name`, `order_index`. **Los precios salen de
  RevenueCat/Play**, no de esta tabla (se eliminaron las columnas de Stripe).
- `mana_transactions` es solo lectura para el cliente; se escribe por RPC
  `SECURITY DEFINER`.

### Gremio, salas y misiones
`chat_rooms`, `chat_room_messages`, `chat_room_participants`, `seat_requests`,
`livekit_token_requests`, `guild_quest_pool`, `guild_announcements`,
`guild_battle_pass`, `guild_collaborative_missions`, `mission_templates`,
`mission_instances`, `player_completed_quests`, `secret_missions`,
`emergency_missions`, `global_events`, `player_event_progress`,
`daily_challenges`

- `chat_room_participants.last_seen_at` se actualiza con heartbeat; el cron
  `purge-stale-participants` borra los que llevan más de 180 s sin latido.
- Varias tablas de este grupo están sin uso tras retirar pantallas
  (battle pass, misiones secretas, eventos globales). Ver issue #37.

### Operación
`retention_events`, `analytics_events`, `api_request_logs`, `ai_usage_logs`,
`llm_quota_events`, `revenuecat_events`, `system_ai_settings`,
`player_daily_state`

- `revenuecat_events` da idempotencia al webhook (PK = `event.id`).
- `retention_events` recibe los eventos de producto (paywall, onboarding, etc.).

---

## 2. RLS

Regla general: **el dueño solo lee lo suyo**, y escribe únicamente donde el
producto lo necesita.

| Tabla | Acceso del cliente |
|---|---|
| `user_subscriptions` | **SELECT** (antes era `FOR ALL`: se podía auto-asignar premium) |
| `payments` | **SELECT** |
| `mana_transactions` | SELECT |
| `user_language_profiles` | `FOR ALL` del dueño *(pendiente: ver abajo)* |
| Contenido propio (conversaciones, mensajes, vocabulario, stats) | `FOR ALL` del dueño |

Escrituras sensibles van por RPC `SECURITY DEFINER` o **service role**:
`renew_mana_cycle`, `sync_entitlement`, `grant_mana`, `refund_mana`,
`apply_placement_as`.

### Nivel CEFR (cerrado en #73)

El cliente **no** escribe `cefr_level_id` ni `game_rank`:

- `guard_language_profile` fuerza el nivel inicial (A1/E) en el `INSERT` y
  revierte esos campos en el `UPDATE` de `authenticated`/`anon`.
- `apply_self_declared_level(code)` guarda la elección del onboarding una sola
  vez y la marca `{"source":"self_declared"}`. Se rechaza si ya hay evaluación.
- `apply_placement_as(user, …)` (solo `service_role`) escribe el resultado del
  Oráculo desde la Edge Function `evaluate-placement` y marca
  `placement_assessed_at`.
- `apply_placement(…)` sigue existiendo como envoltorio para builds antiguas,
  pero está revocado para `authenticated`/`anon`.

---

## 3. RPC principales

| Función | Uso |
|---|---|
| `consume_mana(user, action)` | Cobra una acción de IA y devuelve el estado |
| `get_mana_state(user)` | Saldo, límite y expiración |
| `renew_mana_cycle(user, allowance, expires)` | Repone el ciclo (conserva el maná comprado) |
| `sync_entitlement(...)` | Aplica el estado de RevenueCat (idempotente, solo service role) |
| `purchase_cosmetics(...)` | Compra con oro |
| `session_rewards(...)` | Cierra sesión y acredita XP/maná |
| `check_ai_audio_quota` / `track_ai_audio_time` | Cuota de audio |
| `purge_stale_participants(seconds)` | Limpia presencia |
| `get_dashboard_state(user)` | Progreso + logros del dashboard en una llamada (P-19b) |
| `refund_mana(user, action)` | Devuelve plan y `daily_used` tras un turno fallido (solo service role) |
| `refund_failed_turn(turn_ref, action)` | Reembolso idempotente desde el cliente (P-06) |
| `apply_self_declared_level(code)` | Nivel autodeclarado del onboarding, una sola vez (#73) |
| `apply_placement_as(user, …)` | Resultado del Oráculo; solo `service_role` (#73) |
| `get_daily_goal_progress(tz)` | Minutos de hoy, meta, racha y si ya se celebró (P-23) |
| `claim_daily_goal_celebration(tz)` | Celebración de la meta, una vez por día (P-23) |

---

## 4. Migraciones — realidad actual

| Métrica | Valor |
|---|---|
| Archivos `.sql` en `supabase/migrations/` (raíz) | 134 |
| Con prefijo válido de 14 dígitos | 59 |
| Sin prefijo (el CLI los ignora) | 75 |
| En subcarpetas (`archive/`, `audit/`) | 40 |
| Migraciones aplicadas | **67** |

El repo **no reproduce** el esquema: 33 migraciones se aplicaron desde el SQL
Editor y solo existen en el historial de Supabase.

⚠️ **No ejecutar `supabase db push` contra producción**: intentaría aplicar 26
archivos con prefijo no registrado.

La foto verificada del esquema (recuentos y consulta para regenerarla) está en
[runbooks/SCHEMA_BASELINE.md](runbooks/SCHEMA_BASELINE.md).

---

## 5. Objetos añadidos en octubre de 2026

| Objeto | Para qué | Historia |
|---|---|---|
| `ai_usage_logs` (+ `action_code`, `audio_seconds`, `status`, `cost_estimate_usd`) | Uso y coste de IA | P-14 #99 |
| Vistas `ai_usage_daily`, `ai_usage_by_session` | Coste por usuario/día/sesión | P-14 #99 |
| `analytics_events` política `analytics_events_select_admin` + vistas `analytics_onboarding_funnel`, `analytics_activation`, `analytics_retention`, `analytics_sessions_per_week` | Embudo, activación y retención | P-15 #100 |
| `get_dashboard_state(uuid)` | Progreso + logros en una RPC | P-19b #163 |
| Trigger `trg_message_sequence` | `sequence_number` sin carrera | P-19 #104 |
| `refund_mana` actualizado | Restaura también `daily_used` | P-07 #92 |

Procedimiento de baseline (requiere Docker + contraseña de BD) y detalle
completo en [runbooks/MIGRATION_STATUS.md](runbooks/MIGRATION_STATUS.md).
