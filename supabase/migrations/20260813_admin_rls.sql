-- ============================================================================
-- TutorSaas — FASE P0: RLS de administración (rol admin)
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-13
--
-- Cierra el acceso de escritura del panel web: SOLO los usuarios cuyo
-- `app_metadata.role = 'admin'` pueden INSERT/UPDATE/DELETE en las tablas
-- gestionadas desde el admin. El resto (authenticated) conserva SELECT.
--
-- ⚠️ REQUISITO: asignar el rol al admin en Supabase Dashboard
--   Authentication → Users → tu usuario → App Metadata:
--     { "role": "admin" }
--
-- ⚠️ Aplicar desde el SQL Editor (la DB live es de solo lectura vía API).
-- ============================================================================

BEGIN;

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'ai_action_costs',
        'mana_potions',
        'mana_gems',
        'prestige_ladder',
        'cosmetic_catalog',
        'subscription_plans',
        'system_ai_settings',
        'scenarios',
        'cefr_levels'
    ]
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);

        -- Escritura: SOLO role=admin.
        EXECUTE format('DROP POLICY IF EXISTS admin_all ON public.%I', t);
        EXECUTE format($p$CREATE POLICY admin_all ON public.%I FOR ALL
            USING ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
            WITH CHECK ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')$p$, t);

        -- Lectura para usuarios autenticados (la app y el admin la necesitan).
        EXECUTE format('DROP POLICY IF EXISTS authenticated_read ON public.%I', t);
        EXECUTE format($p$CREATE POLICY authenticated_read ON public.%I FOR SELECT
            USING (auth.role() = 'authenticated')$p$, t);
    END LOOP;
END;
$$;

COMMIT;

-- VERIFICACIÓN:
-- SELECT schemaname, tablename, policyname, cmd
--   FROM pg_policies WHERE tablename IN
--   ('ai_action_costs','mana_potions','mana_gems','prestige_ladder',
--    'cosmetic_catalog','subscription_plans','system_ai_settings','scenarios','cefr_levels')
--   ORDER BY tablename, cmd;
-- SELECT id, email, raw_app_meta_data->>'role' AS role FROM auth.users;
