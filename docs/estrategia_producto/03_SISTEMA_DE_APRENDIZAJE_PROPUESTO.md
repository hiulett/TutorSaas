# 03 — Sistema de aprendizaje propuesto

---

## 1. Principio

El producto enseña **inglés oral en contexto**. Todo lo demás (gramática,
vocabulario, lectura) entra al servicio de esa conversación.

Lo que hoy existe y funciona:

| Pieza | Estado |
|---|---|
| Evaluación inicial (Oráculo) | Existe: `PlacementAiEvaluator` devuelve CEFR, rango y 10 dimensiones en una llamada |
| Evaluación de objetivos por escena | Existe: LLM estricto que devuelve `true/false` por objetivo |
| Repaso espaciado SM-2 | Existe y ya está conectado a la UI (#24) |
| Radar de habilidades | Existe: 6 dimensiones + objetivos + vocabulario + fluidez |
| Corrección de errores | Parcial: se corrige al cerrar, sin persistencia por error |

---

## 2. Evaluación inicial: estimación ≠ validación

**Problema:** hoy una sola llamada al modelo asigna `cefr_level` y `game_rank`
definitivos. Es una **estimación**, pero se presenta como un hecho y condiciona
todo el contenido.

**Propuesta:**

| Concepto | Cómo se obtiene | Qué se muestra |
|---|---|---|
| **Estimación inicial** | Test del Oráculo (una sesión) | «Nivel estimado: A2» con etiqueta visible de estimación |
| **Perfil por competencia** | 5 valores con confianza (baja/media/alta) | Barras por habilidad, no un número único |
| **Nivel validado** | Tras N sesiones con evidencia | «A2 confirmado» solo con evidencia suficiente |

Competencias del perfil:

1. **Comprensión oral** — ¿responde a lo que se le pregunta?
2. **Producción oral** — longitud, estructura y variedad de sus respuestas.
3. **Vocabulario** — retención diferida (no repetición inmediata).
4. **Gramática** — errores recurrentes, no conteo bruto.
5. **Fluidez** — palabras por minuto y pausas/repeticiones.

**Regla:** un CEFR global solo se muestra cuando al menos 3 de las 5
competencias coinciden. Si hay dispersión (comprensión B1, producción A2), se
muestra el perfil, no un nivel.

**Coste:** la estimación ya se paga (una llamada `oracle_eval`). El perfil se
deriva de datos existentes; no requiere IA adicional.

---

## 3. Plan de aprendizaje personalizado

**Problema:** hoy el usuario elige lección de un catálogo de 500. No hay plan;
hay un menú. Eso produce la sensación de «ejercicios al azar».

**Propuesta:** bloques de 4 semanas con un objetivo declarado.

```
Bloque (4 semanas)
├── Competencia primaria    (ej. producción oral)
├── Competencia secundaria  (ej. vocabulario)
├── 3 hitos narrativos      (misiones principales)
├── Misiones diarias        (rotan por actividad, no por tema)
├── Refuerzo SRS            (automático, según vencimiento)
└── Evaluación de cierre    (Oráculo o misión-examen)
```

El plan se ajusta **al cerrar cada bloque**, no después de cada misión. Así se
evita la sucesión impredecible de ejercicios.

**Datos ya disponibles:** `user_language_profiles` (CEFR, XP), `user_settings`
(meta diaria, intereses), `mission_instances`, `user_vocabulary`,
`oracle_turns`.

---

## 4. Repetición espaciada y recuperación activa

**Lo que ya existe:** SM-2 completo (`updateVocabularySrsScore`) y tarjeta de
repaso (`SrsReviewCard`, #24). En producción había 62 palabras vencidas sin
interfaz hasta ese cambio.

**Lo que falta:**

1. **Separar reconocimiento de producción.**
   - Tarjeta A: ves la palabra en inglés → dices el significado (reconocimiento).
   - Tarjeta B: ves el significado → la dices en inglés (producción).
   Solo B cuenta como evidencia de dominio oral.

2. **Alimentar misiones con errores.**
   Los fallos de una escena (`corrections`) generan una misión de refuerzo con
   esas estructuras, no con vocabulario aleatorio.

3. **Distinguir repetición inmediata de espaciada.**
   Repetir la respuesta correcta al instante no demuestra nada. La evidencia
   válida es la recuperación **tras ≥ 24 h**.

**Regla:** una palabra se marca `mastered` solo si se recuperó en producción
tras dos intervalos distintos (≥ 1 día y ≥ 7 días).

---

## 5. Tutor de IA

### 5.1 Qué debe hacer la IA y qué no

| Tarea | Motor | Motivo |
|---|---|---|
| Mantener la conversación | **IA** | Es el producto |
| Evaluar objetivos abiertos | **IA + reglas** | Keywords primero, LLM para matices |
| Corregir gramática | **IA** (batch al cerrar) | Coste y coherencia |
| Decidir siguiente misión | **Reglas** | Determinista y explicable |
| Recompensas y maná | **Reglas + RPC** | Debe ser auditable |
| Contenido de lecciones | **Pre-generado + validado** | Evitar inconsistencias |
| Pronunciación | **No hoy** | Requiere modelo acústico; el score actual es una estimación textual |

### 5.2 Contexto y memoria

Cada sesión debe llevar un **briefing** corto (no el historial completo):

```
Nivel: A2 (estimado) · Competencia foco: producción oral
Errores recurrentes: pasado simple, preposiciones de lugar
Palabras en refuerzo: 12
Objetivo de la sesión: describir un plan futuro
```

Ventaja: menos tokens, respuestas más consistentes y menos deriva del personaje.

### 5.3 Prevención de inconsistencias

- Rúbrica explícita por objetivo (hoy ya es estricta).
- Temperatura baja en evaluación (`0.3`, ya configurado).
- Validación de la salida: si el JSON no parsea, **no** se inventa resultado; se
  reintenta una vez y, si falla, se evalúa por keywords.
- Personaje: 3 reglas fijas (tono, longitud, no cambiar de idioma).

### 5.4 Coste y latencia

Ver `05_IA_Y_OPTIMIZACION_DE_COSTES.md`. Resumen: el 90 % de las llamadas son
conversación (barata, ya pagada con maná); la evaluación es 1 llamada por
sesión; el contenido se pre-genera.

---

## 6. Demostración de aprendizaje

Hoy no se puede responder a «¿está aprendiendo?». Propuesta de evidencias, de
menor a mayor valor:

| Nivel | Evidencia | Cómo se mide | Ya existe |
|---|---|---|---|
| 1 | Actividad completada | Instancia de misión `completed` | ❌ (motor inerte) |
| 2 | Conocimiento practicado | Palabra vista en escena | ✅ |
| 3 | Respuesta correcta | Objetivo cumplido | ✅ |
| 4 | Conocimiento retenido | Recuperación a ≥ 7 días | Parcial (SRS) |
| 5 | Competencia demostrada | Misma tarea con dificultad comparable, semanas después | ❌ |
| 6 | Transferencia | Situación nueva, mismo objetivo | ❌ |

**Indicadores propuestos (no métricas de vanidad):**

- **Retención de vocabulario a 7 días**: % de palabras repasadas correctamente
  tras un intervalo ≥ 7 días.
- **Progreso en tarea comparable**: diferencia de cumplimiento de objetivos en
  la misma categoría de misión entre semana 1 y semana 4.
- **Reducción de reparaciones**: nº de veces que el usuario repite o reformula
  por turno (proxy de fluidez).
- **Transferencia**: cumplimiento de objetivos en una misión no vista del mismo
  tipo y nivel.

**Ninguno de estos datos existe hoy.** Sin ellos no se puede afirmar que el
producto enseñe; solo que se usa. Cualquier afirmación de mejora educativa sin
estos datos sería inventada.

---

## 7. Qué NO hacer

- No añadir un test de nivel de 50 preguntas: rompe la fantasía y no mide oral.
- No mostrar un CEFR por cada palabra.
- No usar el modelo para calcular progreso (no es determinista).
- No penalizar el error con pérdida de recursos: el fallo ya es contenido.
- No prometer «fluidez en X semanas»: no hay evidencia.
