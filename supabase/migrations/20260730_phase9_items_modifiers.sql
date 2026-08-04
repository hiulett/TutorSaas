-- ============================================================================
-- TutorSaas — Fase 9 RPG · Esquema del sistema de items + modificadores
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- IT-01, IT-02, MM-01, MM-05 · Pegar en el SQL Editor y ejecutar.
-- ============================================================================

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ IT-01: Ampliar tipos de item (key, book, mission_modifier)                 ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
ALTER TABLE public.player_inventory DROP CONSTRAINT IF EXISTS player_inventory_item_type_check;

ALTER TABLE public.player_inventory
    ADD CONSTRAINT player_inventory_item_type_check
    CHECK (item_type IN (
        'title','skin','frame','aura','pet','emote','theme',
        'table_theme','guild_decoration','relic','consumable',
        'key','book','mission_modifier'
    ));

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ IT-02: Metadata de items (efecto, meta, fuente de obtención)               ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
ALTER TABLE public.player_inventory
    ADD COLUMN IF NOT EXISTS item_effect JSONB,
    ADD COLUMN IF NOT EXISTS item_meta JSONB,
    ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'shop';

COMMENT ON COLUMN public.player_inventory.item_effect IS 'Efecto del item consumible/modificador (ej. {"type":"reward_x2"}).';
COMMENT ON COLUMN public.player_inventory.item_meta IS 'Metadata adicional (nivel requerido, temporada, colección).';
COMMENT ON COLUMN public.player_inventory.source IS 'Origen: shop, loot, quest, reward, guild.';

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ MM-01: Modificadores en misiones (multiplicador + trazabilidad)            ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
ALTER TABLE public.mission_instances
    ADD COLUMN IF NOT EXISTS reward_multiplier INTEGER DEFAULT 1,
    ADD COLUMN IF NOT EXISTS applied_modifier_code VARCHAR(100);

COMMENT ON COLUMN public.mission_instances.reward_multiplier IS 'Multiplicador de recompensa (1, 2). Aplica items mission_modifier.';
COMMENT ON COLUMN public.mission_instances.applied_modifier_code IS 'Código del item modificador aplicado (trazabilidad).';

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ MM-05: Seed de items mission_modifier en catálogo                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
INSERT INTO public.cosmetic_catalog (id, name, description, category, price_gems, rarity) VALUES
    ('mod_recompensa_x2', 'Pergamino de Recompensa x2', 'Duplica la XP y gemas de la próxima misión completada.', 'consumable', 120, 'rare'),
    ('mod_piedra_facilidad', 'Piedra de Facilidad', 'Reduce a la mitad el objetivo de una misión activa.', 'consumable', 90, 'common'),
    ('mod_piedra_desafio', 'Piedra de Desafío', 'Aumenta la recompensa x2 pero sube el objetivo 50%.', 'consumable', 150, 'epic'),
    ('mod_llave_ruta_secreta', 'Llave de Ruta Secreta', 'Desbloquea una misión secreta adicional.', 'consumable', 200, 'rare')
ON CONFLICT (id) DO NOTHING;

-- Catálogo de llaves y libros (IT-03, IT-01)
INSERT INTO public.cosmetic_catalog (id, name, description, category, price_gems, rarity) VALUES
    ('key_mazmorra_oculta', 'Llave de la Mazmorra Oculta', 'Desbloquea la mazmorra oculta por 24h.', 'consumable', 150, 'rare'),
    ('key_archivo_gremio', 'Llave del Archivo del Gremio', 'Accede a contenido histórico premium temporal.', 'consumable', 250, 'epic'),
    ('book_phrasal_verbs', 'Libro de Phrasal Verbs', 'Guía de phrasal verbs esenciales (nivel B1+).', 'consumable', 100, 'common'),
    ('book_grimorio_tiempos', 'Grimorio de Tiempos Verbales', 'Referencia completa de tiempos verbales.', 'consumable', 180, 'rare'),
    ('book_pronunciacion', 'Manual de Pronunciación', 'Claves fonéticas para sonar natural.', 'consumable', 120, 'common')
ON CONFLICT (id) DO NOTHING;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║ DC-01: Seed de skins, fondos y decoración de guild                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
INSERT INTO public.cosmetic_catalog (id, name, description, category, price_gems, rarity) VALUES
    ('skin_cazador', 'Skin: Cazador de Élite', 'Aspecto de cazador veterano.', 'consumable', 800, 'rare'),
    ('skin_arcano', 'Skin: Portador del Arcano', 'Aspecto imbuido de maná.', 'consumable', 1600, 'epic'),
    ('theme_fondo_abismo', 'Fondo: Abismo en Calma', 'Fondo del mapa con temática abisal.', 'consumable', 900, 'rare'),
    ('guild_dec_trofeo_dragon', 'Trofeo: Colmillo de Dragón', 'Trofeo del gremio por cacerías colaborativas.', 'consumable', 0, 'epic'),
    ('guild_dec_estandarte', 'Estandarte del Gremio', 'Decora la mesa del gremio con tu estandarte.', 'consumable', 600, 'rare')
ON CONFLICT (id) DO NOTHING;

-- Verificación
-- SELECT id, name, category, rarity FROM public.cosmetic_catalog WHERE id IN ('mod_recompensa_x2','mod_piedra_facilidad','mod_piedra_desafio','mod_llave_ruta_secreta','key_mazmorra_oculta','book_phrasal_verbs','skin_cazador','guild_dec_trofeo_dragon');
-- SELECT column_name FROM information_schema.columns WHERE table_schema='public'
--   AND table_name IN ('player_inventory','mission_instances')
--   AND column_name IN ('item_effect','item_meta','source','reward_multiplier','applied_modifier_code');
