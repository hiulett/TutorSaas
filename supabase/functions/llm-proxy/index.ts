// llm-proxy — Proxy seguro para DeepSeek (chat/SSE) y Groq (STT).
//
// Las claves de DeepSeek/Groq viven SOLO como Edge Function secrets
// (DEEPSEEK_API_KEY, GROQ_API_KEY). El cliente móvil autentica con el JWT
// de sesión de Supabase y la función reenvía la petición, de modo que el
// APK no contiene ninguna clave de IA.
//
// Endpoints:
//   POST /chat        { messages, stream, action_code?, conversation_id?,
//                       client_capabilities? } -> DeepSeek chat (SSE)
//   POST /transcribe  multipart (file)           -> Groq Whisper transcription
//   GET  /health                                 -> estado de la función
//
// Issue #9: cuota por usuario (30 peticiones/minuto) y allow-list de modelo.
// P-14 (#99): cada llamada se registra en `ai_usage_logs` (tokens, audio,
// latencia, estado y coste estimado). No se guarda texto de conversaciones.
// P-07 (#92): el maná se cobra AQUÍ, antes de llamar al modelo, según
// `ai_action_costs`. El cliente ya no cobra.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import {
  estimateChatCostUsd,
  estimateTranscribeCostUsd,
  extractUsageFromChatResponse,
  extractUsageFromSse,
  normalizeActionCode,
  normalizeUuid,
  type ChatUsage,
} from './usage.ts';
import {
  FREE_ACTIONS,
  normalizeCapabilities,
  normalizeManaChargeMode,
  shouldCharge,
  validateMessages,
} from './validation.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const supabase = createClient(supabaseUrl, supabaseAnonKey);
const admin = createClient(supabaseUrl, serviceRoleKey || supabaseAnonKey);

const deepseekApiKey = Deno.env.get('DEEPSEEK_API_KEY') ?? '';
const deepseekBaseUrl = Deno.env.get('DEEPSEEK_BASE_URL') ?? 'https://api.deepseek.com/v1';

// Límites estrictos de tokens de salida (evitan bucles del modelo y
// explicaciones excesivamente largas). El proxy aplica SIEMPRE un tope:
// respeta `max_tokens` del cliente solo si está dentro del rango válido;
// si el cliente no lo envía o lo excede, usa los valores siguientes.
const DEFAULT_MAX_TOKENS = 200;
const MAX_TOKENS_CAP = 600;
// #73: la evaluación del Oráculo devuelve un JSON con 10 puntuaciones,
// fortalezas, debilidades y explicación. Con 600 tokens se truncaba y el
// servidor caía al respaldo heurístico.
const MAX_TOKENS_CAP_ORACLE_EVAL = 1200;

// Issue #9: solo se permite el modelo que usa la app.
const DEFAULT_MODEL = 'deepseek-v4-flash';
const ALLOWED_MODELS = new Set([DEFAULT_MODEL]);

// Issue #9: ventana de 60 s, 30 peticiones (un turno hace ~2 llamadas).
const QUOTA_LIMIT_PER_MINUTE = 30;

// Issue #9: límite de audio por transcripción (10 MB).
const MAX_AUDIO_BYTES = 10 * 1024 * 1024;

// P-14: tope del buffer que se conserva para leer el `usage` del SSE. El
// chunk final de DeepSeek es pequeño; 32 KB cubren de sobra un final partido.
const SSE_USAGE_BUFFER_LIMIT = 32 * 1024;

// P-07: los topes de entrada (tokens del prompt bajo control del servidor) y
// su validación viven en `validation.ts`, probado con `deno test`.

// P-07: modo de cobro. `capability` (defecto de transicion) solo cobra si el
// cliente declara `server_mana`; `all` cobra siempre; `off` no cobra (rollback).
// Pasar a `all` cuando la app que ya no cobra en cliente este publicada.
const MANA_CHARGE_MODE = normalizeManaChargeMode(Deno.env.get('MANA_CHARGE_MODE'));

// P-07: copia de respaldo si `ai_action_costs` no responde (evita que un fallo
// de lectura convierta acciones de pago en gratuitas).
const FALLBACK_PAID_ACTIONS = new Set([
  'dungeon_turn',
  'free_chat_turn',
  // P-29-b (#193): correcciones en conversación libre.
  'correction_turn',
  'lesson_generation',
  'oracle_eval',
  'oracle_turn',
]);

const groqApiKey = Deno.env.get('GROQ_API_KEY') ?? '';
const groqSttUrl = Deno.env.get('GROQ_STT_URL') ?? 'https://api.groq.com/openai/v1/audio/transcriptions';

// P-20: CORS solo para el origen configurado. La app movil no envia Origin,
// asi que no necesita la cabecera; el web admin no llama al proxy.
const corsAllowedOrigin = Deno.env.get('CORS_ALLOWED_ORIGIN') ?? '';
const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  ...(corsAllowedOrigin.length > 0
    ? { 'Access-Control-Allow-Origin': corsAllowedOrigin, 'Vary': 'Origin' }
    : {}),
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const unauthorized = () => json({ error: 'Unauthorized' }, 401);

function readJwt(req: Request): string {
  const auth = req.headers.get('authorization') ?? '';
  const bearer = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
  // El anon key (apikey) no es un JWT de usuario; si llega solo, no autentica.
  if (!bearer || bearer === supabaseAnonKey) return '';
  return bearer;
}

async function requireUser(req: Request): Promise<{ id: string } | null> {
  try {
    const token = readJwt(req);
    if (!token) return null;
    const { data, error } = await supabase.auth.getUser(token);
    if (error || !data.user) return null;
    return { id: data.user.id };
  } catch {
    return null;
  }
}

// ── Cuota (issue #9, fail-closed desde P-07) ─────────────────────────────────

type QuotaResult = 'ok' | 'denied' | 'error';

async function checkQuota(userId: string): Promise<QuotaResult> {
  try {
    const { data, error } = await admin.rpc('check_llm_quota', {
      p_user_id: userId,
      p_limit: QUOTA_LIMIT_PER_MINUTE,
    });
    if (error) {
      console.error('quota check failed:', error.message);
      return 'error';
    }
    return data === true ? 'ok' : 'denied';
  } catch (e) {
    console.error('quota check error:', e);
    return 'error';
  }
}

// ── Cobro de maná (P-07 / #92) ────────────────────────────────────────────────

interface ChargeResult {
  success: boolean;
  source?: string;
  cost?: number;
  remaining?: number;
  reason?: string;
}

interface PaidActionsCache {
  at: number;
  codes: Set<string>;
}

let paidActionsCache: PaidActionsCache | null = null;
const PAID_ACTIONS_TTL_MS = 60_000;

async function paidActionCodes(): Promise<Set<string>> {
  const now = Date.now();
  if (paidActionsCache && now - paidActionsCache.at < PAID_ACTIONS_TTL_MS) {
    return paidActionsCache.codes;
  }
  try {
    const { data, error } = await admin
      .from('ai_action_costs')
      .select('action_code')
      .eq('is_active', true);
    if (error) throw new Error(error.message);
    const codes = new Set<string>(
      (data ?? [])
        .map((row: { action_code?: string }) => String(row.action_code ?? ''))
        .filter((code: string) => code.length > 0),
    );
    if (codes.size === 0) return FALLBACK_PAID_ACTIONS;
    paidActionsCache = { at: now, codes };
    return codes;
  } catch (e) {
    console.error('ai_action_costs load failed, using fallback:', e);
    return paidActionsCache?.codes ?? FALLBACK_PAID_ACTIONS;
  }
}

function shouldChargeTurn(capabilities: string[]): boolean {
  return shouldCharge(capabilities, MANA_CHARGE_MODE);
}

/// Cobra en nombre del usuario con service role. Lanza si la RPC falla.
async function chargeMana(userId: string, actionCode: string): Promise<ChargeResult> {
  const { data, error } = await admin.rpc('consume_mana', {
    p_user_id: userId,
    p_action_code: actionCode,
  });
  if (error) throw new Error(error.message);
  return (data ?? { success: false, reason: 'unknown' }) as ChargeResult;
}

/// P-26: reclama el turno de gracia diario (una vez por día, service role).
async function claimManaGrace(userId: string): Promise<boolean> {
  try {
    const { data, error } = await admin.rpc('claim_mana_grace', {
      p_user_id: userId,
    });
    if (error) {
      console.error('claim_mana_grace failed:', error.message);
      return false;
    }
    return data === true;
  } catch (e) {
    console.error('claim_mana_grace error:', e);
    return false;
  }
}

/// Devuelve el maná de un intento fallido. Solo aplica a cobros del plan:
/// `refund_mana` no restaura ítems equipados (fuera de alcance, como P-06).
async function refundMana(userId: string, actionCode: string): Promise<void> {
  try {
    const { error } = await admin.rpc('refund_mana', {
      p_user_id: userId,
      p_action_code: actionCode,
    });
    if (error) console.error('refund_mana failed:', error.message);
  } catch (e) {
    console.error('refund_mana error:', e);
  }
}

// ── Registro de uso de IA (P-14 / #99) ───────────────────────────────────────

type UsageStatus = 'ok' | 'error' | 'timeout' | 'rate_limited' | 'no_mana' | 'blocked';

interface UsageLogInput {
  userId: string;
  actionCode: string;
  model: string | null;
  conversationId?: string | null;
  inputTokens?: number | null;
  outputTokens?: number | null;
  audioSeconds?: number | null;
  latencyMs: number;
  status: UsageStatus;
  costEstimateUsd?: number | null;
}

/// Best-effort: un fallo al registrar nunca debe tumbar la conversación.
async function logAiUsage(entry: UsageLogInput): Promise<void> {
  try {
    const { error } = await admin.from('ai_usage_logs').insert({
      user_id: entry.userId,
      conversation_id: entry.conversationId ?? null,
      action_code: entry.actionCode,
      model: entry.model,
      input_tokens: entry.inputTokens ?? null,
      output_tokens: entry.outputTokens ?? null,
      audio_seconds: entry.audioSeconds ?? null,
      cost_estimate_usd: entry.costEstimateUsd ?? null,
      latency_ms: entry.latencyMs,
      status: entry.status,
    });
    if (error) console.error('ai_usage_logs insert failed:', error.message);
  } catch (e) {
    console.error('ai_usage_logs insert error:', e);
  }
}

/// Reenvía el SSE tal cual y, de paso, registra el `usage` del chunk final.
/// El cliente debe leer hasta `[DONE]`: si corta antes, el usage no llega.
function streamWithUsageLogging(
  upstream: ReadableStream<Uint8Array>,
  ctx: {
    userId: string;
    actionCode: string;
    model: string;
    conversationId: string | null;
    startedAt: number;
  },
): ReadableStream<Uint8Array> {
  const decoder = new TextDecoder();
  let buffer = '';
  let logged = false;

  const flushLog = (usage: ChatUsage | null) => {
    if (logged) return;
    logged = true;
    void logAiUsage({
      userId: ctx.userId,
      actionCode: ctx.actionCode,
      model: ctx.model,
      conversationId: ctx.conversationId,
      inputTokens: usage?.inputTokens ?? null,
      outputTokens: usage?.outputTokens ?? null,
      latencyMs: Math.round(performance.now() - ctx.startedAt),
      status: 'ok',
      costEstimateUsd: usage ? estimateChatCostUsd(usage) : null,
    });
  };

  return upstream.pipeThrough(
    new TransformStream<Uint8Array, Uint8Array>({
      transform(chunk, controller) {
        controller.enqueue(chunk);
        buffer += decoder.decode(chunk, { stream: true });
        if (buffer.length > SSE_USAGE_BUFFER_LIMIT) {
          buffer = buffer.slice(-SSE_USAGE_BUFFER_LIMIT);
        }
        const usage = extractUsageFromSse(buffer);
        if (usage) flushLog(usage);
      },
      flush() {
        buffer += decoder.decode();
        flushLog(extractUsageFromSse(buffer));
      },
    }),
  );
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const url = new URL(req.url);
  // Robust path dispatch: el último segmento es el endpoint, sin importar el
  // prefijo que la plataforma anteponga (p.ej. /functions/v1/<slug>/health).
  const segments = url.pathname.split('/').filter((s) => s.trim().length > 0);
  const path = segments.length > 0 ? `/${segments[segments.length - 1]}` : '/';

  if (path === '/health' && req.method === 'GET') {
    // P-20: no se revela que claves estan configuradas ni el modo de cobro.
    return json({ ok: true, ts: new Date().toISOString() });
  }

  if (path !== '/chat' && path !== '/transcribe' && path !== '/health') {
    return json({ error: 'Not found', path: url.pathname, segments }, 404);
  }

  // Auth: todo endpoint de IA exige un usuario autenticado (JWT válido).
  const user = await requireUser(req);
  if (!user) return unauthorized();

  // Issue #9 + P-07: cuota antes de gastar tokens del proveedor.
  // Fail-closed: si no se puede comprobar, se rechaza con un error controlado.
  const quota = await checkQuota(user.id);
  if (quota === 'denied') {
    return json(
      {
        error: 'rate_limited',
        message: 'Demasiadas peticiones. Espera un momento y vuelve a intentarlo.',
      },
      429,
    );
  }
  if (quota === 'error') {
    return json(
      {
        error: 'quota_unavailable',
        message: 'No se pudo verificar la cuota. Reintenta en unos segundos.',
      },
      503,
    );
  }

  try {
    if (path === '/chat') {
      return await handleChat(req, user.id);
    }
    return await handleTranscribe(req, user.id);
  } catch (e) {
    console.error('llm-proxy error:', e);
    return json({ error: String(e) }, 500);
  }
});

// ── POST /chat → DeepSeek (soporta streaming SSE) ─────────────────────────────

async function handleChat(req: Request, userId: string): Promise<Response> {
  if (!deepseekApiKey) return json({ error: 'DeepSeek not configured' }, 500);

  const startedAt = performance.now();
  const body = await req.json();
  const messages = body?.messages;
  if (!Array.isArray(messages)) {
    return json({ error: 'messages array is required' }, 400);
  }

  // P-07: topes de entrada (tokens de prompt controlados por el servidor).
  const limitError = validateMessages(messages);
  if (limitError) {
    return json({ error: 'payload_too_large', message: limitError }, 413);
  }

  const stream = body?.stream ?? true;

  // P-14/P-07: acción de IA. Si no llega, se asume turno de conversación libre.
  const rawAction = typeof body?.action_code === 'string'
    ? body.action_code.trim().toLowerCase()
    : '';
  const actionCode = rawAction.length > 0
    ? normalizeActionCode(rawAction, '')
    : 'free_chat_turn';
  if (!actionCode) {
    return json({ error: 'invalid_action', action_code: rawAction.slice(0, 40) }, 400);
  }

  const conversationId = normalizeUuid(body?.conversation_id);
  const capabilities = normalizeCapabilities(body?.client_capabilities);

  // Issue #9: el modelo lo decide el servidor. Si el cliente pide otro, se
  // degrada al permitido en lugar de reenviarlo.
  const requestedModel = typeof body?.model === 'string' ? body.model : DEFAULT_MODEL;
  const model = ALLOWED_MODELS.has(requestedModel) ? requestedModel : DEFAULT_MODEL;
  if (model !== requestedModel) {
    console.warn('model not allowed, falling back:', requestedModel);
  }

  // P-07: valida la acción contra `ai_action_costs` (o la lista de gratuitas).
  const paidActions = await paidActionCodes();
  const isPaid = paidActions.has(actionCode);
  if (!isPaid && !FREE_ACTIONS.has(actionCode)) {
    return json({ error: 'invalid_action', action_code: actionCode }, 400);
  }

  // P-07: cobra ANTES de llamar al modelo. Sin saldo no se gasta IA.
  let charged: ChargeResult | null = null;
  if (isPaid && shouldChargeTurn(capabilities)) {
    try {
      const result = await chargeMana(userId, actionCode);
      if (!result.success) {
        // P-26: turno de gracia diario. Si se agotó el tope diario del plan
        // gratuito, se permite este turno sin cobro para que el usuario pueda
        // cerrar el intercambio en curso (una vez por día, server-side).
        if (result.reason === 'daily_limit_reached' && await claimManaGrace(userId)) {
          console.info('mana grace turn used', { userId, actionCode });
          charged = {
            success: true,
            source: 'grace',
            cost: 0,
            remaining: result.remaining ?? 0,
          };
        } else {
          void logAiUsage({
            userId,
            actionCode,
            model,
            conversationId,
            latencyMs: Math.round(performance.now() - startedAt),
            status: 'no_mana',
          });
          return json(
            {
              error: 'no_mana',
              reason: result.reason ?? 'insufficient_mana',
              cost: result.cost ?? null,
              remaining: result.remaining ?? null,
            },
            402,
          );
        }
      } else {
        charged = result;
      }
    } catch (e) {
      console.error('consume_mana failed:', e);
      void logAiUsage({
        userId,
        actionCode,
        model,
        conversationId,
        latencyMs: Math.round(performance.now() - startedAt),
        status: 'error',
      });
      return json(
        {
          error: 'mana_unavailable',
          message: 'No se pudo verificar tu maná. Reintenta en unos segundos.',
        },
        503,
      );
    }
  }

  // Si el intento falla después de cobrar, se devuelve el maná (solo plan).
  const refundIfCharged = async () => {
    if (charged?.source === 'plan') {
      await refundMana(userId, actionCode);
    }
  };

  const temperature = body?.temperature;
  const requestedMaxTokens = typeof body?.max_tokens === 'number'
    ? body.max_tokens
    : DEFAULT_MAX_TOKENS;
  // #73: la evaluación del Oráculo necesita más espacio de salida que un turno
  // de chat (JSON con 10 métricas). El resto de acciones mantienen el tope.
  const maxTokensCap = actionCode === 'oracle_eval' ? MAX_TOKENS_CAP_ORACLE_EVAL : MAX_TOKENS_CAP;
  const maxTokens = Math.min(Math.max(requestedMaxTokens, 1), maxTokensCap);

  const payload: Record<string, unknown> = {
    model,
    messages,
    stream,
    max_tokens: maxTokens,
  };
  if (typeof temperature === 'number') payload.temperature = temperature;
  // P-14: pide a DeepSeek el bloque `usage` también en streaming.
  if (stream) payload.stream_options = { include_usage: true };

  // Retry con backoff ante errores transitorios del proveedor (429/5xx).
  const maxAttempts = 3;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    let upstream: Response;
    try {
      upstream = await fetch(`${deepseekBaseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${deepseekApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });
    } catch (e) {
      // Fallo de red: no es reintentable aquí si el fetch lanzó por DNS/TLS.
      await refundIfCharged();
      void logAiUsage({
        userId,
        actionCode,
        model,
        conversationId,
        latencyMs: Math.round(performance.now() - startedAt),
        status: 'error',
      });
      throw e;
    }

    if (upstream.ok) {
      if (stream) {
        // Reenvío SSE transparente al cliente (burbuja de streaming en la app).
        return new Response(
          upstream.body
            ? streamWithUsageLogging(upstream.body, {
              userId,
              actionCode,
              model,
              conversationId,
              startedAt,
            })
            : null,
          {
            status: 200,
            headers: {
              ...corsHeaders,
              'Content-Type': 'text/event-stream',
              'Cache-Control': 'no-cache',
              'Connection': 'keep-alive',
            },
          },
        );
      }
      const data = await upstream.json();
      const usage = extractUsageFromChatResponse(data);
      void logAiUsage({
        userId,
        actionCode,
        model,
        conversationId,
        inputTokens: usage.inputTokens,
        outputTokens: usage.outputTokens,
        latencyMs: Math.round(performance.now() - startedAt),
        status: 'ok',
        costEstimateUsd: estimateChatCostUsd(usage),
      });
      return json(data);
    }

    const errText = await upstream.text();
    console.error(`DeepSeek upstream error (attempt ${attempt}/${maxAttempts}):`, upstream.status, errText);

    // Defensa: si el proveedor no soporta `stream_options`, se reintenta sin
    // él. Se pierde el desglose de tokens, pero la conversación no se rompe.
    if (upstream.status === 400 && payload.stream_options) {
      console.warn('stream_options rejected by provider, retrying without usage chunk');
      delete payload.stream_options;
      continue;
    }

    const retryable = upstream.status === 429 || upstream.status === 500 || upstream.status === 503;
    if (attempt < maxAttempts && retryable) {
      // Backoff exponencial: 500ms, 1s, 2s.
      await new Promise((r) => setTimeout(r, 500 * Math.pow(2, attempt - 1)));
      continue;
    }

    await refundIfCharged();
    void logAiUsage({
      userId,
      actionCode,
      model,
      conversationId,
      latencyMs: Math.round(performance.now() - startedAt),
      status: 'error',
    });
    return json({ error: `DeepSeek error ${upstream.status}` }, upstream.status);
  }

  await refundIfCharged();
  return json({ error: 'DeepSeek request failed' }, 500);
}

// ── POST /transcribe → Groq Whisper ───────────────────────────────────────────

async function handleTranscribe(req: Request, userId: string): Promise<Response> {
  if (!groqApiKey) return json({ error: 'Groq not configured' }, 500);

  const startedAt = performance.now();
  const form = await req.formData();
  const file = form.get('file');
  if (!(file instanceof File)) {
    return json({ error: 'file is required' }, 400);
  }

  // Issue #9: no se aceptan audios desproporcionados.
  if (file.size > MAX_AUDIO_BYTES) {
    return json({ error: 'audio too large', max_bytes: MAX_AUDIO_BYTES }, 413);
  }

  const model = (form.get('model') as string) ?? 'whisper-large-v3-turbo';
  const language = (form.get('language') as string) ?? 'en';
  const responseFormat = (form.get('response_format') as string) ?? 'json';
  const actionCode = normalizeActionCode(form.get('action_code'), 'stt_transcribe');

  // P-14: se pide `verbose_json` internamente para obtener `duration` (segundos
  // de audio). Al cliente se le devuelve la misma forma que pidió.
  const wantsVerbose = responseFormat === 'verbose_json';
  const canMeasureDuration = responseFormat === 'json' || wantsVerbose;

  const upstreamForm = new FormData();
  upstreamForm.append('file', file, file.name || 'recording.m4a');
  upstreamForm.append('model', model);
  upstreamForm.append('language', language);
  upstreamForm.append('response_format', canMeasureDuration ? 'verbose_json' : responseFormat);

  const upstream = await fetch(groqSttUrl, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${groqApiKey}` },
    body: upstreamForm,
  });

  if (!upstream.ok) {
    const errText = await upstream.text();
    console.error('Groq upstream error:', upstream.status, errText);
    void logAiUsage({
      userId,
      actionCode,
      model,
      latencyMs: Math.round(performance.now() - startedAt),
      status: 'error',
    });
    return json({ error: `Groq error ${upstream.status}` }, upstream.status);
  }

  const data = await upstream.json();
  const audioSeconds = typeof data?.duration === 'number' && Number.isFinite(data.duration)
    ? data.duration
    : null;

  void logAiUsage({
    userId,
    actionCode,
    model,
    audioSeconds,
    latencyMs: Math.round(performance.now() - startedAt),
    status: 'ok',
    costEstimateUsd: estimateTranscribeCostUsd(audioSeconds),
  });

  if (canMeasureDuration && !wantsVerbose) {
    // Contrato histórico del cliente: solo `{ text }`.
    return json({ text: typeof data?.text === 'string' ? data.text : '' });
  }
  return json(data);
}
