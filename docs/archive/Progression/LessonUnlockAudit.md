# Diagnóstico del problema — Desbloqueo de lecciones en la Ruta por Etapas

> **Ruta:** `Docs/Progression/LessonUnlockAudit.md`
> **Fecha:** 2026-08-04

---

## Síntoma
Tras la evaluación del Oráculo (ej. nivel **B1**), la Ruta por Etapas del Dashboard muestra
todas las lecciones de niveles anteriores (A1, A2) como **bloqueadas** (🔒), cuando deberían
estar desbloqueadas por haber demostrado ese nivel.

## Causa raíz
La lógica de desbloqueo vive **solo en el frontend**, en
`lib/features/dashboard/presentation/widgets/learning_path_roadmap.dart`:

```dart
final isNextLesson = !isCompleted &&
    (catalogIndex == 0 ||
        (catalogIndex > 0 && _isLessonCompleted(catalog[catalogIndex - 1].id)));
final isLocked = !isCompleted && !isNextLesson;
```

**El bug:** `catalogIndex` es el índice de la lección en el catálogo **global** (A1→C2) y
`isNextLesson` solo mira la lección inmediatamente anterior. Al iniciar, `catalogIndex` de
la primera lección de A2 es > 0, pero la anterior (última de A1) no está completada → toda
la etapa se bloquea, ignorando que el usuario **ya demostró** el nivel en el Oráculo.

**Consecuencia:** el `activeUserLevel` (B1, desde BD) **no participa** en la decisión de
desbloqueo. Las etapas previas quedan bloqueadas.

## Dónde se decide el bloqueo
- **Frontend:** `learning_path_roadmap.dart` (`isLocked` / `isNextLesson`).
- También `dungeon_map_screen.dart` reutiliza `isLessonCompleted` (secuencial por nivel).
- **Backend:** no hay lógica de desbloqueo; solo datos (`user_language_profiles.cefr_levels`,
  `conversations` como historial).

## Duplicación detectada
- `ProgressUtils.isLessonCompleted` (helper puro) duplica la comprobación inline del roadmap
  (`_isLessonCompleted`). Centralizar elimina la duplicación.

## Fuente de la verdad (correcta)
- **Nivel CEFR**: `userProgressProvider` → `user_language_profiles.cefr_levels.code`
  (la escribe el Oráculo vía `_persistOracleAssessment`).
- **Historial**: `completedLessonsProvider` → `conversations` (scenario_id, score).
- No hay valores hardcodeados para el nivel del usuario.

## Solución propuesta
Centralizar la lógica de desbloqueo en un **servicio puro** (`LessonUnlockService`) que:
1. Reciba: nivel CEFR del usuario + catálogo + historial de completadas.
2. Clasifique cada lección como `completed` (jugador), `unlockedByLevel` (Oráculo),
   `nextAvailable` (primera disponible del nivel actual) o `locked`.
3. Reglas: niveles anteriores → desbloqueadas; nivel actual → solo la 1ª disponible y luego
   secuencial; niveles superiores → bloqueadas.
