// llm-proxy — Proxy seguro para DeepSeek (chat/SSE) y Groq (STT).
//
// Las claves de DeepSeek/Groq viven SOLO como Edge Function secrets
// (DEEPSEEK_API_KEY, GROQ_API_KEY). El cliente móvil autentica con el JWT
// de sesión de Supabase y la función reenvía la petición, de modo que el
// APK no contiene ninguna clave de IA.
//
// Endpoints:
//   POST /chat        { messages, stream } -> DeepSeek chat completions (SSE)
//   POST /transcribe  multipart (file)     -> Groq Whisper transcription
//   GET  /health                            -> estado de la función

import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

const deepseekApiKey = Deno.env.get('DEEPSEEK_API_KEY') ?? '';
const deepseekBaseUrl = Deno.env.get('DEEPSEEK_BASE_URL') ?? 'https://api.deepseek.com/v1';
const groqApiKey = Deno.env.get('GROQ_API_KEY') ?? '';
const groqSttUrl = Deno.env.get('GROQ_STT_URL') ?? 'https://api.groq.com/openai/v1/audio/transcriptions';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const unauthorized = () =>
  json({ error: 'Unauthorized' }, 401);

function readJwt(req: Request): string {
  const auth = req.headers.get('authorization') ?? '';
  const bearer = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
  // El anon key (apikey) no es un JWT de usuario; si llega solo, no autentica.
  if (!bearer || bearer === supabaseAnonKey) return '';
  return bearer;
}

async function requireUser(req: Request): Promise<boolean> {
  try {
    const token = readJwt(req);
    if (!token) return false;
    const { data, error } = await supabase.auth.getUser(token);
    return !error && !!data.user;
  } catch {
    return false;
  }
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
    return json({
      ok: true,
      hasDeepSeek: !!deepseekApiKey,
      hasGroq: !!groqApiKey,
      ts: new Date().toISOString(),
    });
  }

  if (path !== '/chat' && path !== '/transcribe' && path !== '/health') {
    return json({ error: 'Not found', path: url.pathname, segments }, 404);
  }

  // Auth: todo endpoint de IA exige un usuario autenticado (JWT válido).
  if (!(await requireUser(req))) {
    return unauthorized();
  }

  try {
    if (path === '/chat') {
      return await handleChat(req);
    }
    return await handleTranscribe(req);
  } catch (e) {
    console.error('llm-proxy error:', e);
    return json({ error: String(e) }, 500);
  }
});

// ── POST /chat → DeepSeek (soporta streaming SSE) ─────────────────────────────

async function handleChat(req: Request): Promise<Response> {
  if (!deepseekApiKey) return json({ error: 'DeepSeek not configured' }, 500);

  const body = await req.json();
  const messages = body?.messages;
  if (!Array.isArray(messages)) {
    return json({ error: 'messages array is required' }, 400);
  }
  const stream = body?.stream ?? true;
  const model = body?.model ?? 'deepseek-v4-flash';
  const temperature = body?.temperature;

  const payload: Record<string, unknown> = {
    model,
    messages,
    stream,
  };
  if (typeof temperature === 'number') payload.temperature = temperature;

  // Retry con backoff ante errores transitorios del proveedor (429/5xx).
  const maxAttempts = 3;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const upstream = await fetch(`${deepseekBaseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${deepseekApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (upstream.ok) {
      if (stream) {
        // Reenvío SSE transparente al cliente (burbuja de streaming en la app).
        return new Response(upstream.body, {
          status: 200,
          headers: {
            ...corsHeaders,
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
          },
        });
      }
      const data = await upstream.json();
      return json(data);
    }

    const errText = await upstream.text();
    console.error(`DeepSeek upstream error (attempt ${attempt}/${maxAttempts}):`, upstream.status, errText);
    const retryable = upstream.status === 429 || upstream.status === 500 || upstream.status === 503;
    if (attempt < maxAttempts && retryable) {
      // Backoff exponencial: 500ms, 1s, 2s.
      await new Promise((r) => setTimeout(r, 500 * Math.pow(2, attempt - 1)));
      continue;
    }
    return json({ error: `DeepSeek error ${upstream.status}` }, upstream.status);
  }

  return json({ error: 'DeepSeek request failed' }, 500);
}

// ── POST /transcribe → Groq Whisper ───────────────────────────────────────────

async function handleTranscribe(req: Request): Promise<Response> {
  if (!groqApiKey) return json({ error: 'Groq not configured' }, 500);

  const form = await req.formData();
  const file = form.get('file');
  if (!(file instanceof File)) {
    return json({ error: 'file is required' }, 400);
  }
  const model = (form.get('model') as string) ?? 'whisper-large-v3-turbo';
  const language = (form.get('language') as string) ?? 'en';
  const responseFormat = (form.get('response_format') as string) ?? 'json';

  const upstreamForm = new FormData();
  upstreamForm.append('file', file, file.name || 'recording.m4a');
  upstreamForm.append('model', model);
  upstreamForm.append('language', language);
  upstreamForm.append('response_format', responseFormat);

  const upstream = await fetch(groqSttUrl, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${groqApiKey}` },
    body: upstreamForm,
  });

  if (!upstream.ok) {
    const errText = await upstream.text();
    console.error('Groq upstream error:', upstream.status, errText);
    return json({ error: `Groq error ${upstream.status}` }, upstream.status);
  }

  const data = await upstream.json();
  return json(data);
}
