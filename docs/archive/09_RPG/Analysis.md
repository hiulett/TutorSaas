# Fase 9 — RPG · Objetos que Modifican Misiones (tarea 33)

> Fuente de verdad: `/docs`. Diseño basado en el motor de misiones real (T-400..T-404) + economía (Fase 6).

## 1. Estado actual (verificado)
- Motor de misiones: `mission_templates`, `mission_instances` (status, current/target, recompensas), `secret_missions`, `emergency_missions`, `guild_collaborative_missions`.
- Progresión: `updateProgress(delta)` incremental (T-402).
- Recompensas: `claimReward` → `add_xp`/`add_gems`/`reward_history` (T-500).
- **No existe mecánica de items que modifique misiones.**

## 2. Diseño — Objetos que modifican misiones

### Categoría `mission_modifier` en `player_inventory`

| Item | Efecto | Ejemplo de uso |
|---|---|---|
| **Pergamino de Recompensa x2** | Duplica XP/gemas de la próxima misión completada | Se consume al reclamar |
| **Piedra de Facilidad** | Reduce target_value 50% de una misión activa | Se aplica a una instancia |
| **Piedra de Desafío** | Aumenta recompensa 2x pero sube target 50% | Riesgo/recompensa |
| **Llave de Ruta Secreta** | Desbloquea una misión secreta extra | Activa `secret_missions` |
| **Cristal del Oráculo** | Revela pistas/objetivos de una misión antes de empezar | Reduce dificultad percibida |

### Mecánica de aplicación
1. El jugador posee el item (`player_inventory` con `item_type='mission_modifier'` y `item_effect` JSONB).
2. Al aceptar/reclamar una misión, se ofrecen los modificadores aplicables (UI).
3. Al aplicar:
   - **Recompensa x2**: se guarda `mission_instances.reward_multiplier = 2` (nueva columna).
   - **Facilidad**: se actualiza `target_value = ceil(target * 0.5)`.
   - **Desafío**: `target_value = ceil(target * 1.5)` y `reward_multiplier = 2`.
   - **Ruta secreta**: inserta una `secret_mission` nueva.
4. El item se consume (delete de `player_inventory`).

### Columnas nuevas en `mission_instances`
| Columna | Tipo | Uso |
|---|---|---|
| `reward_multiplier` | INTEGER DEFAULT 1 | Multiplicador de recompensa (1, 2) |
| `applied_modifier_code` | VARCHAR(100) | Item usado (trazabilidad) |

### Impacto en economía
- El x2 de recompensa **aumenta el valor percibido** sin inflar la economía si los items son escasos (drops raros o tienda cara).
- Balance: recompensa base de misiones ya está calibrada (50-400 XP); x2 ocasional no rompe la progresión.
- Riesgo: si es fácil farmear modificadores, inflación de gemas/XP → limitar a 1-2 modificadores activos por día (reutilizar `player_daily_state` o contador).

## 3. Plan de implementación
| # | Tarea | Prioridad | Nota |
|---|---|---|---|
| MM-01 | Columnas `reward_multiplier`, `applied_modifier_code` en `mission_instances` | P0 | SQL |
| MM-02 | `claimReward` respeta `reward_multiplier` | P0 | Código |
| MM-03 | Repo: `applyMissionModifier(instanceId, itemCode)` | P1 | Código |
| MM-04 | UI: opciones de modificador al aceptar misión | P1 | Código |
| MM-05 | Seed de items `mission_modifier` en catálogo | P0 | SQL |

---
# Fase 9 — RPG · Decoración y Cosméticos (tarea 34)

## 1. Estado actual (verificado)
- `cosmetic_catalog` con 23 items (title/frame/aura/pet/emote/table_theme).
- `player_inventory` con `is_equipped` (soporta equipar).
- `HunterCatalog.titles` (catálogo de títulos en código) + título equipado persistido (`equipped_title_code`).
- T-501 inventario: equipar/desequipar funcionando.

## 2. Diseño — Personalización completa

| Ámbito | Items | Estado |
|---|---|---|
| **Avatar** | Skins/clases | ⚠️ `skin` en CHECK pero sin items seed |
| **Títulos** | 5 títulos | ✅ funcional (equipar + mostrar) |
| **Marcos** | 3 marcos | ✅ catálogo; equipar en inventario |
| **Mascotas** | 2 mascotas | ✅ catálogo |
| **Efectos/Auras** | 3 auras | ✅ catálogo |
| **Fondos** | `theme` | ⚠️ en CHECK, sin seed |
| **Decoración de Guild** | `guild_decoration` | ⚠️ en CHECK, sin seed (trofeos) |
| **Colecciones** | — | ❌ sin sistema de colección |

### Mejoras propuestas
1. **Seed de skins/fondos/decoración**: añadir 3 skins, 3 fondos, 3 decoraciones de guild al catálogo.
2. **Colecciones**: tabla `player_collections` (collection_id, item_codes[] completados, reward_code) para incentivar completar sets.
3. **Trofeos del guild**: decoraciones obtenibles solo por logros de gremio (misiones colaborativas completadas) — prestigio.

### Regla anti pay-to-win
- Todos los cosméticos son **puramente visuales** (sin stats). Confirmado: `is_equipped` solo afecta la UI.
- Los modificadores de misión (tarea 33) NO son cosméticos; se obtienen por juego/drops, no solo por compra.

## 3. Plan de implementación
| # | Tarea | Prioridad | Nota |
|---|---|---|---|
| DC-01 | Seed de skins/fondos/decoración de guild | P0 | SQL |
| DC-02 | Tabla `player_collections` + lógica de completitud | P1 | SQL + código |
| DC-03 | Trofeos de guild por misiones colaborativas | P1 | Código |
| DC-04 | Mostrar cosméticos equipados en avatar/HUD | P1 | Código |

---
## Resumen Fase 9
- **Tarea 32 (Items)**: análisis completo; base sólida (11 tipos), ampliar con key/book/mission_modifier + metadata + drops.
- **Tarea 33 (Modificadores)**: diseño completo (recompensa x2, facilidad/desafío, ruta secreta) con columnas y balance.
- **Tarea 34 (Cosméticos)**: diseño de personalización + colecciones + trofeos, anti pay-to-win.

**Total de tareas propuestas:** IT-01..05, MM-01..05, DC-01..04 = 14 tareas atómicas.

## Estado de implementación (2026-07-30)

### ✅ Aplicado en DB (script `20260730_phase9_items_modifiers.sql`)
- IT-01: CHECK `item_type` ampliado (key, book, mission_modifier) — verificado.
- IT-02: columnas `item_effect`, `item_meta`, `source` en `player_inventory` — verificado.
- MM-01: columnas `reward_multiplier`, `applied_modifier_code` en `mission_instances` — verificado.
- MM-05 + IT-03 + DC-01: 13 items nuevos en catálogo (4 modificadores, 2 llaves, 3 libros, 2 skins, 2 decoraciones) — verificado.

### ✅ Implementado en código (build OK, tests 13/13)
- MM-02: `claimReward` respeta `reward_multiplier` (multiplica XP/gemas).
- MM-03: `applyMissionModifier` en `mission_repository.dart` — soporta los 4 códigos y consume el item del inventario.

### ⬜ Pendiente
- MM-04: UI de opciones de modificador al aceptar misión.
- IT-04: repo aplica efecto consumible genérico (`item_effect`).
- IT-05: `getInventory` filtra por categoría/source.
- DC-02/03/04: colecciones, trofeos, mostrar equipados.
