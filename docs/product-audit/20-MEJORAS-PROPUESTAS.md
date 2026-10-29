# Análisis de mejoras — Dungeon of English (TutorSaas)

> **Propósito de este documento:** servir como insumo para generar historias de usuario.
> Cada hallazgo (ID `H-xx`) y cada propuesta (ID `P-xx`) trae contexto, evidencia, impacto,
> alcance sugerido, criterios de aceptación candidatos, notas técnicas, dependencias y métricas.
>
> **Base:** auditoría estática de la versión `1.0.21+22` (25-oct-2026), documentos 00–19.
> **Limitación importante:** la auditoría no ejecutó la app y no hay usuarios reales (solo cuentas de prueba,
> actividad en 4 de los últimos 30 días). Las estimaciones de impacto son inferencias; marcadas con confianza
> **A** (alta, hecho en código/datos), **B** (media), **C** (hipótesis a validar).
>
> **Cómo usar con una IA para crear historias:** pídele que genere una historia por cada `P-xx`,
> usando el formato "Como [rol], quiero [acción], para [beneficio]", copiando los criterios de aceptación
> candidatos, y respetando las dependencias y la prioridad indicadas.

---

## 0. Resumen ejecutivo

1. **El núcleo funciona** (voz → transcripción → IA → TTS; 140 lecciones en código y 500 escenarios en BD; economía de maná en servidor).
2. **Lo que falla está alrededor del núcleo:**
   - El **bucle de recompensa está roto**: el resumen muestra cifras fijas y el servidor acredita otras.
   - **No hay retorno programado**: sin push ni email; la racha no se actualiza.
   - **Hay fallos que destruyen confianza** y no se miden (sin crash reporting, sin coste de IA).
   - **La economía es manipulable** desde el cliente.
3. **Recomendación:** congelar funciones nuevas hasta cerrar los bloques A (confianza) y B (observabilidad).
   Después construir retención (C), enganche (D) y pedagogía (E).

### Mapa de bloques

| Bloque | Tema | Prioridad | Dependencias |
|---|---|---|---|
| A | Confianza y seguridad (bugs que rompen la percepción o la economía) | P0 | — |
| B | Observabilidad y estabilidad técnica | P0/P1 | — |
| C | Retención y hábito | P1 | A (racha, resumen), B (eventos) |
| D | Enganche y dinamismo | P1/P2 | A, C |
| E | Pedagogía | P1/P2 | A, B |
| F | Monetización | P1/P2 | A, B (coste de IA) |
| G | Contenido, social y limpieza de producto | P2/P3 | — |

---

## 1. Bloque A — Confianza y seguridad

### H-01 · Resumen de sesión con cifras falsas
- **Evidencia:** `session_summary_screen.dart:216-222,312` muestra "+80 XP" fijo y racha "+1" como etiqueta fija;
  fluidez/pronunciación se calculan con defaults 0.85/0.80; duración inventada `max(60, turnos*45)` (`:35-52`).
  El servidor acredita `minutos × 10` XP, `objetivos × (10+bonus)` oro y `objetivos × (5+bonus)` fragmentos
  (`apply_session_rewards`).
- **Problema:** el momento de mayor carga emocional del bucle muestra datos que no coinciden con lo acreditado.
- **Impacto en usuario:** pierde la relación acción → recompensa; desconfía de todo número de la app. Confianza **A**.
- **Impacto en negocio:** menor retención; reseñas negativas por "números raros".
- **Datos que lo confirmarían:** comparación recompensa mostrada vs. `session_reward_ledger`.

**P-01 · Resumen con datos reales del servidor** (P0, esfuerzo M)
- **Alcance:** `endSession` debe devolver el resultado de `apply_session_rewards` (XP, oro, fragmentos, minutos reales,
  objetivos cumplidos) y pasarlo a `/summary` por parámetros o provider. Sustituir fluidez/pronunciación inventadas
  por métricas reales o etiquetarlas "estimadas".
- **Criterios de aceptación candidatos:**
  - El XP, oro y fragmentos mostrados son idénticos a los registrados en `session_reward_ledger` de esa sesión.
  - La duración mostrada es la real (`conversations.duration_seconds`).
  - Si la RPC falla, se muestra un estado explícito ("No pudimos acreditar tu recompensa, reintentar") y no una cifra inventada.
  - Reabrir `/summary` no recalcula ni vuelve a acreditar nada.
  - Ninguna cifra del resumen está hardcodeada.
- **Notas técnicas:** modelo `SessionResult` (Freezed) devuelto por `endSession`; eliminar constantes en `_buildRewardSummary`;
  la RPC ya es idempotente por `session_id`.
- **Métricas:** discrepancia mostrada/acreditada = 0 %; tasa de apertura de resumen sin error.

### H-02 · Drop de sesión repetible y decorativo
- **Evidencia:** `session_drop_controller.dart:24,32-50`: al reabrir `/summary` se vuelve a "tirar" el drop y se llama a `add_xp`
  (15 × rareza). El objeto es solo texto.
- **Problema:** XP farmeable y recompensa sin valor real. Confianza **A**.

**P-02 · Drop idempotente y con valor real** (P0, esfuerzo S–M)
- **Criterios:**
  - El drop se genera una sola vez por `session_id` (guardar en servidor, no en cliente).
  - Reabrir `/summary` muestra el mismo drop ya reclamado, sin acreditar de nuevo.
  - El drop puede ser un objeto real del inventario (cosmético, freeze de racha, poción) o se elimina la animación de objeto.
- **Notas:** crear RPC `claim_session_drop(session_id)` con tabla `session_drops(user_id, session_id, item_code, rarity)` única por sesión.
- **Dependencia:** P-01.

### H-03 · Racha rota
- **Evidencia:** `logPracticeSession` (`dashboard_repository_impl.dart:556-604`) intenta escribir `current_streak`, `longest_streak`,
  `total_minutes`, `last_practice_date`, pero el trigger `guard_language_profile` los descarta
  (`20261019043716_guard_language_profile.sql:41-44`). `apply_session_rewards` tampoco los toca. Además existen dos fuentes:
  `player_streaks` y `user_language_profiles.current_streak`.
- **Problema:** la racha, ancla principal de hábito, no avanza. Confianza **A**.

**P-03 · Racha y minutos por RPC del servidor** (P0, esfuerzo M)
- **Alcance:** RPC `SECURITY DEFINER` `register_practice(session_id)` que actualice `total_minutes`, `last_practice_date`,
  `current_streak`, `longest_streak` con regla de zona horaria definida, y que `endSession` invoque. Unificar fuente de verdad.
- **Reglas a definir (decisión de producto):** día calendario según zona horaria del usuario; mínimo de minutos para contar el día
  (sugerido: 1 meta cumplida o ≥3 min); qué pasa si pierde un día (freeze, ver P-12).
- **Criterios:**
  - Practicar un día nuevo incrementa la racha en 1; practicar dos veces el mismo día no la incrementa.
  - Un día sin práctica (sin freeze) reinicia la racha a 0 al siguiente cierre de sesión.
  - `longest_streak` nunca disminuye.
  - Se elimina la escritura inútil del cliente.
  - Existe una sola tabla/columna fuente de verdad documentada.
- **Tests:** unitarios de la lógica de fecha (cambio de día, zona horaria, DST).
- **Métricas:** % de usuarios con racha ≥3; distribución de rachas.

### H-04 · Banner "Racha en riesgo" siempre activo
- **Evidencia:** `progress_tab_view.dart:46-48` usa `invocations_used`, que nunca se incrementa.

**P-04 · Banner de racha basado en datos reales** (P0, esfuerzo S)
- **Criterios:**
  - Aparece solo si hay racha ≥1 y `last_practice_date` es ayer (no hoy) y faltan menos de N horas para medianoche local.
  - Desaparece al cumplir la práctica del día.
  - Muestra cuánto falta para mantenerla ("Practica 1 meta para salvar tu racha de 6 días").
- **Dependencia:** P-03.

### H-05 · Error de IA mostrado y guardado como mensaje del tutor
- **Evidencia:** `conversation_repository_impl.dart:207-217`: el texto del error se emite como contenido del asistente,
  se narra por TTS y se persiste en `messages`.
- **Impacto:** rompe la inmersión, contamina el historial enviado al modelo (24 mensajes) y puede filtrar detalles del proveedor. Confianza **A**.

**P-05 · Manejo de errores de IA como evento de sistema** (P0, esfuerzo M)
- **Criterios:**
  - Los errores no se guardan en `messages` ni se narran por TTS.
  - La UI muestra una burbuja de sistema distinta con botón "Reintentar" que reenvía el último turno.
  - Mensajes diferenciados: sin red, límite de cuota (429), error del proveedor, timeout.
  - Reintento automático con backoff exponencial (máx. 3 intentos) antes de mostrar el error.
  - Si el STT falla, se ofrece reintentar el audio o escribir el texto.
  - El error se registra con `ai_error(endpoint, code, retries)` (ver P-16).
- **Notas:** separar `ChatEvent` de `ChatMessage` en el estado; filtrar mensajes de error al armar el contexto.

### H-06 · Maná cobrado aunque la IA falle
- **Evidencia:** el cobro ocurre antes de llamar al modelo y solo `lesson-generator` reembolsa (`:210-214`).

**P-06 · Reembolso automático de maná por fallo** (P0, esfuerzo M)
- **Criterios:**
  - Si el turno falla tras agotar reintentos, se reembolsa el coste de ese turno y queda registro en `mana_transactions` (tipo `refund`).
  - El reembolso es idempotente por turno.
  - El usuario ve "No se descontó maná por este intento".
- **Notas:** RPC `refund_mana(transaction_id)` con validación de pertenencia; mejor aún, mover el cobro al servidor (P-07).

### H-07 · `llm-proxy` no valida maná (coste de IA ilimitado)
- **Evidencia:** `llm-proxy/index.ts:101-268` sin `consume_mana`; el cobro es 100 % cliente. Cuota de 30 req/min con fail-open.
- **Impacto:** un cliente modificado consume IA gratis; riesgo económico directo. Confianza **A**.

**P-07 · Cobro de maná en el servidor de IA** (P0, esfuerzo L)
- **Alcance:** el proxy llama a `consume_mana` (service role en nombre del `auth.uid()`) antes de invocar al modelo, según `ai_action_costs`;
  el cliente ya no cobra. Cuota fail-closed.
- **Criterios:**
  - Una petición sin saldo devuelve 402/403 con código `NO_MANA` y no llama a DeepSeek/Groq.
  - Peticiones directas al proxy con JWT válido pero sin maná fallan.
  - Si `check_llm_quota` falla, se rechaza la petición (fail-closed) con mensaje controlado.
  - Se aplica el límite diario `daily_limit` también aquí.
  - Se limitan los tokens de entrada (tope de longitud de mensajes y de nº de mensajes).
- **Riesgos:** latencia extra por RPC; migración coordinada cliente/servidor (versionar el endpoint o usar flag).
- **Dependencia:** P-06 (reembolso), P-16 (logs de uso).

### H-08 · RPC de economía con importes del cliente y funciones sin guarda de identidad
- **Evidencia:** `add_xp`, `add_gold`, `add_gems`, `add_fragments` aceptan importes del cliente y solo validan identidad;
  `mission_repository.dart:230-276` (`claimReward`) los usa. `add_mana_item` (SECURITY DEFINER) no valida `auth.uid()` y es ejecutable por `anon`.
  `grant_next_seat` no valida rol. `ai_usage_logs` tiene política FOR ALL del dueño.
- **Impacto:** cualquier usuario puede acreditarse recursos o inventario. Confianza **A**.

**P-08 · Endurecer economía** (P0/P1, esfuerzo M)
- **Criterios:**
  - `claim_mission_reward(instance_id)` calcula XP/gemas desde `mission_instances` (`xp_reward`, `gem_reward`), valida estado `completed`
    y `is_reward_claimed=false`, y es idempotente.
  - Se revoca EXECUTE a `anon` y `authenticated` en `add_xp/add_gold/add_gems/add_fragments/add_mana_item`, o se les añade validación y tope.
  - `add_mana_item` y `grant_next_seat` validan `auth.uid()` y rol de moderador.
  - `ai_usage_logs`: el dueño solo SELECT; INSERT solo desde service role.
  - Test SQL/pgTAP por cada función que demuestre que un `authenticated` no puede acreditar importes arbitrarios.
- **Nota:** también resolver el doble conteo de misiones (cliente y servidor avanzan el progreso) dejando solo el servidor.

### H-09 · Herramientas de desarrollador destructivas en producción
- **Evidencia:** `settings_screen.dart:179,1257-1346`: switch "forzar onboarding" y botón rojo que borra `user_language_profiles`.

**P-09 · Gate de herramientas de desarrollador** (P0, esfuerzo S)
- **Criterios:** la sección solo se compila/muestra con `kDebugMode`, o por flag de admin (`app_metadata.role='admin'`); no existe en el build release.
- **Test:** widget test que verifica ausencia de la sección en modo release.

### H-10 · Sin borrar cuenta ni exportar datos
- **Evidencia:** RPC `delete_my_account()` y `export_my_data()` existen; sin UI (`settings_screen.dart`).
- **Impacto:** requisito de Google Play (borrado de cuenta in-app y vía web) y RGPD. Confianza **A**. Riesgo de rechazo/retirada de la app.

**P-10 · Borrar cuenta y exportar datos desde ajustes** (P0, esfuerzo M)
- **Criterios:**
  - Ajustes → Cuenta → "Exportar mis datos": genera JSON y lo comparte/guarda (`share_plus` o descarga).
  - "Borrar mi cuenta": doble confirmación (texto "BORRAR" o contraseña), explica qué se elimina y que suscripciones activas se gestionan en Play.
  - Tras borrar, cierra sesión y vuelve a Welcome.
  - Manejo de error visible; no se silencia.
  - Cumple con la declaración de eliminación de datos de Play Console (también URL web de solicitud).
- **Dependencia:** definir política de retención (`analytics_events` no se purga por cron).

### H-11 · Otros defectos de confianza en UI (agrupados)
| ID | Hallazgo | Evidencia | Propuesta |
|---|---|---|---|
| H-11a | Chips de CEFR en ajustes no cambian nada (trigger) | `settings_screen.dart:509-530` | P-11a: quitarlos o convertirlos en "Repetir examen del Oráculo" |
| H-11b | Dos indicadores de maná contradictorios en conversación (435 fijo vs real) | `conversation_screen.dart:60,875-881` | P-11b: dejar solo el real |
| H-11c | "Siguiente lección" puede llevar a la misma | `session_summary_screen.dart:394-435` | P-11c: ocultar el botón si no hay siguiente y ofrecer "Volver a la ruta" |
| H-11d | "Ver vocabulario" solo lanza un snackbar | `:337-344` | P-11d: navegar a una pantalla de palabras de la sesión |
| H-11e | Logout sin confirmación | `dashboard_screen.dart:501-538` | P-11e: diálogo de confirmación |
| H-11f | Estado vacío de tienda con mensaje técnico | `shop_screen.dart:284-289` | P-11f: mensaje amigable y reintento |
| H-11g | Textos ES/EN mezclados | `settings_screen.dart:403-409,1178`; `profile_edit_screen.dart` | P-11g: mover a ARB |
| H-11h | Ruta `/disruption` excluida del redirect pero no registrada | `router.dart:34-40` | P-11h: quitar la exclusión |
| H-11i | Avatar real vs `avatar_url` usado como identificador de clase | `profile_edit_screen.dart:557`; `onboarding_screen.dart:257` | P-11i: separar `player_class` y `avatar_url` |
| H-11j | Onboarding no permite volver atrás | `onboarding_screen.dart:403-412` | P-11j: botón "Atrás" |
| H-11k | Leaderboard con nombres inventados ("Cazador XXXX"), 0 estrellas, línea de ascenso fija | `league_leaderboard_widget.dart:183-206` | Ver P-30 (ligas) |
- **Criterios genéricos para H-11:** el elemento deja de mostrar información falsa o inerte; existe test o verificación manual por cada uno.

### H-12 · Errores silenciados (`catch (_) {}`)
- **Evidencia (doc 12 §3):** `onboarding_screen.dart:242-263`, `dashboard_repository_impl.dart:386-388,605-607,727-729,781-817`,
  `srs_flashcard_modal.dart:71`, `lesson_generator_service.dart:18-24`, `retention_analytics.dart:37-40`.
- **Impacto:** onboarding "completado" con datos parciales; usuario cree que repasó una tarjeta que no se guardó.

**P-12 · Política de errores y reintento** (P1, esfuerzo M)
- **Criterios:**
  - Ningún `catch (_) {}` queda sin al menos registro (`ErrorTracker`) y, cuando afecta al usuario, mensaje visible.
  - Onboarding: si falla el guardado, no se marca como completado y se ofrece reintentar.
  - SRS: si falla la RPC, la tarjeta vuelve a la cola y se muestra aviso.
  - Regla de lint o revisión de PR que prohíba `catch (_) {}`.

---

## 2. Bloque B — Observabilidad y estabilidad técnica

### H-13 · Sin crash reporting ni telemetría de errores
- **Evidencia:** `ErrorTracker` solo hace `debugPrint` (`error_tracker.dart:31-56`); 0 dependencias de Sentry/Crashlytics.

**P-13 · Crash reporting** (P0, esfuerzo S–M)
- **Herramientas:** Firebase Crashlytics (integración nativa con Flutter) o Sentry (cubre además Edge Functions en Deno).
- **Criterios:**
  - Excepciones no capturadas (`FlutterError.onError`, `PlatformDispatcher.onError`, zonas) se envían con `user_id` anónimo, versión y plataforma.
  - `ErrorTracker.logError` reenvía a la herramienta.
  - Los `catch` relevantes (P-12) reportan con contexto.
  - No se envía contenido de conversaciones.
  - Alertas ante picos de errores.

### H-14 · Sin medición de coste y uso de IA
- **Evidencia:** `ai_usage_logs` = 0 filas; `analytics_events.invoke_llm` (416) sin tokens; dos llamadas LLM por turno.

**P-14 · Registro de uso de IA en el proxy** (P0, esfuerzo M)
- **Criterios:**
  - Cada llamada a `/chat` y `/transcribe` inserta en `ai_usage_logs`: `user_id`, `action_code`, `model`, `tokens_in`, `tokens_out`,
    `audio_seconds`, `latency_ms`, `status`, `cost_estimate_usd`.
  - Vista/consulta de coste por usuario/día/sesión.
  - No se guarda texto de conversaciones.
  - Documentar tarifa por token/minuto usada para la estimación.
- **Métrica clave:** coste de IA por sesión y por usuario activo vs. ingreso por usuario.
- **Dependencia:** P-08 (RLS de la tabla).

### H-15 · Analítica insuficiente
- **Evidencia:** 8 eventos sin propiedades (doc 17); no hay navegación, embudo, aprendizaje ni errores.

**P-15 · Taxonomía mínima de eventos** (P1, esfuerzo M)
- **Herramientas:** PostHog (embudos, cohortes, retención, feature flags, session replay opcional) o Firebase Analytics.
- **Eventos (con propiedades acotadas):**
  ```
  onboarding_step(step, elapsed_ms)         onboarding_complete(cefr, minutes)
  lesson_start(scenario_id, level, mana_start)
  turn(mode, input_mode, goals_open)
  lesson_end(scenario_id, turns, minutes, goals_done, goals_total, exit_reason)
  srs_review(cards, correct, delayed)       mission_claimed(type, xp, gems)
  paywall_viewed(source)                    purchase(plan_id, result)
  ai_error(endpoint, code, retries)         app_open()
  streak_updated(value, source)             notification_permission(result)
  ```
- **Criterios:**
  - Todos los eventos con propiedades; sin PII ni texto de conversación.
  - Dashboard con: embudo de onboarding, activación (primera lección cerrada <24 h), retención D1/D7/D30, sesiones/usuario/semana.
  - Consentimiento/aviso de privacidad actualizado.

### H-16 · Sin staging y migraciones no reproducibles
- **Evidencia:** único backend de producción; 164 `.sql` (49 con prefijo de 14 dígitos); 33 migraciones sin archivo; `db push` prohibido.

**P-16 · Entorno de staging y baseline de esquema** (P1, esfuerzo L)
- **Criterios:**
  - Proyecto Supabase de staging con datos sintéticos; la app permite apuntar a él por `--dart-define`.
  - Baseline del esquema actual (`supabase db dump`) versionado; las migraciones nuevas parten de ahí.
  - Regla: cambios de esquema solo por migración revisada.
  - Documentado en un runbook.

### H-17 · CI en rojo y sin CD
- **Evidencia:** `flutter analyze` sale con código 1 (35 warnings, 128 infos); no hay CD; AAB 104 MB / APK 131.9 MB.

**P-17 · Pipeline sano** (P1, esfuerzo M)
- **Criterios:**
  - 0 warnings (corregir ~10 `dead_code` y resto) y el job de analyze en verde.
  - Eliminar las 13 dependencias sin uso (reduce tamaño y superficie).
  - Job de build de AAB firmado en tags (Fastlane o Codemagic) y subida a pista interna de Play.
  - Medir y fijar un presupuesto de tamaño de AAB.

### H-18 · Cobertura de pruebas en integraciones
- **Evidencia:** 159 tests verdes, pero no cubren parser SSE, `llm-proxy`, `lesson-generator`, flujo de conversación, navegación, compras.

**P-18 · Tests de contrato e integración** (P2, esfuerzo L)
- **Criterios:**
  - Tests del parser SSE (fragmentos partidos, `[DONE]`, errores a mitad).
  - Tests del repositorio de conversación con cliente HTTP mock (429, 500, timeout).
  - Tests del `redirect` del router (sin sesión, sin perfil, con perfil, sin red).
  - Tests de Edge Functions (Deno) para validación de entrada y de maná.
  - Cobertura medida y publicada en CI.

### H-19 · Resiliencia de red y rendimiento
- **Evidencia:** dashboard cae a ceros sin red (`dashboard_repository_impl.dart:59-69`); reintento fijo de 2 intentos; `sequence_number` con `MAX+1` (carrera);
  `getUserAchievements` 5–6 consultas con upserts en bucle; `getRecommendedLessons` 4 consultas secuenciales; `sync-entitlement` en cada creación del provider; splash fijo 800 ms.

**P-19 · Resiliencia y rendimiento** (P1/P2, esfuerzo L)
- **Criterios:**
  - Estado "Sin conexión" explícito (banner) y último progreso en caché con marca de antigüedad; nunca se muestra "0 XP" por fallo de red.
  - Reintento con backoff exponencial y jitter en llamadas críticas.
  - `sequence_number` asignado por el servidor (secuencia o trigger).
  - Consolidar consultas de dashboard en una RPC (`get_dashboard_state`), y logros calculados en servidor.
  - `sync-entitlement` con TTL (p. ej. máx. 1 vez por hora) o solo en login/resume.
  - Splash proporcional al trabajo real (no 800 ms fijos) y medición del tiempo de arranque (objetivo: <2 s en gama media).

### H-20 · Seguridad menor
- CORS `*`, `/health` sin auth que revela claves configuradas, sin tope de tokens de entrada, prompt injection en la evaluación de metas sin delimitadores,
  audio máximo 10 MB, sin aviso de privacidad in-app sobre el uso de IA.

**P-20 · Hardening del proxy y privacidad** (P2, esfuerzo M)
- **Criterios:** `/health` sin detalle; CORS restringido; delimitadores y validación de IDs de metas devueltos por el modelo contra las metas reales;
  pantalla/diálogo de privacidad en onboarding explicando qué se envía a la IA (transcripciones, nivel, idioma nativo; no email ni nombre).

---

## 3. Bloque C — Retención y hábito

### H-21 · No existe canal de retorno
- **Evidencia:** sin paquetes de push, sin `POST_NOTIFICATIONS`, `notifications_enabled`/`notification_time` sin uso, sin email de reactivación.
- **Impacto:** la retención depende de que el usuario se acuerde. Confianza **A**.

**P-21 · Notificaciones push y locales** (P1, esfuerzo L)
- **Herramientas:** `firebase_messaging` (FCM) para push servidor→cliente; `flutter_local_notifications` + `timezone` para recordatorios programados.
- **Alcance:**
  1. **Recordatorio diario local** a la hora elegida (`notification_time`).
  2. **Push de racha en riesgo** (servidor, vía cron + Edge Function) si no practicó y la racha ≥2.
  3. **Push de reactivación** a los 3 y 7 días de inactividad.
  4. **Notificación contextual:** "Te falta 1 meta en *Ordering at a café*".
- **Criterios:**
  - Permiso solicitado **tras la primera lección completada**, con pantalla previa que explica el beneficio; si se rechaza, se ofrece reintento desde Ajustes.
  - Ajustes: interruptor, selector de hora, selector de días; respeta `notifications_enabled`.
  - Máximo 1 notificación por día y silencio nocturno (22:00–08:00 local).
  - Textos localizados (es/en/pt) y deep link al destino (lección pendiente / home).
  - Se registra token en tabla `device_tokens(user_id, token, platform, updated_at)` con RLS; se limpian tokens inválidos.
  - Eventos: `notification_permission`, `notification_sent`, `notification_opened`.
- **Notas técnicas:** Android 13+ requiere `POST_NOTIFICATIONS`; Android 12+ y alarmas exactas (`SCHEDULE_EXACT_ALARM`) — preferir inexactas para evitar rechazo de Play; canal de notificaciones.
- **Métricas:** opt-in rate, open rate, retención D7 de usuarios con vs. sin notificaciones (experimento).

**P-22 · Email de reactivación** (P2, esfuerzo M)
- **Herramientas:** Resend o Brevo + Edge Function + cron.
- **Criterios:** envío a los 3 y 7 días de inactividad a usuarios con email verificado; enlace de baja (unsubscribe) obligatorio; plantilla localizada; máximo 2 emails por inactividad.

### H-23 · Meta diaria no rastreada
- **Evidencia:** `daily_goal_minutes` solo ordena escenarios (`dashboard_repository_impl.dart:96-134`); `daily_stats` existe.

**P-23 · Meta diaria visible** (P1, esfuerzo M)
- **Criterios:**
  - Anillo de progreso en Home hacia `daily_goal_minutes` con minutos reales de hoy (desde `daily_stats`).
  - Celebración (animación + haptic) al completarla, una sola vez al día.
  - La meta cumplida cuenta para la racha (P-03).
  - Editable desde Ajustes con efecto inmediato.
- **Dependencia:** P-03.

### H-24 · Misiones que no enganchan
- **Evidencia:** 533 instancias creadas, 7 completadas (1,3 %); semanales sin UI (`features/missions/screens/` no existe); doble conteo cliente+servidor; secretas/eventos/gremio sin flujo.

**P-24 · Rediseño de misiones** (P1, esfuerzo M–L)
- **Criterios:**
  - **Misión del día destacada** en Home (1 principal + 2 secundarias), con barra de progreso y recompensa visible.
  - Pantalla de misiones con pestañas Diarias / Semanales.
  - Progreso solo por servidor (eliminar avance de cliente) y sin doble conteo.
  - Misiones alcanzables (basadas en la distribución real: p. ej. "habla 3 minutos", "completa 1 meta").
  - Reclamo por RPC del servidor (P-08) con animación.
  - Medir tasa de completado por plantilla; retirar plantillas con <5 % de completado.
  - Ocultar o posponer secretas/eventos/gremio hasta que exista flujo.

### H-25 · Time-to-value largo
- **Evidencia:** 3 pantallas + examen oral antes de la primera lección; no hay lección de prueba. El nombre del personaje no se pide; motivación y personalidad hardcodeadas.

**P-25 · Mini-conversación inicial (prueba de valor)** (P1, esfuerzo M–L)
- **Alcance:** antes del registro (o inmediatamente tras él), una conversación guiada de ~60–90 s ("pide un café") con 2–3 turnos, sin examen, que termina mostrando una recompensa y una invitación a "crear tu personaje".
- **Criterios:**
  - El usuario habla con el tutor en <60 s desde la primera apertura.
  - Se pide el registro **después** de esa primera experiencia (o se permite continuar como invitado y vincular cuenta luego; el repositorio ya soporta login anónimo).
  - Coste de IA acotado (tope de turnos y maná de bienvenida).
  - El Oráculo pasa a ser opcional ("Calibrar mi nivel") con alternativa de selección manual PRE-A1…B2.
  - Se pide el nombre del personaje y se guarda en `display_name`.
  - Se miden: % que habla en el primer minuto, % que completa onboarding (embudo, P-15).
- **Riesgo:** abuso por cuentas anónimas (rate limit por dispositivo/IP).

### H-26 · Maná que se agota sin aviso
- **Evidencia:** solo hay chequeo ≥12 al entrar; 200/día en el plan gratis ≈ 16 turnos; el coste por turno no se muestra.

**P-26 · Transparencia y suavizado del consumo** (P1, esfuerzo M)
- **Criterios:**
  - Medidor de maná visible en conversación con coste del próximo turno.
  - Aviso al quedar para ≤3 turnos ("Te quedan 3 turnos hoy").
  - Pantalla de "sin maná" con hora de recarga, alternativas (repasar vocabulario, chat de texto de bajo coste) y CTA al paywall.
  - Decidir si el límite diario (200) es lo deseado; evaluar un "turno gratis de cierre" para que nunca se corte a mitad de una meta.
- **Dependencia:** P-07.

### H-27 · Retorno tras inactividad sin contexto
**P-27 · Pantalla de "bienvenido de vuelta"** (P2, esfuerzo S–M)
- **Criterios:** si pasaron ≥3 días, Home muestra tarjeta "Te quedaste en [lección] – a 1 meta"; botón único "Continuar"; sin culpar por la racha perdida (mensaje positivo; ofrecer reiniciar).

---

## 4. Bloque D — Enganche y dinamismo

### H-28 · Cierre de sesión poco pedagógico
**P-28 · Resumen "Qué aprendiste"** (P1, esfuerzo M)
- **Criterios:**
  - Muestra: metas cumplidas/total, 3 palabras nuevas con traducción, 1 corrección concreta (original → corregido → por qué), racha real, XP/oro reales.
  - Botones: "Repasar palabras" (abre SRS con esas palabras), "Siguiente lección" (solo si existe), "Volver".
  - Si no hubo correcciones, mensaje positivo en lugar de tarjeta genérica.
  - Compartible como imagen (opcional, P3) para crecimiento orgánico.
- **Dependencia:** P-01, P-29 (correcciones), P-33 (vocabulario).

### H-29 · Corrección implícita y sin registro de errores
- **Evidencia:** la tabla `corrections` existe y no se escribe; el tutor solo reformula; no hay historial de errores.

**P-29 · Corrección explícita y registro de errores** (P1, esfuerzo L)
- **Alcance:** tras cada turno, la llamada de evaluación (que ya existe) devuelve además un JSON `{errors:[{original, corrected, type, explanation}]}`; se guarda en `corrections`.
- **Criterios:**
  - Tipos acotados: `grammar`, `vocabulary`, `word_choice`, `pronunciation_hint`, `typo_stt` (para no penalizar errores de transcripción).
  - Chip discreto bajo la burbuja del usuario que se despliega con la corrección (no interrumpe la conversación); configurable según `correction_level`.
  - Pantalla "Mis errores" agrupada por tipo y recurrencia.
  - Los errores recurrentes alimentan misiones de refuerzo y el prompt del tutor.
  - Validar el JSON contra esquema; si falla, no bloquear el turno.
- **Costo/riesgo:** más tokens de salida; usar la misma llamada para metas + errores + vocabulario (P-33) para no añadir llamadas.
- **Métricas:** reducción de la tasa de repetición del mismo error.

### H-30 · Monotonía de actividad
- **Evidencia:** todo es conversación libre; no hay comprensión auditiva, lectura ni escritura evaluadas.

**P-30 · Nuevos tipos de actividad** (P2, esfuerzo L cada uno)
| Actividad | Descripción | Criterios clave | Coste IA |
|---|---|---|---|
| **Shadowing** | El tutor dice una frase (TTS), el usuario la repite; se compara la transcripción con el objetivo | Muestra % de coincidencia por palabra, resalta palabras faltantes, 5 frases por ronda | Bajo (solo STT) |
| **Listening quiz** | TTS reproduce un mini-diálogo; el usuario elige la respuesta correcta | Opción múltiple, 3–5 preguntas, banco de ítems con respuesta conocida (reproducible) | Nulo si es precomputado |
| **Conversación con giros** | A mitad del escenario ocurre un imprevisto (vuelo cancelado, pedido equivocado) | Giro definido en el escenario (`twist`), evaluable como meta | Igual que hoy |
| **Reto de frases útiles** | Usar 3 frases clave en la conversación | Reutiliza `user_scenario_phrases` | Igual |
| **Jefe de nivel** | Conversación larga de promoción con rúbrica fija | Ver P-31 | Medio |
- **Prioridad sugerida:** Shadowing y Listening quiz primero (mejoran pronunciación y comprensión, hoy no medidas, y son baratos).

### H-31 · Examen de promoción ≈ repetir el Oráculo
- **Evidencia:** `router.dart:72-84` ignora parámetros; sin tope de turnos ni timeout de cierre (si el modelo no emite `[RESULT:CEFR=…]`, el examen no termina); el nivel lo fija el texto declarado por el modelo.

**P-31 · Examen de promoción robusto ("Jefe de mazmorra")** (P1, esfuerzo L)
- **Criterios:**
  - Tope duro de turnos (p. ej. 8) y timeout; al alcanzarlo se fuerza el cierre y se evalúa con los datos disponibles.
  - Rúbrica fija con 6 dimensiones (ya existen `scores_*`) y umbral de aprobación explícito.
  - El resultado indica puntuación por dimensión y qué reforzar; si no aprueba, ofrece lecciones de refuerzo y reintento tras un tiempo/costo definido.
  - Resultado persistido por RPC (no escrito por el cliente) para que el nivel no dependa de una cadena de texto del modelo.
  - Presentación temática (jefe, barra de vida que baja con cada acierto) como capa visual.
- **Dependencia:** P-14, P-07.

### H-32 · Capa RPG sin consecuencias
- **Evidencia:** nivel = XP/1000 no desbloquea nada; rango = CEFR; gemas (sin sumidero), fragmentos (invisibles), pergaminos (tabla deprecada); tienda solo cosméticos con oro; leaderboard crudo.

**P-32 · Economía y progresión con propósito** (P2, esfuerzo L)
- **Criterios (por sub-historia):**
  - **Sumideros:** gemas → freeze de racha, reintento de jefe, cosméticos premium; fragmentos → crafteo de cosméticos o eliminar; pergaminos → migrar a tabla vigente o eliminar.
  - **Nivel de cazador desbloquea algo** (marcos, mascotas, escenarios temáticos) y se anuncia al subir.
  - **Ligas semanales** (Bronce/Plata/Oro…): cohortes de ~30, ascenso/descenso, reinicio semanal, nombres reales (`display_name`) y avatar, sin hardcodes.
  - **Recompensas variables reales:** cofres con probabilidades visibles y objetos reales.
  - **Freeze de racha:** conectar `purchaseStreakFreeze` con UI (P-03).
  - Antes de agregar economía, decidir qué recursos se mantienen (simplificar de 5 monedas a 3).

### H-33 · Calidad del vocabulario
- **Evidencia:** extracción por regex `\b[a-zA-Z]{4,15}\b`, máx. 6 palabras/turno; traducción propia salvo 21 palabras; `part_of_speech` por sufijo; `difficulty_level='A2'` para todo; incluye palabras vacías y errores de STT.

**P-33 · Vocabulario curado por el LLM** (P1, esfuerzo M)
- **Criterios:**
  - Se extraen solo palabras de contenido (sin stopwords) con traducción al idioma nativo, categoría gramatical, nivel CEFR estimado y frase de ejemplo.
  - Fuente: el tutor/LLM devuelve las palabras nuevas relevantes en la misma llamada de evaluación (P-29); la lista es validada.
  - Se filtran errores de transcripción (palabras fuera de diccionario).
  - SRS programa solo palabras con traducción válida.
  - Pantalla "Mi vocabulario" con estado (nueva/aprendiendo/dominada) y búsqueda.
- **Métricas:** `retention_7d` con muestra suficiente; % de palabras válidas.

### H-34 · Mejoras de interacción en la conversación
**P-34 · Experiencia de conversación** (P1/P2, esfuerzo M, dividir en historias pequeñas)
- **P-34a Botón de pausa / detener al tutor** (no existe; hoy solo tocar el micrófono o salir).
- **P-34b Sugerencias de respuesta:** si el usuario se bloquea, "Necesito ayuda" muestra 3 frases tocables (de `useful_phrases` o generadas), con coste de maná bajo.
- **P-34c Velocidad del TTS** (0.75×/1×/1.25×) y **selección de voz** (`tutor_voice_id` ya existe en `user_settings`).
- **P-34d Traducción bajo demanda** de la burbuja del tutor al idioma nativo (`ai_explanations_native`).
- **P-34e Permiso de micrófono denegado:** flujo "ir a ajustes" (hoy no existe).
- **P-34f Modo hold-to-talk** vs tap-to-toggle (`micModeHoldToTalkProvider` existe sin consumidores).
- **P-34g Feedback visual de grabación** (forma de onda) y de latencia ("pensando…").
- **Criterios genéricos:** cada una con evento de uso y ajuste persistido en `user_settings`.

### H-35 · Fluidez y pronunciación no medidas realmente
- **Evidencia:** latencia fija 1.8 s; "claridad fonética" = similitud de texto transcrito; el radar pinta porcentajes con precisión.

**P-35 · Honestidad de métricas** (P1, esfuerzo S–L)
- **Opción corta (S):** etiquetar como "estimado" y reducir la precisión (niveles Bajo/Medio/Alto).
- **Opción larga (L):** evaluación de pronunciación real (p. ej. Azure Pronunciation Assessment, Speechace u otro servicio) con coste y latencia a evaluar.
- **Criterios (opción corta):** el radar no muestra decimales falsos; tooltip "Estimación basada en tu conversación"; la pronunciación se deriva de datos reales (palabras mal transcritas por STT) o se oculta.

### H-36 · Presencia fuera de la app
**P-36 · Widget de pantalla de inicio (Android)** (P2, esfuerzo M)
- **Herramienta:** paquete `home_widget`.
- **Criterios:** muestra racha, minutos de hoy vs. meta y botón "Practicar"; se actualiza al cerrar sesión y al cambiar de día; funciona sin abrir la app en segundo plano más allá de lo permitido.

### H-37 · Feedback háptico, sonido y animaciones
**P-37 · Pulido sensorial** (P3, esfuerzo S–M)
- **Criterios:** haptics en completar meta, subir de nivel y reclamar misión; sonidos opcionales (la sección "Audio" de ajustes está vacía); animaciones de celebración con Lottie o `flutter_animate` (dependencias ya declaradas sin uso). Toggle para desactivar.

---

## 5. Bloque E — Pedagogía

### H-38 · Doble currículo y doble criterio de "completada"
- **Evidencia:** Dart `LessonCatalog` (140 lecciones) vs. `scenarios` (500 filas); desbloqueo al 75 % vs. estrellas al 100 %; halo con comentario "70 %" pero umbral 0.75; la Ruta usa el catálogo Dart y el dashboard usa `scenarios`; el catálogo Dart no filtra por intereses.

**P-38 · Única fuente de currículo** (P1, esfuerzo L)
- **Criterios:**
  - `scenarios` es la fuente única; el catálogo Dart se usa solo como semilla de migración y se elimina del runtime.
  - Un solo criterio de "completada" (definir: 75 % o 100 %) implementado en una función (cliente y servidor).
  - Las estrellas, el halo y el desbloqueo se derivan de la misma regla.
  - La Ruta por Etapas filtra y prioriza por intereses.
  - Existe estado "sin conexión" con caché del último currículo descargado.
  - Tests que comprueban consistencia entre el halo, estrellas y desbloqueo.
- **Decisión de producto requerida:** umbral de aprobación y si las estrellas premian frases usadas.

### H-39 · Evaluación de metas no determinista
- **Evidencia:** el LLM evalúa en cada turno sin rúbrica (`t=0.3`); IDs devueltos no se filtran; si falla, `{}` y el turno no evalúa; el usuario puede completar sin que se registre; un usuario puede "pasar" metas con frases mínimas.

**P-39 · Evaluación de metas robusta** (P1, esfuerzo M)
- **Criterios:**
  - Prompt con rúbrica por meta ("cumplida si el usuario produce X en una oración completa y comprensible").
  - Validación de IDs contra las metas reales; descartar los desconocidos.
  - Si la evaluación falla, se reintenta en el siguiente turno con el historial acumulado (no se pierde).
  - Heurística local de keywords solo como respaldo visual, nunca para persistir.
  - Un conjunto de conversaciones de referencia (golden set) para medir acuerdo entre ejecuciones (objetivo: ≥90 % de consistencia).
  - Considerar modelo más pequeño para esta tarea (ver P-41).

### H-40 · Sin adaptación dentro del nivel
- **Evidencia:** escenarios con `difficulty_level = CEFR` exacto; no hay ajuste por desempeño; sin mezcla nuevo/conocido; el perfil de IA (`user_ai_profiles`) se escribe y nunca se lee en los prompts.
- **Estado (29-oct-2026, P-40 · #125): remediado en código.** El prompt del
  turno se compone con `TutorPromptBuilder` e incluye `tutor_prompt_instructions`,
  `focus_areas`/`interests`, `motivation`, estilo/personalidad, errores
  recurrentes, metas pendientes, `main_objective`, frases útiles, repaso cada 3
  lecciones y el ajuste simplificar/subir por rachas. La selección de lecciones
  une `user_settings.interests` con `user_ai_profiles.focus_areas`. Detalle y
  límites: `docs/runbooks/P40_PERSONALIZACION.md`.

**P-40 · Adaptación y personalización** (P2, esfuerzo L)
- **Criterios:**
  - Si el usuario falla N veces seguidas, el tutor simplifica y ofrece pistas; si acierta fácil, sube la complejidad.
  - El prompt del tutor incorpora `tutor_prompt_instructions`, intereses, errores recurrentes (P-29) y las metas pendientes.
  - Inyectar `mainObjective` y frases útiles del escenario en el prompt (hoy solo rol/contexto).
  - Práctica acumulativa: cada N lecciones, repaso de frases/vocabulario de lecciones anteriores.
  - Lección de refuerzo funcional (ver P-42).

### H-41 · Coste de IA por turno
- **Evidencia:** 2 llamadas LLM + 1 STT por turno; historial de 24 mensajes siempre; `max_tokens` 200.

**P-41 · Optimización del coste de IA** (P2, esfuerzo M)
- **Criterios (medir antes de optimizar con P-14):**
  - Evaluar metas solo cuando el mensaje tiene señal (≥N palabras o coincide con keywords).
  - Combinar evaluación de metas + errores + vocabulario en una sola llamada.
  - Historial dinámico por longitud de tokens (resumen del contexto antiguo en lugar de 24 mensajes fijos).
  - Modelo más pequeño para tareas booleanas.
  - Meta: reducir el coste por sesión X % sin bajar calidad (medida con el golden set de P-39).

### H-42 · Refuerzo por IA roto
- **Evidencia:** `weakestSkill` devuelve `comprehension`/`naturalness`, que el generador rechaza (400); sin datos del Oráculo ambos valen 0 y siempre ganan; `catch (_) {}`.

**P-42 · Arreglar y activar lección de refuerzo** (P2, esfuerzo M)
- **Criterios:**
  - Mapeo correcto de habilidades a `skill_focus` aceptados; la generación pasa con cada skill válido.
  - El refuerzo se basa en errores recurrentes reales (P-29) en lugar de puntuaciones del Oráculo.
  - Los escenarios generados entran en `review_status='draft'` y pasan por revisión antes de mostrarse a todos (o solo al usuario creador).
  - Error visible y reembolso de 100 maná si falla.

### H-43 · Cobertura pedagógica limitada
- **Evidencia:** no hay lectura ni escritura; comprensión auditiva no evaluada; sin test de nivel continuo.

**P-43 · Evaluación continua del nivel** (P3, esfuerzo L)
- **Criterios:** mini-chequeos periódicos (cada ~10 lecciones) que ajustan el nivel sugerido; informe semanal de progreso (palabras nuevas, errores corregidos, minutos, nivel estimado) accesible desde la app y opcionalmente por email.

---

## 6. Bloque F — Monetización

### H-44 · El premium solo añade maná
- **Evidencia:** no hay gates funcionales (`isPremiumProvider` solo cambia badge y paywall); 0 pagos, 1 suscripción `noble` sobre 11; sin compra de maná/gemas; sin trial; planes legacy con features inexistentes (Battle Pass, Blind Listening).

**P-44 · Propuesta de valor premium diferenciada** (P1, esfuerzo M–L)
- **Opciones a validar** (decisión de producto; una o varias):
  - Informe semanal detallado y "Mis errores" con repaso inteligente.
  - Modo jefe/examen y escenarios exclusivos.
  - Tutor con voces premium o personalidades extra.
  - Sin límite diario de turnos de chat de texto.
  - Historial de conversaciones con transcripciones y audio.
- **Criterios:** el paywall muestra beneficios concretos (no solo "más maná"); cada beneficio premium está implementado y gateado; eventos `paywall_viewed(source)`, `purchase`.

**P-45 · Prueba gratuita y gestión de planes** (P2, esfuerzo M)
- **Criterios:** trial configurado en Play/RevenueCat (7 días) con mensaje de recordatorio previo al cobro; planes legacy eliminados o ocultos de forma que no puedan reactivarse; pantalla propia (no solo paywall nativo) que explique diferencias entre `noble`, `realeza`, `divino`.

**P-46 · Compra de maná opcional** (P2, esfuerzo M)
- **Criterios:** pociones/paquetes de maná con productos de Play (consumibles) o decisión explícita de no venderlos y ajustar el allowance; coherencia con el límite diario; no se vende ventaja pedagógica injusta.

**P-47 · Análisis de margen** (P1, esfuerzo S)
- **Criterios:** informe de coste de IA por usuario (P-14) frente a ingreso por plan; definir el allowance de maná por plan de forma que el margen sea positivo con el uso real; revisión trimestral.
- **Dependencia:** P-14.

---

## 7. Bloque G — Contenido, social y limpieza

### H-48 · Capa social sin uso
- **Evidencia:** 6 salas, 0 mensajes, 0 participantes; battle pass solo lectura; salas de voz sin uso registrado; LiveKit tiene coste potencial.

**P-48 · Decisión sobre gremio y salas** (P2)
- **Opciones:** (a) pausarlo (ocultar tab) hasta tener masa crítica de usuarios; (b) reactivarlo con contenido sembrado (salas temáticas con horarios, "Práctica en pareja" asincrónica, retos por equipo).
- **Criterios (opción a):** se retira la pestaña de Gremio del dock y se documenta cómo reactivarla; no se pierden datos. **Opción b:** salas con anfitrión (bot o moderador) y horarios fijos, y métrica de mensajes/semana.
- **Recomendación:** (a) hasta que haya >500 usuarios activos semanales.

### H-49 · Contenido limitado por nivel
- **Evidencia:** 20 escenarios (PRE-A1) y 80 por nivel, 4 idiomas; solo se ofrece inglés; sin contenido nuevo tras el primer nivel; escenarios se repiten.

**P-49 · Pipeline de contenido** (P2, esfuerzo L)
- **Criterios:** proceso de generación asistida + revisión (`review_status`) de nuevos escenarios; calendario de contenido (p. ej. "evento del mes"); contenido por interés (los intereses hoy filtran solo la BD, no la Ruta); métricas de repetición por usuario.

### H-50 · Marca inconsistente
- **Evidencia:** "Dungeon of English" (`app.dart:31`), "DungeonSpeak" (manifest, productos Play), "TutorSaas" (`pubspec`, bundle id).

**P-50 · Unificar marca** (P3, esfuerzo S–M)
- **Criterios:** nombre único en app, tienda, onboarding y textos legales; nota: el `applicationId` no se puede cambiar tras publicar, solo el nombre visible; actualizar productos/entitlement solo si es seguro (no romper compras existentes).

### H-51 · Limpieza técnica
**P-51 · Deuda controlada** (P3)
- Eliminar 13 dependencias sin uso, `STT_URL/TTS_URL` sin uso, `UserProgress` sin uso, `micModeHoldToTalkProvider` (si no se implementa P-34f), `system_ai_settings` (leerlo o retirar el panel), planes legacy.
- Partir pantallas monolíticas (>1.000 líneas): `conversation_screen`, `settings_screen`, `chat_rooms_screen`, `voice_room_screen`, `onboarding_screen`.
- Mover lógica de negocio de repositorios (estrellas, racha, progreso) a servicios de dominio o servidor.
- Accesibilidad: `Semantics`, contraste, soporte de lector de pantalla, ya cubierta parcialmente por tests de escala de texto.

---

## 8. Backlog priorizado (para convertir en historias)

| Orden | ID | Historia (título corto) | Prioridad | Esfuerzo | Depende de |
|---|---|---|---|---|---|
| 1 | P-09 | Ocultar herramientas de desarrollador en release | P0 | S | — |
| 2 | P-13 | Crash reporting | P0 | S–M | — |
| 3 | P-05 | Errores de IA como evento de sistema con reintento | P0 | M | — |
| 4 | P-01 | Resumen con datos reales del servidor | P0 | M | — |
| 5 | P-02 | Drop idempotente | P0 | S–M | P-01 |
| 6 | P-03 | Racha y minutos por RPC | P0 | M | — |
| 7 | P-04 | Banner de racha real | P0 | S | P-03 |
| 8 | P-10 | Borrar cuenta y exportar datos | P0 | M | — |
| 9 | P-08 | Endurecer RPC de economía | P0/P1 | M | — |
| 10 | P-14 | Registro de uso/coste de IA | P0 | M | P-08 |
| 11 | P-07 | Cobro de maná en el proxy | P0 | L | P-06, P-14 |
| 12 | P-06 | Reembolso por fallo | P0 | M | — |
| 13 | P-11 | Correcciones de UI inertes (a–j) | P1 | M total | — |
| 14 | P-12 | Política de errores (sin `catch` vacíos) | P1 | M | P-13 |
| 15 | P-15 | Taxonomía de eventos + PostHog/Firebase | P1 | M | — |
| 16 | P-17 | CI verde, dependencias, CD | P1 | M | — |
| 17 | P-23 | Meta diaria visible | P1 | M | P-03 |
| 18 | P-21 | Notificaciones push/locales | P1 | L | P-03, P-15 |
| 19 | P-24 | Rediseño de misiones | P1 | M–L | P-08 |
| 20 | P-25 | Mini-conversación inicial | P1 | M–L | P-15 |
| 21 | P-26 | Transparencia del maná | P1 | M | P-07 |
| 22 | P-28 | Resumen "Qué aprendiste" | P1 | M | P-01, P-29, P-33 |
| 23 | P-29 | Corrección explícita y registro de errores | P1 | L | P-41 (opcional) |
| 24 | P-33 | Vocabulario curado | P1 | M | P-29 |
| 25 | P-39 | Evaluación de metas robusta | P1 | M | — |
| 26 | P-31 | Examen de promoción ("Jefe") | P1 | L | P-14 |
| 27 | P-35 | Honestidad de métricas | P1 | S | — |
| 28 | P-38 | Única fuente de currículo | P1 | L | — |
| 29 | P-44 / P-47 | Valor premium + análisis de margen | P1 | M–L / S | P-14 |
| 30 | P-16 | Staging y baseline | P1 | L | — |
| 31 | P-19 | Resiliencia de red y rendimiento | P1/P2 | L | — |
| 32 | P-34 | Mejoras de conversación (a–g) | P1/P2 | M total | — |
| 33 | P-30 | Nuevas actividades (shadowing, listening…) | P2 | L c/u | P-15 |
| 34 | P-32 | Economía con propósito y ligas | P2 | L | P-08, P-24 |
| 35 | P-36 | Widget Android | P2 | M | P-03 |
| 36 | P-22, P-27 | Email y "bienvenido de vuelta" | P2 | M / S–M | P-21 |
| 37 | P-40, P-41, P-42 | Adaptación, coste IA, refuerzo | P2 | L / M / M | P-14, P-29 |
| 38 | P-45, P-46 | Trial y compra de maná | P2 | M | P-44 |
| 39 | P-18, P-20 | Tests de integración y hardening | P2 | L / M | — |
| 40 | P-48, P-49, P-50, P-51, P-37, P-43 | Social, contenido, marca, deuda, pulido, evaluación continua | P2/P3 | varios | — |

---

## 9. Plan sugerido por fases

| Fase | Duración | Historias | Resultado esperado |
|---|---|---|---|
| **1. Confianza y medición** | Semanas 1–2 | P-09, P-13, P-05, P-01, P-02, P-03, P-04, P-10, P-08, P-14 | App confiable, medible y conforme con Play |
| **2. Protección económica** | Semanas 2–4 | P-06, P-07, P-11, P-12, P-17, P-15 | Coste de IA controlado; pipeline sano; eventos con propiedades |
| **3. Primer ciclo de retención** | Semanas 4–6 | P-23, P-21, P-24, P-26, P-28 | Hábito diario funcional y canal de retorno |
| **4. Activación y aprendizaje** | Semanas 6–10 | P-25, P-29, P-33, P-39, P-35, P-38 | Mejor time-to-value y aprendizaje demostrable |
| **5. Diferenciación** | Semanas 10–14 | P-31, P-30, P-34, P-44, P-47, P-32 | Enganche variado y premium con valor real |
| **6. Escala y limpieza** | Continuo | P-16, P-19, P-18, P-20, P-36, P-40..P-51 | Robustez a largo plazo |

> **Antes de la fase 3,** conviene reclutar **20–50 usuarios reales** (beta cerrada en Play) con la instrumentación de la fase 1–2 activa.
> Así se valida si el cuello de botella es activación, hábito o monetización, y se ajusta el orden del backlog.

---

## 10. Métricas de éxito por objetivo

| Objetivo | Métrica | Fuente | Meta inicial sugerida (a validar) |
|---|---|---|---|
| Activación | % que completa la primera lección en <24 h | `lesson_start/lesson_end` | ≥40 % |
| Time-to-value | Segundos hasta el primer turno hablado | `turn` con `elapsed_ms` | <90 s |
| Hábito | % con racha ≥3 días | `streak_updated` | ≥25 % de activos |
| Retención | D1 / D7 / D30 | PostHog cohortes | D1 ≥35 %, D7 ≥15 %, D30 ≥7 % |
| Engagement | Sesiones/usuario activo/semana | eventos | ≥3 |
| Confianza | Discrepancia mostrado vs. acreditado | ledger vs. UI | 0 % |
| Estabilidad | Sesiones sin crash | Crashlytics/Sentry | ≥99,5 % |
| Coste | Coste IA por sesión / por usuario activo | `ai_usage_logs` | Definir tras 2 semanas de datos |
| Monetización | Conversión paywall → compra; ARPU | RevenueCat + eventos | Definir tras beta |
| Aprendizaje | `retention_7d` de vocabulario; repetición de errores | `learning_evidence()`, `corrections` | Tendencia positiva |

> Las metas numéricas son referencias típicas de apps de hábito/idiomas, **no** datos de esta app; sustitúyelas por las que defina el equipo con datos reales.

---

## 11. Preguntas abiertas que condicionan las historias

1. **Racha:** ¿cuál es la definición de "día practicado" (minutos o metas) y qué zona horaria se usa?
2. **Completada:** ¿75 % o 100 % de las metas? ¿Las estrellas premian frases usadas?
3. **Invitados:** ¿se permite probar antes de registrarse (login anónimo ya soportado en el repositorio)?
4. **Premium:** ¿qué beneficios concretos se venden además de maná?
5. **Gremio:** ¿se pausa hasta tener masa crítica o se reactiva con contenido sembrado?
6. **Pronunciación:** ¿se integra un servicio de evaluación real o se etiqueta como estimación?
7. **Idiomas:** hoy solo se enseña inglés; ¿se expande a fr/de/it (los escenarios ya existen en BD)?
8. **Monedas:** ¿se simplifica a oro + maná + gemas y se eliminan fragmentos y pergaminos?
9. **Privacidad:** ¿qué aviso y consentimiento se requieren para enviar transcripciones al LLM y para la analítica?
10. **Plataforma:** ¿se planea iOS? Cambia la estrategia de push, pagos y widget.
11. **Proveedor de analítica/crash:** ¿PostHog, Firebase o Sentry (coste, privacidad, hosting)?
12. **Presupuesto de IA:** ¿qué coste máximo por usuario activo es aceptable?

---

## 12. Plantilla sugerida para cada historia de usuario

```
ID: P-xx — Título
Como [rol: usuario nuevo / usuario activo / usuario free / suscriptor / administrador / desarrollador]
Quiero [acción]
Para [beneficio]

Contexto y evidencia: (copiar de H-xx)
Alcance: (incluido / excluido)
Criterios de aceptación (Dado/Cuando/Entonces):
  1. Dado ..., cuando ..., entonces ...
Notas técnicas: (archivos, RPC, tablas, herramientas)
Dependencias:
Eventos de analítica a emitir:
Casos borde y errores:
Definición de hecho: tests, revisión, QA en dispositivo, sin warnings, documentación actualizada
Prioridad / esfuerzo:
```

---

## 13. Limitaciones de este análisis

1. Basado en análisis estático (sin ejecutar la app); latencias, UX real, TTS y permisos no se observaron.
2. No hay usuarios reales: las proyecciones de retención y las metas de la sección 10 son hipótesis.
3. No se probaron compras ni el estado de RevenueCat/Customer Center.
4. Algunas propuestas (P-30, P-32, P-44, P-48) requieren decisiones de producto antes de estimar con precisión.
5. Las estimaciones de esfuerzo (S/M/L) son relativas: S ≈ 1–2 días, M ≈ 3–5 días, L ≈ 1–3 semanas para un desarrollador familiarizado con el código.
