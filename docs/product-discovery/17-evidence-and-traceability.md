# 17 — Evidencia y trazabilidad

> **Qué es.** La matriz que permite responder "¿esto existe?, ¿dónde?, ¿lo
> prueba algo?". Cada fila une **una funcionalidad** con su **pantalla o
> archivo**, su **contrato de servidor** (RPC, tabla o Edge Function) y el
> **test** que la cubre.
>
> **Medido:** 30-oct-2026, worktree `p14-ai-usage` (`origin/master`).
> Cifras base en [`_baseline.md`](_baseline.md).
> Contexto: [`00`](00-product-overview.md), [`01`](01-product-identity-and-universe.md),
> [`16`](16-product-glossary.md).

---

## 0. Método de verificación

| Qué | Cómo se comprobó | Fiabilidad |
|---|---|---|
| Existencia de pantalla | `Get-ChildItem lib -Recurse -Filter *_screen.dart` (20) + `class` en cada archivo | Alta |
| Ruta registrada | Lectura de `lib/app/router.dart:33-140` (20 rutas) | Alta |
| RPC invocada | Búsqueda de `.rpc(` en `lib/` (55 llamadas) y extracción del nombre | Alta |
| Tabla existente y con datos | Consulta de solo lectura al MCP `supabase` (`information_schema`, `pg_proc`, `pg_policies` y `count(*)` por tabla) | Alta (30-oct) |
| Contrato de Edge Function | Lectura de `supabase/functions/*/index.ts` | Alta |
| Test que cubre | Nombre y aserciones del archivo en `test/` (88 archivos, 741 casos) | Media-alta: "lo cubre" significa que **hay** un caso sobre esa lógica, no que la cobertura sea completa |
| **Aspecto visual** | **No verificado**: sin dispositivo, sin visión de imágenes y sin capturas en el repo (`docs/ui-ux-audit/screenshots/README.md:7`) | Nula |

**Regla aplicada:** si un eslabón falta (p. ej. no hay RPC, o no hay test), la
fila lo dice y se etiqueta `[PENDIENTE DE VALIDAR]` en lugar de darlo por bueno.

---

## 1. Matriz maestra funcionalidad → pantalla → servidor → test

### 1.1 Núcleo

| Funcionalidad | UI / archivo | Servidor (RPC · tabla · función) | Test | Etiqueta |
|---|---|---|---|---|
| Arranque y resolución de destino | `lib/app/splash_screen.dart:15` | `currentUserProvider` + `NavigationDecisionEngine` (`lib/app/router.dart:149-173`) | `navigation_decision_test.dart` (4) | `[IMPLEMENTADO]` |
| Login / registro (correo y Google) | `welcome_screen.dart:15` | Supabase Auth · `users` · `handle_new_user` | `google_sign_in_error_test.dart` | `[IMPLEMENTADO]` |
| Onboarding (4 pasos) | `onboarding_screen.dart:27` | `user_language_profiles`, `user_settings`, `user_ai_profiles`; `apply_self_declared_level` (`onboarding_repository_impl.dart:80`) | **Sin test de flujo** | `[PARCIAL]` |
| Creación de personaje (clase, nombre, avatar) | `character_creation_wizard.dart` | `hunter_classes` (8 filas) | **Sin test** | `[IMPLEMENTADO]` |
| Prueba de valor 60 s (Mira) | `mini_conversation_screen.dart:25` | `guild_chat` (gratis) → `llm-proxy` | `mini_conversation_test.dart` (14) | `[IMPLEMENTADO]` |
| Placement oral (Oráculo) | `conversation_screen.dart:46` (`oracleMode`) | `evaluate-placement` → `apply_placement_as` (`index.ts:492`); `oracle_assessments` (79), `oracle_turns` (85) | `placement_outcome_test.dart` | `[IMPLEMENTADO]` |
| Dashboard 4 pestañas | `dashboard_screen.dart:33` · tabs `:371-378` · dock `:572-598` | `get_dashboard_state` (`dashboard_repository_impl.dart:31`) | `dashboard_repository_test.dart`, `overflow_test.dart`, `text_scale_test.dart` | `[IMPLEMENTADO]` |
| Ruta / mapa de mazmorras | `learning_path_roadmap.dart` (nodos `:721,774`) | `refresh_recommended_path` (`dashboard_repository_impl.dart:298`), `scenarios` (500), `lesson_catalog_index` (140) | `recommended_path_test.dart`, `lesson_unlock_service_test.dart`, `lesson_relevance_test.dart` | `[IMPLEMENTADO]` |

### 1.2 Conversación y evaluación

| Funcionalidad | UI / archivo | Servidor | Test | Etiqueta |
|---|---|---|---|---|
| Conversación por voz (tap o hold) | `conversation_screen.dart:46` · botón/hold en `conversation_mic_button.dart` | `llm-proxy` `/stt` + `/chat` (SSE); `conversations` (70), `messages` (771) | `conversation_flow_test.dart`, `conversation_repository_http_test.dart`, `sse_chat_decoder_test.dart`, `hold_to_talk_gesture_test.dart`, `conversation_hold_to_talk_notifier_test.dart`, `mic_permission_card_test.dart` | `[IMPLEMENTADO]` |
| TTS del tutor | `conversation_screen.dart` + sheet TTS | `flutter_tts` on-device (`app_es.arb:1031-1035`) | `conversation_tts_notifier_test.dart`, `tts_preferences_test.dart`, `tts_settings_sheet_test.dart` | `[IMPLEMENTADO]` |
| Prompt adaptativo por perfil | `conversation_repository_impl.dart` | `user_ai_profiles` | `tutor_prompt_builder_test.dart` (11), `tutor_adaptation_test.dart`, `conversation_flow_test.dart` | `[IMPLEMENTADO]` |
| Evaluación de metas | `conversation_providers.dart` (`evaluateGoals`) | acción `goal_eval`; `user_scenario_goals`, `scenario_goals` | `goal_evaluation_gate_test.dart` (8), `goal_evaluation_golden_test.dart`, `goal_evaluation_robustness_test.dart` | `[IMPLEMENTADO]` |
| Correcciones por turno | `correction_chip.dart`, `corrections_providers.dart:14` | `corrections` (**0 filas**), acción `correction_turn` (3 de maná) | `corrections_logic_test.dart` (22), `correction_turn_policy_test.dart`, `correction_chip_test.dart` | `[PARCIAL]` |
| Mis errores | `my_errors_screen.dart:20` | `corrections` (SELECT con RLS, `corrections_repository.dart:72-88`) | **Sin test de pantalla** | `[PARCIAL]` |
| Resumen de sesión | `session_summary_screen.dart:31` | `close_session` (`economy_repository_impl.dart:798`) → `apply_session_rewards`; `get_session_learned_summary` | `session_learned_summary_test.dart` (12), `session_drop_result_test.dart` | `[IMPLEMENTADO]` |
| Drop de fin de sesión | `session_drop_controller.dart` | `claim_session_drop` (`:926`), `session_drops` | `session_drop_result_test.dart` (5) | `[PARCIAL]` |
| Lección de refuerzo | `session_summary_screen.dart:816` | `lesson-generator`; `lesson_generation` (100 de maná) | `remedial_lesson_test.dart` (21) | `[IMPLEMENTADO]` |
| Comprensión auditiva | `listening_quiz_screen.dart:26` | `listening_exercises` (3), `submit_listening_attempt` (`listening_repository.dart:128`), `listening_attempts` (**0**) | `listening_quiz_screen_test.dart` (4), `listening_grading_test.dart`, `listening_models_test.dart`, `listening_session_test.dart`, `listening_path_card_test.dart` | `[IMPLEMENTADO]` |
| Jefe de mazmorra (promoción) | `boss_exam_result_screen.dart:16`, `boss_exam_card.dart:139`, `level_checkpoint_banner.dart:117` | `boss_exam_status` (`boss_exam_service.dart:25`); `boss_exam_attempts` (**0**) | `boss_exam_result_test.dart` (4), `boss_exam_rules_test.dart`, `boss_exam_card_test.dart`, `boss_exam_status_test.dart` | `[IMPLEMENTADO]` |

### 1.3 Progreso, economía y compras

| Funcionalidad | UI / archivo | Servidor | Test | Etiqueta |
|---|---|---|---|---|
| XP y nivel de cazador | `hunter_hud_header.dart`, `progress_tab_view.dart` | `add_xp` (`economy_repository_impl.dart:944`); `1 + XP/1000` | `hunter_level_test.dart` (4) | `[IMPLEMENTADO]` |
| Aura y tiers | `aura_hud.dart`, `aura_system.dart` | `add_aura_xp` (`:842`), `aura_session_awards` (12) | `aura_system_test.dart` (19) | `[IMPLEMENTADO]` |
| Título de prestigio (21 escalones) | chip en `chat_rooms_screen.dart:1048-1075` | `prestige_ladder`, `get_prestige_title` (`:956`), `compute_prestige_title` | `aura_system_test.dart` (validación de rango) | `[IMPLEMENTADO]` |
| Racha y freeze | `progress_tab_view.dart` | `player_streaks`; `purchase_streak_freeze` (`:675`) | `streak_rules_test.dart` (12) | `[IMPLEMENTADO]` |
| Maná (saldo, coste, presupuesto) | `oracle_mana_bar.dart:131`, `dungeon_guardian_screen.dart:25` | `get_mana_state` (`:809`), `consume_mana` (`:785`), `refund_failed_turn` (`:877`), `ai_action_costs` (7) | `mana_budget_test.dart` (8) | `[IMPLEMENTADO]` |
| Turno de gracia | Sin UI propia (aviso de 3 turnos) | `claim_mana_grace` (server-side, service role) | **Sin test en el repo Flutter** | `[IMPLEMENTADO]` según `docs/PRODUCT.md:123-137` |
| Recompensa diaria | `daily_reward_modal.dart` | `player_pergaminos`, `increment_pergaminos_max`, `daily_stats` | `economy_repository_helpers_test.dart` (15) | `[IMPLEMENTADO]` |
| Recompensas de nivel | `level_rewards_*` | `level_rewards`, `level_reward_status` (`:690`), `claim_level_rewards` (`:705`) | — | `[IMPLEMENTADO]` |
| Tienda de cosméticos | `shop_screen.dart:29` | `cosmetic_catalog` (40), `purchase_cosmetic` (`:627`), `craft_cosmetic` (`:653`) | `shop_screen_test.dart`, `economy_purpose_test.dart` (21) | `[IMPLEMENTADO]` |
| Inventario y equipado | `inventory_screen.dart:18` | `player_inventory`, `equip_cosmetic` (`:376`) | `economy_repository_helpers_test.dart` | `[IMPLEMENTADO]` |
| Paywall y planes | `paywall_screen.dart:32` | `subscription_plans` (3 activos de 8) | `paywall_plans_test.dart` (3), `subscription_plan_test.dart` (5) | `[IMPLEMENTADO]` |
| Entitlement premium | `subscription_providers.dart:54` | RevenueCat + `sync-entitlement`; `user_subscriptions` (15) | `premium_flow_test.dart` (4) | `[IMPLEMENTADO]` |
| Pagos reales | — | `payments` (**0 filas**) | — | `[PENDIENTE DE VALIDAR]`: no se ha cobrado nunca |

### 1.4 Social y periferia

| Funcionalidad | UI / archivo | Servidor | Test | Etiqueta |
|---|---|---|---|---|
| Gremio (mesas) | `chat_rooms_screen.dart:48` | `chat_rooms` (6), `join_table` (`:446`), `leave_table` (`:205`), `guild_announcements` (4) | `guild_master_stream_test.dart` (3) — **solo el streaming del Maestre** | `[PARCIAL]` |
| Sala de voz (sillas, presencia) | `voice_room_screen.dart:25` | `livekit-token`, `claim_seat` (`:473`), `request_seat` (`:490`), `stand_up` (`:515`), `report_presence`, `user_presence`; `chat_room_messages` (**0**), `chat_room_participants` (**0**) | **Sin test** | `[PARCIAL]` |
| Maestre de Mesa (chat) | `guild_master_floating_banner.dart:130-137` | `guild_chat` (gratis) → `llm-proxy` | `guild_master_stream_test.dart` (3) | `[IMPLEMENTADO]` |
| Misiones (diarias/semanales) | `missions_screen.dart:16`, `mission_spotlight_widget.dart:90,120` | `mission_instances` (637), `mission_templates` (35), `claim_mission_reward` (`mission_repository.dart:189`), `rotate_daily_missions` | `mission_models_test.dart` (24), `mission_card_test.dart`, `mission_claim_result_test.dart`, `mission_progress_service_test.dart`, `mission_visibility_test.dart`, `mission_spotlight_test.dart` | `[IMPLEMENTADO]` |
| Informe semanal | `weekly_report_screen.dart:19`, `weekly_report_card.dart:44` | `get_weekly_report` (`weekly_report_service.dart:26`); `weekly_stats` (**0**) | `weekly_report_test.dart` (12) | `[IMPLEMENTADO]` |
| Repaso SRS de vocabulario | `srs_review_card.dart`, `srs_flashcard_modal.dart` | `user_vocabulary` (79), `vocabulary_reviews`, `record_vocabulary_review` (`dashboard_repository_impl.dart:682`), `curate_session_vocabulary` (`conversation_repository_impl.dart:702`) | `vocabulary_curation_test.dart` (14) | `[IMPLEMENTADO]` |
| Leaderboard | `progress_tab_view.dart:489` (`LeaderboardSection`) | `get_leaderboard` (`dashboard_providers.dart:652`) | `overflow_test.dart` (layout) | `[PARCIAL]`: nombres anonimizados a `Cazador XXXX` (`progress_tab_view.dart:527`) |
| Ajustes (idioma, CEFR, corrección, borrado, exportación) | `settings_screen.dart:24` | `user_settings`; `export_my_data` (`:470`), `delete_my_account` (`:522`) | `app_settings_launcher_test.dart`, `tts_settings_sheet_test.dart` | `[IMPLEMENTADO]` |
| Perfil (nombre, clase, avatar, memorias) | `profile_edit_screen.dart:18` | `users`, `user_language_profiles` (guard `guard_language_profile`) | **Sin test** | `[IMPLEMENTADO]` |
| Recordatorios locales | `notification_providers.dart:71` (`ReminderSync`) | `device_tokens`, `user_settings` (hora/días) | `reminder_schedule_test.dart` (19) | `[IMPLEMENTADO]` |
| Widget de pantalla de inicio | `home_widget_providers.dart:46` | `daily_stats`, `player_streaks` | `home_widget_launch_test.dart`, `home_widget_snapshot_test.dart` (9) | `[IMPLEMENTADO]` |
| Meta diaria (anillo) | `dashboard_screen.dart:399` | `get_daily_goal_progress` (`dashboard_providers.dart:45`), `claim_daily_goal_celebration` (`:71`) | `daily_goal_progress_test.dart` (6) | `[IMPLEMENTADO]` |
| Retorno tras inactividad | `WelcomeBackCard` (`dashboard_screen.dart:397`) | `learning_evidence` (`dashboard_providers.dart:183`) | `welcome_back_test.dart` (4) | `[IMPLEMENTADO]` |
| Feedback sensorial | `core/` (vibración/sonido) | local | `sensory_feedback_test.dart` (6) | `[IMPLEMENTADO]` |
| Analítica de eventos | `core/services/retention_analytics.dart` | `retention_events`/`analytics_events` | `analytics_taxonomy_test.dart` (8) | `[IMPLEMENTADO]` |
| Navegación y contrato de rutas | `lib/app/router.dart:33-140` | — | `router_contract_test.dart` (5), `router_routes_test.dart` (2), `navigation_decision_test.dart` (4) | `[IMPLEMENTADO]` |

---

## 2. Mapa de rutas (20) → pantalla

Fuente: `lib/app/router.dart:33-140`. Todas en `lib/`.

| # | Ruta | Pantalla | Archivo | Entradas detectadas |
|---|---|---|---|---|
| 1 | `/splash` | `SplashScreen` | `app/splash_screen.dart` | arranque (`:86` → `/`) |
| 2 | `/` | `WelcomeScreen` | `features/onboarding/.../welcome_screen.dart` | splash; logout (`settings_screen.dart:570`) |
| 3 | `/onboarding` | `OnboardingScreen` | `features/onboarding/.../onboarding_screen.dart` | welcome (`:296,684`) |
| 4 | `/mini-conversation` | `MiniConversationScreen` | `features/onboarding/.../mini_conversation_screen.dart` | fin de onboarding (`onboarding_screen.dart:396`) → `/home` (`:157`) |
| 5 | `/oracle-test` | `ConversationScreen(oracleMode)` | `features/conversation/.../conversation_screen.dart` | quick access (`dashboard_screen.dart:507`), jefe (`boss_exam_card.dart:139`), checkpoint (`level_checkpoint_banner.dart:117`) |
| 6 | `/home` | `DashboardScreen` | `features/dashboard/.../dashboard_screen.dart` | muchas (fin de flujos) |
| 7 | `/conversation` | `ConversationScreen` | idem | ruta (`learning_path_roadmap.dart:721,774`), guardián (`dungeon_guardian_screen.dart:615`), sala de voz (`voice_room_screen.dart:1237`) |
| 8 | `/summary` | `SessionSummaryScreen` | `features/dashboard/.../session_summary_screen.dart` | cierre de conversación (`conversation_screen.dart:131`) |
| 9 | `/paywall` | `PaywallScreen` | `features/subscription/.../paywall_screen.dart` | badge PRO (`dashboard_screen.dart:418`), guardián (`:211`) |
| 10 | `/profile-edit` | `ProfileEditScreen` | `features/dashboard/.../profile_edit_screen.dart` | pestaña Estado (`progress_tab_view.dart:137`) |
| 11 | `/chat-rooms` | `ChatRoomsScreen` | `features/chat_rooms/.../chat_rooms_screen.dart` | pestaña Gremio (`dashboard_screen.dart:374`, modo tab); sala de voz (`voice_room_screen.dart:192`) |
| 12 | `/voice-room` | `VoiceRoomScreen` | `features/chat_rooms/.../voice_room_screen.dart` | mesas (`chat_rooms_screen.dart:441,768,774,880`), Maestre (`guild_master_floating_banner.dart:111,113`) |
| 13 | `/shop` | `ShopScreen` | `features/economy/.../shop_screen.dart` | quick access (`dashboard_screen.dart:500`), inventario (`inventory_screen.dart:226`) |
| 14 | `/inventory` | `InventoryScreen` | `features/economy/.../inventory_screen.dart` | gremio (`chat_rooms_screen.dart:602`), tienda (`shop_screen.dart:401`) |
| 15 | `/dungeon-guardian` | `DungeonGuardianScreen` | `features/economy/.../dungeon_guardian_screen.dart` | conversación sin maná (`conversation_screen.dart:220`) |
| 16 | `/boss-result` | `BossExamResultScreen` | `features/boss_exam/.../boss_exam_result_screen.dart` | fin del jefe (`conversation_screen.dart:1971`) |
| 17 | `/my-errors` | `MyErrorsScreen` | `features/corrections/.../my_errors_screen.dart` | quick access (`dashboard_screen.dart:528`) |
| 18 | `/weekly-report` | `WeeklyReportScreen` | `features/weekly_report/.../weekly_report_screen.dart` | tarjeta (`weekly_report_card.dart:44`) |
| 19 | `/listening` | `ListeningQuizScreen` | `features/listening/.../listening_quiz_screen.dart` | tarjeta de ruta (`listening_path_card.dart:48`) |
| 20 | `/missions` | `MissionsScreen` | `features/missions/.../missions_screen.dart` | spotlight (`mission_spotlight_widget.dart:90,120`) |

**Sin entrada de navegación detectada `[PARCIAL]`:**
- `/listening` y `/weekly-report` solo se alcanzan si sus tarjetas se pintan en
  el dashboard; con 0 intentos y `weekly_stats` vacío, es probable que el
  usuario nunca las vea. `[PENDIENTE DE VALIDAR]` (requiere ejecución).

---

## 3. Medición de datos (30-oct-2026)

Consultas de solo lectura a `public` en el proyecto `sipiumfdpvnszthykyog`.

| Tabla | Filas | Lectura |
|---|---|---|
| `users` | 68 | Cohorte pequeña, mayoritariamente de prueba |
| `conversations` / `messages` | 70 / 771 | Uso real del núcleo |
| `oracle_assessments` / `oracle_turns` | 79 / 85 | Función más ejercitada |
| `user_vocabulary` | 79 | Curación funcionando |
| `ai_usage_logs` | 54 | P-14 en marcha (`stt_transcribe` 16, `dungeon_turn` 13, `oracle_turn` 8) |
| `mission_instances` | 637 | Generación masiva por cron |
| `mana_transactions` | 222 | La economía de consumo se mueve |
| `aura_session_awards` | 12 | El Aura se acredita |
| `practice_sessions` | **2** | Tabla "oficial" de práctica casi vacía |
| `user_subscriptions` / `payments` | 15 / **0** | Sin ingresos |
| `boss_exam_attempts` | **0** | Creada 29-oct |
| `listening_attempts` | **0** | Creada 29-oct |
| `corrections` | **0** | Creada 29-oct; escritura best-effort (`corrections_repository.dart:57-68`) |
| `chat_room_messages` / `chat_room_participants` | **0 / 0** | Salas sembradas 19-ago, nunca usadas |
| `weekly_stats` | **0** | El informe calcula al vuelo |

Catálogos (para dimensión del contenido): `scenarios` 500 · `lesson_catalog_index`
140 · `guild_quest_pool` 199 · `mission_templates` 35 · `hunter_titles` 24 ·
`hunter_classes` 8 · `prestige_ladder` 21 · `cosmetic_catalog` 40 ·
`mana_potions` 7 · `mana_gems` 8 · `listening_exercises` 3 ·
`oracle_questions` 7 · `achievements` 6 · `chat_rooms` 6 · `cefr_levels` 7 ·
`guild_battle_pass` 23 · `guild_announcements` 4.

`[PENDIENTE DE VALIDAR]`: si los 68 usuarios son reales o de prueba, y si la base
medida es la de producción o un proyecto de desarrollo. Requiere acceso a Play
Console/RevenueCat y a la lista de proyectos Supabase.

---

## 4. Cobertura de pruebas (741 casos · 88 archivos)

| Área | Archivos representativos | Casos |
|---|---|---|
| Conversación, voz y TTS | `conversation_flow`, `conversation_repository_http`, `sse_chat_decoder`, `hold_to_talk_gesture`, `conversation_tts_notifier`, `tts_settings_sheet` | ~30 |
| Evaluación de metas | `goal_evaluation_gate`, `goal_evaluation_golden`, `goal_evaluation_robustness` | ~20 |
| Correcciones | `corrections_logic`, `correction_turn_policy`, `correction_chip` | ~26 |
| Misiones | `mission_models`, `mission_progress_service`, `mission_visibility`, `mission_spotlight`, `mission_card`, `mission_claim_result` | ~45 |
| Economía y tienda | `economy_purpose`, `economy_repository_helpers`, `shop_screen`, `mana_budget`, `refund_result` | ~50 |
| Aura, rango y nivel | `aura_system`, `hunter_level`, `skill_band`, `streak_rules` | ~40 |
| Jefe / placement | `boss_exam_result`, `boss_exam_rules`, `boss_exam_status`, `boss_exam_card`, `placement_outcome` | ~25 |
| Listening | `listening_quiz_screen`, `listening_grading`, `listening_models`, `listening_session`, `listening_path_card` | ~25 |
| Informe semanal | `weekly_report` | 12 |
| Resumen de sesión | `session_learned_summary`, `session_drop_result`, `remedial_lesson` | ~38 |
| Rutas y navegación | `router_contract`, `router_routes`, `navigation_decision` | 11 |
| UI y accesibilidad | `overflow`, `text_scale`, `app_contrast`, `golden/*`, `bundled_fonts`, `l10n_encoding` | ~30 |
| Periferia | `reminder_schedule`, `home_widget_*`, `analytics_taxonomy`, `sensory_feedback`, `welcome_back` | ~45 |

### 4.1 Huecos de cobertura (funcionalidad sin test)

| Funcionalidad | Por qué importa | Evidencia |
|---|---|---|
| Flujo de onboarding completo | Es el embudo de entrada y no tiene ni un `testWidgets` | no hay `onboarding_test.dart` en `test/` |
| Creación de personaje / clases | Lee `hunter_classes` con fallback en memoria | `hunter_classes_providers.dart:18` |
| Sala de voz (LiveKit, sillas, cola) | 500+ líneas de estado colaborativo sin pruebas | `voice_room_screen.dart:34` |
| Mis errores (pantalla) | La lógica está probada, la pantalla no | `my_errors_screen.dart:20` |
| Perfil (edición) | Escribe en `users` y `user_language_profiles` | `profile_edit_screen.dart:18` |
| `claim_mana_grace` | Vive en `llm-proxy`; sin test Deno en el repo | `supabase/functions/llm-proxy/` |

Los Edge Functions **sí** tienen algún test propio
(`supabase/functions/llm-proxy/validation_test.ts`), pero no cubren el turno de
gracia ni la evaluación.

---

## 5. Lo que queda `[PENDIENTE DE VALIDAR]`

| Tema | Qué falta para cerrarlo |
|---|---|
| **Aspecto visual real** | Capturas en dispositivo (procedimiento en `docs/ui-ux-audit/screenshots/README.md:13-27`) + revisión con visión de imágenes |
| **Naturaleza de la base medida** | Confirmar si `sipiumfdpvnszthykyog` es producción y si los 68 usuarios son reales |
| **Ingresos** | Play Console + RevenueCat (`payments` = 0 no distingue "no vendido" de "no configurado") |
| **Rangos SS/SSS** | Revisar la intención de producto: ¿umbral de precisión o resto de una escala antigua? |
| **`corrections` = 0** | Reproducir una sesión con corrección y verificar que el `upsert` llega (la escritura traga errores: `corrections_repository.dart:66-68`) |
| **`weekly_stats` = 0** | Confirmar que `get_weekly_report` calcula en vivo y no depende de esa tabla |
| **Mesas fantasma del Maestre** | ¿Se decide leer `chat_rooms` o se acepta la ficción? (§01 §6.1) |
| **`practice_sessions` = 2** | Entender por qué la tabla "oficial" no registra lo que sí registra `aura_session_awards` (12) |
| **Lectura/escritura evaluadas** | Sigue sin existir; `docs/PRODUCT.md:11-13` lo declara fuera de alcance |
| **Localización del prestigio** | `get_prestige_title` devuelve `name_es` siempre (migración `20260813_mana_aura_redesign.sql:391`) |

---

## 6. Cómo mantener esta matriz

1. Si se añade una pantalla, **regístrala en `lib/app/router.dart`** y añade su
   fila en §2 (el `router_contract_test.dart` ya falla si falta una ruta
   esperada: `test/router_contract_test.dart`).
2. Si se añade una RPC, añádela a §1 con el `archivo:línea` de la llamada
   (`.rpc('nombre'`).
3. Si se crea una funcionalidad sin test, anótala en §4.1 en vez de omitirla.
4. Toda cifra de §3 caduca: vuelve a medirla con `select count(*)` antes de
   citarla en otro documento.
