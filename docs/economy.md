# Economía — Dungeon of English

> Documento maestro de economía. Sincronizado: 2026-07-30 (Fases 6, 8, 9).

## Recursos
| Recurso | Tabla/columna | Uso |
|---|---|---|
| Gemas | `user_language_profiles.total_gems` | Moneda premium (shop, recargas) |
| Oro | `user_language_profiles.total_gold` | Moneda secundaria (gasto futuro) |
| Fragmentos | `user_language_profiles.fragments` | Loot de conversaciones (T-504/505) |
| Invocaciones (energía) | `player_daily_state` | Límite de turnos de IA (T-506) |
| Pergaminos | `player_pergaminos` + `pergaminos_max` | Contenido offline |
| Items | `player_inventory` + `cosmetic_catalog` | Cosmético/modificador/consumible |

## RPCs (verificados en live)
`add_xp`, `add_gems`, `spend_gems`, `add_fragments`, `increment_pergaminos_max`, `rotate_daily_missions`.

## Economía del Guild
- `guild_battle_pass` (T-502) — prestigio, niveles, claim de recompensas.
- `guild_quest_pool` + `guild_collaborative_missions` — recompensas por rachas de gremio.
- Prestigio visible en el Gran Salón (G-G).

## Balance
- Plan gratuito: 30 min/mes audio + energía diaria (15-20 invocaciones) ≈ $0.02-0.05/mes/usuario de costo real.
- Loot escalado por nivel CEFR (T-507): fragmentos/gemas × (1 + bonus nivel).
- Catálogo de precios ajustado (T-507).
- Items mission_modifier: escasos (drops/tienda) → no inflan la economía.

## Tienda e inventario
- `/shop` (Fase 6), `/inventory` (T-501) con equipar/filtrar.
- Battle Pass `/battle-pass` (T-502), Daily Rewards modal (T-503).

## Preparación para monetización
- 4 planes en `subscription_plans` (free/monthly/annual/lifetime) con límites de audio IA.
- MO-A/MO-B aplicados: lifetime 1200min, Battle Pass en monthly.

## Balance 6-12 meses (ECO-04)

### 1. Ingresos (income) de gemas por mes
Usuario activo: 5 sesiones/semana ≈ 20 sesiones/mes.

| Fuente | Gemas/mes | Notas |
|---|---|---|
| Recompensa diaria (claim) | ~200 | 5 gemas/día base + escalado por racha |
| Misiones diarias y de gremio | ~150 | Pool rotativo + colaborativas de gremio |
| Drops/loot | ~100 | Escalado por nivel CEFR (T-507) |
| Battle pass gratuito | ~80 | Track gratuito (T-502) |
| **TOTAL** | **~530** | |

### 2. Gastos (sinks) por mes

| Sink | Gemas/mes | Notas |
|---|---|---|
| Consumible invocación +5 (40 gemas) | ~320 | Usuario casual, 2/semana |
| Tienda rotativa | ~100 | Oferta semanal |
| Streak freeze (30 gemas) | ~30 | Uso ocasional, ~1/mes |
| Entrenamiento con oro | — | NO gasta gemas; oro por separado |
| **TOTAL** | **~450** | |

### 3. Oro (economía secundaria)
- **Ingreso:** ~500 oro/mes (recompensas de raid/sesión).
- **Sinks:** Entrenamiento 100-250 oro → ~400 oro/mes.
- **Neto:** positivo leve (~+100 oro/mes) → permite acumular para el pase.

### 4. Fragmentos
- **Ingreso:** ~200/mes (raids).
- **Sinks (uso ocasional):** Pergamino 50 · Gema 100 · Título épico 300 · Pase 500.

### 5. Tabla resumen 6-12 meses
Neto mensual: +530 − 450 = **~+80 gemas/mes**. El usuario además compra consumibles cuando ve ofertas (no se modela como ingreso base).

| Escenario | Saldo inicial | Neto/mes | Proyección 6 meses | Proyección 12 meses |
|---|---|---|---|---|
| Conservador | 0 | +80 | +480 | +960 |
| Con compras por ofertas | 0 | +80 + ocasional | ~+600 | ~+1.200 |

**Conclusión:** sin inflación crítica. El neto positivo es moderado y los sinks estables; deja margen para que los usuarios premium tengan más sinks (monetización) sin castigar al jugador gratuito.

### 6. Nota de diseño
Si el neto superara **+100 gemas/mes durante 12 meses**, se añadiría un sink cosmético (caja de cosméticos). Estado actual: **balance sano** (+80/mes, muy por debajo del umbral).
