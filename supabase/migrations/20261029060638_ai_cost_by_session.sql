-- P-41 (#126): coste de IA por conversación.
--
-- `ai_usage_logs` (P-14) ya guarda tokens y coste por llamada; faltaba una
-- vista por sesión para medir la meta de reducción sin escribir SQL a mano.
-- `security_invoker` hace que se apliquen las RLS de `ai_usage_logs`
-- (`usage_logs_select_own`), así que cada usuario solo ve sus sesiones.

create or replace view public.ai_cost_by_session
with (security_invoker = true) as
select
  conversation_id,
  user_id,
  min(created_at) as started_at,
  max(created_at) as ended_at,
  count(*) as calls,
  coalesce(sum(input_tokens), 0) as input_tokens,
  coalesce(sum(output_tokens), 0) as output_tokens,
  round(sum(cost_estimate_usd)::numeric, 6) as cost_usd
from public.ai_usage_logs
where conversation_id is not null
group by conversation_id, user_id;

comment on view public.ai_cost_by_session is
  'Coste estimado de IA por conversacion (P-41). security_invoker: respeta las RLS de ai_usage_logs.';

grant select on public.ai_cost_by_session to authenticated;
