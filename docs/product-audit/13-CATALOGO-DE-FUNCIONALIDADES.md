# 13 — Catálogo de funcionalidades

> Matriz trazable. **Estado:** V (implementado y verificado en código) · P
> (parcial) · D (diseñado sin conexión) · X (no existe / código muerto) · NV (no
> verificable sin ejecutar).

---

## 1. Identidad y acceso

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| AUTH-01 | Registro por email | Crea cuenta Supabase; valida formato y ≥6 chars | Supabase Auth | `auth.users` | V | `welcome_screen.dart:651` |
| AUTH-02 | Login por email | Email+contraseña | Supabase Auth | sesión | V | `welcome_screen.dart:686` |
| AUTH-03 | Login con Google | `signInWithIdToken` con `serverClientId` | Google Identity | `auth.users` | V | `auth_repository_impl.dart:22-54` |
| AUTH-04 | Recuperar contraseña | Envía email de reset | Supabase Auth | — | V | `welcome_screen.dart:607` |
| AUTH-05 | Reenviar confirmación | Reenvía email de alta | Supabase Auth | — | V | `welcome_screen.dart:674` |
| AUTH-06 | Login anónimo | Soportado por el repositorio | Supabase Auth | — | X (sin UI) | `auth_repository_impl.dart:57` |
| AUTH-07 | Cerrar sesión | Desde dashboard y ajustes | Supabase Auth | — | V | `dashboard_screen.dart:535` |
| AUTH-08 | Borrar cuenta | RPC existe, sin pantalla | `delete_my_account` | cascada | X (sin UI) | RPC en prod |
| AUTH-09 | Exportar datos | RPC existe, sin pantalla | `export_my_data` | JSON | X (sin UI) | RPC en prod |
| AUTH-10 | Redirección por estado | Sin sesión→welcome; sin perfil→onboarding | Supabase | `user_language_profiles` | V | `navigation_resolver.dart:58-84` |

## 2. Onboarding y perfil

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| ONB-01 | Idioma nativo | 8 opciones | — | `users.native_language` | V | `onboarding_screen.dart:56-107` |
| ONB-02 | Idioma objetivo | Solo inglés | `languages` | `user_language_profiles.language_id` | V | `onboarding_screen.dart:852-887` |
| ONB-03 | Examen del Oráculo | Conversación oral adaptativa | LLM | `oracle_assessments` | V | `conversation_providers.dart:715+` |
| ONB-04 | Salto a PRE-A1 | Fija nivel y rango F | — | `cefr_level_id`, `game_rank` | V | `onboarding_screen.dart:179-190` |
| ONB-05 | Creación de personaje | Clase, meta diaria, intereses | `hunter_classes` | `user_settings`, perfil | V/P | `character_creation_wizard.dart` |
| ONB-06 | Nombre del personaje | **No se pide** | — | — | X | `character_creation_wizard.dart:13-23` |
| ONB-07 | Perfil de IA | Resumen pedagógico | — | `user_ai_profiles` | P (se escribe, no se lee) | `onboarding_repository_impl.dart:138-155` |
| PRO-01 | Editar perfil | Nombre, bio, idioma, clase | Storage | `users` | V | `profile_edit_screen.dart` |
| PRO-02 | Subir avatar | Cámara/galería → bucket `avatars` | Storage RLS | `users.avatar_url` | V (RLS NV) | `profile_edit_screen.dart:119-126` |
| PRO-03 | Preferencias | Corrección, tutor, cadencia, meta | — | `user_settings` | V | `settings_screen.dart:196-277` |
| PRO-04 | Idiomas de UI/aprendizaje | es/en/pt + seguir dispositivo | local + BD | `user_settings` | V | `language_settings.dart` |
| PRO-05 | Cambiar nivel CEFR | Chips en ajustes | — | — | X (bloqueado por trigger) | `settings_screen.dart:509-530` |

## 3. Aprendizaje

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| LRN-01 | Catálogo de 140 lecciones | 20 por nivel CEFR | — | Dart | V | `lesson_catalog.dart:96` |
| LRN-02 | 500 escenarios en BD | 20/80 por nivel y idioma | — | `scenarios` | V (prod) | `scenarios` |
| LRN-03 | Recomendación por nivel/interés | Filtra por CEFR exacto y ordena por interés | BD | `user_settings` | V | `dashboard_repository_impl.dart:73-245` |
| LRN-04 | Ruta por Etapas | Desbloqueo secuencial por nivel | catálogo | `user_scenario_goals` | V | `lesson_unlock_service.dart` |
| LRN-05 | Halo de progreso | Color por % de metas | — | — | V | `lesson_halo.dart` |
| LRN-06 | Estrellas | 1-3 según metas y frases | BD | — | P (criterio distinto al desbloqueo) | `dashboard_repository_impl.dart:186-195` |
| LRN-07 | Conversación por voz | graba→STT→LLM→TTS | DeepSeek, Groq | `messages` | V | doc 07 |
| LRN-08 | Chat de texto | Drawer de teclado | LLM | `messages` | V | `conversation_screen.dart:1140-1180` |
| LRN-09 | Metas en vivo | Barra con objetivos | LLM | `user_scenario_goals` | V | `live_goals_tracker_bar.dart` |
| LRN-10 | Frases útiles | Lista y marca de uso | LLM/BD | `user_scenario_phrases` | V | `repo:627-639` |
| LRN-11 | Tópicos sugeridos | 20 chips | — | — | V | `conversation_screen.dart:1198-1212` |
| LRN-12 | Repetición TTS | Re-escuchar burbuja | `flutter_tts` | — | V | `:1433-1438` |
| LRN-13 | Resumen de sesión | Cifras y correcciones | — | — | P (cifras fijas) | `session_summary_screen.dart` |
| LRN-14 | Siguiente lección | Navega a la siguiente del nivel | catálogo | — | P | `session_summary_screen.dart:394-435` |
| LRN-15 | Ver vocabulario desde resumen | Solo snackbar | — | — | X | `:337-344` |
| LRN-16 | Lección de refuerzo por IA | Genera sub-misión | `lesson-generator` | `scenarios` | D (roto) | doc 07 §2.4 |
| LRN-17 | Examen de promoción | Repite el Oráculo | LLM | `oracle_assessments` | P (params ignorados) | `router.dart:72-84` |

## 4. Gamificación y economía

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| GAM-01 | Maná por acción | Cobro server-side con límite diario | `consume_mana` | `mana_transactions` | V | doc 06 §3.1 |
| GAM-02 | Límite diario de maná | 200/día por defecto | `user_subscriptions.daily_limit` | idem | V | `20260818_03_mana_rpcs.sql` |
| GAM-03 | Maná por plan | 3.000-25.500/mes | RevenueCat/webhook | `user_subscriptions` | V | doc 10 |
| GAM-04 | Compra de maná | Pociones/packs | — | `mana_potions`, `mana_gems` | X (sin UI) | §doc 10 |
| GAM-05 | XP | `minutos×10` + misiones | — | `xp_points` | V | `apply_session_rewards` |
| GAM-06 | Nivel de cazador | `1 + xp/1000` | — | — | V | `hunter_level.dart` |
| GAM-07 | Rango | Derivado del CEFR | — | `game_rank` | V | `cefr_rank.dart` |
| GAM-08 | Oro | `objetivos×(10+bonus)` | — | `total_gold` | V | `apply_session_rewards` |
| GAM-09 | Gemas | Recompensa de misiones | `add_gems` | `total_gems` | P (sin sumidero) | `mission_repository.dart:257` |
| GAM-10 | Fragmentos | `objetivos×(5+bonus)` | — | `fragments` | P (invisible) | `apply_session_rewards` |
| GAM-11 | Aura | Fórmula ponderada + desbloqueo | radar | `aura_xp`, `skill_radar` | V | `aura_system.dart` |
| GAM-12 | Prestigio | 21 escalones por aura XP | `prestige_ladder` | `prestige_title_code` | V | prod |
| GAM-13 | Títulos | 5 líneas por umbrales | radar | `user_titles` | V | `title_evaluator.dart` |
| GAM-14 | Recompensa diaria | Escalón por día | — | `player_daily_state` | V | `daily_reward_modal.dart` |
| GAM-15 | Misiones diarias | Motor server + 3 triggers | `advance_my_missions` | `mission_instances` | V (doble conteo) | doc 06 §6 |
| GAM-16 | Misiones semanales | Se crean, sin UI | ídem | ídem | P | idem |
| GAM-17 | Misiones secretas/eventos/gremio | Modelos y tablas | — | varias | D | idem |
| GAM-18 | Reclamo de misión | Acredita XP+gemas desde el cliente | `add_xp`, `add_gems` | `reward_history` | P (importe cliente) | `mission_repository.dart:230-276` |
| GAM-19 | Racha | Visible en dashboard | — | `current_streak` | P (no se actualiza) | doc 08 §5 |
| GAM-20 | Freeze de racha | Compra | — | `player_streaks` | X | `economy_repository_impl.dart:401` |
| GAM-21 | Tienda de cosméticos | Solo oro | `purchase_cosmetic` | `player_inventory` | V | `shop_screen.dart:64-91` |
| GAM-22 | Inventario / equipar | Filtros y equipado | `equip_cosmetic` | `player_inventory` | V | `inventory_screen.dart` |
| GAM-23 | Auras bloqueadas | Requiere Aura despierta | — | — | V | `inventory_screen.dart:43-54` |
| GAM-24 | Leaderboard | Top 10 XP global | `get_leaderboard` | perfiles | P (sin ligas) | `dashboard_providers.dart:352` |
| GAM-25 | Logros | 6 en catálogo, auto-unlock cliente | — | `user_achievements` | P | `dashboard_repository_impl.dart:288-350` |
| GAM-26 | Drop de sesión | XP 15×rareza + objeto decorativo | `add_xp` | — | P (repite al reabrir) | `session_drop_controller.dart` |
| GAM-27 | Descubrimiento de escena | `record_scenario_outcome` | — | `scenario_progress` | V | migración `20261019051325` |

## 5. Social y salas

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| SOC-01 | Salón del gremio | Lista de mesas, presencia, anuncios | Realtime | `chat_rooms`, participantes | V (sin uso) | `chat_rooms_screen.dart` |
| SOC-02 | Crear mesa | Diálogo + insert | — | `chat_rooms` | V | `:314-469` |
| SOC-03 | Sala de voz | Token LiveKit, asientos | LiveKit | `chat_room_participants` | V (NV sin red) | `voice_room_screen.dart` |
| SOC-04 | Cola de asientos | FIFO `request_seat` | — | `seat_requests` | V | `:221-243` |
| SOC-05 | Moderación | Long-press para bajar a alguien | `moderator_stand` | idem | V | `:267-284` |
| SOC-06 | Chat de texto de sala | Bottom sheet | — | `chat_room_messages` | V (0 msgs) | `:310-466` |
| SOC-07 | Maestre de Mesa | Banner flotante con IA | LLM | — | P | `guild_master_floating_banner.dart` |
| SOC-08 | Battle Pass | Solo lectura de nivel | — | `guild_battle_pass` | D | `chat_rooms_screen.dart:1011-1064` |
| SOC-09 | Música de taberna | `just_audio` | assets | — | V | `tavern_music_service.dart` |
| SOC-10 | Presencia global | Heartbeat + purga 180 s | cron | `chat_room_participants` | V | `report_presence` |

## 6. Monetización

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| MON-01 | Paywall nativo | UI de RevenueCat | RevenueCat | offerings | V (NV) | `paywall_screen.dart:122` |
| MON-02 | Compra de suscripción | Play Billing | Play/RC | `user_subscriptions` | V (NV) | doc 10 |
| MON-03 | Restaurar compras | `restorePurchases` | RC | — | V | `:72-95` |
| MON-04 | Customer Center | Gestión de suscripción | RC | — | V | `:170-183` |
| MON-05 | Webhook de compras | Idempotente por `event.id` | EF | `revenuecat_events` | V | doc 10 |
| MON-06 | Reconciliación | `sync-entitlement` al abrir | EF | `user_subscriptions` | V | `subscription_providers.dart:51` |
| MON-07 | Estado premium en app | RC + fallback BD | — | — | V | `premium_status.dart` |
| MON-08 | Trial gratuito | — | — | — | X | doc 10 §7 |

## 7. Analítica, operación y calidad

| ID | Funcionalidad | Descripción | Dependencias | Datos | Estado | Evidencia |
|---|---|---|---|---|---|---|
| OPS-01 | Eventos de producto | `analytics_events` | Supabase | 8 tipos | P | doc 17 |
| OPS-02 | Coste de IA | `ai_usage_logs` | — | 0 filas | X | prod |
| OPS-03 | Errores | `ErrorTracker` local | — | — | P (no envía) | `error_tracker.dart` |
| OPS-04 | Panel admin web | 8 páginas React | RLS admin | catálogos, usuarios | V (no auditado a fondo) | `web_admin/src/pages/` |
| OPS-05 | Cron de misiones | 00:05 UTC | EF/cron | `mission_instances` | V | prod |
| OPS-06 | Purga de presencia | Cada minuto (>180 s) | cron | participantes | V | prod |
| OPS-07 | Purga de logs | 03:15 UTC | cron | logs | V | prod |
| OPS-08 | CI analyze+test | GitHub Actions | — | — | V | `.github/workflows/ci.yml` |
| OPS-09 | CD / despliegue | Manual | — | — | X | doc 02 §8 |
| OPS-10 | Export/borrado de datos | RPC sin UI | — | — | X (UI) | doc 09 |
| DEV-01 | Modo desarrollador | Fuerza onboarding + **borra perfil** | — | `user_language_profiles` | V (sin gate) | `settings_screen.dart:1257-1346` |

