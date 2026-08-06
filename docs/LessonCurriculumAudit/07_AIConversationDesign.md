# 07 — Diseño de conversaciones IA (AI Conversation Design)

## Principio: conversaciones dinámicas, no hardcodeadas

Cada lección NO contiene guion de conversación. Solo define **contexto, objetivos, reglas, rol del NPC y resultado esperado**. El diálogo lo genera el LLM en tiempo real.

## Flujo de la conversación

```
Lección (LessonData)                    Supabase scenarios (480 filas)
    │  id, title, level                    │  initial_assistant_message
    │  goals (texto + keywords)            │  context, assistant_role, user_role
    ▼                                      ▼
initSession(conversation_providers.dart)
    │  resuelve lesson por id/título
    ▼
System prompt (conversation_providers.dart:_processTranscription ~L921-924)
    │  "You are an AI Language Tutor roleplaying as {assistantRole} in {scenarioContext}.
    │   Target CEFR Level: {level}. Keep your response appropriate for CEFR level {level}
    │   (simple for A1/A2, intermediate for B1/B2, advanced for C1, native for C2)."
    ▼
DeepSeek SSE streaming (conversation_repository_impl.dart:getTutorResponseStream)
    │  mensajes del usuario + sistema → respuestas del NPC
    ▼
Evaluación de metas (_evaluateGoalsWithAi, conversation_providers.dart:1049)
    │  envía últimos 12 mensajes + metas pendientes → JSON {goalId: bool}
    ▼
user_scenario_goals (persistencia inmediata) → progreso de la misión
```

## Lo que la IA recibe por lección

| Elemento | Fuente | Ejemplo |
|---|---|---|
| Contexto | `scenarioContext` | "You are a friendly barista... Interact with a beginner (A1) student." |
| Rol NPC | `assistantRole` | "Barista" |
| Rol usuario | `userRole` | "Customer" |
| Nivel CEFR | `level` | "A1" |
| Objetivos | `goals` (texto + keywords) | "Order a coffee drink" (keywords: order, coffee, drink) |
| Mensaje inicial | `initialAssistantMessage` | "Hello! Welcome to Metro Cafe..." |
| Frases objetivo | `usefulPhrases` | "I would like a coffee, please." |

## Reglas de la conversación (inyectadas por nivel)

El system prompt ajusta la dificultad **automáticamente por banda CEFR**:

- **A1/A2**: frases cortas, vocabulario básico, presente/pasado simple, respuestas lentas.
- **B1/B2**: preguntas de opinión, narración, negociación básica.
- **C1**: discurso estructurado, matices, lenguaje profesional.
- **C2**: discurso abstracto, léxico experto, argumentación jurídica/científica.

## Evaluación de objetivos (resultado esperado)

1. `_evaluateGoalsWithAi` evalúa SOLO metas no completadas (ventana móvil de 12 mensajes).
2. Cada meta alcanzada → `saveCompletedGoal` → UPSERT `user_scenario_goals` (persistencia inmediata).
3. Progreso = `completedGoals / totalGoals` (ver `Docs/MissionProgressAudit`).
4. El chat termina cuando el usuario decide salir; el progreso queda persistido.

## Coherencia con la arquitectura IA existente

- **No hay cambios** en `conversation_repository_impl.dart` ni en el streaming.
- El nivel se transmite vía `lesson.level` en el system prompt (ya implementado).
- Las 120 lecciones usan el **mismo motor de conversación** — solo cambian los datos.
