# Operaciones

_Actualizado: 29-oct-2026 (funciones, cron y modo de cobro verificados contra
producción y código)._

---

## 1. Entornos

| Entorno | Dónde | Notas |
|---|---|---|
| Producción | Supabase `sipiumfdpvnszthykyog` | Único entorno real; la app publicada y las builds locales apuntan aquí |
| Admin web | `web_admin/` (React + Vite) | Usa el mismo proyecto Supabase |
| Local | `flutter run -d <device>` | Emulador o teléfono físico |

No hay entorno de staging. Las pruebas se hacen contra producción con cuentas
de prueba (`test*@mailinator.com`).

---

## 2. Edge Functions

| Función | Propósito | `verify_jwt` |
|---|---|---|
| `llm-proxy` | Proxy de DeepSeek (chat SSE) y Groq (STT). Las claves viven aquí | ✅ |
| `evaluate-placement` | Evalúa el examen del Oráculo y persiste el nivel CEFR (llama a `llm-proxy` con `oracle_eval`) | ✅ |
| `sync-entitlement` | Reconcilia RevenueCat con `user_subscriptions` a petición del usuario | ✅ |
| `livekit-token` | Emite tokens de sala de voz | ✅ |
| `lesson-generator` | Genera lecciones con IA | ✅ |
| `revenuecat-webhook` | Procesa eventos de compra; valida un Bearer propio | ❌ |
| `missions-cron` | Rota misiones diarias; protegida por `CRON_SECRET` | ❌ |
| `reactivation-email` | Email de reactivación + baja sin login; `dry_run` por defecto | ❌ |

```sh
supabase functions deploy <nombre> --project-ref sipiumfdpvnszthykyog --use-api
supabase functions list --project-ref sipiumfdpvnszthykyog
```

`--use-api` evita necesitar Docker para desplegar.

Comprobado el 29-oct-2026: **8 funciones desplegadas y activas** con el
`verify_jwt` de la tabla (`llm-proxy` v18, `missions-cron`, `livekit-token`,
`revenuecat-webhook`, `lesson-generator`, `sync-entitlement`,
`evaluate-placement`, `reactivation-email`).

Topes de salida de `llm-proxy`: 200 tokens por defecto y 600 como máximo; la
evaluación del Oráculo (`action_code = oracle_eval`) tiene 1200 porque devuelve
un JSON con 10 métricas y con 600 se truncaba (#73).

---

## 3. Secretos

```sh
supabase secrets list --project-ref sipiumfdpvnszthykyog   # nombres (valores hasheados)
supabase secrets set NOMBRE=valor --project-ref ...
```

| Secreto | Usado por |
|---|---|
| `DEEPSEEK_API_KEY`, `DEEPSEEK_BASE_URL` | `llm-proxy`, `lesson-generator` |
| `GROQ_API_KEY`, `GROQ_STT_URL` | `llm-proxy` (STT) |
| `LIVEKIT_API_KEY`, `LIVEKIT_API_SECRET`, `LIVEKIT_URL` | `livekit-token` |
| `REVENUECAT_AUTH_TOKEN` | `revenuecat-webhook` (Bearer que envía RevenueCat) |
| `REVENUECAT_SECRET_KEY` | `sync-entitlement` (API v1, `sk_…`) |
| `CRON_SECRET` | `missions-cron` |
| `AI_PRICE_INPUT_PER_1M`, `AI_PRICE_OUTPUT_PER_1M`, `AI_PRICE_STT_PER_MINUTE` | `llm-proxy` (estimación de coste; opcionales) |
| `MANA_CHARGE_MODE` | `llm-proxy` (cobro de maná: `capability` por defecto en el código, `all`, `off`) |
| `RESEND_API_KEY`, `RESEND_FROM` | `reactivation-email` (opcional `REACTIVATION_CTA_URL`) |
| `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | Todas |

⚠️ `config.json` y `web_admin/.env` no se commitean. Las claves de IA nunca van
en el cliente.

### 3.1 Coste de IA (P-14)

`llm-proxy` inserta una fila por llamada en `ai_usage_logs` (sin texto de
conversación): `action_code`, `model`, `input_tokens`, `output_tokens`,
`audio_seconds`, `latency_ms`, `status` y `cost_estimate_usd`.

Tarifas por defecto (sobrescribibles con los secretos de la tabla):

| Secreto | Defecto | Concepto |
|---|---|---|
| `AI_PRICE_INPUT_PER_1M` | `0.27` | USD por 1M tokens de entrada |
| `AI_PRICE_OUTPUT_PER_1M` | `1.10` | USD por 1M tokens de salida |
| `AI_PRICE_STT_PER_MINUTE` | `0.000667` | USD por minuto de audio (Groq Whisper) |

`cost_estimate_usd` es una **estimación**, no una factura: ajústala si cambia
el contrato del proveedor.

#### Medición y optimización (P-41)

Vista `ai_cost_by_session` (respeta RLS con `security_invoker`): coste, tokens y
número de llamadas por conversación. Se rellena solo cuando el cliente envía
`conversation_id` en `/chat`.

```sql
-- coste por sesión y por acción (últimos 30 días)
select * from public.ai_cost_by_session order by started_at desc limit 20;
select action_code, count(*), round(avg(input_tokens)) as in,
       round(avg(output_tokens)) as out, round(sum(cost_estimate_usd)::numeric, 4) as usd
  from public.ai_usage_logs
 where created_at > now() - interval '30 days'
 group by 1 order by 5 desc;
```

**Estado (29-oct-2026):** hay muy pocas llamadas registradas (8) y casi ninguna
con `conversation_id`, así que **aún no hay baseline por sesión**. Las
optimizaciones aplicadas son las de coste evidente:

1. **Evaluación de metas con gate** (`GoalEvaluationGate`): la llamada extra de
   IA solo se hace si la respuesta del alumno tiene ≥5 palabras o una palabra
   clave de una meta pendiente; el cierre de sesión fuerza una última evaluación
   para no perder objetivos. Ahorra una llamada por turno en respuestas vacías
   o monosílabos.
2. **Historial por longitud** (`maxChatContextChars = 6000`): además del tope de
   24 mensajes, se recorta por caracteres conservando los 4 últimos. 24 mensajes
   largos ya no viajan enteros en cada turno.

Pendiente (necesita datos o un golden set de P-39): combinar metas + errores +
vocabulario en una sola llamada, modelo más pequeño para tareas booleanas y
resumen del contexto antiguo (esto último añade una llamada, así que solo tiene
sentido si el ahorro de contexto la compensa).

#### Correcciones en conversación libre (P-29-b / #193 · P-40-c / #222)

En una lección con metas pendientes las correcciones viajan en la respuesta de
`goal_eval` (gratuita) y **no** hay llamada extra. Cuando no hay `goal_eval` en
el turno —chat libre, lección sin metas o metas ya cumplidas— el cliente pide
solo las correcciones con su propio `action_code`:

| `action_code` | Coste | Quién lo pide | Cuándo |
|---|---|---|---|
| `correction_turn` | **0 maná** (gratuita desde P-40-c) | `ConversationRepository.evaluateTurnCorrections` | Turno sin `goal_eval`, si el gate y el presupuesto lo permiten |

Alta original de P-29-b con `apply_migration
ai_action_costs_correction_turn_p29b` (versión `20261029145742`). P-40-c la
desactiva con `apply_migration ai_action_costs_correction_turn_free_p40c`
(versión `20261030035724`, archivo
`supabase/migrations/20261030035724_ai_action_costs_correction_turn_free_p40c.sql`).

Por qué es gratuita: el maná ya lo paga el turno de conversación
(`free_chat_turn`/`dungeon_turn`); las correcciones son su salida pedagógica.
Cobrarlas aparte dejaba a los planes sin saldo sin ningún historial en
`user_recurring_errors`, así que el tutor nunca podía adaptarse (P-40).

Mecánica: la fila de `ai_action_costs` queda con `is_active = false` y el proxy
acepta la acción por `FREE_ACTIONS` (`supabase/functions/llm-proxy/validation.ts`).
La lista de gratuitas tiene prioridad sobre la tabla, de modo que el orden de
despliegue no puede cobrarla por error. `consume_mana` nunca se llama.

Rollback (volver a cobrar): reactivar la fila
(`update public.ai_action_costs set is_active = true where action_code =
'correction_turn'`), quitar `correction_turn` de `FREE_ACTIONS` y desplegar el
proxy. No hace falta tocar el cliente: si la acción desaparece, recibe
`400 invalid_action` y lo trata como fallo silencioso (sin chip, chat intacto).

Reglas de activación (`CorrectionTurnPolicy`, lógica pura y testeada):

1. **Gate existente**: la respuesta del alumno necesita ≥5 palabras
   (`GoalEvaluationGate`); en chat libre no hay metas que aporten keywords.
2. **Tope por sesión**: máximo **6** evaluaciones (`maxEvaluationsPerSession`).
   Ya no se traduce en maná, pero acota el gasto real de tokens (6 llamadas
   cortas por sesión frente a un turno de conversación por mensaje). Los
   intentos fallidos también consumen presupuesto.
3. **`correction_level = important_only`** no llama al modelo. Ese nivel sigue
   recibiendo correcciones en lecciones con metas (donde la evaluación ya se
   paga para marcar objetivos).
4. **Sin duplicados**: si el turno lanzó `goal_eval`, `correction_turn` no se
   pide aunque quede presupuesto.
5. **Sin maná no cambia nada**: no hay ninguna condición de saldo. Un alumno que
   conversa con el turno de gracia sigue generando correcciones.

Degradación: un fallo de red, un JSON ilegible o un `429` dejan el turno igual y
consumen una de las 6 evaluaciones (se reintenta en el turno siguiente dentro del
tope). Un `402 no_mana` solo puede venir de un proxy antiguo todavía desplegado;
se cuenta igual y no se muestra error. Las correcciones se registran en
`public.corrections` (`turn_ref` + `upsert` idempotente) y el chip se pinta bajo
la burbuja como en P-29. Un invitado, un turno sin `turn_ref` o una lista vacía
no escriben fila (`CorrectionTurnPolicy.shouldPersist`).

Evento de analítica: `correction_eval` (`analytics_events`), con `action`,
`result` (`ok` | `no_mana` | `failed`), `count` (correcciones aceptadas),
`evals` (acumulado de la sesión) y `level`. Sin texto del alumno.

```sql
-- Coste real de las correcciones en chat libre (últimos 30 días)
select action_code, count(*) as calls,
       round(avg(input_tokens)) as tokens_in,
       round(sum(cost_estimate_usd)::numeric, 4) as usd
from public.ai_usage_logs
where action_code = 'correction_turn'
  and created_at > now() - interval '30 days'
group by 1;

-- Coste por sesión incluyendo correcciones
select conversation_id, sum(calls) as calls, round(sum(cost_estimate_usd), 4) as usd
from public.ai_usage_by_session
where started_at > now() - interval '7 days'
group by 1 order by 3 desc limit 20;
```


### 3.2 Cobro de maná en el proxy (P-07)

Desde P-07 el maná se cobra en `llm-proxy`, **antes** de llamar al modelo, con
`consume_mana` y el `action_code` validado contra `ai_action_costs`. El cliente
ya no cobra.

| Situación | Respuesta |
|---|---|
| Saldo insuficiente (plan o límite diario) | `402` `{"error":"no_mana","reason":"insufficient_mana"}` |
| `action_code` desconocido o inactivo | `400` `{"error":"invalid_action"}` |
| `consume_mana` falla por BD | `503` `{"error":"mana_unavailable"}` (fail-closed) |
| `check_llm_quota` falla | `503` `{"error":"quota_unavailable"}` (fail-closed) |
| Prompt demasiado grande (>40 mensajes, >4.000 car/mensaje, >24.000 total) | `413` `{"error":"payload_too_large"}` |

Si el proveedor falla después de cobrar, el proxy llama a `refund_mana`
(solo cobros `source='plan'`; los ítems equipados quedan fuera, como en P-06).

`MANA_CHARGE_MODE`:

- `capability` (**defecto del código**: un valor desconocido o vacío también cae
  aquí): cobra solo si el cliente envía `client_capabilities: ["server_mana"]`.
  Las builds antiguas siguen cobrando en cliente y no se les cobra dos veces.
- `all` (estado final): cobra siempre. Pásalo a `all` cuando la app que ya no
  cobra en cliente esté publicada; cierra el hueco de los clientes modificados.
- `off`: no cobra (rollback de emergencia; la IA queda gratis).

Acciones gratuitas (lista `FREE_ACTIONS` del proxy; no se cobran aunque exista
fila): `goal_eval`, `carisma_eval`, `guild_chat`, `stt_transcribe`,
`correction_turn` (P-40-c; su fila en `ai_action_costs` queda inactiva).

```sql
-- Coste por usuario y día
select user_id, day, action_code, calls, tokens_in, tokens_out,
       audio_seconds, cost_estimate_usd
from public.ai_usage_daily
order by day desc, cost_estimate_usd desc;

-- Coste por sesión (conversación)
select * from public.ai_usage_by_session
order by cost_estimate_usd desc limit 20;

-- Coste diario agregado (service role)
select day, sum(calls) as calls, round(sum(cost_estimate_usd), 4) as usd
from public.ai_usage_daily group by day order by day desc;
```

---

### 3.3 Analitica de producto (P-15)

Los eventos viven en `analytics_events (user_id, event_name, properties jsonb, created_at)`.
La taxonomia esta en `lib/core/analytics/analytics_taxonomy.dart`.

Reglas de `properties`:

- Solo ids, codigos y contadores. Nunca email, nombre, texto de conversacion,
  audio ni tokens.
- `sanitizeAnalyticsProperties` descarta claves con PII, listas/mapas y trunca
  los textos a 200 caracteres.

Vistas (RLS: el dueno ve lo suyo; `app_metadata.role = 'admin'` ve todo):

| Vista | Que mide |
|---|---|
| `analytics_onboarding_funnel` | Embudo por paso + completados |
| `analytics_activation` | Primera sesion dentro de 24 h del registro |
| `analytics_retention` | Actividad D1 / D7 / D30 por cohorte |
| `analytics_sessions_per_week` | Sesiones por usuario y semana |

Panel: `web_admin` -> pestana "Retencion y Embudo".

Privacidad: el aviso in-app del onboarding (`privacy_body` en los tres `.arb`)
declara que se guardan metricas de uso agregadas sin texto de conversacion ni
datos personales. Queda como tarea de operaciones (fuera del repo) reflejar lo
mismo en el formulario **Data Safety** de la ficha de Play.

## 4. Cron

| Job | Frecuencia | Qué hace |
|---|---|---|
| `rotate-daily-missions` | `5 0 * * *` | Rota el tablón de misiones (00:05 UTC) |
| `clean-old-logs` | `15 3 * * *` | Poda logs antiguos |
| `purge-stale-participants` | `* * * * *` | Borra participantes sin latido (>180 s) |
| `reactivation-email-daily` | `0 10 * * *` | **No programado**: el envío de reactivación (3 y 7 días) está implementado, pero el `cron.schedule` no se ejecuta hasta que exista `RESEND_API_KEY`. Ver [runbook](runbooks/REACTIVATION_EMAIL.md) |

```sql
select jobname, schedule, active from cron.job;
select * from cron.job_run_details order by start_time desc limit 20;
```

---

## 5. Webhook de RevenueCat

| Campo | Valor |
|---|---|
| URL | `https://sipiumfdpvnszthykyog.supabase.co/functions/v1/revenuecat-webhook` |
| App | `app69c16b2a83` (**Play Store**, no Test Store) |
| Eventos | initial_purchase, renewal, product_change, cancellation, billing_issue, uncancellation, transfer, subscription_paused, expiration, subscription_extended |
| Auth | `Authorization: Bearer <REVENUECAT_AUTH_TOKEN>` |

Comprobación rápida:

```sh
curl -s https://…/functions/v1/revenuecat-webhook                  # {"received":true}
curl -s -X POST -H "Content-Length: 0" https://…/revenuecat-webhook # {"error":"Unauthorized"}
```

Errores típicos:

| Síntoma | Causa |
|---|---|
| `app_id` distinto de `app69c16b2a83` | Los eventos de Play no llegan (pasó el 18-oct) |
| 401 en todas las entregas | `REVENUECAT_AUTH_TOKEN` distinto entre dashboard y Supabase |
| Compra sin plan | Webhook caído → la app corrige con `sync-entitlement` al abrirse |

---

## 6. Logs y diagnóstico

```sql
-- logs unificados (ClickHouse) vía MCP: source = 'auth_logs' | 'function_logs' | 'edge_logs'
```

- Errores de funciones: `function_logs`.
- Auth (logins, correos sin confirmar): `auth_logs`.
- Estado de suscripción: `user_subscriptions`.
- Maná: `mana_transactions`.

---

## 7. CI

`.github/workflows/ci.yml` ejecuta `flutter analyze` y `flutter test` en cada
push/PR. **No hay despliegue automático**: la app se sube a mano a Play, las
funciones con `supabase functions deploy` y el admin web con `npm run build` +
hosting estático.

---

## 8. Runbooks

- [Pruebas de compra (Play + RevenueCat)](runbooks/PURCHASE_TESTING.md)
- [Estado de las migraciones](runbooks/MIGRATION_STATUS.md)
- [Email de reactivación](runbooks/REACTIVATION_EMAIL.md)

---

## 9. Contenido de comprensión auditiva (P-30 / #115)

El audio de los ejercicios lo sintetiza `flutter_tts` en el dispositivo: **no
hay Edge Function, ni `action_code`, ni coste de IA**. Lo único que se escribe
en servidor son los intentos y el progreso.

### Añadir un ejercicio

Insertar una fila en `public.listening_exercises` (SQL Editor o MCP). No hace
falta desplegar la app: el cliente lee el banco al abrir la Ruta.

```sql
insert into public.listening_exercises (slug, level, title, context, lines, questions, sort_order)
values (
  'b2_airport_announcement',          -- slug estable (va en la URL y en lesson_id)
  'B2',                               -- PRE-A1 | A1 | A2 | B1 | B2 | C1 | C2
  'Airport announcement',
  'You are waiting at the gate.',
  '[
    {"speaker": "Announcer", "text": "Flight BA two four nine is now boarding at gate twelve."},
    {"speaker": "Passenger", "text": "Did they say gate twelve or gate twenty?"}
  ]'::jsonb,
  '[
    {
      "id": "q1",
      "prompt": "Which flight is boarding?",
      "options": [
        {"id": "a", "text": "BA 249"},
        {"id": "b", "text": "BA 429"},
        {"id": "c", "text": "BA 2490"}
      ],
      "correct": "a",
      "explanation": "The announcement says flight BA two four nine."
    }
  ]'::jsonb,
  20                                  -- orden dentro del nivel
)
on conflict (slug) do update
  set level = excluded.level,
      title = excluded.title,
      context = excluded.context,
      lines = excluded.lines,
      questions = excluded.questions,
      sort_order = excluded.sort_order,
      is_active = true;
```

Reglas de contenido (las valida un `check` y el cliente):

- `lines`: 1–8 intervenciones, cada una con `speaker` y `text`.
- `questions`: 1–8, con al menos 2 opciones y `correct` apuntando a una de
  ellas. Un ítem mal formado se descarta al cargar (y el ejercicio no se ofrece).
- `slug` no se cambia después de publicar: es el `lesson_id` del progreso
  (`listening:<slug>`) y la clave de la URL `/listening?exerciseId=<slug>`.

### Retirar o corregir un ejercicio

- Corrección de texto: `update` de la fila (los intentos ya guardados no se
  recalculan).
- Retirada: `update public.listening_exercises set is_active = false`.

### Verificar

```sql
select slug, level, jsonb_array_length(questions) as preguntas
  from public.listening_exercises
 where is_active
 order by level, sort_order;

select user_id, score, total, passed, created_at
  from public.listening_attempts
 order by created_at desc
 limit 20;
```

Los minutos de práctica y la racha asociados se consultan en `practice_sessions`
(`session_id like 'listening:%'`).
