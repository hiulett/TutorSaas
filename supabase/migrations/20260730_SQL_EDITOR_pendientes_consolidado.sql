-- ============================================================================
-- TutorSaas — SCRIPTS PENDIENTES CONSOLIDADOS PARA SQL EDITOR
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Reúne los 4 scripts pendientes de las Fases 2–6 en UN SOLO pegada.
-- Pegar TODO este archivo en el SQL Editor y ejecutar en orden.
-- ============================================================================

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 1) T-104 — País de origen (users.country_code)                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS country_code VARCHAR(10) DEFAULT 'MX';

COMMENT ON COLUMN public.users.country_code IS 'País de origen del usuario (ISO-3166 alpha-2).';

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 2) T-504/T-505 — Fragmentos (columna + RPC add_fragments)                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS fragments INTEGER DEFAULT 0;

COMMENT ON COLUMN public.user_language_profiles.fragments IS 'Fragmentos rúnicos obtenidos como loot en conversaciones.';

CREATE OR REPLACE FUNCTION public.add_fragments(p_user_id UUID, p_amount INTEGER)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_language_profiles
    SET fragments = COALESCE(fragments, 0) + p_amount
    WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        INSERT INTO public.user_language_profiles (user_id, fragments)
        VALUES (p_user_id, p_amount);
    END IF;
END;
$$;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3) T-507 — Balance económico (ajuste de catálogo)                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
UPDATE public.cosmetic_catalog SET price_gems = 40   WHERE id = 'consumible_invocacion5' AND price_gems > 40;
UPDATE public.cosmetic_catalog SET price_gems = 150  WHERE id = 'consumible_invocacion20' AND price_gems > 150;
UPDATE public.cosmetic_catalog SET price_gems = 80   WHERE id = 'consumible_pergamino10' AND price_gems > 80;
UPDATE public.cosmetic_catalog SET price_gems = 300  WHERE id = 'consumible_pergamino50' AND price_gems > 300;
UPDATE public.cosmetic_catalog SET price_gems = 450  WHERE id = 'title_eloquente' AND price_gems > 450;
UPDATE public.cosmetic_catalog SET price_gems = 750  WHERE id = 'title_cazador_sombras' AND price_gems > 750;
UPDATE public.cosmetic_catalog SET price_gems = 1800 WHERE id = 'title_leyenda_viva' AND price_gems > 1800;
UPDATE public.cosmetic_catalog SET price_gems = 550  WHERE id = 'frame_escudo' AND price_gems > 550;
UPDATE public.cosmetic_catalog SET price_gems = 1100 WHERE id = 'frame_dragón' AND price_gems > 1100;
UPDATE public.cosmetic_catalog SET price_gems = 750  WHERE id = 'aura_mana' AND price_gems > 750;
UPDATE public.cosmetic_catalog SET price_gems = 1400 WHERE id = 'aura_fuego' AND price_gems > 1400;
UPDATE public.cosmetic_catalog SET price_gems = 2300 WHERE id = 'aura_sombras' AND price_gems > 2300;
UPDATE public.cosmetic_catalog SET price_gems = 1400 WHERE id = 'pet_lunático' AND price_gems > 1400;
UPDATE public.cosmetic_catalog SET price_gems = 2300 WHERE id = 'pet_fénix' AND price_gems > 2300;
UPDATE public.cosmetic_catalog SET price_gems = 1800 WHERE id = 'theme_mesa_bosque' AND price_gems > 1800;
UPDATE public.cosmetic_catalog SET price_gems = 2800 WHERE id = 'theme_mesa_abismo' AND price_gems > 2800;
UPDATE public.cosmetic_catalog SET price_gems = 350  WHERE id = 'emote_paquete1' AND price_gems > 350;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 4) T-404 — Rotación diaria de misiones (función rotate_daily_missions)     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
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
    DELETE FROM mission_instances WHERE status = 'completed' AND completed_at < v_cutoff;
    DELETE FROM mission_instances WHERE status = 'expired';
    DELETE FROM secret_missions WHERE is_completed = TRUE OR expires_at < NOW();
    DELETE FROM reward_history WHERE claimed_at < v_cutoff;

    FOR v_user IN
        SELECT DISTINCT user_id FROM user_language_profiles
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

COMMENT ON FUNCTION public.rotate_daily_missions() IS 'Rotación diaria de misiones para todos los usuarios (T-404).';

-- Opcional: programar con pg_cron si está disponible
-- select cron.schedule('rotate-missions', '0 6 * * *', $$select public.rotate_daily_missions();$$);

-- ═══ FIN — Verificación rápida: ═══════════════════════════════════════════════
-- SELECT column_name FROM information_schema.columns WHERE table_schema='public'
--   AND table_name IN ('users','user_language_profiles')
--   AND column_name IN ('country_code','fragments');
-- SELECT proname FROM pg_proc JOIN pg_namespace n ON n.oid=pronamespace
--   WHERE n.nspname='public' AND proname IN ('add_fragments','rotate_daily_missions');
