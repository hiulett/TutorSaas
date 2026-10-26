# 11 — Retención y notificaciones

> Medición: 25-oct-2026. Evidencia: `AndroidManifest.xml`, `pubspec.yaml`,
> `retention_analytics.dart`, `dashboard`, `progress_tab_view`, `daily_reward_modal`,
> `pg_cron` y agregados de producción.

---

## 1. Notificaciones: no existen

| Comprobación | Resultado | Evidencia |
|---|---|---|
| Paquete de push (Firebase/FCM/local notifications) | **Ninguno** | `pubspec.yaml:10-56` |
| Permiso `POST_NOTIFICATIONS` | **No declarado** | `AndroidManifest.xml:2-3` (solo RECORD_AUDIO e INTERNET) |
| Permiso `SCHEDULE_EXACT_ALARM` / `RECEIVE_BOOT_COMPLETED` | No | ídem |
| Campos de preferencia | `user_settings.notifications_enabled`, `notification_time` existen y **no se leen** | tabla en producción; 0 referencias en `lib/` |
| Sección de ajustes de audio/notificaciones | Retirada (sección vacía) | `settings_screen.dart:166-170` |
| Email transaccional de reactivación | No hay integración | — |
| Deep links de re-engagement | Solo el callback de auth | `AndroidManifest.xml:32` |

**Conclusión:** la app **no puede** traer de vuelta al usuario. No hay recordatorio,
ni push, ni correo, ni campaña. La retención depende exclusivamente de que el
usuario abra la app por su cuenta.

---

## 2. Mecanismos de regreso que sí existen (in-app)

| Mecanismo | Cómo funciona | Estado | Evidencia |
|---|---|---|---|
| **Recompensa diaria** | Modal en el home; escalón por día; una vez al día | ✅ | `daily_reward_modal.dart` |
| **Misiones diarias** | Cron a las 00:05 UTC crea instancias; progreso por triggers; reclamo manual | ✅ P (doble conteo) | `rotate-daily-missions`; `advance_my_missions` |
| **Racha** | `current_streak` visible en el dashboard | ⚠️ **no se actualiza** por el trigger de guarda | doc 08 §5 |
| **Banner "racha en riesgo"** | Se muestra si `invocations_used <= 0` | ⚠️ siempre activo (contador nunca se incrementa) | `progress_tab_view.dart:46-48` |
| **SRS** | Tarjeta si hay vocabulario vencido | ✅ | `srs_review_card.dart` |
| **Bonus de sesión** | XP/oro al cerrar | ⚠️ el resumen no lo refleja | doc 06 §5 |
| **Leaderboard** | Top 10 por XP global | ✅ P (sin ligas) | `get_leaderboard` |
| **Presencia en gremio** | Heartbeat y salas en vivo | ✅ pero sin actividad real | `report_presence`; 0 mensajes |
| **Aura / prestigio / títulos** | Progresión a largo plazo | ✅ | `aura_system.dart` |
| **Meta diaria** | `daily_goal_minutes` se usa para ordenar escenarios, no como objetivo rastreado | ⚠️ P | `dashboard_repository_impl.dart:96-134` |

---

## 3. Lo que la app registra (y lo que no)

Eventos realmente emitidos (`analytics_events`, producción, 463 filas):

| Evento | Filas | Dónde se emite |
|---|---|---|
| `invoke_llm` | 416 | `conversation_providers` |
| `session_start` | 17 | `conversation_providers:149-156` |
| `app_open` | 12 | `app.dart:27` (una vez por proceso) |
| `session_end` | 8 | `conversation_providers:1623-1632` |
| `paywall_viewed` | 4 | `paywall_screen.dart` |
| `claim_daily` | 4 | `daily_reward_modal.dart` |
| `purchase_started` / `purchase_succeeded` | 1 / 1 | `paywall_screen.dart` |

**No se registran** (aunque el prompt de auditoría los pedía): onboarding
completado, primera lección, lección completada, tiempo por actividad, respuesta
correcta/incorrecta, error repetido, abandono de lección, racha iniciada/perdida,
meta diaria cumplida, nivel alcanzado, conversación con IA iniciada/finalizada,
error de IA, consumo de tokens, prueba iniciada, suscripción cancelada.

Además:
- El evento **`invoke_llm` se emite en cada llamada** (incluidas las de evaluación
  de metas): es telemetría de volumen, no de aprendizaje.
- `api_request_logs` guarda `invoke_llm`/`invoke_llm_error` sin tokens.
- `ErrorTracker` no envía nada a un backend.

---

## 4. Qué se puede calcular hoy con los datos existentes

| Métrica | ¿Posible? | Con qué |
|---|---|---|
| Usuarios registrados | ✅ | `users` |
| Sesiones y mensajes por día | ✅ | `conversations.started_at`, `messages.created_at` |
| Minutos practicados/día | ✅ | `daily_stats.minutes_practiced` |
| Retención de vocabulario a 7 días | ✅ (pocos datos) | `learning_evidence()` |
| Misiones completadas | ✅ | `mission_instances.status` |
| Maná consumido por acción | ✅ | `mana_transactions` |
| Compras | ✅ (0 filas) | `payments`, `user_subscriptions` |
| Pantallas vistas | ❌ | no hay eventos de navegación |
| Finalización de lección | ⚠️ aproximable | `user_scenario_goals` + `scenario_progress` |
| Tiempo por turno | ⚠️ aproximable | `oracle_turns.response_time_sec` (solo Oráculo) |
| Abandono de sesión | ⚠️ aproximable | `conversations.status`/`ended_at` |
| Racha real | ❌ | el campo no se actualiza |
| Coste de IA por usuario | ❌ | `ai_usage_logs` vacía |

**No se puede afirmar nada sobre retención real**: producción solo tiene actividad
en 4 días de los últimos 30 y 1-2 usuarios por día; son cuentas de prueba.

---

## 5. Riesgos de retención (hechos + inferencia marcada)

| # | Hecho | Consecuencia probable (inferencia) | Confianza |
|---|---|---|---|
| 1 | Sin push ni correo | El regreso depende de la memoria del usuario | Alta |
| 2 | La racha no se actualiza | El principal ancla de hábito no funciona | Alta |
| 3 | El resumen muestra cifras fijas | Se rompe la percepción de progreso | Alta |
| 4 | No hay objetivo diario rastreado | El usuario no sabe si "cumplió" | Media |
| 5 | El valor depende de tener maná | Al agotarlo, la sesión termina | Alta |
| 6 | Las misiones semanales no se ven | Se pierde un horizonte de 7 días | Alta |
| 7 | No hay contenido nuevo tras el primer nivel | Repetición de escenarios | Media |
| 8 | El gremio está vacío | La capa social no retiene | Alta |
