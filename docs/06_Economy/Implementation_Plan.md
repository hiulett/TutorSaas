# Fase 6 — Implementation_Plan

> Plan de implementación (PRIORIZADO). Sin implementación realizada aún — documentación.

## Objetivo

Completar la economía desacoplada de la UI: oro, cristales, núcleos, fragmentos, loot,
inventario, recompensas, tienda, battle pass, daily rewards, integración IA y balance.

## Pasos

### 6.1 Fix de `claimDailyReward` (P0)
1. Corregir el update que asigna una Future a `pergaminos_max`:
   separar el RPC `increment_pergaminos_max` del update del daily state.

### 6.2 Inventario UI (P0)
1. Pantalla de inventario: lista de items, equipar/desequipar (`toggleEquip`).
2. Ruta `/inventory` + acceso desde dashboard.

### 6.3 Battle Pass (P0)
1. Repositorio para `guild_battle_pass` (get/upsert level+xp, claim).
2. Pantalla battle pass + integración con XP ganado.

### 6.4 Daily Rewards UI (P1)
1. Pantalla/modal de daily reward usando `claimDailyReward` + streak visual.

### 6.5 Oro y fragmentos (P1)
1. Definir lógica de gasto de oro (columna `total_gold`).
2. Definir "fragmentos" como recurso (drop de conversaciones) o descartar si no aplica.

### 6.6 Loot/drops (P1)
1. Recompensar items al completar conversaciones/eventos (insert en inventario).

### 6.7 Integración con IA (P1)
1. Conectar `useInvocation`/`canInvoke` con el inicio de conversaciones.
2. `generateDailyPergaminos` → Edge Function con contenido real.

### 6.8 Balance económico (P2)
1. Tabla de balance/curva de precios; ajustar cosmetic_catalog.
2. Simulación de economía.

## Criterios de terminación

- `flutter analyze` 0 errores; `flutter test` verde.
- Tienda, inventario, battle pass y daily rewards navegables.
- Las invocaciones limitan el acceso a IA de forma verificable.
- Economía sin acoplamiento a UI (repositorio + providers).
