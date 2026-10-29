-- Issue #109 (P-24) · Corrección del techo diario de voz en la vista de alcanzabilidad.
-- Versión real registrada por Supabase: 20261029062120
--
-- Evidencia (29-oct-2026, solo lectura): la plantilla "Mantén tu Racha"
-- (speak_minutes, target 10, daily) tiene 1 instancia completada de 59
-- (1,69 %), mientras que "El Viajero Semanal" (25 min) y "El Políglota"
-- (20 palabras) tienen 0/59. Por eso el techo diario de speak_minutes es 10,
-- no 5, y el semanal sigue en 15.
create or replace view public.mission_templates_reachability as
select
  t.id,
  t.mission_type,
  t.title,
  t.objective_type,
  t.target_value,
  t.is_active,
  public.mission_objective_is_server_tracked(t.objective_type) as objetivo_rastreado,
  case t.mission_type
    when 'daily' then case t.objective_type
      when 'speak_minutes'      then 10
      when 'conversation_turns' then 5
      when 'vocab_words'        then 5
      when 'sessions'           then 1
      when 'practice_session'   then 1
    end
    when 'weekly' then case t.objective_type
      when 'speak_minutes'      then 15
      when 'conversation_turns' then 15
      when 'vocab_words'        then 10
      when 'sessions'           then 3
      when 'practice_session'   then 3
    end
  end as techo_target,
  (
    t.mission_type in ('daily', 'weekly')
    and public.mission_objective_is_server_tracked(t.objective_type)
    and t.target_value > 0
    and t.target_value <= case t.mission_type
      when 'daily' then case t.objective_type
        when 'speak_minutes'      then 10
        when 'conversation_turns' then 5
        when 'vocab_words'        then 5
        when 'sessions'           then 1
        when 'practice_session'   then 1
      end
      when 'weekly' then case t.objective_type
        when 'speak_minutes'      then 15
        when 'conversation_turns' then 15
        when 'vocab_words'        then 10
        when 'sessions'           then 3
        when 'practice_session'   then 3
      end
    end
  ) as alcanzable
from public.mission_templates t;

comment on view public.mission_templates_reachability is
  'Issue #109: plantillas alcanzables con el motor actual (tipo visible, objetivo con trigger y target <= techo medido). Espejo de mission_visibility.dart.';
