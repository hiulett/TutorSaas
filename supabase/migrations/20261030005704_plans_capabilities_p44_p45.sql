-- P-44 (#129) / P-45 (#130) — valor por capacidad y prueba gratuita.
--
-- Decisiones de producto aplicadas (no se renegocian en este cambio):
--   * DIVINO se retira: `is_active = false`. La fila NO se borra porque
--     `user_subscriptions` y `payments` la referencian.
--   * NOBLE y REALEZA se diferencian por CAPACIDAD, no solo por volumen de
--     maná:
--       - NOBLE   → informe semanal con 4 semanas de historial + trial 7 días
--       - REALEZA → informe semanal con 52 semanas + títulos/auras exclusivos
--   * El trial real vive en Play Console y RevenueCat. `trial_days` es solo lo
--     que la app puede prometer y DEBE coincidir con Play; si Play no lo
--     ofrece, vale 0 (ver docs/runbooks/TRIAL_NOBLE_P45.md).
--
-- Enforcement en servidor (no solo texto en el paywall):
--   * `get_weekly_report` respeta `subscription_plans.weekly_report_weeks`.
--   * `purchase_cosmetic` / `craft_cosmetic` respetan
--     `cosmetic_catalog.min_plan`.

-- ── 1. Columnas de capacidad ────────────────────────────────────────────────
alter table public.subscription_plans
  add column if not exists trial_days integer not null default 0,
  add column if not exists weekly_report_weeks integer not null default 1,
  add column if not exists tier integer not null default 0;

alter table public.subscription_plans
  drop constraint if exists subscription_plans_trial_days_range;
alter table public.subscription_plans
  add constraint subscription_plans_trial_days_range
  check (trial_days >= 0 and trial_days <= 30);

alter table public.subscription_plans
  drop constraint if exists subscription_plans_weekly_report_weeks_range;
alter table public.subscription_plans
  add constraint subscription_plans_weekly_report_weeks_range
  check (weekly_report_weeks >= 1 and weekly_report_weeks <= 52);

alter table public.cosmetic_catalog
  add column if not exists min_plan text;

alter table public.cosmetic_catalog
  drop constraint if exists cosmetic_catalog_min_plan_check;
alter table public.cosmetic_catalog
  add constraint cosmetic_catalog_min_plan_check
  check (min_plan is null or length(trim(min_plan)) > 0);

comment on column public.subscription_plans.trial_days is
  'P-45 (#130): días de prueba gratuita que la app puede anunciar. 0 = sin trial. Debe coincidir con la oferta de Play Console/RevenueCat.';
comment on column public.subscription_plans.weekly_report_weeks is
  'P-44 (#129): semanas de historial visibles en el informe semanal (get_weekly_report).';
comment on column public.subscription_plans.tier is
  'P-44 (#129): rango de capacidad del plan (0 plebeyo, 1 noble, 2 realeza). Lo usa cosmetic_catalog.min_plan.';
comment on column public.cosmetic_catalog.min_plan is
  'P-44 (#129): plan mínimo para comprar/craftear el cosmético (null = cualquiera). Se valida en purchase_cosmetic y craft_cosmetic.';

-- ── 2. Reglas reutilizables ─────────────────────────────────────────────────
create or replace function public.plan_tier(p_plan_id text)
returns integer
language sql
stable
set search_path = public
as $fn$
  select coalesce(
    (select sp.tier from public.subscription_plans sp where sp.id = p_plan_id),
    0
  );
$fn$;

create or replace function public.effective_plan_id(p_user_id uuid)
returns text
language sql
stable
security definer
set search_path = public
as $fn$
  select coalesce(
    (
      select us.plan_id
        from public.user_subscriptions us
        join public.subscription_plans sp on sp.id = us.plan_id
       where us.user_id = p_user_id
         and us.status::text in ('active', 'in_grace')
         and (us.period_end is null or us.period_end > now())
       limit 1
    ),
    'plebeyo'
  );
$fn$;

-- `true` si el usuario autenticado tiene al menos el plan pedido.
create or replace function public.has_plan_tier(p_min_plan text)
returns boolean
language sql
stable
security definer
set search_path = public
as $fn$
  select public.plan_tier(public.effective_plan_id(auth.uid()))
         >= public.plan_tier(p_min_plan);
$fn$;

create or replace function public.plan_weekly_report_weeks(p_user_id uuid)
returns integer
language sql
stable
security definer
set search_path = public
as $fn$
  select coalesce(
    (
      select sp.weekly_report_weeks
        from public.subscription_plans sp
       where sp.id = public.effective_plan_id(p_user_id)
    ),
    1
  );
$fn$;

revoke all on function public.plan_tier(text) from public, anon;
revoke all on function public.effective_plan_id(uuid) from public, anon;
revoke all on function public.has_plan_tier(text) from public, anon;
revoke all on function public.plan_weekly_report_weeks(uuid) from public, anon;
grant execute on function public.plan_tier(text) to authenticated, service_role;
grant execute on function public.effective_plan_id(uuid) to service_role;
grant execute on function public.has_plan_tier(text) to service_role;
grant execute on function public.plan_weekly_report_weeks(uuid) to service_role;

-- ── 3. Informe semanal: historial por plan ──────────────────────────────────
create or replace function public.get_weekly_report(
  p_week_offset integer default 0,
  p_tz_offset_minutes integer default 0,
  p_language_id integer default 1
)
returns jsonb
language plpgsql
stable security definer
set search_path = public
as $function$
declare
  v_user uuid := auth.uid();
  v_offset integer := greatest(-840, least(coalesce(p_tz_offset_minutes, 0), 840));
  v_week integer := greatest(0, least(coalesce(p_week_offset, 0), 52));
  v_weeks integer;
  v_locked boolean;
  v_start date;
  v_end date;
  v_start_ts timestamptz;
  v_end_ts timestamptz;
  v_level text;
  v_level_name text;
  v_rank text;
  v_assessed boolean := false;
begin
  if v_user is null then
    raise exception 'No autorizado';
  end if;

  -- P-44 (#129): el historial disponible lo decide el plan (servidor).
  v_weeks := public.plan_weekly_report_weeks(v_user);
  v_locked := v_week > (v_weeks - 1);

  v_start := date_trunc('week', (now() + make_interval(mins => v_offset))::date)::date
             - (v_week * 7);
  v_end := v_start + 6;
  v_start_ts := (v_start::timestamp - make_interval(mins => v_offset)) at time zone 'UTC';
  v_end_ts := ((v_end + 1)::timestamp - make_interval(mins => v_offset)) at time zone 'UTC';

  -- Semana fuera del historial del plan: se responde el marco (fechas y
  -- límite) pero NUNCA los datos.
  if v_locked then
    return jsonb_build_object(
      'week_offset', v_week,
      'start_date', v_start,
      'end_date', v_end,
      'language_id', p_language_id,
      'has_data', false,
      'locked', true,
      'history_weeks', v_weeks,
      'new_words', 0,
      'words_reviewed', 0,
      'words_mastered', 0,
      'corrections', 0,
      'top_error_type', null,
      'lessons_completed', 0,
      'minutes', 0,
      'sessions', 0,
      'practice_days', 0,
      'level', null,
      'level_name', null,
      'level_assessed', false,
      'game_rank', null,
      'previous', jsonb_build_object(
        'new_words', 0,
        'corrections', 0,
        'lessons_completed', 0,
        'minutes', 0
      ),
      'server_time', now()
    );
  end if;

  select upper(cl.code), cl.name, ulp.game_rank,
         (ulp.placement_assessed_at is not null)
    into v_level, v_level_name, v_rank, v_assessed
    from public.user_language_profiles ulp
    left join public.cefr_levels cl on cl.id = ulp.cefr_level_id
   where ulp.user_id = v_user
   order by (ulp.language_id = coalesce(p_language_id, 1)) desc, ulp.language_id
   limit 1;

  return (
    with bounds as (
      select v_start as cur_start_day, v_end as cur_end_day,
             v_start_ts as cur_start_ts, v_end_ts as cur_end_ts,
             v_start - 7 as prev_start_day, v_end - 7 as prev_end_day,
             v_start_ts - interval '7 days' as prev_start_ts,
             v_start_ts as prev_end_ts
    ),
    cur as (
      select
        (select count(*)
           from public.user_vocabulary
          where user_id = v_user and deleted_at is null
            and created_at >= b.cur_start_ts and created_at < b.cur_end_ts) as new_words,
        (select count(*)
           from public.user_vocabulary
          where user_id = v_user and is_mastered
            and last_reviewed_at >= b.cur_start_ts
            and last_reviewed_at < b.cur_end_ts) as words_mastered,
        (select count(distinct vocabulary_id)
           from public.vocabulary_reviews
          where user_id = v_user
            and reviewed_at >= b.cur_start_ts and reviewed_at < b.cur_end_ts) as words_reviewed,
        (select count(*)
           from public.corrections
          where user_id = v_user
            and created_at >= b.cur_start_ts and created_at < b.cur_end_ts) as corrections,
        (select error_type
           from public.corrections
          where user_id = v_user and error_type is not null
            and created_at >= b.cur_start_ts and created_at < b.cur_end_ts
          group by error_type
          order by count(*) desc, error_type
          limit 1) as top_error_type,
        (select count(*)
           from public.lesson_progress
          where user_id = v_user and status = 'passed'
            and completed_at >= b.cur_start_ts and completed_at < b.cur_end_ts) as lessons_completed,
        (select coalesce(sum(minutes), 0)::int
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.cur_start_day and b.cur_end_day) as minutes,
        (select count(*)
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.cur_start_day and b.cur_end_day) as sessions,
        (select count(distinct practiced_on)
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.cur_start_day and b.cur_end_day) as practice_days
      from bounds b
    ),
    prev as (
      select
        (select count(*)
           from public.user_vocabulary
          where user_id = v_user and deleted_at is null
            and created_at >= b.prev_start_ts and created_at < b.prev_end_ts) as new_words,
        (select count(*)
           from public.corrections
          where user_id = v_user
            and created_at >= b.prev_start_ts and created_at < b.prev_end_ts) as corrections,
        (select count(*)
           from public.lesson_progress
          where user_id = v_user and status = 'passed'
            and completed_at >= b.prev_start_ts and completed_at < b.prev_end_ts) as lessons_completed,
        (select coalesce(sum(minutes), 0)::int
           from public.practice_sessions
          where user_id = v_user
            and practiced_on between b.prev_start_day and b.prev_end_day) as minutes
      from bounds b
    )
    select jsonb_build_object(
      'week_offset', v_week,
      'start_date', v_start,
      'end_date', v_end,
      'language_id', p_language_id,
      'has_data', (c.new_words + c.words_reviewed + c.corrections
                   + c.lessons_completed + c.sessions) > 0,
      'locked', false,
      'history_weeks', v_weeks,
      'new_words', c.new_words,
      'words_reviewed', c.words_reviewed,
      'words_mastered', c.words_mastered,
      'corrections', c.corrections,
      'top_error_type', c.top_error_type,
      'lessons_completed', c.lessons_completed,
      'minutes', c.minutes,
      'sessions', c.sessions,
      'practice_days', c.practice_days,
      'level', case when v_assessed then v_level else null end,
      'level_name', case when v_assessed then v_level_name else null end,
      'level_assessed', v_assessed,
      'game_rank', case when v_assessed then nullif(v_rank, '') else null end,
      'previous', jsonb_build_object(
        'new_words', p.new_words,
        'corrections', p.corrections,
        'lessons_completed', p.lessons_completed,
        'minutes', p.minutes
      ),
      'server_time', now()
    )
    from cur c, prev p
  );
end;
$function$;

revoke all on function public.get_weekly_report(integer, integer, integer) from public, anon;
grant execute on function public.get_weekly_report(integer, integer, integer) to authenticated;

comment on function public.get_weekly_report(integer, integer, integer) is
  'P-43 (#128) + P-44 (#129): informe semanal calculado en servidor; las semanas visibles las limita subscription_plans.weekly_report_weeks (locked=true fuera del historial del plan).';

-- ── 4. Cosméticos exclusivos por plan ───────────────────────────────────────
create or replace function public.purchase_cosmetic(
    p_user_id   uuid,
    p_item_id   text,
    p_currency  text default 'gold'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
  v_item     public.cosmetic_catalog%rowtype;
  v_price    integer;
  v_currency text := lower(coalesce(p_currency, 'gold'));
  v_level    integer;
  v_owned    boolean;
  v_move     jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  if v_currency not in ('gold', 'gems') then
    return jsonb_build_object('success', false, 'reason', 'bad_currency');
  end if;

  select * into v_item from public.cosmetic_catalog where id = p_item_id;
  if not found then
    return jsonb_build_object('success', false, 'reason', 'not_found');
  end if;
  if v_item.min_plan is not null and not public.has_plan_tier(v_item.min_plan) then
    return jsonb_build_object('success', false, 'reason', 'plan_required',
      'required_plan', v_item.min_plan);
  end if;
  if v_item.available_from is not null and v_item.available_from > now() then
    return jsonb_build_object('success', false, 'reason', 'not_available');
  end if;
  if v_item.available_to is not null and v_item.available_to < now() then
    return jsonb_build_object('success', false, 'reason', 'not_available');
  end if;

  v_price := case when v_currency = 'gems'
                  then coalesce(v_item.price_gems, 0)
                  else coalesce(v_item.price_gold, 0) end;
  if v_price <= 0 then
    return jsonb_build_object('success', false, 'reason', 'not_purchasable');
  end if;

  select public.economy_level(xp_points) into v_level
    from public.user_language_profiles
   where user_id = p_user_id
   order by language_id
   limit 1;

  if v_level is null then
    return jsonb_build_object('success', false, 'reason', 'no_profile');
  end if;

  if v_level < coalesce(v_item.required_level, 1) then
    return jsonb_build_object('success', false, 'reason', 'level_locked',
      'required_level', v_item.required_level, 'level', v_level);
  end if;

  select exists (
    select 1 from public.player_inventory
     where user_id = p_user_id and item_code = p_item_id
  ) into v_owned;
  if v_owned then
    return jsonb_build_object('success', false, 'reason', 'already_owned');
  end if;

  v_move := public.economy_apply_currency(
    p_user_id, v_currency, -v_price, 'cosmetic:' || p_item_id,
    'cosmetic:' || p_item_id || ':' || v_currency);

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object('success', false,
      'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'required_level', v_item.required_level, 'level', v_level);
  end if;

  insert into public.player_inventory (user_id, item_code, item_type, is_equipped, source)
  values (p_user_id, p_item_id, coalesce(v_item.category, 'cosmetic'), false, 'shop');

  return jsonb_build_object('success', true, 'item_id', p_item_id,
    'item_type', coalesce(v_item.category, 'cosmetic'),
    'price', v_price, 'currency', v_currency,
    'balance', (v_move ->> 'balance')::integer,
    'required_level', v_item.required_level);
end;
$fn$;

revoke all on function public.purchase_cosmetic(uuid, text, text) from public, anon;
grant execute on function public.purchase_cosmetic(uuid, text, text) to authenticated;

create or replace function public.craft_cosmetic(p_user_id uuid, p_item_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
  v_item  public.cosmetic_catalog%rowtype;
  v_owned boolean;
  v_move  jsonb;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'No autorizado';
  end if;

  select * into v_item from public.cosmetic_catalog where id = p_item_id;
  if not found then
    return jsonb_build_object('success', false, 'reason', 'not_found');
  end if;
  if v_item.min_plan is not null and not public.has_plan_tier(v_item.min_plan) then
    return jsonb_build_object('success', false, 'reason', 'plan_required',
      'required_plan', v_item.min_plan);
  end if;
  if coalesce(v_item.craft_cost_fragments, 0) <= 0 then
    return jsonb_build_object('success', false, 'reason', 'not_craftable');
  end if;

  select exists (
    select 1 from public.player_inventory
     where user_id = p_user_id and item_code = p_item_id
  ) into v_owned;
  if v_owned then
    return jsonb_build_object('success', false, 'reason', 'already_owned');
  end if;

  v_move := public.economy_apply_currency(
    p_user_id, 'fragments', -v_item.craft_cost_fragments,
    'craft:' || p_item_id, 'craft:' || p_item_id);

  if (v_move ->> 'ok')::boolean is not true then
    return jsonb_build_object('success', false,
      'reason', coalesce(v_move ->> 'reason', 'insufficient'),
      'cost', v_item.craft_cost_fragments);
  end if;

  insert into public.player_inventory (user_id, item_code, item_type, is_equipped, source)
  values (p_user_id, p_item_id, coalesce(v_item.category, 'cosmetic'), false, 'craft');

  return jsonb_build_object('success', true, 'item_id', p_item_id,
    'item_type', coalesce(v_item.category, 'cosmetic'),
    'cost', v_item.craft_cost_fragments, 'currency', 'fragments',
    'balance', (v_move ->> 'balance')::integer);
end;
$fn$;

revoke all on function public.craft_cosmetic(uuid, text) from public, anon;
grant execute on function public.craft_cosmetic(uuid, text) to authenticated;

-- ── 5. Datos: planes por capacidad (DIVINO fuera del catálogo) ──────────────
update public.subscription_plans
   set tier = 0, trial_days = 0, weekly_report_weeks = 1
 where id = 'plebeyo';

update public.subscription_plans
   set tier = 1, trial_days = 7, weekly_report_weeks = 4
 where id = 'noble';

update public.subscription_plans
   set tier = 2, trial_days = 0, weekly_report_weeks = 52
 where id = 'realeza';

update public.subscription_plans
   set tier = 2, trial_days = 0
 where id = 'divino';

-- Planes heredados (Stripe). Siguen inactivos; el tier solo mantiene la
-- coherencia si alguna suscripción antigua siguiera viva.
update public.subscription_plans set tier = 0 where id = 'free';
update public.subscription_plans set tier = 1 where id = 'monthly';
update public.subscription_plans set tier = 2 where id in ('annual', 'lifetime');

update public.subscription_plans
   set features = jsonb_build_array(
       '3.000 de maná/mes',
       'Tope diario de 200 de maná',
       'Conversación con IA, misiones y ranking',
       'Informe de la semana en curso'
   )
 where id = 'plebeyo';

update public.subscription_plans
   set features = jsonb_build_array(
       '17.000 de maná/mes',
       'Sin tope diario de maná',
       'Informe semanal con 4 semanas de historial',
       'Conversación con IA, misiones y ranking'
   )
 where id = 'noble';

update public.subscription_plans
   set features = jsonb_build_array(
       '20.500 de maná/mes',
       'Sin tope diario de maná',
       'Informe semanal con 52 semanas de historial',
       'Títulos y auras exclusivos de REALEZA',
       'Conversación con IA, misiones y ranking'
   )
 where id = 'realeza';

-- DIVINO se retira del catálogo sin borrar la fila (histórico de compras).
update public.subscription_plans
   set is_active = false,
       trial_days = 0,
       description = 'Plan retirado: sus capacidades se reparten entre NOBLE y REALEZA.'
 where id = 'divino';

-- Títulos/auras exclusivos de REALEZA (enforcement en las RPC de compra).
update public.cosmetic_catalog
   set min_plan = 'realeza'
 where id in ('title_leyenda_viva', 'aura_sombras');
