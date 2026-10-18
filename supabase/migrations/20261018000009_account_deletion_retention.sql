-- Issue #16: sin retención de conversaciones ni borrado/exportación de cuenta.
--
-- Antes:
--   * No existía forma de que un usuario borrase su cuenta ni exportase sus datos.
--   * `clean_old_logs` no existía en la base (solo en documentación) y no había
--     ningún job de retención programado.
--
-- Este cambio añade lo que no requiere una decisión de producto sobre cuánto
-- tiempo conservar conversaciones:
--   * borrado de cuenta en cascada,
--   * exportación de datos del usuario,
--   * limpieza programada de logs (90 días).

create or replace function public.delete_my_account()
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $d$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  -- Las 17 claves foráneas hacia auth.users son ON DELETE CASCADE / SET NULL,
  -- así que el borrado arrastra perfil, progreso, economía y conversaciones.
  delete from auth.users where id = v_uid;

  return jsonb_build_object('success', true);
end;
$d$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

create or replace function public.export_my_data()
returns jsonb
language plpgsql
security definer
set search_path = public
as $e$
declare
  v_uid uuid := auth.uid();
  v_out jsonb;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  v_out := jsonb_build_object(
    'exported_at', now(),
    'user_id', v_uid,
    'profile', (select to_jsonb(p) from public.user_language_profiles p where p.user_id = v_uid),
    'settings', (select to_jsonb(s) from public.user_settings s where s.user_id = v_uid),
    'conversations', (select coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb)
                        from public.conversations c where c.user_id = v_uid),
    'messages', (select coalesce(jsonb_agg(to_jsonb(m)), '[]'::jsonb)
                   from public.messages m
                   join public.conversations c on c.id = m.conversation_id
                  where c.user_id = v_uid),
    'vocabulary', (select coalesce(jsonb_agg(to_jsonb(v)), '[]'::jsonb)
                     from public.user_vocabulary v where v.user_id = v_uid)
  );

  return v_out;
end;
$e$;

revoke all on function public.export_my_data() from public, anon;
grant execute on function public.export_my_data() to authenticated;

create or replace function public.clean_old_logs()
returns integer
language plpgsql
security definer
set search_path = public
as $c$
declare
  v_deleted integer := 0;
  v_n integer;
begin
  if to_regclass('public.api_request_logs') is not null then
    delete from public.api_request_logs where created_at < now() - interval '90 days';
    get diagnostics v_n = row_count;
    v_deleted := v_deleted + v_n;
  end if;

  if to_regclass('public.ai_usage_logs') is not null then
    delete from public.ai_usage_logs where created_at < now() - interval '90 days';
    get diagnostics v_n = row_count;
    v_deleted := v_deleted + v_n;
  end if;

  return v_deleted;
end;
$c$;

revoke all on function public.clean_old_logs() from public, anon, authenticated;

do $sched$
begin
  if not exists (select 1 from cron.job where jobname = 'clean-old-logs') then
    perform cron.schedule('clean-old-logs', '15 3 * * *', 'select public.clean_old_logs();');
  end if;
end;
$sched$;
