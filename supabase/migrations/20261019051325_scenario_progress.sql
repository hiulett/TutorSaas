-- Issue #76: la conversación no dejaba rastro en el mundo.
--
-- Se guarda el resultado por escena y se desbloquea la siguiente solo con
-- éxito. `attempts` permite que el NPC «recuerde» el intento anterior sin
-- volver a llamar al modelo (el resultado se deriva de los objetivos ya
-- evaluados: determinista y sin coste de IA).
--
--   éxito   = objetivos cumplidos == total
--   parcial = ratio >= 0.5
--   fallo   = resto

create table if not exists public.scenario_progress (
  user_id uuid not null references public.users(id) on delete cascade,
  scenario_id text not null,
  last_outcome text not null check (last_outcome in ('success','partial','failure')),
  best_ratio numeric not null default 0,
  attempts integer not null default 1,
  unlocked_next boolean not null default false,
  first_success_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, scenario_id)
);

alter table public.scenario_progress enable row level security;

drop policy if exists scenario_progress_select_own on public.scenario_progress;
create policy scenario_progress_select_own on public.scenario_progress
  for select to authenticated using (auth.uid() = user_id);

-- Solo escribe la RPC: el resultado no puede fabricarse desde el cliente.
revoke insert, update, delete on public.scenario_progress from authenticated, anon;

create or replace function public.record_scenario_outcome(
  p_scenario_id text,
  p_completed integer,
  p_total integer
)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_ratio numeric;
  v_outcome text;
  v_row public.scenario_progress%rowtype;
  v_first_success boolean := false;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if p_scenario_id is null or p_total is null or p_total <= 0 then
    return jsonb_build_object('ok', false, 'reason', 'invalid_args');
  end if;

  v_ratio := least(1, greatest(0, coalesce(p_completed, 0)::numeric / p_total));
  if coalesce(p_completed, 0) >= p_total then
    v_outcome := 'success';
  elsif v_ratio >= 0.5 then
    v_outcome := 'partial';
  else
    v_outcome := 'failure';
  end if;

  select * into v_row from public.scenario_progress
   where user_id = v_uid and scenario_id = p_scenario_id;

  if not found then
    insert into public.scenario_progress (
      user_id, scenario_id, last_outcome, best_ratio, attempts,
      unlocked_next, first_success_at
    ) values (
      v_uid, p_scenario_id, v_outcome, v_ratio, 1,
      v_outcome = 'success',
      case when v_outcome = 'success' then now() else null end
    );
    v_first_success := v_outcome = 'success';
  else
    v_first_success := v_row.first_success_at is null and v_outcome = 'success';
    update public.scenario_progress set
      last_outcome = v_outcome,
      best_ratio = greatest(v_row.best_ratio, v_ratio),
      attempts = v_row.attempts + 1,
      unlocked_next = v_row.unlocked_next or v_outcome = 'success',
      first_success_at = coalesce(v_row.first_success_at,
                                  case when v_outcome = 'success' then now() end),
      updated_at = now()
     where user_id = v_uid and scenario_id = p_scenario_id;
  end if;

  return jsonb_build_object(
    'ok', true,
    'outcome', v_outcome,
    'ratio', v_ratio,
    'first_success', v_first_success
  );
end;
$function$;

revoke all on function public.record_scenario_outcome(text, integer, integer) from public, anon;
grant execute on function public.record_scenario_outcome(text, integer, integer) to authenticated;
