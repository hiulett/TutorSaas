# 17 — Métricas y analítica

> Medición: 25-oct-2026. Evidencia: `retention_analytics.dart`, llamadas a
> `track`, `analytics_events` en producción (463 filas) y `analytics_events` RLS.

---

## 1. Instrumentación existente

Un único mecanismo: `RetentionAnalytics.track(userId, eventName, properties)`
inserta en **`analytics_events`** (`retention_analytics.dart:27-41`). Es
fire-and-forget: nunca lanza.

| Evento | Dónde se emite | Propiedades | Volumen en producción |
|---|---|---|---|
| `app_open` | `app.dart:27` (1 por proceso) | — | 12 |
| `session_start` | `conversation_providers.dart:149-156` | — | 17 |
| `session_end` | `conversation_providers.dart:1623-1632` | — | 8 |
| `invoke_llm` | `conversation_repository_impl.dart:160-161` | — | 416 |
| `paywall_viewed` | `paywall_screen.dart:41-59` | — | 4 |
| `purchase_started` | `paywall_screen.dart` | — | 1 |
| `purchase_succeeded` | `paywall_screen.dart` | — | 1 |
| `claim_daily` | `daily_reward_modal.dart` | — | 4 |

**Ningún evento lleva propiedades.** No se registra `scenario_id`, `level`,
`duration`, `goal_id`, `result`, `error_code` ni `plan`.

Tablas auxiliares con valor analítico:

| Tabla | Qué aporta | Volumen |
|---|---|---|
| `conversations` | Inicio/fin/duración/estado | 68 |
| `messages` | Turnos por conversación | 740 (305 de usuario) |
| `daily_stats` | Minutos y conversaciones por día | 4 |
| `mana_transactions` | Consumo por acción | 39 |
| `mission_instances` | Misiones creadas/completadas | 533 / 7 |
| `oracle_assessments` / `oracle_turns` | Exámenes y turnos con tiempos | 76 |
| `vocabulary_reviews` | Repasos y retención diferida | 7 |
| `session_reward_ledger` | Cierres con recompensa | 2 |
| `llm_quota_events` | Peticiones contadas por cuota | 45 |
| `api_request_logs` | Llamadas y errores de IA | 32 |
| `ai_usage_logs` | **Coste/tokens** | **0** |

---

## 2. Qué se puede medir hoy

| Métrica | Fórmula con datos actuales | Limitación |
|---|---|---|
| Usuarios registrados | `count(users)` | Incluye pruebas |
| Onboarding completado | `count(user_language_profiles)` | No distingue de cuentas antiguas |
| Sesiones/día | `conversations.started_at` | Sin identificar abandono |
| Turnos/sesión | `messages` por `conversation_id` | — |
| Minutos/día | `daily_stats.minutes_practiced` | Solo si se cerró sesión |
| Maná por acción | `mana_transactions.action_code` | — |
| Misiones completadas | `mission_instances.status='completed'` | Doble conteo posible |
| Retención de vocabulario | `learning_evidence()` | Muestra pequeña |
| Uso de IA | `llm_quota_events` | Sin tokens |
| Coste de IA | ❌ | No instrumentado |
| Pantallas vistas | ❌ | No hay evento de navegación |
| Respuestas correctas/incorrectas | ❌ | No existe noción de "correcto" |
| Abandono de lección | ⚠️ aproximable | `conversations` sin `ended_at` |
| Racha | ❌ | Campo no actualizado |
| Suscripción cancelada | ⚠️ | `revenuecat_events` (webhook) |

---

## 3. Brechas de medición (por prioridad)

### P0 — sin esto no se puede decidir nada

| # | Métrica | Definición propuesta | Dónde instrumentar | Datos |
|---|---|---|---|---|
| M1 | Embudo de onboarding | eventos por paso (inicio, idioma, oráculo, personaje, fin) | `onboarding_screen` | `step`, `elapsed_ms` |
| M2 | Activación | primera lección iniciada y cerrada en <24 h | `conversation_providers` | `scenario_id`, `level`, `goals_done/total` |
| M3 | Sesión de aprendizaje | inicio, turnos, duración, cierre, motivo de salida | `conversation_providers` | `turns`, `minutes`, `exit_reason`, `mana_start/end` |
| M4 | Coste de IA | modelo, tokens in/out, latencia, coste | `llm-proxy` → `ai_usage_logs` | por llamada |
| M5 | Error de IA | tipo, endpoint, código, reintentos | `llm-proxy` + cliente | `error_code` |
| M6 | Retención D1/D7 | por `user_id` y `app_open`/sesión | ya hay `app_open` | requiere cohortes |

### P1 — mejoran el diagnóstico

| # | Métrica | Datos |
|---|---|---|
| M7 | Metas cumplidas por escenario y nivel | `goal_id`, `completed` |
| M8 | Repetición de lección | `attempts`, `best_ratio` (ya en `scenario_progress`) |
| M9 | Uso del SRS | tarjetas vistas, aciertos, retención |
| M10 | Paywall → compra | `paywall_viewed`, `purchase_started`, `purchase_succeeded`, `plan_id` |
| M11 | Consumo de maná y punto de agotamiento | `action_code`, saldo previo |
| M12 | Uso del chat de texto vs voz | `input_mode` |

### P2 — nice to have

- Tiempo por turno y latencia percibida.
- Uso de tópicos y frases útiles.
- Abandono del examen del Oráculo.
- Distribución de niveles asignados.

---

## 4. Privacidad

- `analytics_events` permite INSERT/SELECT solo del dueño (RLS verificada).
- No se debe añadir contenido de conversación a los eventos: basta con IDs y
  agregados.
- No se registran datos personales en `api_request_logs` (solo endpoint y estado).
- `ai_usage_logs` debería guardar tokens y coste, no el texto.

---

## 5. Recomendación de instrumentación mínima (fase 2)

Una taxonomía de ~12 eventos con propiedades acotadas:

```
onboarding_step(step, elapsed_ms)
onboarding_complete(cefr, minutes)
lesson_start(scenario_id, level, mana_start)
turn(mode, input_mode, goals_open)
lesson_end(scenario_id, turns, minutes, goals_done, goals_total, exit_reason)
srs_review(cards, correct, delayed)
mission_claimed(type, xp, gems)
paywall_viewed(source)
purchase(plan_id, result)
ai_error(endpoint, code, retries)
ai_usage(model, tokens_in, tokens_out, latency_ms)   # servidor
app_open()
```

Con eso se pueden calcular activación, sesión media, coste por sesión, retención
D1/D7, conversión y calidad del aprendizaje sin añadir datos sensibles.
