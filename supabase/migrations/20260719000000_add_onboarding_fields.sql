-- ==========================================================
-- AGREGAR COLUMNAS DE PERFIL A USER_SETTINGS
-- ==========================================================

-- 1. Agregar la columna de intereses como arreglo de textos
ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS interests TEXT[] DEFAULT '{}';

-- 2. Agregar la columna de motivación
ALTER TABLE public.user_settings 
ADD COLUMN IF NOT EXISTS motivation TEXT DEFAULT 'general';
