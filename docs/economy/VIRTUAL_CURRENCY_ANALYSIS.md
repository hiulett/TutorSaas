# Monedas y recursos: análisis de la economía virtual

_Auditoría económica · Fase 3. Sin cambios de código ni de base de datos._

**Método y límites de verificación.** Este documento se apoya en tres fuentes y
las distingue siempre:

| Fuente | Qué aporta | Fiabilidad |
|---|---|---|
| `docs/runbooks/ECONOMY_SINKS.md` | Cifras **verificadas contra producción** (`sipiumfdpvnszthykyog`) el 29-oct-2026 con consultas de solo lectura | Alta (medición real, fechada) |
| Migraciones `supabase/migrations/*.sql` | Definición real de tablas, RPC, triggers e idempotencia | Alta (es el esquema, aunque el repo no lo reproduzca entero) |
| Código Dart (`lib/features/economy/**`) | Qué pinta y qué puede pedir la app | Alta para el cliente |

**No verificable en esta sesión:** no hay acceso MCP a producción desde este
entorno, así que **no se han re-ejecutado** las consultas de `v_economy_flow`, ni
se han contado filas actuales de `player_inventory`, `currency_ledger` o
`cosmetic_catalog`. Cualquier cifra de volumen es la de la medición del
29-oct-2026 y va marcada como tal.

---

## 1. Inventario de recursos

| Recurso | Tipo | Función real | Implementado |
|---|---|---|---|
| **Maná** | Moneda de consumo de IA (no es moneda de juego) | Paga cada acción de IA. Se agota y limita la práctica | Sí, servidor |
| **Oro** (`total_gold`) | Moneda gratuita de progresión | Compra cosméticos del catálogo | Sí |
| **Gemas** (`total_gems`) | Moneda premium-adyacente | Freeze de racha y cosméticos premium | Sí |
| **Fragmentos** (`fragments`) | Material de fabricación | Recetas de `craft_cosmetic` | Sí |
| **XP** (`xp_points`) | Progresión | Nivel de cazador y bolsas de nivel | Sí |
| **Pergaminos** (`player_pergaminos`) | Recurso residual | **Sin sumidero**; la recompensa diaria aún los entrega | Parcial / fósil |
| **Racha** | Estado, no moneda | Multiplica/motiva, habilita freeze | Sí |

Fuentes de la tabla: `ECONOMY_SINKS.md` §1, `PRODUCT.md` §3,
`lib/features/economy/domain/models/economy_wallet.dart` y
`shop_offer.dart` (`CurrencyKind`: `gold`, `gems`, `fragments`).

**Lo que no existe.** No hay moneda premium comprada con dinero real, ni
conversión entre monedas, ni moneda social. No hay tienda de maná: `PRODUCT.md`
§6 registra «Retirar venta de maná y el tab de MANÁ de la tienda» como decisión
tomada. El maná se obtiene por plan y pociones, no se compra por separado.

---

## 2. Fuentes (money sources)

| Fuente | Qué entrega | Mecanismo real | Notas |
|---|---|---|---|
| Cierre de sesión | Oro + fragmentos | `apply_session_rewards`: objetivos × (10 + bonus de nivel) para oro; × (5 + bonus) para fragmentos | Verificado en producción 29-oct |
| Bolsas de nivel | Oro | `claim_level_rewards` en niveles 2, 3, 5, 8, 12, 15 | Idempotente por `level_reward:<nivel>` |
| Misiones | Gemas | `claim_mission_reward(p_instance_id)` | Contrato endurecido en 3 migraciones |
| Recompensa diaria | Gemas 5 / 50 / 100 / 300 + pergaminos | Flujo de recompensa diaria | El importe lo decide el servidor |
| Sesión (drops) | Loot de sesión | `claim_session_drop` | `session_drops.sql` |
| Sesión (XP) | XP | Nivel = `1 + XP/1000` | `economy_level(xp)` en SQL |
| Maná | 3.000 / 17.000 / 20.500 al mes por plan | Plan + `consume_mana` en servidor | Tope de 200/día en gratuito + 1 turno de gracia |

## 3. Sumideros (money sinks)

| Sumidero | Moneda | Precio | Dónde se valida |
|---|---|---|---|
| Cosméticos del catálogo | Oro | **60–1.200** | `purchase_cosmetic` (SECURITY DEFINER) |
| Cosméticos premium | Gemas | **350–2.800** | `purchase_cosmetic(..., 'gems')` |
| Freeze de racha | Gemas | 30, **máximo 3** | `purchase_streak_freeze` |
| Crafteo | Fragmentos | 120 / 250 / 400 | `craft_cosmetic` |
| Acciones de IA | Maná | Turno Oráculo 15 · cierre 30 · mazmorra 12 | `consume_mana` (servidor) |
| Desbloqueo por nivel | — (no cuesta) | Requiere `required_level` 2–20 | `cosmetic_catalog` |

**Sumidero que no existe:** no hay forma de gastar **pergaminos**. Es el único
recurso declarado sin salida (el propio runbook lo reconoce en §6).

---

## 4. Reglas de integridad (lo que sostiene el sistema)

1. **El cliente no escribe saldos.** Todo movimiento pasa por
   `economy_apply_currency` a través de cinco RPC `SECURITY DEFINER`
   (`purchase_cosmetic`, `craft_cosmetic`, `purchase_streak_freeze`,
   `spend_currency`, `claim_level_rewards`). El trigger `guard_language_profile`
   descarta `total_gold`, `total_gems`, `fragments` y `xp_points` enviados por el
   cliente.
2. **Libro mayor con idempotencia.** `currency_ledger` con
   `unique (user_id, ref_key)`: repetir una compra con la misma referencia
   devuelve el saldo aplicado sin volver a cobrar.
3. **Ninguna moneda compra ventaja de aprendizaje.** El maná se cobra por turno
   sin importar el plan; oro/gemas/fragmentos solo pagan cosméticos, freezes y
   crafteo. Está escrito en `PRODUCT.md` §2 y §3 y aplicado en las RPC.
4. **Medición desde el primer día.** Vista `v_economy_flow`
   (currency, reason, earned, spent, movements) y API `get_economy_wallet` con el
   mismo dato, para que UI y análisis no discrepen.

---

## 5. Estado histórico y diagnóstico del balance

La medición de producción del **29-oct-2026** (antes de P-32) es el dato más
valioso que tenemos, porque describe la economía **ya vivida por usuarios**:

| Comprobación | Resultado medido |
|---|---|
| `player_inventory` | **0 filas** — nadie compró nunca un cosmético |
| Oro máximo / mediana | 160 / 100 — el cosmético más barato costaba 120 |
| Gemas máximas por usuario | 57 — el cosmético más barato costaba 350 |
| Fragmentos | 483 en 5 perfiles, **sin sumidero** |
| Libro de movimientos | **no existía** (solo `session_reward_ledger`, de ingresos) |
| `spendGold()` del cliente | escribía `UPDATE total_gold`, el trigger lo descartaba y devolvía `true` sin cobrar |

Lectura: la economía estaba **rota por dos lados a la vez** — los precios de
entrada eran inalcanzables con el saldo real (100 de oro frente a un mínimo de
120; 57 gemas frente a 350) y el gasto no dejaba rastro. No era un problema de
"faltan sumideros": era que **el único sumidero existente era inalcanzable**.

Después de P-32 se añadieron objetos de entrada a 60/80/90 y el libro de
movimientos, lo que hace medible el ratio de sumidero
(`spent / earned`). El runbook fija dos umbrales de lectura: por debajo de
**0.2** el precio de entrada sigue alto; por encima de **0.8** el catálogo se
queda corto.

**Estado de salud: no determinable con los datos de esta sesión.** No hay
`v_economy_flow` ejecutado después de P-32, así que **no sabemos si el ratio de
sumidero llegó a una banda sana**. Esta es la primera métrica que hay que
recuperar (ver `ECONOMY_METRICS_AND_KPIS.md`).

---

## 6. Decisiones que este análisis considera correctas

- **Una moneda dura y dos blandas**, no cinco. Maná (recurso de uso), oro (progresión) y gemas (premium) tienen funciones disjuntas y ninguna se convierte en otra: eso evita arbitraje y lavado de moneda.
- **Fragmentos como material de fabricación** en vez de cuarta moneda: da una vía alternativa a la compra (juega → fabrica) sin añadir otra cifra que explicar.
- **XP separado del gasto**: el nivel no se compra, se gana. Mantiene la progresión ligada al aprendizaje.
- **Sin venta directa de maná.** Es la decisión más discutible comercialmente y la más sana pedagógicamente: evita que el dinero compre tiempo de práctica.

## 7. Problemas detectados (priorizados)

| # | Problema | Evidencia | Severidad |
|---|---|---|---|
| C-1 | **Pergaminos sin sumidero** | `ECONOMY_SINKS.md` §6; `player_pergaminos` sigue existiendo | Media (inflación muerta) |
| C-2 | **Ratio de sumidero sin medir tras P-32** | No hay consulta posterior en repo ni doc | Alta (no se puede decidir sin dato) |
| C-3 | **Gemas sin fuente gratuita suficiente para su precio** | 57 de máximo medido frente a 350 del cosmético más barato | Alta (el sumidero premium nace inalcanzable) |
| C-4 | **Oro solo paga cosméticos** | `ECONOMY_SINKS.md` §3 | Media (sumidero estrecho: se agota el interés al comprar 3–4 objetos) |
| C-5 | **Freeze de racha tope 3** | `purchase_streak_freeze` | Baja (correcto como protección, no como sumidero) |

## 8. Conversiones y arbitraje

**No existe ninguna conversión entre monedas**, y es una decisión que conviene
mantener: cualquier cambio oro↔gemas introduce un tipo de cambio que hay que
balancear, y una vía para que el oro gratuito erosione el valor de la moneda
premium. La única "conversión" real es **tiempo de juego → recursos**, que es
exactamente la que interesa.

## 9. Qué falta para completar esta fase

1. Ejecutar `v_economy_flow` en producción y calcular `sink_ratio` por moneda.
2. Contar usuarios con saldo alto y sin gasto (acumulación).
3. Distribución de `cosmetic_catalog` por `required_level` y precio, para ver si la escalera de precios acompaña a la de niveles.

Sin esos tres datos, cualquier ajuste de precios sería una corazonada.
