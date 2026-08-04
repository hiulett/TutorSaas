# Fase 4 — Architecture

> Arquitectura del Sistema de Conversaciones.

## Módulos

```
lib/features/conversation/
├── data/repositories/conversation_repository_impl.dart
├── domain/
│   ├── models/
│   │   ├── conversation_message.dart (+freezed/g)
│   │   └── conversation_state.dart (+freezed/g)
│   └── repositories/conversation_repository.dart
└── presentation/
    ├── providers/conversation_providers.dart
    ├── screens/
    │   ├── conversation_screen.dart        # 1175 líneas
    │   └── level_exam_screen.dart
    └── widgets/
        ├── conversational_tactics_navigator.dart
        ├── live_goals_tracker_bar.dart
        └── voice_waveform_visualizer.dart
```

## Pipeline de voz (NO ALTERAR)

```
record (AAC/m4a) → Groq Whisper (en) → DeepSeek SSE (deepseek-chat) → flutter_tts (rate 0.48)
```

- Hold-to-Talk vía paquete `record` (no `speech_to_text`).
- Evaluación de objetivos por keyword: `isSatisfiedBy`.
- Conversaciones de escenario persisten; chats libres son efímeros.

## Flujo

```
ConversationScreen
   ├─ pre: ConversationalTacticsNavigator (táctica → bonus XP)
   ├─ loop: mensaje usuario → STT → LLM → TTS → evaluación de metas → recompensa
   └─ post: /summary (SessionSummaryScreen)
```

## Decisiones

- Feature-first; Riverpod para estado de conversación.
- `_AnimatedMessage` top-level (corregido error de clase anidada).
- Microinteracciones en `_GoalChip` (AnimationController 600ms).

## Gaps

1. HUD/header de conversación no está al nivel de la plantilla battle.
2. `FloatingReward` no está integrado en el flujo de logros.
