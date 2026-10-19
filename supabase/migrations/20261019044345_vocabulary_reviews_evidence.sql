-- Issue #74: sin historial de repasos no se puede demostrar retención.
--
-- Se añade una tabla append-only y se mueve el SM-2 al servidor, de modo que
-- la evidencia no dependa de lo que el cliente afirme que hizo.
--
-- `delayed_retrieval` marca los repasos correctos recuperados tras ≥ 7 días:
-- esa es la señal de retención (repetir al instante no demuestra nada).

create table if not exists public.vocabulary_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  vocabulary_id uuid,
  quality numeric not null,
  interval_before integer,
  interval_after integer,
  days_since_last numeric,
  delayed_retrieval boolean not null default false,
  reviewed_at timestamptz not null default now()
);

create index if not exists vocabulary_reviews_user_idx
  on public.vocabulary_reviews (user_id, reviewed_at desc);

alter table public.vocabulary_reviews enable row level security;

drop policy if exists reviews_select_own on public.vocabulary_reviews;
create policy reviews_select_own on public.vocabulary_reviews
  for select to authenticated using (auth.uid() = user_id);

-- Solo se escribe por la RPC: insertar a mano sería falsear la evidencia.
revoke insert, update, delete on public.vocabulary_reviews from authenticated, anon;

create or replace function public.record_vocabulary_review(
  p_vocabulary_id uuid,
  p_quality numeric
)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_row public.user_vocabulary%rowtype;
  v_quality numeric;
  v_ease numeric;
  v_interval integer;
  v_seen integer;
  v_correct integer;
  v_days numeric;
  v_delayed boolean := false;
  v_mastered boolean;
  v_next timestamptz;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if p_vocabulary_id is null or p_quality is null then
    return jsonb_build_object('ok', false, 'reason', 'missing_args');
  end if;

  select * into v_row
    from public.user_vocabulary
   where user_id = v_uid and vocabulary_id = p_vocabulary_id
   limit 1;
  if not found then
    return jsonb_build_object('ok', false, 'reason', 'not_found');
  end if;

  v_quality := least(5, greatest(0, p_quality));
  v_ease := coalesce(v_row.ease_factor, 2.5);
  v_interval := coalesce(v_row.interval_days, 1);
  v_seen := coalesce(v_row.times_seen, 1);
  v_correct := coalesce(v_row.times_correct, 1);
  v_days := case when v_row.last_seen_at is null then null
                 else extract(epoch from (now() - v_row.last_seen_at)) / 86400.0 end;
  v_delayed := v_days is not null and v_days >= 7 and v_quality >= 3;

  -- SM-2 (misma fórmula que tenía el cliente).
  v_ease := v_ease + (0.1 - (5.0 - v_quality) * (0.08 + (5.0 - v_quality) * 0.02));
  if v_ease < 1.3 then v_ease := 1.3; end if;

  if v_quality < 3 then
    v_interval := 1;
  else
    v_correct := v_correct + 1;
    if v_interval = 1 then
      v_interval := 6;
    else
      v_interval := round(v_interval * v_ease);
    end if;
  end if;

  v_seen := v_seen + 1;
  v_mastered := v_correct >= 3 and v_interval >= 14;
  v_next := now() + (v_interval || ' days')::interval;

  update public.user_vocabulary set
    ease_factor = v_ease,
    interval_days = v_interval,
    times_seen = v_seen,
    times_correct = v_correct,
    is_mastered = v_mastered,
    next_review_at = v_next,
    last_seen_at = now(),
    last_reviewed_at = now(),
    updated_at = now()
   where id = v_row.id;

  insert into public.vocabulary_reviews (
    user_id, vocabulary_id, quality, interval_before, interval_after,
    days_since_last, delayed_retrieval
  ) values (
    v_uid, p_vocabulary_id, v_quality, v_row.interval_days, v_interval,
    v_days, v_delayed
  );

  return jsonb_build_object(
    'ok', true,
    'delayed_retrieval', v_delayed,
    'interval_after', v_interval,
    'mastered', v_mastered
  );
end;
$function$;

revoke all on function public.record_vocabulary_review(uuid, numeric) from public, anon;
grant execute on function public.record_vocabulary_review(uuid, numeric) to authenticated;
