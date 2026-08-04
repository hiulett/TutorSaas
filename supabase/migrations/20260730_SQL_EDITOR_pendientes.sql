-- ============================================================================
-- TutorSaas — MIGRACIONES PENDIENTES PARA SQL EDITOR
-- Proyecto: sipiumfdpvnszthykyog (TutorSaas, producción)
-- Fecha: 2026-07-30
-- Diagnóstico: la DB live rechaza DDL ("read-only transaction") vía cliente;
-- aplicar este script manualmente desde el SQL Editor del dashboard.
--
-- CONTENIDO:
--   PARTE A — Columnas de idioma en user_settings (Fase 2)
--   PARTE B — RPCs de economía: add_xp, add_gems, spend_gems, increment_pergaminos_max (Fase 6)
--   PARTE C — Mission Engine completo (8 tablas + seed + RLS) [contenido en 20260730_mission_engine.sql]
--   PARTE D — Oracle questions (si no aplicada) [contenido en 20260730_oracle_questions.sql]
--
-- INSTRUCCIONES:
-- 1. Abrir https://supabase.com/dashboard/project/sipiumfdpvnszthykyog/sql
-- 2. Pegar TODO este archivo y ejecutar en orden.
-- 3. Verificar que no haya errores.
-- ============================================================================

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ PARTE A — FASE 2: Columnas de idioma en user_settings                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
ALTER TABLE public.user_settings
    ADD COLUMN IF NOT EXISTS ui_language VARCHAR(10) DEFAULT 'es',
    ADD COLUMN IF NOT EXISTS learning_language VARCHAR(10) DEFAULT 'en',
    ADD COLUMN IF NOT EXISTS ai_explanations_native BOOLEAN DEFAULT TRUE;

COMMENT ON COLUMN public.user_settings.ui_language IS 'Idioma de la interfaz (UI) de la app.';
COMMENT ON COLUMN public.user_settings.learning_language IS 'Idioma que se está aprendiendo (target).';
COMMENT ON COLUMN public.user_settings.ai_explanations_native IS 'Si las explicaciones de gramática de la IA se dan en el idioma nativo.';

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ PARTE B — FASE 6: RPCs de economía                                        ║
-- ║ Usados por economy_repository_impl.dart y mission_repository.dart         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- add_xp: suma XP al perfil de idioma activo del usuario.
CREATE OR REPLACE FUNCTION public.add_xp(p_user_id UUID, p_amount INTEGER)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_language_profiles
    SET xp_points = COALESCE(xp_points, 0) + p_amount
    WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        INSERT INTO public.user_language_profiles (user_id, xp_points)
        VALUES (p_user_id, p_amount);
    END IF;
END;
$$;

-- add_gems: suma gemas al saldo del usuario.
CREATE OR REPLACE FUNCTION public.add_gems(p_user_id UUID, p_amount INTEGER)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_language_profiles
    SET total_gems = COALESCE(total_gems, 0) + p_amount
    WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        INSERT INTO public.user_language_profiles (user_id, total_gems)
        VALUES (p_user_id, p_amount);
    END IF;
END;
$$;

-- spend_gems: resta gemas; devuelve TRUE si hubo saldo suficiente.
CREATE OR REPLACE FUNCTION public.spend_gems(p_user_id UUID, p_amount INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_gems INTEGER;
BEGIN
    SELECT COALESCE(total_gems, 0) INTO v_gems
    FROM public.user_language_profiles
    WHERE user_id = p_user_id;

    IF v_gems IS NULL OR v_gems < p_amount THEN
        RETURN FALSE;
    END IF;

    UPDATE public.user_language_profiles
    SET total_gems = v_gems - p_amount
    WHERE user_id = p_user_id;

    RETURN TRUE;
END;
$$;

-- increment_pergaminos_max: aumenta el tope diario de pergaminos.
CREATE OR REPLACE FUNCTION public.increment_pergaminos_max(p_user_id UUID, p_amount INTEGER)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.player_daily_state
    SET pergaminos_max = COALESCE(pergaminos_max, 5) + p_amount
    WHERE user_id = p_user_id
      AND date = CURRENT_DATE;
END;
$$;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ PARTE C — FASE 5: Mission Engine                                           ║
-- ║ Contenido íntegro en: supabase/migrations/20260730_mission_engine.sql      ║
-- ║ (8 tablas + seed 29 plantillas + índices + RLS + Realtime)                 ║
-- ║ ▶ Pegar a continuación el contenido COMPLETO de ese archivo.               ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ PARTE D — FASE 2: Oracle questions                                          ║
-- ║ Contenido íntegro en: supabase/migrations/20260730_oracle_questions.sql    ║
-- ║ (tabla oracle_questions + 7 preguntas + RLS)                                ║
-- ║ ▶ Verificar si la tabla ya existe en live (sí existe en este proyecto)     ║
-- ║   antes de pegar; si ya existe, omitir esta parte.                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- ═══ FIN DEL SCRIPT — Verificar con: ═══════════════════════════════════════════
-- SELECT proname FROM pg_proc JOIN pg_namespace n ON n.oid=pronamespace
--   WHERE n.nspname='public' AND proname IN ('add_xp','add_gems','spend_gems','increment_pergaminos_max');
-- SELECT column_name FROM information_schema.columns WHERE table_schema='public'
--   AND table_name='user_settings' AND column_name IN ('ui_language','learning_language','ai_explanations_native');
-- SELECT tablename FROM pg_tables WHERE schemaname='public'
--   AND tablename IN ('mission_templates','mission_instances','secret_missions','emergency_missions','global_events','player_event_progress','guild_collaborative_missions','reward_history');
