# 06 — Casos de prueba

## Pruebas unitarias del servicio (`MissionProgressService`)

### Caso 1 — 0/5 objetivos → 0%
```dart
MissionProgressService.lessonProgress(completedGoals: 0, totalGoals: 5) == 0.0
```

### Caso 2 — 1/5 → 20%
```dart
MissionProgressService.lessonProgress(completedGoals: 1, totalGoals: 5) == 0.2
```

### Caso 3 — 2/5 → 40%
```dart
MissionProgressService.lessonProgress(completedGoals: 2, totalGoals: 5) == 0.4
```

### Caso 4 — 3/5 → 60%
```dart
MissionProgressService.lessonProgress(completedGoals: 3, totalGoals: 5) == 0.6
```

### Caso 5 — 4/5 → 80%
```dart
MissionProgressService.lessonProgress(completedGoals: 4, totalGoals: 5) == 0.8
```

### Caso 6 — 5/5 → 100%
```dart
MissionProgressService.lessonProgress(completedGoals: 5, totalGoals: 5) == 1.0
```

### Casos límite

```dart
lessonProgress(completedGoals: 0, totalGoals: 0) == 0.0   // sin objetivos → 0%
lessonProgress(completedGoals: 7, totalGoals: 5) == 1.0    // clamp a 1.0
lessonProgress(completedGoals: -1, totalGoals: 5) == 0.0   // clamp a 0.0
```

## Pruebas de conteo desde BD

```dart
// Filas simuladas de user_scenario_goals
final rows = [
  {'scenario_id': 'a1_greetings', 'goal_id': 'g1', 'is_completed': true},
  {'scenario_id': 'a1_greetings', 'goal_id': 'g2', 'is_completed': true},
  {'scenario_id': 'a1_greetings', 'goal_id': 'g3', 'is_completed': false},
  {'scenario_id': 'a1_greetings', 'goal_id': 'g4', 'is_completed': false},
  {'scenario_id': 'a1_greetings', 'goal_id': 'g5', 'is_completed': false},
];

completedGoalsForScenario(rows, 'a1_greetings') == 2   // 2/5 → 40%
completedGoalsForScenario(rows, 'otra_mision') == 0    // filas de otra misión no cuentan
```

## Pruebas de estado en memoria (chat)

```dart
countCompletedGoals({'g1': true, 'g2': true, 'g3': false, 'g4': false, 'g5': false}) == 2
countCompletedGoals({}) == 0
```

## Prueba de integración UI (paridad)

Para la misión `a1_greetings` (5 objetivos), el valor que pinta `QuestCard.progress` en el dashboard **debe ser idéntico** al que usa `LiveGoalsTrackerBar` / la barra amarilla del chat:

```
dashboardQuestCardProgress == chatBarProgress == completedGoals / 5
```

Se comprueba que ambos consumen `MissionProgressService` con los mismos inputs (objetivos completados / objetivos totales del catálogo).

## Archivo de test

`test/mission_progress_service_test.dart`
