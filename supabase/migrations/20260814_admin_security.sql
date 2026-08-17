-- ============================================================================
-- TutorSaas — Hardening de seguridad del Web Admin (auditoría)
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-14
--
-- 1) CIERRA la fuga de PII: la tabla `users` tenía `SELECT USING (true)` →
--    cualquiera (anon o cualquier usuario de la app) podía leer email, bio,
--    país y avatar de TODOS. Ahora solo el propio usuario o el rol admin.
-- 2) `subscription_plans`: elimina la lectura anónima (solo authenticated/admin).
--
-- ⚠️ Aplicar desde el SQL Editor.
-- ============================================================================

BEGIN;

-- 1) users: lectura solo self o admin.
DROP POLICY IF EXISTS users_read ON public.users;
CREATE POLICY users_read_self_or_admin ON public.users FOR SELECT
    USING (
        auth.uid() = id
        OR ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
    );

-- 2) subscription_plans: sin lectura anónima (el paywall es authenticated).
DROP POLICY IF EXISTS "Anyone can read subscription_plans" ON public.subscription_plans;
DROP POLICY IF EXISTS plans_read ON public.subscription_plans;

COMMIT;

-- VERIFICACIÓN:
-- SELECT tablename, policyname, cmd, qual FROM pg_policies
--   WHERE tablename IN ('users','subscription_plans') ORDER BY tablename, cmd;
