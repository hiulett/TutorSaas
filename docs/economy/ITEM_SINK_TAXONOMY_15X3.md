# Taxonomía de sumideros: 15 ideas por recurso

_Diseño creativo · funciones que en su mayoría **no existen**. Nada implementado._

## Taxonomía adoptada

| Recurso | Dominio | Promesa al usuario |
|---|---|---|
| **Pergaminos** | **Repaso** | «Vuelve sobre lo que ya viste» |
| **Oro** | **Funciones de la conversación** | «Mejora la escena que estoy viviendo» |
| **Gemas** | **Estatus** | «Que se me vea» |

### Tres items que no encajan y cómo se resuelven

1. **Freeze de racha** (hoy 30 gemas) no es estatus ni repaso. Propuesta: **gratis 1/semana** y comprable con **oro** (protege el hábito, no se exhibe).
2. **Reparar racha** tampoco: pasa a **oro**.
3. **Alquilar un cosmético** no es función de conversación: pasa a **gemas** (consumo recurrente de estatus).

**Tensión a vigilar:** las funciones de conversación que **llaman al LLM** cuestan
dinero. Que el oro sea moneda ganada no significa que la función sea gratis de
producir. Regla: **oro compra funciones de coste cero** (interfaz, TTS local,
caché) o consumibles limitados; lo que genera tokens **también consume maná**.

---

## PERGAMINOS · 15 formas de repasar

| # | Idea | Qué repasa | Coste de IA |
|---|---|---|---|
| P1 | Repaso de la última sesión | Correcciones convertidas en ejercicios | Cero (se genera y cachea) |
| P2 | Mazo SRS por tema | Vocabulario de un tema (café, aeropuerto…) | Cero |
| P3 | Simulacro CEFR | Examen autocorregido del nivel actual | Cero |
| P4 | Lectura corta con preguntas | Comprensión lectora | Cero |
| P5 | Escritura guiada | 3 frases/día con plantilla y corrección ligera | Bajo (corrección) |
| P6 | Listening con TTS local | Escucha + preguntas sin LLM | Cero |
| P7 | Tarjetas en el widget de inicio | Repaso del día desde el móvil | Cero |
| P8 | Drill de pronunciación | Grabarte y comparar forma de onda con el NPC | Cero |
| P9 | Bingo semanal de vocabulario | Palabras del gremio | Cero |
| P10 | Diario del cazador | Escribir una entrada al día | Bajo |
| P11 | Repaso de fonemas problemáticos | Los fonemas que el códex te marcó | Cero |
| P12 | Reconstruir una conversación pasada | Elegir la respuesta correcta en un diálogo ya vivido | Cero |
| P13 | Traducción inversa | ES→EN de frases de tu sesión | Cero |
| P14 | «Frases que casi dijiste» | Errores corregidos en formato tarjeta | Cero |
| P15 | Examen sorpresa de hace 7 días | Repaso espaciado de una lección vieja | Cero |

---

## ORO · 15 funciones para la conversación

| # | Idea | Qué añade a la escena | Necesita LLM |
|---|---|---|---|
| O1 | Pista del tutor | Una pista contextual en el turno | Sí (limitado) |
| O2 | Traducción de la burbuja del NPC | Verla en tu idioma | No (desde caché) |
| O3 | «Más lento» | El NPC repite su línea a otra velocidad | No (TTS) |
| O4 | Subtítulos de la escena | Texto de lo que suena | No |
| O5 | Tema extra en la rueda | Añade un tema de conversación a la lección | No (catálogo) |
| O6 | Cambiar el tono del NPC | Formal / casual / sarcástico | Sí |
| O7 | Invitar a un compañero | Un segundo NPC entra en la escena | Sí |
| O8 | Objeto de escena | Pedir el menú, el mapa, la carta | Sí |
| O9 | Comodín de reformulación | El NPC repite la idea con otras palabras | Sí |
| O10 | Más tiempo de respuesta | La escena no te mete prisa | No (temporizador) |
| O11 | Modo «solo escuchar» | 5 turnos escuchando sin hablar | No |
| O12 | Marcar frase para estudiar | La guarda en tu mazo | No |
| O13 | Variante de escenario | Mismo objetivo, otro contexto | No (catálogo) |
| O14 | Reinicio limpio de escena | Repetir sin perder racha ni progreso | No |
| O15 | Elegir acento del NPC | US / UK en la voz | No (TTS) |

**Revisión de la tensión:** O1, O6, O7, O8 y O9 generan tokens. Propuesta: esas
cinco **cuestan oro *y* consumen el maná del turno** (como cualquier acción de
IA), o se limitan a N usos por sesión. Las otras diez son de coste cero y pueden
ser el corazón del sumidero de oro.

---

## GEMAS · 15 formas de estatus

| # | Idea | Dónde se ve | Recurrente |
|---|---|---|---|
| G1 | Título exclusivo de temporada | Perfil y ranking | Por temporada |
| G2 | Marco animado del avatar | Burbuja del chat y gremio | Único |
| G3 | Aura con partículas | Avatar y sala de voz | Único |
| G4 | Pase de exhibición | Entrada del ranking semanal | ✅ por semana |
| G5 | Efecto de entrada al gremio | Al entrar a la mesa | Único |
| G6 | Estandarte del gremio | Mesa compartida | Único |
| G7 | Tema de la mesa de voz | Sala | Por temporada |
| G8 | Voz del Maestre | Avisos y bienvenida | Único |
| G9 | Nombre con color | Chat y listas | Único |
| G10 | Insignia de hito | Perfil («30 días», «B1») | Por hito |
| G11 | Mascota coleccionable | Acompaña al avatar | Único |
| G12 | Vitrina del perfil | 3 slots para medallas | Ampliación |
| G13 | Alquiler de skin premium (7 días) | Avatar | ✅ recurrente |
| G14 | Tema visual de la app | Toda la interfaz | Único |
| G15 | Tarjeta del gremio | Banner compartido | Por temporada |

---

## Cómo queda el balance

| Recurso | Naturaleza del gasto | Recurrencia |
|---|---|---|
| Pergaminos | Práctica (autoconsumo) | **Alta**: cada sesión genera repaso |
| Oro | Función de escena | **Media**: limitado por catálogo + maná |
| Gemas | Estatus | **Baja**: compra única, alquiler cubre la recurrencia |
