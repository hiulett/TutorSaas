-- ============================================================================
-- TutorSaas — LIVE-03 FIX: restaurar acceso y leaderboard seguro vía RPC
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
--
-- Problema de la migración anterior (20260731_live03_leaderboard_rls.sql):
--   - El REVOKE global + grants de columna rompió la lectura del perfil
--     propio (language_id, total_gems, fragments, current_streak, ...),
--     porque la app consulta columnas que quedaron sin GRANT para
--     authenticated.
--   - La policy leaderboard_read con USING(true) expondría TODAS las
--     columnas de TODOS si se restaurara el SELECT de tabla.
--
-- Solución correcta (mejor práctica Supabase):
--   1) Restaurar SELECT completo de la tabla para authenticated. La RLS
--      `profiles_self` (auth.uid() = user_id) sigue limitando por fila.
--   2) Eliminar la policy leaderboard_read (using true) que exponía todo.
--   3) Crear RPC get_leaderboard(...) SECURITY DEFINER con search_path fijo
--      que devuelve SOLO user_id + xp_points de todos los cazadores.
--   4) La app consume la RPC, no la tabla.
-- ============================================================================

-- 1. Restaurar SELECT de tabla para authenticated (la RLS profiles_self
--    sigue protegiendo por fila).
grant select on public.user_language_profiles to authenticated;

-- 2. Eliminar la policy peligrosa de lectura global.
drop policy if exists "leaderboard_read" on public.user_language_profiles;

-- 3. RPC de leaderboard: devuelve solo user_id + xp_points de los top N.
drop function if exists public.get_leaderboard(integer);
create or replace function public.get_leaderboard(p_limit integer default 20)
  returns table (user_id uuid, xp_points integer)
  language sql
  security definer
  set search_path = public
as $$
  select ulp.user_id, ulp.xp_points
  from public.user_language_profiles ulp
  order by ulp.xp_points desc
  limit p_limit;
$$;

-- 4. Exponer la RPC a autenticados (solo EXECUTE, sin SELECT directo extra).
revoke all on function public.get_leaderboard(integer) from public;
grant execute on function public.get_leaderboard(integer) to authenticated;

-- ============================================================================
-- Verificación:
--   - SELECT has_table_privilege('authenticated',
--       'public.user_language_profiles', 'SELECT');  -- true
--   - SELECT * FROM public.get_leaderboard(5);        -- top 5 (service_role)
--   - Desde la app: rpc('get_leaderboard', {'p_limit': 20})
-- ============================================================================
