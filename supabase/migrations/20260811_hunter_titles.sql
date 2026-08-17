-- ============================================================================
-- TutorSaas — TÍTULOS DE HABILIDAD (asignados por desempeño, no comprables)
-- Fecha: 2026-08-11
--
-- hunter_titles: catálogo de títulos por línea de habilidad (conversación).
-- user_titles: títulos GANADOS por el cazador (idempotente, sin retroceso).
-- Idempotente.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.hunter_titles (
    code        TEXT PRIMARY KEY,
    line        TEXT NOT NULL,             -- fluidez|fonetica|lexico|precision|constancia|carisma
    tier        INTEGER NOT NULL,          -- 1..4 (1 humilde → 4 legendario)
    rarity      TEXT NOT NULL DEFAULT 'common',
    threshold   NUMERIC NOT NULL,          -- umbral de la métrica de la línea
    name        TEXT NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS public.user_titles (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    line       TEXT NOT NULL,
    title_code TEXT NOT NULL REFERENCES public.hunter_titles(code),
    tier       INTEGER NOT NULL,
    earned_at  TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, line, title_code)
);

-- Seed del catálogo (24 títulos: 6 líneas × 4 niveles)
INSERT INTO public.hunter_titles (code, line, tier, rarity, threshold, name, description) VALUES
  -- FLUIDEZ
  ('titulo_fluidez_1', 'fluidez', 1, 'common',    60, 'Aprendiz de Palabras', 'Empiezas a expresarte con continuidad.'),
  ('titulo_fluidez_2', 'fluidez', 2, 'rare',      75, 'El Correo Veloz', 'Hablas con ritmo y fluidez notable.'),
  ('titulo_fluidez_3', 'fluidez', 3, 'epic',      88, 'Heraldo del Vendaval', 'Tu discurso fluye sin esfuerzo.'),
  ('titulo_fluidez_4', 'fluidez', 4, 'legendary', 95, 'Vocero de los Dioses', 'Fluidez casi divina al conversar.'),
  -- FONÉTICA
  ('titulo_fonetica_1', 'fonetica', 1, 'common',    55, 'Aprendiz de la Voz', 'Tu pronunciación empieza a ser clara.'),
  ('titulo_fonetica_2', 'fonetica', 2, 'rare',      70, 'Eco del Coliseo', 'Pronuncias con precisión destacable.'),
  ('titulo_fonetica_3', 'fonetica', 3, 'epic',      85, 'Cantor de Cristal', 'Tu fonética es limpia y brillante.'),
  ('titulo_fonetica_4', 'fonetica', 4, 'legendary', 94, 'Afinador Celestial', 'Claridad fonética de otro plano.'),
  -- LÉXICO
  ('titulo_lexico_1', 'lexico', 1, 'common',    20,   'Recolector de Palabras', 'Sumas tus primeras palabras dominadas.'),
  ('titulo_lexico_2', 'lexico', 2, 'rare',      80,   'Bibliotecario de Aldea', 'Tu vocabulario crece con solidez.'),
  ('titulo_lexico_3', 'lexico', 3, 'epic',      200,  'Escriba del Abismo', 'Dominas un vocabulario extenso.'),
  ('titulo_lexico_4', 'lexico', 4, 'legendary', 500,  'Lexicógrafo Eterno', 'Tu léxico no tiene fronteras.'),
  -- PRECISIÓN (gramática)
  ('titulo_precision_1', 'precision', 1, 'common',    50, 'Aprendiz de las Reglas', 'Estructuras simples ya son sólidas.'),
  ('titulo_precision_2', 'precision', 2, 'rare',      70, 'Aprendiz de Runas', 'Tu gramática gana consistencia.'),
  ('titulo_precision_3', 'precision', 3, 'epic',      85, 'Gramático del Coliseo', 'Construyes oraciones con dominio.'),
  ('titulo_precision_4', 'precision', 4, 'legendary', 94, 'Forjador de Sintaxis', 'Tu precisión gramatical es legendaria.'),
  -- CONSTANCIA
  ('titulo_constancia_1', 'constancia', 1, 'common',    3,   'Aprendiz Constante', 'Tres días seguidos practicando.'),
  ('titulo_constancia_2', 'constancia', 2, 'rare',      7,   'Guardián del Fuego', 'Una semana ininterrumpida.'),
  ('titulo_constancia_3', 'constancia', 3, 'epic',      30,  'Centinela del Amanecer', 'Un mes de constancia férrea.'),
  ('titulo_constancia_4', 'constancia', 4, 'legendary', 100, 'Leyenda de la Racha', 'Cien días de dedicación absoluta.'),
  -- CARISMA (cualitativo — IA; seed para el futuro paso)
  ('titulo_carisma_1', 'carisma', 1, 'common',    55, 'Novato del Gremio', 'Te desenvuelves en conversaciones.'),
  ('titulo_carisma_2', 'carisma', 2, 'rare',      70, 'Alma de la Taberna', 'Conectas naturalmente con los demás.'),
  ('titulo_carisma_3', 'carisma', 3, 'epic',      85, 'Embajador del Reino', 'Llevas la conversación con soltura.'),
  ('titulo_carisma_4', 'carisma', 4, 'legendary', 94, 'Oráculo Menor', 'Tu carisma conversacional es de otro mundo.')
ON CONFLICT (code) DO NOTHING;

-- RLS
ALTER TABLE public.hunter_titles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_titles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_hunter_titles" ON public.hunter_titles;
CREATE POLICY "select_hunter_titles" ON public.hunter_titles FOR SELECT USING (true);

DROP POLICY IF EXISTS "select_own_user_titles" ON public.user_titles;
CREATE POLICY "select_own_user_titles" ON public.user_titles FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_user_titles" ON public.user_titles;
CREATE POLICY "insert_own_user_titles" ON public.user_titles FOR INSERT WITH CHECK (auth.uid() = user_id);
