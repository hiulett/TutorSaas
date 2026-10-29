-- P-14 (#99): registro de uso y coste de IA en llm-proxy.
--
-- Objetivo: medir coste real por usuario/dia/sesion sin guardar texto de
-- conversaciones. La tabla ya existia (init 20260717000000) pero nunca se
-- escribio: 0 filas y sin columnas para accion, audio ni estado.
--
-- Tarifas usadas para `cost_estimate_usd` (configurables por secreto de la
-- Edge Function, ver docs/OPERATIONS.md):
--   AI_PRICE_INPUT_PER_1M   -> 0.27 USD por 1M tokens de entrada
--   AI_PRICE_OUTPUT_PER_1M  -> 1.10 USD por 1M tokens de salida
--   AI_PRICE_STT_PER_MINUTE -> 0.000667 USD por minuto de audio (Groq)
-- Es una ESTIMACION, no una factura: no sustituye al panel del proveedor.

-- 1. Columnas nuevas.
alter table public.ai_usage_logs
  add column if not exists action_code varchar(64),
  add column if not exists audio_seconds numeric(10, 2),
  add column if not exists status varchar(16) not null default 'ok';

-- 2. `cost_usd` pasa a `cost_estimate_usd` (la tabla esta vacia: rename seguro).
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'ai_usage_logs'
      and column_name = 'cost_usd'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'ai_usage_logs'
      and column_name = 'cost_estimate_usd'
  ) then
    alter table public.ai_usage_logs rename column cost_usd to cost_estimate_usd;
  end if;
end $$;

-- 3. Estados permitidos (el proxy escribe ok/error; P-07 anadira no_mana).
alter table public.ai_usage_logs
  drop constraint if exists ai_usage_logs_status_check;
alter table public.ai_usage_logs
  add constraint ai_usage_logs_status_check
  check (status in ('ok', 'error', 'timeout', 'rate_limited', 'no_mana', 'blocked'));

comment on column public.ai_usage_logs.cost_estimate_usd is
  'Coste estimado en USD (tarifas en docs/OPERATIONS.md). No es una factura.';
comment on column public.ai_usage_logs.audio_seconds is
  'Duracion del audio transcrito, en segundos. NULL si el proveedor no la devuelve.';
comment on column public.ai_usage_logs.action_code is
  'Accion de IA (ai_action_costs.action_code o codigo de evaluacion gratuita).';

-- 4. Indices para las consultas de coste.
create index if not exists idx_ai_usage_action_created
  on public.ai_usage_logs (action_code, created_at desc);
create index if not exists idx_ai_usage_conversation
  on public.ai_usage_logs (conversation_id)
  where conversation_id is not null;

-- 5. Vistas de coste (security_invoker: aplica la RLS de la tabla, cada
--    usuario ve solo sus filas; el service role ve todas).
create or replace view public.ai_usage_daily
with (security_invoker = true) as
select
  user_id,
  (created_at at time zone 'UTC')::date as day,
  action_code,
  model,
  count(*)                                as calls,
  coalesce(sum(input_tokens), 0)::bigint  as tokens_in,
  coalesce(sum(output_tokens), 0)::bigint as tokens_out,
  coalesce(sum(audio_seconds), 0)         as audio_seconds,
  coalesce(sum(cost_estimate_usd), 0)     as cost_estimate_usd
from public.ai_usage_logs
group by 1, 2, 3, 4;

create or replace view public.ai_usage_by_session
with (security_invoker = true) as
select
  user_id,
  conversation_id,
  min(created_at)                         as started_at,
  max(created_at)                         as last_at,
  count(*)                                as calls,
  coalesce(sum(input_tokens), 0)::bigint  as tokens_in,
  coalesce(sum(output_tokens), 0)::bigint as tokens_out,
  coalesce(sum(audio_seconds), 0)         as audio_seconds,
  coalesce(sum(cost_estimate_usd), 0)     as cost_estimate_usd
from public.ai_usage_logs
where conversation_id is not null
group by 1, 2;

revoke all on public.ai_usage_daily from anon, authenticated;
revoke all on public.ai_usage_by_session from anon, authenticated;
grant select on public.ai_usage_daily to authenticated;
grant select on public.ai_usage_by_session to authenticated;
