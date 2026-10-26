# 01 — Visión del producto

> Medición: 25-oct-2026. Se separa **observado** (código/datos) de **inferido**
> (interpretación), según la regla de no convertir suposiciones en hechos.

---

## 1. Qué problema intenta resolver (observado + inferido)

**Observado:** la app entrena **hablar inglés** en situaciones concretas (café,
aeropuerto, entrevista, negociación) con un interlocutor de IA, y mide la
actividad con una capa de rol (XP, rango, aura, oro, maná).

**Inferido:** el problema que ataca es *"sé algo de inglés pero no me atrevo a
hablar / no tengo con quién practicar"*. La app no enseña gramática desde cero:
asume vocabulario y estructuras básicas y pone al usuario a conversar.

**Evidencia del enfoque:**
- Todos los escenarios son diálogos con rol (`assistantRole`, `userRole`,
  `initialAssistantMessage`) en `lesson_catalog.dart`.
- No hay ejercicios de gramática, lecturas ni escritura (doc 05 §1).
- El onboarding incluye un examen oral, no un test escrito.

---

## 2. Tipo de producto

| Dimensión | Valor observado |
|---|---|
| Categoría | Educación / idiomas con mecánicas de RPG |
| Plataforma | Android (Flutter) |
| Modelo | Free-to-play con suscripción (maná) |
| Núcleo | Conversación oral con IA + evaluación por metas |
| Capa de juego | Reputación (XP, rango, aura, títulos) + monedas (maná, oro) |
| Multijugador | Salas de voz (LiveKit) y gremio — implementado, sin uso |
| Idiomas de UI | es / en / pt |
| Idioma enseñado | Inglés (el selector de objetivo solo ofrece inglés) |

---

## 3. Propuesta de valor **tal como está implementada**

1. **Práctica oral sin agenda**: se habla cuando se quiere, con un tutor que
   responde en inglés y adapta el registro al CEFR.
2. **Contextos reales**: 500 escenarios (20 por nivel en PRE-A1 y 80 por nivel en
   A1-C2, en 4 idiomas) con metas y frases útiles.
3. **Progreso medible (en parte)**: metas por escenario, estrellas, XP, aura,
   retención de vocabulario a 7 días.
4. **Estética de juego**: HUD, radar de habilidades, títulos, prestigio.
5. **Economía de uso**: el maná limita el consumo de IA y diferencia planes.

**Lo que la propuesta NO incluye hoy:** corrección explícita de errores,
ejercicios dirigidos, plan de estudio, evaluación de comprensión auditiva,
garantía de progreso medido más allá del vocabulario.

---

## 4. Usuarios contemplados

| Perfil | Evidencia | Nota |
|---|---|---|
| Adulto que ya tuvo inglés y quiere hablarlo | Examen oral de entrada; niveles A1-C2 | Perfil principal |
| Principiante absoluto | Nivel PRE-A1 con 20 lecciones de una palabra y salto manual | Contemplado, con techo bajo |
| Profesional | 33 escenarios de `business` en el catálogo | Segundo interés más frecuente |
| Estudiante | Escenarios `school`/`daily` | — |
| Jugador de RPG | Aura, prestigio, títulos, tienda | Capa de motivación |
| Usuario social | Gremio y salas de voz | Sin actividad real |

**No contemplados:** niños (sin control parental ni contenido adaptado), docentes
(sin panel de clase), empresas (sin gestión de equipos).

---

## 5. Nivel de inglés que asume

- **Entrada:** desde PRE-A1 (palabras sueltas) hasta C2.
- **Salto rápido:** PRE-A1 si el usuario no quiere examinarse.
- **Progresión:** el contenido se filtra por el CEFR exacto; no hay mezcla.
- **Supuesto implícito:** el usuario sabe leer la UI en es/en/pt y puede hablar en
  voz alta en un entorno privado.

---

## 6. Necesidades de aprendizaje cubiertas

| Necesidad | ¿Cubierta? | Cómo |
|---|---|---|
| Perder el miedo a hablar | ✅ | Conversación sin penalización |
| Practicar situaciones reales | ✅ | 500 escenarios |
| Ampliar vocabulario | ⚠️ | Extracción automática + SRS |
| Corregir gramática | ⚠️ | Corrección implícita del tutor |
| Entender al interlocutor | ⚠️ | TTS del tutor, sin evaluación |
| Escribir | ❌ | — |
| Leer | ❌ | — |
| Preparar un examen | ❌ | No hay formato de examen |
| Medir progreso real | ⚠️ | Metas + retención de vocabulario |

---

## 7. Diferenciación frente a apps convencionales

**Observado:**
1. Conversación **oral** con IA como actividad central (no tarjetas ni ejercicios).
2. Capa RPG con **aura, prestigio y títulos** ligados a métricas de habla.
3. **Maná** como coste por turno de IA (modelo de consumo, no de lecciones).
4. Estética *cyber-manhwa* oscura y consistente.

**Inferido:** la diferenciación es de *formato* (hablar + rol), no de *método*
pedagógico. No hay un mecanismo propio de enseñanza (tipo repetición espaciada de
frases, corrección dirigida o currículo adaptativo).

---

## 8. Funcionalidades centrales vs complementarias

| Núcleo | Complementario | Residual / sin uso |
|---|---|---|
| Conversación por voz | Tienda de cosméticos | Gremio y salas de voz |
| Metas por escenario | Misiones diarias | Battle pass |
| Desbloqueo por nivel | Recompensa diaria | Misiones semanales/secretas/eventos |
| Maná | Aura / prestigio / títulos | Gemas, fragmentos, pergaminos |
| Resumen de sesión | SRS de vocabulario | Leaderboard |
| Onboarding + Oráculo | Logros | Invocaciones, freezes de racha |

---

## 9. Qué parece terminado, incompleto o en desarrollo

| Estado | Elementos |
|---|---|
| **Terminado y funcionando** | Login/registro, onboarding, voz→STT→LLM→TTS, metas, SRS, maná, compras (RevenueCat), tienda de oro, inventario de cosméticos, tema e i18n |
| **Terminado con defectos** | Resumen de sesión, racha, misiones (doble conteo), evaluaciones de fluidez/pronunciación, cambio de nivel en ajustes |
| **Incompleto** | Misiones semanales (sin UI), refuerzo por IA (roto), exportar/borrar cuenta (sin UI), reporte de errores |
| **En desarrollo / maqueta** | Gremio (vacío), salas de voz (sin uso), battle pass, leaderboard sin identidad, eventos y misiones especiales |

---

## 10. Promesas de la interfaz no respaldadas por el comportamiento

| Promesa visible | Realidad | Evidencia |
|---|---|---|
| "Gana +80 XP" al cerrar | Cifra fija; el servidor acredita otra | `session_summary_screen.dart:216-222` |
| Métricas de pronunciación y fluidez con porcentaje | Estimaciones (texto/similitud, latencia fija) | doc 05 §1 |
| "Racha en riesgo" | Se calcula con un contador que nunca se incrementa | `progress_tab_view.dart:46-48` |
| Cambiar nivel CEFR en ajustes | El trigger lo descarta | doc 09 §7 |
| Planes con "Battle Pass" y "Blind Listening" en BD | Esas features no existen en la app | doc 10 §2 |
| Drop de objeto al terminar | El objeto es texto decorativo | `session_drop_controller.dart` |
| "Siguiente lección" | Puede repetir la misma lección | `session_summary_screen.dart:394-435` |
| Gremio con battle pass | Solo se lee el nivel; no hay pase | `chat_rooms_screen.dart:1011-1064` |

---

## 11. Identidad de marca (inconsistente)

Aparecen tres nombres: **"Dungeon of English"** (`app.dart:31`), **"DungeonSpeak"**
(`AndroidManifest.xml` y productos de Play) y **"TutorSaas"** (`pubspec.yaml`,
bundle id). No hay una identidad única en la app, la tienda y el código.

---

## 12. Resumen de posicionamiento (inferido, sujeto a validación)

> "Practica inglés hablando con un tutor de IA en escenarios reales, con una capa
> de progreso tipo RPG que convierte cada conversación en una aventura."

La primera mitad de la frase está implementada y funciona. La segunda
(progreso/aventura) existe en la interfaz, pero **no cierra el bucle**: las
recompensas no coinciden con lo acreditado, la racha no avanza y el gremio está
vacío.
