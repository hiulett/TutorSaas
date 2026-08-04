# Diseño de la Evaluación del Oráculo — Documento 05

> **Proyecto:** TutorSaas / Dungeon of English (Flutter)
> **Alcance:** Diseño completo de la evaluación conversacional del Oráculo (voz + IA)
> **Método:** Datos verificados contra `oracle_conversation_screen.dart`, `placement_ai.dart`, `oracle_providers.dart`, `voice_service.dart`, `cefr_rank.dart`
> **Estado:** Diseño de experiencia y especificación de prompt (sin modificación de código)
> **Fecha:** 2026-08-02

---

## 1. Visión y principios

La evaluación del Oráculo debe ser una **conversación**, no un examen. El jugador no "contesta un test": **despierta dentro del Reino del Verbo y un guía místico lee su alma lingüística** para asignarle su rango inicial.

Principios rectores:

1. **No se siente como evaluación.** El jugador habla sobre sí mismo, no sobre gramática. La evaluación es un subproducto de la conversación.
2. **Voz primero.** El pipeline real (record → Groq Whisper `en` → DeepSeek → flutter_tts) es la experiencia central; el teclado es solo accesibilidad/fallback (`oracle_conversation_screen.dart:194-269`).
3. **Adaptativo.** La dificultad sube o baja según la calidad percibida de las respuestas anteriores (ver §5).
4. **Breve y sin fricción.** 3–5 minutos, 5–8 intercambios, con cierre narrativo claro.
5. **Degradación elegante.** Si la IA falla, la heurística local garantiza un rango y el flujo nunca se bloquea (`placement_ai.dart:221-259`, `oracle_conversation_screen.dart:106-115`).

---

## 2. Flujo general (estado deseado)

```
ONBOARDING paso "Clasificación"
   │
   ▼
[El Oráculo invoca al jugador] ── narrativa de entrada (episodio)
   │
   ▼
Conversación de voz natural (3–5 min)
   ├─ Turno Oráculo: pregunta + TTS (flutter_tts) + texto en pantalla
   ├─ Turno Jugador: hold-to-talk → Groq Whisper → transcripción mostrada
   └─ (motor interno) acumula respuestas + señales de interacción
   │
   ▼
[El Oráculo delibera] ── spinner narrativo ("consulta los archivos del reino")
   │
   ▼
PlacementAiEvaluator (DeepSeek) → JSON
   │   └─ fallback → heurística _computeLevel()
   ▼
Resultado: CEFR + Rango del juego + Fortalezas/Debilidades + Explicación narrativa
   │
   ▼
Tarjeta de resultado (rango del juego) → paso creación de personaje
   │   └─ persistencia en user_language_profiles
```

El flujo de navegación actual (`context.push('/oracle-test')`, `onboarding_screen.dart:143-158`) se conserva; lo que cambia es la **experiencia interna** de la pantalla del Oráculo.

---

## 3. Personalidad del Oráculo

**Arquetipo:** el Oráculo del Gremio — guía místico y custodio del **Reino del Verbo**.

| Rasgo | Cómo se expresa |
|---|---|
| Místico/ancestral | Habla de "el reino", "el archivo", "el vacío", "los archivos del reino". Trata el idioma como una fuerza mágica. |
| Sabio y sereno | Nunca corrige bruscamente; observa y comenta ("sabio", "curioso", "cálido" — ver `emotion` en `oracle_question.dart:6`). |
| Personalizado | Se refiere al jugador como "Cazador". Evoca el episodio narrativo actual (`_oracleEpisodes`, `oracle_conversation_screen.dart:31-52`). |
| No evaluador explícito | No dice "estás en B1". Solo asigna rango al final con una frase de desenlace ("El vacío retrocede. Nivel B1 desbloqueado." — `oracle_conversation_screen.dart:291,621`). |

**Voz (TTS):** la personalidad también se transmite por tono. Mantener `flutter_tts` rate 0.48, `pitch 1.05`, `en-US` (`voice_service.dart:128-132`). Los textos del Oráculo se escriben **para ser leídos en voz alta** (frases cortas, sin jerga técnica, con pausas naturales).

---

## 4. Instrucciones del sistema (prompt del evaluador)

El evaluador debe medir 10 dimensiones. Las 5 primeras son las que hoy devuelve `scores` (`placement_ai.dart:20-26`); las 5 adicionales se infieren del flujo (tiempos, expansión, naturalidad, señales de voz) y se expresan como criterios de juicio dentro del prompt.

### 4.1 Dimensiones a evaluar

| Dimensión | Qué se mide | Fuente |
|---|---|---|
| **listening / comprehension** | Qué tan bien responde a lo que se le pregunta (relevancia de la respuesta) | transcripción + relevancia al prompt |
| **speaking** | Producción hablada: capacidad de sostener el turno | transcripción + longitud/expansión |
| **pronunciation** | Claridad e inteligibilidad (se infiere conservadoramente de la transcripción; Whisper no da fonética) | transcripción + heurística |
| **vocabulary** | Rango, precisión y adecuación de palabras | transcripción |
| **grammar** | Estructuras, tiempos y concordancia | transcripción |
| **sentence structure** | Complejidad sintáctica: simple → compuesta → subordinada | transcripción |
| **confidence** | Seguridad percibida (poco "um/ah", respuestas directas) | transcripción + señales |
| **fluency** | Flujo, ritmo, pausas, muletillas | transcripción + tiempos de respuesta |
| **response time** | Latencia del turno (señal de procesamiento) | timestamps del flujo |
| **naturalness** | Grado en que suena a habla natural vs. memorizada/robotizada | transcripción |

### 4.2 Prompt `system` rediseñado (propuesta)

```
You are the Oracle of the Guild, a mystical guide of the Kingdom of the Word.
You are having a friendly spoken conversation with a language learner (the "Hunter").
You must evaluate their ENGLISH from the conversation transcripts provided — do not
act like a test proctor; judge like a wise observer who is calibrating the Hunter's
soul-level, not their test score.

EVALUATE ONLY THE HUNTER'S RESPONSES. Ignore your own questions.

Assess these 10 dimensions and score each 0–100:
1. listening: how relevantly the response addresses the question asked.
2. speaking: ability to produce and sustain a spoken turn.
3. pronunciation: clarity and intelligibility (be CONSERVATIVE; infer from text clues only).
4. vocabulary: range, precision and appropriateness.
5. grammar: correctness of structures, tenses and agreement.
6. sentence_structure: syntactic complexity (simple → compound → subordinate).
7. confidence: certainty and directness (hesitation markers like "um/uh" lower it).
8. fluency: flow, pace, ability to keep the conversation going.
9. response_time: how quickly the response comes (only if timing hints are provided).
10. naturalness: how much it sounds like natural speech vs. memorized / robotic.

Adaptive difficulty: the conversation raised or lowered complexity based on earlier
answers. Weigh later, harder answers MORE when they succeed, and later, simpler
answers LESS harshly. If the Hunter struggled, do not punish the level for one weak
turn — the pattern across ALL answers matters most.

Rules:
- Short or empty answers => level A1 and low scores. Do NOT inflate.
- 3+ answers that are relevant, expanded and mostly correct => B1 or above.
- Complex structures (conditionals, subordinate clauses) sustained => B2+.
- If transcription looks like STT noise, do not penalize; note it in weaknesses.
- Strengths and weaknesses: 2–3 short noun phrases each, in the SAME language as the
  explanation language requested (default: English).
- explanation: 1–2 sentences in the RPG tone of the Oracle (mystical, kind, precise).
- recommended_focus: pick ONE from this enum: basic_phrases, everyday_vocabulary,
  past_tenses, present_tenses, future_tenses, conditionals, grammar_articles,
  listening_comprehension, speaking_fluency, pronunciation_clarity, complex_topics.

Return ONLY a valid JSON object. No markdown, no code fences, no extra text:
{
  "cefr_level": "B1",
  "game_rank": "C",
  "scores": {"listening":75,"speaking":70,"pronunciation":72,"vocabulary":65,"grammar":58,"sentence_structure":60,"confidence":68,"fluency":70,"response_time":72,"naturalness":66},
  "strengths": ["clear everyday vocabulary", "good listening comprehension"],
  "weaknesses": ["past tense accuracy", "complex sentence structure"],
  "explanation": "The Hunter holds a flowing conversation about daily life, yet hesitates with past tenses and subordinate clauses.",
  "recommended_focus": "grammar_past_tenses"
}
```

> **Compatibilidad:** el contrato JSON actual de la pantalla lee `scores.pronunciation/vocabulary/grammar/comprehension/fluency` (`oracle_conversation_screen.dart:300`, `placement_ai.dart:20-26`). La propuesta **añade** 5 claves al sub-objeto `scores` pero mantiene las 5 originales (renombra `comprehension` → se mantiene como alias de `listening` para no romper). La normalización Dart actual solo conserva las claves de `_scoreKeys` (`placement_ai.dart:21-26`), así que el rediseño debe ampliar `_scoreKeys` y el modelo para las 10 dimensiones (§7).

---

## 5. Escalado de dificultad adaptativo

### 5.1 Motor de dificultad (estado propuesto)

Cada turno asigna una **dificultad objetivo** (`difficulty ∈ {bajo, medio, alto}`) que determina el estilo de la siguiente pregunta del Oráculo:

```
Estimación provisional por turno (dentro de la conversación):
  quality_turn(t) = f(longitud, expansión, señales de duda, relevancia)

si quality_turn(t) alta   → dificultad sube (siguiente pregunta más abstracta)
si quality_turn(t) media  → se mantiene (profundiza el tema)
si quality_turn(t) baja   → dificultad baja (retrocede a tema cotidiano/seguro)
```

### 5.2 Banco de preguntas por banda de dificultad

| Dificultad | Estilo de pregunta | Ejemplos (tono Oráculo) |
|---|---|---|
| **Baja** (A1–A2) | Presente simple, vida cotidiana, respuestas cortas | "Tell me about yourself. Where are you from?" (`oracle_providers.dart:28`) |
| **Media** (A2–B1) | Rutinas, gustos, pasado reciente | "What do you do when you are not practicing languages?" (`:35`); "Tell me about your daily routine." (`:41`) |
| **Alta** (B1–B2+) | Pasado, condicionales, opiniones, abstracción | "Imagine you find a dragon in your backyard. What would you say?" (`:48`); "How did you handle a recent challenge?" (`:53`) |

El banco vive en la tabla `oracle_questions` (config por DB, campo `emotion` y nuevo campo `difficulty`). El fallback local ya existe (`oracle_providers.dart:24-59`) y debe ampliarse con preguntas de las 3 bandas.

### 5.3 Lógica sugerida (pseudocódigo de diseño)

```
pregunta_actual = _questions[índice según dificultad]
al responder:
  señal = evaluar_respuesta(respuesta)   # longitud + expansión + señales de duda
  dificultad_siguiente = clamp(dificultad ± señal, baja, alta)
  elegir siguiente pregunta de la banda dificultad_siguiente
```

> **Nota de implementación:** la elección de pregunta puede hacerse en la pantalla (marcando `difficulty` en `OracleQuestion`) o delegando el siguiente turno al LLM (que generaría su propia pregunta con la banda indicada). La primera opción es más barata y determinista; la segunda es más natural. **Recomendación:** banco por DB + selección local en v1, y evolución a generación LLM del siguiente turno en v2.

---

## 6. Tiempo, cantidad de preguntas y criterio de terminación

### 6.1 Parámetros recomendados

| Parámetro | Valor | Justificación |
|---|---|---|
| **Duración objetivo** | **3–5 min** | Suficiente para 5–8 turnos de voz sin fatiga; respeta el target de onboarding corto. |
| **Preguntas** | **5–8** | Hoy el límite es 7 (`oracle_providers.dart:15`), fallback 5. 5 mínimo para promediar ruido STT; 8 máximo para no alargar. |
| **Criterio de terminación temprana** | Terminar en cuanto se alcance **confianza** (señal acumulada ≥ umbral) con **≥4 respuestas útiles** | Evita preguntar de más a un B1 claro o a un A1 claro. |
| **Límite duro** | 8 respuestas máx. | Barrera anti-bucles; el botón actual de "COMPLETAR / SALTAR" se conserva (`oracle_conversation_screen.dart:682-696`). |
| **Tiempo por turno** | 10 s grabación máx; 30 s espera de respuesta | Evita turnos vacíos y reduce "response time" como señal. |

### 6.2 Terminación

```
terminar = (respuestas útiles >= 5)              // suficiente señal
         OR (respuestas totales >= 8)            // límite duro
         OR (señal de confianza alta o baja extremos y respuestas >= 4)
```
- Si el jugador omite 2 preguntas seguidas → el Oráculo ofrece **saltar a la creación de personaje** (rango por defecto A1/E, ya previsto en `onboarding_screen.dart:166-168`).
- Si STT devuelve vacío en ≥3 turnos → aviso y opción de teclado (ya existe el fallback `_openKeyboardSheet`).

---

## 7. Clasificación: CEFR → Rango del juego

### 7.1 Escala del juego (verificada en `cefr_rank.dart`)

`E (novato) → D → C → B → A → S → SS → SSS (élite)`.

### 7.2 Tabla de conversión recomendada (con rango de puntaje)

| Rango del juego | CEFR | Descripción (de `cefr_rank.dart:31-40`) | Escala de scores IA (promedio 0–100) |
|---|---|---|---|
| **E** | A1 | Novato — cada aventura empieza con un primer paso | 0–39 |
| **D** | A1+/A2 | Aprendiz — los básicos ya no te frenan | 40–54 |
| **C** | A2+/B1 | Aventurero — te desenvuelves en mazmorras cotidianas | 55–69 |
| **B** | B1+/B2 | Guerrero — conversaciones firmes y con recursos | 70–79 |
| **A** | B2+/C1 | Campeón — lideras la conversación con soltura | 80–87 |
| **S** | C1+/C2 | Leyenda — casi imposible de igualar | 88–93 |
| **SS** | C2 (alto) | Leyenda Suprema — dominio casi perfecto | 94–96 |
| **SSS** | C2 (maestría) | Deidad del Idioma — maestría absoluta | 97–100 |

**Mapeo canónico actual (`cefr_rank.dart:8-15`):** A1→E, A2→D, B1→C, B2→B, C1→A, C2→S. Los rangos SS y SSS se derivan de un **scores alto dentro de C2** (más granularidad de prestigio por encima de "S").

### 7.3 Regla de asignación (recomendación)

- El **CEFR** lo decide el modelo (dimensión primaria, estándar educativo, ya validado en `placement_ai.dart:182-188`).
- El **rango del juego** se deriva en Dart con `CefrRank.gameRankFromCefr(cefr)` (`cefr_rank.dart:45-48`), para **no depender del LLM**. Cuando el LLM devuelva `game_rank` se valida contra la escala `{E,D,C,B,A,S,SS,SSS}` y se normaliza a mayúsculas (`placement_ai.dart:146-148`).
- Los rangos `SS/SSS` solo se otorgan si, además de C2, el promedio de `scores` supera los umbrales de la tabla. Si el modelo devuelve un rango inconsistente con el CEFR (p. ej. CEFR B1 + rango SS), **gana la derivación Dart** (el CEFR manda).

### 7.4 Justificación

- **Por qué CEFR primero:** es el estándar reconocible de progreso (BD `cefr_levels`, habilidades, salones de conversación, y re-tests de ascenso lo usan).
- **Por qué rango del juego encima:** el HUD System RPG motiva a progresar ("desbloquear rango") y oculta la crudeza de un test educativo; es el gancho de retención.
- **Por qué 8 rangos y no 6:** los rangos extra (SS/SSS) dan prestigio de final de juego sin tocar la escala CEFR, y se derivan de puntajes altos — no requieren nuevo modelo educativo.

---

## 8. Mejora del prompt de PlacementAiEvaluator

Resumen de cambios frente al prompt actual (`placement_ai.dart:92-123`):

| Aspecto | Actual | Propuesto | Motivo |
|---|---|---|---|
| Persona | "ancient and wise judge" | **"mystical guide of the Kingdom of the Word"**, no examinador | Refuerza conversación vs. examen |
| Dimensiones | 5 (`pronunciation/vocabulary/grammar/comprehension/fluency`) | **10** (añade `listening`, `sentence_structure`, `confidence`, `response_time`, `naturalness`) | Mejor calibración del HUD y del reporte |
| Adaptatividad | No existe | Instrucción explícita: **"weigh later, harder answers MORE"** | La IA debe entender el escalado adaptativo del banco |
| Trato del ruido STT | Solo reglas generales | **"If transcription looks like STT noise, do not penalize"** | Evita penalizar errores del transcritor (riesgo documentado) |
| Idioma de salida | Está en inglés, strengths en inglés | Se pide explícito: "in the SAME language as the explanation language requested" | Sostiene el modelo de 3 idiomas (explicaciones en nativo) |
| `temperature` | 0.3 | **0.2** | Mayor consistencia del JSON |
| `recommended_focus` | Free text | **Enum validado** (mismo que `placement_ai.dart` / CHECK en DB) | Evita valores huérfanos que rompen el foco inicial |

### 8.1 Estandarización del contrato JSON

Normalizar a camelCase en Dart (ya hace `_normalizeResult`, `placement_ai.dart:137-155`) y ampliar el modelo freezed propuesto en `docs/Onboarding_Revamp/03_AI_Placement_Test.md:223-290` con las 5 claves nuevas de `scores`. El parser defensivo tolera markdown/JSON envolvente (`placement_ai.dart:192-216`), y se conserva el fallback heurístico.

---

## 9. Fallback y degradación (inalterado como red de seguridad)

| Fallo | Comportamiento |
|---|---|
| DeepSeek sin red / timeout | Heurística `_computeLevel()` (promedio de palabras: A1<6, A2 6–11, B1 12–19, B2 20–31, C1≥32 — `oracle_conversation_screen.dart:77-115`) |
| JSON inválido / sin `cefr_level` | `_normalizeResult`/`_heuristicFallback` (`placement_ai.dart:221-259`) |
| STT vacío | Se descarta; si ≥3 vacíos seguidos → sugerir teclado |
| Persistencia RLS falla | `try-catch` silencioso (`oracle_conversation_screen.dart:361-398`); el usuario nunca se bloquea |

> Regla de oro (heredada de `03_AI_Placement_Test.md:435`): **la IA es un plus; el flujo actual es la red de seguridad.** El rediseño no puede atrapar al jugador en la pantalla del Oráculo.

---

## 10. Checklist de implementación (diseño → código)

- [ ] Ampliar `OracleQuestion` con campo `difficulty` (baja/media/alta) y poblarlo en `oracle_questions` (migración DB).
- [ ] Ampliar el banco de preguntas de fallback a 3 bandas (`oracle_providers.dart:24-59`).
- [ ] Motor de dificultad adaptativo en `OracleConversationScreen` (señal → banda siguiente).
- [ ] Rediseñar `PlacementAiEvaluator._buildSystemPrompt()` (persona + 10 dimensiones + adaptatividad + ruido STT + enum).
- [ ] Ampliar `_scoreKeys` y el modelo `AiPlacementResult` a 10 scores; normalizar y guardar (paridad con `docs/Onboarding_Revamp/03_AI_Placement_Test.md:349-397`).
- [ ] Regla de derivación de rango: CEFR manda, rangos SS/SSS solo con scores altos en C2.
- [ ] Tarjeta de resultado con radar de 10 stats + explicación narrativa localizada.
- [ ] Terminación temprana por confianza (≥4 útiles) + límite duro 8.
- [ ] i18n de los nuevos textos del Oráculo (ver Documento 04, §5.1-B).
- [ ] `flutter analyze` (0 errores) + `flutter test` + prueba manual voz/fallback/RLS.
