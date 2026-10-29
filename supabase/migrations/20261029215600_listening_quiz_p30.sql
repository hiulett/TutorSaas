-- P-30 (#115) — Comprensión auditiva ("listening quiz").
--
-- Primer tipo de actividad que NO es conversación libre. El audio lo genera el
-- dispositivo con `flutter_tts` (coste de IA: 0). El banco de ítems vive en
-- `listening_exercises` (precomputado, reproducible) y la corrección es
-- exclusivamente del servidor: `submit_listening_attempt` compara las
-- respuestas con `questions[].correct` y persiste el resultado.
--
-- Integraciones que ya existían y se reutilizan sin duplicar lógica:
--   * `lesson_progress` (lesson_id = 'listening:<slug>', skill_focus =
--     'listening') → cuenta en `get_weekly_report` y en la evidencia de
--     aprendizaje. `boss_exam_status` lo ignora porque filtra por prefijo CEFR
--     (`a1_%`, `b1_%`...), así que no infla el jefe de nivel.
--   * `advance_missions_for_user(uid, 'listening_items', aciertos)` → misiones.
--   * `register_practice` → racha, minutos y `daily_stats` con el tiempo real
--     medido por el cliente (una sola vez por ejercicio y día).
--
-- Cómo añadir más ejercicios: insertar en `public.listening_exercises` con el
-- JSON descrito abajo (ver también docs/OPERATIONS.md, sección "Contenido").

-- ---------------------------------------------------------------------------
-- 1. Banco de ítems
-- ---------------------------------------------------------------------------
create table if not exists public.listening_exercises (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  level varchar(10) not null
    check (level in ('PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
  title text not null,
  context text not null default '',
  -- [{ "speaker": "Barista", "text": "Good morning!" }, ...]
  lines jsonb not null default '[]'::jsonb,
  -- [{ "id": "q1", "prompt": "What ...?",
  --    "options": [{"id": "a", "text": "..."}, ...],
  --    "correct": "b", "explanation": "..." }, ...]
  questions jsonb not null default '[]'::jsonb,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint listening_exercises_lines_shape
    check (jsonb_typeof(lines) = 'array' and jsonb_array_length(lines) between 1 and 8),
  constraint listening_exercises_questions_shape
    check (jsonb_typeof(questions) = 'array' and jsonb_array_length(questions) between 1 and 8)
);

create index if not exists listening_exercises_level_idx
  on public.listening_exercises (level, sort_order)
  where is_active;

alter table public.listening_exercises enable row level security;

drop policy if exists listening_exercises_read_active on public.listening_exercises;
create policy listening_exercises_read_active
  on public.listening_exercises
  for select
  to anon, authenticated
  using (is_active);

comment on table public.listening_exercises is
  'P-30 (#115): banco precomputado de ejercicios de comprensión auditiva. Solo lectura desde el cliente; el contenido se edita por SQL Editor/MCP.';

-- ---------------------------------------------------------------------------
-- 2. Intentos (progreso por servidor)
-- ---------------------------------------------------------------------------
create table if not exists public.listening_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  exercise_id uuid not null references public.listening_exercises (id) on delete cascade,
  score integer not null check (score >= 0),
  total integer not null check (total > 0),
  passed boolean not null,
  answers jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists listening_attempts_user_idx
  on public.listening_attempts (user_id, exercise_id, created_at desc);

alter table public.listening_attempts enable row level security;

drop policy if exists listening_attempts_select_own on public.listening_attempts;
create policy listening_attempts_select_own
  on public.listening_attempts
  for select
  to authenticated
  using (auth.uid() = user_id);

comment on table public.listening_attempts is
  'P-30 (#115): intentos de comprensión auditiva. Escritura exclusiva de submit_listening_attempt (SECURITY DEFINER); el cliente no puede insertar ni puntuarse.';

-- ---------------------------------------------------------------------------
-- 3. Corrección + progreso (servidor)
-- ---------------------------------------------------------------------------
create or replace function public.submit_listening_attempt(
  p_exercise_id uuid,
  p_answers jsonb,
  p_minutes integer default 2,
  p_tz_offset_minutes integer default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid := auth.uid();
  v_ex public.listening_exercises%rowtype;
  v_question jsonb;
  v_qid text;
  v_given text;
  v_correct text;
  v_score integer := 0;
  v_total integer := 0;
  v_passed boolean;
  v_results jsonb := '[]'::jsonb;
  v_attempt_id uuid;
  v_advanced integer := 0;
  v_practice jsonb;
  v_minutes integer;
  v_answers jsonb := case
    when jsonb_typeof(coalesce(p_answers, '{}'::jsonb)) = 'object'
      then coalesce(p_answers, '{}'::jsonb)
    else '{}'::jsonb
  end;
begin
  if v_uid is null then
    return jsonb_build_object('ok', false, 'reason', 'unauthorized');
  end if;

  select * into v_ex
    from public.listening_exercises
   where id = p_exercise_id and is_active
   limit 1;

  if not found then
    return jsonb_build_object('ok', false, 'reason', 'exercise_not_found');
  end if;

  v_total := jsonb_array_length(v_ex.questions);
  if v_total <= 0 then
    return jsonb_build_object('ok', false, 'reason', 'exercise_empty');
  end if;

  -- La corrección se hace aquí: el cliente solo envía {question_id: option_id}.
  for v_question in select value from jsonb_array_elements(v_ex.questions) loop
    v_qid := v_question->>'id';
    v_correct := v_question->>'correct';
    v_given := nullif(trim(coalesce(v_answers->>v_qid, '')), '');
    if v_given is not null and v_given = v_correct then
      v_score := v_score + 1;
      v_results := v_results || jsonb_build_array(jsonb_build_object(
        'id', v_qid,
        'correct', true,
        'answer', v_correct,
        'explanation', coalesce(v_question->>'explanation', '')
      ));
    else
      v_results := v_results || jsonb_build_array(jsonb_build_object(
        'id', v_qid,
        'correct', false,
        'answer', v_correct,
        'explanation', coalesce(v_question->>'explanation', '')
      ));
    end if;
  end loop;

  -- Mismo criterio de superación que el resto de lecciones (P-38 / #123).
  v_passed := public.lesson_completion_passed(v_score, v_total);

  insert into public.listening_attempts (
    user_id, exercise_id, score, total, passed, answers
  ) values (
    v_uid, v_ex.id, v_score, v_total, v_passed, v_answers
  ) returning id into v_attempt_id;

  insert into public.lesson_progress (
    user_id, lesson_id, skill_focus, status, completed_at
  ) values (
    v_uid,
    'listening:' || v_ex.slug,
    'listening',
    case when v_passed then 'passed' else 'failed' end,
    now()
  );

  -- Misiones: cada pregunta acertada avanza `listening_items`.
  v_advanced := public.advance_missions_for_user(v_uid, 'listening_items', v_score);

  -- Práctica/racha con el tiempo real medido en el cliente. La clave incluye
  -- día y slug: repetir el mismo ejercicio el mismo día no suma minutos de más.
  v_minutes := greatest(0, least(coalesce(p_minutes, 0), 30));
  v_practice := public.register_practice(
    p_session_id => 'listening:' || v_ex.slug || ':' ||
      to_char(
        now() + make_interval(mins => coalesce(p_tz_offset_minutes, 0)),
        'YYYYMMDD'
      ),
    p_minutes => v_minutes,
    p_objectives => v_score,
    p_tz_offset_minutes => coalesce(p_tz_offset_minutes, 0)
  );

  return jsonb_build_object(
    'ok', true,
    'attempt_id', v_attempt_id,
    'exercise_id', v_ex.id,
    'score', v_score,
    'total', v_total,
    'passed', v_passed,
    'results', v_results,
    'missions_advanced', v_advanced,
    'practice', coalesce(v_practice, '{}'::jsonb)
  );
end;
$function$;

revoke all on function public.submit_listening_attempt(uuid, jsonb, integer, integer) from public;
grant execute on function public.submit_listening_attempt(uuid, jsonb, integer, integer) to authenticated;

comment on function public.submit_listening_attempt(uuid, jsonb, integer, integer) is
  'P-30 (#115): corrige un intento de comprensión auditiva, escribe listening_attempts + lesson_progress, avanza la misión listening_items y registra práctica. Única fuente de puntuación.';

-- ---------------------------------------------------------------------------
-- 4. Misión: nuevo objective_type tracked por el servidor
-- ---------------------------------------------------------------------------
create or replace function public.mission_objective_is_server_tracked(p_objective text)
returns boolean
language sql
immutable
as $function$
  select coalesce(p_objective = any (array[
    'speak_minutes',
    'conversation_turns',
    'vocab_words',
    'sessions',
    'practice_session',
    'listening_items'
  ]), false);
$function$;

insert into public.mission_templates (
  mission_type, title, description, objective_type, target_value,
  xp_reward, gem_reward, min_cefr_level, is_active, cooldown_hours
)
select
  'daily',
  'El Oído Atento',
  'Acierta 3 preguntas de comprensión auditiva en la Ruta.',
  'listening_items',
  3,
  45,
  5,
  'A1',
  true,
  0
where not exists (
  select 1 from public.mission_templates where title = 'El Oído Atento'
);

insert into public.mission_templates (
  mission_type, title, description, objective_type, target_value,
  xp_reward, gem_reward, min_cefr_level, is_active, cooldown_hours
)
select
  'weekly',
  'Cinco Escuchas',
  'Acierta 5 preguntas de comprensión auditiva esta semana.',
  'listening_items',
  5,
  120,
  20,
  'A2',
  true,
  0
where not exists (
  select 1 from public.mission_templates where title = 'Cinco Escuchas'
);

-- ---------------------------------------------------------------------------
-- 5. Contenido inicial (3 ejercicios reales, niveles A1/A2/B1)
-- ---------------------------------------------------------------------------
insert into public.listening_exercises (slug, level, title, context, lines, questions, sort_order)
values
(
  'a1_coffee_to_go',
  'A1',
  'Coffee to go',
  'You are at a busy coffee shop. Listen to the order and answer.',
  '[
    {"speaker": "Barista", "text": "Good morning! What can I get for you today?"},
    {"speaker": "Customer", "text": "Hi! Can I have a flat white, please? To take away."},
    {"speaker": "Barista", "text": "Sure. Small or large?"},
    {"speaker": "Customer", "text": "Large, please. And how much is that?"},
    {"speaker": "Barista", "text": "That is four pounds twenty, please."}
  ]'::jsonb,
  '[
    {
      "id": "q1",
      "prompt": "What does the customer order?",
      "options": [
        {"id": "a", "text": "A latte"},
        {"id": "b", "text": "A filter coffee"},
        {"id": "c", "text": "A flat white"}
      ],
      "correct": "c",
      "explanation": "The customer says: \"Can I have a flat white, please?\""
    },
    {
      "id": "q2",
      "prompt": "What size does the customer choose?",
      "options": [
        {"id": "a", "text": "Small"},
        {"id": "b", "text": "Large"},
        {"id": "c", "text": "Medium"}
      ],
      "correct": "b",
      "explanation": "The customer answers \"Large, please\" after the barista asks about size."
    },
    {
      "id": "q3",
      "prompt": "How much does the coffee cost?",
      "options": [
        {"id": "a", "text": "Three pounds twenty"},
        {"id": "b", "text": "Four pounds twenty"},
        {"id": "c", "text": "Four pounds twelve"}
      ],
      "correct": "b",
      "explanation": "The barista says \"That is four pounds twenty\"."
    }
  ]'::jsonb,
  10
),
(
  'a2_delayed_train',
  'A2',
  'The delayed train',
  'You are at a train station. Listen to the announcement and the conversation.',
  '[
    {"speaker": "Announcer", "text": "Good afternoon, passengers. The three fifteen train to Bristol is delayed by twenty minutes because of a signal failure."},
    {"speaker": "Passenger", "text": "Excuse me, did they say twenty minutes?"},
    {"speaker": "Staff", "text": "Yes, twenty minutes. It will leave from platform six instead of platform two."}
  ]'::jsonb,
  '[
    {
      "id": "q1",
      "prompt": "Which train is delayed?",
      "options": [
        {"id": "a", "text": "The 3:15 train to Bristol"},
        {"id": "b", "text": "The 3:50 train to Bristol"},
        {"id": "c", "text": "The 3:15 train to Brighton"}
      ],
      "correct": "a",
      "explanation": "The announcement names the three fifteen train to Bristol."
    },
    {
      "id": "q2",
      "prompt": "Why is the train delayed?",
      "options": [
        {"id": "a", "text": "Bad weather"},
        {"id": "b", "text": "A signal failure"},
        {"id": "c", "text": "A broken engine"}
      ],
      "correct": "b",
      "explanation": "The announcer says it is delayed \"because of a signal failure\"."
    },
    {
      "id": "q3",
      "prompt": "Which platform will the train leave from?",
      "options": [
        {"id": "a", "text": "Platform two"},
        {"id": "b", "text": "Platform six"},
        {"id": "c", "text": "Platform twelve"}
      ],
      "correct": "b",
      "explanation": "The staff member says it will leave from platform six instead of platform two."
    }
  ]'::jsonb,
  10
),
(
  'b1_office_voicemail',
  'B1',
  'Voicemail from the office',
  'You are at work. Listen to a voicemail from a colleague and answer.',
  '[
    {"speaker": "Marta", "text": "Hi, it is Marta from the design team. I am calling about tomorrow''s client meeting. It has been moved from nine to half past ten, and it is now in room four B, not the big conference room. Could you bring the printed mock-ups? Also, please send me the updated budget before six today. Thanks!"}
  ]'::jsonb,
  '[
    {
      "id": "q1",
      "prompt": "Why is Marta calling?",
      "options": [
        {"id": "a", "text": "To change the details of a meeting"},
        {"id": "b", "text": "To cancel a meeting"},
        {"id": "c", "text": "To book a conference room"}
      ],
      "correct": "a",
      "explanation": "She gives a new time and a new room for tomorrow''s client meeting."
    },
    {
      "id": "q2",
      "prompt": "What time is the meeting now?",
      "options": [
        {"id": "a", "text": "Nine o''clock"},
        {"id": "b", "text": "Half past ten"},
        {"id": "c", "text": "Six o''clock"}
      ],
      "correct": "b",
      "explanation": "Marta says the meeting \"has been moved from nine to half past ten\"."
    },
    {
      "id": "q3",
      "prompt": "What should the listener bring?",
      "options": [
        {"id": "a", "text": "The updated budget"},
        {"id": "b", "text": "The printed mock-ups"},
        {"id": "c", "text": "A key card"}
      ],
      "correct": "b",
      "explanation": "She asks: \"Could you bring the printed mock-ups?\""
    },
    {
      "id": "q4",
      "prompt": "When should the updated budget be sent?",
      "options": [
        {"id": "a", "text": "Before six today"},
        {"id": "b", "text": "Tomorrow at ten"},
        {"id": "c", "text": "By Friday"}
      ],
      "correct": "a",
      "explanation": "She says: \"please send me the updated budget before six today\"."
    }
  ]'::jsonb,
  10
)
on conflict (slug) do update
  set level = excluded.level,
      title = excluded.title,
      context = excluded.context,
      lines = excluded.lines,
      questions = excluded.questions,
      sort_order = excluded.sort_order,
      is_active = true;
