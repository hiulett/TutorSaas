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
| `sync-entitlement` | Reconcilia RevenueCat con `user_subscriptions` a petición del usuario | ✅ |
| `livekit-token` | Emite tokens de sala de voz | ✅ |
| `lesson-generator` | Genera lecciones con IA | ✅ |
| `revenuecat-webhook` | Procesa eventos de compra; valida un Bearer propio | ❌ |
| `missions-cron` | Rota misiones diarias; protegida por `CRON_SECRET` | ❌ |

```sh
supabase functions deploy <nombre> --project-ref sipiumfdpvnszthykyog --use-api
supabase functions list --project-ref sipiumfdpvnszthykyog
```

`--use-api` evita necesitar Docker para desplegar.

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
| `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | Todas |

⚠️ `config.json` y `web_admin/.env` no se commitean. Las claves de IA nunca van
en el cliente.

---

## 4. Cron

| Job | Frecuencia | Qué hace |
|---|---|---|
| `rotate-daily-missions` | `5 0 * * *` | Rota el tablón de misiones (00:05 UTC) |
| `clean-old-logs` | `15 3 * * *` | Poda logs antiguos |
| `purge-stale-participants` | `* * * * *` | Borra participantes sin latido (>180 s) |

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
