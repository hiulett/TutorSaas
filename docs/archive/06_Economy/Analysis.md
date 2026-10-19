# Fase 6 — Analysis

> Análisis del estado actual de la Economía del Juego.

## 1. Monedas y recursos

| Recurso | Representación | Fuente |
|---|---|---|
| Gemas (cristales) | `user_language_profiles.total_gems` | RPC `add_gems`/`spend_gems` |
| Oro | `user_language_profiles.total_gold` (default 100) | Columna existente, **sin lógica de uso aún** |
| Invocaciones (núcleos) | `player_daily_state.invocations_used/max` | límite 20 + bonus por racha |
| Pergaminos | `player_pergaminos` + `pergaminos_used/max` | contenido batch offline |
| Items/loot | `player_inventory` + `cosmetic_catalog` | compra/equip |

## 2. Repositorio (`economy_repository_impl.dart`, 355 líneas)

- **getDailyState**: crea estado diario con `invocations_max = 20 + (streak~/7)*5`.
- **useInvocation / canInvoke**: control de gasto de invocaciones (throw si agotado).
- **getStreak / updateStreak**: racha con lógica diff de días (1→incrementa, 0→igual, >1→reset).
- **claimDailyReward**: gemas escalonadas por racha (5/50/100/300) + pergaminos; usa `add_gems`.
  - ⚠️ Bug: pasa una Future como valor a `pergaminos_max` en el update (`.rpc(...)` dentro del mapa).
- **purchaseItem**: consumibles (invocación+5/+20) vs cosméticos; gasta gemas, inserta inventario.
- **toggleEquip / addGems / spendGems / getGems**.
- **generateDailyPergaminos**: genera 5 pergaminos placeholder (contenido real pendiente de
  Edge Function).

## 3. Providers (`economy_providers.dart`)

5 providers autoDispose: dailyState, streak, gemBalance, canInvoke, inventory.

## 4. UI

- `shop_screen.dart` (301 líneas, `/shop`): tienda de cosméticos.
- `nucleo_arcano_limit_screen.dart`: aviso de núcleo agotado.
- **Faltan**: pantallas de inventario, battle pass, daily rewards UI, gold spending.

## 5. Paridad con requisitos de Fase 6

| Requisito | Estado |
|---|---|
| Oro | ⚠️ columna, sin lógica |
| Cristales (gemas) | ✅ completo |
| Núcleos (invocaciones) | ✅ |
| Fragmentos | ⚠️ no identificado como recurso separado |
| Loot | ⚠️ items solo comprables, sin drops |
| Inventario | ✅ repo + provider; ⚠️ sin pantalla |
| Recompensas | ✅ claimDailyReward |
| Tienda | ✅ `/shop` |
| Battle Pass | ⚠️ tabla `guild_battle_pass`, sin repo/UI |
| Daily Rewards | ✅ claimDailyReward (sin pantalla dedicada) |
| Integración con IA | ⚠️ invocaciones limitan IA; sin wiring con conversation |
| Balance económico | ⚠️ sin simulación/ajuste |
| Desacoplado de UI | ✅ (repo + providers independientes) |

## 6. Conclusión

Economía ~60%. Gaps: bug en `claimDailyReward`, oro sin lógica, battle pass sin acceso,
inventario sin UI, loot/drops, integración IA-conversación, balance.
