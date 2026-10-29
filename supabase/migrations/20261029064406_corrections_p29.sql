-- P-29 (#114) — Corrección explícita y registro de errores.
--
-- Versión real del historial: 20261029064406 (apply_migration `corrections_p29`).
-- No ejecutar `supabase db push` (ver docs/runbooks/MIGRATION_STATUS.md).
--
-- Qué hace:
--   1. `corrections` pasa a ser propiedad del usuario (`user_id`), con
--      `conversation_id`, `turn_ref` y `created_at`; `message_id` deja de ser
--      obligatorio porque el turno se evalúa en segundo plano.
--   2. CHECK del conjunto acotado de tipos (validación en servidor).
--   3. Índice único por turno: sin duplicados de la misma corrección.
--   4. RLS de lectura/escritura propia (antes solo se podía escribir colgando
--      de un `message_id` concreto, y la tabla nunca se escribía).
--   5. Vista `user_recurring_errors`: agrupa por tipo y recurrencia para el
--      prompt del tutor y las misiones de refuerzo.

alter table public.corrections
  alter column message_id drop not null,
  add column if not exists user_id uuid references auth.users (id) on delete cascade,
  add column if not exists conversation_id uuid references public.conversations (id) on delete cascade,
  add column if not exists turn_ref text,
  add column if not exists created_at timestamptz not null default now();

alter table public.corrections
  drop constraint if exists corrections_error_type_check;
alter table public.corrections
  add constraint corrections_error_type_check
  check (
    error_type is null
    or error_type in (
      'grammar',
      'vocabulary',
      'word_choice',
      'pronunciation_hint',
      'typo_stt'
    )
  );

create index if not exists corrections_user_created_idx
  on public.corrections (user_id, created_at desc);

create unique index if not exists corrections_turn_dedupe_idx
  on public.corrections (user_id, turn_ref, error_type, original_text);

-- La política antigua dependía de `message_id`; ahora la propiedad es `user_id`.
drop policy if exists corrections_self on public.corrections;
drop policy if exists corrections_select_own on public.corrections;
create policy corrections_select_own on public.corrections
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists corrections_insert_own on public.corrections;
create policy corrections_insert_own on public.corrections
  for insert to authenticated
  with check (user_id = auth.uid());

create or replace view public.user_recurring_errors
with (security_invoker = true) as
select
  c.user_id,
  c.error_type,
  lower(c.corrected_text) as normalized_corrected,
  (array_agg(c.corrected_text order by c.created_at desc))[1] as last_corrected,
  (array_agg(c.original_text order by c.created_at desc))[1] as last_original,
  (array_agg(coalesce(c.explanation, '') order by c.created_at desc))[1] as last_explanation,
  count(*)::int as occurrences,
  max(c.created_at) as last_seen_at
from public.corrections c
where c.user_id is not null
group by c.user_id, c.error_type, lower(c.corrected_text);

grant select on public.user_recurring_errors to authenticated;
