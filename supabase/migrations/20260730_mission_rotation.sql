-- ============================================================================
-- TutorSaas — T-404: Rotación diaria de misiones (función SQL)
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Pegar en el SQL Editor y ejecutar. La edge function missions-cron la invoca.
-- ============================================================================

-- Rota las misiones diarias de TODOS los usuarios activos:
--  1. Limpia misiones antiguas (completadas >14 días, expiradas, secretas vencidas).
--  2. Llena slots vacíos con plantillas diarias/semanales según CEFR.
-- Devuelve el número de misiones creadas.
CREATE OR REPLACE FUNCTION public.rotate_daily_missions()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_created INTEGER := 0;
    v_cutoff TIMESTAMPTZ := NOW() - INTERVAL '14 days';
    v_user RECORD;
    v_template RECORD;
    v_slots INTEGER;
    v_active INTEGER;
    v_cefr VARCHAR(5);
BEGIN
    -- Limpieza global
    DELETE FROM mission_instances WHERE status = 'completed' AND completed_at < v_cutoff;
    DELETE FROM mission_instances WHERE status = 'expired';
    DELETE FROM secret_missions WHERE is_completed = TRUE OR expires_at < NOW();
    DELETE FROM reward_history WHERE claimed_at < v_cutoff;

    -- Iterar usuarios con perfil de idioma activo
    FOR v_user IN
        SELECT DISTINCT user_id
        FROM user_language_profiles
    LOOP
        SELECT COALESCE(c.code, 'A1') INTO v_cefr
        FROM user_language_profiles p
        LEFT JOIN cefr_levels c ON c.id = p.cefr_level_id
        WHERE p.user_id = v_user.user_id
        LIMIT 1;

        SELECT COUNT(*) INTO v_active
        FROM mission_instances
        WHERE user_id = v_user.user_id AND status = 'active';

        v_slots := GREATEST(10 - v_active, 0);
        IF v_slots = 0 THEN CONTINUE; END IF;

        -- Asignar plantillas diarias no duplicadas (respetando CEFR)
        FOR v_template IN
            SELECT * FROM mission_templates
            WHERE is_active = TRUE
              AND mission_type IN ('daily', 'weekly')
              AND (min_cefr_level IS NULL OR min_cefr_level <= v_cefr)
              AND id NOT IN (
                  SELECT template_id FROM mission_instances
                  WHERE user_id = v_user.user_id AND template_id IS NOT NULL
              )
            ORDER BY mission_type, created_at
        LOOP
            EXIT WHEN v_slots <= 0;
            INSERT INTO mission_instances (
                user_id, template_id, mission_type, title, description,
                objective_type, target_value, xp_reward, gem_reward, item_reward,
                status, started_at
            ) VALUES (
                v_user.user_id, v_template.id, v_template.mission_type, v_template.title,
                v_template.description, v_template.objective_type, v_template.target_value,
                v_template.xp_reward, v_template.gem_reward, v_template.item_reward,
                'active', NOW()
            )
            ON CONFLICT DO NOTHING;
            v_created := v_created + 1;
            v_slots := v_slots - 1;
        END LOOP;
    END LOOP;

    RETURN v_created;
END;
$$;

-- Invocable por la edge function y por pg_cron si está habilitado:
--   select cron.schedule('rotate-missions', '0 6 * * *', $$select public.rotate_daily_missions();$$);
COMMENT ON FUNCTION public.rotate_daily_missions() IS 'Rotación diaria de misiones para todos los usuarios (T-404).';
