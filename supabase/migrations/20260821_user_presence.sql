-- ============================================================================
-- PRESENCIA DE USUARIOS EN LA APP — sección actual + heartbeat
--
-- Propósito: el web admin muestra cuántos usuarios hay online en la app y en
-- qué sección (ruta go_router) están.
--
-- Reglas:
--   1. El cliente móvil reporta su sección actual + heartbeat cada ~30s.
--   2. Un usuario cuenta como "online" si su last_seen_at tiene < 3 min.
--   3. Las escrituras pasan SOLO por el RPC report_presence (SECURITY DEFINER),
--      que usa auth.uid() ⇒ nadie puede reportar por otro usuario.
--   4. SELECT: el propio usuario y los admins (app_metadata.role = 'admin').
-- ============================================================================

-- ── 1. Tabla de presencia ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_presence (
    user_id      UUID        PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    section      TEXT        NOT NULL DEFAULT 'app',
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS user_presence_last_seen_idx
    ON public.user_presence (last_seen_at DESC);

-- ── 2. RPC de reporte de presencia (heartbeat) ────────────────────────────────
CREATE OR REPLACE FUNCTION public.report_presence(p_section TEXT)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    INSERT INTO public.user_presence (user_id, section, last_seen_at)
    VALUES (auth.uid(), p_section, NOW())
    ON CONFLICT (user_id)
    DO UPDATE
        SET section = EXCLUDED.section, last_seen_at = NOW()
        WHERE auth.uid() IS NOT NULL;
$$;

-- ── 3. RLS ────────────────────────────────────────────────────────────────────
ALTER TABLE public.user_presence ENABLE ROW LEVEL SECURITY;

-- Lectura: el propio usuario o un admin.
DROP POLICY IF EXISTS "Leer propia presencia o admin" ON public.user_presence;
CREATE POLICY "Leer propia presencia o admin"
ON public.user_presence FOR SELECT
USING (
    auth.uid() = user_id
    OR (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- ── 4. Permisos ───────────────────────────────────────────────────────────────
REVOKE ALL ON FUNCTION public.report_presence(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.report_presence(TEXT) TO authenticated;
