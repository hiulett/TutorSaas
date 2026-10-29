# Economía: sumideros y medición (P-32 / #117)

Qué se puede gastar hoy, dónde se gasta y cómo se comprueba que la economía
tiene sumideros reales. Todas las cifras de este documento están verificadas
contra producción (`sipiumfdpvnszthykyog`) el **2026-10-29** con consultas de
solo lectura.

## 1. Monedas que se mantienen (decisión)

| Recurso | Se gana con | Se gasta en | Dónde |
|---|---|---|---|
| **Oro** | `apply_session_rewards` (objetivos × (10 + bonus de nivel)), bolsas de nivel | Cosméticos del catálogo | Tienda → ORO |
| **Gemas** | `claim_mission_reward`, recompensa diaria (5/50/100/300) | Freeze de racha (30, máx. 3) y cosméticos premium | Tienda → GEMAS |
| **Fragmentos** | `apply_session_rewards` (objetivos × (5 + bonus)) | Crafteo de cosméticos (receta del catálogo) | Tienda → FRAGMENTOS |
| **Maná** | Plan + compra (RevenueCat) | Cada acción de IA (`consume_mana`, servidor) | HUD / Santuario |

Reglas:

- **Ninguna moneda compra ventajas de aprendizaje.** El maná de IA se cobra en
  servidor por turno; el oro/gemas/fragmentos solo compran cosméticos, freezes y
  crafteo.
- **El cliente no escribe saldos.** Todo movimiento pasa por
  `economy_apply_currency` (helper interno) a través de `purchase_cosmetic`,
  `craft_cosmetic`, `purchase_streak_freeze`, `spend_currency` o
  `claim_level_rewards`, todas `SECURITY DEFINER`. El trigger
  `guard_language_profile` sigue descartando cualquier `total_gold`,
  `total_gems`, `fragments` o `xp_points` que envíe el cliente.
- **Idempotencia:** `currency_ledger` tiene `unique (user_id, ref_key)`. Repetir
  una compra con la misma referencia devuelve el saldo ya aplicado y **no**
  vuelve a cobrar.

## 2. Estado antes de P-32 (por qué hacía falta)

| Comprobación | Resultado el 2026-10-29 |
|---|---|
| `select count(*) from player_inventory` | **0** — nadie compró nunca un cosmético |
| Oro: `max(total_gold)` / mediana | 160 / 100 (el cosmético más barato costaba 120) |
| Gemas: máximo por usuario | 57 (el cosmético más barato costaba 350) |
| Fragmentos | 483 en 5 perfiles, **sin ningún sumidero** |
| Libro de movimientos de moneda | **no existía** (solo `session_reward_ledger`, ingresos) |
| `spendGold()` del cliente | `UPDATE total_gold` que el trigger descartaba: devolvía `true` sin cobrar |
| `purchaseStreakFreeze()` / `purchaseItem()` | sin ninguna entrada en la UI |

Consecuencia: el gasto era **inmedible** y dos de las tres monedas no tenían
salida.

## 3. Sumideros activos tras P-32

- **ORO** — `cosmetic_catalog.price_gold` (60–1200). Tres objetos nuevos de
  entrada (60/80/90) para que la primera compra sea posible con el saldo inicial
  de 100. Los objetos caros exigen nivel de cazador (`required_level` 2–20).
- **GEMAS** — `purchase_streak_freeze` (30 gemas, tope 3) y los cosméticos con
  `price_gems` (350–2800) vía `purchase_cosmetic(..., 'gems')`.
- **FRAGMENTOS** — `craft_cosmetic` con `craft_cost_fragments`
  (`title_cazador_sombras` 120, `frame_escudo` 250, `aura_fuego` 400).
- **Nivel** — `level_rewards` paga oro al alcanzar los niveles 2, 3, 5, 8, 12 y
  15 (`claim_level_rewards`, idempotente por `level_reward:<nivel>`) y el
  catálogo desbloquea objetos por nivel. La tienda anuncia el próximo
  desbloqueo y las recompensas pendientes.

## 4. Medición: ¿el oro tiene sumidero?

Vista agregada (sin acceso para la app: solo `service_role` / SQL Editor):

```sql
-- Ganado vs gastado por moneda y motivo.
select currency, reason, earned, spent, movements
  from public.v_economy_flow
 order by currency, reason;
```

Ratio de sumidero (1.0 = todo lo ganado se gasta):

```sql
select currency,
       sum(earned) as earned,
       sum(spent)  as spent,
       case when sum(earned) > 0
            then round(sum(spent)::numeric / sum(earned), 3)
            else null end as sink_ratio
  from public.v_economy_flow
 group by currency;
```

Por usuario (para detectar acumulación sin salida):

```sql
select user_id,
       sum(delta) filter (where currency = 'gold' and delta > 0) as gold_in,
       -sum(delta) filter (where currency = 'gold' and delta < 0) as gold_out,
       sum(delta) filter (where currency = 'fragments' and delta > 0) as frag_in,
       -sum(delta) filter (where currency = 'fragments' and delta < 0) as frag_out
  from public.currency_ledger
 group by user_id
 order by gold_in desc;
```

El mismo dato por usuario sale en la app con `get_economy_wallet`
(`earned` / `spent`), así que la UI y el panel miden lo mismo.

Lectura esperada: si `sink_ratio` de `gold` se queda por debajo de ~0.2 con
usuarios activos, el precio de entrada sigue siendo alto; si supera 0.8, el
catálogo se queda corto y toca añadir objetos (nunca bajar precios a mano sin
migración).

## 5. Consultas de verificación puntual

```sql
-- ¿Qué está desbloqueado por nivel y a qué precio?
select required_level, category, count(*), min(price_gold), max(price_gold)
  from public.cosmetic_catalog
 group by required_level, category
 order by required_level;

-- ¿Cuántas recetas de fragmentos hay y a qué coste?
select id, craft_cost_fragments
  from public.cosmetic_catalog
 where craft_cost_fragments > 0
 order by craft_cost_fragments;

-- Freezes comprados (una fila por compra idempotente).
select user_id, count(*) as freezes_bought
  from public.currency_ledger
 where reason = 'streak_freeze'
 group by user_id;
```

## 6. Lo que NO cubre esta historia

- **Ligas semanales** (cohortes de ~30, ascenso/descenso, reinicio semanal) y
  **cofres con probabilidades visibles**: siguen pendientes. El leaderboard
  actual (`LeagueLeaderboardWidget`) no tiene cohortes ni premios.
- **Pergaminos**: `player_pergaminos` y `increment_pergaminos_max` siguen
  existiendo y la recompensa diaria aún los entrega; no se han migrado ni
  eliminado en esta entrega (fuera del alcance mínimo de P-32).
