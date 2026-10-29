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
| `user_ai_profiles.recommended_path_scenarios` | Vacío en producción y sin productor: exigiría una ruta pedagógica por usuario (generación = coste de IA). | Issue de seguimiento creado desde P-40. |
| Subir/bajar **el escenario** a otra banda CEFR | El catálogo tiene `difficulty_level` fijo por escenario; generar contenido adaptado por banda cuesta una llamada `lesson_generation` (maná). | Issue de seguimiento creado desde P-40; hoy el ajuste es léxico dentro del mismo escenario. |
| Errores recurrentes en planes sin maná | `corrections` se puebla con `correction_turn`, que cobra maná; sin maná no hay historial que leer (solo `goal_eval`, que es gratis, pero solo en lecciones con metas). | Issue de seguimiento creado desde P-40. |
| Reordenar el catálogo por `skill_radar` | El radar vive en un provider de presentación; moverlo al repositorio duplica consultas. Se priorizó interés + duración. | No verificable hoy: pendiente de medir impacto antes de añadirlo. |

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

Conclusión honesta: la personalización **está conectada y probada en código**,
pero en producción todavía no hay datos que la alimenten porque los usuarios
actuales no completaron el onboarding con intereses y aún no hay correcciones
registradas. La medición de efecto real queda pendiente de que exista ese dato.
