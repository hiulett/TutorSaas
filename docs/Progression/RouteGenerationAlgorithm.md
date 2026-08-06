# Algoritmo de generación de la Ruta por Etapas

> **Ruta:** `Docs/Progression/RouteGenerationAlgorithm.md`

---

## Entradas
- `userCefr` (String): nivel CEFR del usuario (de `userProgressProvider`/BD).
- `catalog` (List<LessonData>): catálogo de lecciones (ya ordenado por nivel+orden).
- `completedLessons` (List<Map>): historial de `conversations` (scenario_id).

## Salida por lección
Un enum de estado:

| Estado | Significado | Visual |
|---|---|---|
| `completedByPlayer` | El usuario completó la lección (fila en conversations) | Check dorado/medalla |
| `unlockedByOracle` | Desbloqueada automáticamente por el nivel demostrado en el Oráculo | Pergamino sellado / insignia Oráculo |
| `nextAvailable` | Primera lección disponible del nivel actual | Play ▶ + glow |
| `locked` | No accesible aún | Candado 🔒 |

## Algoritmo

```
función clasificarLecciones(userCefr, catalog, completedLessons):
  ordenNiveles = [A1, A2, B1, B2, C1, C2]
  idxNivelUsuario = índice de userCefr en ordenNiveles
  porNivel = agrupar catalog por lesson.level

  para cada lección L en catalog:
    si L está en completedLessons:
      estado[L] = completedByPlayer
      continuar

    idxNivelLeccion = índice de L.level en ordenNiveles

    si idxNivelLeccion < idxNivelUsuario:
      estado[L] = unlockedByOracle          # niveles previos: todo desbloqueado
    si idxNivelLeccion > idxNivelUsuario:
      estado[L] = locked                    # niveles superiores: bloqueado
    si idxNivelLeccion == idxNivelUsuario:
      # Nivel actual: la primera no completada y consecutiva está disponible
      anterioresDelNivel = lecciones del mismo nivel antes de L
      si TODAS anterioresDelNivel están en completedLessons:
        estado[L] = nextAvailable            # primera disponible
      si no:
        estado[L] = locked                   # secuencial dentro del nivel

  devolver estado
```

## Nota sobre progresión cruzada
- Dentro del nivel actual, la disponibilidad es **estrictamente secuencial** (solo la
  primera lección no completada del nivel).
- Los niveles previos se muestran como desbloqueados (no bloquean), aunque el usuario no
  las haya completado una a una — se asume dominio por la clasificación del Oráculo.
- Completar lecciones de niveles previos sigue contando en el progreso global
  (`completedLessons`), pero no afecta al desbloqueo del nivel actual.

## Reutilización
- `ProgressUtils.isLessonCompleted` se mantiene como helper puro de "¿hay fila en conversations?".
- El nuevo `LessonUnlockService` lo usa internamente (sin duplicar).
