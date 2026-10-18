-- ═══════════════════════════════════════════════════════════════════════════
-- 20260818_06_descripciones_planes.sql
-- Actualiza description y features de los planes al modelo comercial nuevo
-- (nombres Plus/Pro/Max y maná 17K/20.5K/25.5K).
-- Ejecutar en Supabase Dashboard → SQL Editor (idempotente).
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE public.subscription_plans SET
  description = 'DungeonSpeak Plus: 17,000 de maná al mes para practicar inglés conversacional con tu tutor IA. Sube de rango en el mapa de mazmorras.',
  features = '["17,000 maná/mes", "Conversación IA", "Títulos de rango F a A", "Salas de voz del Gran Salón", "Misiones premium e incursión semanal"]'::jsonb,
  updated_at = now()
WHERE id = 'noble';

UPDATE public.subscription_plans SET
  description = 'DungeonSpeak Pro: 20,500 de maná al mes. Estamento REALEZA: avanza más rápido, más misiones y mayor techo de prestigio.',
  features = '["20,500 maná/mes", "Títulos de rango hasta SS", "Salas de voz con prioridad", "Misiones premium", "Incursión semanal"]'::jsonb,
  updated_at = now()
WHERE id = 'realeza';

UPDATE public.subscription_plans SET
  description = 'DungeonSpeak Max: 25,500 de maná al mes. Estamento DIVINO: el máximo poder, prioridad total y acceso anticipado.',
  features = '["25,500 maná/mes", "Títulos de rango hasta SSS", "Prioridad total en salas de voz", "Misiones premium", "Incursión semanal", "Acceso anticipado"]'::jsonb,
  updated_at = now()
WHERE id = 'divino';

-- ─────────────────────────────────────────────────────────────────────────────
-- VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────────────────────
SELECT id, name, description FROM public.subscription_plans
WHERE id IN ('noble','realeza','divino') ORDER BY order_index;
