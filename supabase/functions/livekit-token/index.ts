// livekit-token - Emite tokens de acceso de LiveKit para el gremio (voz).
//
// Autentica el JWT de Supabase del cazador, consulta su estado de presencia
// para emitir canPublish (solo seated publica audio) y aplica un rate limit
// por usuario para evitar abuso/DoS de emisión de tokens.
//
// Secrets requeridos:
//   LIVEKIT_API_KEY     (clave de la instancia LiveKit)
//   LIVEKIT_API_SECRET  (secreto de la instancia LiveKit, fuerte + rotado)
//   LIVEKIT_URL         (wss://livekit.tudominio o wss://IP:7443 con TLS)
//
// Query params:
//   room    -> id de la mesa (por defecto "guild")
//   publish -> fallback SOLO si no hay participación conocida.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { AccessToken } from 'npm:livekit-server-sdk@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const supabase = createClient(supabaseUrl, supabaseServiceKey);

const livekitUrl = Deno.env.get('LIVEKIT_URL') ?? 'wss://93.127.132.53:7443';
const livekitApiKey = Deno.env.get('LIVEKIT_API_KEY') ?? '';
const livekitApiSecret = Deno.env.get('LIVEKIT_API_SECRET') ?? '';

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

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const auth = req.headers.get('Authorization') ?? '';
    const jwt = auth.replace(/^Bearer\s+/i, '');
    if (!jwt) return json({ error: 'no_auth' }, 401);

    const { data: { user }, error } = await supabase.auth.getUser(jwt);
    if (error || !user) return json({ error: 'invalid_token' }, 401);

    // ── Rate limit por usuario (anti-abuso): 20 tokens/min. ──────────────
    try {
      const { data: allowed } = await supabase.rpc('check_token_rate_limit', {
        p_user_id: user.id,
        p_max_requests: 20,
        p_window_seconds: 60,
      });
      if (allowed === false) {
        return json({ error: 'rate_limited' }, 429);
      }
    } catch (_) {
      // Si el RPC aún no existe (migración pendiente), no bloquear.
    }

    const url = new URL(req.url);
    const room = url.searchParams.get('room') ?? 'guild';
    const requestedPublish = (url.searchParams.get('publish') ?? 'true') === 'true';

    let displayName = user.email?.split('@')[0] ?? 'Cazador';
    let avatarUrl = 'warrior';

    // Presencia real en la mesa -> decide canPublish en el servidor.
    let canPublish = requestedPublish;
    try {
      const { data: participant } = await supabase
        .from('chat_room_participants')
        .select('presence_state, speaker_slot')
        .eq('room_id', room)
        .eq('user_id', user.id)
        .maybeSingle();

      if (participant) {
        canPublish = participant.presence_state === 'seated';
      }
    } catch (_) {
      // Sin BD o schema antiguo: se conserva el fallback del cliente.
    }

    try {
      const { data: profile } = await supabase
        .from('users')
        .select('display_name, avatar_url')
        .eq('id', user.id)
        .maybeSingle();
      if (profile) {
        if (profile.display_name) displayName = profile.display_name;
        if (profile.avatar_url) avatarUrl = profile.avatar_url;
      }
    } catch (_) {}

    const at = new AccessToken(livekitApiKey, livekitApiSecret, {
      identity: user.id,
      name: displayName,
      metadata: JSON.stringify({ avatar_url: avatarUrl }),
      ttl: '12h',
    });
    at.addGrant({
      room,
      roomJoin: true,
      canPublish,
      canSubscribe: true,
    });
    const token = await at.toJwt();

    return json({ url: livekitUrl, token, room, canPublish });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
