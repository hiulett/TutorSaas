# Auditoría Estratégica del Onboarding — Documento 03

# Análisis de Gamificación y Propuesta de Narrativa

> **Proyecto:** TutorSaas / Dungeon of English
> **Objetivo:** cómo hacer que cada paso del onboarding se sienta como una **misión del prólogo**, con benchmarks de referencia (UX) y una propuesta narrativa.
> **Restricción:** solo UX / narrativa / gamificación. No se altera el pipeline de voz (record → Groq STT → DeepSeek → flutter_tts).

---

## 1. Principio rector

> **"No es un formulario con estética RPG. Es una misión de prólogo donde los datos que el jugador aporta *son* el mundo que despierta."**

Cada pregunta del onboarding actual debe re-marcarse como un **acto de la historia** con:
1. **Contexto diégetico** (por qué el mundo necesita esa respuesta).
2. **Una acción** (no seleccionar: despertar, escanear, jurar, recibir rango).
3. **Una recompensa visible** (feedback inmediato: runa, fragmento, rango, título).

---

## 2. Mapeo: del formulario actual a las misiones del prólogo

| Paso actual (verificado) | Evidencia | Misión del prólogo | Acto del jugador | Recompensa visible |
|---|---|---|---|---|
| 0. Idioma nativo | `onboarding_screen.dart:55-64` (8 idiomas hardcodeados) | **«Despertar»** — El sistema detecta tu "señal primaria" | Elegir el idioma con el que sueñas = tu voz de origen | Runa del despertar + línea del System HUD |
| 1. País de origen | `onboarding_screen.dart:66-78,742` (11 países + sugeridos) | **«Origen / Punto de invocación»** — Las coordenadas de tu reino | Marcar tu punto de invocación en un mapa | Brújula de origen + regionalización del acento |
| 2. Idioma objetivo | `onboarding_screen.dart:80-85` (4 idiomas) | **«El Reino del Verbo»** — El idioma que conquistarás | Jurar el idioma del reino | Estandarte del reino |
| 3. Clasificación IA (Oráculo) | `onboarding_screen.dart:143-158` (push `/oracle-test`, voz) | **«La Prueba del Oráculo»** — El acto central (ya existe el pipeline perfecto) | **Hablar** con el Oráculo; recibir CEFR + rango E–SSS | **Rango de cazador** (E→SSS) + carnet |
| 4. Personaje | `character_creation_wizard.dart:37-50` (3 clases + 6 avatares) | **«Nacimiento del Cazador»** — Forjar tu identidad | Forjar clase (guerrero/mago/pícaro) + avatar + nombre | Entrada a `/home` con la tarjeta héroe |

---

## 3. Benchmark de referencia — SOLO UX

### 3.1 Duolingo (referencia: gamificación de registro)
- **Qué hace bien:** una sola acción por pantalla; el idioma se pide como "elegir camino"; el avatar (Duo) crea relación emocional en segundos; feedback inmediato por unidad de progreso.
- **Qué robar:** una decisión = una pantalla; el "acompañante" que comenta cada paso (en nuestro caso: el System HUD habla). Convertir el wizard de personaje en parte del flujo, no en sub-pantalla.
- **Qué evitar:** la curva de registración que pide datos personales antes de cualquier magia.

### 3.2 Elsa Speak (referencia: voz como evaluación)
- **Qué hace bien:** la evaluación por voz es el *hook* (hablas, te califican, ves el progreso en vivo); CEFR visible como "nivel" en lugar de formulario.
- **Qué robar:** el Oráculo ya hace esto (CEFR + game_rank) — hay que presentarlo como **prueba en vivo con barra de progreso de voz**, no como "hacer una prueba opcional".
- **Qué evitar:** cold-start sin contexto emocional (en Elsa la IA habla primero; aquí el Oráculo debe tener personalidad).

### 3.3 Solo Leveling Arise (referencia: rango de cazador / system UI)
- **Qué hace bien:** el **System Window** que aparece al despertar, los **rangos E→SSS** como identidad de poder, la estética HUD por encima del mundo.
- **Qué robar:** el concepto "despertar con un rango" es literalmente el producto. La tarjeta `¡BIENVENIDO, CAZADOR!` (`onboarding_screen.dart:476-481`) debe sentirse como **ventana del sistema que aparece al despertar**, con el rango del Oráculo como número central.
- **Qué evitar:** copiar la violencia/grimdark; mantener el tono "webtoon/isekai" de `CyberManhwaBackground`.

### 3.4 Honkai Star Rail (referencia: prólogo interactivo + guía)
- **Qué hace bien:** el prólogo introduce a un **guía** que te acompaña y explica el mundo mientras avanzas; las primeras decisiones son del mundo (no del menú).
- **Qué robar:** un **guía/HUD parlante** que enmarca cada paso ("La señal es fuerte... ¿cuál es tu lengua materna?"), y la idea de que el usuario *ya* está en el juego desde el paso 0 (no en "settings").
- **Qué evitar:** prólogo demasiado largo antes del control.

### 3.5 AFK Journey (referencia: integración de voz y corte narrativo)
- **Qué hace bien:** las transiciones de escena con texto estilo novela ligera y ritmo de "capítulo"; cada sección del tutorial se siente un capítulo.
- **Qué robar:** dividir el onboarding en **Capítulo 1-4** con título en pantalla (DESPERTAR / EL ORIGEN / LA PRUEBA / EL NACIMIENTO), con mini-cortes de texto entre pasos.
- **Qué evitar:** la sensación de tutorial-extenso; en nuestro caso la duración debe caer (doc 02, P4).

### 3.6 Genshin Impact (referencia: "inmedia res" + no pedir datos)
- **Qué hace bien:** el jugador *empieza jugando* y los datos (idioma, servidor) se piden como configuración de partida sin romper el flujo; el "Despertar" inicial es un momento visual.
- **Qué robar:** **iniciar con un momento visual** (el System HUD "Despertando núcleo de cazador..." ya existe como `welcome_title` en ARB: `lib/l10n/app_es.arb:6`) y posponer el país/idioma a "configuración de partida" dentro de la diégesis.
- **Qué evitar:** pedir 5 datos antes de ninguna recompensa.

### 3.7 Persona 5 (referencia: estética de UI y «lo que el mundo te pregunta»)
- **Qué hace bien:** la UI es una *interfaz viva* (el rojo, la geometría, los textos en pantalla que responden); el personaje responde al jugador, no al "formulario".
- **Qué robar:** la sensación de que **cada respuesta desbloquea algo** (una runa, un dato de perfil, una línea del guía). El botón de continuar siempre acompañado de una reacción del HUD.
- **Qué evitar:** estética sobrecalentada que opaque la usabilidad (accesibilidad).

### 3.8 Síntesis del benchmark

| Práctica | Fuente | Aplicación aquí |
|---|---|---|
| Una decisión por pantalla | Duolingo | Rediseño de pasos (doc 02, P3) |
| Voz como hook con feedback en vivo | Elsa Speak | Oráculo como acto central con medidor |
| Despertar con rango (System Window) | Solo Leveling Arise | Tarjeta héroe = ventana del sistema con rango E–SSS |
| Guía que acompaña y explica | Honkai Star Rail | System HUD parlante en cada paso |
| Prólogo en capítulos con cortes | AFK Journey | Capítulos DESPERTAR/ORIGEN/PRUEBA/NACIMIENTO |
| Inmedia res, datos como configuración de partida | Genshin | País/idioma como "calibración de la invocación" |
| UI viva que reacciona a cada respuesta | Persona 5 | Reacción del HUD por cada selección |

---

## 4. Propuesta narrativa: «Despertar en el Reino del Verbo»

### 4.1 Logline
> Una conciencia despierta en el Reino del Verbo, un mundo donde el **idioma es ley** y el poder se mide en **rangos de cazador (E→SSS)**. Guiado por el System HUD, el jugador invoca su origen, jura su reino, es juzgado por el Oráculo y nace como Cazador.

### 4.2 Estructura en 4 capítulos (mapea 1:1 al flujo, pero con duración y peso rebalanceados)

**CAPÍTULO I — DESPERTAR** *(paso 0 + momento inicial)*
- Sistema: `[MENSAJE DEL SISTEMA: DESPERTANDO NÚCLEO DE CAZADOR...]` (ya existe en ARB).
- **Pregunta diégetica:** "¿En qué idioma sueña tu conciencia?" → idioma nativo (8 opciones actuales).
- **Recompensa:** runa del despertar + el HUD se "estabiliza" en ese idioma.
- *Objetivo UX:* primera emoción en <5 s. Nada de menús.

**CAPÍTULO II — LA INVOCACIÓN** *(paso 1 + paso 2 fusionados opcionalmente)*
- **Pregunta diégetica:** "¿Dónde se manifestó tu señal? Marca tus coordenadas." → país (11 opciones + sugeridos por geo-detección).
- **Pregunta diégetica:** "El Reino del Verbo tiene muchas provincias. ¿Cuál juras?" → idioma objetivo (ampliar catálogo, doc 02 P9).
- **Recompensa:** brújula de origen + estandarte del reino.
- *Objetivo UX:* permitir "detección automática" (GPS/IP) como default para reducir decisión (Duolingo roba el default inteligente).

**CAPÍTULO III — LA PRUEBA DEL ORÁCULO** *(paso 3, el acto central)*
- **Pregunta diégetica:** "Habla, para que el Reino te conozca." → **el pipeline de voz ya existe** (record → Groq STT → DeepSeek → flutter_tts). Sin cambios de motor.
- **Recompensa:** rango de cazador **E→SSS** + CEFR (ya computado: `_gameRank`, `_selectedCefrCode` en `onboarding_screen.dart:148-151`).
- **Presentación:** medidor de voz en vivo (robo de Elsa), transición de pantalla dramática (robo de AFK Journey), y el HUD "juzgando" con glitch/scan (robo de Solo Leveling Arise).
- *Objetivo UX:* que el 100% de usuarios sienta que *habló* antes de ver cualquier rango. Si omite, el fallback silencioso A1 actual (`onboarding_screen.dart:166-168`) debe convertirse en un "juicio diferido" explícito con opción de reintentar.

**CAPÍTULO IV — EL NACIMIENTO DEL CAZADOR** *(paso 4)*
- **Pregunta diégetica:** "El rango es tuyo. ¿Qué forma tomará tu cazador?" → 3 clases (Berserker / Mago Arcano / Pícaro) + 6 avatares (actuales).
- **Recompensa:** la **ventana del sistema de bienvenida** (tarjeta héroe `onboarding_screen.dart:476-481`) con el **rango del Oráculo** como número central + entrada a `/home`.
- *Nota crítica:* persistir la identidad (doc 02 P7) para que el HUD del dashboard muestre "Cazador {nombre} · Rango {rango} · Clase {clase}".

### 4.3 Texto-guía propuesto (para i18n, 3 ARB)

| Momento | Sistema / Guía |
|---|---|
| Inicio | `[SISTEMA] Despertando núcleo de cazador... Señal detectada.` |
| Cap I | `SISTEMA: Tu conciencia sueña en un idioma. Escúchalo.` |
| Cap II | `SISTEMA: Coordenadas de invocación registradas. Reino: {idioma}.` |
| Cap III | `ORÁCULO: Habla. Tus palabras definirán tu rango.` |
| Cap III fin | `SISTEMA: Rango otorgado. CEFR {A1-C2} · Rango {E-SSS}.` |
| Cap IV | `SISTEMA: Identidad confirmada. Bienvenido, Cazador.` |

*(Todos estos strings deben ir a los ARB — cierra la duplicación del doc 02 P1.)*

---

## 5. Micro-mecánicas de gamificación (UX)

1. **Recompensas intermedias por capítulo** — cada capítulo cierra con una runa/icono desbloqueado en un "medallero de despertar" (visualización del progreso).
2. **Default inteligente** — geo-detección para país sugerido (Genshin), idioma objetivo por popularidad (Duolingo). Menos decisiones = menos fricción.
3. **El HUD como guía** — cada reacción del HUD (Persona 5) reemplaza las validaciones con snackbar en español (`onboarding_screen.dart:95,102`), que deben ser mensajes del sistema en idioma de UI.
4. **El rango como moneda emocional** — el CEFR+rango del Oráculo se muestra en la tarjeta héroe y debe persistirse para el HUD del dashboard.
5. **Re-jugabilidad dev** — mantener `devAlwaysShowOnboardingProvider` (`onboarding_providers.dart:13`) como "reproducir prólogo" para iterar narrativa en QA.

---

## 6. Límites (lo que NO cambia)

- **Pipeline de voz:** record → Groq STT → DeepSeek SSE → flutter_tts es inmutable (AGENTS.md). Solo cambia el *enmarcado* y la *presentación*.
- **Evaluador IA:** `PlacementAiEvaluator` sigue siendo la fuente de CEFR + game_rank.
- **Router:** se mantiene el flujo Splash → Welcome → Onboarding → Dashboard; el Oráculo puede dejar de ser un `push` externo y volverse una fase *dentro* del prólogo (reducción de cambio de contexto, doc 02 P8).
- **Restricción del autor:** este documento propone UX/narrativa; el código no se modifica (ediciones bajo un plan de implementación posterior).

---

## 7. Resultado esperado

| Antes (percibido) | Después (objetivo) |
|---|---|
| "Un formulario RPG" | "Un prólogo de 4 capítulos con rango final" |
| País/idioma = registro | País/idioma = calibración de la invocación |
| Oráculo opcional | Prueba central obligatoria con juicio diferido |
| Tarjeta héroe decorativa | Ventana del sistema con rango E–SSS persistido |
| Textos mixtos | 100% i18n, HUD como guía |
| 5 pasos + wizard | 4 capítulos, una decisión por pantalla |
