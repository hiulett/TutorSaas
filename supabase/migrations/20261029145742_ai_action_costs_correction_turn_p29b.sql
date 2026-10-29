-- P-29-b (#193) — Correcciones en conversación libre.
--
-- Versión real del historial: 20261029145742 (apply_migration
-- `ai_action_costs_correction_turn_p29b`). No ejecutar `supabase db push`
-- (ver docs/runbooks/MIGRATION_STATUS.md).
--
-- Qué hace:
--   Da de alta el coste de una evaluación de correcciones por turno en chat
--   libre (`action_code = correction_turn`, 3 de maná). El maná lo cobra
--   `llm-proxy` ANTES de llamar al modelo (`consume_mana` lee `cost_mana` de
--   esta tabla). Coste bajo a propósito: el cliente limita a 6 evaluaciones
--   por sesión (`CorrectionTurnPolicy.maxEvaluationsPerSession`), así que el
--   gasto extra máximo por sesión es 18 de maná frente a 8 por turno de
--   conversación libre.
--
-- Rollback: `delete from public.ai_action_costs where action_code =
-- 'correction_turn';` (el proxy pasa a devolver 400 invalid_action para esa
-- acción; el cliente ya degrada sin romper el chat).

insert into public.ai_action_costs (action_code, label, cost_mana, description, is_active)
values (
  'correction_turn',
  'Correccion de turno (chat libre)',
  3,
  'Una llamada al LLM por turno evaluado en conversacion libre (P-29-b). Tope 6 por sesion.',
  true
)
on conflict (action_code) do update
  set label       = excluded.label,
      cost_mana   = excluded.cost_mana,
      description = excluded.description,
      is_active   = excluded.is_active,
      updated_at  = now();
