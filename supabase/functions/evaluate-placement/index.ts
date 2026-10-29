// evaluate-placement — evalúa el examen oral del Oráculo en el servidor (#73).
//
// El cliente ya no decide el nivel CEFR: envía la transcripción de sus
// respuestas y recibe un nivel validado y persistido. La llamada al modelo se
// hace a través de `llm-proxy /chat` con `action_code = oracle_eval`, así que
// el maná se cobra en el servidor (P-07) y el uso queda en `ai_usage_logs`
// (P-14). Esta función no habla con DeepSeek directamente para no duplicar
// coste ni saltarse la cuota.
//
// Reglas:
// - Escala cerrada: PRE-A1…C2 y rango F…SSS. Cualquier otro valor se descarta.
// - Modo promoción: el nivel nunca baja (solo sube o se mantiene).
// - La pista declarada por el Oráculo en la conversación se acepta solo si
//   está a ±1 banda de la evaluación del servidor.
//
// P-31 (#116) — el examen de promoción es un jefe con reglas verificables en
// el servidor, no una cadena de texto del modelo:
// - Se exige evidencia mínima (respuestas y palabras) antes de evaluar.
// - Rúbrica fija de 6 dimensiones y umbral explícito: para ASCENDER hace falta
//   media >= 65 y ninguna dimensión < 45. Si no se cumple, el nivel se mantiene
//   y se devuelve el motivo.
// - Cooldown de 12 h tras un intento que no ascendió.
// - Cada intento se registra en `boss_exam_attempts` (service role); el cliente
//   no puede escribirlo.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const CEFR_SCALE = ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
const RANK_SCALE = ['F', 'E', 'D', 'C', 'B', 'A', 'S', 'SS', 'SSS'];
const RANK_BY_CEFR: Record<string, string> = {
  'PRE-A1': 'F',
  'A1': 'E',
  'A2': 'D',
  'B1': 'C',
  'B2': 'B',
  'C1': 'A',
  'C2': 'S',
};
const SCORE_KEYS = [
  'listening',
  'speaking',
  'pronunciation',
  'vocabulary',
  'grammar',
  'sentence_structure',
  'confidence',
  'fluency',
  'response_time',
  'naturalness',
];

// Límites de entrada: el prompt es coste del servidor.
const MAX_ANSWERS = 40;
const MAX_ANSWER_CHARS = 2000;
const MAX_TOTAL_CHARS = 20000;

// P-31 (#116): reglas del jefe de mazmorra.
const MIN_BOSS_ANSWERS = 5;
const MIN_BOSS_WORDS = 25;
const BOSS_COOLDOWN_HOURS = 12;
const RUBRIC_DIMENSIONS = [
  'listening',
  'fluency',
  'grammar',
  'vocabulary',
  'pronunciation',
  'naturalness',
] as const;
const RUBRIC_PASS_AVERAGE = 65;
const RUBRIC_MIN_DIMENSION = 45;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

const SYSTEM_PROMPT = `You are the Oracle of the Guild, an ancient and wise being that has judged thousands of adventurers in the Kingdom of the Word. You speak in a mystical, wise tone but evaluate objectively.

A young hunter has spoken with you. Your task is to classify their spoken English from the conversation transcripts provided.

Assign:
1. A CEFR level (PRE-A1, A1, A2, B1, B2, C1 or C2). PRE-A1 is for speakers who can only manage isolated words (hello, yes/no, numbers, basic colors) with minimal vocabulary and no sentences.
2. A game rank from the scale: F, E, D, C, B, A, S, SS, SSS (F is lowest, SSS is highest). PRE-A1 maps to F, A1 maps to E.
3. Scores from 0 to 100 for ALL of these dimensions:
   - listening (how well they understood the questions)
   - speaking (overall speaking ability)
   - pronunciation (clarity and intelligibility)
   - vocabulary (range, precision, appropriateness)
   - grammar (correctness of structures, tenses, agreement)
   - sentence_structure (variety and complexity of sentences)
   - confidence (willingness to answer, hesitation)
   - fluency (flow, pace, no long pauses)
   - response_time (how quickly they responded)
   - naturalness (how natural the language sounds, not memorized)
4. Short lists of strengths and weaknesses (at most 3 items each, under 60 characters per item).
5. A brief explanation of your judgment (under 240 characters).
6. A recommended focus area (one short phrase, under 60 characters) the student should work on next.

Evaluation rules:
- Be objective and strict but encouraging.
- Weigh difficult/expanded answers more than one-word replies.
- If the transcript contains mostly isolated words (one-word answers, minimal vocabulary, no sentences), assign PRE-A1/F rather than A1.
- If a transcript looks like STT noise or empty, do not penalize harshly; note it.
- Comprehension is judged by how relevant each answer is to the question asked.
- Cap: C2/SSS only for truly outstanding, complex, natural English.

Return ONLY a valid JSON object with EXACTLY these keys (no markdown, no code fences, no extra text):
{
  "cefr_level": "B1",
  "game_rank": "C",
  "scores": {"listening": 72, "speaking": 68, "pronunciation": 70, "vocabulary": 65, "grammar": 60, "sentence_structure": 62, "confidence": 78, "fluency": 66, "response_time": 75, "naturalness": 64},
  "strengths": ["clear basic sentences", "good comprehension"],
  "weaknesses": ["limited vocabulary range", "frequent tense mistakes"],
  "explanation": "Short paragraph justifying the assigned level.",
  "recommended_focus": "Past tenses and extended answers"
}`;

function normalizeCefr(raw: unknown): string {
  const value = String(raw ?? '').trim().toUpperCase();
  if (CEFR_SCALE.includes(value)) return value;
  if (value === 'A0' || value === 'PREA1' || value === 'PRE_A1' || value === 'PRE A1') {
    return 'PRE-A1';
  }
  return '';
}

function normalizeRank(raw: unknown): string {
  const value = String(raw ?? '').trim().toUpperCase();
  return RANK_SCALE.includes(value) ? value : '';
}

function normalizeScores(raw: unknown): Record<string, number> {
  const out: Record<string, number> = {};
  if (raw && typeof raw === 'object') {
    for (const key of SCORE_KEYS) {
      const value = (raw as Record<string, unknown>)[key];
      if (typeof value === 'number' && Number.isFinite(value)) {
        out[key] = Math.max(0, Math.min(100, Math.round(value)));
      }
    }
  }
  return out;
}

function normalizeStringList(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .filter((item): item is string => typeof item === 'string')
    .map((item) => item.trim())
    .filter((item) => item.length > 0)
    .slice(0, 10);
}

/** Extrae el JSON aunque el modelo lo envuelva en markdown. */
function parseJsonLoose(content: string): Record<string, unknown> | null {
  const text = content.trim();
  if (!text) return null;
  try {
    const direct = JSON.parse(text);
    if (direct && typeof direct === 'object') return direct as Record<string, unknown>;
  } catch {
    // sigue con la extracción por llaves
  }
  const start = text.indexOf('{');
  const end = text.lastIndexOf('}');
  if (start === -1 || end <= start) return null;
  try {
    const candidate = JSON.parse(text.slice(start, end + 1));
    if (candidate && typeof candidate === 'object') return candidate as Record<string, unknown>;
  } catch {
    return null;
  }
  return null;
}

/** Respaldo determinista si el modelo no devuelve un JSON válido. */
function heuristicCefr(answers: string[]): string {
  if (answers.length === 0) return 'A1';
  const words = answers.reduce(
    (sum, answer) => sum + answer.trim().split(/\s+/).filter(Boolean).length,
    0,
  );
  const avg = words / answers.length;
  if (avg >= 32) return 'C1';
  if (avg >= 20) return 'B2';
  if (avg >= 12) return 'B1';
  if (avg >= 6) return 'A2';
  return 'A1';
}

function sanitizeAnswers(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  const out: string[] = [];
  let total = 0;
  for (const item of raw) {
    if (typeof item !== 'string') continue;
    const text = item.trim().slice(0, MAX_ANSWER_CHARS);
    if (!text) continue;
    if (total + text.length > MAX_TOTAL_CHARS) break;
    total += text.length;
    out.push(text);
    if (out.length >= MAX_ANSWERS) break;
  }
  return out;
}

function buildTranscript(answers: string[]): string {
  if (answers.length === 0) return 'The student did not provide any spoken responses.';
  const numbered = answers
    .map((answer, index) => `Response ${index + 1}: "${answer}"`)
    .join('\n');
  return `Student conversation transcripts:\n${numbered}`;
}

function countWords(answers: string[]): number {
  return answers.reduce(
    (sum, answer) => sum + answer.trim().split(/\s+/).filter(Boolean).length,
    0,
  );
}

type Rubric = {
  complete: boolean;
  average: number;
  passed: boolean;
  lowest_dimension: string;
  threshold_average: number;
  threshold_min_dimension: number;
};

/** Rúbrica fija del jefe: media y suelo por dimensión, calculados aquí. */
function computeRubric(scores: Record<string, number>): Rubric {
  const values = RUBRIC_DIMENSIONS
    .map((dimension) => scores[dimension])
    .filter((value): value is number => typeof value === 'number');
  const average = values.length > 0
    ? Math.round(values.reduce((sum, value) => sum + value, 0) / values.length)
    : 0;
  const lowest = [...RUBRIC_DIMENSIONS].sort(
    (a, b) => (scores[a] ?? 0) - (scores[b] ?? 0),
  )[0] ?? '';
  const complete = values.length === RUBRIC_DIMENSIONS.length;
  return {
    complete,
    average,
    passed:
      complete &&
      average >= RUBRIC_PASS_AVERAGE &&
      values.every((value) => value >= RUBRIC_MIN_DIMENSION),
    lowest_dimension: lowest,
    threshold_average: RUBRIC_PASS_AVERAGE,
    threshold_min_dimension: RUBRIC_MIN_DIMENSION,
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const auth = req.headers.get('Authorization') ?? '';
  const jwt = auth.replace(/^Bearer\s+/i, '');
  if (!jwt) return json({ error: 'unauthorized' }, 401);

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  const user = userData?.user;
  if (userErr || !user) return json({ error: 'unauthorized' }, 401);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'invalid_body' }, 400);
  }

  const answers = sanitizeAnswers(body.answers);
  if (answers.length === 0) return json({ error: 'no_answers' }, 400);

  const languageId = Number.isFinite(Number(body.language_id)) && Number(body.language_id) > 0
    ? Number(body.language_id)
    : 1;
  const declaredCefr = normalizeCefr(body.declared_cefr);
  const declaredRank = normalizeRank(body.declared_rank);
  // `mode` solo etiqueta el intento: el nivel y la decisión siguen siendo del
  // servidor. Las reglas de jefe (evidencia, rúbrica, cooldown) se aplican por
  // el estado del servidor (nivel ya evaluado), no por lo que diga el cliente.
  const mode: 'placement' | 'boss' = body.mode === 'boss' ? 'boss' : 'placement';
  const forced = body.forced === true;

  // ── Estado actual: modo promoción (nunca baja) ────────────────────────────
  let previousCefr = '';
  let previousRank = '';
  let previousAssessed = false;
  try {
    const { data: profile } = await admin
      .from('user_language_profiles')
      .select('cefr_level_id, game_rank, placement_assessed_at')
      .eq('user_id', user.id)
      .eq('language_id', languageId)
      .maybeSingle();

    if (profile?.cefr_level_id != null) {
      const { data: level } = await admin
        .from('cefr_levels')
        .select('code')
        .eq('id', profile.cefr_level_id)
        .maybeSingle();
      previousCefr = normalizeCefr(level?.code);
      previousRank = normalizeRank(profile.game_rank);
      // Un perfil recién creado tiene un CEFR por defecto sin evaluar: eso es
      // placement inicial, no promoción.
      previousAssessed = profile.placement_assessed_at != null;
    }
  } catch (e) {
    console.error('profile lookup failed:', e);
  }

  const bossRules = Boolean(previousCefr && previousAssessed);

  // P-31 (#116): evidencia mínima. Un timeout del cliente puede cerrar el
  // examen con pocas respuestas; en ese caso el intento no cuenta.
  const words = countWords(answers);
  if (bossRules && (answers.length < MIN_BOSS_ANSWERS || words < MIN_BOSS_WORDS)) {
    return json({
      error: 'insufficient_evidence',
      min_answers: MIN_BOSS_ANSWERS,
      min_words: MIN_BOSS_WORDS,
      answers: answers.length,
      words,
    }, 400);
  }

  // Cooldown ANTES de llamar al modelo: no se cobra maná por un intento
  // bloqueado por la regla de reintento.
  if (bossRules) {
    try {
      const { data: lastFailure } = await admin
        .from('boss_exam_attempts')
        .select('created_at')
        .eq('user_id', user.id)
        .eq('language_id', languageId)
        .eq('decision', 'maintained')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (lastFailure?.created_at) {
        const nextAttempt = new Date(
          new Date(lastFailure.created_at).getTime() + BOSS_COOLDOWN_HOURS * 3600 * 1000,
        );
        if (nextAttempt.getTime() > Date.now()) {
          return json({
            error: 'cooldown',
            cooldown_hours: BOSS_COOLDOWN_HOURS,
            next_attempt_at: nextAttempt.toISOString(),
          }, 429);
        }
      }
    } catch (e) {
      console.error('boss cooldown lookup failed:', e);
    }
  }

  // ── Evaluación del modelo (cobra maná en el proxy) ────────────────────────
  let evaluation: Record<string, unknown> | null = null;
  let source: 'ai' | 'heuristic' = 'ai';

  try {
    const proxy = await fetch(`${supabaseUrl}/functions/v1/llm-proxy/chat`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${jwt}`,
        'apikey': anonKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'deepseek-v4-flash',
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: buildTranscript(answers) },
        ],
        stream: false,
        temperature: 0.3,
        max_tokens: 1000,
        action_code: 'oracle_eval',
        client_capabilities: ['server_mana'],
      }),
    });

    if (proxy.status === 402) {
      const detail = await proxy.json().catch(() => ({}));
      return json({ error: 'no_mana', ...detail }, 402);
    }
    if (!proxy.ok) {
      const detail = await proxy.text().catch(() => '');
      console.error('llm-proxy error', proxy.status, detail.slice(0, 300));
      return json({ error: 'evaluation_unavailable', status: proxy.status }, 502);
    }

    const payload = await proxy.json();
    const content = payload?.choices?.[0]?.message?.content;
    if (typeof content === 'string') evaluation = parseJsonLoose(content);
  } catch (e) {
    console.error('evaluate-placement fetch error:', e);
    return json({ error: 'evaluation_unavailable' }, 502);
  }

  if (!evaluation) source = 'heuristic';

  const evaluatedCefr = normalizeCefr(evaluation?.cefr_level) || heuristicCefr(answers);
  const evaluatedIdx = CEFR_SCALE.indexOf(evaluatedCefr);

  // La pista declarada en la conversación se acepta solo si está a ±1 banda:
  // el usuario vio ese nivel y conviene no contradecirlo, pero nunca manda.
  let cefr = evaluatedCefr;
  if (declaredCefr) {
    const declaredIdx = CEFR_SCALE.indexOf(declaredCefr);
    if (declaredIdx >= 0 && Math.abs(declaredIdx - evaluatedIdx) <= 1) {
      cefr = declaredCefr;
    }
  }

  let rank = normalizeRank(evaluation?.game_rank);
  if (declaredRank && Math.abs(RANK_SCALE.indexOf(declaredRank) - RANK_SCALE.indexOf(rank)) <= 2) {
    rank = declaredRank;
  }

  const scores = normalizeScores(evaluation?.scores);
  const strengths = normalizeStringList(evaluation?.strengths);
  const weaknesses = normalizeStringList(evaluation?.weaknesses);
  const rubric = computeRubric(scores);

  // ── Decisión del jefe (servidor) ──────────────────────────────────────────
  // En promoción real (nivel ya evaluado) el ascenso exige además la rúbrica
  // aprobada. Si falta cualquier condición, el nivel se mantiene y se explica
  // el motivo; nunca se baja (modo promoción).
  let decision: 'promoted' | 'maintained' | 'initial' = 'initial';
  let reasonCode: string | null = null;

  if (previousCefr) {
    const previousIdx = CEFR_SCALE.indexOf(previousCefr);
    const candidateIdx = CEFR_SCALE.indexOf(cefr);

    if (candidateIdx > previousIdx && (!bossRules || rubric.passed)) {
      decision = 'promoted';
    } else {
      cefr = previousCefr;
      decision = 'maintained';
      reasonCode = candidateIdx > previousIdx
        ? (rubric.complete ? 'rubric_below_threshold' : 'rubric_unavailable')
        : 'no_improvement';
    }
  }

  if (previousCefr && reasonCode === 'rubric_below_threshold' && rubric.lowest_dimension) {
    const weakest = `${rubric.lowest_dimension} ${scores[rubric.lowest_dimension] ?? 0}/${RUBRIC_MIN_DIMENSION}`;
    if (!weaknesses.includes(weakest)) weaknesses.unshift(weakest);
    weaknesses.splice(4);
  }

  if (previousCefr && reasonCode === 'rubric_below_threshold' && rubric.lowest_dimension) {
    const weakest = `${rubric.lowest_dimension} ${scores[rubric.lowest_dimension] ?? 0}/${RUBRIC_MIN_DIMENSION}`;
    if (!weaknesses.includes(weakest)) weaknesses.unshift(weakest);
    weaknesses.splice(4);
  }

  if (!rank) rank = RANK_BY_CEFR[cefr] ?? 'F';
  if (previousCefr === cefr && previousRank) rank = previousRank;

  const explanation = typeof evaluation?.explanation === 'string'
    ? evaluation.explanation.trim().slice(0, 2000)
    : 'Evaluación estimada por longitud de respuesta: el Oráculo no devolvió un JSON válido.';
  const recommendedFocus = typeof evaluation?.recommended_focus === 'string'
    ? evaluation.recommended_focus.trim().slice(0, 200)
    : 'Mantener conversación y ampliar las respuestas';

  // ── Persistencia (service role; el cliente no puede escribir el nivel) ────
  const { error: applyErr } = await admin.rpc('apply_placement_as', {
    p_user_id: user.id,
    p_cefr_code: cefr,
    p_rank: rank,
    p_scores: scores,
    p_strengths: strengths,
    p_weaknesses: weaknesses,
    p_explanation: explanation,
    p_recommended_focus: recommendedFocus,
    p_language_id: languageId,
  });

  if (applyErr) {
    console.error('apply_placement_as rpc error:', applyErr);
    return json({ error: 'db_error', detail: applyErr.message }, 500);
  }

  // P-31 (#116): registrar el intento del jefe con service role. Solo los
  // intentos de promoción (usuario ya evaluado) entran en la tabla: el
  // placement inicial no es un reto del jefe ni debe abrir cooldown.
  // El cliente no puede escribirla, así que el histórico es fiable.
  const nextAttemptAt = bossRules && decision === 'maintained'
    ? new Date(Date.now() + BOSS_COOLDOWN_HOURS * 3600 * 1000).toISOString()
    : null;

  if (bossRules) {
    const { error: attemptErr } = await admin.from('boss_exam_attempts').insert({
      user_id: user.id,
      language_id: languageId,
      from_cefr: previousCefr || null,
      to_cefr: cefr,
      decision,
      reason_code: reasonCode,
      average_score: rubric.average || null,
      scores,
      turns: answers.length,
      forced,
    });

    if (attemptErr) {
      // No bloquea el resultado: el nivel ya está persistido y validado.
      console.error('boss_exam_attempts insert failed:', attemptErr.message);
    }
  }

  return json({
    cefr_level: cefr,
    game_rank: rank,
    scores,
    strengths,
    weaknesses,
    explanation,
    recommended_focus: recommendedFocus,
    previous_cefr_level: previousCefr || null,
    promoted: decision === 'promoted',
    decision,
    reason_code: reasonCode,
    mode,
    forced,
    turns: answers.length,
    rubric: {
      ...rubric,
      dimensions: RUBRIC_DIMENSIONS.reduce<Record<string, number>>((acc, dimension) => {
        const value = scores[dimension];
        if (typeof value === 'number') acc[dimension] = value;
        return acc;
      }, {}),
    },
    next_attempt_at: nextAttemptAt,
    source,
  });
});
