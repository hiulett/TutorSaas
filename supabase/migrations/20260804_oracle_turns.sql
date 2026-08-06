-- ============================================================================
-- TutorSaas — Oracle v2: Persistencia granular de la evaluación conversacional
-- Fecha: 2026-08-04
--
-- 1) Extiende `oracle_assessments` con métricas de sesión y scores finales.
-- 2) Crea `oracle_turns` con cada pregunta/respuesta y métricas por turno.
-- Idempotente.
-- ============================================================================

-- ── Extender oracle_assessments ──────────────────────────────────────────────
alter table public.oracle_assessments
  add column if not exists ai_model text default 'deepseek-v4-flash',
  add column if not exists prompt_version text default 'v2',
  add column if not exists stopped_at_cefr varchar(5),
  add column if not exists scores_pronunciation int,
  add column if not exists scores_fluency int,
  add column if not exists scores_grammar int,
  add column if not exists scores_vocabulary int,
  add column if not exists scores_comprehension int,
  add column if not exists scores_naturalness int;

-- ── Tabla oracle_turns (pregunta + respuesta + métricas por turno) ──────────
create table if not exists public.oracle_turns (
  id uuid primary key default gen_random_uuid(),
  assessment_id uuid not null references public.oracle_assessments(id) on delete cascade,
  turn_order int not null default 0,
  cefr_level varchar(5) not null default 'A1',
  question_text text,
  question_audio_url text,
  answer_transcript text,
  answer_audio_url text,
  response_time_sec numeric,
  answer_duration_sec numeric,
  pronunciation_score int,
  fluency_score int,
  grammar_score int,
  vocabulary_score int,
  comprehension_score int,
  naturalness_score int,
  partial_score int,
  created_at timestamptz not null default now()
);

alter table public.oracle_turns enable row level security;

drop policy if exists "oracle_turns_select_own" on public.oracle_turns;
create policy "oracle_turns_select_own" on public.oracle_turns
  for select
  using (
    exists (
      select 1 from public.oracle_assessments a
      where a.id = oracle_turns.assessment_id and a.user_id = auth.uid()
    )
  );

drop policy if exists "oracle_turns_insert_own" on public.oracle_turns;
create policy "oracle_turns_insert_own" on public.oracle_turns
  for insert
  with check (
    exists (
      select 1 from public.oracle_assessments a
      where a.id = oracle_turns.assessment_id and a.user_id = auth.uid()
    )
  );

create index if not exists idx_oracle_turns_assessment
  on public.oracle_turns (assessment_id, turn_order);
