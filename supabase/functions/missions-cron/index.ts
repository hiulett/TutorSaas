import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, serviceRole);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const url = new URL(req.url);
  // `?dry=1` valida la autenticación sin rotar misiones (usado por los tests).
  const dry = url.searchParams.get('dry') === '1';

  // Issue #13: el secreto vive en Vault y se valida en la base, no en una
  // variable de entorno. Así el job de pg_cron puede leerlo sin exponerlo.
  const auth = req.headers.get('authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7).trim() : '';
  if (!token) return json({ error: 'Unauthorized' }, 401);

  const { data: valid, error: authError } = await supabase.rpc(
    'verify_cron_secret',
    { p_token: token },
  );
  if (authError) return json({ error: authError.message }, 500);
  if (valid !== true) return json({ error: 'Unauthorized' }, 401);

  if (dry) return json({ ok: true, dry: true });

  try {
    const { data, error } = await supabase.rpc('rotate_daily_missions');
    if (error) throw error;
    return json({ ok: true, created: data ?? 0 });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
