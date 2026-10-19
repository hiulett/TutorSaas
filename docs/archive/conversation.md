# Conversación — Dungeon of English

> Documento maestro de conversación. Sincronizado: 2026-07-30 (Fases 4, 8, 10).

## Pipeline de voz (NO ALTERAR)
```
record (AAC/m4a) → Groq Whisper (whisper-large-v3-turbo, en) → DeepSeek SSE (deepseek-v4-flash) → flutter_tts (on-device, rate 0.48)
```
- Latencia objetivo <1.5s · TTS on-device = $0 · STT/LLM optimizados (Fase 8).

## Oráculo
- `HunterCatalog.oracle` (NPC, rango SSS).
- Header de conversación con rango del Oráculo + barra SegmentedBar 10 segmentos (T-300/T-301).
- Oracle conversacional para evaluación CEFR (`/oracle-test`, Fase 2).

## Metas y evaluación
- `LiveGoalsTrackerBar`: chips M1..Mn animados + barra segmentada (T-301).
- Evaluación con **ventana móvil** (últimos 12 mensajes, IA-03) usando `deepseek-v4-flash` (IA-02).
- `FloatingReward` "+XP" al completar metas (T-302).
- `_AnimatedMessage` slide+fade (tokens fast, Fase 10).

## Tácticas
- `ConversationalTacticsNavigator` al iniciar: fluidez / gramática / pistas (T-303).
- Persistidas en estado (`selectedTactic`).

## Economía asociada
- Invocaciones (núcleo arcano) limitan turnos de IA (T-506).
- Loot al finalizar sesión: fragmentos + gemas escalados por nivel (T-505/T-507).
- Cuota de minutos mensual (`check_ai_audio_quota`).

## Persistencia
- Escenarios: conversations + messages + user_scenario_goals/phrases.
- Chats libres: efímeros.

## Pendiente
- Moderación/audio real en salas de voz del gremio.
