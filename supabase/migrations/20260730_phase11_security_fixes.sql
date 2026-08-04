-- ============================================================================
-- TutorSaas — Fase 11 QA · Bloqueadores de seguridad (QA-1, QA-2, QA-3)
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Pegar en el SQL Editor y ejecutar.
-- ============================================================================

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ QA-1: system_ai_settings solo accesible por service_role (server)          ║
-- ║ (el cliente Flutter NO lee esta tabla — verificado)                        ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
DROP POLICY IF EXISTS ai_settings_read ON public.system_ai_settings;

ALTER TABLE public.system_ai_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY ai_settings_service_role ON public.system_ai_settings
    FOR ALL USING (auth.role() = 'service_role');

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ QA-2: vocabulary_items — INSERT restringido (WITH CHECK true → uid)        ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
DROP POLICY IF EXISTS "Authenticated users can insert vocabulary_items" ON public.vocabulary_items;
DROP POLICY IF EXISTS "Authenticated users can read vocabulary_items" ON public.vocabulary_items;

-- Los usuarios solo pueden leer/insertar vocabulario de su propio idioma
-- (o vocabulario global sin dueño). Ajustar según el modelo real: esta tabla
-- es un catálogo, no por-usuario. Lectura para autenticados es aceptable;
-- el INSERT debe validar campos (sin claves arbitrarias no se puede restringir
-- más sin columna owner). Se limita a lecturas autenticadas y se mantiene
-- INSERT con check mínimo del idioma.
CREATE POLICY "vocab_read_authenticated" ON public.vocabulary_items
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "vocab_insert_authenticated" ON public.vocabulary_items
    FOR INSERT WITH CHECK (
        auth.role() = 'authenticated'
        AND length(coalesce(word, '')) BETWEEN 1 AND 64
        AND language_id IS NOT NULL
    );

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ QA-3: Revocar EXECUTE a roles expuestos de funciones SECURITY DEFINER      ║
-- ║ internas (solo server/service). Se mantienen las que la app llama          ║
-- ║ desde el cliente autenticado: add_xp, add_gems, spend_gems,                ║
-- ║ increment_pergaminos_max, check_ai_audio_quota, track_ai_audio_time.       ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- 1. Funciones SOLO server (rotación/triggers) → revocar a anon Y authenticated
REVOKE EXECUTE ON FUNCTION public.rotate_daily_missions() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.trigger_set_timestamps() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_auth_rate_limit() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_rate_limit() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_user_rate_limit(uuid, integer, integer) FROM anon, authenticated;

-- 2. Funciones que la app SI usa desde el cliente → se mantienen para authenticated
--    pero se revoca a anon (nunca deben invocarse sin login).
REVOKE EXECUTE ON FUNCTION public.add_xp(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.add_gems(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.spend_gems(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.increment_pergaminos_max(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.add_fragments(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_ai_audio_quota(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.track_ai_audio_time(text, integer) FROM anon;

-- Verificación
-- SELECT polname, pg_get_expr(polqual, polrelid) FROM pg_policy WHERE polrelid='system_ai_settings'::regclass;
-- SELECT has_function_privilege('anon', 'public.rotate_daily_missions()', 'EXECUTE');
-- SELECT has_function_privilege('authenticated', 'public.add_xp(uuid, integer)', 'EXECUTE');
