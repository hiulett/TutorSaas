// reactivation-email — Issue #107 (P-22). Canal de retorno por email.
//
// Responsabilidades:
//   * Seleccionar usuarios inactivos con email verificado y opt-in (la lógica
//     vive en la RPC `reactivation_candidates`, no aquí).
//   * Enviar el email por Resend y registrar el intento en
//     `reactivation_emails` (idempotente: 1 email/día y 1 por etapa y episodio).
//   * Atender la baja sin login: `GET|POST ?unsubscribe=<token>`.
//
// Seguridad:
//   * `verify_jwt=false`: la invoca pg_cron con el secreto de cron de Vault
//     (validado con `verify_cron_secret`) o un operador con la service role key.
//   * Sin `RESEND_API_KEY` y con `dry_run:false` responde 503 `not_configured`
//     y no envía nada. `dry_run` es el modo por defecto, así que un cron mal
//     configurado no manda correos.
//   * No se registran direcciones de email en logs ni en respuestas: solo
//     identificadores anonimizados (sha256 corto del user_id).
//
// Variables de entorno:
//   RESEND_API_KEY   (secreto, obligatorio para enviar)
//   RESEND_FROM      (opcional) remitente, p.ej. "Dungeon of English <hola@dominio>"
//   RESEND_API_URL   (opcional) endpoint del proveedor
//   REACTIVATION_CTA_URL (opcional) destino del botón; por defecto la ficha de Play

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { normalizeLocale, renderEmail } from './templates.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const resendApiKey = Deno.env.get('RESEND_API_KEY') ?? '';
const resendFrom = Deno.env.get('RESEND_FROM') ??
  'Dungeon of English <onboarding@resend.dev>';
const resendApiUrl = Deno.env.get('RESEND_API_URL') ??
  'https://api.resend.com/emails';
const appUrl = Deno.env.get('REACTIVATION_CTA_URL') ??
  'https://play.google.com/store/apps/details?id=com.tutorsaas.tutorsaas';

const DEFAULT_INACTIVE_DAYS = 7;
const DEFAULT_WINDOW_DAYS = 3;
const DEFAULT_LIMIT = 50;
const MAX_LIMIT = 500;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const htmlPage = (message: string, status = 200) =>
  new Response(
    `<!doctype html><html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Dungeon of English</title></head>
<body style="margin:0;background:#05070E;color:#E1E2ED;font-family:-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
<div style="max-width:520px;margin:0 auto;padding:48px 20px;">
<p style="margin:0 0 20px;font-size:11px;letter-spacing:3px;text-transform:uppercase;color:#00E5FF;">Dungeon of English</p>
<p style="margin:0;font-size:17px;line-height:1.6;">${message}</p>
</div></body></html>`,
    { status, headers: { 'Content-Type': 'text/html; charset=utf-8' } },
  );

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function clampInt(value: unknown, fallback: number, min: number, max: number) {
  const parsed = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(parsed)) return fallback;
  return Math.min(max, Math.max(min, Math.trunc(parsed)));
}

// Comparación en tiempo constante (evita filtrar el secreto por temporización).
function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

// Identificador estable y anónimo para logs/respuestas (nunca el email).
async function anonymize(userId: string): Promise<string> {
  const bytes = new TextEncoder().encode(userId);
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return Array.from(new Uint8Array(digest).slice(0, 5))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

interface Candidate {
  user_id: string;
  email: string;
  display_name: string | null;
  locale: string;
  streak: number | null;
  unsubscribe_token: string;
  last_activity_on: string;
  days_inactive: number;
  stage_days: number;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const url = new URL(req.url);
  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  // --- Baja sin login (token opaco del propio usuario) ---------------------
  const unsubscribeToken = url.searchParams.get('unsubscribe');
  if (unsubscribeToken) {
    if (req.method !== 'GET' && req.method !== 'POST') {
      return json({ error: 'Method not allowed' }, 405);
    }
    if (!UUID_RE.test(unsubscribeToken)) {
      return htmlPage('Este enlace de baja no es válido.', 400);
    }
    const { data, error } = await admin.rpc('reactivation_unsubscribe', {
      p_token: unsubscribeToken,
    });
    if (error) {
      console.error('reactivation_unsubscribe error:', error.message);
      return htmlPage('No pudimos procesar la baja. Inténtalo más tarde.', 500);
    }
    if (data !== true) {
      return htmlPage('Este enlace de baja no es válido o ya caducó.', 404);
    }
    const message =
      'Listo: no volverás a recibir correos de reactivación. Puedes seguir usando la app con normalidad.';
    if (req.method === 'POST') {
      // RFC 8058 (one-click): basta con un 2xx.
      return new Response(message, {
        status: 200,
        headers: { 'Content-Type': 'text/plain; charset=utf-8' },
      });
    }
    return htmlPage(message, 200);
  }

  if (req.method === 'GET') {
    return json({
      ok: true,
      function: 'reactivation-email',
      dry_run_default: true,
    });
  }
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  // --- Autenticación (cron o service role) --------------------------------
  const auth = req.headers.get('authorization') ?? '';
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  if (!token) return json({ error: 'Unauthorized' }, 401);

  // 1) service role key del propio runtime (comparación en tiempo constante).
  let authorized = Boolean(serviceKey) && safeEqual(token, serviceKey);

  // 2) Cualquier clave con permiso de service role: se comprueba usándola
  //    contra una RPC que solo service_role puede ejecutar. Así funcionan tanto
  //    la legacy JWT como las nuevas `sb_secret_...` sin hardcodear formatos.
  if (!authorized) {
    const probe = createClient(supabaseUrl, token, {
      auth: { persistSession: false },
    });
    const { error: probeError } = await probe.rpc('reactivation_candidates', {
      p_inactive_days: 90,
      p_window_days: 90,
      p_limit: 1,
    });
    authorized = !probeError;
  }

  // 3) Secreto de cron compartido (Vault), el mismo que usa missions-cron.
  if (!authorized) {
    const { data, error } = await admin.rpc('verify_cron_secret', {
      p_token: token,
    });
    if (error) {
      console.error('verify_cron_secret error:', error.message);
      return json({ error: 'Unauthorized' }, 401);
    }
    authorized = data === true;
  }
  if (!authorized) return json({ error: 'Unauthorized' }, 401);

  // --- Parámetros ----------------------------------------------------------
  let body: Record<string, unknown> = {};
  try {
    body = (await req.json()) as Record<string, unknown>;
  } catch {
    body = {};
  }

  const dryRun = body.dry_run !== false;
  const inactiveDays = clampInt(
    body.inactive_days,
    DEFAULT_INACTIVE_DAYS,
    1,
    90,
  );
  const windowDays = clampInt(body.window_days, DEFAULT_WINDOW_DAYS, 1, 90);
  const limit = clampInt(body.limit, DEFAULT_LIMIT, 1, MAX_LIMIT);

  if (!dryRun && !resendApiKey) {
    return json(
      {
        error: 'not_configured',
        detail: 'Falta el secreto RESEND_API_KEY en la Edge Function',
      },
      503,
    );
  }

  const { data, error } = await admin.rpc('reactivation_candidates', {
    p_inactive_days: inactiveDays,
    p_window_days: windowDays,
    p_limit: limit,
  });
  if (error) {
    console.error('reactivation_candidates error:', error.message);
    return json({ error: 'db_error', detail: error.message }, 500);
  }

  const candidates = (data ?? []) as Candidate[];

  const byStage: Record<string, number> = {};
  const byLocale: Record<string, number> = {};
  for (const c of candidates) {
    byStage[String(c.stage_days)] = (byStage[String(c.stage_days)] ?? 0) + 1;
    byLocale[c.locale] = (byLocale[c.locale] ?? 0) + 1;
  }

  // --- Simulación (por defecto) -------------------------------------------
  if (dryRun) {
    const sample = await Promise.all(
      candidates.slice(0, 5).map(async (c) => ({
        player: await anonymize(c.user_id),
        stage_days: c.stage_days,
        days_inactive: c.days_inactive,
        locale: c.locale,
        streak: c.streak ?? 0,
      })),
    );
    return json({
      ok: true,
      dry_run: true,
      provider: 'resend',
      provider_configured: Boolean(resendApiKey),
      inactive_days: inactiveDays,
      window_days: windowDays,
      candidates: candidates.length,
      by_stage: byStage,
      by_locale: byLocale,
      sample,
    });
  }

  // --- Envío real ----------------------------------------------------------
  let sent = 0;
  let failed = 0;
  let skipped = 0;
  const failures: Array<{ player: string; code: string }> = [];

  for (const candidate of candidates) {
    const player = await anonymize(candidate.user_id);
    const locale = normalizeLocale(candidate.locale);
    const unsubscribeUrl =
      `${supabaseUrl}/functions/v1/reactivation-email?unsubscribe=${candidate.unsubscribe_token}`;

    // Reserva antes de enviar: los UNIQUE de la tabla garantizan idempotencia
    // aunque haya dos ejecuciones concurrentes.
    const { data: reserved, error: reserveError } = await admin
      .from('reactivation_emails')
      .insert({
        user_id: candidate.user_id,
        stage_days: candidate.stage_days,
        last_activity_on: candidate.last_activity_on,
        locale,
        provider: 'resend',
        status: 'sending',
      })
      .select('id')
      .single();

    if (reserveError) {
      if (reserveError.code === '23505') {
        skipped++;
        continue;
      }
      failed++;
      failures.push({ player, code: 'reserve_failed' });
      console.error('reactivation reserve_failed', player, reserveError.message);
      continue;
    }

    const rowId = reserved?.id as string;
    const content = renderEmail(locale, {
      name: candidate.display_name ?? '',
      streak: candidate.streak ?? 0,
      daysInactive: candidate.days_inactive,
      appUrl,
      unsubscribeUrl,
    });

    try {
      const response = await fetch(resendApiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${resendApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: resendFrom,
          to: [candidate.email],
          subject: content.subject,
          html: content.html,
          text: content.text,
          headers: {
            'List-Unsubscribe': `<${unsubscribeUrl}>`,
            'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
          },
        }),
      });

      if (!response.ok) {
        const code = `http_${response.status}`;
        await response.body?.cancel();
        failed++;
        failures.push({ player, code });
        await admin
          .from('reactivation_emails')
          .update({ status: 'failed', error_code: code, updated_at: new Date().toISOString() })
          .eq('id', rowId);
        console.error('reactivation provider_error', player, code);
        continue;
      }

      const payload = await response.json().catch(() => null);
      await admin
        .from('reactivation_emails')
        .update({
          status: 'sent',
          provider_message_id: payload?.id ?? null,
          updated_at: new Date().toISOString(),
        })
        .eq('id', rowId);
      sent++;
    } catch (e) {
      failed++;
      failures.push({ player, code: 'network_error' });
      await admin
        .from('reactivation_emails')
        .update({ status: 'failed', error_code: 'network_error', updated_at: new Date().toISOString() })
        .eq('id', rowId);
      console.error('reactivation network_error', player, String(e));
    }
  }

  console.log(
    `reactivation-email done: candidates=${candidates.length} sent=${sent} failed=${failed} skipped=${skipped}`,
  );

  return json({
    ok: true,
    dry_run: false,
    provider: 'resend',
    inactive_days: inactiveDays,
    window_days: windowDays,
    candidates: candidates.length,
    sent,
    failed,
    skipped,
    by_stage: byStage,
    by_locale: byLocale,
    failures: failures.slice(0, 10),
  });
});
