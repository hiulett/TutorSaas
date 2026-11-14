-- Currículo: esquema base (CUR-01).
--
-- Migración ADITIVA: no toca `lesson_progress` ni `lesson_catalog_index`.
-- Todo el contenido educativo pasa a estas tablas y se sirve por RPC; no hay
-- políticas de cliente (solo service_role y funciones SECURITY DEFINER).
--
-- Ids: `lessons.id` conserva el id del catálogo Dart para no romper el progreso
-- histórico (`lesson_progress.lesson_id` es texto).

-- ── Niveles ─────────────────────────────────────────────────────────────────
create table if not exists public.curriculum_levels (
  id             text primary key,
  name           text not null,
  cefr           text not null check (cefr in ('PRE-A1','A1','A2','B1','B2','C1','C2')),
  order_index    integer not null unique,
  narrative_world text,
  description    text,
  estimated_hours integer,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

insert into public.curriculum_levels (id, name, cefr, order_index, narrative_world)
values
  ('pre_a1', 'Despertar',        'PRE-A1', 1, 'El Umbral'),
  ('a1',     'Aprendiz',         'A1',     2, 'La Aldea de los Ecos'),
  ('a2',     'Iniciado',         'A2',     3, 'El Bosque de los Nombres'),
  ('b1',     'Cazador',          'B1',     4, 'Las Ruinas del Verbo'),
  ('b2',     'Veterano',         'B2',     5, 'La Ciudad Sumergida'),
  ('c1',     'Maestro',          'C1',     6, 'El Archivo Prohibido'),
  ('c2',     'Leyenda',          'C2',     7, 'El Trono del Silencio')
on conflict (id) do nothing;

-- ── Unidades ────────────────────────────────────────────────────────────────
create table if not exists public.curriculum_units (
  id          uuid primary key default gen_random_uuid(),
  level_id    text not null references public.curriculum_levels(id) on delete cascade,
  slug        text not null,
  title       text not null,
  description text,
  order_index integer not null,
  created_at  timestamptz not null default now(),
  unique (level_id, slug),
  unique (level_id, order_index)
);

create index if not exists idx_curriculum_units_level
  on public.curriculum_units (level_id, order_index);

-- ── Lecciones ───────────────────────────────────────────────────────────────
create table if not exists public.lessons (
  id                text primary key,
  unit_id           uuid references public.curriculum_units(id) on delete set null,
  title             text not null,
  category          text not null default 'daily',
  difficulty        smallint check (difficulty between 1 and 5),
  order_index       integer not null default 0,
  estimated_minutes integer,
  main_objective    text,
  scenario_context  text,
  assistant_role    text,
  user_role         text,
  initial_message   text,
  status            text not null default 'draft'
                    check (status in ('draft','review','published','archived')),
  current_version   integer not null default 1,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (unit_id, order_index)
);

create index if not exists idx_lessons_unit on public.lessons (unit_id, order_index);
create index if not exists idx_lessons_status on public.lessons (status);

-- ── Versiones (snapshot publicado) ──────────────────────────────────────────
create table if not exists public.lesson_versions (
  id           uuid primary key default gen_random_uuid(),
  lesson_id    text not null references public.lessons(id) on delete cascade,
  version      integer not null,
  snapshot     jsonb not null,
  changelog    text,
  published_at timestamptz,
  published_by uuid references auth.users(id) on delete set null,
  created_at   timestamptz not null default now(),
  unique (lesson_id, version)
);

create index if not exists idx_lesson_versions_latest
  on public.lesson_versions (lesson_id, version desc);

-- ── Contenido por versión ───────────────────────────────────────────────────
create table if not exists public.lesson_objectives (
  id              uuid primary key default gen_random_uuid(),
  lesson_id       text not null references public.lessons(id) on delete cascade,
  version         integer not null default 1,
  code            text not null,
  description     text not null,
  competency      text not null check (competency in
    ('speaking','vocabulary','grammar','listening','reading','writing','pronunciation','communication')),
  criterion       text,
  evidence_examples jsonb,
  common_errors   jsonb,
  is_required     boolean not null default true,
  needs_review    boolean not null default false,
  order_index     integer not null default 0,
  unique (lesson_id, version, code)
);

create table if not exists public.lesson_phrases (
  id                 uuid primary key default gen_random_uuid(),
  lesson_id          text not null references public.lessons(id) on delete cascade,
  version            integer not null default 1,
  phrase             text not null,
  translation        text,
  translation_status text not null default 'pending'
                     check (translation_status in ('ok','identical','pending')),
  audio_url          text,
  order_index        integer not null default 0,
  unique (lesson_id, version, order_index)
);

create table if not exists public.lesson_vocabulary (
  id             uuid primary key default gen_random_uuid(),
  lesson_id      text not null references public.lessons(id) on delete cascade,
  version        integer not null default 1,
  lemma          text not null,
  translation    text,
  pos            text,
  ipa            text,
  definition     text,
  context        text,
  example        text,
  priority       smallint default 1,
  is_required    boolean not null default false,
  objective_code text,
  unique (lesson_id, version, lemma)
);

create table if not exists public.lesson_grammar (
  id                  uuid primary key default gen_random_uuid(),
  lesson_id           text not null references public.lessons(id) on delete cascade,
  version             integer not null default 1,
  topic_code          text not null,
  title               text not null,
  explanation_md      text,
  contrastive_example text,
  common_mistakes     jsonb,
  order_index         integer not null default 0,
  unique (lesson_id, version, topic_code)
);

-- ── Actividades ─────────────────────────────────────────────────────────────
create table if not exists public.activity_types (
  code           text primary key,
  renderer_key   text not null,
  schema_version integer not null default 1,
  payload_schema jsonb not null,
  is_enabled     boolean not null default false,
  created_at     timestamptz not null default now()
);

insert into public.activity_types (code, renderer_key, payload_schema, is_enabled)
values
  ('conversation', 'conversation', '{"type":"object","required":["goals"]}'::jsonb, true),
  ('mcq', 'mcq', '{"type":"object","required":["question","options","correct"]}'::jsonb, false),
  ('fill_blank', 'fill_blank', '{"type":"object","required":["text_with_gaps","answers"]}'::jsonb, false),
  ('order_words', 'order_words', '{"type":"object","required":["tokens","correct_order"]}'::jsonb, false)
on conflict (code) do nothing;

create table if not exists public.lesson_activities (
  id             uuid primary key default gen_random_uuid(),
  lesson_id      text not null references public.lessons(id) on delete cascade,
  version        integer not null default 1,
  activity_type  text not null references public.activity_types(code) on delete restrict,
  order_index    integer not null,
  instructions   text,
  payload        jsonb not null default '{}'::jsonb,
  scoring        jsonb,
  feedback_good  text,
  feedback_bad   text,
  unique (lesson_id, version, order_index)
);

-- ── Prerrequisitos ──────────────────────────────────────────────────────────
create table if not exists public.lesson_prerequisites (
  lesson_id          text not null references public.lessons(id) on delete cascade,
  requires_lesson_id text not null references public.lessons(id) on delete cascade,
  kind               text not null default 'required' check (kind in ('required','recommended')),
  primary key (lesson_id, requires_lesson_id),
  check (lesson_id <> requires_lesson_id)
);

-- ── RLS: sin acceso de cliente (solo service_role / SECURITY DEFINER) ───────
alter table public.curriculum_levels     enable row level security;
alter table public.curriculum_units      enable row level security;
alter table public.lessons               enable row level security;
alter table public.lesson_versions        enable row level security;
alter table public.lesson_objectives      enable row level security;
alter table public.lesson_phrases         enable row level security;
alter table public.lesson_vocabulary      enable row level security;
alter table public.lesson_grammar         enable row level security;
alter table public.activity_types         enable row level security;
alter table public.lesson_activities      enable row level security;
alter table public.lesson_prerequisites   enable row level security;

-- Sin políticas: los clientes no leen contenido directamente. La lectura va por
-- RPC SECURITY DEFINER (CUR-07) y la escritura por RPC admin (CUR-08).

comment on table public.lessons is
  'Catálogo curricular (CUR-01). id = id del catálogo Dart para no romper lesson_progress.';
comment on table public.lesson_versions is
  'Snapshot de cada versión publicada; una versión nueva no revoca completadas.';
