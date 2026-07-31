-- Add equipped_title_code column to user_language_profiles
-- This stores the currently equipped hunter title code for the Status Window
ALTER TABLE user_language_profiles
ADD COLUMN IF NOT EXISTS equipped_title_code text DEFAULT 'oido_halcon_abismo_c';

-- Optional: Add a similar column to users table for a global equipped title across languages
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS equipped_title_code text DEFAULT 'oido_halcon_abismo_c';

COMMENT ON COLUMN user_language_profiles.equipped_title_code IS 'Code of the currently equipped HunterTitleItem from HunterCatalog. Default: oido_halcon_abismo_c (Oído de Halcón del Abismo - Rank C)';
