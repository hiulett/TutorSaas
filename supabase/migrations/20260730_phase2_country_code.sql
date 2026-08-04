-- ============================================================================
-- TutorSaas — T-104: Columna país de origen en users
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Pegar en el SQL Editor y ejecutar.
-- ============================================================================

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS country_code VARCHAR(10) DEFAULT 'MX';

COMMENT ON COLUMN public.users.country_code IS 'País de origen del usuario (ISO-3166 alpha-2).';
