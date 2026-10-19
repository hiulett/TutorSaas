-- Issue #81: distinguir el contenido generado por IA del contenido curado.
--
-- Las lecciones que produce `lesson-generator` nacen como `draft` para que
-- alguien las revise antes de darlas por buenas en la biblioteca compartida.
-- Las 500 escenarios existentes quedan como `approved`.

alter table public.scenarios
  add column if not exists review_status text not null default 'approved';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'scenarios_review_status_check'
  ) then
    alter table public.scenarios
      add constraint scenarios_review_status_check
      check (review_status in ('approved', 'draft', 'rejected'));
  end if;
end $$;
