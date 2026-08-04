# Onboarding Revamp · 01 · Auditoría del Onboarding Actual

> **Proyecto:** TutorSaas / Dungeon of English
> **Alcance:** Flujo de onboarding Flutter (`lib/features/onboarding/`) + evaluación de nivel + persistencia + esquema DB.
> **Método:** Revisión de código verificada (datos reales, referencias `archivo:línea`). Sin inventar comportamiento; sin modificar código.
> **Fecha:** 2026-08-01

---

## 1. Flujo actual (verificado en código)

El onboarding es un `OnboardingScreen` con **3 páginas** controladas por `PageView` (scrolleo deshabilitado, navegación por botón):

```
Page 0: idioma nativo + país + switch de idioma UI + idioma objetivo
Page 1: nivel CEFR (manual) + botón "Examen del Oráculo"
Page 2: creación de personaje (CharacterCreationWizard)
```

- Archivo principal: `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (**728 líneas**).
- `PageView` con las 3 páginas: `onboarding_screen.dart:311-319`.
- Navegación y validación: `_nextPage()` en `onboarding_screen.dart:96-134` (valida idioma nativo en página 0 y nivel CEFR en página 1; al terminar ejecuta `_completeOnboardingAndPurchase`).

### Página 0 — Idioma nativo + país + switch + idioma objetivo
Método `_buildNativeLanguageAndCountryPage` en `onboarding_screen.dart:372-590`. **Mezcla 4 decisiones del usuario en una sola página:**

| Decisión | UI | Evidencia |
|---|---|---|
| Idioma nativo | Lista de 8 idiomas con `GlassCard` (`_nativeLanguages`) | `onboarding_screen.dart:50-59` (datos), `398-450` (render) |
| País de origen | `DropdownButton` con 11 países (`_countries`) | `onboarding_screen.dart:61-73` (datos), `453-487` (render) |
| Idioma de la interfaz | `Switch` "App Interface Language" | `onboarding_screen.dart:38` (estado), `490-531` (render) |
| Idioma objetivo | Lista de 4 idiomas con `GlassCard` (`_targetLanguages`) | `onboarding_screen.dart:75-80` (datos), `534-585` (render) |

### Página 1 — Nivel CEFR manual + Examen del Oráculo
Método `_buildLevelPage` en `onboarding_screen.dart:593-727`:

- **Botón "EXAMEN DEL ORÁCULO (TEST)"** (`onboarding_screen.dart:611-660`) que navega a `/oracle-test` vía `context.push('/oracle-test')` (`onboarding_screen.dart:615`).
- **Selección manual de nivel CEFR** (A1–C2) con badges/títulos/descripciones (`_levels` en `onboarding_screen.dart:82-89`, render en `663-723`). Estado `_selectedCefrCode` (`onboarding_screen.dart:39`).

### Página 2 — Creación de personaje
Método `_buildCharacterCreationPage` en `onboarding_screen.dart:359-371` → delega en `CharacterCreationWizard` (widget independiente, `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`, 211 líneas):

- Clase (warrior/mage/rogue) + avatar (6 opciones con colores) + nombre.
- **Ya usa tokens de diseño** (`GlassCard`, `AppColors`): `character_creation_wizard.dart:156` (GlassCard), `34-47` (colores vía AppColors), `35-37` (clases), `40-47` (avatars).
- Al completar devuelve `CharacterCreationData(name, playerClass, avatarIndex)` (`character_creation_wizard.dart:190-194`).

### Evaluación de nivel
- **`/oracle-test` → `OracleConversationScreen`** (`lib/features/onboarding/presentation/screens/oracle_conversation_screen.dart`, 393 líneas): evaluación CEFR por **heurística de longitud de palabras**.
  - Umbrales: `_minWordsA2=6`, `_minWordsB1=12`, `_minWordsB2=20`, `_minWordsC1=32` (`oracle_conversation_screen.dart:64-67`).
  - `_computeLevel()`: promedio de palabras por respuesta → A1 < 6, A2 6–11, B1 12–19, B2 20–31, C1 ≥ 32 (`oracle_conversation_screen.dart:78-87`).
  - **El input es un `TextField` de texto escrito** (`oracle_conversation_screen.dart:273-292`), a pesar de que la tarjeta `SystemWindow` anuncia "RESPONDE CON TU VOZ / DI TU RESPUESTA EN INGLÉS" (`oracle_conversation_screen.dart:267-269`). No usa el pipeline de voz (no STT, no TTS).
  - Persiste vía `savePlacementResult` (`oracle_conversation_screen.dart:108-114`) con `learningGoal='conversational'` y `mainDifficulty='speaking_fluency'` **hardcodeados** y `quizScore=_answers.length`.
- **`/oracle-quiz` → `PlacementTestScreen`** (`lib/features/onboarding/presentation/screens/placement_test_screen.dart`, 692 líneas): test de opción múltiple escrito (NO conversacional) en 4 pasos (objetivo, obstáculo, quiz de 3 preguntas, resultado).
  - Quiz de 3 preguntas de opción múltiple: `placement_test_screen.dart:58-84`.
  - `_computeLevel()` por puntaje: 0→A1, 1→A2, 2→B1, 3→B2 (`placement_test_screen.dart:89-95`).
  - Persiste vía `savePlacementResult` (`placement_test_screen.dart:192-198`).
  - **Es huérfano del flujo**: solo está registrado en `lib/app/router.dart:42-43`; el onboarding navega únicamente a `/oracle-test` (`onboarding_screen.dart:615`). No hay ninguna otra referencia a `PlacementTestScreen` ni a `/oracle-quiz` en el código.

### Persistencia
`saveOnboardingData` en `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart` (206 líneas):

1. Upsert en `users` (`native_language`, email, display_name) — `onboarding_repository_impl.dart:31-37`.
2. Get-or-create `languages` (crea si no existe) — `onboarding_repository_impl.dart:43-68`.
3. Get-or-create `cefr_levels` (crea si no existe) — `onboarding_repository_impl.dart:71-96`.
4. Upsert `user_language_profiles` (`cefr_level_id`, `xp_points`, `current_streak`) — `onboarding_repository_impl.dart:99-119`.
5. Upsert `user_settings` (`daily_goal_minutes`, `correction_style`, `tutor_personality`, `interests`, `motivation`) — `onboarding_repository_impl.dart:122-136`.
6. Upsert `user_ai_profiles` (`pedagogical_summary`, `learning_style`, `focus_areas`, `tutor_prompt_instructions`) — `onboarding_repository_impl.dart:139-155`.

Complementariamente, `_completeOnboardingAndPurchase` (`onboarding_screen.dart:149-212`):
- Actualiza `users.country_code` (`onboarding_screen.dart:178-180`).
- Actualiza perfil con `updateUserProfile(displayName: _characterName, avatarUrl: _characterClass, ...)` (`onboarding_screen.dart:184-189`). **Nota:** `avatarIndex` (los 6 avatares) se recoge en el wizard pero **no se persiste** — la URL del avatar se setea con la clase del personaje.
- Aplica idiomas vía `userLanguageProvider` / `localeProvider` (`onboarding_screen.dart:169-175`, `197-201`).

`savePlacementResult` (`lib/features/onboarding/presentation/providers/placement_providers.dart:23-60`) solo:
1. Obtiene/usa `cefr_levels.id` por código (fallback `id=1`) — `placement_providers.dart:32-42`.
2. Upsert `user_language_profiles` con `cefr_level_id` y `language_id` fijo `1` (inglés) — `placement_providers.dart:45-51`.
3. Escribe en `users.bio` un string `[Stats|...] Goal: ... | Obstacle: ... | Quiz: ...` — `placement_providers.dart:55-59`.

### Esquema DB
- `public.cefr_levels`: `id`, `code`, `name`, `description`, `order_index`, `difficulty_range`, `color` (`supabase/migrations/full_database_decoupling.sql:16-25`). Seed A1–C2 (`full_database_decoupling.sql:32-41`; A2/B2/C1/C2 agregados en `supabase/migrations/20260721000001_fix_cefr_levels.sql:5-10`).
- **No existe columna ni tabla para el rango del juego** (E, D, C, B, A, S, SS, SSS). El concepto de rango de juego existe en código como catálogo de títulos (`hunter_catalog.dart:8` → `rankTier: F, E, D, C, B, A, S, SS, SSS`) y como mapeos CEFR→rango informales/hardcodeados:
  - `profile_edit_screen.dart:295-298`: A1→D-RANK, A2→C-RANK, B1→B-RANK, B2→A-RANK, else→S-RANK.
  - `chat_rooms_screen.dart:814-824`: banda CEFR → emblema hierro/plata/oro.
  - `docs/09_RPG/narrative.md:19`: la narrativa define el CEFR (A1→C2) como "jerarquía de rango de cazador" — no usa E..SSS.

---

## 2. Hallazgos

### H1. Página 1 sobrecargada: 4 decisiones del usuario en una sola pantalla
**Evidencia:** `onboarding_screen.dart:372-590` (idioma nativo `398-450`, país `453-487`, switch `490-531`, idioma objetivo `534-585`).

**Problema:** Alto costo cognitivo y fricción de entrada. El usuario debe resolver 4 decisiones (idioma nativo, país, idioma de UI, idioma objetivo) antes de poder continuar; además, el `SingleChildScrollView` obliga a scroll en pantallas pequeñas (el contenido excede el viewport). Se contradice el principio de una decisión por paso y dificulta el análisis de abandono por paso.

**Impacto:** Mayor tasa de abandono en el primer paso, peor telemetría (no se puede saber en qué decisión se pierde el usuario) y sesgo de carga en el primer 30% del onboarding.

---

### H2. Selección manual de nivel CEFR
**Evidencia:** Lista `_levels` A1–C2 en `onboarding_screen.dart:82-89`; render y selección en `663-723`; validación obligatoria en `110-120`.

**Problema:** El usuario puede **auto-clasificarse**, lo que contradice el objetivo del producto de clasificar por evaluación (IA/Oráculo). Un autodiagnóstico de nivel es subjetivo (sobre/subestimación habitual: A1/C1 erróneos, falsos B1) y alimenta perfiles de aprendizaje con datos poco confiables (`user_language_profiles.cefr_level_id`). El texto de la propia página lo reconoce al ofrecer "Selecciona tu nivel actual o realiza el Examen del Oráculo" (`onboarding_screen.dart:606`).

**Impacto:** Calibración incorrecta del tutor IA y de las misiones/escenarios desde el día uno; contenido desalineado con el nivel real; doble fuente de verdad (manual vs. examen) sin reconciliación.

---

### H3. La "evaluación" del Oráculo es una heurística de longitud de palabras, no IA ni voz
**Evidencia:** Umbrales en `oracle_conversation_screen.dart:64-67`; `_computeLevel()` por promedio de palabras en `78-87`; input de **texto escrito** (`TextField`) en `273-292`; tarjeta engañosa "RESPONDE CON TU VOZ" en `267-269`.

**Problema:**
- El nivel se estima por **cantidad de palabras**, no por calidad lingüística (gramática, vocabulario, coherencia). Responder con frases largas pero incorrectas sube el nivel; respuestas breves pero correctas lo bajan. No es IA ni voz.
- El copy de UI promete respuesta por voz ("RESPONDE CON TU VOZ", "DI TU RESPUESTA EN INGLÉS", `oracle_conversation_screen.dart:268-269`) pero el control real es un campo de texto — expectativa rota.
- `learningGoal` y `mainDifficulty` se persisten **hardcodeados** (`'conversational'`, `'speaking_fluency'`) sin preguntar al usuario (`oracle_conversation_screen.dart:111-112`), pese a que `/oracle-quiz` sí los pregunta (`placement_test_screen.dart:43-55`).
- Nivel máximo posible C1; nunca C2. A1 es el valor por defecto cuando no hay respuestas (`oracle_conversation_screen.dart:79`).

**Impacto:** Clasificación de bajo valor predictivo; experiencia rota respecto a la promesa de "Oráculo" (voz/IA); datos de perfil poco fiables que arrastran a tutor, misiones y economía.

---

### H4. Dos evaluaciones duplicadas: `/oracle-test` vs `/oracle-quiz`
**Evidencia:** `/oracle-test` → `OracleConversationScreen` (`router.dart:38-40`); `/oracle-quiz` → `PlacementTestScreen` (`router.dart:42-44`). Ambos persisten con `savePlacementResult` (`oracle_conversation_screen.dart:108-114`, `placement_test_screen.dart:192-198`) y ambos calculan nivel con heurísticas propias e inconsistentes entre sí:
- Oráculo (texto libre): umbrales de palabras (`oracle_conversation_screen.dart:64-87`).
- Quiz (opción múltiple): puntaje 0–3 → A1..B2 (`placement_test_screen.dart:89-95`).

**Problema:** `PlacementTestScreen` (/oracle-quiz) **es huérfano**: no se referencia desde ningún otro punto del código (solo registro de ruta). Duplica el propósito de `/oracle-test` con otra mecánica (cuestionario escrito de opción múltiple) y otra regla de cálculo, generando resultados inconsistentes según la ruta que se tome. El header del quiz incluso reclama ser pasos "9/12" de un onboarding de 8 pasos (`placement_test_screen.dart:326`).

**Impacto:** Ambigüedad de producto (¿cuál es el examen canónico?), resultados CEFR divergentes según la ruta, código muerto mantenido, confusión en la telemetría.

---

### H5. No existe mapeo formal CEFR → rango del juego (E..SSS)
**Evidencia:** `cefr_levels` no tiene columna de rango de juego (`full_database_decoupling.sql:16-25`). El rango de juego existe solo como catálogo de títulos (`hunter_catalog.dart:8`) y como mapeos informales/hardcodeados:
- `profile_edit_screen.dart:295-298` (D-RANK…S-RANK, sin SS/SSS).
- `chat_rooms_screen.dart:814-824` (emblemas hierro/plata/oro por banda).
- La narrativa usa CEFR como rango (`docs/09_RPG/narrative.md:19`), no E..SSS.

**Problema:** No hay un mapeo central, único y persistido de CEFR → rango del juego. Los rangos se derivan ad-hoc y de forma inconsistente entre pantallas (perfil, gremio), y el rango E..SSS del catálogo de títulos (`hunter_catalog.dart`) no se conecta con el nivel CEFR persistido en `user_language_profiles`.

**Impacto:** Progresión de juego desacoplada del nivel lingüístico; incoherencias visuales entre pantallas (rango D..S en perfil vs. emblemas en gremio vs. títulos F..SSS); sin base para calcular recompensas/desbloqueos por rango.

---

### H6. No se persisten fortalezas/debilidades ni explicación del resultado
**Evidencia:** `savePlacementResult` solo recibe `cefrLevel`, `learningGoal`, `mainDifficulty`, `quizScore` (`placement_providers.dart:23-60`); en `/oracle-test` goal y difficulty van hardcodeados (`oracle_conversation_screen.dart:108-114`); el resultado final en UI es "Nivel X desbloqueado" sin desglose (`oracle_conversation_screen.dart:305-332`). El modelo `PlacementResult` sí define `levelName`, `levelDescription`, `studyPlan` (`placement_result.dart:13-23`) pero **esos campos no se envían a la DB** (el repositorio los ignora). Las fortalezas/debilidades se escriben solo como texto plano en `users.bio` (`placement_providers.dart:55-59`), no como columnas estructuradas.

**Problema:** Se pierde el valor pedagógico de la evaluación: el usuario no recibe feedback de qué hizo bien/mal ni por qué se le asignó ese nivel, y el sistema no guarda datos estructurados (fortalezas, debilidades, explicación, respuestas) para calibrar al tutor IA o mostrar progreso.

**Impacto:** Menor confianza en la evaluación (sin justificación), sin insumo para personalizar el plan de estudio ni para tracking longitudinal; información no estructurada (bio) frágil.

---

### H7. Creación de personaje: ya migrada a tokens, pero con integración incompleta
**Evidencia:** `character_creation_wizard.dart` usa `GlassCard` (`:156`) y `AppColors` en toda la UI (`:35-47`, `:157`, `:164`, `:172`, etc.). Integración en `onboarding_screen.dart:359-371` y persistencia en `onboarding_screen.dart:184-189` (`updateUserProfile(displayName, avatarUrl: _characterClass, ...)`).

**Problema / observaciones de integración:**
- `avatarIndex` (6 avatares con colores, `character_creation_wizard.dart:40-47`) se captura en `CharacterCreationData` (`:10-16`, `:190-194`) pero **OnboardingScreen lo descarta** (`onboarding_screen.dart:362-364` solo lee `name` y `playerClass`) y se persiste `avatarUrl = _characterClass` (`onboarding_screen.dart:187`), no el avatar elegido.
- No hay persistencia de `avatarIndex` ni en `users` ni en perfiles; al volver a entrar no se restaura la selección.
- Los textos del wizard están hardcodeados en español ("CREA TU PERSONAJE", "NOMBRE DEL CAZADOR", "EL ORÁCULO TE ESPERA" — `character_creation_wizard.dart:74, 89, 202`) en lugar de usar `AppLocalizations` (el resto del onboarding usa `l10n`, p. ej. `onboarding_screen.dart:380, 536, 601`).

**Impacto:** La selección de avatar es cosmética (se pierde), el personaje no es memorable/reversible y el wizard rompe la consistencia i18n del resto del onboarding.

---

## 3. Tabla resumen

| # | Hallazgo | Evidencia (archivo:línea) | Problema clave | Impacto |
|---|---|---|---|---|
| H1 | Página 1 sobrecargada (4 decisiones) | `onboarding_screen.dart:372-590` | Costo cognitivo + fricción en el primer paso | Abandono alto, telemetría pobre |
| H2 | Selección manual de nivel CEFR | `onboarding_screen.dart:82-89, 110-120, 663-723` | Contradice clasificación por evaluación/IA | Perfil descalibrado desde el día 1 |
| H3 | Evaluación por heurística de palabras (no IA/voz) | `oracle_conversation_screen.dart:64-87, 267-292` | Nivel estimado por cantidad de palabras; UI promete voz | Clasificación poco confiable; expectativa rota |
| H4 | `/oracle-test` y `/oracle-quiz` duplican propósito | `router.dart:38-44`; `oracle_conversation_screen.dart:108-114`; `placement_test_screen.dart:89-95, 192-198` | Dos reglas de nivel inconsistentes; `/oracle-quiz` huérfano | Resultados divergentes, código muerto |
| H5 | Sin mapeo CEFR → rango de juego (E..SSS) | `full_database_decoupling.sql:16-25`; `hunter_catalog.dart:8`; `profile_edit_screen.dart:295-298`; `chat_rooms_screen.dart:814-824` | Rangos ad-hoc e inconsistentes entre pantallas | Progresión de juego desacoplada del nivel |
| H6 | No se persisten fortalezas/debilidades/explicación | `placement_providers.dart:23-60`; `placement_result.dart:13-23`; `oracle_conversation_screen.dart:108-114` | Solo `cefrLevel` + `quizScore`; el resto en `bio` | Sin feedback pedagógico ni datos estructurados |
| H7 | Personaje migrado a tokens pero integración incompleta | `character_creation_wizard.dart:10-16, 190-194`; `onboarding_screen.dart:362-364, 184-189` | `avatarIndex` descartado; textos hardcodeados en español | Avatar se pierde; inconsistencia i18n |

---

## 4. Observaciones adicionales verificadas

- **Navegación tras el examen:** tanto `/oracle-test` como `/oracle-quiz` redirigen a `/home` al terminar (`oracle_conversation_screen.dart:117`, `placement_test_screen.dart:200`), sin regresar al onboarding ni continuar el flujo de creación de personaje (el nivel asignado en el examen no se refleja de vuelta en el paso 2 del onboarding).
- **Fallo tolerado de forma silenciosa:** si `saveOnboardingData` o el guardado de país/perfil fallan, el flujo continúa y navega a `/home` igualmente (try-catch con `catch (_) {}` y redirección en `onboarding_screen.dart:181, 192, 203-211`; `placement_providers.dart:42, 51, 59`). Puede dejarse al usuario con perfil incompleto sin aviso.
- **`language_id` fijo = 1 (inglés)** en `savePlacementResult` (`placement_providers.dart:48`) sin resolver el idioma objetivo real.
- **C2 inalcanzable** en la evaluación del Oráculo (máx. C1, `oracle_conversation_screen.dart:82`) y en el quiz (máx. B2, `placement_test_screen.dart:93-94`), pese a existir como nivel en `cefr_levels`.
- **Contador heredado:** el header del quiz dice "9/12" como continuación de "8 onboarding screens" (`placement_test_screen.dart:326`), vestigio de un diseño previo.

---

## 5. Próximos pasos sugeridos (a detallar en `02_Revamp_Plan.md`)

1. **Dividir página 1** en pasos de una sola decisión (idioma nativo → país → idioma de UI → idioma objetivo) con telemetría por paso.
2. **Canonizar la evaluación**: una sola vía de clasificación (oráculo), idealmente IA + voz reutilizando el pipeline existente (Groq STT → DeepSeek), y eliminar o reciclar `/oracle-quiz`.
3. **Reemplazar la heurística de palabras** por evaluación por IA (o al menos por respuestas con scoring cualitativo) y alinear el copy "RESPONDE CON TU VOZ".
4. **Definir y persistir el mapeo CEFR → rango del juego** (E..SSS) en una sola fuente de verdad (columna/tabla en DB + utilidad central en Dart), reutilizando el catálogo de títulos existente.
5. **Persistir fortalezas/debilidades/explicación** como campos estructurados (nueva tabla `placement_assessments` o columnas en `user_language_profiles`) y mostrar feedback post-evaluación.
6. **Integrar por completo la creación de personaje**: persistir `avatarIndex`, restaurar selección al volver, y pasar textos a `AppLocalizations`.
