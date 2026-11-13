# 24 — Facturación de maná: por qué el 38,6 % del gasto de IA se cobra a 0

> **P0-3 / [#271](https://github.com/hiulett/TutorSaas/issues/271).**
> Datos leídos de producción (`sipiumfdpvnszthykyog`) el **31-oct-2026**, solo
> lectura. Ningún cambio aplicado: este documento es una **propuesta** que espera
> decisión de Isaac.
>
> Etiquetas usadas: `[HECHO]` = verificado contra código o consulta reproducible ·
> `[INFERENCIA]` = deducción razonable sin prueba directa · `[PROPUESTA]` = no
> aplicado · `[NO VERIFICABLE]` = falta evidencia o acceso.

---

## 0. Resumen ejecutivo

| Pregunta | Respuesta |
|---|---|
| ¿Cuánto del gasto de IA se cobra a 0 de maná? | **38,60 %** ($0,005813 de $0,015060) — `[HECHO]` |
| ¿Es un fallo? | **No en su mayor parte**: es `FREE_ACTIONS` del proxy. Solo **0,15 %** ($0,000022) es una llamada de pago no cobrada. |
| % recalculado sumando el fallo | **38,75 % ≈ 38,7 %** (coincide con la cifra previa, que venía redondeada) |
| `MANA_CHARGE_MODE` desplegado | **No existe como secreto** → el proxy corre con el valor por defecto del código: **`capability`** `[HECHO]` |
| Maná realmente cobrado en la muestra | **348 maná** por **$0,015060** de gasto estimado → **$0,0000433/maná** (todo) · **$0,0000266/maná** (solo acciones de pago) |
| Muestra | **54 filas**, **6 usuarios**, **3 días** (29-oct 05:05 → 31-oct 01:26 UTC). **83,1 % del gasto es un solo usuario** (`46bd5746`) |
| No verificable | Precios reales del proveedor (el coste es **estimado**), valor histórico del modo, y por qué 4 usuarios consumieron maná **sin fila** en el libro |

**Las tres acciones con mayor desfase** (gasto de IA sin maná cobrado):

1. `goal_eval` — $0,004243 (**28,2 %** del gasto total), 0 maná. Gratis por diseño.
2. `stt_transcribe` — $0,000769 (**5,1 %**), 0 maná. Gratis por diseño.
3. `carisma_eval` — $0,000635 (**4,2 %**), 0 maná. Gratis por diseño.

Por coste **por llamada** el orden cambia: `goal_eval` $0,000707 · `carisma_eval`
$0,000212 · `guild_chat` $0,000166 · `stt_transcribe` $0,000048.

> **Lectura de fondo `[INFERENCIA]`.** El maná no es dinero: es un **limitador de
> ritmo**. Cobrar 0 por `goal_eval` no pierde ingresos (nadie compra maná: `purchased_mana_balance`
> = 0 en las 15 suscripciones), pero **rompe la atribución de coste**: 28 % del
> gasto de IA no tiene contrapartida en el presupuesto del jugador. Arreglar el
> 38,6 % sin arreglar la dispersión interna (ver §3.3) mueve el problema, no lo
> resuelve.

---

## 1. Causa del 38,6 %: qué acciones se cobran a 0 y por qué

### 1.1 Mezcla del gasto medido `[HECHO]`

`ai_usage_logs` contiene **toda** la historia del registro P-14 (54 filas, desde
el 29-oct). Agrupado por acción:

| Acción | Maná (`ai_action_costs`) | Llamadas | Coste estimado | % del gasto | ¿Cobrada? |
|---|---:|---:|---:|---:|---|
| `goal_eval` | **0** (`FREE_ACTIONS`) | 6 | $0,004243 | 28,17 % | **no** |
| `oracle_turn` | 15 | 8 | $0,002717 | 18,04 % | sí |
| `dungeon_turn` | 12 | 13 (12 ok + 1 `no_mana`) | $0,002522 | 16,75 % | 11 de 12 |
| `oracle_eval` | 30 | 3 | $0,002436 | 16,18 % | sí (saldo) |
| `vocabulary_curation` | 2 | 3 | $0,001550 | 10,29 % | sí |
| `stt_transcribe` | **0** (`FREE_ACTIONS`) | 16 | $0,000769 | 5,11 % | **no** |
| `carisma_eval` | **0** (`FREE_ACTIONS`) | 3 | $0,000635 | 4,22 % | **no** |
| `guild_chat` | **0** (`FREE_ACTIONS`) | 1 | $0,000166 | 1,10 % | **no** |
| `free_chat_turn` | 8 | 1 | $0,000022 | 0,15 % | **no** ← fallo |
| `lesson_generation` | 100 | 0 | — | — | — |
| `correction_turn` | 3 (**inactiva**) | 0 | — | — | — |

Suma: **$0,015060**. Gratis por diseño: $0,004243 + $0,000769 + $0,000635 +
$0,000166 = **$0,005813 = 38,60 %**.

### 1.2 Por qué: dos motivos distintos que conviene no mezclar

**(a) Gratis por diseño — 38,60 %.** El proxy decide con dos listas
(`supabase/functions/llm-proxy/index.ts:436-441`):

```ts
const isFree = FREE_ACTIONS.has(actionCode);
const isPaid = !isFree && paidActions.has(actionCode);
```

`FREE_ACTIONS` (`supabase/functions/llm-proxy/validation.ts:23-29`):

| Acción | Maná en `ai_action_costs` | Motivo declarado en el código | ¿Sostenible? |
|---|---:|---|---|
| `stt_transcribe` | (no tiene fila) | es el **input** de un turno que ya se cobra | Sí: cobrarlo sería facturar dos veces la misma interacción |
| `guild_chat` | (no tiene fila) | chat de gremio, coste social | Decisión de producto |
| `goal_eval` | (no tiene fila) | evaluación **interna** de metas por sesión | **Discutible: es el 28 % del gasto** |
| `carisma_eval` | (no tiene fila) | evaluación interna al cerrar sesión | Discutible |
| `correction_turn` | 3, `is_active = false` | P-40-c: sin ella el alumno sin maná no genera correcciones | Sí (filas inactiva + lista) |

Ninguna de estas cinco acciones tiene fila en `ai_action_costs` (salvo
`correction_turn`, inactiva). El proxy las acepta **solo** por la allow-list
`FREE_ACTIONS`; no es que su coste sea 0 por error de configuración: **no se
consultó nunca la tabla**.

**(b) No cobrada por hueco de cliente — 0,15 %.** `free_chat_turn` es una acción
de pago (8 maná, fila activa). Hay **1 llamada** y **0 maná** cobrado:

- `ai_usage_logs`: 1 fila, usuario `8e0105eb`, 29-oct 14:34, `$0,000022`.
- `mana_transactions`: **0 filas** para ese usuario.
- `user_subscriptions`: **no existe fila** para ese usuario.

Como `consume_mana` **siempre** inserta una fila en el libro al cobrar
(`20260819_fix_mana_consume.sql:105`) y además garantiza la fila de suscripción
(`:46-50`), la ausencia de ambas prueba que **la RPC no se llamó**: o el cliente
no declaró `server_mana` (modo `capability`) o la llamada llegó por otro camino.
`[HECHO]` que no se cobró; `[NO VERIFICABLE]` desde qué build salió.

### 1.3 Anomalía del libro de maná (importante para medir) `[HECHO]`

Cuatro usuarios **consumieron saldo** pero **no tienen ninguna fila** en
`mana_transactions`:

| Usuario | `used_audio_seconds` | `daily_used` | Filas en libro | Consumo que lo explica |
|---|---:|---:|---:|---|
| `80577ca5` | 60 | 60 | **0** | 2 × `oracle_eval` (30) |
| `86de8ad8` | 30 | 30 | **0** | 1 × `oracle_eval` (30) |
| `995578c4` | 24 | 24 | **0** | 2 × `dungeon_turn` (12) |
| `3a8aa483` | 12 | 200 | **0** | 1 × `dungeon_turn` (12); el otro turno fue **gracia** |

Los otros 11 usuarios con saldo consumido **cuadran exactamente** con su libro
(p. ej. `4dba739b`: 192 usados / 192 debitados; `b98891f8`: 180/180).

`[INFERENCIA]` Como la función desplegada inserta siempre y no hay triggers ni
borrados en código, lo más probable es **(i)** que esas 4 filas se borraran a
mano desde el SQL Editor durante una sesión de pruebas (los 4 usuarios se crearon
el 29-oct entre 05:04 y 05:32) o **(ii)** que entre el 29-oct y el 30-oct corriera
una versión intermedia de `consume_mana` sin el `INSERT`. `[NO VERIFICABLE]` sin
el historial de migraciones del SQL Editor.

**Consecuencia metodológica:** el libro **no es prueba suficiente** de que una
llamada se cobró. Para las acciones de pago usé **dos** fuentes (libro + delta de
saldo). Para las gratuitas el código es concluyente: no hay RPC que llamar.

---

## 2. `MANA_CHARGE_MODE`: cómo comprobarlo sin suponerlo

### 2.1 Resultado: no está configurado → el modo efectivo es `capability` `[HECHO]`

`supabase secrets list --project-ref sipiumfdpvnszthykyog` devuelve **17
secretos** y entre ellos **no aparece `MANA_CHARGE_MODE`** (tampoco
`AI_PRICE_*`). Los secretos de Supabase son **de proyecto**, no por función, y no
hay `supabase/config.toml` ni workflow de despliegue en el repo: la Edge Function
no tiene de dónde leer otro valor.

Cadena de deducción, toda verificable:

```ts
// supabase/functions/llm-proxy/index.ts:78
const MANA_CHARGE_MODE = normalizeManaChargeMode(Deno.env.get('MANA_CHARGE_MODE'));

// supabase/functions/llm-proxy/validation.ts:36-40
const mode = (value ?? '').trim().toLowerCase();
if (mode === 'all' || mode === 'off') return mode;
return 'capability';          // ← cualquier otro valor (incluido undefined)
```

⇒ `Deno.env.get()` = `undefined` ⇒ **`capability`**.

Caveat honesto: si alguien desplegara con `--env-file` un archivo local no
versionado, el secreto seguiría sin estar en la lista pero el proceso tendría el
valor. `[NO VERIFICABLE]` desde el repo ni desde la BD; solo un log al arrancar
lo cierra del todo (§2.3).

### 2.2 Qué hace cada modo (código, `validation.ts:42-50`)

| Modo | Comportamiento | Efecto medido |
|---|---|---|
| `off` | `shouldCharge()` → `false` siempre | **Toda** la IA es gratis, incluso acciones de pago. Rollback de emergencia. |
| `capability` **(efectivo hoy)** | cobra **solo** si el body trae `client_capabilities: ["server_mana"]` | Las builds antiguas que cobran en cliente no se cobran dos veces; **una build que no declare la capacidad no paga nada** |
| `all` | cobra **siempre** (`shouldCharge` → `true`) | Cierra el hueco de clientes modificados; **cobra dos veces** a cualquier build que aún cobre en cliente |

### 2.3 Métodos fiables para leer el valor real (propuestos, no aplicados) `[PROPUESTA]`

| Método | Fiabilidad | Coste | Nota |
|---|---|---|---|
| **A. `supabase secrets list`** (lo usado aquí) | Prueba **presencia/ausencia**, no el valor. Si el digest es `sha256(valor)`, comparar con `sha256("off"\|"capability"\|"all")` daría el valor exacto | 0 (solo lectura) | `[NO VERIFICABLE]` que el digest sea sha256 del valor; hay que confirmarlo con un secreto de valor conocido |
| **B. Campo en `/health`** | Total | 1 línea + deploy | Hoy `/health` **oculta** el modo a propósito (`index.ts:344-347`, P-20). Exponerlo tras `Authorization: Bearer <service_role>` o un header secreto evita filtrarlo al público |
| **C. `console.info` en el arranque** | Total, y **no expone nada** | ~1 línea + deploy | `console.info('mana mode', { mode: MANA_CHARGE_MODE })` en el top-level; se lee en los logs de la función (`query_logs`, `function_logs`). **Método recomendado** |
| **D. Sonda de comportamiento** (POST sin `client_capabilities` y mirar 402) | Media: se confunde con límites de saldo y consume maná real | Alto riesgo | No hacerlo en producción |

### 2.4 Corrección de documentación `[HECHO]`

`docs/OPERATIONS.md:62` dice «`all` **por defecto**». Es falso: el defecto del
código es `capability` (`validation.ts:39`). Corregido en este mismo PR.
`docs/product-discovery/02-application-architecture.md:476` sí lo decía bien.

---

## 3. Coste real por acción vs maná cobrado

### 3.1 Tabla `[HECHO]` (muestra: 54 llamadas, 6 usuarios, 3 días)

| Acción | Maná tabla | Llamadas ok | $ total | $/llamada | **Maná cobrado** | Evidencia del cobro | **$/maná** |
|---|---:|---:|---:|---:|---:|---|---:|
| `goal_eval` | 0 | 6 | 0,004243 | 0,000707 | **0** | free por diseño | ∞ |
| `oracle_turn` | 15 | 8 | 0,002717 | 0,000340 | **120** | libro (8×−15) | 0,0000226 |
| `dungeon_turn` | 12 | 12 | 0,002522 | 0,000210 | **132** | libro (8×12) + saldo (11×12 total; 1 gracia) | 0,0000191 |
| `oracle_eval` | 30 | 3 | 0,002436 | 0,000812 | **90** | **solo saldo** (sin libro, §1.3) | 0,0000271 |
| `vocabulary_curation` | 2 | 3 | 0,001550 | 0,000517 | **6** | libro (3×−2) | **0,000258** |
| `stt_transcribe` | 0 | 16 | 0,000769 | 0,000048 | **0** | free por diseño | ∞ |
| `carisma_eval` | 0 | 3 | 0,000635 | 0,000212 | **0** | free por diseño | ∞ |
| `guild_chat` | 0 | 1 | 0,000166 | 0,000166 | **0** | free por diseño | ∞ |
| `free_chat_turn` | 8 | 1 | 0,000022 | 0,000022 | **0** | **hueco** (sin libro ni suscripción) | ∞ |
| `lesson_generation` | 100 | 0 | — | — | — | sin uso en la muestra | — |
| `correction_turn` | 3 (inactiva) | 0 | — | — | — | sin uso desde P-40-c | — |
| **Total** | — | **53** | **0,015060** | — | **348** | — | **0,0000433** |

Precio sombra del maná (solo acciones de pago): $0,009247 / 348 = **$0,0000266
por maná** ⇒ **3.000 maná del plan gratuito ≈ $0,08 de IA** al mes.

### 3.2 Qué mide exactamente ese «$»

`cost_estimate_usd` es una **estimación del propio proxy**
(`supabase/functions/llm-proxy/usage.ts:43-49`), calculada con
`AI_PRICE_INPUT_PER_1M` / `AI_PRICE_OUTPUT_PER_1M` / `AI_PRICE_STT_PER_MINUTE`
y, si no existen, con los valores por defecto **0,27 / 1,10 $ por 1M** y
**0,000667 $/min** de STT. Esos tres secretos **tampoco están configurados**
(§2.1), así que **toda la columna $ usa los precios por defecto**.
`[NO VERIFICABLE]` el coste facturado real: requiere la facturación de
DeepSeek/Groq. Si los precios reales difieren, los **porcentajes se mantienen**
(cambia la escala), porque todas las acciones de chat usan la misma tarifa.

### 3.3 El desfase que no es del 38,6 %: dispersión interna `[HECHO]`

Entre las acciones **sí cobradas**, el precio por maná varía **13,5×**:

| Acción | $/maná | vs `dungeon_turn` |
|---|---:|---:|
| `dungeon_turn` | 0,0000191 | 1,0× |
| `oracle_turn` | 0,0000226 | 1,2× |
| `oracle_eval` | 0,0000271 | 1,4× |
| `vocabulary_curation` | 0,000258 | **13,5×** |

`[INFERENCIA]` Cualquier propuesta de «cobrar el 38,6 %» que ignore esto produce
un sistema donde un turno de mazmorra paga 13 veces menos por dólar que una
curaduría. El maná sigue midiendo **ritmo**, no coste.

### 3.4 Tamaño y sesgo de la muestra `[HECHO]`

| Dato | Valor |
|---|---|
| Filas | 54 (de ellas 1 `no_mana`, sin coste) |
| Usuarios | 6 |
| Ventana | 29-oct-2026 05:05 → 31-oct-2026 01:26 UTC (3 días) |
| Concentración | `46bd5746` = **45 llamadas (83,3 %)** y **$0,012520 (83,1 %)** del gasto |
| Cobertura de acciones | 9 de las 11 configuradas; `lesson_generation` y `correction_turn` **sin datos** |

Es una muestra **de puesta en marcha**, no de uso real: el registro P-14 empezó
el 29-oct y el 83 % viene de una sola cuenta (probablemente de pruebas). Las
cifras son válidas como **orden de magnitud**, no como serie.

---

## 4. Propuesta de corrección (sin aplicar, requiere decisión)

> Recordatorio: el maná **no genera ingresos** hoy (`purchased_mana_balance` = 0
> en 15/15 suscripciones, `mana_items` = 0). Cobrar más maná = **racionar más**,
> no recaudar más. Si el objetivo es margen, la palanca es el **precio del plan**;
> si es atribución y control de coste, las palancas son P1–P3.

### P1 — Poner `MANA_CHARGE_MODE=all` (config, sin código)

- **Qué:** crear el secreto en el proyecto y redesplegar `llm-proxy`.
- **Por qué:** hoy el cobro depende de que **el cliente se autodeclare**. Un
  cliente modificado paga 0 y el servidor no lo nota.
- **Impacto medido:** 1 de 28 llamadas de pago (3,6 %) no se cobró → **$0,000022
  (0,15 %)** recuperables. Impacto pequeño **hoy**, cierre de clase de fallo.
- **Riesgo que hay que decidir antes:** las builds que **aún cobran en cliente**
  pasarían a pagar dos veces. Según `docs/product-audit/ESTADO-HISTORIAS.md:33`
  la última build publicada es `1.0.19+20` (alpha) y **no hay release en
  producción**; el código actual (1.0.21) ya declara `server_mana` en las 5 rutas
  (`conversation_repository_impl.dart:151,314,378,449,669`). **Confirmar qué
  builds hay en la calle (Play Console) antes de activar.** `[NO VERIFICABLE]`
  desde la BD.

### P2 — Registrar el maná cobrado en `ai_usage_logs` (migración + 5 líneas)

- **Qué:** añadir `mana_charged INTEGER` y `charge_source TEXT` (`plan`/`equipped`/`grace`/`none`)
  a `ai_usage_logs`; el proxy los escribe desde el `ChargeResult` que ya tiene
  (`index.ts:444-500`).
- **Por qué:** hoy **no existe forma de cruzar** una llamada de IA con su cobro;
  este informe tuvo que reconstruirlo con deltas de saldo y topó con la anomalía
  de §1.3. Sin esto, la pregunta «¿cuánto se cobra a 0?» **no se puede responder
  con una consulta**.
- **Impacto:** 0 ingresos; convierte el 38,6 % en un panel permanente y detecta
  regresiones como la del libro de maná.

### P3 — Decidir el precio de las evaluaciones internas (producto)

`goal_eval` + `carisma_eval` = **32,4 % del gasto** y 0 maná. Tres opciones, con
impacto al precio sombra actual ($0,0000266/maná):

| Opción | Maná por llamada | Maná recuperable en la muestra | Gasto cubierto |
|---|---:|---:|---:|
| A. Dejarlas gratis y **documentarlas como coste de bienes** | 0 | 0 | 0 % |
| B. Integrarlas en el turno (subir `dungeon_turn` 12→16 / `free_chat_turn` 8→11 / `oracle_turn` 15→19) | +4 por turno | +84 (21 turnos) | **14,8 %** |
| C. Cobrarlas aparte al precio sombra | `goal_eval` 27 · `carisma_eval` 8 | 6×27 + 3×8 = **186** | **32,4 % del gasto** |

`[INFERENCIA]` C es la única que alinea coste y cobro, pero duplica el precio
percibido de una sesión. B es invisible para el jugador. **Decisión de producto,
no técnica.**

### P4 — `stt_transcribe`: dejarlo gratis **a propósito** (sin cambio)

5,1 % del gasto. Es el input de un turno que ya paga 8–15 maná; cobrarlo sería
facturar dos veces al mismo turno. Recomendación: **no tocarlo** y contabilizarlo
como coste de bienes del turno en el panel de P2.

### P5 — Repreciar `vocabulary_curation` (opcional)

2 maná por $0,000517 = **13,5×** la tarifa del turno. Alinearlo al precio sombra
sería ~19 maná. Impacto en la muestra: 6 → 58 maná (+52). `[INFERENCIA]` Subirlo
tanto puede desincentivar una función pedagógica; alternativa: bajarlo a coste 0
y tratarlo como parte del cierre de sesión. **Decisión de producto.**

### Resumen de impacto

| Propuesta | Esfuerzo | Gasto de IA que pasa a tener contrapartida | Riesgo |
|---|---|---|---|
| P1 `MANA_CHARGE_MODE=all` | Config | 0,15 % | Doble cobro a builds antiguas |
| P2 telemetría `mana_charged` | 1 migración + 5 líneas | 0 % (habilita medir el 100 %) | Ninguno |
| P3-B integrar evals en el turno | Config (`ai_action_costs`) + copy | 14,8 % | Cambia el precio percibido |
| P3-C cobrar evals aparte | Config + UI de saldo | 32,4 % | Duplica el coste de sesión |
| P4 STT gratis | — | 0 % | Ninguno |
| P5 reprecio curaduría | Config | 9,0 % | Desincentivo pedagógico |

Ninguna de estas propuestas se ha aplicado.

---

## 5. Hecho / inferencia / propuesta / no verificable

**Hecho**
- 38,60 % del gasto estimado de IA se cobra a 0 por `FREE_ACTIONS`; +0,15 % por
  una llamada de pago no cobrada ⇒ 38,75 %.
- `MANA_CHARGE_MODE` **no está entre los 17 secretos** del proyecto → modo
  efectivo `capability`, por el defecto de `validation.ts:39`.
- `docs/OPERATIONS.md:62` afirmaba «`all` por defecto»: incorrecto.
- 4 usuarios consumieron saldo el 29-oct sin fila en `mana_transactions`.
- Un solo usuario concentra el 83,1 % del gasto medido.

**Inferencia**
- El 0,15 % de `free_chat_turn` viene de una build que no declara `server_mana`.
- La ausencia de filas en el libro para esos 4 usuarios se debe a borrado manual
  o a una versión intermedia de `consume_mana`.
- El maná mide ritmo, no coste; cobrar el 38,6 % no recupera ingresos.

**No verificable (y qué falta)**
- **Precios reales** de DeepSeek/Groq: falta facturación del proveedor; el «$» es
  estimación a tarifa por defecto.
- **Valor histórico** de `MANA_CHARGE_MODE`: no hay histórico de secretos ni logs
  de arranque. Cerrarlo exige P2/B-C de §2.3.
- **Builds instaladas** (para decidir P1): requiere Play Console.
- **Causa de la anomalía del libro**: requiere historial del SQL Editor.

---

## 6. Evidencia reproducible (solo lectura)

```sql
-- E1. Mezcla del gasto por acción (54 filas)
select action_code, status, count(*) calls,
       sum(cost_estimate_usd)::numeric(12,6) cost_total
from public.ai_usage_logs
group by 1,2 order by 4 desc nulls last;

-- E2. Precios vigentes (7 filas, correction_turn inactiva)
select action_code, cost_mana, is_active from public.ai_action_costs order by cost_mana desc;

-- E3. Maná cobrado (libro) en la ventana
select action_code, type, count(*) n, sum(amount) mana
from public.mana_transactions
where created_at >= '2026-10-29 05:00+00'
group by 1,2 order by 1;

-- E4. Cuadre saldo vs libro (detecta la anomalía de §1.3)
select left(us.user_id::text,8) usr, us.used_audio_seconds used, us.daily_used dl,
       coalesce(sum(case when m.type='action' then -m.amount end),0) ledger_debits,
       count(m.*) ledger_rows
from public.user_subscriptions us
left join public.mana_transactions m on m.user_id = us.user_id
group by 1,2,3
having us.used_audio_seconds > 0 or count(m.*) > 0
order by us.used_audio_seconds desc;

-- E5. Concentración de la muestra
select left(user_id::text,8) usr, count(*) calls,
       round(100*sum(cost_estimate_usd)/(select sum(cost_estimate_usd) from public.ai_usage_logs),1) pct
from public.ai_usage_logs group by 1 order by 3 desc;
```

```sh
# E6. Secretos desplegados (nombres + digest; NO muestra valores)
supabase secrets list --project-ref sipiumfdpvnszthykyog
# → 17 secretos; MANA_CHARGE_MODE y AI_PRICE_* ausentes
```

Resultados literales resumidos en §1.1, §1.3, §2.1 y §3.1.
