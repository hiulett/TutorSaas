-- P-33 (#118): vocabulario curado por el LLM.
--
-- Antes: `analyzeAndSaveSessionProgress` extraía palabras con
--   `\b[a-zA-Z]{4,15}\b` (máx. 6 por turno), traducía con un diccionario de 21
--   entradas y usaba `word` como traducción para todo lo demás. Resultado en
--   producción: 65 de 70 `vocabulary_items` con `translation = word`, todas
--   con `difficulty_level = 'A2'`, y basura de STT (`alberto`, `cadira`,
--   `bueno`, `baile`).
--
-- Ahora: el LLM propone hasta 8 palabras por SESIÓN y este RPC es la última
-- línea de defensa. Aunque el cliente envíe cualquier cosa, aquí se valida:
--   * forma canónica (minúsculas, una sola palabra, sin números),
--   * que la palabra exista REALMENTE en los mensajes del alumno,
--   * que no sea stopword ni nombre propio (solo apariciones en minúscula),
--   * traducción no vacía, distinta de la palabra y sin saltos de línea,
--   * categoría gramatical y CEFR dentro de escalas cerradas,
--   * dedupe dentro del lote y contra `vocabulary_items` / `user_vocabulary`.
--
-- La escritura va por este RPC `SECURITY DEFINER`: el cliente no inserta
-- directamente en `vocabulary_items` ni `user_vocabulary`.
--
-- Coste: `ai_action_costs.vocabulary_curation = 2` maná por sesión (una sola
-- llamada al cerrar la sesión). El cobro lo hace `llm-proxy` (P-07) antes de
-- llamar al modelo; si el modelo falla, el proxy reembolsa.

-- ── 1. Frase de ejemplo (criterio P-33) ──────────────────────────────────────
alter table public.vocabulary_items
  add column if not exists example_sentence text;

comment on column public.vocabulary_items.example_sentence is
  'Frase de ejemplo devuelta por el curador LLM (P-33). Puede ser NULL en filas antiguas.';

-- ── 2. Coste de la acción de IA ──────────────────────────────────────────────
insert into public.ai_action_costs (action_code, label, cost_mana, description, is_active, updated_at)
values (
  'vocabulary_curation',
  'Curaduría de vocabulario',
  2,
  'Extrae y valida hasta 8 palabras nuevas al cerrar la sesión (una llamada al LLM).',
  true,
  now()
)
on conflict (action_code) do update
  set label = excluded.label,
      cost_mana = excluded.cost_mana,
      description = excluded.description,
      is_active = excluded.is_active,
      updated_at = now();

-- ── 3. Auditoría de ejecuciones (se registra también cuando falla) ───────────
create table if not exists public.vocabulary_curation_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  conversation_id uuid references public.conversations(id) on delete cascade,
  status text not null check (status in (
    'ok', 'rejected', 'invalid_json', 'model_error', 'no_mana',
    'invalid_action', 'error'
  )),
  reason text,
  requested integer not null default 0,
  accepted integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists vocabulary_curation_runs_user_idx
  on public.vocabulary_curation_runs (user_id, created_at desc);

alter table public.vocabulary_curation_runs enable row level security;

drop policy if exists vocabulary_curation_runs_select_own
  on public.vocabulary_curation_runs;
create policy vocabulary_curation_runs_select_own
  on public.vocabulary_curation_runs
  for select to authenticated
  using (auth.uid() = user_id);

-- Solo el RPC escribe: el cliente no puede falsear la evidencia.
revoke insert, update, delete on public.vocabulary_curation_runs
  from authenticated, anon;

-- ── 4. Stopwords inglesas (palabras de función, no de contenido) ─────────────
create or replace function public.is_vocabulary_stopword(p_word text)
returns boolean
language sql
immutable
set search_path = ''
as $function$
  select coalesce(
    lower(btrim(p_word)) = any (array[
      'a','an','the','and','or','but','if','then','than','so','because','as',
      'of','at','by','for','with','about','into','through','during','before',
      'after','above','below','to','from','up','down','in','out','on','off',
      'over','under','again','further','once','here','there','when','where',
      'why','how','all','any','both','each','few','more','most','other','some',
      'such','no','nor','not','only','own','same','too','very','can','will',
      'just','should','now','i','me','my','myself','we','our','ours',
      'ourselves','you','your','yours','yourself','yourselves','he','him',
      'his','himself','she','her','hers','herself','it','its','itself','they',
      'them','their','theirs','themselves','what','which','who','whom','this',
      'that','these','those','am','is','are','was','were','be','been','being',
      'have','has','had','having','do','does','did','doing','would','could',
      'shall','may','might','must','ought','im','ive','dont','doesnt','didnt',
      'cant','wont','isnt','arent','wasnt','werent','yeah','yes','okay','ok',
      'uh','um','hmm','oh','ah','well','really','actually','maybe','please',
      'thanks','thank','hello','hi','hey','bye','goodbye'
    ]::text[]),
    false
  );
$function$;

revoke all on function public.is_vocabulary_stopword(text) from public, anon, authenticated;

-- ── 5. RPC de curaduría ──────────────────────────────────────────────────────
create or replace function public.curate_session_vocabulary(
  p_conversation_id uuid,
  p_items jsonb,
  p_status text default 'ok',
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_uid uuid := auth.uid();
  v_conv public.conversations%rowtype;
  v_native text := 'es';
  v_item jsonb;
  v_word text;
  v_translation text;
  v_pos text;
  v_pos_code text;
  v_cefr text;
  v_example text;
  v_vocab_id uuid;
  v_requested integer := 0;
  v_inserted integer := 0;
  v_skipped integer := 0;
  v_status text := lower(btrim(coalesce(p_status, 'ok')));
  v_seen text[] := array[]::text[];
  v_out jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    raise exception 'No autorizado';
  end if;

  if p_conversation_id is null then
    raise exception 'Sesion no valida';
  end if;

  select * into v_conv
    from public.conversations
   where id = p_conversation_id
     and user_id = v_uid
     and deleted_at is null;

  if not found then
    raise exception 'Sesion no valida';
  end if;

  select coalesce(nullif(btrim(u.native_language), ''), 'es')
    into v_native
    from public.users u
   where u.id = v_uid;

  if v_status not in (
    'ok', 'rejected', 'invalid_json', 'model_error', 'no_mana',
    'invalid_action', 'error'
  ) then
    v_status := 'error';
  end if;

  -- Un `p_items` que no sea array no debe romper el cierre de sesión.
  if p_items is null or jsonb_typeof(p_items) is distinct from 'array' then
    p_items := '[]'::jsonb;
  end if;

  v_requested := jsonb_array_length(p_items);

  -- Fallo del modelo / JSON inválido / sin maná: no se inventa nada, solo se
  -- deja constancia de que la sesión se omitió.
  if v_status <> 'ok' or v_requested = 0 then
    insert into public.vocabulary_curation_runs
      (user_id, conversation_id, status, reason, requested, accepted)
    values (
      v_uid,
      p_conversation_id,
      case when v_status = 'ok' then 'rejected' else v_status end,
      left(coalesce(nullif(btrim(p_reason), ''), 'no_items'), 200),
      v_requested,
      0
    );

    return jsonb_build_object(
      'ok', false,
      'status', case when v_status = 'ok' then 'rejected' else v_status end,
      'inserted', 0,
      'skipped', v_requested,
      'items', '[]'::jsonb
    );
  end if;

  for v_item in
    select value
      from jsonb_array_elements(p_items) with ordinality as t(value, ord)
     where ord <= 8
  loop
    v_word := lower(btrim(coalesce(v_item->>'word', '')));
    v_word := regexp_replace(v_word, '\s+', ' ', 'g');

    -- Forma canónica: una sola palabra, sin números ni símbolos raros.
    if v_word !~ '^[a-z][a-z''-]{1,31}$' then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    -- Errores de STT evidentes: sin vocal o repetición de una letra (>3).
    if v_word !~ '[aeiouy]' or v_word ~ '(.)\1\1\1' then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    if public.is_vocabulary_stopword(v_word) then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    if v_word = any (v_seen) then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    -- Anti-alucinación: la palabra tiene que estar en un mensaje del alumno.
    if not exists (
      select 1
        from public.messages m
       where m.conversation_id = p_conversation_id
         and m.sender_role = 'user'
         and m.text ~* ('\y' || v_word || '\y')
    ) then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    -- Nombres propios / STT: exigimos al menos una aparición en minúscula
    -- (las mayúsculas de inicio de frase no cuentan como evidencia).
    if not exists (
      select 1
        from public.messages m
       where m.conversation_id = p_conversation_id
         and m.sender_role = 'user'
         and m.text ~ ('\y' || v_word || '\y')
    ) then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    v_translation := btrim(coalesce(v_item->>'translation', ''));
    if length(v_translation) < 1
       or length(v_translation) > 80
       or v_translation ~ '[\r\n]'
       or lower(v_translation) = v_word
       or v_translation !~ '[[:alpha:]]' then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    v_pos_code := lower(btrim(coalesce(v_item->>'part_of_speech', '')));
    v_pos := case v_pos_code
      when 'noun' then 'Sustantivo'
      when 'verb' then 'Verbo'
      when 'adjective' then 'Adjetivo'
      when 'adverb' then 'Adverbio'
      when 'preposition' then 'Preposición'
      when 'pronoun' then 'Pronombre'
      when 'conjunction' then 'Conjunción'
      when 'interjection' then 'Interjección'
      when 'phrase' then 'Frase'
      else null
    end;
    if v_pos is null then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    v_cefr := upper(btrim(coalesce(v_item->>'cefr', '')));
    if v_cefr not in ('A1', 'A2', 'B1', 'B2', 'C1', 'C2') then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    v_example := btrim(coalesce(v_item->>'example', ''));
    if length(v_example) > 300 then
      v_example := left(v_example, 300);
    end if;
    -- Un ejemplo que no contiene la palabra no es evidencia de uso.
    if v_example <> '' and v_example !~* ('\y' || v_word || '\y') then
      v_example := '';
    end if;

    v_seen := v_seen || v_word;

    select vi.id
      into v_vocab_id
      from public.vocabulary_items vi
     where vi.language_id = v_conv.language_id
       and lower(vi.word) = v_word
     limit 1;

    if v_vocab_id is null then
      insert into public.vocabulary_items (
        language_id, word, translation, part_of_speech,
        native_language, difficulty_level, example_sentence
      )
      values (
        v_conv.language_id, v_word, v_translation, v_pos,
        v_native, v_cefr, nullif(v_example, '')
      )
      on conflict (language_id, word) do update
        set updated_at = now()
      returning id into v_vocab_id;
    else
      -- Solo se repara una traducción basura (vacía o igual a la palabra);
      -- nunca se sobrescribe una traducción ya curada.
      update public.vocabulary_items vi
         set translation = case
               when nullif(btrim(vi.translation), '') is null
                 or lower(btrim(vi.translation)) = lower(vi.word)
               then v_translation
               else vi.translation
             end,
             part_of_speech = coalesce(nullif(btrim(vi.part_of_speech), ''), v_pos),
             native_language = coalesce(nullif(btrim(vi.native_language), ''), v_native),
             example_sentence = coalesce(vi.example_sentence, nullif(v_example, '')),
             updated_at = now()
       where vi.id = v_vocab_id;
    end if;

    insert into public.user_vocabulary (
      user_id, vocabulary_id, word, translation,
      times_seen, times_correct, ease_factor, interval_days,
      next_review_at, last_seen_at, created_at
    )
    values (
      v_uid, v_vocab_id, v_word, v_translation,
      1, 0, 2.5, 1,
      now() + interval '1 day', now(), now()
    )
    on conflict (user_id, word) do nothing;

    if found then
      v_inserted := v_inserted + 1;
      v_out := v_out || jsonb_build_object(
        'word', v_word,
        'translation', v_translation,
        'part_of_speech', v_pos,
        'part_of_speech_code', v_pos_code,
        'cefr', v_cefr,
        'example', v_example
      );
    else
      -- Ya la tenía el alumno: no se reprograma ni se duplica.
      v_skipped := v_skipped + 1;
    end if;
  end loop;

  insert into public.vocabulary_curation_runs
    (user_id, conversation_id, status, reason, requested, accepted)
  values (
    v_uid,
    p_conversation_id,
    case when v_inserted > 0 then 'ok' else 'rejected' end,
    left(
      case
        when v_inserted > 0 and v_skipped > 0 then 'filtered_' || v_skipped
        when v_inserted > 0 then null
        else coalesce(nullif(btrim(p_reason), ''), 'no_valid_items')
      end,
      200
    ),
    v_requested,
    v_inserted
  );

  return jsonb_build_object(
    'ok', v_inserted > 0,
    'status', case when v_inserted > 0 then 'ok' else 'rejected' end,
    'inserted', v_inserted,
    'skipped', v_skipped,
    'items', v_out
  );
end;
$function$;

revoke all on function public.curate_session_vocabulary(uuid, jsonb, text, text)
  from public, anon;
grant execute on function public.curate_session_vocabulary(uuid, jsonb, text, text)
  to authenticated;
