# Auditoría 04 — Sincronización de Progreso (Inconsistencia entre Roadmap y Chat)

**Fecha:** 2026-08-01
**Ámbito:** Cálculo y visualización del progreso de lecciones (dungeon map, roadmap, chat)
**Estado:** Hallazgo verificado — propuesta de corrección (sin cambios de código)

---

## 1. Hallazgo

Existen **3 cálculos de progreso distintos e inconsistentes** para la misma lección/contenido. El usuario reporta que el **roadmap muestra un % de avance en la primera lección**, mientras que el **chat muestra 0%** para la misma lección.

Los tres orígenes son:

| Pantalla | Cálculo | Referencia |
|---|---|---|
| **Dungeon map (header)** | `SegmentedBar(value: (effectiveIndex + 1) / _levelOrder.length)` → **posición del nivel actual en la lista** (`A1..C2`), NO progreso real de lecciones completadas | `dungeon_map_screen.dart:114-118` |
| **LearningPathRoadmap** | `stageProgress = completedCount / totalCount` por etapa, con `completedCount` = lecciones de la etapa completadas según `widget.completedLessonsHistory` (= `completedLessonsProvider`) | `learning_path_roadmap.dart:105-107` |
| **Chat** | `realProgressRatio = max(savedProgress, (mensajes-1)/10)`, con `savedProgress` desde `recommendedLessonsProvider` (`match['progress']`) y `currentProgress = progressMessages/10` | `conversation_screen.dart:558-574` |

## 2. Causa raíz

La **fuente de verdad no está centralizada**. Cada pantalla deriva el progreso de una fuente distinta:

1. **Dungeon header** → posición de nivel (`_levelOrder`) — mide en qué punto de la lista está el usuario, no cuánto ha completado.
2. **Roadmap** → `completedLessonsProvider` (tabla `conversations`) — lecciones completadas por etapa.
3. **Chat** → `match['progress']` de `recommendedLessonsProvider` (`dashboard_providers.dart:32`), con fallback a `(mensajes-1)/10` (fórmula local; comentario "matches getRecommendedLessons formula").

Como el chat depende del campo `progress` calculado por `recommendedLessonsProvider`, y ese campo no se alimenta de la misma fuente que `completedLessonsProvider` (que sí lee `conversations`), **una misma lección puede mostrar avance en una pantalla y 0% en otra**.

## 3. Evidencia

| Elemento | Referencia |
|---|---|
| Fuente de lecciones completadas (`conversations` → `scenario_id, score, fluency_score, created_at` filtrado por `user_id`) | `completedLessonsProvider` — `dashboard_providers.dart:228` |
| Dungeon header = posición de nivel, no progreso | `dungeon_map_screen.dart:114-118` (`SegmentedBar` + `_levelOrder` + `effectiveIndex`) |
| Uso de `isLessonCompleted` (basado en `completedLessonsProvider`) | `dungeon_map_screen.dart` |
| Roadmap por etapa: `completedCount / totalCount` y `_getLessonScore` | `learning_path_roadmap.dart:105-107` |
| Chat: `max(savedProgress, (mensajes-1)/10)` | `conversation_screen.dart:558-574` |
| Origen de `savedProgress` = `match['progress']` | `recommendedLessonsProvider` — `dashboard_providers.dart:32` |
| Contrato SQL de la fuente | `conversations` → `select('scenario_id, score, fluency_score, created_at').eq('user_id', ...)` |

## 4. Solución propuesta — un único origen de progreso

1. **Centralizar la fuente de verdad en `completedLessonsProvider`** (tabla `conversations`). Definir el progreso de una lección como:
   - Si existe una conversación completada para la lección → progreso derivado de `score` / `fluency_score`.
   - Si no existe → **0%**, coherente en todas las pantallas.

2. **Crear un helper central** (`lib/features/dashboard/domain/models/progress_utils.dart` o un provider) que todas las pantallas consuman. Este helper debe exponer, al menos:
   - `lessonProgress(scenarioId)` → 0..1 derivado de la conversación completada.
   - `stageProgress(stageId)` → `completedCount / totalCount` por etapa (mover la lógica de `learning_path_roadmap.dart` aquí).
   - `levelProgress(levelId)` → **lecciones completadas del nivel actual / total de lecciones del nivel** (reemplazar la posición de nivel).

3. **Dungeon header:** calcular lecciones completadas del nivel actual sobre el total del nivel (basado en `completedLessonsProvider`), **no** la posición en `_levelOrder`.

4. **Chat:** usar el mismo origen central. Mostrar 0% hasta que exista conversación guardada (comportamiento coherente con roadmap/dungeon). Eliminar o reducir la dependencia de `match['progress']` como fuente primaria; si `recommendedLessonsProvider` necesita el campo `progress`, debe calcularlo desde el mismo helper.

5. **`recommendedLessonsProvider`:** alinear el cálculo de `match['progress']` con el helper central para que nunca contradiga el roadmap.

## 5. Archivos afectados

- `lib/features/dashboard/presentation/dungeon_map_screen.dart`
- `lib/features/dashboard/presentation/learning_path_roadmap.dart`
- `lib/features/conversation/presentation/conversation_screen.dart`
- `lib/features/dashboard/data/dashboard_providers.dart` (`completedLessonsProvider`, `recommendedLessonsProvider`)
- **Nuevo:** `lib/features/dashboard/domain/models/progress_utils.dart` (helper central)

## 6. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **Romper la navegación** al cambiar el header del dungeon map | Mantener intactos los callbacks de navegación; tocar solo el cálculo del `SegmentedBar`. |
| **Perder la lógica de desbloqueo de niveles** (bloqueo A1→A2→…→C2) | El desbloqueo y la barra de progreso son conceptos distintos: preservar `isLessonCompleted` / condiciones de unlock tal como están; solo corregir la métrica que alimenta la barra. |
| **Cambiar el % mostrado en el chat** tras unir fuentes | Es el comportamiento deseado (coherencia); documentar en el changelog y validar con el usuario. |
| **Cálculos en dos lugares** (helper y providers) mientras dura la migración | Migrar de una vez; el helper central es la única fuente que deben consumir las 3 pantallas. |

## 7. Notas de cierre

- No se modifica código en esta auditoría; es propuesta de corrección pendiente de aprobación.
- El contrato de datos (`conversations`) no cambia: solo la derivación del progreso en UI.
- Tras implementar, verificar el escenario reportado (roadmap % > 0 vs chat 0%) y confirmar que ambas pantallas coinciden.
