# Evaluación de metas — regla P-39

_Actualizado: 29-oct-2026 · Issue #124 (P-39)_

La evaluación de metas usa **una sola** llamada `goal_eval` por turno
(`llm-proxy`); devuelve `{goals, corrections}` desde P-29. Este runbook fija
cómo se interpreta esa respuesta y cómo se mide sin añadir llamadas.

## Regla dura: sin falsos positivos

> Una meta solo se marca si el modelo la devuelve con `true` **y** su id
> pertenece al catálogo de la lección.

Implementación:

- `GoalEvaluationResult.goalsForCatalog(...)`
  (`lib/features/conversation/domain/models/goal_evaluation_result.dart`)
  devuelve una entrada por id del catálogo; los ids inventados se descartan y
  las metas no devueltas quedan en `false`.
- El repositorio aplica el filtro con los ids enviados al proxy
  (`conversation_repository_impl.dart`, `evaluateGoals`).
- El provider vuelve a filtrar antes de pintar o persistir
  (`conversation_providers.dart`, `_evaluateGoalsWithAi`). Nunca crea una meta
  sintética para un id desconocido.

El prompt de `goal_eval` incluye una rúbrica por meta: la meta es `true` solo si
el alumno produjo la acción específica en una oración completa y comprensible;
una keyword, un fragmento o repetir la frase del tutor no bastan (salvo metas
PRE-A1 que piden explícitamente una palabra).

El parser (`goal_evaluation_parser.dart`) es deliberadamente tolerante, pero
**no adivina**:

| Entrada | Resultado |
|---|---|
| JSON con prosa alrededor o bloque ```json | se recorta y se parsea |
| Comas finales | se reparan |
| JSON truncado | se rescatan solo pares `"id": true/false` completos |
| `true` / `false` como texto (`"true"`, `"FALSE"`) | se aceptan |
| `1`, `0`, `null`, listas, objetos | se ignoran |
| Id desconocido | se conserva en el parseo y se descarta al filtrar catálogo |
| Respuesta vacía o ilegible | `succeeded=false`; no marca nada |

## Reintento y gate

- `GoalEvaluationGate` decide **cuándo** llamar (≥5 palabras o una keyword de
  una meta pendiente). Las keywords cortas del catálogo (`hi`, `tea`) se
  comparan por palabra completa: “this” no activa “hi”.
- Solo las metas **pendientes** participan en el gate; si ya están todas, no se
  gasta una llamada.
- Si `goal_eval` falla, `_goalEvaluationPendingRetry` hace que el turno
  siguiente reintente aunque no pase el gate, y `endSession` reintenta antes de
  cerrar. El historial se mantiene (ventana móvil de 12 mensajes, IA-03).

## Golden set

- Fixture: `test/fixtures/goal_evaluation_golden_set.json` (10 conversaciones,
  35 etiquetas de meta; incluye tutor-only, keyword suelta, debilidad sin
  mejora y pregunta que no es pregunta).
- Test: `test/goal_evaluation_golden_test.dart`.
- Evaluador determinista: `GoalEvaluationBaseline`
  (`lib/features/conversation/domain/models/goal_evaluation_baseline.dart`).
  Es **solo línea base de CI/QA**: no llama al modelo y no persiste nada.
- El test exige ≥90 % de acuerdo y determinismo (misma entrada → misma salida).

Para una comparación manual contra el modelo real, se puede reutilizar el
fixture y comparar `expected` con la respuesta de `goal_eval`; esa medición no
corre en CI.

## Medición de aciertos por lección (solo lectura)

No se crea vista: una vista en `public` necesitaría `security_invoker` y
revisión de RLS para no exponer datos de otros usuarios. La consulta siguiente
es barata y usa la tabla existente `user_scenario_goals`:

```sql
select g.scenario_id as lesson_id,
       count(*) as goals_completed,
       count(distinct g.user_id) as learners,
       count(distinct g.conversation_id) as conversations,
       max(g.completed_at) as last_completion
  from public.user_scenario_goals g
 where g.is_completed
 group by g.scenario_id
 order by goals_completed desc;
```

Muestra verificada (29-oct-2026, MCP `supabase`, solo lectura):

| lesson_id | goals_completed | learners | conversations |
|---|---:|---:|---:|
| `a1_ordering_coffee_at_a_cafe` | 12 | 4 | 4 |
| `prea1_hello_hello` | 7 | 4 | 4 |
| `a1_checking_into_a_hotel` | 6 | 2 | 2 |
| `prea1_yes_no` | 3 | 1 | 1 |
| `prea1_my_name_is` | 3 | 1 | 1 |

> `user_scenario_goals` solo guarda metas completadas (`is_completed=true`), así
> que la consulta mide **aciertos**, no intentos fallidos. El denominador del
> catálogo (`scenario_goals`) usa ids UUID y no se puede unir de forma directa
> con el `scenario_id` textual de esta tabla.
