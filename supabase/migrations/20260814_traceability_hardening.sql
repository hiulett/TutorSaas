-- ============================================================================
-- TutorSaas — Trazabilidad + hardening (auditoría web admin)
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-14
--
-- 1) Trazabilidad: columna `updated_by` + trigger en las tablas editadas por el
--    admin, de modo que cada INSERT/UPDATE registre auth.uid() automáticamente.
-- 2) Hardening: `scenarios` deja de ser legible por anon (solo authenticated/admin).
--
-- ⚠️ Aplicar desde el SQL Editor.
-- ============================================================================

BEGIN;

-- Trigger que rellena updated_by (auth.uid()) y updated_at en cada cambio.
CREATE OR REPLACE FUNCTION public.tg_set_updated_by()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    NEW.updated_by := auth.uid();
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'subscription_plans',
        'scenarios',
        'cefr_levels',
        'cosmetic_catalog',
        'system_ai_settings',
        'ai_action_costs',
        'mana_potions',
        'mana_gems',
        'prestige_ladder',
        'user_language_profiles'
    ]
    LOOP
        EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS updated_by uuid', t);
        EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS updated_at timestamptz', t);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_set_updated_by ON public.%I', t);
        EXECUTE format('CREATE TRIGGER trg_set_updated_by BEFORE INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_by()', t);
    END LOOP;
END;
$$;

-- scenarios: quita la lectura anónima (queda authenticated_read + admin_all).
DROP POLICY IF EXISTS scenarios_read ON public.scenarios;

COMMIT;

-- VERIFICACIÓN:
-- SELECT tablename, policyname, cmd, qual FROM pg_policies
--   WHERE schemaname='public' AND tablename='scenarios' ORDER BY cmd;
-- SELECT column_name FROM information_schema.columns
--   WHERE table_schema='public' AND table_name='subscription_plans' AND column_name='updated_by';
