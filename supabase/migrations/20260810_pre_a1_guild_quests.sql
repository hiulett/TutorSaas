-- ============================================================================
-- TutorSaas — Contenido PRE-A1 (rango F): misiones y pool del gremio
-- Fecha: 2026-08-10
--
-- 1) Plantillas de misión (diarias/semanales) para el nivel PRE-A1.
-- 2) Misiones del pool del gremio con rango F (recomendadas para PRE-A1).
-- 3) Fix del RPC `rotate_daily_missions`: el gating por CEFR usa order_index
--    (la comparación léxica rompe con 'PRE-A1' porque ordena después de las
--    letras y le daría misiones de niveles altos a un usuario PRE-A1).
-- Idempotente.
-- ============================================================================

-- 1. PLANTILLAS DE MISIÓN PRE-A1
-- ============================================================================
INSERT INTO public.mission_templates (mission_type, title, description, objective_type, target_value, xp_reward, gem_reward, min_cefr_level)
SELECT * FROM (VALUES
  ('daily', 'El Primer Saludo', 'Di "hello" y "hi" en una conversación', 'speak_minutes', 1, 20, 2, 'PRE-A1'),
  ('daily', 'Una Palabra Nueva', 'Aprende 1 palabra nueva en una sesión', 'vocab_words', 1, 20, 2, 'PRE-A1'),
  ('daily', 'Mi Nombre en Inglés', 'Completa una sesión y di tu nombre', 'sessions', 1, 20, 2, 'PRE-A1'),
  ('weekly', 'Los Diez Números', 'Practica los números del 1 al 10', 'vocab_words', 10, 80, 10, 'PRE-A1')
) AS v(mission_type, title, description, objective_type, target_value, xp_reward, gem_reward, min_cefr_level)
WHERE NOT EXISTS (SELECT 1 FROM public.mission_templates t WHERE t.title = v.title);

-- 2. POOL DEL GREMIO — RANGO F (recomendadas para PRE-A1)
-- ============================================================================
INSERT INTO public.guild_quest_pool (quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, min_cefr_level, game_rank, category)
SELECT * FROM (VALUES
  ('daily', 'El Primer Saludo', 'Saluda en inglés con "hello" en una sesión', 'speak_minutes', 1, 20, 2, 'PRE-A1', 'F', 'speaking'),
  ('daily', 'Sí o No', 'Responde sí/no en una conversación', 'sessions', 1, 20, 2, 'PRE-A1', 'F', 'speaking'),
  ('daily', 'Palabras de Colores', 'Aprende los colores básicos', 'vocab_words', 3, 25, 3, 'PRE-A1', 'F', 'vocabulary'),
  ('daily', 'Cuenta Hasta Diez', 'Di los números del 1 al 10', 'vocab_words', 5, 25, 3, 'PRE-A1', 'F', 'vocabulary'),
  ('daily', 'El Eco del Nombre', 'Pronuncia y repite tu nombre y el del tutor', 'speak_minutes', 2, 25, 3, 'PRE-A1', 'F', 'speaking'),
  ('weekly', 'Primeras Diez Palabras', 'Aprende 10 palabras nuevas esta semana', 'vocab_words', 10, 100, 12, 'PRE-A1', 'F', 'vocabulary'),
  ('weekly', 'El Fundamento del Gremio', 'Completa 5 sesiones básicas en la semana', 'sessions', 5, 120, 15, 'PRE-A1', 'F', 'speaking')
) AS v(quest_type, title, description, objective_type, target_value, xp_reward, gem_reward, min_cefr_level, game_rank, category)
WHERE NOT EXISTS (SELECT 1 FROM public.guild_quest_pool g WHERE g.title = v.title);

-- 3. FIX RPC rotate_daily_missions (gating CEFR por order_index)
-- ============================================================================
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
    v_cefr_order INTEGER;
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
        SELECT COALESCE(c.code, 'A1'), COALESCE(c.order_index, 1)
        INTO v_cefr, v_cefr_order
        FROM user_language_profiles p
        LEFT JOIN cefr_levels c ON c.id = p.cefr_level_id
        WHERE p.user_id = v_user.user_id
        LIMIT 1;

        SELECT COUNT(*) INTO v_active
        FROM mission_instances
        WHERE user_id = v_user.user_id AND status = 'active';

        v_slots := GREATEST(10 - v_active, 0);
        IF v_slots = 0 THEN CONTINUE; END IF;

        -- Asignar plantillas diarias no duplicadas (respetando CEFR por order_index)
        FOR v_template IN
            SELECT * FROM mission_templates
            WHERE is_active = TRUE
              AND mission_type IN ('daily', 'weekly')
              AND (min_cefr_level IS NULL OR EXISTS (
                  SELECT 1 FROM cefr_levels c
                  WHERE c.code = min_cefr_level AND c.order_index <= v_cefr_order
              ))
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

COMMENT ON FUNCTION public.rotate_daily_missions() IS 'Rotación diaria de misiones para todos los usuarios (T-404), gating CEFR por order_index (soporta PRE-A1).';
