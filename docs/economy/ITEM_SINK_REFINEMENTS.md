# Tres sumideros refinados: misión custom, fuego de racha y chat personalizable

_Diseño. Nada implementado._

---

## 1 · Misión a medida — «Contrato de práctica»

**Idea del usuario:** financiar una misión del gremio se convierte en **crear una
misión custom con lo que el usuario necesita practicar**.

**Qué es:** el jugador describe su necesidad («vocabulario de aduanas», «pasado
simple», «pedir direcciones en un aeropuerto») y el servidor genera un escenario
con NPC, 2–3 objetivos y corrección normal.

**Moneda:** **oro** (crear contenido del mundo) **+ maná** (la generación llama
al LLM). El oro paga el contrato; el maná paga los tokens.

**Precio propuesto:** 150 oro por contrato · **1 contrato al día** · el maná del
turno se cobra como siempre.

**Antiabuso (crítico):**
1. La generación ocurre **en servidor** (`lesson-generator` ya existe), nunca en cliente.
2. Objetivos **bloqueados al CEFR del perfil**; el LLM no puede subir dificultad a petición.
3. **Recompensa fija**: XP normal, oro reducido, **cero gemas** y `reward_multiplier = 1`
   forzado. Si no, es una granja de recompensas.
4. **Moderación del tema** (lista de temas permitidos + filtro de contenido).
5. El contrato generado se guarda como **pergamino del gremio**: otros pueden
   jugarlo una vez. Convierte un gasto individual en contenido social.

**Riesgo principal:** convertirse en «pago por contenido más fácil». Mitigación:
mismo evaluador y mismos objetivos exigentes que una misión normal; solo cambia
el tema.

**Qué hay que construir:** UI de contrato, RPC `create_custom_mission` (valida
oro, CEFR, moderación, llama a `lesson-generator`), tabla/vista de contratos
compartidos, tope diario.

---

## 2 · Fuego de racha — «brasero del cazador»

**Idea del usuario:** efecto de fuego que **crece** con la racha.

**Qué es:** un efecto de llama que envuelve avatar/perfil/burbuja y sube de
intensidad por tramos: 3, 7, 14, 30, 60, 100 días. El efecto se compra; **los
tramos se ganan**.

**Moneda:** **gemas** (es estatus). El crecimiento no se paga.

**Precio propuesto:** 200–400 gemas según variante (brasa, azul, abisal).

**Diseño que evita el castigo:**
- Si pierdes la racha, **el brasero no desaparece**: baja de intensidad un tramo
  y se recupera al volver a la racha. No se destruye lo comprado.
- Se muestra el «mejor tramo alcanzado» en el perfil aunque ahora estés abajo:
  el estatus refleja tu historia, no tu última semana.
- El tramo 100 puede ser **exclusivo de suscripción** (`min_plan`) como estatus
  máximo.

**Regla dura:** el fuego **no** da bonus de recompensa. Es visual. Cualquier
«+X% por racha» debe ser independiente y para todos.

**Qué hay que construir:** catálogo de braseros, tiers por racha, capa de
renderizado (partículas), persistencia del mejor tramo.

---

## 3 · Chat de voz personalizable

**Idea del usuario:** personalizar el chat de voz con cosas como **personalidad**.

**Qué es:** packs que cambian **cómo suena y cómo actúa** el NPC, no cuánto
aprende el usuario: personalidad (mentor, sarcástico, coach, narrador), acento
(US/UK), ritmo (pausado/normal), verbosidad (habla más o menos).

**Moneda:** **oro** por desbloqueo (funcionalidad de la escena), **una vez**
cada pack; el uso posterior no cuesta extra. Los packs de voz premium pueden ser
`min_plan` para suscriptores.

**Precio propuesto:** 100–300 oro por pack de personalidad; 150 oro por acento.

**Reglas de equidad (importantes):**
1. **Todas las personalidades corrigen igual.** Cambian el tono, no la exigencia
   ni la generosidad de la evaluación. Si una personalidad «perdona más», se
   convierte en ventaja comprable.
2. **El acento no sustituye práctica de acento**: la voz UK/US es estética de
   escena; el entrenamiento de pronunciación sigue siendo libre y evaluado igual.
3. La personalidad se aplica **solo a los NPCs**, no al Oráculo ni al examen (el
   evaluador debe ser estable).

**Coste real:** bajo. Es un parámetro del prompt y de TTS; no añade turnos.

**Riesgo:** si el pack cambia la dificultad del vocabulario del NPC, afecta al
aprendizaje → fijar el nivel de vocabulario al CEFR del usuario, siempre.

**Qué hay que construir:** catálogo de packs, `user_settings` con personalidad y
acento, inyección en el prompt de escena, selección de voz TTS.

---

## Encaje en el modelo

| Idea | Moneda | Recurrente | Coste real |
|---|---|---|---|
| Misión a medida | Oro + maná | ✅ diaria (tope) | Generación de contenido |
| Brasero de racha | Gemas | Compra única, tramos ganados | Render de partículas |
| Packs de voz/personalidad | Oro (+ `min_plan`) | Compra única | Prompt + TTS |

## Los tres riesgos que no hay que perder de vista

1. **La misión custom no puede pagar gemas** ni aceptar multiplicadores: sería la
   granja perfecta.
2. **El brasero no puede dar bonus**: si sube recompensas, es pago por progreso.
3. **La personalidad no puede alterar la evaluación**: el evaluador (Oráculo) se
   queda fuera de cualquier personalización.
