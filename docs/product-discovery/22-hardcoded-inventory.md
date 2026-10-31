# 22 · Inventario de lo hardcodeado (Parte B)

> Barrido del **31-oct-2026** sobre `lib/`, `supabase/functions/` y
> `supabase/migrations/` del worktree `p14-ai-usage` (`origin/master`).
> Decisiones aplicadas: [_decisions.md](_decisions.md) §«Regla de ubicación».
>
> **Criterio de la regla**: contenido y parámetros de balance → **BD**; lógica,
> algoritmos, tokens de diseño, textos de interfaz (`.arb`) y validaciones de
> seguridad → **código**; **prompts → BD, y la Edge Function los lee de allí,
> nunca se envían al cliente**.
>
> Tipos: **contenido** · **balance** · **lógica** · **seguridad** · **interfaz**.
> Acción: **migrar a BD** · **mantener (razón técnica)** · **mover a configuración**.

---

## 0. Resumen

| Tipo | Hallazgos | Con equivalente en BD (sí/parcial) | Duplicado o divergente |
|---|---:|---:|---:|
| Contenido | **13** | 4 | 6 |
| Balance | **21** | 9 | 4 |
| Lógica | **10** | 6 | 4 |
| Seguridad | **18** (9 de código + 9 de permisos) | 9 (los permisos **son** BD) | 8 |
| Interfaz | **5** | 0 | 1 (contra `.arb`) |
| **Total** | **67** | **28** | **23** |

Lectura rápida:

- `[HECHO]` **El currículo vive en Dart**, no en la BD: 140 lecciones y 312 KB
  en `lesson_catalog.dart`, mientras las tablas de metas y frases de escenario
  están **vacías** (`scenario_goals` = 0, `scenario_phrases` = 0).
- `[HECHO]` **Los prompts se envían desde el cliente** en 6 ubicaciones; el
  `llm-proxy` solo limita tamaño, no sustituye el prompt.
- `[HECHO]` El sistema de títulos está **triplicado** (Dart, tabla
  `hunter_titles` y `.arb`) y la tabla no la lee nadie.
- `[HECHO]` Los parámetros de economía que más se muestran al jugador
  (recompensa diaria, +100 XP/+15 gemas por nodo, drop) están en Dart y **no
  tienen fila en BD**.
- `[HECHO]` 12 funciones SQL se redefinen **3 o más veces** en migraciones
  (`track_ai_audio_time` 5 veces): el repo no es fuente de verdad del esquema.

---

## 1. Contenido (13)

| # | Archivo:línea | Qué es | ¿BD? | ¿Divergencia? | Acción |
|---|---|---|---|---|---|
| C-01 | `lib/features/dashboard/data/models/lesson_catalog.dart:1-4621` | **140 lecciones** completas (título, nivel, objetivo, contexto, rol del tutor, rol del alumno, dificultad) — 312 KB | Parcial: `scenarios` (500 UUID) y `lesson_catalog_index` (140 ids/títulos) | **Sí**: el currículo del cliente tiene ids (`prea1_hello_hello`) que **no existen** en `scenarios`; son dos currículos distintos | **Migrar a BD** (D-09); dejar en Dart solo el lector de la copia local |
| C-02 | `lesson_catalog.dart` (554 `ScenarioGoalItem`, 553 `UsefulPhraseItem`) | Metas, palabras clave, frase de ejemplo y traducción de cada lección | No: `scenario_goals` 0 filas, `scenario_phrases` 0 filas | **Sí**: contenido pedagógico completo fuera de BD | **Migrar a BD** |
| C-03 | `lesson_catalog.dart` (142 `scenarioContext`) | Texto que se inyecta como rol del tutor en el prompt | Parcial: `scenarios.context` sí tiene contexto (500 filas), pero de **otro** currículo | **Sí** | **Migrar a BD** y que el prompt lo lea el servidor |
| C-04 | `lib/features/dashboard/data/models/hunter_skill_titles.dart:91-122` | **24 títulos** de habilidad (nombre, descripción, rareza, umbral) | **Sí**: `hunter_titles` = 24 filas idénticas | No hoy; **triplicado** (Dart + tabla + `.arb`) y la tabla **no se lee** | **Migrar a BD** (usar la tabla) y borrar el catálogo Dart |
| C-05 | `lib/features/dashboard/data/models/hunter_catalog.dart:32-121` | **15 títulos de caza** (nombre, tier F–SSS, icono, descripción) | No | — | **Migrar a BD** |
| C-06 | `hunter_catalog.dart:124-215` | **10 monstruos/jefes** únicos (Oráculo, 3 regulares, 6 jefes de piso A1–C2) con nombre, nivel, descripción y avatar | No | — | **Migrar a BD** |
| C-07 | `lib/features/onboarding/domain/models/hunter_class.dart:32-121` | **8 clases** de cazador (elemento, aura, avatar) | No | — | **Migrar a BD** si la clase llega a tener efecto; si es solo identidad, mover a configuración |
| C-08 | `lib/features/onboarding/domain/models/cefr_rank.dart:38-48` | Descripciones narrativas de los 9 rangos («Deidad del Idioma») | No | — | **Migrar a BD** (catálogo de rangos) |
| C-09 | `lib/features/economy/domain/models/drop_loot.dart:54-72` | **8 nombres** de botín (Fragmento de Maná, Pergamino del Viento, Corona del Vacío…) | No: el servidor solo devuelve `rarity`, `xp`, `gold` | **Sí**: `DropLoot.fromServer` fija el título «Bolsa de oro» e ignora estos nombres | **Decidir**: migrar a BD o borrar el pool (código muerto) |
| C-10 | `lib/features/economy/data/repositories/economy_repository_impl.dart:484-498` | **5 diálogos de relleno** en inglés insertados como «pergaminos» | No: `player_pergaminos` = 0 filas | **Sí**: contradice D-05 y D-09 | **Eliminar**; el pergamino debe ser reintento (D-05) |
| C-11 | `supabase/functions/reactivation-email/templates.ts:52-…` | Copy del email de reactivación en es/en/pt (asunto, cuerpo, CTA) | No | — | **Mover a configuración** (`email_templates`) si marketing lo edita |
| C-12 | `lib/features/dashboard/presentation/widgets/league_leaderboard_widget.dart:37-41` | **Ranking falso**: 4 nombres + XP (Elena Rostova 3.240, Marco Silva 2.890, Sophie 2.100, Klaus 1.850) como *fallback* | Parcial: `get_leaderboard` | **Sí**: si la RPC falla, el jugador ve un ranking inventado sin aviso | **Eliminar** el fallback o marcarlo como demo en UI |
| C-13 | `lib/features/onboarding/data/country_catalog.dart:28-…` | Catálogo de países/nacionalidades | No | — | **Mantener** (dato ISO estable, sin valor de negocio) |

---

## 2. Balance (21)

| # | Archivo:línea | Qué es | ¿BD? | ¿Divergencia? | Acción |
|---|---|---|---|---|---|
| B-01 | `lib/features/economy/data/repositories/economy_repository_impl.dart:206-219` | **Recompensa diaria**: 5/50/100/300 gemas y 2/5/8/15 pergaminos por racha 0/7/14/30 | **No** | — | **Migrar a BD** (`daily_reward_tiers`) |
| B-02 | `lib/features/economy/presentation/widgets/daily_reward_modal.dart:67-75` | **Copia** de la misma tabla para el preview | No | Duplica B-01 en otra capa (hoy coinciden) | **Migrar a BD** y que la UI lea la misma fuente |
| B-03 | `economy_repository_impl.dart:47` | `bonus = (racha ~/ 7) * 5` invocaciones extra | No | — | **Migrar a BD** o eliminar (contador muerto, L-08) |
| B-04 | `economy_repository_impl.dart:54-70`; `lib/features/economy/presentation/providers/economy_providers.dart:33-36` | Defaults `invocations_max = 20`, `pergaminos_max = 5` | No | **Sí**: dos copias del default en Dart | **Mover a configuración** (una sola constante) |
| B-05 | `lib/features/dashboard/presentation/widgets/learning_path_roadmap.dart:707-708` | Cada nodo anuncia **+100 XP / +15 gemas** | **No** | **Sí**: el servidor no paga gemas por lección; el XP real depende de minutos/metas | **Migrar a BD** o quitar la cifra |
| B-06 | `drop_loot.dart:52-99` | Probabilidades **2/8/25/65 %**, base 15 XP, multiplicadores 1,0/1,5/2,0/3,0 | **Sí**: `claim_session_drop` (`20261026094912_session_drops.sql:76-89`) | No hoy (mismos valores), pero es **código muerto** (`roll()` sin llamadores) | **Eliminar** el duplicado Dart |
| B-07 | `lib/features/missions/domain/models/mission_visibility.dart:43-58` | Techos de misión: diario 10/5/5/1/1 · semanal 15/15/10/3/3 | **Sí**: vista `mission_templates_reachability` | No hoy (idénticos) | **Mantener** el espejo con test de contrato, o leer la vista |
| B-08 | `lib/features/missions/data/repositories/mission_repository.dart:13-19` | Cuotas: 10 activas, 3 de gremio, 3 secretas, 14 días de antigüedad | **Sí**: `rotate_daily_missions` usa 10 | No hoy | **Migrar a BD** (parámetros del cron y de la UI) |
| B-09 | `lib/features/boss_exam/domain/services/boss_exam_rules.dart:13-19` | Examen de jefe: 8 turnos, 5 respuestas, 12 min | Parcial: servidor exige 5 respuestas y 25 palabras; 12 h de cooldown | **Sí**: el límite de 12 min y los 8 turnos **solo existen en el cliente** | **Migrar a BD** los umbrales; el corte de turnos es lógica de UI |
| B-10 | `lib/features/conversation/presentation/providers/conversation_providers.dart:2613-2620` | Bonus CEFR del aura: A2=1, B1=2, B2=3, C1=4, C2=5 | **Sí**: misma escala en `close_session` | No hoy | **Mantener** (lógica de cálculo), pero en un solo sitio |
| B-11 | `lib/features/dashboard/presentation/screens/settings_screen.dart:1082-1121` | Opciones de meta diaria: **10/15/30/60** | Parcial: `user_settings.daily_goal_minutes` (default 15) | — | **Mover a configuración** |
| B-12 | `lib/features/dashboard/domain/models/hunter_level.dart:13-18` | **1.000 XP por nivel** | **Sí**: `economy_level` | No hoy | **Mantener** como espejo documentado |
| B-13 | `lib/features/dashboard/domain/models/aura_system.dart:142-159` | Pesos del «poder de aura» (0,25/0,25/0,20/0,10/0,10/0,05/0,05) y cortes de tier (0,25/0,45/0,65/0,85) | No | — | **Mover a configuración** (afecta a lo que se muestra como prestigio) |
| B-14 | `supabase/functions/llm-proxy/index.ts:51-66` | Topes de tokens (200 / 600 / 1.200 para `oracle_eval`), modelo permitido, 30 req/min, 10 MB de audio | No | — | **Mantener** (validación de seguridad §6) |
| B-15 | `supabase/functions/llm-proxy/validation.ts:11-13` | 40 mensajes, 4.000 caracteres/mensaje, 24.000 totales | No | — | **Mantener** (seguridad) |
| B-16 | `supabase/functions/evaluate-placement/index.ts:57-74` | 40 respuestas / 2.000 chars / 20.000 totales; 5 respuestas y 25 palabras de evidencia; rúbrica media ≥65 y mínima ≥45; cooldown 12 h | No | — | **Migrar a BD** los umbrales de rúbrica y del jefe; mantener los topes de payload |
| B-17 | `supabase/functions/lesson-generator/index.ts:53` | Tope de coste `MAX_LESSON_COST_MANA = 300` | Parcial: `ai_action_costs.lesson_generation` = 100 | No | **Mantener** como *circuit breaker* técnico |
| B-18 | `lib/features/onboarding/domain/models/mini_conversation_script.dart:23,46-60` | Conversación de prueba: **2 turnos** / 60 s | No | — | **Migrar a BD** (forma parte del onboarding configurable) |
| B-19 | `lib/features/dashboard/domain/models/streak_rules.dart:9-11,36` | Racha cuenta con ≥3 min o ≥1 meta; aviso 6 h antes de medianoche | **Sí**: `register_practice` | Parcial: el 6 h es solo cliente | **Mantener** (espejo de UI); mover el 6 h a configuración |
| B-20 | `lib/features/corrections/domain/models/turn_correction.dart:39-41` | Máx. 3 correcciones por turno; 240/320 caracteres | No | — | **Mantener** (validación de payload) |
| B-21 | `lib/features/corrections/domain/models/correction_turn_policy.dart:36` | Máx. 6 evaluaciones de corrección por sesión | No | — | **Mantener** (control de coste) |

---

## 3. Lógica (10)

| # | Archivo:línea | Qué es | ¿BD? | ¿Divergencia? | Acción |
|---|---|---|---|---|---|
| L-01 | `mission_visibility.dart:26-98` | Espejo de la vista `mission_templates_reachability` (visibilidad y alcanzabilidad) | **Sí** | No hoy; dos implementaciones a mantener en paralelo | **Mantener** con test de contrato contra la vista |
| L-02 | `cefr_rank.dart:13-35` vs `evaluate-placement/index.ts:32-42` vs `cefr_levels` (BD) | Tres copias del mapeo CEFR↔rango y del orden CEFR | **Sí** | **Sí, latente**: añadir un nivel exige tocar 3 sitios; el TS no tiene PRE-A1 en `RANK_BY_CEFR` | **Mantener** la lógica, **mover la tabla de rangos a BD** |
| L-03 | `boss_exam_rules.dart:40-69` | Veredicto local (sube solo con nivel mayor **y** rúbrica aprobada) | Parcial: `evaluate-placement` decide en servidor | No | **Mantener** (fallback explícito), documentar que no manda |
| L-04 | `streak_rules.dart:14-26` | `nextStreak` espejo de `register_practice` | **Sí** | No | **Mantener** (solo UI) |
| L-05 | `aura_system.dart:126-150` | `computePower` solo en cliente: el «poder» no se persiste | No | — | **Mantener** (visual) o mover a BD si el aura debe gobernar algo |
| L-06 | `lib/features/dashboard/domain/models/title_evaluator.dart:13-20,52-76` | Umbrales y **decisión** de qué título gana el jugador | Parcial: `hunter_titles.threshold` | **Sí**: el cliente decide y escribe `user_titles`; la BD solo almacena | **Migrar a BD** la concesión (RPC), mantener el cálculo si se replica |
| L-07 | `drop_loot.dart:75-99` | `DropLoot.roll()` con `Random` local | No | Código muerto | **Eliminar** |
| L-08 | `economy_repository_impl.dart:78-106` | `useInvocation` / `canInvoke` (cuota de 20/día) | No | **Sí**: `useInvocation` **no se llama nunca**; la cuota no existe | **Eliminar** o implementar |
| L-09 | `supabase/migrations/20260819_fix_mana_consume.sql` (`consume_mana`) | Regla de negocio por **string** `v_plan_id = 'plebeyo'` | **Sí** (`subscription_plans.tier`) | **Sí**: un plan gratuito con otro `id` perdería el tope diario | **Mantener** la lógica, pero comparar por `tier`/`class_name` |
| L-10 | `aura_system.dart:71` | `_maxRankIndex = 8` (tope de la escala F–SSS) | No | — | **Mantener** con la escala en un solo sitio (L-02) |

---

## 4. Seguridad (18: 9 de código + 9 de permisos)

| # | Archivo:línea | Qué es | ¿BD? | ¿Divergencia? | Acción |
|---|---|---|---|---|---|
| S-01 | `lib/features/conversation/data/repositories/conversation_repository_impl.dart:262-301`, `:426-435`, `:628-…` | **3 prompts completos** (evaluador de metas, carisma, curador de vocabulario) enviados como `role: system` | **No** | **Sí**: viola «prompts → BD, nunca al cliente» | **Migrar a BD**; el `llm-proxy` debe componer el prompt por `action_code` |
| S-02 | `lib/features/conversation/presentation/providers/conversation_providers.dart:1261-1315` | Prompt del **Oráculo** (placement y promoción) en el cliente | No | **Sí** | **Migrar a BD** |
| S-03 | `lib/features/conversation/domain/services/tutor_prompt_builder.dart:132-260` | Prompt del **tutor** (rol, nivel, perfil, modo corrección) | No | **Sí** | **Migrar a BD** (plantilla por `action_code` + variables) |
| S-04 | `lib/features/corrections/domain/models/correction_prompt.dart:25-…` | Prompt del **coach de correcciones** | No | **Sí** | **Migrar a BD** |
| S-05 | `lib/features/onboarding/domain/models/mini_conversation_script.dart:46-60` | Prompt de **Mira, la tabernera** (onboarding) | No | **Sí** | **Migrar a BD** |
| S-06 | `lib/features/chat_rooms/presentation/widgets/guild_master_floating_banner.dart:133-…` | Prompt del **Maestre del gremio** | No | **Sí** | **Migrar a BD** |
| S-07 | `supabase/functions/lesson-generator/index.ts:199-227`; `evaluate-placement/index.ts:88-127` | Prompts **en la Edge Function** (buena ubicación técnica, mala según D-09) | **No** | — | **Migrar a BD** y que la función los lea |
| S-08 | `lib/core/constants/api_constants.dart:10,15,65` | `SUPABASE_URL`, **anon key** y `REVENUECAT_API_KEY` como `defaultValue` | n/a | No: la anon key y la SDK key son **públicas por diseño** | **Mantener** (razón técnica documentada) |
| S-09 | `api_constants.dart:29,42,52,57`; `hunter_catalog.dart:146-210`; `league_leaderboard_widget.dart:37-41` | URLs de terceros (`api.deepseek.com`, `api.groq.com`, `api.tutorsaas.ai`, `api.dicebear.com`) | No | **Sí**: `api.tutorsaas.ai` ya estaba marcado como **sin uso** en [`../product-audit/02-ARQUITECTURA-TECNICA.md:180`](../product-audit/02-ARQUITECTURA-TECNICA.md) y sigue como `defaultValue` | **Mover a configuración** y borrar el host muerto |

### 4.1 Permisos y guardas (evidencia: consulta a producción, no archivo)

| # | Objeto | Estado | Riesgo |
|---|---|---|---|
| P-01 | `advance_my_missions(text,int)` | `EXECUTE` a `authenticated`; `SECURITY DEFINER`; sin tope superior del delta | Avanza cualquier misión propia por el valor que quiera |
| P-02 | `mission_instances` INSERT/UPDATE propios + `guard_mission_instance` | La guarda fuerza `status`, `current_value`, `is_reward_claimed`… **no `xp_reward`/`gem_reward`** | Crear misión con recompensa arbitraria y cobrarla |
| P-03 | `increment_pergaminos_max(uuid,int)` | `EXECUTE` a `authenticated`, sin tope ni coste | Auto-otorgarse pergaminos |
| P-04 | `player_daily_state` UPDATE propio | Sin guarda de columnas | Reescribir `invocations_max`, `pergaminos_max`, `daily_reward_claimed` |
| P-05 | `spend_currency`, `spend_gems` | `EXECUTE` a `PUBLIC`/`authenticated` | Gasto sin pasar por el catálogo |
| P-06 | `purchase_streak_freeze` | `EXECUTE` a `PUBLIC` y `anon` | Superficie innecesaria |
| P-07 | `consume_mana` | `EXECUTE` a `anon` | Superficie innecesaria |
| P-08 | `user_titles` INSERT | Rol `public` | Cualquiera se concede cualquier título |
| P-09 | `purchaseItem` (`economy_repository_impl.dart:261-338`) | Compra **en cliente**: `spendGems` y luego `UPDATE player_daily_state` | Salta las validaciones de `purchase_cosmetic` |

Estas 9 no son «hardcodes de texto» sino **reglas de seguridad embebidas en
migraciones/permisos**; se listan porque la Parte B incluye seguridad.

---

## 5. Interfaz (5)

| # | Archivo:línea | Qué es | ¿BD? | ¿Divergencia? | Acción |
|---|---|---|---|---|---|
| I-01 | `learning_path_roadmap.dart:713-717` | Snackbar en español hardcodeado («🔒 MAZMORRA BLOQUEADA…») | No | **Sí**: no pasa por `.arb`, se rompe en en/pt | **Mover a `.arb`** |
| I-02 | `learning_path_roadmap.dart:702-706` | Letras mágicas de estado del nodo (`'S'`, `'B'`, `'O'`, `'D'`) | No | — | **Mantener** (lógica de presentación) |
| I-03 | `drop_loot.dart:101-106` | Etiquetas de rareza («COMÚN», «LEGENDARIO») | No | — | **Mover a `.arb`** |
| I-04 | `lib/features/missions/presentation/screens/missions_screen.dart:46-66` | Fallbacks `?? 'Diarias'`, `?? 'Semanales'` | No | — | **Mantener** (fallback de l10n) |
| I-05 | Todo `lib/` | **95** `Color(0x…)` y **419** `EdgeInsets` literales (ver [_baseline.md](_baseline.md)) | n/a | Fuera de alcance de este doc | **Mover a `AppColors`/`AppSpacing`** (deuda ya medida en 04) |

---

## 6. Duplicados entre Dart, SQL y Edge Functions

| Concepto | Dart | SQL | Edge Function | ¿Divergen? |
|---|---|---|---|---|
| Escala CEFR / rango | `cefr_rank.dart:10,13-35,73` | `cefr_levels` | `evaluate-placement:32-42`, `lesson-generator:38` | **Sí, latente** (el TS no mapea PRE-A1) |
| XP por nivel (1.000) | `hunter_level.dart:13-18` | `economy_level` | — | No |
| Títulos de habilidad (24) | `hunter_skill_titles.dart:91-122` | `hunter_titles` (24) | — | No (triplicado con `.arb`) |
| Umbrales de títulos | `title_evaluator.dart:13-20` | `hunter_titles.threshold` | — | No |
| Techos de misión | `mission_visibility.dart:43-58` | vista `mission_templates_reachability` | — | No |
| Cuota de misiones (10/3/3/14) | `mission_repository.dart:13-19` | `rotate_daily_missions` (10) | — | No |
| Drop de sesión (2/8/25/65, 15/10) | `drop_loot.dart:52-99` | `claim_session_drop` | — | No (Dart muerto) |
| Rúbrica del jefe (5/25, 65/45, 12 h) | `boss_exam_rules.dart:13-19` | `boss_exam_status` (12 h) | `evaluate-placement:57-74` | **Sí**: 8 turnos y 12 min solo en Dart |
| Bonus CEFR del aura | `conversation_providers.dart:2613-2620` | `close_session` | — | No |
| Coste de IA por acción | — | `ai_action_costs` | `lesson-generator:127-142` (lo relee) | No (patrón correcto) |
| Prompts | 6 archivos Dart | — | 2 funciones TS | **Sí**: dos familias de prompt incompatibles |
| Currículo | `lesson_catalog.dart` (140) | `scenarios` (500) + `lesson_catalog_index` (140) | `lesson-generator` (inserta en `scenarios`) | **Sí**: dos currículos |

### 6.1 Duplicados dentro de SQL `[HECHO]`

12 funciones se redefinen **3 o más veces** en `supabase/migrations/`
(`track_ai_audio_time` 5; `check_ai_audio_quota`, `get_mana_state`,
`consume_mana`, `rotate_daily_missions`, `refund_mana`, `add_fragments`,
`claim_mission_reward`, `purchase_cosmetic`, `purchase_streak_freeze`,
`boss_exam_status`, `touch_presence`/`leave_table` 3). El repo **no reproduce**
el esquema (33 migraciones se aplicaron desde el SQL Editor), así que la
definición vigente solo se conoce por `pg_get_functiondef`. `[INFERENCIA]`
Cualquier revisión futura leerá una versión obsoleta si confía en el archivo.

---

## 7. Lo que ya está en el sitio correcto (no tocar)

Sirve de patrón para lo demás:

| Elemento | Dónde | Por qué está bien |
|---|---|---|
| Catálogo de cosméticos (40) | `cosmetic_catalog` | contenido + precio en BD |
| Escalones de prestigio (21) | `prestige_ladder` | contenido + umbrales en BD |
| Bolsas de nivel (6) | `level_rewards` | contenido + importes en BD |
| Costes de IA (7) | `ai_action_costs` | balance en BD, leído por la Edge Function |
| Contenido de listening | tablas de ejercicios (map-based) | el cliente solo mapea |
| Escala CEFR narrativa | `cefr_levels` | descripciones en BD |
| Fórmulas de recompensa | `close_session`, `session_drops` | lógica en SQL (servidor), no en cliente |
| `.arb` (en/es/pt) | `lib/l10n/` | textos de interfaz donde deben estar |

---

## 8. Los 5 más peligrosos

| # | Hallazgo | Tipo | Por qué es peligroso | Evidencia |
|---|---|---|---|---|
| 1 | **Prompts en el cliente** (6 sitios) | seguridad | Cualquier build modificada puede cambiar el comportamiento del tutor, el evaluador de metas o el Oráculo; el `llm-proxy` no recompone el prompt. Es la violación más directa de la regla de `_decisions.md` y la más cara de reparar. | `conversation_repository_impl.dart:262,426,628`; `conversation_providers.dart:1261`; `tutor_prompt_builder.dart:132-260`; `correction_prompt.dart:25`; `mini_conversation_script.dart:46` |
| 2 | **`mission_instances`: recompensa no blindada + `advance_my_missions` sin tope** | seguridad | Cadena completa de inflación de XP/gemas: insertar misión con `xp_reward=99.999` → avanzar → cobrar. No requiere root ni claves. | `guard_mission_instance` (no toca `xp_reward`/`gem_reward` en INSERT); política `insert_own_instances`; `routine_privileges` de `advance_my_missions` |
| 3 | **Dos currículos divergentes** | contenido | El jugador ve 140 lecciones de Dart; la BD tiene 500 escenarios distintos y las tablas de metas/frases del currículo Dart están **vacías**. Publicar contenido desde el panel no cambia lo que ve el alumno. | `lesson_catalog.dart` (140 `LessonData`) vs `scenarios` (500) / `lesson_catalog_index` (140) / `scenario_goals` (0) |
| 4 | **Recompensa diaria hardcodeada y rota que falla en silencio** | balance | 5/50/100/300 gemas y 2/5/8/15 pergaminos viven en Dart (duplicados en la UI); `add_gems` no es ejecutable por `authenticated`, así que el `catch (_) → {}` deja al jugador pulsando un botón que nunca paga y sin mensaje. | `economy_repository_impl.dart:206-244`; `daily_reward_modal.dart:67-75`; `routine_privileges` de `add_gems` |
| 5 | **`increment_pergaminos_max` + `player_daily_state` sin guarda** | seguridad/balance | Auto-otorgamiento sin coste de un recurso que D-05 quería convertir en «reintento»: destruye el único sumidero previsto y no deja traza contable (`currency_ledger` = 0). | `increment_pergaminos_max` (`SECURITY DEFINER`, sin tope); política `update_own_daily`; D-05 en `_decisions.md` |

Menciones: `api.tutorsaas.ai` (host muerto que sigue como `defaultValue`),
ranking falso como fallback silencioso y `purchaseItem` comprando en cliente.

---

## 9. No verificable

| Afirmación | Por qué | Qué falta |
|---|---|---|
| Si `api.tutorsaas.ai` sigue operativo | Ya está documentado como «sin uso» en `product-audit/02`; no hay referencia en Edge Functions ni secretos consultables | DNS/HTTP check + decisión de producto |
| Si el contenido de `scenarios` (500) se usa en alguna pantalla | `lesson-generator` inserta ahí; no se encontró lector de `scenarios` en Dart | Rastrear la RPC que sirve escenarios |
| Cuántas de las 140 lecciones de Dart coinciden con `scenarios` | Distinto espacio de ids (slug vs UUID) | Emparejar por título |
| Si `hunter_titles` se usará algún día | 0 lectores en Dart y en `pg_proc` | Decisión de producto (títulos de prestigio vs. habilidad) |
