# 18 — Inventario técnico

> Medición: 25-oct-2026. Rutas relativas a la raíz del repo.

---

## 1. Puntos de entrada

| Archivo | Rol |
|---|---|
| `lib/main.dart` | Arranque: fuentes, error tracker, Supabase, `ProviderScope` |
| `lib/app/app.dart` | `MaterialApp.router`, locale, presencia, `app_open` |
| `lib/app/router.dart` | 14 rutas + redirect central |
| `lib/app/navigation_resolver.dart` | Motor de decisión inicial |
| `lib/app/splash_screen.dart` | Splash 800 ms + warm-up |
| `android/app/src/main/AndroidManifest.xml` | Permisos y deep link |
| `supabase/functions/*/index.ts` | 6 Edge Functions |

---

## 2. Archivos por responsabilidad (no generados)

### `lib/app/`
`app.dart`, `router.dart`, `navigation_resolver.dart`, `splash_screen.dart`

### `lib/core/`
| Archivo | Responsabilidad |
|---|---|
| `ai/placement_ai.dart` | Evaluación del Oráculo (JSON, CEFR) |
| `cache/cached_future_controller.dart`, `cache/json_disk_cache.dart` | Caché en memoria/disco |
| `constants/api_constants.dart` | URLs, claves públicas, entitlement |
| `i18n/app_translations.dart`, `language_settings.dart`, `locale_provider.dart` | Idioma UI/aprendizaje |
| `services/revenuecat_service.dart` | SDK de compras |
| `services/retention_analytics.dart` | Eventos |
| `services/tavern_music_service.dart` | Música de fondo |
| `theme/*` | Colores, tipografía, spacing, radius, motion, elevación |
| `utils/error_tracker.dart`, `utils/text_diff_utils.dart` | Errores y diffs |
| `widgets/*` (13) | GlassCard, RunicButton, RpgAvatar, QuestCard, SegmentedBar, FloatingReward, ManaMeter, SystemSnack, CyberManhwaBackground, AnimatedCounter, DraggableMonster, ConfigurationError, SystemWindow |

### `lib/features/`
| Feature | Archivos clave |
|---|---|
| `auth` | `auth_repository_impl.dart`, `auth_providers.dart` |
| `onboarding` | `welcome_screen.dart`, `onboarding_screen.dart`, `character_creation_wizard.dart`, `onboarding_repository_impl.dart`, `cefr_rank.dart`, `hunter_class*` |
| `conversation` | `conversation_providers.dart` (1.495), `conversation_screen.dart` (1.462), `conversation_repository_impl.dart` (719), `conversation_state.dart`, `live_goals_tracker_bar.dart` |
| `chat_rooms` | `chat_rooms_screen.dart`, `voice_room_screen.dart`, `guild_master_floating_banner.dart`, repositorio (651) |
| `dashboard` | `dashboard_screen.dart`, `settings_screen.dart`, `profile_edit_screen.dart`, `session_summary_screen.dart`, `dashboard_repository_impl.dart` (881), `lesson_catalog.dart`, `aura_system.dart`, `hunter_level.dart`, `lesson_unlock_service.dart`, `title_evaluator.dart`, `progress_tab_view.dart`, `skills_radar_chart.dart`, `league_leaderboard_widget.dart`, `daily_quests_widget.dart` |
| `economy` | `economy_repository_impl.dart` (675), `dungeon_guardian_screen.dart`, `shop_screen.dart`, `inventory_screen.dart`, `daily_reward_modal.dart`, `session_drop_controller.dart`, `drop_loot.dart`, `mana_item_inventory.dart` |
| `missions` | `mission_models.dart` (421), `mission_repository.dart` (660), `mission_providers.dart` |
| `presence` | `presence_repository_impl.dart` (21), `presence_providers.dart` |
| `subscription` | `revenuecat` providers, `paywall_screen.dart`, `premium_status.dart` |
| `vocabulary` | `srs_grade.dart`, `srs_review_card.dart`, `srs_flashcard_modal.dart` |

Generados (no editar): `*.freezed.dart`, `*.g.dart`, `lib/l10n/app_localizations*.dart`.

---

## 3. Endpoints y RPC usados por el cliente

### Edge Functions
| Endpoint | Método | Cliente |
|---|---|---|
| `/functions/v1/llm-proxy/transcribe` | POST | `conversation_repository_impl.dart:40` |
| `/functions/v1/llm-proxy/chat` | POST (SSE y JSON) | `:105,234,304`; `placement_ai.dart:53` |
| `/functions/v1/lesson-generator` | POST | `lesson_generator_service.dart:70` |
| `/functions/v1/sync-entitlement` | POST | `subscription_repository_impl.dart:31` |
| `/functions/v1/livekit-token` | POST | `voice_room_screen.dart:88-100` |

### RPC Postgres invocadas
`consume_mana`, `get_mana_state`, `apply_session_rewards`, `add_aura_xp`,
`add_xp`, `add_gold`, `add_gems`, `add_fragments`, `advance_my_missions`,
`record_scenario_outcome`, `record_vocabulary_review`, `learning_evidence`,
`purchase_cosmetic`, `equip_cosmetic`, `equip_mana_item`, `desequip_mana_item`,
`get_leaderboard`, `claim_seat`, `request_seat`, `stand_up`, `join_table`,
`leave_table`, `moderator_stand`, `touch_presence`, `report_presence`,
`sync_entitlement`, `delete_my_account`*, `export_my_data`*.
(\* solo desde SQL/cliente; sin UI.)

### Tablas leídas/escritas (principales)
`users`, `user_settings`, `user_language_profiles`, `user_ai_profiles`,
`languages`, `cefr_levels`, `scenarios`, `conversations`, `messages`,
`user_scenario_goals`, `user_scenario_phrases`, `scenario_progress`,
`user_vocabulary`, `vocabulary_items`, `daily_stats`, `daily_fluency_stats`,
`speech_dna_metrics`, `user_subscriptions`, `subscription_plans`,
`mana_transactions`, `player_inventory`, `cosmetic_catalog`, `mission_templates`,
`mission_instances`, `reward_history`, `daily_challenges`, `chat_rooms`,
`chat_room_participants`, `chat_room_messages`, `seat_requests`,
`guild_announcements`, `guild_battle_pass`, `guild_collaborative_missions`,
`oracle_assessments`, `oracle_turns`, `achievements`, `user_achievements`,
`user_titles`, `analytics_events`, `api_request_logs`, `player_daily_state`.

---

## 4. Dependencias (pubspec)

**En uso:** `flutter_riverpod`, `go_router`, `dio`, `supabase_flutter`,
`google_sign_in`, `record`, `flutter_tts`, `livekit_client`, `just_audio`,
`fl_chart`, `google_fonts`, `shared_preferences`, `purchases_flutter`,
`purchases_ui_flutter`, `freezed_annotation`, `json_annotation`, `image_picker`,
`intl`, `cupertino_icons`.

**Declaradas sin uso (13):** `speech_to_text`, `video_player`, `lottie`,
`shimmer`, `web_socket_channel`, `flutter_secure_storage`, `logger`,
`url_launcher`, `cached_network_image`, `flutter_animate`, `riverpod_annotation`,
`hooks_riverpod`, `flutter_hooks`.

**Dev:** `flutter_test`, `flutter_lints`, `build_runner`, `freezed`,
`json_serializable`, `riverpod_generator`.

---

## 5. Configuración

| Archivo | Qué define |
|---|---|
| `pubspec.yaml` | Versión `1.0.21+22`, assets (fuentes, imágenes, música) |
| `l10n.yaml` | ARB, plantilla `app_en.arb`, salida `app_localizations.dart` |
| `analysis_options.yaml` | `flutter_lints`, sin overrides de severidad |
| `config.json` / `config.sample.json` | `--dart-define` (no versionado) |
| `opencode.json`, `.opencode/`, `.agents/` | Configuración de agentes (no afecta al runtime) |
| `android/app/build.gradle.kts` | `applicationId com.tutorsaas.tutorsaas`, firma release |
| `.github/workflows/ci.yml` | Analyze + Test |
| `supabase/functions/*/` | Código de las 6 funciones |
| `supabase/migrations/` | 164 `.sql` (49 con prefijo de 14 dígitos) |

---

## 6. Recursos

| Recurso | Contenido |
|---|---|
| `assets/google_fonts/` | Space Grotesk, Inter, JetBrains Mono (empaquetadas) |
| `assets/images/`, `avatars/` | Ilustraciones y avatares |
| `assets/music/` | Música de taberna |
| `web_admin/` | Panel React + Vite (8 páginas, `dist/` compilado) |
| `web/` | Manifest e iconos PWA (no usado por la app Android) |
| `scripts/dump_schema.ps1` | Utilidad de volcado de esquema |
| `docs/` | Documentación vigente + `archive/` histórico |

---

## 7. Artefactos y medición

| Artefacto | Tamaño | Fuente |
|---|---|---|
| AAB release | 104,0 MB | `docs/CONTEXTO_ACTUAL.md:21` (no re-medido) |
| APK release | 131,9 MB | ídem |
| Pruebas | 159 en verde | ejecución 25-oct-2026 |
| Analyzer | 0 errores / 35 warnings / 128 infos | ejecución 25-oct-2026 |
| Tablas / políticas / funciones | 77 / 122 / 58 | producción |
| Migraciones aplicadas | historial de Supabase (no reproducible en repo) | doc 08 |

---

## 8. Archivos y rutas citados con frecuencia en este audit

```
lib/features/conversation/presentation/providers/conversation_providers.dart
lib/features/conversation/data/repositories/conversation_repository_impl.dart
lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
lib/features/dashboard/data/models/lesson_catalog.dart
lib/features/dashboard/domain/models/{aura_system,hunter_level,lesson_unlock_service,lesson_halo,title_evaluator}.dart
lib/features/economy/data/repositories/economy_repository_impl.dart
lib/features/missions/data/repositories/mission_repository.dart
lib/features/dashboard/presentation/screens/{dashboard,settings,session_summary,profile_edit}_screen.dart
lib/features/conversation/presentation/screens/conversation_screen.dart
lib/core/ai/placement_ai.dart
lib/core/services/{revenuecat_service,retention_analytics}.dart
supabase/functions/llm-proxy/index.ts
supabase/functions/lesson-generator/index.ts
supabase/migrations/20261018000000_session_rewards_rpc.sql
supabase/migrations/20261019043716_guard_language_profile.sql
supabase/migrations/20261019044345_vocabulary_reviews_evidence.sql
supabase/migrations/20261019051325_scenario_progress.sql
```
