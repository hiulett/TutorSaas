-- ============================================================================
-- TutorSaas — T-507: Balance económico (ajuste de catálogo)
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Pegar en el SQL Editor y ejecutar.
-- ============================================================================

-- Balance: consumibles accesibles (~5 sesiones), cosméticos progresivos.
UPDATE public.cosmetic_catalog SET price_gems = 40   WHERE id = 'consumible_invocacion5' AND price_gems > 40;
UPDATE public.cosmetic_catalog SET price_gems = 150  WHERE id = 'consumible_invocacion20' AND price_gems > 150;
UPDATE public.cosmetic_catalog SET price_gems = 80   WHERE id = 'consumible_pergamino10' AND price_gems > 80;
UPDATE public.cosmetic_catalog SET price_gems = 300  WHERE id = 'consumible_pergamino50' AND price_gems > 300;

-- Títulos
UPDATE public.cosmetic_catalog SET price_gems = 450  WHERE id = 'title_eloquente' AND price_gems > 450;
UPDATE public.cosmetic_catalog SET price_gems = 750  WHERE id = 'title_cazador_sombras' AND price_gems > 750;
UPDATE public.cosmetic_catalog SET price_gems = 1800 WHERE id = 'title_leyenda_viva' AND price_gems > 1800;

-- Marcos y auras (progresión 600 → 2500)
UPDATE public.cosmetic_catalog SET price_gems = 550  WHERE id = 'frame_escudo' AND price_gems > 550;
UPDATE public.cosmetic_catalog SET price_gems = 1100 WHERE id = 'frame_dragón' AND price_gems > 1100;
UPDATE public.cosmetic_catalog SET price_gems = 750  WHERE id = 'aura_mana' AND price_gems > 750;
UPDATE public.cosmetic_catalog SET price_gems = 1400 WHERE id = 'aura_fuego' AND price_gems > 1400;
UPDATE public.cosmetic_catalog SET price_gems = 2300 WHERE id = 'aura_sombras' AND price_gems > 2300;

-- Mascotas y temas
UPDATE public.cosmetic_catalog SET price_gems = 1400 WHERE id = 'pet_lunático' AND price_gems > 1400;
UPDATE public.cosmetic_catalog SET price_gems = 2300 WHERE id = 'pet_fénix' AND price_gems > 2300;
UPDATE public.cosmetic_catalog SET price_gems = 1800 WHERE id = 'theme_mesa_bosque' AND price_gems > 1800;
UPDATE public.cosmetic_catalog SET price_gems = 2800 WHERE id = 'theme_mesa_abismo' AND price_gems > 2800;

-- Emotes
UPDATE public.cosmetic_catalog SET price_gems = 350 WHERE id = 'emote_paquete1' AND price_gems > 350;
