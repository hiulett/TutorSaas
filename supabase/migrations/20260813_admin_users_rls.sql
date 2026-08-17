-- ============================================================================
-- TutorSaas — Admin CRUD sobre usuarios (RLS)
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-13
--
-- Permite que el rol admin (app_metadata.role = 'admin') lea/edite/elimine
-- cualquier perfil de idioma y usuario, además de sus propias filas.
--
-- ⚠️ Aplicar desde el SQL Editor.
-- ============================================================================

BEGIN;

ALTER TABLE public.user_language_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS admin_all ON public.user_language_profiles;
CREATE POLICY admin_all ON public.user_language_profiles FOR ALL
    USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
    WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS admin_all ON public.users;
CREATE POLICY admin_all ON public.users FOR ALL
    USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
    WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

COMMIT;

-- VERIFICACIÓN:
-- SELECT tablename, policyname FROM pg_policies
--   WHERE tablename IN ('user_language_profiles','users') ORDER BY tablename, policyname;
