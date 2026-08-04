# Fase 4 — Recovery

> Recuperación y gestión de regresiones de la Fase 4.

## ⚠️ Contexto crítico del repo

- Repo con UN SOLO commit; trabajo sin commitear.
- **PROHIBIDO** `git checkout`/`git restore` sobre Dart — revertir editando.

## ⚠️ Pipeline de voz — DO NOT ALTER

- record → Groq → DeepSeek SSE → flutter_tts (rate 0.48).
- Cualquier cambio debe respetarlo; verificarlo tras cada iteración.

## Procedimiento

1. Backup/commit antes de retocar `conversation_screen.dart` (1175 líneas).
2. Cambios pequeños por widget; `flutter analyze` + `flutter test` tras cada uno.
3. El `_AnimatedMessage` debe permanecer top-level (no anidado en otra clase).
4. Registrar regresiones en `Change_Log.md` / `Known_Issues.md`.

## Riesgos específicos de Fase 4

- Refactor del header/HUD: alto riesgo de romper el layout de la conversación activa.
- Microinteracciones: evitar animaciones infinitas que rompan `pumpAndSettle` en tests.
