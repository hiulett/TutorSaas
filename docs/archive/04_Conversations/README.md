# Fase 4 — Sistema de Conversaciones

> Estado: **Documentación** (análisis y plan). Sin cambios de código en esta fase.
> Carpetas de referencia: `lib/features/conversation/`, `PlantillaHtml/combat_system_english_battle/`.

## Resumen

Oráculo definitivo, header y HUD de conversación, barra de progreso, objetivos dinámicos,
animaciones, microinteracciones, indicadores de logros y recompensas visuales.

## Estado actual

- **ConversationScreen** (1175 líneas): pipeline de voz (record → Groq → DeepSeek SSE →
  flutter_tts), objetivos dinámicos con `LiveGoalsTrackerBar`, mensajes animados
  (`_AnimatedMessage` slide+fade), waveform (`voice_waveform_visualizer`).
- **ConversationalTacticsNavigator** (`conversational_tactics_navigator.dart`): selector de
  táctica (fluidez/gramática/pistas) con bonus de XP, `SystemWindow` + bottom sheet.
- **LiveGoalsTrackerBar** (`live_goals_tracker_bar.dart`): chips M1..Mn con animación de
  completado (escala + glow), contador `completed/total`.
- **LevelExamScreen**: examen por nivel CEFR.
- **Oracle**: `HunterCatalog.oracle` (NPC) usado en la conversación.

## Documentos

| Documento | Contenido |
|---|---|
| [Analysis.md](Analysis.md) | Análisis del módulo de conversaciones |
| [Implementation_Plan.md](Implementation_Plan.md) | Plan de implementación |
| [Architecture.md](Architecture.md) | Arquitectura del pipeline conversacional |
| [Database.md](Database.md) | Esquema de conversaciones y objetivos |
| [Tasks.md](Tasks.md) | Tareas y estado |
| [QA_Report.md](QA_Report.md) | Reporte de QA |
| [Recovery.md](Recovery.md) | Recuperación/regresiones |
| [Known_Issues.md](Known_Issues.md) | Problemas conocidos |
| [Change_Log.md](Change_Log.md) | Registro de cambios |
