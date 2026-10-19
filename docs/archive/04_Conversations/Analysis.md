# Fase 4 — Analysis

> Análisis del estado actual del Sistema de Conversaciones.

## 1. ConversationScreen (`conversation_screen.dart`, 1175 líneas)

Componentes detectados:
- **Pipeline de voz** (NO alterar): record (AAC/m4a) → Groq Whisper (en) → DeepSeek SSE → flutter_tts (rate 0.48).
- **Objetivos dinámicos**: `LiveGoalsTrackerBar(goals, goalEvaluationResults, onTapCompass)` — barra con chips M1..Mn y contador.
- **Progreso**: `completedGoals/totalGoals` (evaluado por keyword `isSatisfiedBy`).
- **Mensajes animados**: `_AnimatedMessage` (top-level, slide+fade) aplicado al último mensaje.
- **NPC Oráculo**: `HunterCatalog.oracle`.
- **Waveform**: `voice_waveform_visualizer.dart` (visualización de grabación).
- **Tácticas**: invocación de `ConversationalTacticsNavigator.show(...)` con `onStart(tactic)`.

## 2. ConversationalTacticsNavigator

Bottom sheet con `SystemWindow`:
- Tácticas: `fluency` (+15% DEX XP), `grammar` (+15% INT XP), `hints` (traducciones en pantalla).
- Botón "INICIAR MAZMORRA" → `onStart(tactic)`.

## 3. LiveGoalsTrackerBar

- Chips `M{n}` con animación al completar (escala 1→1.3 easeOutBack + glow emerald).
- Contador `completed/total` en mono.
- Tap → abre detalle de objetivos (compass).

## 4. Paridad con PlantillasHTML

| Plantilla | Elemento | Estado |
|---|---|---|
| `combat_system_english_battle` | Battle HUD | Parcial — objetivos y barra presentes; falta estética completa de battle HUD |
| `conversational_tactics_navigator` | Selector de táctica | ✅ Implementado |
| `ai_mentor_chat_system` | Coach premium | No (Fase 4 lo puede incluir como "Oráculo definitivo") |

## 5. Conclusión

El core conversacional está implementado y funcional. Gaps:
1. "Oráculo definitivo" (header/HUD) — falta refinar header y estética battle.
2. Indicadores de logros y recompensas visuales en flujo (`FloatingReward` no se usa en conversación).
3. El pipeline de voz está aislado; las microinteracciones existen pero pueden unificarse.
