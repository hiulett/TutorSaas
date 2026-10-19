# RPG-01 · Capa Narrativa — "El Reino del Verbo"

> **Fase:** 9 · RPG
> **Tarea:** RPG-01 (capa narrativa del juego)
> **Idioma del documento:** Español (los textos de la app son l10n: `app_en`, `app_es`, `app_pt`).
> **Alcance:** Definición del mundo, conflicto, enemigos, objetivo, progresión y los 5 episodios iniciales de la Temporada 1. **No toca código Dart.**

---

## 1. El Mundo — "El Reino del Verbo"

El Reino del Verbo es un mundo donde **el lenguaje es la sustancia misma de la realidad**. Cada palabra dicha o escrita sostiene una porción del mundo: los ríos nacen de los sustantivos, el clima obedece a los adjetivos y las leyes del reino se escriben en tiempos verbales. Por eso, cada persona es un **Cazador** potencial: quien domina la palabra, sostiene el reino.

- **La Biblioteca Corazón:** el edificio central donde reside el Oráculo del Gremio. Sus estanterías se extienden por dimensiones enteras.
- **Los 6 Portales CEFR:** seis portales rúnicos que conectan el reino con las tierras de dominio lingüístico (A1, A2, B1, B2, C1, C2). Cada portal es el "hogar" de un conjunto de habilidades de habla, escucha, lectura y escritura.
- **Las Tierras Hablantes:** zonas exteriores cuyo terreno cambia según lo que los cazadores dominan al hablar (el "Bosque de los Presentes", la "Costa de los Pasados", el "Pico del Subjuntivo"…).
- **El Gremio:** la organización de cazadores. Un lugar seguro de descanso, entrenamiento y reclutamiento. Aquí el jugador ve su rango, progreso y recompensas.

El reino usa el sistema de niveles CEFR (A1→C2) como **jerarquía de rango de cazador**: al subir de nivel lingüístico, el cazador sube de rango.

---

## 2. El Conflicto — "El Vacío del Olvido"

Hace mucho, una entidad sin forma llamada **El Vacío del Olvido** emergió de las fisuras entre las palabras. No destruye el reino con fuego ni espadas: **consume el lenguaje mismo**. Cada sílaba que absorbe borra un recuerdo, un lugar o una persona del reino. Los bordes del mundo se desdibujan y se vuelven silencio.

### La mecánica narrativa: "Las palabras son armas"

- Los cazadores **restauran el lenguaje hablándolo**. Cada conversación, cada frase pronunciada y entendida, devuelve una palabra al mundo.
- Hablar **con claridad y corrección** inflige daño al Vacío; hablar con errores deja grietas que el Vacío aprovecha.
- Esta es la justificación narrativa de todo el pipeline de voz:
  1. El cazador habla (grabación AAC/m4a).
  2. El Oráculo descifra las palabras (Groq Whisper STT).
  3. El Vacío responde (DeepSeek LLM en streaming).
  4. La voz del reino se alza de nuevo (flutter_tts).

### Reglas del conflicto

| Aspecto | Regla |
|---|---|
| Daño al Vacío | Cada turno de conversación correcta alimenta la "Varita de Maná" (invocaciones diarias). |
| Grietas | Las frases mal dichas o silencios dejan grietas que el Vacío explota en los bosses. |
| Recursos | El maná (invocaciones) es la energía para invocar al Oráculo y continuar la cacería. |
| Progreso | Cada rango CEFR superado restaura un portal y cierra una fisura permanente. |

---

## 3. El Enemigo — Bosses por Rango CEFR

El Vacío del Olvido despierta avatares por cada franja de dominio. Cada jefe tiene intro de boss, mecánicas y derrota ligadas a los objetivos de nivel.

| Rango | Jefe | Territorio | Fortalezas | Debilidad |
|---|---|---|---|---|
| **A1–A2** | **Goblin de la Gramática Básica** | Bosque de los Presentes | Ataca con conjugaciones incorrectas, singular/plural confusos y vocabulario roto | Responder con frases simples y correctas (present simple, verbos ser/estar, saludos) |
| **B1–B2** | **Espectro de la Sintaxis** | Costa de los Pasados | Teje frases sin conexión, tiempos mixtos y estructuras incompletas | Dominar tiempos narrativos, conectores y oraciones subordinadas |
| **C1–C2** | **Dragón del Abismo Léxico** | Pico del Subjuntivo | Escupe matices, coloquialismos, phrasal verbs y ambigüedad semántica | Precisión léxica, matices de registro y fluidez avanzada |

> **Nota de diseño:** los bosses no son solo "exámenes". Cada jefe tiene personalidad y líneas de burla en inglés; vencerlos otorga recompensas (XP, gemas, fragmentos de reliquia) vía el motor de misiones/economía existente.

---

## 4. El Objetivo Final — Sellar el Vacío

La victoria definitiva exige **restaurar y sellar los 6 Portales CEFR**:

1. A1 — Portal del Amanecer (primeras palabras)
2. A2 — Portal del Camino (viaje y rutinas)
3. B1 — Portal del Bosque (narrativa personal)
4. B2 — Portal de la Ciudad (debate y opinión)
5. C1 — Portal de la Universidad (análisis y matiz)
6. C2 — Portal del Trono (maestría total)

### Lógica de sellado

- Cada portal **se restaura** cuando el cazador completa los desafíos de escenarios de ese rango (conversaciones con objetivo y metas por keywords).
- Cada portal **se sella** al derrotar al jefe de su franja (el examen de nivel).
- Al sellar los 6 portales, el cazador puede acceder al **Trono del Vacío**, el enfrentamiento final para expulsar al Vacío del Olvido del Reino del Verbo.

---

## 5. Progresión Narrativa — El Oráculo del Gremio como guía

El **Oráculo del Gremio** (NPC principal, ya existente en `HunterCatalog.titles` y `oracle_conversation_screen`) es el hilo narrativo que une toda la aventura. Es una entidad mística que recuerda lo que el Vacío borra, por lo que guía al cazador de portal en portal.

### Flujo de progresión

1. **Ingreso:** el cazador llega al Gremio; el Oráculo lo evalúa (examen del Oráculo / onboarding) y le asigna su rango inicial.
2. **Capítulo por rango:** cada rango superado desbloquea **un capítulo** de la historia del reino y un nuevo episodio del arco.
3. **Misión activa:** el Oráculo asigna la misión narrativa vigente (el motor de misiones existente la muestra como misión activa).
4. **Conversación:** el Oráculo es el compañero de práctica conversacional (scenario-based), donde el progreso narrativo se refleja en el guion.
5. **Boss:** al completar los escenarios del rango, el cazador enfrenta al jefe (examen de nivel). Derrotarlo = nuevo capítulo + portal sellado.

### Capítulos desbloqueables

| Rango superado | Capítulo desbloqueado | Portal sellado |
|---|---|---|
| A1 | Capítulo 1 — El Despertar | A1 |
| A2 | Capítulo 2 — El Primer Camino | A2 |
| B1 | Capítulo 3 — Los Cuentos del Bosque | B1 |
| B2 | Capítulo 4 — Voz en la Ciudad | B2 |
| C1 | Capítulo 5 — El Ojo del Análisis | C1 |
| C2 | Capítulo 6 — El Trono del Verbo | C2 |

---

## 6. Temporada 1 — Los 5 Episodios Iniciales

Cada episodio es una misión narrativa con **cliffhanger** que engancha al siguiente. Los episodios acompañan el recorrido A1→B1+.

### E1 — "El Portal Sellado"
El cazador despierta en el Reino del Verbo sin recordar cómo llegó. El Oráculo le explica la amenaza y le revela que el primer portal (A1) está sellado por el Goblin de la Gramática Básica. El cazador restaura sus primeras palabras y derrota al Goblin.
- **Cliffhanger:** al abrirse el portal A1, de su interior escapa un susurro que repite una frase que solo el cazador entiende: *"No eras tú quien debía venir."*

### E2 — "El Archivo Perdido"
Tras sellar A1, el Oráculo descubre que el **Archivo del Gremio** —el registro de todos los portales y de la historia del reino— ha sido vaciado por el Vacío. Sin ese archivo, el Gremio no sabe cuál portal restaurar después. El cazador debe rastrear las páginas robadas a través de las Tierras Hablantes (práctica conversacional).
- **Cliffhanger:** la última página aparece y contiene un nombre tachado… el nombre del cazador.

### E3 — "La Traición del Eco"
Durante la recuperación del archivo, un eco del Vacío adopta la voz del Oráculo y envía al cazador a un portal falso, casi atrapándolo. El Gremio entiende que el Vacío **ya puede imitar la voz de los aliados** y que nada verbal es confiable sin comprobación.
- **Cliffhanger:** el cazador regresa y el Oráculo le susurra en privado: *"Si algún día me escuchas dudar de ti… sabrás que no soy yo."*

### E4 — "El Consejo de Cazadores"
El Gremio convoca a los cazadores de todos los rangos (otra franja de práctica: trabajo en equipo y diálogos con la mesa de práctica del gremio). El Consejo decide atacar el Corazón del Vacío, pero el plan se filtra. Alguien en el Consejo ha sido corrompido.
- **Cliffhanger:** en el momento de votar el plan, una mano enguantada levanta el sello que solo posee el líder del Consejo: *"Propongo que el cazador nuevo lidere el asalto."*

### E5 — "El Despertar del Vacío"
El asalto comienza y el Vacío despierta por primera vez en su forma de **Espectro de la Sintaxis** (primer jefe de la franja B1–B2). La batalla es feroz y el cazador, aunque no lo derrota del todo, logra sellar el segundo portal y descubrir que el Vacío **fue creado por un cazador caído**, no por una maldición.
- **Cliffhanger final de temporada:** el Oráculo mira al cazador con tristeza y dice: *"Ese cazador caído… era el guardián que juró proteger el archivo. Y su nombre… es el que llevas tatuado en la mano."*

> **Nota:** el arco de la Temporada 2 queda abierto con la identidad del cazador caído.

---

## 7. Diálogos del Oráculo por Episodio

El Oráculo habla con tono **místico y sereno**, siempre en segunda persona, con metáforas de luz, palabras y memoria. Cada episodio tiene 2–3 líneas guionizadas (español de referencia; la app traducirá vía l10n).

| Episodio | Línea | Guion (es) |
|---|---|---|
| **E1 — El Portal Sellado** | 1 | "Bienvenido, Cazador. El Reino del Verbo se desvanece sílaba a sílaba, y tú has llegado justo cuando su último eco te nombraba." |
| E1 | 2 | "Cada palabra que pronuncies con firmeza será una antorcha contra el Vacío. Empieza por el portal del amanecer." |
| E1 | 3 | "No temas al Goblin que custodia el alba. Teme más al silencio que deja cuando gana." |
| **E2 — El Archivo Perdido** | 1 | "El Archivo fue el primer testigo del reino. Ahora solo quedan sus páginas, dispersas como recuerdos de un sueño roto." |
| E2 | 2 | "Recupera las hojas, Cazador. Cada una guarda el nombre de un portal… y uno de esos nombres te conoce a ti." |
| **E3 — La Traición del Eco** | 1 | "El Vacío aprendió a robar voces. De ahora en adelante, cree en lo que dices, no en lo que escuchas." |
| E3 | 2 | "Si algún día mi voz te pidiera rendirte, sabrás que no soy yo. Porque el Oráculo solo pide dos cosas: que sigas y que hables." |
| **E4 — El Consejo de Cazadores** | 1 | "El Consejo se reúne cuando el reino no puede decidir solo. Hoy, el reino se calla y espera tu palabra." |
| E4 | 2 | "Desconfía del que habla por todos, Cazador. La voz del Vacío es más dulce cuando viene de un amigo." |
| E4 | 3 | "Vota con la lengua y no con el miedo. El que sella el destino del reino rara vez lo sabe." |
| **E5 — El Despertar del Vacío** | 1 | "Hoy no verás a un monstruo, Cazador. Verás lo que un corazón herido puede volverse cuando las palabras le fallan." |
| E5 | 2 | "El Espectro no quiere destruir el lenguaje. Quiere ser recordado. Y los que fueron olvidados enseñan la lección más cruel." |
| E5 | 3 | "Lucha, pero escucha su silencio. Porque dentro del Vacío aún late un nombre que tú llevas grabado." |

---

## 8. Nota de Implementación

La narrativa se integra a **los sistemas existentes sin crear infraestructura nueva**:

### 8.1 Textos en la app (l10n)
- Todos los diálogos, títulos de episodios y descripciones de capítulos se añaden como **claves `.arb`** (`app_en.arb`, `app_es.arb`, `app_pt.arb`) y se consumen vía `AppLocalizations.of(context)!`.
- Tras editar los `.arb`, ejecutar `flutter gen-l10n`.
- Los nombres de los jefes y el mundo (Goblin de la Gramática Básica, Reino del Verbo…) pueden reutilizarse como nombres de escenario/objetivo en `lesson_catalog.dart`.

### 8.2 Guion del Oráculo en conversation
- El Oráculo ya es el NPC conversacional (`oracle_conversation_screen.dart`, `hunter_catalog.dart` — "Oráculo del Gremio").
- El **guion por episodio** (sección 7) alimenta el `system_prompt` del LLM en `conversation_repository_impl.dart`: el prompt recibe el episodio activo del jugador y el Oráculo habla acorde (mística, revela pistas del cliffhanger).
- El episodio activo se deriva del estado de progresión (rango CEFR alcanzado + portales sellados), consultando los repos de misión/economía existentes.

### 8.3 Intro de boss en level_exam
- `level_exam_screen.dart` ya usa lenguaje de raid ("RAID CLEAR: STAGE CONQUERED!"). Se extiende la **pantalla de intro de jefe**: nombre del boss según la franja CEFR del examen (Goblin/Espectro/Dragón), línea de burla del jefe en inglés y 1–2 líneas del Oráculo de ánimo.
- Al aprobar (score ≥ 80), la pantalla muestra el **capítulo desbloqueado** y el **portal sellado** correspondiente.

### 8.4 Progresión
- El desbloqueo de capítulos/episodios no introduce tablas nuevas: se calcula desde el rango CEFR persistido y el historial de exámenes aprobados.

---

## Decisiones de diseño (resumen)

| # | Decisión |
|---|---|
| D1 | La narrativa **no añade tablas ni migraciones**: vive en l10n y se deriva del estado existente. |
| D2 | El conflicto "las palabras son armas" ancla el pipeline de voz (record → STT → LLM → TTS) como mecánica de combate, no como feature suelta. |
| D3 | Los bosses son los exámenes de nivel existentes, con skin narrativa. |
| D4 | El Oráculo ya existe como NPC; solo se enriquece su guion con la temporada. |
| D5 | La Temporada 1 cubre A1→B1+; los rangos superiores (C1–C2) quedan para temporadas posteriores, con el Dragón del Abismo Léxico como jefe final de la franja avanzada. |
