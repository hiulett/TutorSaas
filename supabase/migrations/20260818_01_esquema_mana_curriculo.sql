-- ═══════════════════════════════════════════════════════════════════════════
-- 20260818_01_esquema_mana_curriculo.sql
-- FASE 1 del plan DungeonSpeak: modelo de maná + currículo + monetización.
-- Ejecutar en Supabase Dashboard → SQL Editor (idempotente).
--
-- Contenido:
--   A) Planes: PLUS 17K / PRO 20.5K / MAX(divino) 25.5K + precios y anuales.
--   B) Catálogo de maná: 4 elixires (mana_potions) + 4 gemas (mana_gems).
--   C) Tabla nueva mana_items (inventario equipable: 1 activo, expiración).
--   D) Tabla nueva lesson_progress (lecciones superadas).
--   E) Columnas skill_focus y parent_id en scenarios (sub misiones).
--   F) Costo de generación de lección (lesson_generation = 100 maná).
--   G) Límite diario free (columnas en user_subscriptions).
-- ═══════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- A) PLANES (modelo 2x2: PLUS/PRO/MAX como noble/realeza/divino)
-- ─────────────────────────────────────────────────────────────────────────────

-- Fix previo: el constraint de class_name solo permitía plebeyo/noble/realeza
-- y bloqueaba la inserción de DIVINO. Se reemplaza para permitir 'divino'.
ALTER TABLE public.subscription_plans
  DROP CONSTRAINT IF EXISTS subscription_plans_class_name_check;
ALTER TABLE public.subscription_plans
  ADD CONSTRAINT subscription_plans_class_name_check
  CHECK (class_name = ANY (ARRAY['plebeyo','noble','realeza','divino']));

-- NOBLE (PLUS): $4.99 / $53.99 · 17,000 maná
UPDATE public.subscription_plans SET
  price          = '$4.99',
  price_annual   = '$53.99',
  mana_allowance = 17000,
  class_name     = 'noble',
  order_index    = 1,
  is_active      = true,
  updated_at     = now()
WHERE id = 'noble';

-- REALEZA (PRO): $9.99 / $107.99 · 20,500 maná
UPDATE public.subscription_plans SET
  price          = '$9.99',
  price_annual   = '$107.99',
  mana_allowance = 20500,
  class_name     = 'realeza',
  order_index    = 2,
  is_active      = true,
  updated_at     = now()
WHERE id = 'realeza';

-- DIVINO (MAX): $12.99 / $132.99 · 25,500 maná (nuevo estamento superior)
INSERT INTO public.subscription_plans (
  id, name, price, price_annual, billing_cycle, monthly_audio_minutes_limit,
  description, badge_tag, features, is_active, order_index, class_name,
  mana_allowance, created_at, updated_at
) VALUES (
  'divino', 'DIVINO', '$12.99', '$132.99', 'monthly', 2000,
  'Estamento supremo: 25,500 maná por ciclo. Títulos de élite, prioridad total y acceso anticipado.',
  'MAX', '["25,500 maná por ciclo", "Títulos de rango hasta SSS", "Salas de voz con prioridad", "Misiones premium e incursión semanal"]'::jsonb,
  true, 3, 'divino', 25500, now(), now()
)
ON CONFLICT (id) DO UPDATE SET
  price          = EXCLUDED.price,
  price_annual   = EXCLUDED.price_annual,
  mana_allowance = EXCLUDED.mana_allowance,
  class_name     = EXCLUDED.class_name,
  order_index    = EXCLUDED.order_index,
  is_active      = true,
  updated_at     = now();

-- FREE (PLEBEYO): maná mensual 3,000 (cubre ~20 lecciones A1/mes)
UPDATE public.subscription_plans SET
  mana_allowance = 3000,
  order_index    = 0,
  is_active      = true,
  updated_at     = now()
WHERE id = 'plebeyo';

-- ─────────────────────────────────────────────────────────────────────────────
-- B) CATÁLOGO DE MANÁ — 4 elixires + 4 gemas (ratio ~3,500 maná/$)
-- ─────────────────────────────────────────────────────────────────────────────

-- Elixires (recarga seria, $0.99-$3.99)
INSERT INTO public.mana_potions (id, name, mana_amount, price_usd, currency, is_active, order_index, created_at, updated_at)
VALUES
  ('elixir_3500',  'ELIXIR DE MANÁ',  3500,  '0.99',  'USD', true, 1, now(), now()),
  ('elixir_7000',  'ELIXIR MAYOR',    7000,  '1.99',  'USD', true, 2, now(), now()),
  ('elixir_10500', 'ELIXIR ARCANO',   10500, '2.99',  'USD', true, 3, now(), now()),
  ('elixir_14000', 'ELIXIR LEGENDARIO',14000,'3.99',  'USD', true, 4, now(), now())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, mana_amount = EXCLUDED.mana_amount,
  price_usd = EXCLUDED.price_usd, is_active = true,
  order_index = EXCLUDED.order_index, updated_at = now();

-- Gemas (topping-up, < $1)
INSERT INTO public.mana_gems (id, name, mana_amount, price_usd, currency, is_active, order_index, created_at, updated_at)
VALUES
  ('gem_1000', 'GEMA DE MANÁ',  1000, '0.29', 'USD', true, 1, now(), now()),
  ('gem_1700', 'GEMA MAYOR',    1700, '0.49', 'USD', true, 2, now(), now()),
  ('gem_2400', 'GEMA ARCANO',   2400, '0.69', 'USD', true, 3, now(), now()),
  ('gem_3100', 'GEMA LEGENDARIA',3100,'0.89', 'USD', true, 4, now(), now())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, mana_amount = EXCLUDED.mana_amount,
  price_usd = EXCLUDED.price_usd, is_active = true,
  order_index = EXCLUDED.order_index, updated_at = now();

-- Desactivar los productos viejos (ya reemplazados)
UPDATE public.mana_potions SET is_active = false, updated_at = now()
WHERE id IN ('potion_25','potion_50','potion_100');
UPDATE public.mana_gems SET is_active = false, updated_at = now()
WHERE id IN ('gem_small','gem_medium','gem_large','gem_bundle');

-- ─────────────────────────────────────────────────────────────────────────────
-- C) TABLA mana_items — inventario equipable (1 activo por vez)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.mana_items (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_type   text NOT NULL CHECK (item_type IN ('gema','elixir')),
  item_id     text NOT NULL,               -- ref a mana_gems/mana_potions id
  mana_amount integer NOT NULL DEFAULT 0,  -- snapshot al comprar
  status      text NOT NULL DEFAULT 'inventory' CHECK (status IN ('inventory','equipped')),
  equipped_at timestamptz,                 -- inicia la expiración
  expires_at  timestamptz,                 -- equipped_at + 48h (gema) / 15d (elixir)
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Solo 1 ítem equipado por usuario
CREATE UNIQUE INDEX IF NOT EXISTS mana_items_one_equipped
  ON public.mana_items (user_id) WHERE status = 'equipped';

-- Índices de consulta
CREATE INDEX IF NOT EXISTS mana_items_user_idx ON public.mana_items (user_id, status);
CREATE INDEX IF NOT EXISTS mana_items_expiry_idx ON public.mana_items (status, expires_at);

-- RLS: cada usuario solo ve/gestiona sus ítems
ALTER TABLE public.mana_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS mana_items_select ON public.mana_items;
CREATE POLICY mana_items_select ON public.mana_items
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS mana_items_insert ON public.mana_items;
CREATE POLICY mana_items_insert ON public.mana_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS mana_items_update ON public.mana_items;
CREATE POLICY mana_items_update ON public.mana_items
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS mana_items_delete ON public.mana_items;
CREATE POLICY mana_items_delete ON public.mana_items
  FOR DELETE USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- D) TABLA lesson_progress — lecciones superadas por el jugador
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.lesson_progress (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id    text NOT NULL,                       -- id del escenario/lección
  skill_focus  text,                                -- skill que refuerza (si sub misión)
  status       text NOT NULL DEFAULT 'passed' CHECK (status IN ('passed','failed')),
  completed_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS lesson_progress_user_idx ON public.lesson_progress (user_id, lesson_id);

ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lesson_progress_select ON public.lesson_progress;
CREATE POLICY lesson_progress_select ON public.lesson_progress
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS lesson_progress_insert ON public.lesson_progress;
CREATE POLICY lesson_progress_insert ON public.lesson_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- E) COLUMNAS en scenarios — skill_focus + parent_id (sub misiones)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.scenarios
  ADD COLUMN IF NOT EXISTS skill_focus text
    CHECK (skill_focus IN ('fluency','vocab','phonetics','grammar','goals'));

ALTER TABLE public.scenarios
  ADD COLUMN IF NOT EXISTS parent_id text;  -- id de la lección principal (sub misión)

CREATE INDEX IF NOT EXISTS scenarios_skill_idx ON public.scenarios (skill_focus, difficulty_level);
CREATE INDEX IF NOT EXISTS scenarios_parent_idx ON public.scenarios (parent_id);

-- ─────────────────────────────────────────────────────────────────────────────
-- F) COSTO de generación de lección (100 maná)
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO public.ai_action_costs (action_code, label, cost_mana, description, is_active, updated_at)
VALUES (
  'lesson_generation', 'Generar lección', 100,
  'Genera una nueva lección de refuerzo (sub misión) orientada a un skill', true, now()
)
ON CONFLICT (action_code) DO UPDATE SET
  cost_mana = 100, is_active = true, updated_at = now();

-- ─────────────────────────────────────────────────────────────────────────────
-- G) LÍMITE DIARIO free (200/día) en user_subscriptions
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.user_subscriptions
  ADD COLUMN IF NOT EXISTS daily_limit integer NOT NULL DEFAULT 200;

ALTER TABLE public.user_subscriptions
  ADD COLUMN IF NOT EXISTS daily_used integer NOT NULL DEFAULT 0;

ALTER TABLE public.user_subscriptions
  ADD COLUMN IF NOT EXISTS daily_reset_date date;  -- fecha del último reset

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT id, name, price, price_annual, mana_allowance, class_name, order_index
FROM public.subscription_plans
WHERE id IN ('plebeyo','noble','realeza','divino') ORDER BY order_index;

SELECT id, name, mana_amount, price_usd FROM public.mana_potions WHERE is_active ORDER BY order_index;
SELECT id, name, mana_amount, price_usd FROM public.mana_gems WHERE is_active ORDER BY order_index;

SELECT column_name FROM information_schema.columns
WHERE table_name='scenarios' AND column_name IN ('skill_focus','parent_id');

SELECT action_code, cost_mana FROM public.ai_action_costs WHERE action_code='lesson_generation';
