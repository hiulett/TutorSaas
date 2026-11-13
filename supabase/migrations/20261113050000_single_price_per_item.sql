-- Un precio por item: base en oro, premium en gemas (#371).
--
-- Hoy 14 items del catalogo tienen precio en oro Y en gemas a la vez, asi que se
-- puede comprar con oro gratuito el mismo objeto que se ofrece como premium.
-- Eso vacia de sentido a la gema.
--
-- Regla aplicada (explicita por id, no por formula, para que sea revisable):
--   * Nivel <= 5  -> solo ORO  (progresion temprana, alcanzable jugando)
--   * Nivel >= 6  -> solo GEMAS (estatus de largo plazo, valor del plan)
--
-- Los items ya de una sola moneda (3 en oro, 17 en gemas) no se tocan, ni las
-- reliquias gratuitas (precio 0/0).
--
-- Impacto en inventarios: `player_inventory` esta en 0 filas (medido 13-nov),
-- asi que nadie tiene un objeto con el precio cambiado.

-- ── 1. Escalera de oro: se retira el precio en gemas ────────────────────────
update public.cosmetic_catalog
   set price_gems = 0
 where id in (
   'emote_paquete1',          -- lvl 1  ·  120 oro
   'title_eloquente',         -- lvl 2  ·  200 oro
   'frame_escudo',            -- lvl 2  ·  250 oro
   'title_cazador_sombras',   -- lvl 3  ·  350 oro
   'aura_mana',               -- lvl 3  ·  300 oro
   'frame_dragón',            -- lvl 4  ·  450 oro
   'aura_fuego'               -- lvl 5  ·  550 oro
 );

-- ── 2. Escalera premium: se retira el precio en oro ─────────────────────────
update public.cosmetic_catalog
   set price_gold = 0
 where id in (
   'pet_lunático',            -- lvl 6  · 1400 gemas
   'theme_mesa_bosque',       -- lvl 8  · 1800 gemas
   'title_leyenda_viva',      -- lvl 10 · 1800 gemas
   'frame_abismo',            -- lvl 12 · 2000 gemas
   'pet_fénix',               -- lvl 15 · 2300 gemas
   'aura_sombras',            -- lvl 18 · 2300 gemas
   'theme_mesa_abismo'        -- lvl 20 · 2800 gemas
 );

-- ── 3. Invariante: un item no puede tener las dos monedas ───────────────────
-- Blinda la regla para futuros inserts, no solo para este UPDATE.
alter table public.cosmetic_catalog
  drop constraint if exists chk_single_currency_price;
alter table public.cosmetic_catalog
  add constraint chk_single_currency_price
  check (not (price_gold > 0 and price_gems > 0));

-- ── 4. Verificacion ─────────────────────────────────────────────────────────
-- No debe quedar ningun item con las dos monedas:
--   select count(*) from public.cosmetic_catalog
--    where price_gold > 0 and price_gems > 0;                 -- esperado 0
--
-- Reparto esperado:
--   select
--     count(*) filter (where price_gold > 0 and price_gems = 0) as solo_oro,   -- 10
--     count(*) filter (where price_gold = 0 and price_gems > 0) as solo_gemas, -- 24
--     count(*) filter (where price_gold = 0 and price_gems = 0) as gratis      -- 6
--   from public.cosmetic_catalog where is_active;
--
-- Precio maximo en oro (la entrada debe seguir asequible):
--   select max(price_gold) from public.cosmetic_catalog where is_active;      -- 550
