# Resumen de implementación

> **Ruta:** `Docs/Progression/ImplementationSummary.md`

---

## Cambios

### 1. Nuevo servicio puro: `LessonUnlockService`
**Archivo:** `lib/features/dashboard/domain/models/lesson_unlock_service.dart`

- Clasifica cada lección en `completedByPlayer | unlockedByOracle | nextAvailable | locked`.
- Recibe `userCefr`, catálogo y `completedLessons` (sin dependencias de Flutter).
- Orden canónico `[A1,A2,B1,B2,C1,C2]` y funciones puras → testeable.

### 2. Roadmap (`learning_path_roadmap.dart`)
- Reemplaza la lógica inline `isNextLesson`/`isLocked` por `LessonUnlockService`.
- Los niveles previos al del usuario se muestran como **desbloqueados (insignia Oráculo)**.
- Nivel actual: primera disponible (▶), resto secuencial (🔒).
- Niveles superiores: 🔒.
- **Visual diferenciado**:
  - `completedByPlayer` → check dorado/medalla.
  - `unlockedByOracle` → insignia del Oráculo (auto_awesome) sobre fondo púrpura.
  - `nextAvailable` → play ▶ + glow.
  - `locked` → candado.

### 3. `dashboard_screen.dart`
- Pasa `activeUserLevel` (ya lo hace) → el roadmap recalcula solo al cambiar `level_code`.
- No requiere cambios de llamada (el nivel ya viene de `userProgressProvider`/BD).

### 4. `ProgressUtils`
- Se mantiene (helper puro) y es reutilizado por el servicio.

## Reevaluaciones futuras
- Al terminar una nueva evaluación del Oráculo, `_persistOracleAssessment` actualiza
  `cefr_level_id` en BD → `userProgressProvider` cambia → `LearningPathRoadmap` recibe el
  nuevo `activeUserLevel` → se **recalcula automáticamente** (vía `didUpdateWidget`).
- Si el usuario asciende de nivel, las rutas previas quedan desbloqueadas sin intervención.

## QA
- `flutter analyze`: 0 errores.
- `flutter test`: 73/73.
- `flutter build apk --debug`: OK.
