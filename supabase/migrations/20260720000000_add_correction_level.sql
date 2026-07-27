-- ==========================================================
-- AGREGAR COLUMNA CORRECTION_LEVEL A USER_SETTINGS
-- ==========================================================

ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS correction_level VARCHAR(20) DEFAULT 'short';
