-- ============================================================================
-- TutorSaas — QA-3 (standalone): revocar EXECUTE de funciones internas
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Firma verificada contra el esquema live. Pegar y ejecutar completo.
-- ============================================================================

-- 1. Funciones SOLO server (rotación/triggers) → revocar a anon Y authenticated
REVOKE EXECUTE ON FUNCTION public.rotate_daily_missions() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.trigger_set_timestamps() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_auth_rate_limit() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_rate_limit() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_user_rate_limit(uuid, integer, integer) FROM anon, authenticated;

-- 2. Funciones que la app usa desde el cliente → mantener para authenticated, revocar a anon
REVOKE EXECUTE ON FUNCTION public.add_xp(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.add_gems(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.spend_gems(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.increment_pergaminos_max(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.add_fragments(uuid, integer) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_ai_audio_quota(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.track_ai_audio_time(text, integer) FROM anon;

-- Verificación (debe mostrar false para las revocadas)
-- SELECT
--   has_function_privilege('anon', 'public.rotate_daily_missions()', 'EXECUTE') AS anon_rotate,
--   has_function_privilege('anon', 'public.add_xp(uuid, integer)', 'EXECUTE') AS anon_addxp,
--   has_function_privilege('authenticated', 'public.rotate_daily_missions()', 'EXECUTE') AS auth_rotate,
--   has_function_privilege('authenticated', 'public.add_xp(uuid, integer)', 'EXECUTE') AS auth_addxp;
