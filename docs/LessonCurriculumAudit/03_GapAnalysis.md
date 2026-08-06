# 03 — Análisis de brechas (Gap Analysis)

## Brechas detectadas

### BD `scenarios`
| Nivel | Filas actuales | Válidas | Requeridas | Brecha |
|---|---|---|---|---|
| A1 | 540 | 0 | 20 | −540 filas + +20 válidas |
| A2 | 540 | 0 | 20 | −540 + +20 |
| B1 | 540 | 0 | 20 | −540 + +20 |
| B2 | 540 | 0 | 20 | −540 + +20 |
| C1 | 540 | 0 | 20 | −540 + +20 |
| C2 | 540 | 0 | 20 | −540 + +20 |

> La brecha no es de **cantidad** sino de **calidad**: hay 3240 filas, pero ninguna es válida. La acción es **reemplazar** por las 120 curadas, no añadir.

### Catálogo Flutter
| Nivel | Existente | Requerida | Faltante |
|---|---|---|---|
| A1 | 5 | 20 | +15 |
| A2 | 3 | 20 | +17 |
| B1 | 2 | 20 | +18 |
| B2 | 2 | 20 | +18 |
| C1 | 1 | 20 | +19 |
| C2 | 4 | 20 | +16 |
| **Total** | **17** | **120** | **+103** |

## Diagrama de brecha (BD)

```
ANTES (BD contaminada)
  A1 [540 filas placeholder] · A2 [540] · ... · C2 [540]   = 3 240
  ── todas inválidas ──

ACCIÓN: TRUNCATE + seed 120 oficiales × 4 idiomas = 480 filas

DESPUÉS (BD currículo oficial)
  A1 [20 títulos × 4 idiomas] · ... · C2 [20 × 4]          = 480 filas
  ── todas válidas ──
```

## Diagrama de brecha (Flutter)

```
ANTES
  catalog = [17 lecciones]  (A1:5, A2:3, B1:2, B2:2, C1:1, C2:4)

ACCIÓN: regenerar catalog con las 120 oficiales (script Node desde seed)

DESPUÉS
  catalog = [120 lecciones] (A1:20, A2:20, B1:20, B2:20, C1:20, C2:20)
```

## Duplicados a evitar
- **Nunca** dos lecciones con el mismo `id` o el mismo `title` dentro de un nivel.
- El seed oficial ya tiene 20 títulos **únicos por nivel** (verificado por script: 20 únicos en cada nivel).
- El catálogo Flutter generado tiene 120 `id` únicos y 120 títulos únicos por nivel.

## Verificación de no-duplicación

```sh
# Script de extracción (Node)
# node extract_lessons.js  →  120 lecciones, 20 por nivel, todas únicas

A1: 20 lecciones, 20 únicas ✅
A2: 20 lecciones, 20 únicas ✅
B1: 20 lecciones, 20 únicas ✅
B2: 20 lecciones, 20 únicas ✅
C1: 20 lecciones, 20 únicas ✅
C2: 20 lecciones, 20 únicas ✅
```
