-- Issue #59: purga de participantes fantasma en salas de gremio.
--
-- `purge_stale_participants(p_max_age_seconds)` existe desde
-- `20260811_guild_table_states.sql`, pero **ningún cron la llamaba**. Resultado:
-- filas de `chat_room_participants` de usuarios que cerraron la app seguían
-- apareciendo como conectadas (en producción se encontraron 2 con 59 días).
--
-- Se programa cada minuto con umbral de 180 s (6 latidos perdidos de 30 s):
-- suficiente para limpiar fantasmas y tolerante con un móvil bloqueado un rato.

do $sched$
begin
  if exists (select 1 from cron.job where jobname = 'purge-stale-participants') then
    perform cron.unschedule('purge-stale-participants');
  end if;

  perform cron.schedule(
    'purge-stale-participants',
    '* * * * *',
    'select public.purge_stale_participants(180);'
  );
end;
$sched$;
