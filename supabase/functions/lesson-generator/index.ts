// lesson-generator — Genera una lección de refuerzo (sub misión) por skill.
//
// Flujo:
//   1. El cliente autentica con su JWT (Bearer).
//   2. Se valida que el usuario tiene saldo y se DEBITA 100 maná
//      (lesson_generation) ANTES de generar.
//   3. Se busca en `scenarios` una lección existente con el mismo
//      `skill_focus` + `difficulty_level` → si existe, se reutiliza (sin costo
//      de generación, pero sí se debita maná por ser una lección de refuerzo).
//   4. Si no existe, DeepSeek genera el escenario → se inserta con
//      `is_custom=true`, `skill_focus` y `parent_id` (sub misión).
//   5. Retorna el escenario (la app lo lanza como lección).
//
// Endpoints:
//   POST /            { skill_focus, level, weakness?, parent_id? }
//   GET  /            health check
//
// Secretos: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY,
//           DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL
import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

// Cliente con anon key (para validar JWT) y con service_role (para insertar).
const supabase = createClient(supabaseUrl, supabaseAnonKey);
const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });

const deepseekApiKey = Deno.env.get('DEEPSEEK_API_KEY') ?? '';
const deepseekBaseUrl = Deno.env.get('DEEPSEEK_BASE_URL') ?? 'https://api.deepseek.com/v1';

const GENERATION_COST = 100; // maná por generar/refuerzo (ai_action_costs.lesson_generation)

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

/** Busca una lección existente con el mismo skill + nivel (biblioteca reutilizable). */
async function findExisting(
  skillFocus: string,
  level: string,
  parentId?: string,
): Promise<Record<string, unknown> | null> {
  let query = admin
    .from('scenarios')
    .select('*')
    .eq('skill_focus', skillFocus)
    .eq('difficulty_level', level)
    .eq('is_active', true)
    .order('created_at', { ascending: true })
    .limit(1);
  if (parentId) query = query.eq('parent_id', parentId);
  const { data, error } = await query.maybeSingle();
  if (error || !data) return null;
  return data;
}

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
        max_tokens: 900,
        temperature: 0.7,
      }),
    });
    if (!resp.ok) return null;
    const data = await resp.json();
    const content = data?.choices?.[0]?.message?.content ?? '';
    const start = content.indexOf('{');
    const end = content.lastIndexOf('}');
    if (start < 0 || end < start) return null;
    try {
      return JSON.parse(content.slice(start, end + 1));
    } catch {
      return null;
    }
  } catch {
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

  const skillFocus = String(body['skill_focus'] ?? '');
  const level = String(body['level'] ?? '').toUpperCase();
  const weakness = String(body['weakness'] ?? skillFocus)
    .replace(/[\r\n]+/g, ' ')
    .slice(0, 200);
  const parentId = body['parent_id'] ? String(body['parent_id']) : undefined;

  if (!['fluency', 'vocab', 'phonetics', 'grammar', 'goals'].includes(skillFocus)) {
    return json({ error: 'skill_focus inválido' }, 400);
  }
  if (!level) return json({ error: 'level requerido' }, 400);

  // Issue #15: se busca la lección ANTES de cobrar. Reutilizar no cuesta.
  const existing = await findExisting(skillFocus, level, parentId);
  if (existing) {
    return json({ success: true, reused: true, scenario: existing, cost: 0 });
  }

  try {
    // ── 1. Debitar de forma atómica (RPC con bloqueo de fila) ───────────────
    // Antes se hacía un read-modify-write manual: dos llamadas concurrentes
    // pasaban la comprobación y la última escritura ganaba (generación gratis).
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
    const cost = Number(charge['cost'] ?? GENERATION_COST);

    // ── 3. Generar con DeepSeek ─────────────────────────────────────────────
    const generated = await generateScenario(skillFocus, level, weakness);
    if (!generated) {
      // Issue #15: si la generación falla, se devuelve el maná cobrado.
      await admin.rpc('refund_mana', {
        p_user_id: userId,
        p_action_code: 'lesson_generation',
      });
      return json({ error: 'generation_failed', cost, refunded: true }, 500);
    }

    const title = String(generated['title'] ?? `Refuerzo de ${skillFocus}`);
    const inserted = {
      language_id: 1, // EN
      title,
      description: String(generated['description'] ?? ''),
      context: String(generated['context'] ?? title),
      difficulty_level: level,
      category: String(generated['category'] ?? 'daily'),
      estimated_minutes: Number(generated['estimated_minutes'] ?? 10),
      main_objective: String(generated['main_objective'] ?? ''),
      assistant_role: String(generated['assistant_role'] ?? 'Tutor de Inglés'),
      user_role: String(generated['user_role'] ?? 'Estudiante'),
      initial_assistant_message: String(generated['initial_assistant_message'] ?? 'Hello! Let\'s practice.'),
      goals: generated['goals'] ?? [],
      useful_phrases: generated['useful_phrases'] ?? [],
      skill_focus: skillFocus,
      parent_id: parentId ?? null,
      is_custom: true,
      is_active: true,
      // Issue #81: el contenido generado por IA nace como borrador; la
      // biblioteca compartida no debe dar por bueno algo sin revisar.
      review_status: 'draft',
    };

    const { data: insertedRow, error: insertErr } = await admin
      .from('scenarios')
      .insert(inserted)
      .select('*')
      .single();
    if (insertErr || !insertedRow) {
      // Issue #15: sin lección insertada no se cobra.
      await admin.rpc('refund_mana', {
        p_user_id: userId,
        p_action_code: 'lesson_generation',
      });
      return json(
        { error: 'insert_failed', detail: String(insertErr), cost, refunded: true },
        500,
      );
    }

    return json({ success: true, reused: false, scenario: insertedRow, cost });
  } catch (e) {
    console.error('lesson-generator error:', e);
    return json({ error: String(e) }, 500);
  }
});
