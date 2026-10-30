# Modelo de datos

_Medido en producción el 29-oct-2026._

| Objeto | Cantidad |
|---|---|
| Tablas en `public` | **88** |
| Políticas RLS | **134** sobre 84 tablas |
| Funciones (`public`) | **92** |
| Trabajos `pg_cron` | 3 |
| Buckets de Storage | 1 |
| Vistas | 14 |

> Los recuentos se miden con `information_schema` / `pg_policies`; cambian con
> cada PR que aplica una migración.

---

## 1. Grupos de tablas

### Identidad y perfil
`users`, `user_settings`, `user_language_profiles`, `user_ai_profiles`,
`languages`, `cefr_levels`, `cefr_recommendation_rules`, `hunter_classes`,
`prestige_ladder`, `hunter_titles`, `user_titles`

- `user_language_profiles` es el centro del progreso: nivel CEFR, rango, XP,
  racha, clase de cazador, equipo cosmético.
- `user_settings` guarda preferencias (meta diaria, intereses, estilo de
  corrección, personalidad del tutor). También el opt-out de los emails de
  reactivación (`reactivation_emails`) y su token de baja (issue #107).
  Preferencias de voz: `tts_speed`, `tutor_voice_id` (#119). Modo del
  micrófono: `mic_mode_hold_to_talk` (boolean, `not null default false`, #198:
  `false` = tap-to-toggle, `true` = mantener para hablar).

### Aprendizaje
`scenarios` (500 filas sembradas), `scenario_goals`, `scenario_objectives`,
`scenario_phrases`, `conversations`, `messages`, `corrections`,
`oracle_assessments`, `oracle_turns`, `oracle_questions`,
`pronunciation_assessments`, `lesson_progress`, `vocabulary_items`,
`user_vocabulary`, `daily_stats`, `weekly_stats`, `daily_fluency_stats`,
`speech_dna_metrics`, `user_scenario_fluency`, `user_scenario_goals`,
`user_scenario_phrases`, `listening_exercises`, `listening_attempts`

- `conversations.scenario_id` es **`varchar`**, no UUID: guarda tanto UUIDs de
  escenario como claves del catálogo Dart (`a1_ordering_coffee_at_a_cafe`) y el
  literal `oracle-evaluation`.
- Criterio único de "lección superada": `lesson_completion_passed()` en SQL y
  `LessonCompletion.isPassed` en Dart (75 %, con una meta fallada tolerada en
  lecciones de 4 metas o menos). Las estrellas salen de
  `lesson_completion_stars()`. Diagnóstico del doble currículo en
  [runbooks/CURRICULUM_ALIGNMENT.md](runbooks/CURRICULUM_ALIGNMENT.md) y en las
  vistas `lesson_completion_state`, `curriculum_progress_keys` y
  `curriculum_alignment_summary`.
- `oracle_turns` guarda las 6 dimensiones que pinta el radar del dashboard
  (pronunciation, fluency, grammar, vocabulary, comprehension, naturalness),
  rellenadas al cerrar el examen.
- `daily_stats` lo escribe `register_practice` (minutos y conversaciones del
  día) desde P-23; antes nadie lo alimentaba y el gráfico semanal salía vacío.
  La meta diaria se calcula sobre `practice_sessions` (el libro idempotente de
  P-03), no sobre `daily_stats`.

### Comprensión auditiva (P-30 / #115)

- `listening_exercises` es el banco de ítems **precomputado**: `slug` estable,
  `level` (PRE-A1…C2), `lines` (jsonb: `[{speaker,text}]`) y `questions`
  (jsonb: `[{id,prompt,options,correct,explanation}]`). Solo lectura desde el
  cliente (`listening_exercises_read_active` para `anon` y `authenticated`).
- `listening_attempts` guarda cada intento (`score`, `total`, `passed`,
  `answers`). El cliente solo puede leer los suyos; **no hay política de
  INSERT**: escribe `submit_listening_attempt` (`SECURITY DEFINER`).
- `submit_listening_attempt(exercise, answers, minutes, tz_offset)` es la única
  fuente de puntuación: corrige contra `questions[].correct`, inserta el intento,
  escribe `lesson_progress` con `lesson_id = 'listening:<slug>'` y
  `skill_focus = 'listening'`, avanza la misión `listening_items` (una unidad
  por respuesta acertada) y llama a `register_practice` con los minutos reales
  medidos en el cliente (la clave es `listening:<slug>:<YYYYMMDD>`, así que
  repetir el mismo ejercicio el mismo día no vuelve a sumar minutos).
- El audio **no** usa IA: lo sintetiza `flutter_tts` en el dispositivo. No hay
  `action_code` ni consumo de maná.
- `get_weekly_report` cuenta estos intentos como `lessons_completed` porque
  `lesson_progress.status` usa el mismo criterio que las lecciones habladas
  (`lesson_completion_passed`). `boss_exam_status` los ignora: filtra por
  prefijo CEFR (`a1_%`, `b1_%`…).

### Economía y progresión
`subscription_plans`, `user_subscriptions`, `payments`, `mana_transactions`,
`mana_potions`, `mana_gems`, `mana_items`, `player_inventory`,
`cosmetic_catalog`, `currency_ledger`, `level_rewards`, `ai_action_costs`,
`session_reward_ledger`, `reward_history`, `player_streaks`,
`aura_session_awards`, `achievements`, `user_achievements`,
`hunter_collection_catalog`, `hunter_collections`, `player_pergaminos`

- `user_subscriptions` es la fuente que lee la app para plan y maná.
  Columnas de tienda: `store`, `rc_product_id`, `rc_expires_at`,
  `last_event_id`, `cancel_at_period_end`.
- `subscription_plans` solo tiene lo que no vive en la tienda: `mana_allowance`,
  `features`, `badge_tag`, `class_name`, `order_index`. **Los precios salen de
  RevenueCat/Play**, no de esta tabla (se eliminaron las columnas de Stripe).
- `mana_transactions` es solo lectura para el cliente; se escribe por RPC
  `SECURITY DEFINER`.
- **P-32 — economía con propósito:** `currency_ledger` es el libro de todo
  movimiento de oro, gemas y fragmentos (`currency`, `delta`, `reason`,
  `ref_key`, `balance_after`). Escribe **solo** `economy_apply_currency`, que es
  interno (`authenticated` no puede ejecutarlo); el cliente solo lo lee, y su
  `unique (user_id, ref_key)` es la idempotencia de cada compra, crafteo, freeze
  y recompensa de nivel.
- `cosmetic_catalog` añade `required_level` (nivel de cazador que desbloquea el
  objeto, 1–50) y `craft_cost_fragments` (receta de crafteo con fragmentos).
  El nivel se calcula con `economy_level(xp_points) = 1 + xp/1000`, la misma
  curva que `HunterLevel` en Dart.
- `level_rewards` (nivel → bolsa de oro / `item_code`) la reclama
  `claim_level_rewards`, idempotente por `level_reward:<nivel>`.
- `player_streaks.streak_freezes` ya **no** se puede subir desde el cliente:
  el trigger `guard_player_streak_freezes` lo limita a `least(new, old)`
  (consumir sigue permitido) y comprar pasa por `purchase_streak_freeze`.
- La métrica de sumideros (oro ganado vs gastado) vive en la vista
  `v_economy_flow`, sin acceso para la app. Ver
  [runbooks/ECONOMY_SINKS.md](runbooks/ECONOMY_SINKS.md).

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
`player_daily_state`, `reactivation_emails`

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
| `currency_ledger` | **SELECT** del dueño (escribe solo la RPC definer) |
| `level_rewards` | **SELECT** (catálogo de recompensas) |
| `v_economy_flow` | **sin acceso** (agregado entre usuarios; solo `service_role`) |
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
| `purchase_cosmetic(user, item, currency)` | Compra un cosmético con `gold` o `gems`: valida saldo, `required_level`, disponibilidad y ownership; entrega el ítem y escribe `currency_ledger` en la misma transacción |
| `craft_cosmetic(user, item)` | Craftea un cosmético pagando `craft_cost_fragments` (idempotente por `craft:<item>`) |
| `purchase_streak_freeze(user, ref)` | Compra un freeze de racha por 30 gemas (máx. 3, idempotente por `ref`) |
| `spend_currency(user, currency, amount, reason, ref)` | Gasto genérico por RPC; sustituye el `UPDATE total_gold` del cliente que el guard descartaba |
| `level_reward_status(user)` / `claim_level_rewards(user)` | Recompensas de nivel: estado y reclamo idempotente |
| `get_economy_wallet(user)` | Cartera (oro, gemas, fragmentos, nivel, freezes) + `earned`/`spent` por moneda |
| `session_rewards(...)` | Cierra sesión y acredita XP/maná |
| `check_ai_audio_quota` / `track_ai_audio_time` | Cuota de audio |
| `purge_stale_participants(seconds)` | Limpia presencia |
| `get_dashboard_state(user)` | Progreso + logros del dashboard en una llamada (P-19b) |
| `refund_mana(user, action)` | Devuelve plan y `daily_used` tras un turno fallido (solo service role) |
| `refund_failed_turn(turn_ref, action)` | Reembolso idempotente desde el cliente (P-06) |
| `submit_listening_attempt(exercise, answers, minutes, tz_offset)` | Corrige y guarda un ejercicio de comprensión auditiva (P-30) |

### Contrato de compensaciones (normalizado)

`refund_failed_turn` y `refund_mana` devuelven **la misma forma**:

```json
{ "success": true, "refunded": 12, "already_refunded": false, "reason": null }
```

| Campo | Tipo | Significado |
|---|---|---|
| `success` | bool | La operación se procesó (no implica devolver maná) |
| `refunded` | int | Maná devuelto; `0` si no había nada que devolver |
| `already_refunded` | bool | Ya existía un `refund` con ese `turn_ref` |
| `reason` | string \| null | `invalid_turn`, `invalid_action`, `no_recent_charge`, o `null` |

Reglas: idempotencia por `mana_transactions.ref_id` (solo `refund_failed_turn`),
ventana de **5 minutos** sobre el último cargo del mismo `action_code`, y no se
restauran ítems equipados. El cliente interpreta el resultado con
`RefundResult` (`lib/features/economy/domain/models/refund_result.dart`).

| `apply_self_declared_level(code)` | Nivel autodeclarado del onboarding, una sola vez (#73) |
| `apply_placement_as(user, …)` | Resultado del Oráculo; solo `service_role` (#73) |
| `get_daily_goal_progress(tz)` | Minutos de hoy, meta, racha y si ya se celebró (P-23) |
| `claim_daily_goal_celebration(tz)` | Celebración de la meta, una vez por día (P-23) |
| `claim_mana_grace(user)` | Turno de gracia diario del maná; solo `service_role` (P-26) |
| `boss_exam_status(language)` | Requisitos del jefe + mini-chequeo cada 10 lecciones (P-31 #116, P-43 #128) |
| `get_weekly_report(week_offset, tz, language)` | Informe semanal en servidor: palabras, correcciones, minutos, lecciones y nivel; `has_data=false` si la semana está vacía (P-43 #128) |
| `learning_evidence()` | Retención, misiones y transferencia sin inventar ceros (#74) |

---

## 4. Migraciones — realidad actual

| Métrica | Valor |
|---|---|
| Archivos `.sql` en `supabase/migrations/` (raíz) | 164 |
| Con prefijo válido de 14 dígitos | 89 |
| Sin prefijo (el CLI los ignora) | 75 |
| En subcarpetas (`archive/`, `audit/`) | 40 |
| Migraciones aplicadas | **98** |

_Recuento local y `schema_migrations` del 29-oct-2026._

El repo **no reproduce** el esquema: parte del historial se aplicó desde el SQL
Editor o por MCP y solo existe en `schema_migrations` de Supabase.

⚠️ **No ejecutar `supabase db push` contra producción**: intentaría aplicar
archivos con prefijo que no están registrados en el historial.

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
| `listening_exercises`, `listening_attempts`, `submit_listening_attempt`, misión `listening_items` | Comprensión auditiva jugable (audio TTS, corrección en servidor) | P-30 #115 |

Procedimiento de baseline (requiere Docker + contraseña de BD) y detalle
completo en [runbooks/MIGRATION_STATUS.md](runbooks/MIGRATION_STATUS.md).

---

## 5. Misiones (#109 · P-24)

### Progreso solo por servidor

Los `mission_instances.current_value/status` los escriben únicamente triggers
`SECURITY DEFINER` sobre datos reales del jugador:

| Trigger | Tabla origen | Objetivo que avanza |
|---|---|---|
| `trg_message_advance_missions` | `messages` | `conversation_turns` |
| `trg_session_reward_advance_missions` | `session_reward_ledger` | `sessions`, `practice_session`, `speak_minutes` |
| `trg_vocabulary_advance_missions` | `user_vocabulary` (INSERT) | `vocab_words` |
| `trg_vocabulary_review_advance_missions` | `vocabulary_reviews` (INSERT) | `vocab_words` (repaso SRS) |

`guard_mission_instance` neutraliza cualquier `UPDATE` de cliente sobre
`current_value`, `status`, `target_value`, `objective_type`, importes y dueño.

**Quitado del cliente en #109** (`lib/features/missions/...`):

- `advanceMissions()` → RPC `advance_my_missions` (doble conteo en el repaso
  SRS; ahora lo cubre `trg_vocabulary_review_advance_missions`).
- `updateProgress()` → escribía `current_value/status` desde el cliente.
- `updateGuildMissionProgress()` y `contributeToWeeklyRaid()` → sumaban
  progreso colectivo desde el cliente sin validación.

### Métrica por plantilla y umbral del 5 %

Vista `mission_template_completion_rates` (versionada en
`supabase/migrations/20261029061945_mission_redesign_observability.sql`):

```sql
select title, mission_type, instancias, completadas, tasa_completado,
       cumple_umbral_5pct
from mission_template_completion_rates
order by completadas desc nulls last, instancias desc;
```

Regla de retiro: `tasa_completado < 5` con `instancias >= 30`. Se aplica a mano
(`update mission_templates set is_active = false`) tras revisión; no se ejecuta
en la migración. A 29-oct-2026 **ninguna** plantilla alcanza el 5 % (máximo
1,69 % con n=59), así que no se retira ninguna: el problema era el flujo, no el
catálogo.

### Alcanzabilidad

Vista `mission_templates_reachability` (espejo de
`lib/features/missions/domain/models/mission_visibility.dart`). Marca
`alcanzable = false` cuando el tipo está oculto (`secondary`, `secret`,
`emergency`, `guild`, `collaborative`, `event`), el objetivo no tiene trigger o
el target supera el techo medido.

A 29-oct-2026: 13 plantillas `daily` alcanzables, 4 `weekly` alcanzables y 2
`weekly` fuera de techo (*El Viajero Semanal*, 25 min; *El Políglota*, 20
palabras). Las 13 `secondary` quedan fuera porque `rotate_daily_missions` solo
reparte `daily` y `weekly`.

### Reclamo

`claim_mission_reward(p_instance_id)` es `SECURITY DEFINER`, bloquea la fila con
`FOR UPDATE`, valida `auth.uid()` y `status = 'completed'`, y es idempotente
(`already_claimed = true`, `xp/gems = 0`). La migración
`20261029062825_fix_claim_mission_reward_source_id.sql` corrige el `insert` en
`reward_history` (`source_id` es `NOT NULL`): antes **todo** reclamo fallaba con
`23502`.

Contrato normalizado (`20261029171705`):

```json
{ "success": true, "ok": true, "already_claimed": false, "xp": 100, "gems": 20, "reason": null }
```

`success` es la clave canónica; `ok` se mantiene como alias deprecado para
builds antiguas. Motivos: `not_found`, `not_completed`.

### Recompensas de sesión

La única vía es `close_session(uuid)`: deriva objetivos (`user_scenario_goals`)
y minutos (`ended_at - started_at`) del servidor y escribe
`session_reward_ledger`.

```json
{ "xp": 300, "gold": 10, "success": true, "fragments": 5, "duplicated": false }
```

En la segunda llamada devuelve los mismos importes con `duplicated: true`.

`apply_session_rewards` está **deprecada**: exige `auth.uid() = p_user_id` pero
su `EXECUTE` está revocado a `authenticated`, así que nadie puede llamarla
(se conserva solo por historial).

### Drop de fin de sesión

`claim_session_drop(session_id, completed_goals)` sortea rareza (común, raro,
épico, legendario) con `(15, 10) × multiplicador` y es idempotente por
`session_drops(user_id, session_id)`.

```json
{ "success": true, "ok": true, "already_claimed": false, "rarity": "epico", "xp": 30, "gold": 20, "reason": null }
```

Motivos: `invalid_session`, `no_goals`. El cliente lo lee con
`SessionDropResult` (acepta `ok` como alias legacy).



