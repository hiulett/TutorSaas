# Fase 9 — RPG · Change_Log

> Registro de cambios de la Fase 9 (Experiencia RPG).

## 2026-07-30

### Documentación
- `docs/09_RPG/Items_System.md` (tarea 32), `docs/09_RPG/Analysis.md` (tareas 33-34 + estado).

### DB (aplicada por el usuario vía SQL Editor)
- Script `20260730_phase9_items_modifiers.sql`:
  - CHECK `player_inventory.item_type` ampliado: +`key`, +`book`, +`mission_modifier`.
  - Columnas `player_inventory`: `item_effect` (JSONB), `item_meta` (JSONB), `source`.
  - Columnas `mission_instances`: `reward_multiplier` (INTEGER DEFAULT 1), `applied_modifier_code` (VARCHAR).
  - Seed: 13 items nuevos (4 mission_modifier, 2 llaves, 3 libros, 2 skins, 2 decoraciones de guild).

### Código (implementado)
- **MM-02**: `claimReward` en `mission_repository.dart` multiplica XP/gemas por `reward_multiplier`.
- **MM-03**: `applyMissionModifier({userId, instanceId, itemCode})` en `mission_repository.dart`:
  - `mod_recompensa_x2` → `reward_multiplier=2`
  - `mod_piedra_facilidad` → `target_value = ceil(target*0.5)`
  - `mod_piedra_desafio` → `target_value = ceil(target*1.5)` + `reward_multiplier=2`
  - `mod_llave_ruta_secreta` → crea misión secreta
  - Consume el item del inventario al aplicarse.

### Verificación
- `flutter analyze`: 0 errores (64 infos/warnings) · `flutter test`: 13/13 · build apk OK.

### Pendiente
- MM-04 (UI de modificadores), IT-04 (efecto consumible genérico), IT-05 (filtros inventario), DC-02/03/04 (colecciones/trofeos/equipados).
