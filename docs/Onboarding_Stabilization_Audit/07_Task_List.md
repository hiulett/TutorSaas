# Lista de Tareas 07 — Backlog Priorizado de Estabilización del Onboarding

**Fecha:** 2026-08-01
**Ámbito:** Backlog ejecutable para las correcciones del onboarding (Fases del `06_Implementation_Plan.md`)
**Estado:** Propuesto — sin código modificado

---

## Convención

- **Prioridad**: P0 (bloquea la experiencia percibida) / P1 (consistencia y robustez) / P2 (diagnóstico).
- **Impacto**: Alto / Medio / Bajo — efecto en el usuario o en la integridad del dato.
- **Riesgo**: Alto / Medio / Bajo — probabilidad de romper el flujo o requerir rework.
- **Dependencia**: tareas que deben ejecutarse antes.

## Backlog

| ID | Tarea | Prioridad | Impacto | Riesgo | Archivos | Verificación |
|---|---|---|---|---|---|---|
| T01 | **Oráculo por voz — STT**: sustituir `TextField` del Oráculo por botón hold-to-talk (`record`) + `ConversationRepository.transcribeAudio(audioPath)` (Groq), anexando la transcripción al hilo `_answers` | P0 | Alto | Medio | `oracle_conversation_screen.dart`; reutilizar `conversation_repository_impl.dart:36` | Hold-to-talk graba y transcribe; `flutter analyze` 0 errores |
| T02 | **Oráculo por voz — TTS**: respuesta oral del Oráculo con `flutter_tts` (rate 0.48). ⚠️ No usar `generateTtsAudio` (stub `''` en `conversation_repository_impl.dart:219`) | P0 | Alto | Medio | `oracle_conversation_screen.dart`; `flutter_tts` directo | El Oráculo "habla" cada pregunta; análisis 0 errores |
| T03 | **Eliminar/justificar el `TextField`**: retirar input escrito (o exponerlo solo como fallback accesible y documentado) | P0 | Medio | Bajo | `oracle_conversation_screen.dart:64`, `:400-401` | No existe caja de texto en el flujo principal; revisar accesibilidad |
| T04 | **Tarjeta del héroe post-onboarding**: mostrar `AIPickHeroCard` o resumen del cazador tras `_completeOnboardingAndPurchase()` exitoso, antes de `context.go('/home')` | P0 | Alto | Medio | `onboarding_screen.dart:225`; `ai_pick_hero_card.dart`; opcionalmente `recommended_lessons_hub.dart` | Al terminar el wizard se ve el héroe y el CTA lleva a `/home` |
| T05 | **Helper de progreso central** (`progress_utils.dart`): único cálculo alimentado por `completedLessonsProvider` (`dashboard_providers.dart:228`) | P1 | Alto | Alto | `progress_utils.dart` (**nuevo**); `dashboard_providers.dart` | Tests de unidad del helper; mismo % en las 3 pantallas |
| T06 | **Dungeon header corregido**: dejar de medir posición de nivel (`(effectiveIndex+1)/6`) y usar progreso real de lecciones completadas | P1 | Medio | Medio | `dungeon_map_screen.dart:23-26`, `:114-118` | Header refleja lecciones completadas, no solo el nivel |
| T07 | **Chat usa el mismo origen**: `savedProgress` desde el helper en vez de `match['progress']` de `recommendedLessonsProvider` | P1 | Medio | Medio | `conversation_screen.dart:558-574` | Misma lección muestra mismo % en chat y roadmap |
| T08 | **Panel de avatar responsive**: `Row spaceEvenly` con 6 orbes fijos (48 px) → `Wrap`/layout fluido para evitar overflow | P1 | Medio | Bajo | `character_creation_wizard.dart` | Sin `RenderFlex overflow` en pantallas ≤320 dp; análisis 0 errores |
| T09 | **Diagnóstico de IA**: preparar checklist y esperar captura del usuario (error/log/status code) antes de tocar código | P2 | Alto | Bajo | `api_constants.dart`, `conversation_repository_impl.dart`, `placement_ai.dart` | Reproducir error con modo dev; captura obtenida y documentada |
| T10 | **QA de regresión del onboarding**: probar flujo completo (5 pasos, guardado, modos dev, free→paywall post-sesión) tras T01–T08 | P1 | Alto | Bajo | `onboarding_screen.dart` + todo el flujo | Smoke test end-to-end; sin regresiones en `/home` |
| T11 | **Documentación final**: actualizar `00_Project_Status.md`, changelog y ADRs (p. ej. ADR-006 voice-pipeline) con el estado real post-cambios | P2 | Bajo | Bajo | `docs/00_Project_Status.md`, `docs/Change_Log.md`, `docs/adr/` | Docs coherentes con el código implementado |

## Secuencia sugerida

```
T01 → T02 → T03   (Fase 1 — Oráculo por voz)
  ↓
T04               (Fase 2 — Tarjeta del héroe)
  ↓
T05 → T06 → T07   (Fase 3 — Progreso centralizado)
  ↓
T08               (Fase 4 — Avatar responsive)
  ↓
T10               (QA regresión — validar todo lo anterior)
  ↓
T09 → T11         (P2 — Diagnóstico IA + docs finales)
```

## Reglas de verificación por tarea

1. Cada tarea termina con `flutter analyze` en **0 errores** (los ~56 infos/warnings existentes se toleran).
2. Después de tocar `.arb`, ejecutar `flutter gen-l10n`.
3. Usar el **modo dev** (`devAlwaysShowOnboardingProvider`, `settings_screen.dart:1238`) como herramienta de QA para repetir el onboarding sin ensuciar perfiles.
4. **No usar `git checkout`/`git restore`** sobre Dart (el repo tiene un solo commit; se pierde el trabajo).
5. Las tareas P0 (T01–T04) se prueban en dispositivo real para validar audio/latencia.
