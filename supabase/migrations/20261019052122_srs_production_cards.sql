-- Issue #78: `mastered` se alcanzaba reconociendo la palabra, sin producirla.
--
-- Se separa la evidencia: solo las respuestas de **producción** cuentan para
-- dominar, y se exige un intervalo consolidado:
--
--   mastered = production_correct >= 2 AND interval_days >= 14
--
-- El reconocimiento sigue moviendo el intervalo (SM-2), pero no acredita
-- dominio.

alter table public.user_vocabulary
  add column if not exists production_correct integer not null default 0;

create or replace function public.record_vocabulary_review(
  p_vocabulary_id uuid,
  p_quality numeric,
  p_card_type text default 'recognition'
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
  v_prod integer;
  v_days numeric;
  v_delayed boolean := false;
  v_mastered boolean;
  v_next timestamptz;
  v_type text;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;
  if p_vocabulary_id is null or p_quality is null then
    return jsonb_build_object('ok', false, 'reason', 'missing_args');
  end if;

  v_type := case when p_card_type = 'production' then 'production' else 'recognition' end;

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
  v_prod := coalesce(v_row.production_correct, 0);
  v_days := case when v_row.last_seen_at is null then null
                else extract(epoch from (now() - v_row.last_seen_at)) / 86400.0 end;
  v_delayed := v_days is not null and v_days >= 7 and v_quality >= 3;

  v_ease := v_ease + (0.1 - (5.0 - v_quality) * (0.08 + (5.0 - v_quality) * 0.02));
  if v_ease < 1.3 then v_ease := 1.3; end if;

  if v_quality < 3 then
    v_interval := 1;
  else
    v_correct := v_correct + 1;
    if v_type = 'production' then
      v_prod := v_prod + 1;
    end if;
    if v_interval = 1 then
      v_interval := 6;
    else
      v_interval := round(v_interval * v_ease);
    end if;
  end if;
  v_seen := v_seen + 1;

  v_mastered := v_prod >= 2 and v_interval >= 14;
  v_next := now() + (v_interval || ' days')::interval;

  update public.user_vocabulary set
    ease_factor = v_ease,
    interval_days = v_interval,
    times_seen = v_seen,
    times_correct = v_correct,
    production_correct = v_prod,
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
    'card_type', v_type,
    'delayed_retrieval', v_delayed,
    'interval_after', v_interval,
    'production_correct', v_prod,
    'mastered', v_mastered
  );
end;
$function$;

revoke all on function public.record_vocabulary_review(uuid, numeric, text) from public, anon;
grant execute on function public.record_vocabulary_review(uuid, numeric, text) to authenticated;
