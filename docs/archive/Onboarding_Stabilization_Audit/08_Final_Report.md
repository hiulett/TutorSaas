# 08 — Informe Final — Onboarding Stabilization Audit

> Proyecto: TutorSaas / Dungeon of English · Fecha: 2026-07-31
> Estado: ✅ Corregido y validado (0 errores analyze · 73/73 tests · build APK OK)

---

## 1. Resumen ejecutivo

Se auditaron y corrigieron 5 frentes: la evaluación del Oráculo (ahora oral por voz), la pantalla de creación del personaje (responsive y consistente), la tarjeta del héroe (ahora visible al finalizar), la sincronización del progreso (una única fuente de verdad) y el diagnóstico del servicio IA (preparado, pendiente de la captura del usuario).

## 2. Hallazgos y causas raíz

| # | Auditoría | Hallazgo | Causa raíz | Solución |
|---|-----------|----------|-----------|----------|
| 1 | Oráculo | Chat ESCRITO (TextField) en lugar de entrevista oral | El revamp no integró el pipeline de voz existente | VoiceService + hold-to-talk + Groq STT + TTS |
| 2 | Crear personaje | Panel avatar (Row de 6×48px) con riesgo de overflow | `Row spaceEvenly` no responsive | `Wrap` (3×2), orbes 48px intactos |
| 3 | Finalización | Tarjeta del héroe NO aparece tras el onboarding | El flujo iba directo a /home | Pantalla "¡BIENVENIDO, CAZADOR!" + AIPickHeroCard |
| 4 | Progreso | 3 cálculos distintos (posición nivel / conteo etapa / match['progress']+mensajes) | Fuente de verdad no centralizada | `ProgressUtils` basado en `completedLessonsProvider` |
| 5 | IA | Error de conexión (captura pendiente) | Por diagnosticar | Checklist de diagnóstico en `05_AI_Service_Diagnostics.md` |

## 3. Cambios implementados

### 3.1 Oráculo por voz — `lib/core/services/voice_service.dart` (nuevo) + `oracle_conversation_screen.dart`
- **`VoiceService.instance`**: singleton desacoplado (record + STT + TTS) reutilizable, con `setTranscriber` inyectable.
  - `startRecording()` (record, aacLc, 16kHz), `stopAndTranscribe()` (valida archivo + transcripción Groq), `speak(text)` (flutter_tts en-US, rate 0.48), `stopSpeaking()`.
- **Oracle**: se eliminó el TextField del flujo principal; ahora es un botón circular **hold-to-talk** (GlassCard, mic, manaCyan) con anillo pulsante mientras graba y spinner al procesar. El saludo y cada pregunta se leen en voz. Fallback: icono "RESPONDER POR TEXTO" (bottom sheet) para accesibilidad.
- `_finish()` intacto: evaluación IA → persistencia detallada → pop con resultado.

### 3.2 Personaje responsive — `character_creation_wizard.dart`
- Panel avatar: `Row spaceEvenly` → `Wrap` (center, spacing 8). 6 orbes 48px fluyen a 3×2 sin overflow. Selección, anillo y glow preservados.

### 3.3 Tarjeta del héroe — `onboarding_screen.dart`
- Nueva pantalla final `_buildHeroWelcomeScreen()`: "¡BIENVENIDO, CAZADOR!" + nombre + clase (icono/color por clase) + pills CEFR y rango del juego + descripción del rango + RunicButton "ENTRAR AL REINO" → /home.
- Guardado intacto; solo se cambió el destino post-guardado (muestra la tarjeta en vez de saltar a /home).

### 3.4 Progreso centralizado — `lib/features/dashboard/domain/models/progress_utils.dart` (nuevo) + `dungeon_map_screen.dart` + `conversation_screen.dart`
- **`ProgressUtils`**: `lessonProgress`, `isLessonCompleted`, `stageProgress`, `overallProgress` — todas basadas en `completedLessonsProvider` (tabla `conversations`).
- **Dungeon header**: ya no usa posición de nivel; usa `ProgressUtils.stageProgress(completedLessons, lecciones del nivel actual)`.
- **Chat**: `savedProgress` ahora usa `ProgressUtils.lessonProgress(completedLessons, scenarioId)` (0 hasta que exista conversación guardada — coherente con el roadmap). Mantiene `mensajes/10` como progreso intra-sesión.
- `recommendedLessonsProvider` intacto (solo el chat dejó de leer `match['progress']`).

### 3.5 Diagnóstico IA — `05_AI_Service_Diagnostics.md`
- Checklist de 8 puntos (ApiConstants, excepciones, reintentos, auth, timeout, proveedor, tokens, red) para diagnosticar el error de conexión cuando el usuario proporcione la captura.

## 4. Verificación

| Check | Resultado |
|-------|-----------|
| `flutter analyze` | 0 errores ✅ |
| `flutter test` | 73/73 ✅ |
| `flutter build apk --debug` | OK ✅ |
| Lógica de negocio | intacta (solo se centralizó cálculo y se añadió voz) |
| Desbloqueo de niveles / navegación | intactos |

## 5. Pendientes

- **Diagnóstico IA**: esperar la captura del error para aplicar el checklist y encontrar la causa raíz.
- **`generateTtsAudio`** del repo sigue siendo stub (devuelve ''); el TTS real lo hace `flutter_tts` vía VoiceService. Puede eliminarse o implementarse según decisión.
- Migración SQL del revamp (`20260731_onboarding_revamp.sql`) pendiente de aplicar para persistir scores/strengths/weaknesses (el código degrada con gracia).

## 6. Resultado esperado (logrado)

- ✅ Evaluación del Oráculo oral y conversacional (voz + TTS + STT), sin cajas de texto en el flujo principal.
- ✅ Creación de personaje responsive y consistente con el tema System HUD.
- ✅ Tarjeta del héroe visible al finalizar el onboarding.
- ✅ Progreso centralizado en una única fuente de verdad.
- ⏳ Diagnóstico IA en curso (a la espera de la captura).
- ✅ Documentación completa en `Docs/Onboarding_Stabilization_Audit/` (8 documentos).
