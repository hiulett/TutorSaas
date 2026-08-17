-- ============================================================================
-- TutorSaas — FASE A: Maná monetizado + Aura sin tope (diseño v4)
-- Proyecto: sipiumfdpvnszthykyog (producción)
-- Fecha: 2026-08-13
--
-- PRINCIPIOS:
--   1. Toda la configuración vive en BD y es editable desde web_admin.
--   2. Maná = única moneda de consumo de IA. Solo se adquiere con dinero
--      (asignación del plan + porciones/gemas comprables). Las sesiones NUNCA
--      otorgan maná.
--   3. Radar de habilidades (techo 100 por skill) y Aura (sin tope) son
--      sistemas separados pero vinculados: el radar pondera la ganancia y es
--      prerequisito (min_radar) de los títulos de prestigio.
--   4. El costo por acción IA es configurable (ai_action_costs).
--
-- ADVERTENCIA: la DB live puede rechazar DDL ("read-only transaction") vía
-- cliente. Aplicar desde el SQL Editor del dashboard o una rama de Supabase.
-- ============================================================================

BEGIN;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 1. TABLAS DE CONFIGURACIÓN (editables desde web_admin)                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- 1.1 Costo por acción IA (única fuente de verdad; el RPC consume_mana lo lee)
CREATE TABLE IF NOT EXISTS public.ai_action_costs (
    action_code  TEXT PRIMARY KEY,
    label        TEXT NOT NULL,
    cost_mana    INTEGER NOT NULL DEFAULT 10 CHECK (cost_mana >= 0),
    description  TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.ai_action_costs IS
  'Costo en Maná por acción IA. Configurable desde web_admin.';

-- 1.2 Porciones de Maná (consumibles, comprables con dinero)
CREATE TABLE IF NOT EXISTS public.mana_potions (
    id           TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    mana_amount  INTEGER NOT NULL CHECK (mana_amount > 0),
    price_usd    NUMERIC(8,2) NOT NULL DEFAULT 0.99 CHECK (price_usd >= 0),
    currency     TEXT NOT NULL DEFAULT 'USD',
    description  TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    order_index  INTEGER NOT NULL DEFAULT 1,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.mana_potions IS
  'Porciones de Maná (pociones de distintos valores). Productos de pago.';

-- 1.3 Packs de Gemas de Maná (productos de pago directos)
CREATE TABLE IF NOT EXISTS public.mana_gems (
    id           TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    mana_amount  INTEGER NOT NULL CHECK (mana_amount > 0),
    price_usd    NUMERIC(8,2) NOT NULL CHECK (price_usd >= 0),
    currency     TEXT NOT NULL DEFAULT 'USD',
    badge        TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    order_index  INTEGER NOT NULL DEFAULT 1,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.mana_gems IS
  'Packs de Gemas de Maná (moneda dura comprable con dinero real).';

-- 1.4 Escalera universal de prestigio (títulos ganados con Aura)
CREATE TABLE IF NOT EXISTS public.prestige_ladder (
    tier_code        TEXT PRIMARY KEY,
    tier_order       INTEGER NOT NULL UNIQUE,
    name_en          TEXT NOT NULL,
    name_es          TEXT NOT NULL,
    name_pt          TEXT NOT NULL,
    aura_xp_threshold BIGINT NOT NULL DEFAULT 0 CHECK (aura_xp_threshold >= 0),
    min_radar        NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (min_radar >= 0 AND min_radar <= 100),
    ceiling_class    TEXT NOT NULL DEFAULT 'plebeyo'
                     CHECK (ceiling_class IN ('plebeyo','noble','realeza')),
    segment          TEXT NOT NULL DEFAULT 'comun'
                     CHECK (segment IN ('comun','noble','real')),
    icon             TEXT,
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.prestige_ladder IS
  'Ladder universal: título = f(aura_xp, min_radar, techo del estamento).';

-- 1.5 Auditoría de transacciones de Maná
CREATE TABLE IF NOT EXISTS public.mana_transactions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    amount      INTEGER NOT NULL,  -- negativo = consumo; positivo = crédito
    type        TEXT NOT NULL CHECK (type IN ('allowance','potion','gem_pack','action','refund','expire','renew')),
    action_code TEXT,
    ref_id      TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mana_transactions_user_time
    ON public.mana_transactions (user_id, created_at DESC);

COMMENT ON TABLE public.mana_transactions IS
  'Auditoría de cada débito/crédito de Maná (costos, refunds y anti-fraude).';

-- 1.6 Idempotencia de Aura por sesión (anti-farm)
CREATE TABLE IF NOT EXISTS public.aura_session_awards (
    session_id   TEXT PRIMARY KEY,
    user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    aura_gained  BIGINT NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_aura_awards_user ON public.aura_session_awards (user_id);

COMMENT ON TABLE public.aura_session_awards IS
  'Registro por sesión de Aura otorgada; evita el doble pago (idempotencia).';

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 2. COLUMNAS NUEVAS EN TABLAS EXISTENTES                                   ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- subscription_plans: estamento + asignación mensual de maná
ALTER TABLE public.subscription_plans
    ADD COLUMN IF NOT EXISTS class_name      TEXT NOT NULL DEFAULT 'plebeyo'
        CHECK (class_name IN ('plebeyo','noble','realeza')),
    ADD COLUMN IF NOT EXISTS mana_allowance  BIGINT NOT NULL DEFAULT 1800
        CHECK (mana_allowance >= 0);

-- Sincroniza mana_allowance cuando se edita monthly_audio_minutes_limit.
DROP TRIGGER IF EXISTS trg_subscription_plans_mana ON public.subscription_plans;
CREATE OR REPLACE FUNCTION public.sync_mana_allowance() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.mana_allowance := GREATEST(COALESCE(NEW.monthly_audio_minutes_limit, 30) * 60, 0);
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_subscription_plans_mana
    BEFORE INSERT OR UPDATE OF monthly_audio_minutes_limit ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION public.sync_mana_allowance();

-- Clasifica planes existentes por su límite de audio.
UPDATE public.subscription_plans SET class_name = 'plebeyo',  mana_allowance = monthly_audio_minutes_limit * 60
    WHERE is_active AND monthly_audio_minutes_limit <= 30;
UPDATE public.subscription_plans SET class_name = 'noble',    mana_allowance = monthly_audio_minutes_limit * 60
    WHERE is_active AND monthly_audio_minutes_limit > 30 AND monthly_audio_minutes_limit <= 600;
UPDATE public.subscription_plans SET class_name = 'realeza',  mana_allowance = monthly_audio_minutes_limit * 60
    WHERE is_active AND monthly_audio_minutes_limit > 600;

-- user_language_profiles: Aura (sin tope) + radar + título de prestigio
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS aura_xp             BIGINT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS skill_radar         JSONB,
    ADD COLUMN IF NOT EXISTS prestige_title_code TEXT;

COMMENT ON COLUMN public.user_language_profiles.aura_xp IS
  'Mérito acumulado sin tope. Solo crece con la actividad (nunca con dinero).';
COMMENT ON COLUMN public.user_language_profiles.skill_radar IS
  'Snapshot del radar de habilidades (5 skills 0-100) usado para títulos.';

-- user_subscriptions: maná comprado extra + expiración del ciclo
ALTER TABLE public.user_subscriptions
    ADD COLUMN IF NOT EXISTS purchased_mana_balance BIGINT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS mana_expires_at       TIMESTAMPTZ;

COMMENT ON COLUMN public.user_subscriptions.purchased_mana_balance IS
  'Maná extra comprado (porciones/packs). Expira al final del ciclo.';
COMMENT ON COLUMN public.user_subscriptions.mana_expires_at IS
  'Fin del ciclo de facturación: al expirar se resetea el maná (decisión 4).';

-- player_daily_state queda DEPRECADO (la energía diaria gratuita se elimina).
COMMENT ON TABLE public.player_daily_state IS
  'DEPRECADO (Fase A): se elimina la energía diaria gratuita. El maná ahora es la asignación mensual del plan + compras.';

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 3. RPCs                                                                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- 3.1 consume_mana: debita el costo configurable de una acción IA.
CREATE OR REPLACE FUNCTION public.consume_mana(p_user_id uuid, p_action_code text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE
    v_cost      INTEGER;
    v_allowance BIGINT;
    v_purchased BIGINT;
    v_used      BIGINT;
    v_expires   TIMESTAMPTZ;
    v_remaining BIGINT;
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
        RETURN jsonb_build_object('success', false, 'reason', 'unauthorized');
    END IF;

    SELECT COALESCE(cost_mana, 0) INTO v_cost
    FROM public.ai_action_costs WHERE action_code = p_action_code AND is_active;
    IF NOT FOUND OR v_cost <= 0 THEN
        RETURN jsonb_build_object('success', false, 'reason', 'invalid_action');
    END IF;

    -- Asignación del plan (free por defecto = 1800 maná/mes).
    SELECT COALESCE(sp.mana_allowance, 1800) INTO v_allowance
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;
    IF NOT FOUND THEN v_allowance := 1800; END IF;

    SELECT COALESCE(us.purchased_mana_balance, 0), COALESCE(us.used_audio_seconds, 0), us.mana_expires_at
    INTO v_purchased, v_used, v_expires
    FROM public.user_subscriptions us WHERE us.user_id = p_user_id;
    IF NOT FOUND THEN v_purchased := 0; v_used := 0; v_expires := NULL; END IF;

    -- Ciclo expirado → sin saldo disponible hasta renovar (decisión 4).
    -- El reinicio real lo hace renew_mana_cycle (webhook de facturación).
    IF v_expires IS NOT NULL AND v_expires < now() THEN
        v_allowance := 0;
        v_purchased := 0;
    END IF;

    v_remaining := GREATEST(0, (v_allowance + v_purchased) - v_used);
    IF v_remaining < v_cost THEN
        RETURN jsonb_build_object('success', false, 'reason', 'insufficient_mana',
                                  'remaining', v_remaining, 'cost', v_cost);
    END IF;

    INSERT INTO public.user_subscriptions (user_id, used_audio_seconds)
    VALUES (p_user_id, 0) ON CONFLICT (user_id) DO NOTHING;

    UPDATE public.user_subscriptions
    SET used_audio_seconds = COALESCE(used_audio_seconds, 0) + v_cost, updated_at = now()
    WHERE user_id = p_user_id;

    INSERT INTO public.mana_transactions (user_id, amount, type, action_code)
    VALUES (p_user_id, -v_cost, 'action', p_action_code);

    RETURN jsonb_build_object('success', true, 'cost', v_cost, 'remaining', v_remaining - v_cost);
END;
$$;

-- 3.2 grant_mana: crédito de maná (compras). SOLO service_role (webhook/pagos).
CREATE OR REPLACE FUNCTION public.grant_mana(p_user_id uuid, p_amount integer, p_source text DEFAULT 'potion')
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
BEGIN
    IF p_user_id IS NULL OR p_amount <= 0 THEN RETURN FALSE; END IF;

    INSERT INTO public.user_subscriptions (user_id, purchased_mana_balance, used_audio_seconds, updated_at)
    VALUES (p_user_id, p_amount, 0, now())
    ON CONFLICT (user_id) DO UPDATE SET
        purchased_mana_balance = COALESCE(user_subscriptions.purchased_mana_balance, 0) + p_amount,
        updated_at = now();

    INSERT INTO public.mana_transactions (user_id, amount, type, ref_id)
    VALUES (p_user_id, p_amount, p_source, 'purchase');

    RETURN TRUE;
END;
$$;

-- 3.3 renew_mana_cycle: reinicia el ciclo (webhook de facturación). SOLO service_role.
CREATE OR REPLACE FUNCTION public.renew_mana_cycle(p_user_id uuid, p_allowance integer, p_expires_at timestamptz)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
BEGIN
    IF p_user_id IS NULL OR p_expires_at IS NULL THEN RETURN FALSE; END IF;

    INSERT INTO public.user_subscriptions (user_id, plan_id, used_audio_seconds, purchased_mana_balance, mana_expires_at, updated_at)
    VALUES (p_user_id, 'free', 0, 0, p_expires_at, now())
    ON CONFLICT (user_id) DO UPDATE SET
        used_audio_seconds = 0, purchased_mana_balance = 0,
        mana_expires_at = EXCLUDED.mana_expires_at, updated_at = now();

    INSERT INTO public.mana_transactions (user_id, amount, type, ref_id)
    VALUES (p_user_id, p_allowance, 'renew', 'cycle');

    RETURN TRUE;
END;
$$;

-- 3.4 add_gold: recompensas de sesión (moneda cosmética). Guard IDOR.
CREATE OR REPLACE FUNCTION public.add_gold(p_user_id uuid, p_amount integer)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN RAISE EXCEPTION 'No autorizado'; END IF;
    UPDATE public.user_language_profiles
    SET total_gold = COALESCE(total_gold, 0) + p_amount WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        INSERT INTO public.user_language_profiles (user_id, total_gold) VALUES (p_user_id, p_amount);
    END IF;
END;
$$;

-- 3.5 add_aura_xp: gana Aura por sesión (idempotente por session_id).
CREATE OR REPLACE FUNCTION public.add_aura_xp(p_user_id uuid, p_session_id text, p_radar jsonb, p_metas integer, p_bonus_nivel integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE
    v_avg    NUMERIC;
    v_factor NUMERIC;
    v_gain   BIGINT;
    v_title  TEXT;
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
        RETURN jsonb_build_object('added', 0, 'error', 'unauthorized');
    END IF;
    IF p_session_id IS NULL OR p_radar IS NULL OR p_metas IS NULL OR p_metas <= 0 THEN
        RETURN jsonb_build_object('added', 0, 'error', 'invalid_params');
    END IF;

    -- factor_radar: calidad de la sesión pondera la ganancia (sin topar el total).
    SELECT COALESCE(AVG((value)::numeric), 0) INTO v_avg FROM jsonb_each(p_radar);
    v_factor := LEAST(2.0, GREATEST(0.2, v_avg / 50.0));
    v_gain   := GREATEST(0, ROUND((p_metas::numeric * (10 + p_bonus_nivel) * v_factor)))::bigint;

    -- Idempotencia: una sesión solo premia una vez.
    INSERT INTO public.aura_session_awards (session_id, user_id, aura_gained)
    VALUES (p_session_id, p_user_id, v_gain)
    ON CONFLICT (session_id) DO NOTHING
    RETURNING aura_gained INTO v_gain;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('added', 0, 'duplicate', true);
    END IF;

    UPDATE public.user_language_profiles
    SET aura_xp = COALESCE(aura_xp, 0) + v_gain,
        skill_radar = p_radar,
        prestige_title_code = public.compute_prestige_title(p_user_id, p_radar)
    WHERE user_id = p_user_id;

    SELECT prestige_title_code INTO v_title FROM public.user_language_profiles WHERE user_id = p_user_id;
    RETURN jsonb_build_object('added', v_gain, 'title', v_title);
END;
$$;

-- 3.6 compute_prestige_title: título actual según aura_xp + radar + techo.
CREATE OR REPLACE FUNCTION public.compute_prestige_title(p_user_id uuid, p_radar jsonb DEFAULT NULL)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE
    v_aura      BIGINT;
    v_radar     NUMERIC;
    v_class     TEXT;
    v_class_rank INTEGER;
    v_tier      TEXT;
BEGIN
    SELECT COALESCE(aura_xp, 0),
           COALESCE((SELECT AVG((value)::numeric)
                     FROM jsonb_each(COALESCE(p_radar, skill_radar, '{}'::jsonb))), 0)
    INTO v_aura, v_radar
    FROM public.user_language_profiles WHERE user_id = p_user_id;
    IF v_aura IS NULL THEN RETURN NULL; END IF;

    SELECT COALESCE(sp.class_name, 'plebeyo') INTO v_class
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;
    IF NOT FOUND THEN v_class := 'plebeyo'; END IF;

    v_class_rank := CASE v_class WHEN 'realeza' THEN 2 WHEN 'noble' THEN 1 ELSE 0 END;

    SELECT tier_code INTO v_tier
    FROM public.prestige_ladder
    WHERE is_active
      AND aura_xp_threshold <= v_aura
      AND min_radar <= v_radar
      AND CASE ceiling_class WHEN 'plebeyo' THEN 0 WHEN 'noble' THEN 1 ELSE 2 END <= v_class_rank
    ORDER BY tier_order DESC
    LIMIT 1;

    RETURN v_tier;
END;
$$;

-- 3.7 get_prestige_title: lectura pública del título (HUD/perfil).
CREATE OR REPLACE FUNCTION public.get_prestige_title(p_user_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE v_tier TEXT; v_name TEXT;
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
        RETURN jsonb_build_object('tier_code', NULL, 'error', 'unauthorized');
    END IF;
    v_tier := public.compute_prestige_title(p_user_id);
    IF v_tier IS NOT NULL THEN
        SELECT name_es INTO v_name FROM public.prestige_ladder WHERE tier_code = v_tier;
    END IF;
    RETURN jsonb_build_object('tier_code', v_tier, 'name', v_name);
END;
$$;

-- 3.8 get_mana_state: saldo actual para el HUD.
CREATE OR REPLACE FUNCTION public.get_mana_state(p_user_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $$
DECLARE
    v_allowance BIGINT; v_purchased BIGINT; v_used BIGINT; v_expires TIMESTAMPTZ;
    v_plan TEXT; v_class TEXT;
BEGIN
    IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
        RETURN jsonb_build_object('error', 'unauthorized');
    END IF;

    SELECT COALESCE(sp.mana_allowance, 1800), COALESCE(sp.class_name, 'plebeyo'), COALESCE(sp.name, 'Plan Gratuito')
    INTO v_allowance, v_class, v_plan
    FROM public.user_subscriptions us
    JOIN public.subscription_plans sp ON us.plan_id = sp.id
    WHERE us.user_id = p_user_id;

    SELECT COALESCE(us.purchased_mana_balance, 0), COALESCE(us.used_audio_seconds, 0), us.mana_expires_at
    INTO v_purchased, v_used, v_expires
    FROM public.user_subscriptions us WHERE us.user_id = p_user_id;

    IF v_allowance IS NULL THEN v_allowance := 1800; END IF;
    IF v_purchased IS NULL THEN v_purchased := 0; END IF;
    IF v_used IS NULL THEN v_used := 0; END IF;

    RETURN jsonb_build_object(
        'allowance', v_allowance,
        'purchased', v_purchased,
        'used', v_used,
        'remaining', GREATEST(0, (v_allowance + v_purchased) - v_used),
        'expires_at', v_expires,
        'plan', COALESCE(v_plan, 'Plan Gratuito'),
        'class', COALESCE(v_class, 'plebeyo')
    );
END;
$$;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 4. PERMISOS (guards y service_role)                                       ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

REVOKE ALL ON FUNCTION public.consume_mana(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.consume_mana(uuid, text) TO authenticated;

REVOKE ALL ON FUNCTION public.add_aura_xp(uuid, text, jsonb, integer, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.add_aura_xp(uuid, text, jsonb, integer, integer) TO authenticated;

REVOKE ALL ON FUNCTION public.add_gold(uuid, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.add_gold(uuid, integer) TO authenticated;

REVOKE ALL ON FUNCTION public.get_prestige_title(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_prestige_title(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.get_mana_state(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_mana_state(uuid) TO authenticated;

-- Solo service_role (webhook de pagos / renovación). Nada de cliente.
REVOKE ALL ON FUNCTION public.grant_mana(uuid, integer, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_mana(uuid, integer, text) TO service_role;

REVOKE ALL ON FUNCTION public.renew_mana_cycle(uuid, integer, timestamptz) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.renew_mana_cycle(uuid, integer, timestamptz) TO service_role;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 5. SEEDS (editables desde web_admin)                                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

INSERT INTO public.ai_action_costs (action_code, label, cost_mana, description) VALUES
    ('oracle_turn',    'Turno del Oráculo',      15, 'Cada turno conversacional con el Oráculo'),
    ('dungeon_turn',   'Turno en mazmorra',      12, 'Cada turno IA dentro de una mazmorra'),
    ('free_chat_turn', 'Conversación libre',      8, 'Turno de conversación libre'),
    ('oracle_eval',    'Evaluación del Oráculo', 30, 'Examen oral del Oráculo (primera gratis)')
ON CONFLICT (action_code) DO NOTHING;

INSERT INTO public.mana_potions (id, name, mana_amount, price_usd, description, order_index) VALUES
    ('potion_25',  'PORCIÓN PEQUEÑA',  25, 0.29, '+25 de Maná', 1),
    ('potion_50',  'PORCIÓN MEDIA',    50, 0.49, '+50 de Maná', 2),
    ('potion_100', 'PORCIÓN GRANDE',  100, 0.99, '+100 de Maná', 3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.mana_gems (id, name, mana_amount, price_usd, badge, order_index) VALUES
    ('gem_small',   '40 DE MANÁ',   40,   0.99,  NULL,        1),
    ('gem_medium',  '200 DE MANÁ', 200,   3.99,  NULL,        2),
    ('gem_large',   '500 DE MANÁ', 500,   7.99,  NULL,        3),
    ('gem_bundle',  '1200 DE MANÁ', 1200, 14.99, 'MEJOR VALOR', 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.prestige_ladder
    (tier_code, tier_order, name_en, name_es, name_pt, aura_xp_threshold, min_radar, ceiling_class, segment) VALUES
    ('aventurero',    1,  'Adventurer',        'Aventurero',        'Aventureiro',       0,      0,  'plebeyo', 'comun'),
    ('explorador',    2,  'Explorer',          'Explorador',        'Explorador',      500,   10,  'plebeyo', 'comun'),
    ('veterano',      3,  'Veteran',           'Veterano',          'Veterano',       1500,   25,  'plebeyo', 'comun'),
    ('caballero',     4,  'Knight',            'Caballero',         'Cavaleiro',      3000,   35,  'plebeyo', 'comun'),
    ('campeon',       5,  'Champion',          'Campeón',           'Campeão',        5000,   45,  'plebeyo', 'comun'),
    ('heroe',         6,  'Hero',              'Héroe',             'Herói',          8000,   55,  'plebeyo', 'comun'),
    ('leyenda',       7,  'Legend',            'Leyenda',           'Lenda',         12000,   65,  'plebeyo', 'comun'),
    ('baron',         8,  'Baron',             'Barón',             'Barão',         16000,   70,  'noble',   'noble'),
    ('vizconde',      9,  'Viscount',          'Vizconde',          'Visconde',      21000,   72,  'noble',   'noble'),
    ('conde',        10,  'Count',             'Conde',             'Conde',         27000,   75,  'noble',   'noble'),
    ('marques',      11,  'Marquis',           'Marqués',           'Marquês',       34000,   78,  'noble',   'noble'),
    ('duque',        12,  'Duke',              'Duque',             'Duque',         43000,   80,  'noble',   'noble'),
    ('gran_duque',   13,  'Grand Duke',        'Gran Duque',        'Grão-Duque',    53000,   82,  'noble',   'noble'),
    ('principe',     14,  'Prince',            'Príncipe',          'Príncipe',      66000,   84,  'realeza', 'real'),
    ('archiduque',   15,  'Archduke',          'Archiduque',        'Arquiduque',    80000,   86,  'realeza', 'real'),
    ('rey',          16,  'King',              'Rey',               'Rei',           96000,   88,  'realeza', 'real'),
    ('gran_rey',     17,  'High King',         'Gran Rey',          'Grão-Rei',     115000,   90,  'realeza', 'real'),
    ('emperador',    18,  'Emperor',           'Emperador',         'Imperador',    140000,   92,  'realeza', 'real'),
    ('legendario',   19,  'Legendary',         'Legendario',        'Lendário',     170000,   94,  'realeza', 'real'),
    ('senor_reinos', 20,  'Lord of Realms',    'Señor de los Reinos','Senhor dos Reinos', 210000, 96, 'realeza', 'real'),
    ('ascendido',    21,  'Ascended',          'Ascendido',         'Ascendido',    260000,   98,  'realeza', 'real')
ON CONFLICT (tier_code) DO NOTHING;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ 6. RLS                                                                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

ALTER TABLE public.ai_action_costs      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mana_potions         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mana_gems            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prestige_ladder      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mana_transactions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aura_session_awards  ENABLE ROW LEVEL SECURITY;

-- Config: lectura pública (authenticated/anon), escritura solo service_role.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='ai_action_costs'  AND policyname='config_read') THEN
        CREATE POLICY config_read ON public.ai_action_costs FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='mana_potions'     AND policyname='config_read') THEN
        CREATE POLICY config_read ON public.mana_potions FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='mana_gems'        AND policyname='config_read') THEN
        CREATE POLICY config_read ON public.mana_gems FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='prestige_ladder'  AND policyname='config_read') THEN
        CREATE POLICY config_read ON public.prestige_ladder FOR SELECT USING (true);
    END IF;
END;
$$;

-- Auditoría: solo el dueño lee sus transacciones.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='mana_transactions' AND policyname='owner_read') THEN
        CREATE POLICY owner_read ON public.mana_transactions FOR SELECT USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='aura_session_awards' AND policyname='owner_read') THEN
        CREATE POLICY owner_read ON public.aura_session_awards FOR SELECT USING (auth.uid() = user_id);
    END IF;
END;
$$;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN:
-- SELECT * FROM public.ai_action_costs;
-- SELECT * FROM public.prestige_ladder ORDER BY tier_order;
-- SELECT p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
--   WHERE n.nspname='public' AND p.proname IN
--   ('consume_mana','grant_mana','renew_mana_cycle','add_aura_xp',
--    'compute_prestige_title','get_prestige_title','get_mana_state','add_gold');
-- SELECT pg_get_functiondef(p.oid) ILIKE '%auth.uid%' FROM pg_proc p
--   JOIN pg_namespace n ON n.oid=p.pronamespace
--   WHERE n.nspname='public' AND p.proname IN
--   ('consume_mana','add_aura_xp','add_gold','get_mana_state','get_prestige_title');
-- ═══════════════════════════════════════════════════════════════════════════
