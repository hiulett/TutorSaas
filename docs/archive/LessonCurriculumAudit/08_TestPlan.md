# 08 — Plan de pruebas (Test Plan)

## Pruebas automatizadas

### `test/lesson_catalog_test.dart` (actualizado)

| # | Caso | Verificación |
|---|---|---|
| 1 | Catálogo total | `catalog.length == 120` |
| 2 | 20 por nivel | `byLevel[A1..C2] == 20` cada uno |
| 3 | IDs únicos | `set(ids).length == 120` |
| 4 | Títulos únicos por nivel | `set(titles[nivel]).length == 20` |
| 5 | Contenido completo | cada lección con `goals` (≥3), `usefulPhrases`, `mainObjective`, `initialAssistantMessage` |
| 6 | Resolución por ID | `getLessonById('a1_ordering_coffee_at_a_cafe')` → A1 |
| 7 | Resolución por título | `getLessonById(title: 'Ordering Coffee at a Cafe')` → A1 |
| 8 | C2 poblada | 20 lecciones C2 con metas y objetivo |
| 9 | Null-safe | `getLessonById(null, title: null)` no crashea |
| 10 | Apertura por nivel | `levelAppropriateOpening` gradúa A1/B1/C2 |
| 11 | Niveles multi-banda | `'A1-C2'` y desconocido → no vacío |

## Casos de progresión (matriz de %)

Para cada misión, verificar que Dashboard y Chat muestren el mismo % (ver `Docs/MissionProgressAudit/06`):

| Completadas | Total | % |
|---|---|---|
| 0/5 | 0% | 0.0 |
| 1/5 | 20% | 0.2 |
| 2/5 | 40% | 0.4 |
| 3/5 | 60% | 0.6 |
| 4/5 | 80% | 0.8 |
| 5/5 | 100% | 1.0 |

## Pruebas manuales (post-aplicación BD)

1. **Onboarding**: crear perfil → el Oráculo clasifica → nivel asignado.
2. **Ruta por Etapas**: ver 20 lecciones por nivel, ordenadas, desbloqueo secuencial.
3. **Iniciar misión**: abrir `a1_ordering_coffee_at_a_cafe` → el tutor saluda acorde a A1.
4. **Completar objetivos**: al lograr metas, el % sube en el chat y en el dashboard al volver.
5. **Recomendaciones**: `recommendedLessonsProvider` sugiere la siguiente lección del nivel.
6. **Gremio/Mapa**: `dungeon_map_screen` muestra el progreso por objetivos del nivel.
7. **Rendimiento**: el catálogo de 120 se carga sin consultas extra (estático); BD consulta ligera `scenarios`.

## Resultado actual

```
flutter analyze            → 0 errores
flutter test               → 102 tests passed (incluye 11 del catálogo)
flutter build apk --debug  → OK
```
