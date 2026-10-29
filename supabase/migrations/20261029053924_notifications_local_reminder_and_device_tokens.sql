-- Issue #106 (P-21): recordatorio diario local y soporte futuro de push.
--
-- Contexto: `user_settings.notifications_enabled` y `notification_time`
-- existian desde el onboarding pero ninguna pantalla los usaba y no habia
-- forma de elegir dias. Tampoco existia `device_tokens`.
--
-- Cambios:
--   1. user_settings.notification_days: dias ISO del recordatorio (1=lunes).
--   2. device_tokens: tokens de push por dispositivo con RLS de dueno. La
--      tabla se crea vacia; el cliente la poblara cuando se anada FCM.
--
-- Version real registrada por MCP en supabase_migrations.schema_migrations:
--   20261029053924

alter table public.user_settings
  add column if not exists notification_days smallint[] not null
    default '{1,2,3,4,5,6,7}'::smallint[];

comment on column public.user_settings.notification_days is
  'Dias ISO del recordatorio diario (1=lunes ... 7=domingo). Issue #106.';

alter table public.user_settings
  drop constraint if exists user_settings_notification_days_valid;

alter table public.user_settings
  add constraint user_settings_notification_days_valid check (
    array_length(notification_days, 1) between 1 and 7
    and notification_days <@ '{1,2,3,4,5,6,7}'::smallint[]
  );

create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  token text not null,
  platform text not null default 'android' check (platform in ('android')),
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint device_tokens_token_key unique (token)
);

create index if not exists device_tokens_user_idx
  on public.device_tokens (user_id);

comment on table public.device_tokens is
  'Tokens de push por dispositivo. Issue #106: la tabla existe antes que FCM; '
  'el cliente la escribira cuando se anada push remoto.';

alter table public.device_tokens enable row level security;

revoke all on public.device_tokens from anon;
grant select, insert, update, delete on public.device_tokens to authenticated;

drop policy if exists device_tokens_self on public.device_tokens;
create policy device_tokens_self on public.device_tokens
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
