-- ============================================================================
-- TutorSaas — Fase 8 IA · MO-A + MO-B: correcciones de monetización
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-30
-- Pegar en el SQL Editor y ejecutar.
-- ============================================================================

-- MO-A: Lifetime debe ser el plan máximo (antes 600 < annual 1200, incoherente)
UPDATE public.subscription_plans
SET monthly_audio_minutes_limit = 1200
WHERE id = 'lifetime';

-- MO-B: Battle Pass incluido en Monthly (hoy solo annual lo tiene)
UPDATE public.subscription_plans
SET features = jsonb_build_array(
    'Conversaciones IA ilimitadas',
    'Corrección gramatical avanzada',
    'Speech DNA completo',
    'Blind Listening ilimitado',
    'Modo Boss ilimitado',
    'Historial ilimitado',
    'Battle Pass incluido'
)
WHERE id = 'monthly';

-- MO-A (complemento): reflejar Battle Pass también en Lifetime
UPDATE public.subscription_plans
SET features = jsonb_build_array(
    'Todo lo del plan anual',
    '1200 min/mes de por vida',
    'Todos los cosméticos futuros',
    'Acceso a expansiones premium',
    'Prioridad máxima en servidores',
    'Battle Pass incluido'
)
WHERE id = 'lifetime';

-- Verificación
-- SELECT id, price, monthly_audio_minutes_limit, features FROM public.subscription_plans ORDER BY order_index;
