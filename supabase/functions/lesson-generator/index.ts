// lesson-generator — Genera una lección de refuerzo (sub misión) por skill.
//
// Flujo (issue #127 / P-42):
//   1. El cliente autentica con su JWT (Bearer).
//   2. Se valida la evidencia: el usuario debe tener errores recurrentes
//      (`user_recurring_errors`, P-29) o haber fallado algún objetivo. Sin
//      evidencia NO se genera una lección vacía ni se cobra (422 no_evidence).
//   3. Se valida el nivel CEFR contra la escala real y el skill contra los
//      `skill_focus` aceptados (con alias de los ejes del radar).
//   4. Si ya existe una lección equivalente (biblioteca aprobada o borrador
//      propio del mismo padre) se reutiliza sin coste.
//   5. Se DEBITA el coste de `ai_action_costs.lesson_generation` de forma
//      atómica (RPC `consume_mana`) ANTES de generar, con tope de coste.
//   6. DeepSeek genera el escenario; se inserta como borrador privado
//      (`review_status='draft'`, `created_by_user_id`) → solo lo ve su creador
//      hasta que pase revisión.
//   7. Cualquier fallo posterior al cobro devuelve el maná (`refund_mana`).
//
// Endpoints:
//   POST /  { skill_focus, level, weakness?, parent_id?, failed_goals?[] }
//   GET  /  health check
//
// Secretos: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY,
//           DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL
import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const supabase = createClient(supabaseUrl, supabaseAnonKey);
const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });

const deepseekApiKey = Deno.env.get('DEEPSEEK_API_KEY') ?? '';
const deepseekBaseUrl = Deno.env.get('DEEPSEEK_BASE_URL') ?? 'https://api.deepseek.com/v1';

// Escala CEFR propia de la app (cefr_rank.dart). Fuera de esta lista, 400.
const CEFR_LEVELS = ['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

// `scenarios.skill_focus` acepta solo estos cinco valores.
const SKILL_FOCUS = ['fluency', 'vocab', 'phonetics', 'grammar', 'goals'];

// Alias de los ejes del radar (`skills_radar_chart.dart`) que NO son
// skill_focus. Antes llegaban tal cual y el generador respondía 400 (H-42).
const SKILL_ALIASES: Record<string, string> = {
  'comprehension': 'goals',
  'naturalness': 'fluency',
  'vocabulary': 'vocab',
  'pronunciation': 'phonetics',
};

// Tope de coste: si la tabla de precios se dispara, no se cobra una lección.
const MAX_LESSON_COST_MANA = 300;

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

const unauthorized = () => json({ error: 'Unauthorized' }, 401);

function readJwt(req: Request): string {
  const auth = req.headers.get('authorization') ?? '';
  const bearer = auth.startsWith('Bearer ') ? auth.slice(7) : auth;
  if (!bearer || bearer === supabaseAnonKey) return '';
  return bearer;
}

async function requireUser(req: Request): Promise<string | null> {
  try {
    const token = readJwt(req);
    if (!token) return null;
    const { data, error } = await supabase.auth.getUser(token);
    return !error && data.user ? data.user.id : null;
  } catch {
    return null;
  }
}

/** Normaliza el skill recibido; devuelve '' si no es mapeable. */
function normalizeSkillFocus(raw: string): string {
  const value = raw.trim().toLowerCase();
  if (SKILL_FOCUS.includes(value)) return value;
  return SKILL_ALIASES[value] ?? '';
}

function cleanText(value: unknown, maxLength: number): string {
  return String(value ?? '')
    .replace(/[\r\n]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, maxLength);
}

/** Errores recurrentes reales del alumno (vista P-29), de más a menos repetido. */
async function fetchRecurringErrors(userId: string): Promise<string[]> {
  try {
    const { data, error } = await admin
      .from('user_recurring_errors')
      .select('error_type, last_original, last_corrected, occurrences')
      .eq('user_id', userId)
      .gte('occurrences', 2)
      .order('occurrences', { ascending: false })
      .limit(3);
    if (error || !data) return [];
    return (data as Record<string, unknown>[]).map((row) => {
      const type = cleanText(row['error_type'], 40);
      const original = cleanText(row['last_original'], 80);
      const corrected = cleanText(row['last_corrected'], 80);
      const times = Number(row['occurrences'] ?? 0);
      return `${type}: "${original}" → "${corrected}" (${times}x)`;
    });
  } catch (e) {
    console.error('recurring errors query failed:', String(e));
    return [];
  }
}

/** Coste vigente de `ai_action_costs`; null si no es usable (o supera el tope). */
async function lessonGenerationCost(): Promise<number | null> {
  try {
    const { data, error } = await admin
      .from('ai_action_costs')
      .select('cost_mana, is_active')
      .eq('action_code', 'lesson_generation')
      .maybeSingle();
    if (error || !data || data['is_active'] !== true) return null;
    const cost = Number(data['cost_mana'] ?? 0);
    if (!Number.isFinite(cost) || cost <= 0 || cost > MAX_LESSON_COST_MANA) return null;
    return cost;
  } catch (e) {
    console.error('ai_action_costs query failed:', String(e));
    return null;
  }
}

/**
 * Lección equivalente ya existente:
 *  - biblioteca aprobada con el mismo skill + nivel (se comparte), o
 *  - borrador propio para el mismo padre + skill + nivel (no se duplica).
 */
async function findExisting(
  userId: string,
  skillFocus: string,
  level: string,
  parentId?: string,
): Promise<Record<string, unknown> | null> {
  try {
    let library = admin
      .from('scenarios')
      .select('*')
      .eq('skill_focus', skillFocus)
      .eq('difficulty_level', level)
      .eq('is_active', true)
      .eq('review_status', 'approved')
      .is('parent_id', null)
      .order('created_at', { ascending: true })
      .limit(1);
    if (parentId) library = library.eq('parent_id', parentId);
    const libraryRes = await library.maybeSingle();
    if (!libraryRes.error && libraryRes.data) return libraryRes.data;

    let own = admin
      .from('scenarios')
      .select('*')
      .eq('created_by_user_id', userId)
      .eq('skill_focus', skillFocus)
      .eq('difficulty_level', level)
      .eq('is_active', true)
      .order('created_at', { ascending: false })
      .limit(1);
    own = parentId ? own.eq('parent_id', parentId) : own.is('parent_id', null);
    const ownRes = await own.maybeSingle();
    if (!ownRes.error && ownRes.data) return ownRes.data;
    return null;
  } catch (e) {
    console.error('findExisting failed:', String(e));
    return null;
  }
}

// Diagnóstico del último fallo del proveedor (no se expone al cliente).
let lastUpstream = '';

/** Pide a DeepSeek un escenario orientado al skill (JSON). */
async function generateScenario(
  skillFocus: string,
  level: string,
  weakness: string,
): Promise<Record<string, unknown> | null> {
  if (!deepseekApiKey) return null;
  const prompt = `You are a language curriculum designer for a conversational English app (CEFR ${level}).

Generate ONE conversation scenario that specifically trains the skill "${skillFocus}" to fix the student's weakness: "${weakness}".

Return STRICT JSON (no markdown, no extra text) with EXACTLY these keys:
{
  "title": "Short scenario title",
  "description": "One-sentence description",
  "context": "Brief setup context",
  "category": "one of: daily, travel, work, social, academic",
  "estimated_minutes": 10,
  "main_objective": "What the student achieves by the end",
  "assistant_role": "Role of the AI tutor (e.g., Coffee Shop Barista)",
  "user_role": "Role of the student (e.g., Customer)",
  "initial_assistant_message": "The tutor's opening line (level-appropriate, natural)",
  "goals": [
    {"text": "Achievable goal targeting ${skillFocus}", "keywords": ["word1", "word2"], "examplePhrase": "Example phrase"}
  ],
  "useful_phrases": [
    {"phrase": "Useful phrase", "translation": "Spanish translation"}
  ]
}

Rules:
- Level-appropriate vocabulary and grammar for CEFR ${level}.
- 4 goals and 4 useful_phrases minimum.
- The scenario must force practice of "${skillFocus}" naturally.
- Keep it plain, natural, real-world English.
`;
  try {
    // Presupuestos de salida: el modelo de este gateway razona antes de
    // responder. Con 600/900 el `content` llegaba vacío (finish_reason=length)
    // y el refuerzo no se generaba nunca; se reintenta una vez con más aire.
    for (const budget of [3000, 4000]) {
      const resp = await fetch(`${deepseekBaseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${deepseekApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'deepseek-v4-flash',
          messages: [{ role: 'user', content: prompt }],
          stream: false,
          max_tokens: budget,
          temperature: 0.7,
        }),
      });
      if (!resp.ok) {
        lastUpstream = `${resp.status} ${(await resp.text()).slice(0, 300)}`;
        return null;
      }
      const data = await resp.json();
      const content = data?.choices?.[0]?.message?.content ?? '';
      const finish = data?.choices?.[0]?.finish_reason ?? '';
      const start = content.indexOf('{');
      const end = content.lastIndexOf('}');
      if (start < 0 || end < start) {
        lastUpstream = `no-json(${finish}, ${budget}): ${String(content).slice(0, 200)}`;
        // Truncado por presupuesto: merece un segundo intento más amplio.
        if (finish === 'length') continue;
        return null;
      }
      try {
        return JSON.parse(content.slice(start, end + 1));
      } catch {
        lastUpstream = `parse-error: ${content.slice(start, Math.min(end + 1, start + 200))}`;
        return null;
      }
    }
    return null;
  } catch (e) {
    console.error('DeepSeek request failed:', String(e));
    lastUpstream = `exception: ${String(e)}`;
    return null;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method === 'GET') {
    return json({ ok: true, hasDeepSeek: !!deepseekApiKey, ts: new Date().toISOString() });
  }
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const userId = await requireUser(req);
  if (!userId) return unauthorized();

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Invalid JSON' }, 400);
  }

  const skillFocus = normalizeSkillFocus(String(body['skill_focus'] ?? ''));
  const level = String(body['level'] ?? '').trim().toUpperCase();
  const parentId = body['parent_id'] ? String(body['parent_id']).slice(0, 64) : undefined;
  const failedGoals = Array.isArray(body['failed_goals'])
    ? (body['failed_goals'] as unknown[])
      .map((g) => cleanText(g, 120))
      .filter((g) => g.length > 0)
      .slice(0, 2)
    : [];

  if (!skillFocus) {
    return json({ error: 'skill_focus inválido', accepted: SKILL_FOCUS }, 400);
  }
  if (!CEFR_LEVELS.includes(level)) {
    return json({ error: 'level inválido', accepted: CEFR_LEVELS }, 400);
  }

  // ── Evidencia: errores reales + objetivo fallado ────────────────────────
  // Sin evidencia no hay refuerzo: una lección genérica sería contenido vacío
  // (y se cobraría igual). Se responde 422 y no se toca el maná.
  const recurring = await fetchRecurringErrors(userId);
  const weaknessParts = [...recurring, ...failedGoals.map((g) => `objective not met: ${g}`)];
  if (weaknessParts.length === 0) {
    return json({ error: 'no_evidence' }, 422);
  }
  const weakness = cleanText(weaknessParts.join('; '), 400);

  // Issue #15 / H-42: se busca la lección ANTES de cobrar. Reutilizar no cuesta.
  const existing = await findExisting(userId, skillFocus, level, parentId);
  if (existing) {
    return json({ success: true, reused: true, scenario: existing, cost: 0 });
  }

  const actionCost = await lessonGenerationCost();
  if (actionCost === null) {
    console.error('lesson_generation cost unavailable or above cap');
    return json({ error: 'cost_unavailable', cap: MAX_LESSON_COST_MANA }, 500);
  }

  try {
    // ── 1. Debitar de forma atómica (RPC con bloqueo de fila) ───────────────
    const { data: charge, error: chargeErr } = await admin.rpc('consume_mana', {
      p_user_id: userId,
      p_action_code: 'lesson_generation',
    });
    if (chargeErr) {
      console.error('consume_mana failed:', chargeErr.message);
      return json({ error: 'mana_error' }, 500);
    }
    if (!charge || charge['success'] !== true) {
      return json({ error: 'insufficient_mana', detail: charge }, 402);
    }
    const cost = Number(charge['cost'] ?? actionCost);

    // ── 2. Generar con DeepSeek ─────────────────────────────────────────────
    const generated = await generateScenario(skillFocus, level, weakness);
    if (!generated) {
      // El detalle del proveedor queda en la plataforma, nunca en la respuesta.
      console.error('lesson-generator upstream failure:', lastUpstream);
      await admin.rpc('refund_mana', {
        p_user_id: userId,
        p_action_code: 'lesson_generation',
      });
      return json({ error: 'generation_failed', cost, refunded: true }, 502);
    }

    // Una lección sin metas no es jugable: se reembolsa y se informa.
    const rawGoals = Array.isArray(generated['goals']) ? generated['goals'] : [];
    const rawPhrases = Array.isArray(generated['useful_phrases'])
      ? generated['useful_phrases']
      : [];
    if (rawGoals.length < 2) {
      await admin.rpc('refund_mana', {
        p_user_id: userId,
        p_action_code: 'lesson_generation',
      });
      return json({ error: 'empty_lesson', cost, refunded: true }, 502);
    }

    const title = cleanText(generated['title'] ?? `Refuerzo de ${skillFocus}`, 120);
    const inserted = {
      language_id: 1, // EN
      title,
      description: cleanText(generated['description'] ?? '', 400),
      context: cleanText(generated['context'] ?? title, 600),
      difficulty_level: level,
      category: cleanText(generated['category'] ?? 'daily', 40) || 'daily',
      estimated_minutes: Number(generated['estimated_minutes'] ?? 10),
      main_objective: cleanText(generated['main_objective'] ?? '', 400),
      assistant_role: cleanText(generated['assistant_role'] ?? 'Tutor de Inglés', 80),
      user_role: cleanText(generated['user_role'] ?? 'Estudiante', 80),
      initial_assistant_message: cleanText(
        generated['initial_assistant_message'] ?? "Hello! Let's practice.",
        400,
      ),
      goals: rawGoals,
      useful_phrases: rawPhrases,
      skill_focus: skillFocus,
      parent_id: parentId ?? null,
      is_custom: true,
      is_active: true,
      // Issue #81 / #127: el contenido generado por IA nace como borrador y
      // solo lo ve su creador hasta que pase revisión (RLS sobre scenarios).
      review_status: 'draft',
      created_by_user_id: userId,
    };

    const { data: insertedRow, error: insertErr } = await admin
      .from('scenarios')
      .insert(inserted)
      .select('*')
      .single();
    if (insertErr || !insertedRow) {
      await admin.rpc('refund_mana', {
        p_user_id: userId,
        p_action_code: 'lesson_generation',
      });
      console.error('scenario insert failed:', insertErr?.message ?? 'no row');
      return json(
        { error: 'insert_failed', detail: String(insertErr?.message ?? ''), cost, refunded: true },
        500,
      );
    }

    return json({ success: true, reused: false, scenario: insertedRow, cost });
  } catch (e) {
    console.error('lesson-generator error:', e);
    // Un fallo inesperado tras cobrar no puede quedarse con el maná.
    try {
      await admin.rpc('refund_mana', {
        p_user_id: userId,
        p_action_code: 'lesson_generation',
      });
    } catch (_) { /* best-effort */ }
    return json({ error: 'unexpected_error', refunded: true }, 500);
  }
});
