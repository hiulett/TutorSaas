# 06 — Tareas de Implementación — Onboarding Revamp

> Proyecto: TutorSaas · Fecha: 2026-07-31
> Objetivo: separar idioma/país/objetivo, clasificación por IA (voz), personaje RPG moderno, notificaciones elegantes.
> Regla: NO eliminar lógica. Reorganizar/unificar. Cada cambio pequeño y verificable.

## P0 — Fundamento (sin cambios de UI)

| # | Tarea | Archivos | Verificación |
|---|-------|----------|--------------|
| T01 | Mapeo CEFR ↔ rango del juego (E,D,C,B,A,S,SS,SSS) como helper puro | `lib/features/onboarding/domain/models/cefr_rank.dart` (nuevo) | unit test |
| T02 | Extender `PlacementResult` con scores/fortalezas/debilidades/explicación | `lib/features/onboarding/domain/models/placement_result.dart` (+freezed) | `flutter analyze` |
| T03 | Prompt de evaluación IA (DeepSeek) + parsing JSON → PlacementResult | `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart` + `lib/core/ai/placement_ai.dart` (nuevo) | fallback a heurística |

## P1 — Estructura del flujo (onboarding_screen)

| # | Tarea | Archivos | Orden |
|---|-------|----------|-------|
| T04 | Separar página 1 en 2: "Idioma del Despertar" (nativo) y "País de Origen" (sugeridos + buscador) | `onboarding_screen.dart` | 1 |
| T05 | Mover idioma objetivo a paso independiente | `onboarding_screen.dart` | 2 |
| T06 | Reemplazar selección manual de nivel por pantalla de clasificación IA (explicación + "INICIAR EVALUACIÓN" → /oracle-test) | `onboarding_screen.dart` | 3 |
| T07 | Conectar `/oracle-test` para que devuelva resultado al flujo (pop con PlacementResult) en vez de escapar a /home | `oracle_conversation_screen.dart` | 4 |

## P2 — Evaluación por IA

| # | Tarea | Archivos | Orden |
|---|-------|----------|-------|
| T08 | El chat del Oráculo usa el pipeline de voz real (hold-to-talk + STT) en lugar de TextField | `oracle_conversation_screen.dart` | 5 |
| T09 | Al terminar, llamar al evaluador IA y persistir rango del juego + scores + fortalezas/debilidades/explicación | `oracle_conversation_screen.dart`, `placement_providers.dart` | 6 |
| T10 | Persistencia SQL: columnas game_rank/scores/strengths/weaknesses/explanation en user_language_profiles (migración) | `supabase/migrations/20260731_onboarding_revamp.sql` | 7 |

## P3 — Personaje RPG

| # | Tarea | Archivos | Orden |
|---|-------|----------|-------|
| T11 | Tarjetas de clase con estado seleccionado RPG (borde rúnico + glow + check + AppMotion) | `character_creation_wizard.dart` | 8 |
| T12 | Botón continuar → `RunicButton`; avatares como orbes con anillo; nombre con estilo System HUD | `character_creation_wizard.dart` | 9 |

## P4 — Notificaciones elegantes

| # | Tarea | Archivos | Orden |
|---|-------|----------|-------|
| T13 | Guía visual: SnackBars con fondo `surfaceContainerHigh` + borde de acento semántico (éxito emerald, error crimson, aviso ámbar, info cian tenue) | `app_theme.dart` + call-sites de SnackBar con backgroundColor plano | 10 |
| T14 | Audit final de notificaciones en onboarding/gremio/economía | varios | 11 |

## QA

| # | Tarea | Verificación |
|---|-------|--------------|
| T15 | `flutter analyze` 0 errores · `flutter test` verdes · `flutter build apk --debug` OK | 12 |
| T16 | Actualizar `07_Final_Report.md` | 13 |
