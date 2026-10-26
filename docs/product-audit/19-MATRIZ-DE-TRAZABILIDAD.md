# 19 — Matriz de trazabilidad

> Cada hallazgo relevante con su evidencia. **Estado:** V (verificado en código) ·
> VP (verificado en producción) · E (ejecutado: tests/analyzer) · I (inferencia,
> no hecho).

| ID | Hallazgo o conclusión | Doc | Origen | Símbolo / sección | Estado |
|---|---|---|---|---|---|
| T-01 | El proyecto tiene 14 rutas y un redirect central por estado | 03 | `lib/app/router.dart` | `routerProvider` :24-138 | V |
| T-02 | Sin sesión → Welcome; sin perfil → onboarding; con perfil → home | 03, 09 | `lib/app/navigation_resolver.dart` | `NavigationDecisionEngine.resolve` :58-84 | V |
| T-03 | La app no tiene push ni permiso de notificaciones | 11 | `AndroidManifest.xml:2-3`; `pubspec.yaml` | — | V |
| T-04 | El catálogo Dart tiene 140 lecciones (20 por nivel) | 05 | `lesson_catalog.dart:96`; `test/lesson_catalog_test.dart:12-23` | `LessonCatalog.catalog` | E |
| T-05 | Producción tiene 500 escenarios (PRE-A1 20 + 80/nivel × 4 idiomas) | 05, 08 | `select difficulty_level, count(*) from scenarios` | — | VP |
| T-06 | El dashboard prioriza `scenarios` sobre el catálogo Dart | 05 | `dashboard_repository_impl.dart:100-115,224-241` | `getRecommendedLessons` | V |
| T-07 | El desbloqueo exige 75 % de metas (no 70/80 como dicen los comentarios) | 05 | `lesson_unlock_service.dart:39-55` | `passThreshold`, `meetsThreshold` | V+E |
| T-08 | Las estrellas usan 100 % de metas (criterio distinto al desbloqueo) | 05, 03 | `dashboard_repository_impl.dart:183-195` | `isCompleted`, `stars` | V |
| T-09 | El LLM evalúa las metas en cada turno y persiste en `user_scenario_goals` | 05, 07 | `conversation_providers.dart:1350-1352`; `repo:229-292` | `evaluateGoals` | V |
| T-10 | La evaluación de metas no filtra IDs devueltos por el modelo | 07 | `conversation_repository_impl.dart:285-286` | `evaluateGoals` | V |
| T-11 | El vocabulario se extrae con regex y traducción hardcodeada (21 palabras) | 05 | `conversation_repository_impl.dart:489-562` | `saveVocabulary` | V |
| T-12 | El SRS es SM-2 en servidor con `delayed_retrieval` | 05, 08 | `record_vocabulary_review`; `20261019044345…sql:79-116` | RPC | VP |
| T-13 | XP = minutos × 10; oro = objetivos × (10+bonus); bonus por CEFR | 06 | `20261018000000_session_rewards_rpc.sql:90-101` | `apply_session_rewards` | V |
| T-14 | Recompensa de sesión idempotente por `session_id` | 06 | ídem :75-88 | ídem | V |
| T-15 | El resumen muestra "+80 XP" fijo y no consume esa respuesta | 03, 15 | `session_summary_screen.dart:216-222,312` | `_buildRewardSummary` | V |
| T-16 | Reabrir `/summary` acredita XP extra (drop no idempotente) | 06, 16 | `session_drop_controller.dart:24,32-50` | `initState` | V |
| T-17 | Nivel = 1 + xp/1000 | 06 | `hunter_level.dart:13-19` | `HunterLevel.levelFor` | V+E |
| T-18 | Rango = CEFR (no se gana con XP) | 06 | `cefr_rank.dart:13-35` | `CefrRank.gameRankFromCefr` | V |
| T-19 | Aura = 0.25 fluidez + 0.25 vocab + 0.20 fonética + 0.10 gramática + 0.10 metas + 0.05 racha + 0.05 rango | 06 | `aura_system.dart:126-150` | `AuraSystem.computePower` | V+E |
| T-20 | 21 escalones de prestigio hasta 260.000 de aura XP | 06 | `prestige_ladder` (prod) | — | VP |
| T-21 | Maná: 12 turno, 15 Oráculo, 8 chat, 30 cierre, 100 lección IA | 06, 07 | `ai_action_costs` (prod); `conversation_providers.dart:1148-1153,820` | `_consumeManaForAction` | V+VP |
| T-22 | `llm-proxy` no valida maná: el cobro es cliente | 07, 16 | `llm-proxy/index.ts:101-268` | handler | V |
| T-23 | Cuota del proxy: 30 req/min, fail-open | 07 | `llm-proxy/index.ts:40,90-98` | `check_llm_quota` | V |
| T-24 | El modelo real es `deepseek-v4-flash`, no `deepseek-chat` | 07 | `llm-proxy/index.ts:36-37` vs `system_ai_settings` | allow-list | V+VP |
| T-25 | El error de IA se muestra y guarda como mensaje del tutor | 07, 15 | `conversation_repository_impl.dart:207-217` | `_friendlyError` | V |
| T-26 | El generador de refuerzo falla por `skill_focus` inválido y se silencia | 07, 16 | `lesson_generator_service.dart:18-24`; `lesson-generator/index.ts:178-180` | `_pickWeakest` | V |
| T-27 | `ai_usage_logs` está vacía: sin trazabilidad de coste | 07, 17 | `count(*)` en producción | — | VP |
| T-28 | `retention_events` no existe; la analítica va a `analytics_events` | 08, 17 | `information_schema` | — | VP |
| T-29 | 77 tablas, 122 políticas, 58 funciones, 3 cron | 02, 08 | consultas a producción | — | VP |
| T-30 | Todas las tablas tienen RLS | 08 | `pg_class.relrowsecurity` | — | VP |
| T-31 | `guard_language_profile` descarta escrituras del cliente en campos de progreso | 08, 09 | `20261019043716_guard_language_profile.sql:31-52` | trigger | VP |
| T-32 | `logPracticeSession` escribe racha/minutos y esas escrituras se descartan | 08, 11 | `dashboard_repository_impl.dart:594-603` vs T-31 | `logPracticeSession` | V |
| T-33 | Los chips de CEFR de ajustes no cambian el nivel | 09 | `settings_screen.dart:509-530` + T-31 | `updateLanguagePreferences` | V |
| T-34 | Botón de dev borra `user_language_profiles` sin gate | 09, 16 | `settings_screen.dart:179,1312-1326` | `_buildDevToolsTile` | V |
| T-35 | No hay UI de borrar cuenta/exportar datos | 09 | RPC existen; sin referencias en `lib/` | — | V+VP |
| T-36 | 8 tipos de evento, sin propiedades | 17 | `retention_analytics.dart:27-41`; producción | `track` | V+VP |
| T-37 | 159 tests en verde; analyzer 0 errores/35 warnings/128 infos (exit 1) | 12 | ejecución 25-oct-2026 | — | E |
| T-38 | 13 dependencias declaradas sin uso | 02, 18 | 0 imports en `lib/` | — | V |
| T-39 | 533 misiones creadas, 7 completadas (1,3 %) | 06, 15 | `mission_instances` (prod) | — | VP |
| T-40 | 0 pagos, 0 inventario, 1 suscripción noble | 10 | `payments`, `player_inventory`, `user_subscriptions` | — | VP |
| T-41 | 8 planes en BD; 4 legacy inactivos con features inexistentes | 10 | `subscription_plans` (prod) | — | VP |
| T-42 | El paywall delega en RevenueCat y no lista planes propios | 03, 10 | `paywall_screen.dart:122` | `_openPaywall` | V |
| T-43 | `sync-entitlement` se invoca en cada creación del provider premium | 10 | `subscription_providers.dart:43-63` | `PremiumStatusNotifier` | V |
| T-44 | `add_xp`/`add_gold`/`add_gems` aceptan importes del cliente | 08, 16 | `pg_proc` (prod); `mission_repository.dart:252-258` | RPC | VP |
| T-45 | `add_mana_item` sin `auth.uid()` y ejecutable por `anon` | 08, 16 | `pg_proc` (prod) | RPC | VP |
| T-46 | Dos fuentes de racha sin reconciliación | 08, 11 | `player_streaks` vs `user_language_profiles` | — | V+VP |
| T-47 | El repo no reproduce el esquema; 33 migraciones sin archivo | 08 | `docs/runbooks/MIGRATION_STATUS.md` | — | V (doc) |
| T-48 | CI ejecuta analyze/test pero no hay CD | 02, 12 | `.github/workflows/ci.yml` | — | V |
| T-49 | Solo hay actividad en 4 de los últimos 30 días (1-2 usuarios/día) | 15, 17 | `analytics_events` | — | VP |
| T-50 | La marca aparece con 3 nombres distintos | 01 | `app.dart:31`; manifest; `pubspec.yaml:1` | — | V |
| T-51 | El onboarding no pide nombre y hardcodea motivación/personalidad | 09 | `onboarding_screen.dart:218-230`; `character_creation_wizard.dart:13-23` | — | V |
| T-52 | El examen del Oráculo no tiene tope de turnos ni timeout de cierre | 07 | `conversation_providers.dart:715-960` | `initOracleSession` | I (código) |
| T-53 | Las métricas de fluidez/pronunciación son estimaciones | 05 | `conversation_repository_impl.dart:669-733` | `logFluencyMetrics` | V |
