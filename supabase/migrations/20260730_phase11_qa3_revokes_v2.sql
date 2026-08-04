-- ============================================================================
-- TutorSaas — QA-3 (v2): revocar EXECUTE de funciones internas
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
--
-- CAUSA: los roles anon/authenticated heredan EXECUTE de PUBLIC (default de
-- PostgreSQL). REVOKE ... FROM anon no basta; hay que revocar también de PUBLIC.
--
-- Estrategia:
--  * Funciones SOLO server → revocar a PUBLIC, anon y authenticated.
--  * Funciones que la app usa desde el cliente → revocar a PUBLIC y anon,
--    y volver a GRANTEAR explícitamente a authenticated.
-- Pegar TODO y ejecutar.
-- ============================================================================

-- ═══ 1. Funciones SOLO server (rotación / triggers) ═══
REVOKE EXECUTE ON FUNCTION public.rotate_daily_missions() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.trigger_set_timestamps() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_auth_rate_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.before_message_inserted_rate_limit() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.check_user_rate_limit(uuid, integer, integer) FROM PUBLIC, anon, authenticated;

-- ═══ 2. Funciones que la app SI usa desde el cliente ═══
-- Revocar a PUBLIC y anon; luego regrantear a authenticated explícitamente.
REVOKE EXECUTE ON FUNCTION public.add_xp(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_xp(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.add_gems(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_gems(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.spend_gems(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.spend_gems(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.increment_pergaminos_max(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.increment_pergaminos_max(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.add_fragments(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_fragments(uuid, integer) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.check_ai_audio_quota(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.check_ai_audio_quota(text) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.track_ai_audio_time(text, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.track_ai_audio_time(text, integer) TO authenticated;

-- ═══ Verificación (debe dar: anon=false en todo; auth=true solo en las de la app) ═══
-- SELECT
--   has_function_privilege('anon', 'public.rotate_daily_missions()', 'EXECUTE') AS anon_rotate,
--   has_function_privilege('anon', 'public.add_xp(uuid, integer)', 'EXECUTE') AS anon_addxp,
--   has_function_privilege('public', 'public.add_xp(uuid, integer)', 'EXECUTE') AS public_addxp,
--   has_function_privilege('authenticated', 'public.add_xp(uuid, integer)', 'EXECUTE') AS auth_addxp,
--   has_function_privilege('authenticated', 'public.rotate_daily_missions()', 'EXECUTE') AS auth_rotate;
