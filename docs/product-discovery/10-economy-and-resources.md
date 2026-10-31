# 10 · Economía y recursos

> Medido el 31-oct-2026 contra producción `sipiumfdpvnszthykyog` (solo lectura,
> MCP `supabase`) y contra `origin/master` del worktree `p14-ai-usage`.
> Baseline: [_baseline.md](_baseline.md).
>
> Decisiones ya tomadas: [../PRODUCT.md](../PRODUCT.md) §3 (monedas) y §8 (tope
> diario + turno de gracia); [../PROPUESTA-P44-P48.md](../PROPUESTA-P44-P48.md)
> §P-46 (no abrir consumibles de maná) y §P-47 (margen). Medición de sumideros
> ya documentada en [../runbooks/ECONOMY_SINKS.md](../runbooks/ECONOMY_SINKS.md):
> este documento **no la repite**, la verifica y la conecta con el ciclo
> completo.

---

## 1. Resumen ejecutivo

La economía tiene **cinco recursos** y **un solo recurso escaso de verdad**
(maná). El oro, las gemas y los fragmentos se ganan, existen en los perfiles y
**no tienen un solo movimiento registrado en el libro contable**: el
`currency_ledger` está vacío aunque los saldos han subido. La razón es
estructural: las tres funciones que pagan monedas escriben el saldo
**directamente** y se saltan `economy_apply_currency`, que según P-32 era "el
único punto de escritura".

Y el recurso escaso (maná) **no es escaso en la práctica**: 13 usuarios han
gastado 3.298 de maná en ~100 días. El tope diario de 200 se ha alcanzado
**una vez** en toda la historia del proyecto.

### 1.1 Deriva corregida en esta pasada

Estas afirmaciones de documentación previa ya no son ciertas; este documento
las reemplaza:

| Dónde | Decía | Realidad verificada |
|---|---|---|
| [`../product-audit/06-GAMEPLAY-Y-GAMIFICACION.md:64`](../product-audit/06-GAMEPLAY-Y-GAMIFICACION.md) | "`llm-proxy` no valida maná: un cliente modificado puede consumir IA sin pagar" | `llm-proxy` llama `consume_mana` y responde 402 (`llm-proxy/index.ts:205-236`, `:452`) |
| [`README.md`](README.md) §5 | "Recompensa de sesión: RPC `apply_session_rewards`" | `apply_session_rewards` está **deprecada y sin EXECUTE** para `authenticated`; la vía real es `close_session(uuid)` (`20261029171705_claim_mission_reward_contract.sql:80-81`) |
| [`../PRODUCT.md`](../PRODUCT.md) §3 | "Pociones" como fuente de maná | `mana_items` = **0 filas** y no hay producto consumible (P-46 cerrado) |

---

## 2. Mapa de recursos

| Recurso | Dónde vive | Se gana con | Se gasta en | Sumidero real |
|---|---|---|---|---|
| **Maná** | `user_subscriptions.used_audio_seconds` (¡nombre engañoso!) + `purchased_mana_balance` + `mana_items` | Plan mensual (`renew_mana_cycle`), elixires | Turnos de IA (`consume_mana`, en servidor) | **Sí** — es el único recurso que se agota |
| **Oro** | `user_language_profiles.total_gold` | `close_session`, `claim_session_drop`, `claim_level_rewards` | `purchase_cosmetic` | **Sí** (cosméticos 60–1.200) |
| **Gemas** | `user_language_profiles.total_gems` | `claim_mission_reward`, recompensa diaria (rota, §6.5) | `purchase_streak_freeze` (30), cosméticos | **Sí** |
| **Fragmentos** | `user_language_profiles.fragments` | `close_session` | `craft_cosmetic` (120/250/400) | **Sí** |
| **XP** | `user_language_profiles.xp_points` + `aura_xp` | `close_session`, `claim_session_drop`, `claim_mission_reward`, `add_aura_xp` | — (no se gasta) | N/A |

`[PENDIENTE DE VALIDAR]` `mana_potions` (7 filas) y `mana_gems` (8 filas):
existen y no las lee ninguna función actual; son legado de la etapa "maná
comprado" que P-46 decidió no reabrir.

---

## 3. Maná

### 3.1 Costes por acción (`ai_action_costs`, 7 filas)

| `action_code` | Coste | `is_active` | Nota |
|---|---|---|---|
| `free_chat_turn` | **8** | sí | Turno de conversación libre |
| `dungeon_turn` | **12** | sí | Turno dentro de una mazmorra |
| `oracle_turn` | **15** | sí | Turno con el Oráculo |
| `oracle_eval` | **30** | sí | Examen oral (primera evaluación gratis) |
| `lesson_generation` | **100** | sí | Lección de refuerzo (se reembolsa si falla) |
| `vocabulary_curation` | **2** | sí | Extracción de hasta 8 palabras al cerrar |
| `correction_turn` | 3 | **no** | Gratuita desde P-40-c (#222) |

El cobro es **server-side**: `llm-proxy` llama `consume_mana` antes de invocar
al modelo y responde 402 si no hay saldo (`llm-proxy/index.ts:205-236`,
`:452`). Un cliente modificado **no** puede saltarse el cobro (esto corrige lo
que decía `docs/product-audit/06-GAMEPLAY-Y-GAMIFICACION.md:64`, ya
desactualizado).

### 3.2 Orden de descuento (`consume_mana`)

```
1. valida auth.uid() = p_user_id
2. valida que la acción exista y esté activa  (si no → invalid_action)
3. garantiza fila en user_subscriptions       (si no existía, el débito se perdía — bug corregido en 20260819)
4. reset diario lazy (si daily_reset_date < CURRENT_DATE)
5. si mana_expires_at < now() → allowance = 0
6. si plan = 'plebeyo' y daily_used + coste > daily_limit → daily_limit_reached
7. descuenta del saldo del plan (used_audio_seconds += coste)
8. si no alcanza → intenta el ítem equipado (mana_items)
9. si no hay ítem → insufficient_mana
```

Evidencia: `supabase/migrations/20260819_fix_mana_consume.sql:32-152`.

### 3.3 El "tope diario" que casi nunca aplica

| Dato | Valor |
|---|---|
| `subscription_plans.mana_allowance` PLEBEYO | 3.000/mes |
| `user_subscriptions.daily_limit` (PLEBEYO) | 200 |
| 3.000 ÷ 30 días | **100/día de media** |
| Días que aguantaría gastando 200/día | **15** |

Es decir: **el tope de 200 solo muerde si el usuario juega 15 días o menos al
mes**. Si juega a diario, el límite que lo frena es el **saldo mensual**
(≈100/día), no el tope diario. La decisión de P-26 ("se mantiene el tope de 200
≈ 16 turnos de mazmorra") se justifica por la *sensación* de corte, no porque
sea el factor limitante real.

### 3.4 Turno de gracia

- `claim_mana_grace(p_user_id)` es idempotente por día (`mana_grace_date`) y
  **solo `service_role`** puede ejecutarla
  (`20261029080000_mana_grace_turn.sql:20-45`).
- La invoca `llm-proxy` únicamente cuando `consume_mana` devuelve
  `daily_limit_reached` (`llm-proxy/index.ts:452`). No aplica al saldo mensual
  agotado. `[IMPLEMENTADO]`
- Efecto medible: **1 fila** con `daily_used >= 200` en toda la BD. El turno de
  gracia se ha podido usar una vez.

### 3.5 Maná comprado (P-46: cerrado)

- `purchased_mana_balance` existe y `consume_mana` lo suma al saldo del plan
  (`v_remaining = (allowance + purchased) − used`).
- `mana_items` (elixires equipables) tiene **0 filas**: nadie ha comprado nunca
  un elixir.
- La tienda **no** tiene tab de MANÁ (`shop_screen.dart:20-29`); el CTA "obtener
  maná" del Santuario abre `/paywall` (`dungeon_guardian_screen.dart:207-211`).
- `[IMPLEMENTADO]` = el hueco técnico está; `[PENDIENTE DE VALIDAR]` = decidir
  si algún día se abre un consumible (P-46 recomienda no hacerlo).

---

## 4. Oro, gemas y fragmentos

### 4.1 El libro contable (`currency_ledger`)

Diseñado en P-32 como **único punto de escritura**, idempotente por
`unique (user_id, ref_key)`:

```sql
create table public.currency_ledger (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  language_id integer not null default 1,
  currency text not null check (currency in ('gold','gems','fragments')),
  delta integer not null check (delta <> 0),
  reason text not null,
  ref_key text not null,
  balance_after integer not null check (balance_after >= 0),
  created_at timestamptz not null default now(),
  unique (user_id, ref_key)
);
```

Evidencia: `20261029215518_economy_purpose_p32.sql:90-116`.

`economy_apply_currency(user, currency, delta, reason, ref_key)` es la función
que mueve el saldo y escribe la fila (`:169-248`). Todo lo demás debería
llamarla.

**Estado real: `currency_ledger` = 0 filas.** Y `v_economy_flow` (la vista que
calcula ganado/gastado) = 0 filas. El `sink_ratio` que
[ECONOMY_SINKS.md](../runbooks/ECONOMY_SINKS.md) §4 propone medir **hoy es
incalculable**.

### 4.2 Quién escribe saldos sin pasar por el libro `[PARCIAL]`

| Función | Escribe | ¿Usa `economy_apply_currency`? |
|---|---|---|
| `purchase_cosmetic` | `total_gold` / `total_gems` | **Sí** (`:395-397` de la migración P-44) |
| `craft_cosmetic` | `fragments` | **Sí** |
| `purchase_streak_freeze` | `total_gems` | **Sí** |
| `spend_currency` | cualquiera | **Sí** (delega) |
| `claim_level_rewards` | `total_gold` | **Sí** (ref `level_reward:<n>`) |
| **`close_session`** | `xp_points`, `total_gold`, `fragments` | **No** — `UPDATE` directo (`20261029041017_close_session_server_rewards.sql:92-96`) |
| **`claim_session_drop`** | `xp_points`, `total_gold` | **No** — `UPDATE` directo (`20261026094912_session_drops.sql:94-97`) |
| **`claim_mission_reward`** | `xp_points`, `total_gems` | **No** — `UPDATE` directo (`20261029171705_claim_mission_reward_contract.sql:62-65`) |

Es decir: **todos los ingresos** de oro/gemas/fragmentos evitan el libro, y
solo los gastos lo usan. Por eso el libro está vacío con saldos > 0.

Prueba numérica: `session_reward_ledger` ha pagado **70 de oro y 35 de
fragmentos** en sus 4 filas, y el saldo máximo de oro en los perfiles es
**180** (media 103). Ese oro extra **no tiene traza contable**: no se sabe si
vino de `claim_level_rewards`, de `add_gold` (solo `service_role`) o de una
semilla.

### 4.3 Catálogo y precios (40 ítems)

| Categoría | Nº | Precio oro | Precio gemas | Nivel requerido |
|---|---|---|---|---|
| `aura` | 3 | 300–1.100 | 750–2.300 | 3–18 |
| `emote` | 2 | 60–120 | 0–350 | 1 |
| `frame` | 3 | 90–… | — | 1–12 |
| `title` | 4 | 80–… | — | 1–10 |
| `pet` | 2 | — | — | 6–15 |
| `theme` | 3 | — | 900 | 8–20 |
| `consumable` (legado: libros, llaves, modificadores, skins) | 23 | **0** | 40–1.600 | 1 |

Rangos reales usados en la práctica:

- **Oro**: el ítem más barato cuesta **60** (`emote_saludo_gremio`) y el saldo
  inicial del perfil es ~100. La primera compra es posible desde el día 1 (esto
  ya lo arregló P-32).
- **Gemas**: el más barato cuesta **40** (`consumible_invocacion5`); el freeze
  de racha, **30**.
- **Fragmentos**: recetas de **120**, **250** y **400**.

### 4.4 Nivel de cazador

`economy_level(xp) = 1 + xp/1000` (`:157-163`), espejo exacto de
`HunterLevel.levelFor` en Dart. Con `xp = 3.263` (el máximo de producción) el
nivel es **4**.

`level_rewards` premia los niveles 2, 3, 5, 8, 12 y 15 con bolsas de 100 a 800
de oro (`:141-154`). Total si se reclaman todos: **2.300 de oro**, y exige
**14.000 de XP** para el nivel 15. Hoy el jugador top (3.263 XP) puede reclamar
**2 y 3 → 250 de oro**.

---

## 5. XP

Dos monedas de progreso distintas y desacopladas:

| Moneda | Fuente | Escala | Qué desbloquea |
|---|---|---|---|
| `xp_points` | `close_session` (minutos × 10), `claim_session_drop` (15 × rareza), `claim_mission_reward` (50–400 × multiplicador) | Nivel = `1 + xp/1000` | Nivel de cazador, cosméticos por `required_level`, `level_rewards` |
| `aura_xp` | `add_aura_xp` (radar + metas + bonus de nivel; sin techo) | 0 → 260.000 | Escalones de prestigio 1–21 (con techo de plan) |

El diseño es sano (XP mide "cuánto", aura mide "qué tan bien"), pero el
apalancamiento está roto: **una sola sesión puede dar 2.400 de XP** por el bug
de §6.1, mientras las misiones (que deberían ser el motor) dan 50–400 y solo
se han completado **8 de 637**.

---

## 6. Recompensas

### 6.1 `close_session` — la vía canónica `[PARCIAL]`

Fórmulas (`20261029041017_close_session_server_rewards.sql:57-90`):

```
objectives = least(12, count(user_scenario_goals completadas))   -- las pone el cliente por turno
minutes    = greatest(0, least(240, ceil((coalesce(ended_at, now()) − started_at)/60)))

xp        = minutes * 10              (0 si objectives = 0)
gold      = objectives * (10 + bonus)  bonus: A2=1, B1=2, B2=3, C1=4, C2=5
fragments = objectives * (5 + bonus)
```

**Defecto grave**: `conversations.ended_at` **nunca se escribe**.

```sql
select count(*) total, count(ended_at) con_fin from public.conversations;
-- 70 | 0
```

Ni una sola línea de Dart escribe `ended_at`. Por tanto `minutes` = *tiempo
desde que se creó la fila de conversación*, no tiempo practicado, **clampado a
240**. Si la conversación se creó hace 5 horas, la sesión vale 240 minutos y
**2.400 de XP**.

Caso real (el único usuario NOBLE, `46bd5746`):

| `session_id` | `started_at` | `objectives` | `minutes` | `xp` |
|---|---|---|---|---|
| `d4435ae6-…` | 30-oct 20:21 | 1 | **240** | **2.400** |
| `84b47423-…` | 30-oct 00:09 | 0 | **240** | 0 |
| `c182bb1b-…` | 24-oct 13:20 | 4 | 7 | 70 |
| `7c90f3d2-…` | — | 2 | 4 | 40 |

Resultado: ese usuario tiene **3.263 XP**, de los que **2.400 (73,5 %)** salen
de una sola sesión con **un** objetivo. El segundo jugador del ranking tiene
**255**. La brecha 12,8× del leaderboard es un artefacto del bug, no mérito.

### 6.2 `claim_session_drop` — drop de fin de sesión `[IMPLEMENTADO]`

- Idempotente por `unique (user_id, session_id)`.
- Sin objetivos → `reason='no_goals'` (anti-farmeo).
- Probabilidades: **legendario 2 %**, épico 8 %, raro 25 %, común 65 %.
- Importes: `xp = round(15 × mult)` (3,0 / 2,0 / 1,5 / 1,0) y
  `gold = round(10 × mult)`.

Evidencia: `20261026094912_session_drops.sql:32-119`.

En producción: **1 fila** en `session_drops`.

### 6.3 `claim_mission_reward` — misiones `[IMPLEMENTADO]`

- Solo misiones `status='completed'`; idempotente por `is_reward_claimed`.
- Paga `xp_reward × reward_multiplier` y `gem_reward × reward_multiplier`,
  escribe en `reward_history`.
- Contrato normalizado `{success, ok (legacy), already_claimed, xp, gems, reason}`.

Evidencia: `20261029171705_claim_mission_reward_contract.sql:13-74`.

En producción: 637 instancias, **8 completadas (1,26 %)** y **8 reclamadas**
(100 % de las completadas). Las 629 restantes siguen `active` con
`expires_at = NULL`: **las misiones nunca caducan** (D6 en §9).

### 6.4 `claim_level_rewards` — bolsas por nivel `[IMPLEMENTADO]`

Idempotente por `ref_key = 'level_reward:<nivel>'`. No otorga objetos: el
desbloqueo por nivel ya lo hace `cosmetic_catalog.required_level`.

### 6.5 Recompensa diaria — **rota** `[PARCIAL → roto]`

`claimDailyReward` (`economy_repository_impl.dart:196-245`) hace todo en el
cliente:

```dart
await _client.rpc('add_gems', {...});                    // línea 221-224
await _client.rpc('increment_pergaminos_max', {...});     // línea 226-229
await _client.from('player_daily_state')
      .update({'daily_reward_claimed': true})             // línea 231-235
```

`add_gems` tiene EXECUTE **solo para `postgres` y `service_role`**
(`information_schema.routine_privileges`). El usuario `authenticated` recibe
*permission denied* → la excepción salta al `catch (_)` de la línea 242 →
`return const {}`. Consecuencias:

1. No se acreditan gemas **nunca**.
2. El `catch` vacío oculta el motivo real (incumple la regla del repo de
   `debugPrint` con el mensaje).
3. Como el fallo ocurre antes del `update`, la recompensa tampoco se marca
   como reclamada: el botón queda en un bucle "pulsa y no pasa nada".
4. `increment_pergaminos_max` **sí** es ejecutable por `authenticated`: si el
   orden se invirtiera, el usuario podría auto-otorgarse pergaminos.

Contraste con los datos: `player_daily_state.daily_reward_claimed = true` en
**4 de 79** filas — restos de cuando la RPC estaba abierta o de la semilla.

Un dato más: la recompensa escala con la **racha** (5/50/100/300 gemas a los
0/7/14/30 días). La racha máxima histórica de la app es **3**
(`max(longest_streak) = 3`). El escalón de 50 gemas **nunca se ha alcanzado**.

### 6.6 Compensaciones (`refund_*`) `[IMPLEMENTADO]`

| RPC | Quién | Idempotencia | Comportamiento |
|---|---|---|---|
| `refund_failed_turn(turn_ref, action_code)` | cliente (`authenticated`) | por `mana_transactions.ref_id = turn_ref` | Devuelve el coste si hubo un débito de esa acción en los **últimos 5 minutos** |
| `refund_mana(user, action_code)` | **solo `service_role`** (lo usa `llm-proxy`) | **ninguna** (no escribe `ref_id`) | Devuelve el coste sin verificar |

Ambas devuelven el contrato normalizado
`{success, refunded, already_refunded, reason}` con
`reason ∈ {invalid_turn, invalid_action, no_recent_charge}`
(`20261029155748_refund_contract_normalized.sql:19-137`).

En producción: **4 reembolsos** de `lesson_generation` (400 de maná devueltos
de 400 cobrados: 100 % de las generaciones fallaron y se compensaron). Ningún
reembolso de `dungeon_turn` pese a 181 turnos.

---

## 7. Ciclo completo

```mermaid
flowchart TD
    subgraph Membresía
        P[Play Billing] --> RC[RevenueCat<br/>entitlement Pro]
        RC --> SE[sync_entitlement]
        SE --> US[(user_subscriptions<br/>plan_id + period_end)]
        SE --> RM[renew_mana_cycle<br/>used=0 · mana 'renew']
    end

    subgraph Maná
        US -->|allowance del plan| MS[get_mana_state → HUD]
        US --> CM{consume_mana}
        AI[llm-proxy] --> CM
        CM -->|ok| TURN[Turno de IA]
        CM -->|daily_limit_reached| GRACE[claim_mana_grace<br/>1 por día, solo service_role]
        GRACE --> TURN
        CM -->|insufficient_mana| SANT[/dungeon-guardian → paywall/]
        TURN -->|falla| REF[refund_failed_turn<br/>5 min de ventana]
        REF --> CM
    end

    subgraph Misión
        AI --> GOALS[user_scenario_goals]
        GOALS --> MSG[messages] --> TRG[on_message_advance_missions]
        TRG --> MI[(mission_instances)]
        MI -->|completed| CMR[claim_mission_reward]
    end

    subgraph Cierre de sesión
        CS[close_session] -->|objectives × (10+bonus)| GOLD[(total_gold)]
        CS -->|objectives × (5+bonus)| FRAG[(fragments)]
        CS -->|minutes × 10| XP[(xp_points)]
        CS --> SR[(session_reward_ledger<br/>idempotente)]
        CS --> TRG2[on_session_reward_advance_missions]
        DROP[claim_session_drop<br/>15×mult XP · 10×mult oro] --> XP
        DROP --> GOLD
        CMR -->|xp × mult| XP
        CMR -->|gem × mult| GEMS[(total_gems)]
        AURA[add_aura_xp] --> AXP[(aura_xp)]
    end

    subgraph Gasto
        GOLD --> PC[purchase_cosmetic] --> INV[player_inventory]
        GEMS --> PSF[purchase_streak_freeze<br/>30 gemas · tope 3]
        GEMS --> PC
        FRAG --> CC[craft_cosmetic] --> INV
        CLR[claim_level_rewards] --> GOLD
        XP --> LVL[nivel = 1 + xp/1000]
        LVL -->|required_level| PC
        LVL --> CLR
        AXP --> PRES[compute_prestige_title<br/>techo por class_name]
    end

    LEDGER[(currency_ledger)]:::ledger
    PC -.-> LEDGER
    CC -.-> LEDGER
    PSF -.-> LEDGER
    CLR -.-> LEDGER
    CS -. ✗ .-> LEDGER
    DROP -. ✗ .-> LEDGER
    CMR -. ✗ .-> LEDGER

    classDef ledger fill:#552,stroke:#fa0,stroke-width:2px
```

Las flechas punteadas discontinuas marcan **ingresos que no escriben en el
libro**: por eso el `sink_ratio` no se puede calcular.

---

## 8. Equilibrio gratis vs. pago, con cifras

### 8.1 Cuántos turnos compra cada plan

| Plan | Maná/mes | Mazmorra (12) | Chat libre (8) | Oráculo (15) | Evaluación (30) | Lección (100) |
|---|---|---|---|---|---|---|
| PLEBEYO | 3.000 | **250** | 375 | 200 | 100 | 30 |
| NOBLE | 17.000 | **1.416** | 2.125 | 1.133 | 566 | 170 |
| REALEZA | 20.500 | **1.708** | 2.562 | 1.366 | 683 | 205 |
| _Tope diario PLEBEYO (200)_ | — | _16/día_ | _25/día_ | _13/día_ | _6/día_ | _2/día_ |

### 8.2 Precio por unidad

| Plan | $/mes | $ por 1.000 de maná | Δ vs. plan anterior |
|---|---|---|---|
| PLEBEYO | $0.00 | — | — |
| NOBLE | $4.99 | **$0.294** | — |
| REALEZA | $9.99 | **$0.487** | +3.500 de maná por **+$5.00** → **$1.429/1.000 = 4,9× peor** |
| DIVINO (retirado) | $12.99 | $0.509 | aún peor |

**El tramo REALEZA es 4,9 veces más caro por unidad de maná que NOBLE.** Con
maná como único argumento, el usuario racional compra NOBLE (P-44 ya lo
diagnosticó; la corrección aplicada fue "diferenciar por capacidad", y de eso
solo hay 52 semanas de historial + 2 cosméticos + 8 escalones de prestigio).

### 8.3 Coste real y margen

Con el coste medido en P-47 (muestra de 8 llamadas):

| Escenario | Cálculo | Coste IA | Margen bruto sobre $4.99 |
|---|---|---|---|
| NOBLE uso típico (todo mazmorra) | 1.416 × $0.00002 | **$0.03** | 99,4 % |
| NOBLE peor caso (todo `oracle_eval`) | 566 × $0.0008 | **$0.45** | 90,9 % |
| REALEZA peor caso | 683 × $0.0008 | **$0.55** | 94,5 % |

Tras la comisión de Play (15 %): NOBLE peor caso ≈ **$0.75** de comisión +
**$0.45** de IA sobre $4.99 → margen ≈ **76 %** (cifra de P-47).

**El maná no es un recurso caro.** Un turno de mazmorra cuesta $0.00002: los
12 de maná que cobra la app equivalen a **$0.00024 de valor percibido frente a
$0.00002 de coste real** (12× de margen en la unidad, 20.000× si se compara
contra el precio del maná de REALEZA). El maná es una **palanca de ritmo**, no
un coste.

### 8.4 El equilibrio real (y por qué es irrelevante hoy)

| Dato de producción | Valor |
|---|---|
| Usuarios que han gastado maná | **13** de 68 |
| Maná total consumido en ~100 días | **3.298** |
| Consumo medio por usuario que usa IA | **253** |
| Consumo medio diario por usuario activo | **≈ 2,5 de maná/día** (0,2 turnos de mazmorra) |
| Tope diario | 200 → **80× el consumo medio** |
| Maná mensual de PLEBEYO | 3.000 → **≈3,2 años** al ritmo medio de un usuario que usa IA |
| Veces que se alcanzó el tope diario | **1** |
| Saldo máximo de oro / gemas / fragmentos | 180 / 96 / 398 |
| `player_inventory` | **0** — nadie ha comprado un cosmético |

Conclusión: **el equilibrio gratis/pago no se puede calibrar con estos datos**
porque nadie ha llegado a los límites. El problema no es que el plan gratuito
sea generoso: es que el uso es 80× menor que el tope.

### 8.5 Tiempo de práctica que representan esas cifras

Si un turno de conversación ≈ 20–30 s de habla del usuario:

| Plan | 250 turnos (PLEBEYO) | 1.416 turnos (NOBLE) |
|---|---|---|
| Tiempo hablado estimado | 1,4–2,1 h/mes | 7,9–11,8 h/mes |
| Media diaria | 2,8–4,2 min | 16–24 min |

El plan gratuito da, en el mejor caso, **menos de 5 minutos de habla al día**.
La meta diaria por defecto es **15 minutos** (`user_settings.daily_goal_minutes`
= 15 en 68 de 68 perfiles). **El plan gratuito no permite cumplir la meta
diaria que la app pide por defecto**: 15 min ≈ 36 turnos de ~25 s = **432 de
maná/día**, es decir **≈13.000 al mes** (4,3× el plan gratuito), y el saldo se
agotaría en la primera semana.

Esa es, probablemente, la incoherencia de diseño más cara del producto: *la
meta por defecto es inalcanzable con el plan por defecto*.

---

## 9. Desequilibrios medidos

| # | Desequilibrio | Cifra |
|---|---|---|
| D1 | XP derivado de `now() − started_at` con `ended_at` siempre nulo | **0 de 70** conversaciones tienen `ended_at`; **2.400 XP** (73,5 % del XP del jugador top) salen de una sesión de 1 objetivo |
| D2 | El libro contable está vacío porque los ingresos lo evitan | `currency_ledger` **0 filas**; `v_economy_flow` **0 filas**; 70 de oro y 35 de fragmentos pagados sin traza |
| D3 | El tramo REALEZA es 4,9× más caro por unidad de maná | $0.294/1.000 (NOBLE) vs $0.487/1.000 (REALEZA) = **$1.429/1.000** marginal |
| D4 | La meta diaria por defecto (15 min) es inalcanzable con PLEBEYO | 250 turnos/mes ≈ **2,8–4,2 min/día** de habla; 15 min/día ≈ 36 turnos × 12 = **432 de maná/día** = **≈13.000/mes** (4,3× el plan gratuito) |
| D5 | La recompensa diaria no paga (y falla en silencio) | `add_gems` sin EXECUTE para `authenticated`; **4 de 79** filas marcadas como reclamadas y **0** gemas acreditadas |
| D6 | Las misiones nunca caducan | **629** instancias `active` con `expires_at = NULL`; **8 de 637** completadas (1,26 %) |
| D7 | El tope diario de 200 no es el factor limitante | 3.000/mes ÷ 30 = **100/día**; el tope de 200 solo muerde **15 días o menos al mes** |
| D8 | El 100 % de las lecciones de refuerzo generadas fallaron y se reembolsaron | `lesson_generation` **4 acciones / 4 reembolsos** (400 de maná devueltos de 400) |

---

## 10. No verificable

| Dato | Por qué | Qué falta |
|---|---|---|
| Coste real de IA por acción | La muestra de P-47 son **8 llamadas**; `ai_usage_logs` tiene 54 filas con `cost_estimate_usd` | Recalcular con ≥ 2 semanas de uso (`ai_cost_by_session`) |
| Si el ingreso del único NOBLE se registró en algún lado | `payments` = 0, `revenuecat_events` = 1 | Logs de `revenuecat-webhook` en la ventana de compra |
| Origen del oro de los perfiles (máx. 180) | No hay traza contable (D2) | Reparar el libro y volver a medir |
| Si `lesson_generation` falla por el modelo o por la BD | Los 4 reembolsos no distinguen causa | Logs de `lesson-generator` |
| Precio real de los consumibles de Play | No hay consumibles publicados (P-46) | Play Console |
| Efecto del turno de gracia en retención | Se ha usado como máximo 1 vez | Más uso real |
