# Fase 9 — RPG · Sistema de Items (tarea 32)

> Fuente de verdad: `/docs`. Análisis basado en DB real (2026-07-30).

## 1. Estado actual (verificado)

### Catálogo (`cosmetic_catalog`) — 23 items
| Categoría | Items | Raridades |
|---|---|---|
| title | 5 (Novato, Elocuente, Imparable, Cazador de Sombras, Leyenda Viva) | common→legendary |
| frame | 3 (Escudo, Dragón, Abismo) | rare→legendary |
| aura | 3 (Maná, Fuego, Sombras) | rare→legendary |
| pet | 2 (Lunático, Fénix) | epic→legendary |
| emote | 1 | common |
| table_theme | 2 (Bosque, Abismo) | epic→legendary |
| relic | 3 (Oráculo, Dragón, Tiempo) | rare→epic (precio 0 = recompensas) |
| consumable | 4 (invocación+5/+20, pergamino10/50) | common→rare |

### Inventario (`player_inventory`)
- CHECK `item_type` soporta 11 tipos: title, skin, frame, aura, pet, emote, theme, table_theme, guild_decoration, relic, consumable.
- UNIQUE (user_id, item_code) · FK users · `is_equipped`.
- Acceso: repo T-501 (`getInventory`, `toggleEquip`, `purchaseItem`).

### Lógica de compra (repo economía)
- `purchaseItem`: consumibles aplican efecto (`invocations_max`+5/+20); cosméticos insertan con `is_equipped=false`.
- `toggleEquip`: alterna equipado.

## 2. Brechas del sistema RPG (respecto al prompt)

| Requisito prompt | Estado | Brecha |
|---|---|---|
| Consumibles | ✅ 4 items | Faltan más tipos (llaves, pergaminos de habilidad) |
| Equipamiento | ⚠️ | Solo cosmético (title/frame/aura/pet) — sin atributos |
| **Llaves** (keys) | ❌ | No existe categoría `key` en el CHECK |
| **Libros** (books/scrolls) | ❌ | No existe categoría `book` |
| Pergaminos | ✅ `player_pergaminos` | Es contenido de práctica, no item de inventario |
| **Reliquias** | ⚠️ | 3 en catálogo pero precio 0 (sin forma de obtenerlas como drop) |
| **Coleccionables** | ❌ | Sin sistema de colección/completitud |
| **Raros/legendarios** | ✅ | Raridades definidas en catálogo |
| **Objetos que modifican misiones** | ❌ | Sin mecánica (tarea 33) |

## 3. Diseño propuesto — Sistema de Items ampliado

### A. Nuevas categorías (ampliar CHECK de `player_inventory`)
| Categoría | Propósito | Ejemplos |
|---|---|---|
| `key` | Desbloquea contenido (mazmorras, contenido premium temporal) | Llave de la Mazmorra Oculta, Llave del Archivo |
| `book` | Otorga conocimiento (guías de gramática, libros de frases) | Libro de Phrasal Verbs, Grimorio de Tiempos Verbales |
| `mission_modifier` | Modifica misiones (tarea 33) | Pergamino de Recompensa x2, Piedra de Dificultad |

### B. Columnas adicionales
| Columna | Tabla | Uso |
|---|---|---|
| `item_effect` JSONB | `player_inventory` | Efecto consumible (ej. `{"type":"invocations","amount":5}`) |
| `item_meta` JSONB | `player_inventory` | Metadata (nivel requerido, temporada) |
| `source` | `player_inventory` | Cómo se obtuvo (shop/loot/quest/reward) |

### C. Obtención de reliquias (drops)
- Reliquias → drops de misiones/conversaciones (T-505 ya da fragmentos; ampliar a reliquias raras).

## 4. Plan de implementación (tareas atómicas)
| # | Tarea | Prioridad | Nota |
|---|---|---|---|
| IT-01 | Ampliar CHECK `item_type` con `key`, `book`, `mission_modifier` | P0 | SQL |
| IT-02 | Columnas `item_effect`, `item_meta`, `source` en `player_inventory` | P0 | SQL |
| IT-03 | Seed de items nuevos (3 llaves, 3 libros, 2 modificadores) | P0 | SQL |
| IT-04 | Repo: aplicar efecto consumible genérico (`item_effect`) | P1 | Código |
| IT-05 | Repo: `getInventory` filtra por categoría/source | P1 | Código |

## 5. Decisiones
- El sistema actual es **sólido como base** (11 tipos, raridades, equipar). La ampliación es incremental: añadir 3 categorías + metadata + drops.
- Los objetos que modifican misiones (tarea 33) usarán la categoría `mission_modifier`.
- Los cosméticos permanecen **puramente cosméticos** (sin stats) para evitar pay-to-win (tarea 34).
