-- ============================================================================
-- TutorSaas — T-504: Oro + Fragmentos (recursos)
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Pegar en el SQL Editor y ejecutar.
-- ============================================================================

-- Fragmentos: drop de conversaciones (acumulables, canjeables en la tienda).
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS fragments INTEGER DEFAULT 0;

COMMENT ON COLUMN public.user_language_profiles.fragments IS 'Fragmentos rúnicos obtenidos como loot en conversaciones.';

-- add_fragments: suma fragmentos al saldo del usuario.
CREATE OR REPLACE FUNCTION public.add_fragments(p_user_id UUID, p_amount INTEGER)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_language_profiles
    SET fragments = COALESCE(fragments, 0) + p_amount
    WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        INSERT INTO public.user_language_profiles (user_id, fragments)
        VALUES (p_user_id, p_amount);
    END IF;
END;
$$;
