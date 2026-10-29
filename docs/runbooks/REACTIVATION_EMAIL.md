# Email de reactivación (issue #107 / P-22)

_Escrito: 29-oct-2026._

Canal de retorno por email para jugadores inactivos. La app **no** participa:
todo vive entre `pg_cron`, la Edge Function `reactivation-email`, la RPC
`reactivation_candidates` y la tabla `reactivation_emails`.

---

## 1. Piezas

| Pieza | Dónde | Qué hace |
|---|---|---|
| Edge Function | `supabase/functions/reactivation-email/` | Selecciona, renderiza y envía; atiende la baja |
| Plantillas es/en/pt | `supabase/functions/reactivation-email/templates.ts` | Texto del email (nada hardcodeado en `index.ts`) |
| Migración | `supabase/migrations/20261029053927_reactivation_emails.sql` | Opt-out, tabla de envíos, RPC de selección y de baja |
| Opt-out | `user_settings.reactivation_emails` (default `true`) | Lo puede leer y escribir el dueño (`user_settings_self`) |
| Token de baja | `user_settings.reactivation_unsubscribe_token` (uuid) | Credencial del enlace; no adivinable, no requiere login |
| Historial | `reactivation_emails` | 1 fila por intento; sin direcciones de email |

Reglas de idempotencia (en la base, no en el código):

- `unique (user_id, sent_on)` → **máximo 1 email al día** por usuario.
- `unique (user_id, stage_days, last_activity_on)` → **máximo 1 email por etapa
  (3 o 7 días) por episodio de inactividad**. Si el jugador vuelve y recae, la
  fecha de actividad cambia y empieza un episodio nuevo (máx. 2 emails por
  episodio).
- `reactivation_candidates` excluye además a quien recibió cualquier email en
  los últimos `p_window_days` (3 por defecto).

---

## 2. Alta del proveedor (Resend)

1. Crear cuenta en <https://resend.com> y **verificar el dominio** de envío
   (registros SPF y DKIM en el DNS). Sin dominio verificado Resend solo entrega
   al correo del propietario de la cuenta.
2. Crear una API key con permiso de envío.
3. Cargar los secretos de la función:

```sh
supabase secrets set RESEND_API_KEY=re_... \
  RESEND_FROM="Dungeon of English <hola@tudominio.com>" \
  --project-ref sipiumfdpvnszthykyog
```

`REACTIVATION_CTA_URL` es opcional (por defecto la ficha de Play
`com.tutorsaas.tutorsaas`). `RESEND_API_URL` también es opcional (para apuntar a
un proveedor compatible con la API de Resend).

**Los valores nunca se commitean ni se pegan en issues/PRs.**

---

## 3. Despliegue

```sh
supabase functions deploy reactivation-email \
  --project-ref sipiumfdpvnszthykyog --use-api --no-verify-jwt
```

`--no-verify-jwt` es obligatorio: pg_cron no manda un JWT de usuario y la baja
tiene que funcionar sin sesión. La autorización real la hace la función:

- `Authorization: Bearer <service role key>` → operador.
- `Authorization: Bearer <secreto de cron>` → validado con `verify_cron_secret`
  (reutiliza el secreto de Vault `missions_cron_secret`, el mismo de
  `missions-cron`).

---

## 4. Prueba segura (no envía nada)

`dry_run` es **true por defecto**. Devuelve el recuento y una muestra
anonimizada (hash corto del `user_id`, sin email).

```sh
# Sustituye $SRK por la service role key del proyecto (no la pegues en el chat)
curl -s -X POST \
  -H "Authorization: Bearer $SRK" \
  -H "Content-Type: application/json" \
  -d '{"inactive_days":7}' \
  https://sipiumfdpvnszthykyog.supabase.co/functions/v1/reactivation-email
```

Respuesta esperada (ejemplo):

```json
{
  "ok": true, "dry_run": true, "provider": "resend",
  "provider_configured": false, "inactive_days": 7, "window_days": 3,
  "candidates": 33, "by_stage": {"7": 33}, "by_locale": {"es": 33},
  "sample": [{"player":"…","stage_days":7,"days_inactive":71,"locale":"es","streak":0}]
}
```

Sin `RESEND_API_KEY`, un envío real (`{"dry_run":false}`) responde
**503 `not_configured`** y no escribe ni envía nada.

---

## 5. Cron (NO activado)

El job se deja escrito pero **inactivo** hasta que exista `RESEND_API_KEY` y el
dominio esté verificado.

```sql
-- Ejecuta la función una vez al día a las 10:00 UTC.
-- `inactive_days: 3` selecciona la etapa 3; la función sube sola a la etapa 7
-- en cuanto el jugador acumula 7 días (y no repite etapas ya enviadas).
select cron.schedule(
  'reactivation-email-daily',
  '0 10 * * *',
  $$
  select net.http_post(
    url := 'https://sipiumfdpvnszthykyog.supabase.co/functions/v1/reactivation-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' ||
        (select decrypted_secret from vault.decrypted_secrets
          where name = 'missions_cron_secret')
    ),
    body := '{"dry_run": false, "inactive_days": 3, "window_days": 3, "limit": 50}'::jsonb,
    timeout_milliseconds := 60000
  );
  $$
);
```

Activación (cuando el proveedor esté listo):

1. Cargar `RESEND_API_KEY` y `RESEND_FROM` (§2).
2. Desplegar la función (§3).
3. Ejecutar el `cron.schedule` de arriba **desde el SQL Editor**.
4. Comprobar: `select jobname, schedule, active from cron.job;`
5. Primer día: mirar `select * from cron.job_run_details order by start_time desc limit 5;`
   y `select status, count(*) from reactivation_emails group by 1;`

Desactivar o pausar:

```sql
select cron.unschedule('reactivation-email-daily');
-- o, sin borrar el job:
update cron.job set active = false where jobname = 'reactivation-email-daily';
```

**No** se activa en esta entrega: sin dominio verificado los envíos fallarían y
gastaríamos filas de historial.

---

## 6. Baja (unsubscribe)

Cada email incluye:

- Enlace visible: `…/functions/v1/reactivation-email?unsubscribe=<token>`
- Cabeceras `List-Unsubscribe` y `List-Unsubscribe-Post` (one-click RFC 8058).

El enlace abre una página sin login y ejecuta
`reactivation_unsubscribe(token)`, que pone `reactivation_emails = false` y
sella `reactivation_unsubscribed_at`. Es idempotente y no revela el email.

Comprobar el estado de un usuario (solo lectura):

```sql
select reactivation_emails, reactivation_unsubscribed_at
  from public.user_settings where user_id = '<uuid>';
```

---

## 7. Diagnóstico

```sql
-- Últimos intentos (sin PII)
select sent_on, status, stage_days, locale, provider_message_id, error_code
  from public.reactivation_emails
 order by created_at desc limit 20;

-- Cuántos candidatos habría ahora (no envía)
select count(*) from public.reactivation_candidates(7, 3, 500);
```

| Síntoma | Causa probable |
|---|---|
| `503 not_configured` | Falta `RESEND_API_KEY` en los secretos de la función |
| `401 Unauthorized` | Token de cron distinto al de Vault, o service key mal copiada |
| `failed` + `http_403` | Dominio no verificado o `RESEND_FROM` no pertenece al dominio |
| `skipped` alto | Idempotencia: ya se envió hoy o esa etapa en el episodio |
| `candidates: 0` | Nadie cumple antigüedad, o todos están en opt-out / sin email confirmado |

---

## 8. Privacidad

- `reactivation_emails` **no** guarda direcciones: `user_id`, fechas, etapa,
  idioma, id del proveedor y estado.
- Los logs solo usan un hash corto del `user_id`.
- La baja no requiere login y persiste en `user_settings`.
- Pendiente de producto: mencionar el email de reactivación en la política de
  privacidad publicada (fuera del alcance de esta historia).
