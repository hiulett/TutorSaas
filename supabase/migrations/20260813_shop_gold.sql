-- ============================================================================
-- TutorSaas — FASE C: Shop en Oro (cosméticos) + catálogo de maná en BD
-- Proyecto: sipiumfdpvnszthykyog
-- Fecha: 2026-08-13
--
-- El shop deja de usar gemas/invocaciones. Los cosméticos se compran con ORO
-- (moneda ganada jugando) y el Maná solo se adquiere con dinero (porciones y
-- packs en mana_potions / mana_gems, ya creados en la Fase A).
-- ============================================================================

BEGIN;

-- Precio en oro de los cosméticos (0 = no se vende por oro).
ALTER TABLE public.cosmetic_catalog
    ADD COLUMN IF NOT EXISTS price_gold INTEGER NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.cosmetic_catalog.price_gold IS
  'Precio en Oro (moneda ganada jugando). 0 = no se vende en la Tienda de Oro.';

UPDATE public.cosmetic_catalog SET price_gold = 200  WHERE id = 'title_eloquente';
UPDATE public.cosmetic_catalog SET price_gold = 350  WHERE id = 'title_cazador_sombras';
UPDATE public.cosmetic_catalog SET price_gold = 800  WHERE id = 'title_leyenda_viva';
UPDATE public.cosmetic_catalog SET price_gold = 250  WHERE id = 'frame_escudo';
UPDATE public.cosmetic_catalog SET price_gold = 450  WHERE id = 'frame_dragón';
UPDATE public.cosmetic_catalog SET price_gold = 900  WHERE id = 'frame_abismo';
UPDATE public.cosmetic_catalog SET price_gold = 300  WHERE id = 'aura_mana';
UPDATE public.cosmetic_catalog SET price_gold = 550  WHERE id = 'aura_fuego';
UPDATE public.cosmetic_catalog SET price_gold = 1100 WHERE id = 'aura_sombras';
UPDATE public.cosmetic_catalog SET price_gold = 600  WHERE id = 'pet_lunático';
UPDATE public.cosmetic_catalog SET price_gold = 1000 WHERE id = 'pet_fénix';
UPDATE public.cosmetic_catalog SET price_gold = 120  WHERE id = 'emote_paquete1';
UPDATE public.cosmetic_catalog SET price_gold = 700  WHERE id = 'theme_mesa_bosque';
UPDATE public.cosmetic_catalog SET price_gold = 1200 WHERE id = 'theme_mesa_abismo';

-- Los consumibles que otorgaban invocaciones quedan DEPRECADOS (maná solo con dinero).
COMMENT ON TABLE public.player_daily_state IS
  'DEPRECADO: la energía diaria gratuita se elimina (diseño v4). El maná = plan + porciones/gemas comprables.';

COMMIT;

-- VERIFICACIÓN:
-- SELECT id, name, category, price_gold FROM public.cosmetic_catalog WHERE price_gold > 0 ORDER BY category, price_gold;
