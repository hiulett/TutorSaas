# Operaciones

_Actualizado: 18-oct-2026._

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
| `MANA_CHARGE_MODE` | `llm-proxy` (cobro de maná: `all` por defecto, `capability`, `off`) |
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

- `capability` (defecto de transición): cobra solo si el cliente envía
  `client_capabilities: ["server_mana"]`. Las builds antiguas siguen cobrando en
  cliente y no se les cobra dos veces.
- `all` (estado final): cobra siempre. Pásalo a `all` cuando la app que ya no
  cobra en cliente esté publicada; cierra el hueco de los clientes modificados.
- `off`: no cobra (rollback de emergencia; la IA queda gratis).

Acciones gratuitas (no están en `ai_action_costs`): `goal_eval`, `carisma_eval`,
`guild_chat`, `stt_transcribe`.

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

Pendiente legal: actualizar el aviso de privacidad de la ficha de Play para
declarar estos eventos agregados (no se envia texto de conversacion).

## 4. Cron

| Job | Frecuencia | Qué hace |
|---|---|---|
| `rotate-daily-missions` | `5 0 * * *` | Rota el tablón de misiones (00:05 UTC) |
| `clean-old-logs` | `15 3 * * *` | Poda logs antiguos |
| `purge-stale-participants` | `* * * * *` | Borra participantes sin latido (>180 s) |
| `reactivation-email-daily` | `0 10 * * *` | **No activo**: email de reactivación (3 y 7 días). Ver [runbook](runbooks/REACTIVATION_EMAIL.md) |

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
