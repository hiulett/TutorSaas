-- =============================================================================
-- ESTADO DEL CAZADOR: stats RPG en columnas reales + título equipado
-- (reemplaza el guardado de stats en el campo bio como texto plano)
-- =============================================================================

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS str_stat INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS int_stat INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS dex_stat INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS luk_stat INTEGER NOT NULL DEFAULT 5;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS equipped_title_code VARCHAR(100) DEFAULT 'oido_halcon_abismo_c';
