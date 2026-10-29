-- P-42 (#127) — Los escenarios generados por IA nacen como borrador privado.
--
-- Antes la única política de lectura era `authenticated_read`, que permitía a
-- CUALQUIER usuario autenticado leer cualquier fila de `scenarios`, incluidos
-- los borradores que el edge function `lesson-generator` inserta con
-- `review_status='draft'`. La lección de refuerzo se generaba y quedaba
-- visible para todos (o invisible, según el filtro del cliente) sin pasar
-- revisión.
--
-- Regla nueva:
--   * biblioteca aprobada y activa → lectura pública (500 escenarios);
--   * borrador activo → solo su creador (`created_by_user_id = auth.uid()`);
--   * admin (`app_metadata.role = 'admin'`) → todo, como antes.
--
-- Aplicada en producción (sipiumfdpvnszthykyog) vía MCP como versión
-- 20261029142618; los borradores ya no se filtran en el cliente.
drop policy if exists authenticated_read on public.scenarios;

create policy scenarios_read_approved_or_own on public.scenarios
  for select to authenticated
  using (
    (is_active and review_status = 'approved')
    or (is_active and review_status = 'draft' and created_by_user_id = auth.uid())
    or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
  );

comment on policy scenarios_read_approved_or_own on public.scenarios is
  'P-42 #127: la biblioteca aprobada es publica; los borradores solo para su creador.';
