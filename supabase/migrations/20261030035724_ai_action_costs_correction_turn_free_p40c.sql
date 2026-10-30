-- P-40-c (#222) — `correction_turn` pasa a ser gratuita.
--
-- Versión real del historial: 20261030035724 (apply_migration
-- `ai_action_costs_correction_turn_free_p40c`).
-- No ejecutar `supabase db push` (ver docs/runbooks/MIGRATION_STATUS.md).
--
-- El turno de conversación ya se cobra (`free_chat_turn`/`dungeon_turn`); las
-- correcciones son su salida pedagógica y no deben depender del saldo. Sin
-- esto, un alumno sin maná no genera historial y `user_recurring_errors` queda
-- vacío para siempre (el prompt del tutor no tiene errores que usar).
--
-- El cobro se apaga desactivando la fila: `consume_mana` solo acepta acciones
-- activas con coste > 0. El proxy además trata `correction_turn` como gratuita
-- por `FREE_ACTIONS` (supabase/functions/llm-proxy/validation.ts), así que no
-- llama a `consume_mana` ni aunque la fila siguiera activa.
--
-- Rollback: reactivar la fila (is_active = true) y quitar 'correction_turn' de
-- FREE_ACTIONS + desplegar el proxy.

update public.ai_action_costs
set is_active = false,
    description = 'Correccion de turno (chat libre). Gratuita desde P-40-c (#222): el mana lo paga el turno de conversacion. Tope 6 por sesion.',
    updated_at = now()
where action_code = 'correction_turn';
