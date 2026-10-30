# Personalización del tutor — qué se usa y qué no (P-40 · #125)

Este runbook cierra el hallazgo **H-40**: la app guardaba datos de
personalización que el prompt del tutor y la selección de lecciones ignoraban.
Aquí queda qué campo **se lee de verdad**, dónde, y qué queda pendiente.

## 1. Flujo

```
onboarding / ajustes
  ├─ user_settings(interests, motivation, correction_level, correction_style,
  │                tutor_personality)               ← lo escribe el cliente
  └─ user_ai_profiles(focus_areas, pedagogical_summary,
                      tutor_prompt_instructions)    ← lo escribe el onboarding
                         │
      TutorPersonalizationRepository.load(user_id)   ← 1 lectura por sesión
                         │                            (añadida en P-40)
                         ▼
      TutorPromptBuilder.build(TutorPromptInput)     ← función pura y testeada
                         │
                         ▼
      system prompt del turno de chat → llm-proxy → DeepSeek
```

- Código: `lib/features/conversation/data/repositories/tutor_personalization_repository.dart`,
  `lib/features/conversation/domain/services/tutor_prompt_builder.dart`,
  `lib/features/conversation/domain/models/tutor_adaptation.dart`.
- Se lee una vez en `ConversationNotifier.initSession` y se espera en el primer
  turno (`_ensureTutorPersonalization`). No hay ninguna llamada nueva al modelo:
  el prompt viaja en el turno que ya se pagaba (`action_code` sin cambios).
- Tests: `test/tutor_prompt_builder_test.dart`, `test/tutor_adaptation_test.dart`.

## 2. Campos y destino

| Campo | Origen | Se usa en |
|---|---|---|
| `interests` | `user_settings` | prompt (`STUDENT PROFILE`) + orden de lecciones recomendadas |
| `focus_areas` | `user_ai_profiles` | ídem (se une con `interests`) |
| `motivation` | `user_settings` | prompt (`STUDENT PROFILE`) |
| `correction_level` | `user_settings` | prompt (`CORRECTION MODE`); `teacher` ya tiene texto propio |
| `correction_style` | `user_settings` | prompt (`Correction style`) |
| `tutor_personality` | `user_settings` | prompt (`Tone`) |
| `tutor_prompt_instructions` | `user_ai_profiles` | prompt (`STUDENT-SPECIFIC TUTOR INSTRUCTIONS`) |
| `pedagogical_summary` | `user_ai_profiles` | respaldo si faltan las instrucciones |
| CEFR real | `user_language_profiles → cefr_levels` | regla de lenguaje del prompt |
| Errores recurrentes | `user_recurring_errors` (P-29) | prompt (`RECURRING MISTAKES`) |
| Metas pendientes | `scenarios.goals` | prompt (`PENDING GOALS`) |
| `main_objective` | `scenarios` | prompt (`YOUR OBJECTIVE IN THIS SCENE`) |
| Frases útiles | `scenarios.useful_phrases` | prompt (`USEFUL PHRASES`) |
| Frases de lecciones previas | `user_scenario_phrases` | prompt (`CUMULATIVE REVIEW`) |
| Lecciones superadas | `lesson_progress.status='passed'` | dispara el repaso cada 3 lecciones |
| Rachas acierto/fallo | correcciones + metas del mismo turno | ajuste simplificar/subir en el prompt |

## 3. Reglas de adaptación

`TutorAdaptationTracker` (sin coste de IA):

- 2 turnos seguidos con correcciones → **simplificar** + pista concreta.
- 3 turnos seguidos limpios y con sustancia (≥6 palabras o meta cumplida) →
  **subir el listón**.
- Turno limpio pero de una palabra ("yes") → neutro: no mueve ninguna racha.
- Se reinicia al abrir cada sesión.

## 4. Qué NO se puede usar sin coste extra

| Campo | Por qué no se usa | Seguimiento |
|---|---|---|
| `user_ai_profiles.learning_style` | Valor único (`auditory_interactive`) escrito por el onboarding; no varía por usuario y no aporta al prompt. | No requiere trabajo: se deja fuera a propósito. |
| Errores recurrentes en planes sin maná | **Resuelto en P-40-c (#222)**: `correction_turn` es gratuita. Ver §6. | — |
| Reordenar el catálogo por `skill_radar` | El radar vive en un provider de presentación; moverlo al repositorio duplica consultas. Se priorizó interés + duración. | No verificable hoy: pendiente de medir impacto antes de añadirlo. |

Las dos filas que antes figuraban aquí (`recommended_path_scenarios` sin
productor y la banda CEFR fija del escenario) **ya no aplican**: las resolvieron
P-40a (#220) y P-40b (#221) sin llamadas nuevas de IA. Detalle en §7.

## 5. Comprobación en producción (solo lectura)

```sql
-- ¿Hay perfiles con datos que el prompt pueda usar?
select count(*) filter (where cardinality(interests) > 0) as con_intereses,
       count(*) filter (where motivation <> '')          as con_motivacion,
       count(*)                                          as total
from public.user_settings;

-- ¿El perfil de IA tiene instrucciones reales (no la plantilla vacía)?
select count(*) filter (where coalesce(tutor_prompt_instructions,'') <> '') as con_instrucciones,
       count(*) filter (where cardinality(focus_areas) > 0)                as con_focus_areas,
       count(*)                                                            as total
from public.user_ai_profiles;

-- ¿Hay evidencia para errores recurrentes?
select count(*) from public.user_recurring_errors;
```

Estado al 29-oct-2026 (MCP `supabase`, solo lectura):

- `user_settings`: 68 filas, **0 con `interests`**, 68 con `tutor_personality`
  y `correction_level`.
- `user_ai_profiles`: 11 filas, `focus_areas` vacío y `tutor_prompt_instructions`
  con la plantilla del onboarding.
- `user_recurring_errors`: 0 filas; `corrections`: 0 filas.
- Usuarios con práctica (≥1 mensaje en una conversación): **34**; con al menos
  una corrección registrada: **0** (ver consulta en §6).

Conclusión honesta: la personalización **está conectada y probada en código**,
pero en producción todavía no hay datos que la alimenten porque los usuarios
actuales no completaron el onboarding con intereses y aún no hay correcciones
registradas. La medición de efecto real queda pendiente de que exista ese dato.

## 6. Errores recurrentes sin maná (P-40-c · #222)

**Problema validado (29-oct-2026).** `corrections` solo se escribía desde dos
llamadas de IA:

- `goal_eval` — gratuita, pero solo corre en lecciones con metas pendientes.
- `correction_turn` — chat libre, lección sin metas o metas ya cumplidas; hasta
  P-40-c costaba **3 de maná**.

Un alumno sin saldo podía conversar con el turno de gracia diario (`claim_mana_grace`)
y recibir respuestas del tutor, pero la segunda llamada devolvía `402 no_mana`:
no había chip, no había fila en `corrections` y `user_recurring_errors` seguía
vacío. El tutor cargaba la vista igual (coste 0), pero no tenía nada que usar.

**Solución.** `correction_turn` pasa a `FREE_ACTIONS` en `llm-proxy` y su fila de
`ai_action_costs` queda inactiva (migración `20261030035724`). El maná lo sigue
pagando el turno de conversación; las correcciones son su salida pedagógica. No
hay llamada nueva: se reutiliza la misma petición de P-29-b. El prompt del tutor
ya recibe `user_recurring_errors` en el turno que paga (`_loadRecurringErrors` →
`TutorPromptBuilder`), así que usarlos no cuesta nada extra.

**Qué se registra (y qué no).**

- Solo las correcciones que devuelve el modelo y que pasan `parseCorrections`
  (tipo del conjunto acotado, `original` y `corrected` no vacíos, máximo 3).
- Solo con usuario real y `turn_ref` (`CorrectionTurnPolicy.shouldPersist`).
  Invitados, turnos sin referencia y listas vacías no escriben fila: no se
  inventan errores para «tener historial».
- La escritura es idempotente por `(user_id, turn_ref, error_type,
  original_text)`; un reintento no duplica.

**Métrica (solo lectura, ejecutada el 30-oct-2026).**

```sql
with practica as (
  select distinct c.user_id
  from public.conversations c
  join public.messages m on m.conversation_id = c.id
  where c.user_id is not null
)
select (select count(*) from practica)                              as usuarios_con_practica,
       (select count(distinct user_id) from public.corrections)      as con_correcciones,
       (select count(*) from public.corrections)                     as filas_corrections,
       (select count(*) from public.user_recurring_errors)           as filas_recurring;

-- Reparto por tipo (cuando haya datos)
select error_type, count(*) as filas, count(distinct user_id) as usuarios
from public.corrections
group by 1 order by 2 desc;
```

Resultado real (30-oct-2026): `usuarios_con_practica = 34`,
`con_correcciones = 0`, `filas_corrections = 0`, `filas_recurring = 0`.

Evidencia adicional de que el hueco era **latente**, no observado:

```sql
-- ¿Se ha pedido/cobrado alguna vez correction_turn?
select 'ai_usage_logs' as fuente, count(*) from public.ai_usage_logs
where action_code = 'correction_turn'
union all
select 'mana_transactions', count(*) from public.mana_transactions
where action_code = 'correction_turn';

-- ¿Hay suscripciones con el saldo del plan agotado?
select count(*) as suscripciones,
       count(*) filter (
         where greatest(0, sp.mana_allowance - coalesce(us.used_audio_seconds, 0)) = 0
       ) as sin_saldo_plan
from public.user_subscriptions us
join public.subscription_plans sp on sp.id = us.plan_id;
```

Resultado: `0` llamadas en `ai_usage_logs`, `0` cargos en `mana_transactions`,
`0` de 15 suscripciones con el saldo agotado. O sea: **ningún usuario llegó a
tocar el camino** todavía, pero el diseño lo garantizaba en cuanto alguien
agotara el saldo (el `402` era inevitable). La métrica de recuperación seguirá
en 0 hasta que un usuario complete turnos con el proxy v18 desplegado. El
histórico anterior no se puede reconstruir (no se guardaba el texto de los
turnos ni había correcciones).

**Despliegue (hecho el 30-oct-2026).** `llm-proxy` versión **18** desplegada
(`supabase functions deploy llm-proxy --project-ref sipiumfdpvnszthykyog
--use-api`) y migración `20261030035724` aplicada por MCP. El orden importa:
primero el proxy (acepta la acción gratis), después la fila inactiva; al revés,
un proxy viejo devolvería `400 invalid_action`. El cliente no cambia: sigue
enviando `correction_turn`.

## 7. P-40a (#220) y P-40b (#221): ruta recomendada y banda del escenario

### Ruta recomendada (P-40a)

- Productor: `refresh_recommended_path(p_user_id)` (`SECURITY DEFINER`,
  migración `20261030040054_path_band_p40ab.sql`). Calcula la ruta con el nivel
  real (`user_language_profiles → cefr_levels`), los intereses
  (`user_settings.interests` + `user_ai_profiles.focus_areas`), los errores
  recurrentes (P-29) y las lecciones superadas (`lesson_progress.status =
  'passed'` y `user_scenario_goals`), sobre escenarios existentes.
- Idempotente: el orden es determinista y solo escribe cuando la ruta cambia.
  No gasta IA ni maná.
- Persistencia: `user_ai_profiles.recommended_path_scenarios` (jsonb). Lector
  barato: `get_recommended_path(p_user_id)`.
- UI: `recommendedPathProvider` → `PathOrder.apply` ordena la Ruta y la CTA
  «continuar aventura»; si la RPC falla o devuelve vacío, se conserva el orden
  actual del catálogo.
- Puente de currículos: `scenarios.lesson_key` enlaza cada escenario de BD con
  su id del catálogo Dart. Los títulos coinciden en PRE-A1…B1 y C2; B2 y C1
  divergieron (ver `CURRICULUM_ALIGNMENT.md`), así que la ruta se calcula sobre
  `lesson_catalog_index` (espejo servidor del catálogo, 140 lecciones, RLS sin
  políticas) y enriquece con el escenario de BD cuando existe. En B2/C1 los
  pasos llegan sin `scenario_id` y la Ruta los abre por `lesson_key`.

### Banda CEFR del escenario (P-40b)

- `ScenarioBand.plan` resuelve la banda del turno con el nivel real:
  - escenario por encima del alumno → se recorta al nivel real;
  - 2 fallos seguidos (`simplify`) → una banda menos (suelo PRE-A1);
  - 3 turnos limpios (`stretch`) → una banda más (techo C2).
- La banda efectiva viaja en el system prompt (`Target CEFR Level` +
  `LEVEL ADAPTATION`) y decide el saludo inicial, no solo el léxico.
- Objetivos: si el escenario queda por encima, el tutor persigue solo los
  primeros N (40–60 % según el hueco, mínimo 2).
- Refuerzo (P-42): `ensureRemedialLesson` recibe la banda adyacente inferior al
  nivel real. Es la misma llamada de siempre: no añade coste.
- El catálogo cubre las 7 bandas (20 escenarios por nivel e idioma), así que no
  hay que generar contenido para «cubrir el hueco» (verificado en producción).

### Medición disponible

```sql
-- Ruta persistida (vacía hasta que un cliente con esta versión abra el dashboard)
select count(*) filter (where recommended_path_scenarios <> '[]'::jsonb) as con_ruta,
       count(*) as total
from public.user_ai_profiles;

-- Puente entre escenarios y catálogo
select count(*) filter (where lesson_key is not null) as con_puente,
       count(*) as total
from public.scenarios where language_id = 1;

-- Espejo del catálogo que usa el servidor (debe ser 20 por nivel)
select level, count(*) from public.lesson_catalog_index group by level order by level;
```

Estado al cerrar P-40a/P-40b (MCP `supabase`, solo lectura): `scenarios` con
102/140 filas de inglés puenteadas (`lesson_key`) y las 38 restantes de B2/C1
sin equivalente; `lesson_catalog_index` con 140/140 lecciones (20 por nivel);
`user_ai_profiles` sigue con 0 rutas persistidas porque ningún cliente de
producción ejecuta todavía la versión que llama a la RPC. La validación
funcional se hizo en una transacción con un usuario real y `rollback` (ruta de
20 pasos, idempotente, intereses primero y superadas al final; también en B2 con
pasos sin `scenario_id`).
