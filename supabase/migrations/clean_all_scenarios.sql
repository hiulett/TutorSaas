-- =============================================================================
-- TUTORSAAS - SCRIPT DE LIMPIEZA EXPLÍCITA DE ESCENARIOS Y LECCIONES
-- Elimina y vacía completamente la tabla public.scenarios de la base de datos
-- =============================================================================

-- 1. Vaciar tabla de conversaciones y mensajes vinculados si existen
TRUNCATE TABLE public.messages CASCADE;
TRUNCATE TABLE public.conversations CASCADE;

-- 2. Vaciar completamente la tabla public.scenarios y reiniciar sus identidades
TRUNCATE TABLE public.scenarios RESTART IDENTITY CASCADE;

-- Confirmación de vaciado
SELECT COUNT(*) AS lecciones_restantes FROM public.scenarios;
