# 02 — Nuevo Flujo de Onboarding (Propuesta)

> Documento de diseño para el rediseño del onboarding de TutorSaas / Dungeon of English.
> **Estado:** propuesta (sin cambios de código aún). Alcance: `lib/features/onboarding/`, `lib/app/router.dart` (solo lectura).
> **Tono:** Isekai / Webtoon / System HUD — dark only, paleta actual (`AppColors`).

---

## 1. Contexto y problema actual

### 1.1 Estado actual (datos reales del código)

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/onboarding` | `OnboardingScreen` (`onboarding_screen.dart`) | `PageView` de **3 páginas** (no desplazable, `NeverScrollableScrollPhysics`): **P0** idioma nativo + país + switch de interfaz + idioma objetivo mezclados en una sola página; **P1** selección **manual** de nivel CEFR (A1–C2) con botón opcional al examen; **P2** creación de personaje (`CharacterCreationWizard`). |
| `/oracle-test` | `OracleConversationScreen` (`oracle_conversation_screen.dart`) | Evaluación **escrita** por longitud de palabras: umbrales `6/12/20/32` → `A2/B1/B2/C1`. Preguntas desde `oracle_questions` (fallback si vacío). Episodios narrativos (5) + `SegmentedBar`. Al terminar: `savePlacementResult` → `context.go('/home')`. |
| `/oracle-quiz` | `PlacementTestScreen` (`placement_test_screen.dart`) | Test de **opción múltiple** en 4 pasos: objetivo → obstáculo → quiz de 3 preguntas → resultado con plan de estudio. Persiste `savePlacementResult` → `/home`. |

### 1.2 Problemas del flujo actual

1. **Paso 0 sobrecargado:** idioma nativo, país, switch de UI y **idioma objetivo** están todos en la misma página (11 países limitados en un `DropdownButton`; el idioma objetivo está integrado en el paso 1 aunque es un dato conceptualmente distinto).
2. **El usuario elige su propio nivel CEFR a mano** (`_levels` A1–C2) — esto genera autoevaluación sesgada y clases mal colocadas.
3. **Tres evaluaciones duplicadas y divergentes:** `oracle-test` (escrita, por palabras), `oracle-quiz` (opción múltiple) y la selección manual. Cada una termina en `/home` sin devolver al flujo de onboarding → el usuario "se pierde" y nunca crea personaje si entra por una evaluación.
4. **La evaluación no tiene rango de juego** (E–SSS); solo CEFR.
5. **Resultado no explicado:** el usuario no entiende qué significa su nivel ni qué se persistió.
6. **Navegación sin estado compartido:** `OnboardingScreen`, `OracleConversationScreen` y `PlacementTestScreen` no comparten un modelo de onboarding; cada uno persiste por separado.

---

## 2. Objetivo de la propuesta

Un flujo de **pasos separados y explícitos**, donde:

- El idioma nativo, el país y el idioma objetivo son **decisiones independientes**.
- El nivel CEFR **nunca se elige manualmente**: lo determina la **IA** a través de una conversación con el Oráculo (voz + texto).
- La evaluación es un **paso embebido** del flujo (no una ruta huérfana que escapa del onboarding).
- El resultado se muestra con **CEFR + rango de juego (E–SSS)** y una explicación en lenguaje narrativo.
- Toda la información se **persiste una sola vez** al final (o en hitos parciales), evitando fragmentación.

### 2.1 Decisión de diseño clave

> **Un solo evaluador por defecto:** la **Conversación del Oráculo** (voz). El quiz de opción múltiple (`/oracle-quiz`) queda como alternativa para usuarios que no puedan usar voz, accesible desde el paso 4 (enlace secundario).

---

## 3. Propuesta de flujo — 6 pasos

### Vista general

```
WelcomeScreen ('/')
   │
   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ ONBOARDING  (/onboarding — OnboardingScreen v2, PageView ampliado)          │
│                                                                            │
│  [Paso 1] Idioma del Despertar  → idioma NATIVO (solo)                     │
│  [Paso 2] Ciudad/País           → selector independiente con buscador      │
│  [Paso 3] Idioma objetivo       → idioma a APRENDER (pestaña separada)    │
│  [Paso 4] Clasificación por IA  → NO manual. Botón "INICIAR EVALUACIÓN"   │
│              │                                                            │
│              ├─► (embebido / navegación) OracleConversationScreen         │
│              │     conversación con el Oráculo (voz)                      │
│              │     → la IA calcula CEFR + rango de juego                  │
│              └─► (alternativa) /oracle-quiz (opción múltiple)             │
│  [Paso 5] Resultado             → CEFR + rango (E..SSS) + explicación     │
│  [Paso 6] Creación del personaje → clase + avatar + nombre                │
│              │                                                            │
│              ▼  persiste TODO (repo de onboarding)                        │
│  /home  (Dashboard)                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Diagrama de flujo (texto)

```
[Paso 1] Idioma nativo ──► ¿válido? ──no──► snackbar "Selecciona tu idioma nativo"
    │ sí
    ▼
[Paso 2] País ──────────► ¿seleccionado? ──no──► snackbar "Selecciona tu país"
    │ sí
    ▼
[Paso 3] Idioma objetivo ► ¿seleccionado? ──no──► snackbar "Selecciona el idioma a aprender"
    │ sí
    ▼
[Paso 4] Clasificación IA
    │ "INICIAR EVALUACIÓN"
    ├───────────────────────────────► OracleConversationScreen (voz, embebida)
    │                                  │ termina → la IA devuelve cefr + rank
    │ (enlace: "¿No puedes usar voz?") ▼
    ├───────────────────────────────► /oracle-quiz (alternativa)
    │                                  │ termina → cefr + rank (derivado)
    ▼
[Paso 5] Resultado (solo lectura) ──► "CONTINUAR" → botón activo
    ▼
[Paso 6] Personaje ──► nombre válido (≥2 chars) y clase seleccionada
    ▼
Persistir (saveOnboardingData + rank + personaje) ──► /home
```

---

## 4. Estructura técnica

### 4.1 Pantalla contenedora: `OnboardingScreen` (v2)

Se mantiene el patrón actual (validado en producción):

- `PageController` + `PageView` con `NeverScrollableScrollPhysics` (la navegación es **por botón**, nunca por swipe).
- **Header común:** botón atrás (si `_currentStep > 0`) + `SegmentedBar` (o barras segmentadas) con N=6 + contador `X/6`.
- **Footer común:** `RunicButton` (etiqueta contextual por paso). En el paso 6 el botón vive dentro del wizard de personaje (patrón actual).
- `Stack` con `CyberManhwaBackground` (`bgMode` por paso) + orbes de glow (runeViolet / manaCyan) como decoración de fondo.
- **Estado del flujo** en un `StateNotifier` compartido (ver §6), no en variables sueltas del State.

Mapeo de `CyberBgMode` por paso (propuesto):

| Paso | `CyberBgMode` |
|---|---|
| 1 Idioma del Despertar | `onboardingStep0` |
| 2 País | `onboardingStep1` |
| 3 Idioma objetivo | `onboardingStep3` |
| 4 Clasificación IA | `onboardingStep2` |
| 5 Resultado | `onboardingStep5` |
| 6 Personaje | `onboardingStep7` |

### 4.2 Paso 1 — Idioma del Despertar

- **Solo idioma nativo.** Título: **"Idioma del Despertar"**.
- Subtítulo: "Personalizaremos tu viaje de aprendizaje según tu idioma materno."
- **Catálogo completo** de idiomas (misma fuente de datos que `languages` en Supabase). Orden sugerido: idiomas más hablados primero.
- Interacción: lista de tarjetas `GlassCard` seleccionables (patrón del `_nativeLanguages` actual), con badge de código ISO y check.
- **Se elimina** de esta página: selector de país, switch de UI y selector de idioma objetivo (pasan a pasos propios).

**Validación:** `_selectedNativeLanguageCode` no vacío. Snackbar si falta:
> "Selecciona tu idioma nativo para continuar."

### 4.3 Paso 2 — Ciudad/País de origen

- Selector independiente. Título: **"Ciudad/País de origen"**.
- **Países sugeridos primero:** EE.UU. (US), México (MX), Brasil (BR), China (CN), India (IN) — tarjetas rápidas de un toque.
- **Buscador con catálogo completo** (NO limitar a 11 como el `_countries` actual): `TextField` + lista filtrada de `country_code` ISO-3166 con nombre localizado.
- Persistencia: `users.country_code` (ya existe la columna, default `'MX'`).

**Validación:** país no vacío. Snackbar:
> "Selecciona tu país de origen para continuar."

### 4.4 Paso 3 — Idioma objetivo

- Pestaña/paso independiente. Título: **"Idioma objetivo"** o **"El idioma a conquistar"**.
- Separado explícitamente del nativo: el usuario ahora distingue "hablo X" de "quiero aprender Y".
- Fuente: tabla `languages` (misma que el paso 1) pero **excluyendo** el idioma nativo seleccionado del catálogo rápido (se puede mostrar deshabilitado si se busca).
- Tarjetas `GlassCard` con descripción corta del idioma (patrón `_targetLanguages` actual con `desc`).
- Impacto: fija `user_settings.learning_language` y `user_language_profiles.language_id`.

**Validación:** idioma objetivo no vacío y ≠ nativo. Snackbar:
> "Selecciona el idioma que quieres aprender."

### 4.5 Paso 4 — Clasificación por IA (núcleo de la propuesta)

- **NO hay selección manual de nivel.** Sin lista A1–C2 tocable.
- UI: tarjeta narrativa del Oráculo (`GlassCard` con `showRunicCorners: true`, `runicColor: royalGold`, ícono `auto_awesome_rounded`).
- Texto de explicación:
  > "El Oráculo analizará tu dominio del idioma mediante una conversación para determinar tu rango inicial."
- Botón principal `RunicButton`: **"INICIAR EVALUACIÓN"** → abre la conversación con el Oráculo (voz).
- Enlace secundario (texto): **"¿No puedes usar voz? Haz el examen por escrito."** → `/oracle-quiz`.

**Conexión con la evaluación IA:**

- La conversación se ejecuta como **paso embebido del flujo** (pantalla `OracleConversationScreen` presentada vía `context.push`, devolviendo el resultado con `context.pop(PlacementResult)` en lugar de `context.go('/home')`).
- El **nivel estimado** (`_computeLevel`, umbrales de palabras 6/12/20/32) se complementa con un **rango de juego** derivado de la misma señal (ver §5.2).
- Al volver, `OnboardingScreen` recibe `cefrLevel` + `rank` y avanza al **Paso 5**.

**Validación:** no se puede continuar sin haber realizado una evaluación (resultado `null` ⇒ botón deshabilitado + mensaje "El Oráculo debe evaluarte primero").

### 4.6 Paso 5 — Resultado

- Pantalla **solo lectura** (sin inputs).
- Tarjeta de nivel: badge grande con `cefrLevel` (gradiente runeViolet → manaCyan, patrón del `_buildStepResult` actual de `PlacementTestScreen`).
- **Rango de juego** destacado (letra E–SSS) con color por rango.
- **Explicación narrativa** en una `GlassCard`:
  - qué significa el CEFR ("Estás en el portal B1…"),
  - qué rango de cazador le corresponde,
  - qué aprenderá primero.
- Botón **"CONTINUAR"** → Paso 6.

### 4.7 Paso 6 — Creación del personaje

- Reutilizar `CharacterCreationWizard` (nombre + avatar + clase).
- **Ajustes propuestos:** mantener la estética RPG moderna actual (pulso del avatar, `GlassCard` por clase, `AnimatedContainer`), título "CREA TU PERSONAJE", botón final **"EL ORÁCULO TE ESPERA"** → dispara la persistencia completa.
- Datos salientes: `name`, `playerClass`, `avatarIndex`.

**Validación (ya existe en el wizard):** nombre ≥ 2 caracteres; clase por defecto `warrior`.

---

## 5. Persistencia y modelos

### 5.1 Tablas involucradas (estado real del esquema)

| Tabla | Columnas relevantes (actuales) | Uso en el nuevo flujo |
|---|---|---|
| `users` | `id`, `email`, `display_name`, `avatar_url`, `native_language`, `country_code`, `timezone`, `bio`, … | P0: `native_language` · P2: `country_code` · P6: `display_name` + `avatar_url` (clase) |
| `cefr_levels` | `id`, `code` (A1–C2), `name`, `description`, `order_index` | Paso 5: resolución del código a nombre/orden |
| `user_language_profiles` | `user_id`, `language_id`, `cefr_level_id`, `xp_points`, `current_streak`, … | Paso 3+5: `language_id` + `cefr_level_id` (upsert `onConflict: user_id, language_id`) |
| `user_settings` | `user_id`, `correction_style`, `tutor_personality`, `daily_goal_minutes`, `ui_language`, `learning_language`, `ai_explanations_native`, … | Pasos 1/3: `ui_language`, `learning_language`, `ai_explanations_native` |
| `languages` | `id`, `code`, `name`, `native_name`, `flag_emoji`, `is_active` | Pasos 1 y 3: catálogo de idiomas |
| `user_ai_profiles` | `user_id`, `pedagogical_summary`, `learning_style`, `focus_areas`, `tutor_prompt_instructions` | Paso 5: instrucciones del tutor según CEFR |

### 5.2 Rango de juego (nuevo concepto)

Mapeo propuesto CEFR → rango del sistema (S+ = élite):

| CEFR | Rango de juego |
|---|---|
| A1 | **E** (Buscador) |
| A2 | **D** (Guardián) |
| B1 | **C** (Aventurero) |
| B2 | **B** (Experto) |
| C1 | **A** (Maestro) |
| C2 | **S / SS / SSS** (Leyenda) — según puntuación/detalles de la conversación |

- El rango se **deriva de la evaluación IA** (misma señal que `_computeLevel`), nunca se elige.
- Colores sugeridos por rango: E–C gris/runeViolet, B manaCyan, A royalGold, S–SSS degradado royalGold→manaCyan.

### 5.3 `PlacementResult` (modelo ya existente)

`lib/features/onboarding/domain/models/placement_result.dart` (freezed). Se extiende la semántica:

- `cefrLevel` (String, A1–C2)
- `learningGoal`
- `mainDifficulty`
- `quizScore`
- **`gameRank`** (nuevo campo sugerido: E–SSS)

`savePlacementResult` (`placement_providers.dart`) ya escribe `user_language_profiles.cefr_level_id` y el `bio` en `users`. Se mantiene como **escriba parcial** dentro del paso 5 (el upsert completo lo hace `saveOnboardingData`).

### 5.4 Persistencia final

Al completar el **Paso 6** se ejecuta la escritura integral (extensión de `saveOnboardingData`):

1. `users` → `native_language`, `country_code`, `display_name`, `avatar_url`, `bio`.
2. `languages` → get-or-create `language_id` del idioma objetivo.
3. `cefr_levels` → get-or-create `cefr_level_id` (resuelto por la IA en el paso 4/5).
4. `user_language_profiles` → upsert (`cefr_level_id`, `xp_points: 0`, `current_streak: 0`) + `game_rank` (nuevo).
5. `user_settings` → `daily_goal_minutes`, `correction_style`, `tutor_personality`, `ui_language`, `learning_language`, `ai_explanations_native`.
6. `user_ai_profiles` → `pedagogical_summary` (con CEFR + rango), `tutor_prompt_instructions`.

Después: `UserLanguageProvider.setLearningLanguage` + `setUiLanguage` + `setAiExplanationsInNative`, `isPremiumProvider.setPremium(false)` (paywall post-sesión, UX-02) y `context.go('/home')`.

---

## 6. Estado compartido (Riverpod)

- **`OnboardingFlowNotifier`** (`StateNotifierProvider`): modela el flujo con `nativeLanguage`, `countryCode`, `targetLanguage`, `placementResult?`, `characterData?`, `currentStep`.
- Ventajas: la conversación del Oráculo (pantalla aparte) **escribe** el resultado al notifier y el paso 5 lo lee; se elimina la fuga de estado entre pantallas.
- `onboardingRepositoryProvider` y `placementRepositoryProvider` ya existen; se mantienen.

---

## 7. Navegación y rutas

- `/onboarding` → `OnboardingScreen` v2 (pasos 1–6).
- `/oracle-test` → `OracleConversationScreen`, **redirigida** a devolver resultado al flujo (`Navigator.pop(result)`) en lugar de `context.go('/home')`.
- `/oracle-quiz` → `PlacementTestScreen`, conservada como alternativa escrita (devuelve resultado al flujo igualmente).
- Sin nuevas rutas permanentes. El flujo es interno a `/onboarding`; la evaluación se presenta como push sobre la misma pantalla.

---

## 8. Widgets reutilizables (inventario real)

| Widget | Archivo | Uso en el flujo |
|---|---|---|
| `GlassCard` | `lib/core/widgets/glass_card.dart` | Tarjetas de selección (idiomas, países, clase), tarjeta del Oráculo, tarjeta de resultado. Soporta `borderColor`, `showRunicCorners`, `runicColor`, `opacity`, `blur`, `semanticLabel`. |
| `RunicButton` | `lib/core/widgets/runic_button.dart` | Botón principal de cada paso (`label`, `icon`, `onPressed`, `isBusy`, colores). Sustituye a los `ElevatedButton` repetidos del código actual. |
| `SegmentedBar` | `lib/core/widgets/segmented_bar.dart` | Indicador de progreso del `PageView` (6 segmentos, `value = step/6`). |
| `AppTypography` | `lib/core/theme/app_typography.dart` | `headline` (títulos de paso), `title/subtitle` (tarjetas), `body/bodyMuted` (descripciones), `label/stat/tiny` (badges, contadores, etiquetas HUD). |
| `CyberManhwaBackground` | `lib/core/widgets/cyber_manhwa_background.dart` | Fondo por paso (`CyberBgMode.onboardingStep0..7`). |
| `CharacterCreationWizard` | `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart` | Paso 6, reutilizado tal cual. |
| `SystemWindow` | `lib/core/widgets/system_window.dart` | Panel "RESPONDE CON TU VOZ" dentro del Oráculo. |
| `AnimatedCounter`, `FloatingReward` | `lib/core/widgets/` | (opcional) animación del rango al revelarse en el paso 5. |

---

## 9. Validaciones por paso (resumen)

| Paso | Campo | Regla | Feedback |
|---|---|---|---|
| 1 | `nativeLanguage` | no vacío | Snackbar (rojo) |
| 2 | `countryCode` | no vacío | Snackbar (rojo) |
| 3 | `targetLanguage` | no vacío **y ≠ nativeLanguage** | Snackbar (rojo) |
| 4 | `placementResult` | no `null` (evaluación completada) | Botón deshabilitado + hint "El Oráculo debe evaluarte" |
| 5 | — | solo lectura; botón siempre activo | — |
| 6 | nombre + clase | nombre ≥ 2 caracteres; clase por defecto | Botón deshabilitado (patrón actual del wizard) |

---

## 10. Criterios de aceptación

- [ ] El usuario **no puede** elegir su nivel CEFR manualmente en ningún punto del flujo.
- [ ] Los pasos 1, 2 y 3 son decisiones independientes y separadas visualmente.
- [ ] El país se busca en un catálogo completo (no limitado) con sugeridos EE.UU., México, Brasil, China e India al inicio.
- [ ] "INICIAR EVALUACIÓN" abre la conversación con el Oráculo (voz); el resultado vuelve al flujo y se muestra en el paso 5.
- [ ] El paso 5 muestra CEFR + rango de juego (E–SSS) con explicación.
- [ ] Todo se persiste en una sola pasada al final del paso 6.
- [ ] `/oracle-quiz` sigue accesible como alternativa escrita desde el paso 4.
- [ ] `flutter analyze`: 0 errores. (`flutter test` verde.)
