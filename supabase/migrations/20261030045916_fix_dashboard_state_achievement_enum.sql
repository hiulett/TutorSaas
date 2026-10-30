-- Fix: `get_dashboard_state` comparaba `achievements.condition_type` con literales
-- que no existen en el enum `achievement_condition`. El enum tiene
-- `streak_days` y `vocabulary_count`, pero la función usaba `'streak'` y
-- `'vocabulary'`, lo que lanzaba `22P02 invalid input value for enum` en cada
-- carga del dashboard (el usuario veía el error en pantalla).
--
-- Además se completan los tipos que el enum define y la función ignoraba
-- (xp_total, minutes_total, scenarios_completed, pronunciation); sin datos
-- disponibles se quedan en 0, no se inventan.

create or replace function public.get_dashboard_state(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_progress jsonb;
  v_achievements jsonb;
  v_streak integer;
  v_languages integer;
  v_conversations integer;
  v_messages integer;
  v_vocabulary integer;
  v_xp integer;
  v_minutes integer;
  v_scenarios integer;
  v_pronunciation integer;
begin
  if coalesce(auth.role(), '') <> 'service_role'
     and (auth.uid() is null or auth.uid() <> p_user_id) then
    raise exception 'No autorizado';
  end if;

  select coalesce(max(current_streak), 0), count(distinct language_id),
         coalesce(max(xp_points), 0), coalesce(max(total_minutes), 0)
    into v_streak, v_languages, v_xp, v_minutes
    from public.user_language_profiles
   where user_id = p_user_id;

  select count(*) into v_conversations from public.conversations where user_id = p_user_id;

  select count(*) into v_messages
    from public.messages m
    join public.conversations c on c.id = m.conversation_id
   where c.user_id = p_user_id and coalesce(m.role, m.sender_role) = 'user';

  select count(*) into v_vocabulary from public.user_vocabulary where user_id = p_user_id;

  select count(distinct lesson_id) into v_scenarios
    from public.lesson_progress
   where user_id = p_user_id and status = 'passed';

  select coalesce(round(phonetic_clarity_score)::int, 0) into v_pronunciation
    from public.speech_dna_metrics
   where user_id = p_user_id
   limit 1;
  v_pronunciation := coalesce(v_pronunciation, 0);

  select jsonb_build_object(
    'xp', coalesce(p.xp_points, 0),
    'streak', coalesce(p.current_streak, 0),
    'last_practice_date', p.last_practice_date,
    'level', coalesce(l.name, 'Principiante'),
    'level_code', coalesce(l.code, 'A1'),
    'game_rank', case
      when p.game_rank is not null and p.game_rank <> '' then p.game_rank
      else case coalesce(l.code, 'A1')
        when 'PRE-A1' then 'F' when 'A1' then 'E' when 'A2' then 'D'
        when 'B1' then 'C' when 'B2' then 'B' when 'C1' then 'A' when 'C2' then 'S'
        else 'E' end
    end,
    'language', coalesce(lang.name, 'Ingl' || chr(233) || 's'),
    'language_emoji', coalesce(lang.flag_emoji, chr(127482) || chr(127480)),
    'equipped_title_code', coalesce(p.equipped_title_code, 'oido_halcon_abismo_c')
  )
  into v_progress
  from public.user_language_profiles p
  left join public.cefr_levels l on l.id = p.cefr_level_id
  left join public.languages lang on lang.id = p.language_id
  where p.user_id = p_user_id
  limit 1;

  if v_progress is null then
    v_progress := jsonb_build_object(
      'xp', 0, 'streak', 0, 'last_practice_date', null,
      'level', 'Principiante', 'level_code', 'A1', 'game_rank', 'E',
      'language', 'Ingl' || chr(233) || 's',
      'language_emoji', chr(127482) || chr(127480),
      'equipped_title_code', 'oido_halcon_abismo_c'
    );
  end if;

  insert into public.user_achievements (user_id, achievement_id)
  select p_user_id, a.id
    from public.achievements a
   where (case a.condition_type
            when 'streak_days' then v_streak
            when 'conversations' then v_conversations
            when 'messages' then v_messages
            when 'languages' then v_languages
            when 'vocabulary_count' then v_vocabulary
            when 'xp_total' then v_xp
            when 'minutes_total' then v_minutes
            when 'scenarios_completed' then v_scenarios
            when 'pronunciation' then v_pronunciation
            else 0
          end) >= coalesce(a.condition_value, 1)
  on conflict (user_id, achievement_id) do nothing;

  select coalesce(jsonb_agg(jsonb_build_object(
      'id', s.id, 'code', s.code, 'title', s.title,
      'description', coalesce(s.description, ''),
      'tier', coalesce(s.icon_url, 'bronze'),
      'xp_reward', coalesce(s.xp_reward, 0),
      'current_value', s.current_value,
      'target_value', coalesce(s.condition_value, 1),
      'is_unlocked', s.unlocked,
      'progress', s.current_value::numeric / greatest(coalesce(s.condition_value, 1), 1)
    ) order by s.unlocked desc, s.id), '[]'::jsonb)
  into v_achievements
  from (
    select a.*, (ua.achievement_id is not null) as unlocked,
      case a.condition_type
        when 'streak_days' then v_streak
        when 'conversations' then v_conversations
        when 'messages' then v_messages
        when 'languages' then v_languages
        when 'vocabulary_count' then v_vocabulary
        when 'xp_total' then v_xp
        when 'minutes_total' then v_minutes
        when 'scenarios_completed' then v_scenarios
        when 'pronunciation' then v_pronunciation
        else 0
      end as current_value
    from public.achievements a
    left join public.user_achievements ua on ua.achievement_id = a.id and ua.user_id = p_user_id
  ) s;

  return jsonb_build_object('progress', v_progress, 'achievements', v_achievements);
end;
$$;
