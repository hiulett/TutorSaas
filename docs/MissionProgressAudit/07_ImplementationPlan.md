# 07 — Plan de implementación

## Alcance

- **Fuente única de verdad**: `user_scenario_goals` (objetivos completados) + `LessonData.goals` (objetivos totales del catálogo).
- **Fórmula única**: `MissionProgressService.lessonProgress(completedGoals, totalGoals)`.
- Se mantiene la arquitectura actual (Riverpod, repositorios, feature-first). No se introduce ningún servicio/API nuevo.

## Pasos

### 1. Crear `MissionProgressService`
Archivo nuevo `lib/features/dashboard/domain/models/mission_progress_service.dart`
(módulo puro: `lessonProgress`, `countCompletedGoals`, `completedGoalsForScenario`).
No depende de Flutter → fácil de testear.

### 2. Añadir `completedGoalsProvider` en `dashboard_providers.dart`
`FutureProvider.autoDispose<List<Map<String, dynamic>>>` que consulta:

```sql
SELECT scenario_id, goal_id, is_completed FROM user_scenario_goals WHERE user_id = ?
```

Observa `dashboardRefreshProvider` (igual que `completedLessonsProvider`) para recargar tras `endSession`. En error → `[]`.

### 3. Corregir el Dashboard (`learning_path_roadmap.dart`)
- Convertir el widget en `ConsumerStatefulWidget` para poder leer `completedGoalsProvider`.
- Para cada lección de la etapa:
  - `completedGoals = MissionProgressService.completedGoalsForScenario(rows, lesson.id)`
  - `totalGoals = lesson.goals.length`
  - `progress = MissionProgressService.lessonProgress(...)`
- Pasar ese `progress` real a `QuestCard` (elimina el hardcode `1.0/0.25/0.0`).
- `progressSegments` = `lesson.goals.length` (barra segmentada coherente con los objetivos).
- Barra de etapa: `stageProgress = Σcompleted(etapa) / Σtotal(etapa)`.
- **Eliminar código muerto**: `_getLessonScore`, el parámetro `score` de `_RoadmapNodeTile`, y `_isLessonCompleted` (reemplazado por el conteo de objetivos).

### 4. Corregir el Chat (`conversation_screen.dart`)
- Sustituir el bloque `savedProgress/progressMessages/currentProgress/realProgressRatio` (L583-592) por:

```dart
final currentLesson = LessonCatalog.getLessonById(conversationState.activeScenarioId, title: widget.scenarioTitle);
final realProgressRatio = MissionProgressService.lessonProgress(
  completedGoals: MissionProgressService.countCompletedGoals(conversationState.goalEvaluationResults),
  totalGoals: currentLesson?.goals.length ?? 0,
);
```

- Eliminar el import/uso de `ProgressUtils.lessonProgress` y `completedLessonsProvider` en este screen (si no se usan en otro lugar del mismo).

### 5. Refactorizar `LiveGoalsTrackerBar`
- Sustituir el cálculo inline `completedCount/totalCount` por `MissionProgressService` para que barra verde y amarilla y dashboard compartan la misma fórmula.

### 6. Eliminar duplicados
- `ProgressUtils.lessonProgress` deja de usarse en el chat; si queda sin consumidores (solo `dungeon_map_screen` usa `stageProgress/overallProgress`), se conserva solo para esos agregados, o se migran también a `MissionProgressService`. **Decisión**: migrar `dungeon_map_screen` a `MissionProgressService.completedGoalsForScenario` para no mantener dos utilidades.

### 7. Tests
- Crear `test/mission_progress_service_test.dart` con los casos de `06_TestCases.md` (0/5..5/5, límites, conteo BD, estado en memoria).

### 8. Verificación
- `flutter analyze` → 0 errores.
- `flutter test` → todos los tests pasan.
- `flutter build apk --debug` → OK.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| `completedGoalsProvider` añade una consulta al dashboard | Es una tabla pequeña; `autoDispose` la libera al salir; sustituye lecturas inútiles de `conversations.score` |
| Cambiar `LearningPathRoadmap` a Consumer rompe tests de widget | No hay tests de widget de este componente; `LessonUnlockService.classify` no cambia |
| `goalEvaluationResults` desactualizado tras re-entrada | `initSession` ya llama `loadCompletedGoals` → siembra desde BD |
| Progreso "nextAvailable" sin barra | Se muestra barra 0% en vez de 0.25 ficticio — comportamiento más honesto |

## Impacto sobre el resto de la app

- **Gremio / Perfil / Estadísticas / Historial**: siguen leyendo `user_scenario_goals` (p.ej. `skillsRadarProvider` ya usa objetivos; `recommendedLessonsProvider` usa `goalsDone/totalGoals`). Al centralizar la fórmula, cualquier pantalla nueva debe usar `MissionProgressService`, no recalcular.
- **`dungeon_map_screen`**: se migra a la fuente única (objetivos) para consistencia.
- **Economía/`endSession`**: sin cambios; ya invalida los providers del dashboard.
- **Sin cambios de esquema**: no se agregan columnas ni tablas; `user_scenario_goals` ya existe y se usa.
