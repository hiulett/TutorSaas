-- ============================================================================
-- TutorSaas — Fase 7 Guild · G-A (CORREGIDO)
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Corrección: las 4 mesas del Gran Salón YA existen en DB (sin ON CONFLICT en title,
-- porque chat_rooms solo tiene PK en id). Este script aplica SOLO la columna
-- room_type, el índice y el tipado de las mesas existentes.
-- Pegar en el SQL Editor y ejecutar.
-- ============================================================================

-- 1. Columna tipo de mesa (purpose dentro de la experiencia RPG)
ALTER TABLE public.chat_rooms
    ADD COLUMN IF NOT EXISTS room_type VARCHAR(20) NOT NULL DEFAULT 'discussion'
    CHECK (room_type IN ('discussion','ai_practice','mentorship','event','training'));

COMMENT ON COLUMN public.chat_rooms.room_type IS 'Propósito de la mesa: discussion, ai_practice, mentorship, event, training.';

-- 2. Tipar las mesas existentes del Gran Salón (idempotente por título)
UPDATE public.chat_rooms
SET room_type = 'discussion',
    moderator_type = COALESCE(moderator_type, 'ai'),
    has_ai_moderator = COALESCE(has_ai_moderator, true)
WHERE title ILIKE '%Taberna del Aprendiz%'
   OR title ILIKE '%Mesa Redonda de T%cticas%'
   OR title ILIKE '%Consejo Supremo%'
   OR title ILIKE '%Archimago%';

-- Mesa 4 es clínica de pronunciación → ai_practice
UPDATE public.chat_rooms
SET room_type = 'ai_practice'
WHERE title ILIKE '%Archimago%';

-- 3. Índice para filtros del salón
CREATE INDEX IF NOT EXISTS idx_chat_rooms_active_type ON public.chat_rooms(is_active, room_type);

-- 4. Verificación
-- SELECT id, title, room_type, is_active FROM chat_rooms ORDER BY created_at;
