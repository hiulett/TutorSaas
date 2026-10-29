-- P-31 (#116) — Examen de promoción robusto ("Jefe de mazmorra").
--
-- `boss_exam_attempts`: registro server-side de cada intento del jefe.
-- El cliente NO puede escribirla (sin políticas INSERT/UPDATE/DELETE); la
-- escribe `evaluate-placement` con service role. La usan el cooldown y la
-- pantalla de resultado (histórico verificado por el servidor).

create table if not exists public.boss_exam_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  language_id integer not null default 1,
  from_cefr text,
  to_cefr text,
  decision text not null check (decision in ('promoted', 'maintained', 'initial')),
  reason_code text,
  average_score integer,
  scores jsonb not null default '{}'::jsonb,
  turns integer not null default 0,
  forced boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists boss_exam_attempts_user_idx
  on public.boss_exam_attempts (user_id, language_id, created_at desc);

alter table public.boss_exam_attempts enable row level security;

drop policy if exists boss_exam_attempts_select_own on public.boss_exam_attempts;
create policy boss_exam_attempts_select_own
  on public.boss_exam_attempts
  for select
  to authenticated
  using (auth.uid() = user_id);

comment on table public.boss_exam_attempts is
  'P-31 (#116): intentos del examen de promocion. Escritura exclusiva de evaluate-placement (service role).';
