-- ============================================================================
-- TutorSaas — LIVE-03: política RLS para el leaderboard semanal
-- Proyecto: sipiumfdpvnszthykyog · Fecha: 2026-07-31
--
-- La política actual de user_language_profiles es `profiles_self`
-- (auth.uid() = user_id), así que la pantalla de ranking solo devuelve
-- la fila del propio usuario. Se añade una política de LECTURA pública
-- para autenticados limitada a las columnas del ranking.
--
-- Nota: el SELECT del leaderboard usa .select('user_id, xp_points'),
-- que a nivel de API solo devuelve esas columnas. La política usa
-- columnas de seguridad con GRANT restringido para no exponer datos
-- sensibles (total_gems, fragments, email...) a otros cazadores.
-- ============================================================================

-- Política: los autenticados pueden LEER filas de todos (para el ranking),
-- pero el GRANT a nivel de columna controla qué campos se exponen.
drop policy if exists "leaderboard_read" on public.user_language_profiles;
create policy "leaderboard_read"
  on public.user_language_profiles
  for select
  to authenticated
  using (true);

-- Restringe el SELECT a solo las columnas del ranking:
-- user_id, xp_points. Revoca columnas sensibles para authenticated.
revoke select on public.user_language_profiles from authenticated;
grant select (user_id, xp_points) on public.user_language_profiles to authenticated;

-- ============================================================================
-- Verificación (desde un cliente autenticado):
--   SELECT user_id, xp_points FROM user_language_profiles ORDER BY xp_points DESC LIMIT 20;
-- Debe devolver filas de TODOS los cazadores.
-- ============================================================================
