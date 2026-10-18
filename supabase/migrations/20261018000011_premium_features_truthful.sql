-- Issue #36: el premium prometía funciones que no existen.
--
-- `features` describía salas prioritarias, misiones premium, incursión semanal,
-- títulos SSS y acceso anticipado. Nada de eso se comprueba en código: lo único
-- que cambia entre planes es el maná (y el límite diario, que solo aplica al
-- plan gratuito).
--
-- Decisión: reducir la propuesta a lo que el producto hace hoy.

update public.subscription_plans
   set features = jsonb_build_array(
       '3.000 de maná/mes',
       'Límite de 200 de maná al día',
       'Conversación con IA',
       'Progreso, misiones y ranking'
   )
 where id = 'plebeyo';

update public.subscription_plans
   set features = jsonb_build_array(
       '17.000 de maná/mes',
       'Sin límite diario',
       'Conversación con IA',
       'Progreso, misiones y ranking'
   )
 where id = 'noble';

update public.subscription_plans
   set features = jsonb_build_array(
       '20.500 de maná/mes',
       'Sin límite diario',
       'Conversación con IA',
       'Progreso, misiones y ranking'
   )
 where id = 'realeza';

update public.subscription_plans
   set features = jsonb_build_array(
       '25.500 de maná/mes',
       'Sin límite diario',
       'Conversación con IA',
       'Progreso, misiones y ranking'
   )
 where id = 'divino';

-- Planes heredados (Stripe) desactivados: no deben aparecer en la tienda.
update public.subscription_plans
   set is_active = false
 where id in ('free', 'monthly', 'annual', 'lifetime');
