-- =============================================================================
-- ANUNCIOS DEL GREMIO - persistidos en BD (editables desde web_admin)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.guild_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message TEXT NOT NULL,
    icon_emoji VARCHAR(10) DEFAULT '📜',
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.guild_announcements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "announcements_read" ON public.guild_announcements;
CREATE POLICY "announcements_read" ON public.guild_announcements
  FOR SELECT USING (TRUE);

-- Seed inicial (anuncios por defecto)
INSERT INTO public.guild_announcements (message, icon_emoji, sort_order) VALUES
  ('El Gremio caza en equipo: únete a una mesa y practica en voz.', '📜', 1),
  ('Raid de vocabulario esta semana: gana doble XP.', '⚔️', 2),
  ('El Oráculo recomienda: 15 min de práctica diaria.', '🔮', 3),
  ('Nuevos cazadores han despertado hoy. ¡Bienvenidos!', '🛡️', 4);
