-- ─────────────────────────────────────────────────────────────────────────────
-- Issue #109 (P-24) · Rediseño de misiones: observabilidad y alcanzabilidad
-- Versión real registrada por Supabase: 20261029061945
--
-- Contexto medido (solo lectura, 29-oct-2026) antes de esta migración:
--   * mission_templates: 33 activas (14 daily, 13 secondary, 6 weekly).
--   * mission_instances: 533 (354 daily / 179 weekly), 526 active, 7 completed
--     → tasa global 1,3 %.
--   * rotate_daily_missions solo asigna mission_type IN ('daily','weekly'),
--     por lo que las 13 plantillas 'secondary' nunca se reparten.
--   * session_reward_ledger: 2 filas, 5 y 7 minutos (p50 5,5).
--   * messages (sender_role='user'): 11,3 turnos por conversación.
--   * user_vocabulary: 10,6 palabras por usuario.
--   * session_reward_ledger: 2 sesiones por usuario como máximo histórico.
--
-- Esta migración NO borra ni desactiva datos: solo expone vistas de medición.
-- El retiro de plantillas (< 5 % de completado) se decide con
-- mission_template_completion_rates y se aplica manualmente
-- (UPDATE mission_templates SET is_active = false) tras confirmarlo.
-- ─────────────────────────────────────────────────────────────────────────────

-- Objetivos que el servidor avanza por trigger:
--   conversation_turns  ← trg_message_advance_missions (messages)
--   sessions, practice_session, speak_minutes ← trg_session_reward_advance_missions
--   vocab_words         ← trg_vocabulary_advance_missions (user_vocabulary)
create or replace function public.mission_objective_is_server_tracked(p_objective text)
returns boolean
language sql
immutable
as $$
  select coalesce(p_objective = any (array[
    'speak_minutes',
    'conversation_turns',
    'vocab_words',
    'sessions',
    'practice_session'
  ]), false);
$$;

comment on function public.mission_objective_is_server_tracked(text) is
  'Issue #109: true si advance_missions_for_user() recibe este objective_type desde un trigger de servidor.';

-- Tasa de completado por plantilla + umbral del 5 % para retirar plantillas.
-- La vista corre con los privilegios del owner para agregar a todos los
-- usuarios sin exponer filas individuales (solo conteos).
create or replace view public.mission_template_completion_rates as
select
  t.id                                as template_id,
  t.mission_type,
  t.title,
  t.objective_type,
  t.target_value,
  t.is_active,
  count(i.id)                         as instancias,
  count(i.id) filter (where i.status = 'completed') as completadas,
  case
    when count(i.id) = 0 then null
    else round(100.0 * count(i.id) filter (where i.status = 'completed') / count(i.id), 2)
  end                                 as tasa_completado,
  case
    when count(i.id) = 0 then false
    else (100.0 * count(i.id) filter (where i.status = 'completed') / count(i.id)) >= 5
  end                                 as cumple_umbral_5pct,
  now()                               as medido_en
from public.mission_templates t
left join public.mission_instances i on i.template_id = t.id
group by t.id, t.mission_type, t.title, t.objective_type, t.target_value, t.is_active;

comment on view public.mission_template_completion_rates is
  'Issue #109: tasa_completado por plantilla y cumple_umbral_5pct. Regla: plantilla con < 5 % y >= 30 instancias se retira (is_active = false) tras revisión manual.';

-- Alcanzabilidad: espejo de lib/features/missions/domain/models/mission_visibility.dart
-- (techos por objetivo y tipo). Si cambian allí, cambiar aquí.
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
      when 'speak_minutes'      then 5
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
        when 'speak_minutes'      then 5
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
  'Issue #109: plantillas alcanzables con el motor actual (tipo visible, objetivo con trigger y target <= techo medido).';

revoke all on public.mission_template_completion_rates from anon;
revoke all on public.mission_templates_reachability from anon;
grant select on public.mission_template_completion_rates to authenticated;
grant select on public.mission_templates_reachability to authenticated;
