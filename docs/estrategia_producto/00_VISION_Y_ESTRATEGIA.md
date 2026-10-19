# 00 — Visión y estrategia

_Fase 2 · octubre 2026_

> **Nota sobre las fuentes.** El encargo pedía los 16 documentos numerados de la
> fase 1 (`00_RESUMEN_EJECUTIVO.md`…`15_ROADMAP…`). **No existen con esos
> nombres.** El equivalente disponible es `docs/archive/auditoria_producto/AUDITORIA_INTEGRAL.md`
> (~1.943 líneas, 113 KB) más el backlog de 72 issues en GitHub. Todo lo que
> sigue se ha verificado además contra el código y la base de datos en
> producción el 18-oct-2026; cuando un dato viene de la auditoría antigua y no
> del código actual, se indica.

---

## 1. La promesa

**«Sobrevive a un mundo que solo habla inglés.»**

No es una app de inglés con decoración de RPG. Es un RPG donde el inglés **es**
la mecánica: sin comprender y responder, el personaje no avanza. La fantasía
(amanecer en un mundo extraño, el Sistema, los rangos) justifica por qué el
jugador está obligado a hablar.

### Por qué esa y no otra

| Promesa alternativa | Por qué se descarta |
|---|---|
| «Aprende inglés jugando» | Genérica; la usan Duolingo y decenas de apps |
| «Tu tutor de IA personal» | El tutor es un medio, no la identidad; además es lo que todo el mundo dice en 2026 |
| «Practica conversación con NPCs» | Correcta pero no diferencia: no explica la progresión ni el mundo |

---

## 2. Qué debe experimentar el usuario que no encuentra en otra app

1. **Consecuencia.** Lo que dice tiene efecto en el mundo: convence al herrero,
   falla una negociación, gana un aliado. En un cuestionario, la respuesta
   correcta solo suma puntos.
2. **Un mundo que no está traducido.** Los NPC hablan inglés porque son
   ingleses, no porque sea un ejercicio.
3. **Un personaje que crece con él.** El rango, el título y el equipo son
   consecuencia de lo que ha hablado.
4. **Presión narrativa, no presión de racha.** El motivo para volver es saber
   qué pasa en la siguiente sala, no conservar una llama.

---

## 3. Qué lo hace atractivo después de los primeros días

Los primeros días engancha la novedad (HUD, voz, Oráculo). Lo que sostiene a
partir del día 7 es **la promesa pendiente**: una mazmorra a medio explorar, un
NPC que dijo «vuelve cuando sepas pedir disculpas», un rango a una misión de
distancia.

Estado actual verificado: **no existe esa promesa pendiente**. Hay 500
escenarios, 33 plantillas de misión y 533 instancias… todas en `active`
(`updateProgress` no tiene ni un llamador en `lib/`). El jugador no puede
completar una misión.

---

## 4. Qué debe sentir al aprender algo

| Momento | Sensación buscada | Cómo se produce |
|---|---|---|
| Entiende una palabra nueva en contexto | «Lo he pillado» | La palabra aparece en un diálogo y desbloquea una opción |
| Mejora su comprensión | «Ya no necesito subtítulos» | El mismo tipo de escena se resuelve más rápido |
| Supera una conversación difícil | «Eso lo he hecho yo» | Un NPC cambia de actitud de forma persistente |

No se busca «puntos» ni «fuegos artificiales». Se busca **competencia
percibida**.

---

## 5. Fantasía mecánica vs. fantasía decorativa

| Elemento | ¿Mecánica o decorativa? | Decisión |
|---|---|---|
| Rangos F→SSS | Mecánica | Determinan qué misiones aceptas y qué NPC te hablan |
| Sistema/HUD | Decorativa con valor | Se conserva: da identidad, pero no debe añadir pasos |
| Maná | Mecánica | Coste real de IA; controla el ritmo |
| Atributos STR/INT/DEX/LUK | **Decorativa hoy** | No afectan a nada verificable: eliminar de la UI o darles efecto |
| Clases de cazador | Semidecorativa | Debe cambiar el tono de los NPC y el tipo de misión |
| Títulos de prestigio | Decorativa | Se conserva como colección |
| Mazmorra/Guardián | Mecánica | Es el escenario de práctica intensiva |

Regla: **si un número no cambia una decisión del jugador, no se muestra en la
pantalla principal.**

---

## 6. Cómo evitar que se perciba como un cuestionario disfrazado

Cinco condiciones, todas verificables:

1. **El fallo tiene consecuencia.** Si respondes mal, el NPC reacciona; no
   aparece un check rojo.
2. **Hay decisiones sin respuesta única.** Elegir entre dos opciones válidas.
3. **El mundo recuerda.** Un NPC que te vio fallar te trata distinto.
4. **El progreso no es solo numérico.** Se desbloquean espacios y personajes.
5. **No se puntúa cada frase.** La evaluación llega al cerrar la escena.

Hoy se cumplen 0 de 5: la conversación no tiene consecuencias fuera de la
pantalla y la evaluación es un mensaje al final.

---

## 7. Los primeros cinco minutos

| Minuto | Qué pasa | Qué demuestra |
|---|---|---|
| 0-1 | Llegas al mundo, el Sistema te reconoce y te da un rango F | Identidad |
| 1-3 | Un NPC te habla en inglés; respondes con voz; te entiende | Que funciona |
| 3-5 | La respuesta cambia algo (el NPC te deja pasar / te bloquea) y recibes tu primera palabra aprendida | Que importa |

Nada de onboarding de 4 pasos antes de la primera conversación. El onboarding
actual (idioma nativo → objetivo → Oráculo → personaje) retrasa la promesa
demasiado: son entre 4 y 8 minutos antes de la primera frase útil.

**Recomendación:** invertir el orden. Primera conversación de 60 segundos →
luego el Oráculo (que ya es una conversación) → luego el personaje.

---

## 8. Objetivos a una semana y a un mes

**Semana 1:** terminar el primer arco (3-5 escenas encadenadas) y ver el rango
subir de F a E. Objetivo emocional: «quiero ver qué hay en la siguiente sala».

**Mes 1:** dominar un dominio concreto (p. ej. pedir en un restaurante sin
titubear) y tener una evidencia propia: una lista de palabras que antes no
sabías y ahora usas. Objetivo emocional: «esto me sirve fuera de la app».

---

## 9. Identidad que no debe perderse

1. **HUD de Sistema** (cian/dorado, monoespaciada, esquinas rectas).
2. **Voz como interfaz principal**: se habla, no se escribe.
3. **El Oráculo** como personaje y como evaluación.
4. **Maná** como recurso que da ritmo.
5. **Tono**: fantasía oscura con humor de manhwa, no infantil.

Aunque cambien mecánicas, esos cinco se mantienen.

---

## 10. Principios de diseño

1. **El inglés es el verbo.** Toda acción relevante se resuelve hablando o
   comprendiendo.
2. **Una decisión por pantalla.** Si hay dos botones igual de importantes, falta
   jerarquía.
3. **El progreso del personaje y el aprendizaje son ejes separados.** Subir de
   rango no implica saber más inglés.
4. **Nada de IA donde una regla basta.** Determinista por defecto, IA donde
   aporta.
5. **El fallo es contenido.** Se diseña qué pasa cuando el jugador no entiende.
6. **El coste es una mecánica, no un castigo.** El maná regula el ritmo, no
   penaliza el error.
7. **Cada pantalla debe justificar su existencia** con una acción que el jugador
   no puede hacer en otra.

---

## 11. Propuesta de valor (una frase)

> **Un RPG de fantasía oscura donde tu personaje solo avanza si el mundo
> entiende lo que dices.**

Y su corolario operativo: *el juego no te da puntos por acertar; te da acceso.*

---

## 12. Qué no se debe sacrificar

- La voz (es lo que hace único al producto).
- El HUD (identidad).
- El Oráculo (evaluación + personaje).
- La economía de maná (sostenibilidad del coste de IA).
- La calidad del inglés que se enseña: mejor menos contenido y validado que
  mucho generado sin revisar.
