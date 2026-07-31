-- =============================================================
-- MIGRACIÓN 6: Soft delete y columnas faltantes en chat_rooms
-- =============================================================

-- 6a. Soft delete en tablas principales
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.conversations ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.user_vocabulary ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.scenarios ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
ALTER TABLE public.pronunciation_assessments ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- 6b. Políticas de soft delete en queries existentes (opcional: ajustar policies para excluir deleted)
DROP POLICY IF EXISTS "scenarios_read" ON public.scenarios;
CREATE POLICY "scenarios_read" ON public.scenarios
  FOR SELECT USING (is_active = true AND deleted_at IS NULL);

-- 6c. Columnas faltantes en chat_rooms
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS max_speakers int NOT NULL DEFAULT 6;
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS has_ai_moderator boolean NOT NULL DEFAULT false;
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS mana_cost_per_min int NOT NULL DEFAULT 0;
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;
ALTER TABLE public.chat_rooms ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- 6d. Actualizar las 4 salas existentes con valores por defecto
UPDATE public.chat_rooms SET
  max_speakers = 6,
  has_ai_moderator = CASE
    WHEN category IN ('business', 'technology', 'art') THEN true
    ELSE false
  END,
  mana_cost_per_min = CASE WHEN category = 'general' THEN 0 ELSE 1 END,
  description = CASE title
    WHEN 'Mesa 1: La Taberna del Aprendiz (A1-A2)' THEN 'Conversacion libre y relajada para cazadores novatos'
    WHEN 'Mesa 2: La Mesa Redonda de Tacticas (B1-B2)' THEN 'Debates de estrategia, negocios y fluidez intermedia'
    WHEN 'Mesa 3: El Consejo Supremo de Altos Cazadores (C1-C2)' THEN 'Elocuencia avanzada y discursos de nivel maestro'
    WHEN 'Mesa 4: La Camara del Archimago (Pronunciacion)' THEN 'Clinica de fonetica y preparacion tecnica'
    ELSE 'Sala de gremio'
  END
WHERE description IS NULL;

SELECT 'Migración 6 completada' AS result;
