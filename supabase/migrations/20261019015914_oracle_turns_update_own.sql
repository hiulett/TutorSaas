-- Issue #25: el radar de habilidades leía 6 columnas de `oracle_turns`
-- (pronunciation, fluency, grammar, vocabulary, comprehension, naturalness)
-- que ningún código escribía: solo se guardaba `partial_score`.
--
-- Al cerrar el examen, la app ya recibe esas dimensiones del evaluador de
-- placement (`scores.pronunciation`, `scores.grammar`, …) y ahora las vuelca
-- en el último turno. Para eso hacía falta poder actualizar el propio turno:
-- antes solo existían políticas de INSERT y SELECT.

drop policy if exists oracle_turns_update_own on public.oracle_turns;
create policy oracle_turns_update_own on public.oracle_turns
  for update to authenticated
  using (exists (
    select 1 from public.oracle_assessments a
    where a.id = oracle_turns.assessment_id and a.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.oracle_assessments a
    where a.id = oracle_turns.assessment_id and a.user_id = auth.uid()
  ));
