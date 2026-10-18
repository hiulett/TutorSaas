-- Issue #13: rotación diaria de misiones programada con pg_cron + pg_net.
--
-- El secreto se genera DENTRO de Postgres y vive solo en Vault. Nunca se
-- escribe en el repositorio ni en variables de entorno de la Edge Function:
--   * pg_cron lo lee de `vault.decrypted_secrets` al construir la cabecera.
--   * missions-cron lo valida con `verify_cron_secret(token)`.
--
-- Requiere las extensiones pg_cron y pg_net habilitadas en el proyecto.

do $vaultblock$
begin
  if not exists (select 1 from vault.secrets where name = 'missions_cron_secret') then
    perform vault.create_secret(
      encode(extensions.gen_random_bytes(32), 'hex'),
      'missions_cron_secret',
      'Bearer token for missions-cron (leido por pg_cron y validado por verify_cron_secret)'
    );
  end if;
end;
$vaultblock$;

create or replace function public.verify_cron_secret(p_token text)
returns boolean
language sql
security definer
set search_path = public, vault
as $fn$
  select coalesce(
    (select decrypted_secret = p_token
       from vault.decrypted_secrets
      where name = 'missions_cron_secret'),
    false
  );
$fn$;

revoke all on function public.verify_cron_secret(text) from public, anon, authenticated;
grant execute on function public.verify_cron_secret(text) to service_role;

do $unsched$
begin
  if exists (select 1 from cron.job where jobname = 'rotate-daily-missions') then
    perform cron.unschedule('rotate-daily-missions');
  end if;
end;
$unsched$;

select cron.schedule(
  'rotate-daily-missions',
  '5 0 * * *',
  $job$
  select net.http_post(
    url := 'https://sipiumfdpvnszthykyog.supabase.co/functions/v1/missions-cron',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'missions_cron_secret')
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 30000
  );
  $job$
);
