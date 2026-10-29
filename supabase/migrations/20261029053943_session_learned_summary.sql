-- Issue #113 (P-28): el resumen de sesion mostraba cifras fijas (fluidez y
-- precision calculadas con formulas locales) y no decia QUE se habia aprendido.
--
-- get_session_learned_summary(conversation, since) devuelve, en una sola
-- llamada y solo para el dueno de la conversacion:
--   * palabras nuevas/repasadas dentro de la ventana de la sesion,
--   * correcciones registradas en los mensajes de la sesion,
--   * objetivos cumplidos (conversacion) y total del escenario si es resoluble,
--   * foco recomendado con evidencia real (error_type repetido > foco del
--     Oráculo > null; nunca se inventa),
--   * metricas foneticas reales del usuario (pueden ser null).
--
-- La ventana la aporta el cliente (`p_since`) porque `conversations` se reutiliza
-- por escenario: `started_at` puede ser de hace semanas y no marca la sesion.
-- El cliente solo puede leer SUS datos: la funcion valida auth.uid() contra
-- conversations.user_id y usa SECURITY DEFINER con search_path fijo.

create or replace function public.get_session_learned_summary(
  p_conversation_id uuid,
  p_since timestamptz default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = 'public'
as $function$
declare
  v_uid uuid := auth.uid();
  v_conv public.conversations%rowtype;
  v_since timestamptz;
  v_words jsonb;
  v_new_words integer := 0;
  v_reviewed_words integer := 0;
  v_corrections jsonb;
  v_goals jsonb;
  v_goals_task integer := 0;
  v_goals_total integer;
  v_focus text;
  v_focus_source text;
  v_clarity integer;
  v_wpm integer;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  select * into v_conv
    from public.conversations
   where id = p_conversation_id
     and user_id = v_uid
     and deleted_at is null;

  if not found then
    raise exception 'Sesion no valida';
  end if;

  -- Ventana de la sesion: la que envia el cliente, acotada a la creacion de la
  -- conversacion. Sin dato, las ultimas 3 horas (una sesion de practica normal).
  v_since := coalesce(p_since, now() - interval '3 hours');
  if v_conv.started_at is not null and v_since < v_conv.started_at then
    v_since := v_conv.started_at;
  end if;

  -- ── Palabras de la sesion ─────────────────────────────────────────────────
  select count(*) filter (where uv.created_at >= v_since),
         count(*) filter (where uv.created_at < v_since)
    into v_new_words, v_reviewed_words
    from public.user_vocabulary uv
   where uv.user_id = v_uid
     and uv.deleted_at is null
     and (uv.last_seen_at >= v_since or uv.created_at >= v_since);

  select coalesce(jsonb_agg(s.row_obj order by s.seen_at desc), '[]'::jsonb)
    into v_words
    from (
      select jsonb_build_object(
               'vocabulary_id', uv.vocabulary_id,
               'word', coalesce(nullif(btrim(uv.word), ''), vi.word),
               'translation', coalesce(nullif(btrim(uv.translation), ''), vi.translation),
               'is_new', (uv.created_at >= v_since),
               'mastered', coalesce(uv.is_mastered, false),
               'interval_days', coalesce(uv.interval_days, 1)
             ) as row_obj,
             coalesce(uv.last_seen_at, uv.created_at) as seen_at
        from public.user_vocabulary uv
        left join public.vocabulary_items vi on vi.id = uv.vocabulary_id
       where uv.user_id = v_uid
         and uv.deleted_at is null
         and (uv.last_seen_at >= v_since or uv.created_at >= v_since)
       order by coalesce(uv.last_seen_at, uv.created_at) desc
       limit 3
    ) s;

  -- ── Correcciones de la sesion (P-29 las escribe en `corrections`) ─────────
  select coalesce(jsonb_agg(s.row_obj order by s.at desc), '[]'::jsonb)
    into v_corrections
    from (
      select jsonb_build_object(
               'original', c.original_text,
               'corrected', c.corrected_text,
               'explanation', c.explanation,
               'error_type', c.error_type
             ) as row_obj,
             coalesce(c.updated_at, m.created_at) as at
        from public.corrections c
        join public.messages m on m.id = c.message_id
       where m.conversation_id = p_conversation_id
         and coalesce(c.updated_at, m.created_at) >= v_since
         and nullif(btrim(c.original_text), '') is not null
       order by coalesce(c.updated_at, m.created_at) desc
       limit 3
    ) s;

  -- ── Objetivos cumplidos en esta conversacion ──────────────────────────────
  select coalesce(jsonb_agg(g.goal_text order by g.completed_at), '[]'::jsonb),
         count(*)
    into v_goals, v_goals_task
    from public.user_scenario_goals g
   where g.user_id = v_uid
     and g.conversation_id = p_conversation_id
     and g.is_completed;

  -- Total de metas del escenario solo si `scenario_id` es resoluble en BD
  -- (el catalogo Dart usa claves de texto; en ese caso el cliente usa el
  -- catalogo, que es la fuente curricular).
  select count(*)
    into v_goals_total
    from public.scenario_goals sg
   where sg.scenario_id::text = v_conv.scenario_id;

  if coalesce(v_goals_total, 0) = 0 then
    v_goals_total := null;
  end if;

  -- ── Foco recomendado: solo con evidencia guardada ─────────────────────────
  select c.error_type
    into v_focus
    from public.corrections c
    join public.messages m on m.id = c.message_id
   where m.conversation_id = p_conversation_id
     and nullif(btrim(c.error_type), '') is not null
   group by c.error_type
   order by count(*) desc
   limit 1;

  if v_focus is not null then
    v_focus_source := 'error_type';
  else
    select nullif(btrim(p.placement_recommended_focus), '')
      into v_focus
      from public.user_language_profiles p
     where p.user_id = v_uid
     order by p.updated_at desc nulls last
     limit 1;

    if v_focus is not null then
      v_focus_source := 'placement';
    end if;
  end if;

  -- ── Metricas foneticas reales (ultima medicion, no de esta sesion) ────────
  select sdm.phonetic_clarity_score, sdm.speaking_wpm
    into v_clarity, v_wpm
    from public.speech_dna_metrics sdm
   where sdm.user_id = v_uid
   order by sdm.updated_at desc nulls last
   limit 1;

  return jsonb_build_object(
    'conversation_id', p_conversation_id,
    'since', v_since,
    'words', v_words,
    'new_words', v_new_words,
    'reviewed_words', v_reviewed_words,
    'corrections', v_corrections,
    'goals', v_goals,
    'goals_completed', v_goals_task,
    'goals_total', v_goals_total,
    'focus', case
      when v_focus is null then null
      else jsonb_build_object('text', v_focus, 'source', v_focus_source)
    end,
    'metrics', jsonb_build_object(
      'phonetic_clarity', v_clarity,
      'wpm', v_wpm
    )
  );
end;
$function$;

revoke all on function public.get_session_learned_summary(uuid, timestamptz) from public, anon;
grant execute on function public.get_session_learned_summary(uuid, timestamptz) to authenticated;

comment on function public.get_session_learned_summary(uuid, timestamptz) is
  'P-28: resumen real de aprendizaje de una sesion (palabras, correcciones, metas, foco). Solo el dueno de la conversacion.';
