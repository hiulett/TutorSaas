# Auditoría técnica y seguridad económica

_Auditoría económica · Fase 9. Solo lectura: no se ha modificado código, esquema
ni datos._

**Alcance de verificación.** Análisis sobre `supabase/migrations/*.sql` y
`lib/**`. **No hay acceso MCP a producción en esta sesión**, por lo que las
políticas RLS y las funciones se citan **tal como están definidas en el repo**.
AGENTS.md advierte que el repo no reproduce el esquema (33 migraciones se
aplicaron desde el SQL Editor), así que **todo hallazgo de seguridad aquí es
«según migraciones» hasta que se contraste con producción**.

---

## 1. Superficie económica real

| Capa | Elementos |
|---|---|
| Tablas de saldo | `user_language_profiles` (`total_gold`, `total_gems`, `fragments`, `xp_points`) |
| Libro mayor | `currency_ledger` (`unique(user_id, ref_key)`), `session_reward_ledger`, `reward_history`, `mana_transactions` |
| Catálogo | `cosmetic_catalog` (`price_gold`, `price_gems`, `craft_cost_fragments`, `required_level`, `min_plan`) |
| Inventario | `player_inventory` (+ `item_effect`, `item_meta`, `source`) |
| Misiones | `mission_instances` (+ `reward_multiplier`, `applied_modifier_code`) |
| Maná | `user_subscriptions`, `mana_transactions`, `mana_items`, `mana_potions`, `mana_gems` |
| Medición | Vista `v_economy_flow`, RPC `get_economy_wallet` |

**RPC económica (`SECURITY DEFINER`):** `economy_apply_currency` (helper
interno), `purchase_cosmetic`, `craft_cosmetic`, `purchase_streak_freeze`,
`spend_currency`, `claim_level_rewards`, `claim_mission_reward`,
`claim_session_drop`, `claim_mana_grace`, `consume_mana`.

**Diseño correcto de base:** el cliente no escribe saldos (el trigger
`guard_language_profile` descarta `total_gold`/`total_gems`/`fragments`/
`xp_points`), y el gasto pasa por RPC con libro mayor idempotente. La
arquitectura del ledger es sólida y no requiere migración: ya existe y ya es
idempotente.

---

## 2. Hallazgos

### F-1 · CRÍTICO — `reward_multiplier` se puede inflar desde el cliente y el servidor no lo acota

**Cadena real:**

1. `20260730_phase9_items_modifiers.sql:36` añade `mission_instances.reward_multiplier`.
2. La RLS `update_own_instances` (`20260730_mission_engine.sql:195`) permite al
   usuario **actualizar sus propias filas** de `mission_instances`.
3. El trigger `guard_mission_instance`
   (`20261018000004_missions_progress.sql:127-155`) restaura en un UPDATE:
   `xp_reward`, `gem_reward`, `target_value`, `objective_type`, `user_id`.
   **No restaura `reward_multiplier`, `status` ni `current_value`.**
4. `claim_mission_reward` (`20261029171705_claim_mission_reward_contract.sql:54-65`):

```sql
v_mult := greatest(1, coalesce(v_row.reward_multiplier, 1));
v_xp   := coalesce(v_row.xp_reward, 0) * v_mult;
v_gems := coalesce(v_row.gem_reward, 0) * v_mult;
```

`greatest(1, …)` pone un **suelo**, no un techo.

**Consecuencia:** un cliente autenticado puede llamar a PostgREST y hacer
`UPDATE mission_instances SET reward_multiplier = 1000, status = 'completed',
current_value = target_value WHERE id = <suya>` y después
`rpc/claim_mission_reward`. El servidor paga `gem_reward × 1000` y lo registra
como legítimo en `reward_history`.

**Severidad:** P0. Es inflación de gemas/xp a voluntad — la moneda premium-adyacente
del sistema.

**Mitigación propuesta (no implementada):**
- Restaurar en el trigger: `new.reward_multiplier := old.reward_multiplier;`
  y `new.status` / `new.current_value` gestionados solo por funciones
  `SECURITY DEFINER`.
- Acotar en la RPC: `v_mult := least(2, greatest(1, coalesce(...)))`.
- Mejor aún: que el multiplicador lo escriba una RPC
  (`apply_mission_modifier(p_instance_id, p_item_code)`) tras validar y consumir
  el item, y que el trigger lo proteja como el resto de campos de recompensa.

> Coincide con el issue abierto **#282 «Recompensas: una sola puerta con
> evidencia de servidor»**. La auditoría aporta el vector concreto.

---

### F-2 · ALTO — La misión se puede «completar» desde el cliente

El guard de F-1 tampoco restaura `status` ni `current_value`. La comprobación de
`claim_mission_reward` es `status = 'completed'`, y el estado lo puede poner el
cliente. Aunque F-1 se cierre, **queda la vía de completar cualquier misión
saltándose la actividad educativa**.

**Mitigación:** que `status`/`current_value` solo cambien dentro de
`advance_missions_for_user` (ya es `SECURITY DEFINER` y ya se invoca desde
triggers de `messages`, `user_vocabulary` y `conversation_turns`), y que el
trigger de guard los revierta en cualquier UPDATE de `authenticated`.

---

### F-3 · ALTO — La tienda vende dos recursos que ya no existen: invocaciones y pergaminos

`cosmetic_catalog` incluye:

| Item | Precio | Texto que promete |
|---|---|---|
| `consumible_invocacion5` | 50 gemas | «Recarga 5 invocaciones de IA» |
| `consumible_invocacion20` | 180 gemas | «Recarga 20 invocaciones de IA» |
| `consumible_pergamino10` | 100 gemas | «Contenido offline para practicar sin IA» |
| `consumible_pergamino50` | 400 gemas | «Lote grande de práctica offline» |

**Estado real:**
- El límite de IA lo cobra `consume_mana` en `llm-proxy`
  (`supabase/functions/llm-proxy/index.ts:205`). **No hay ninguna comprobación de
  invocaciones** en el servidor.
- Las invocaciones solo se mueven en el cliente
  (`economy_repository_impl.dart:44-101`, `:293-304`) incrementando
  `player_daily_state.invocations_max`, un contador que **nadie usa para
  bloquear nada**.
- `pergamino` **no aparece en ninguna Edge Function**. No hay práctica offline
  implementada; la app es online-only.

**Consecuencia:** el usuario puede pagar 50–400 gemas por un item que **no
produce ningún efecto verificable**. Y `player_pergaminos` sigue recibiendo
pergaminos de la recompensa diaria sin sumidero (`ECONOMY_SINKS.md` §6).

**Riesgo:** doble — económico (se cobra por nada: reembolsos, reseñas) y de
confianza (el jugador descubre que no sirve).

---

### F-4 · MEDIO — Efectos de items declarados y no consumidos

| Item | Efecto prometido | Implementación |
|---|---|---|
| `mod_recompensa_x2` / `mod_piedra_facilidad` / `mod_piedra_desafio` | Modificar la misión | **Cliente**: `mission_repository.dart:242-248` escribe `reward_multiplier`/`target_value` en el `update`; el servidor respeta `reward_multiplier` (F-1) pero **no valida que el item exista ni se consuma** |
| `mod_llave_ruta_secreta`, `key_mazmorra_oculta`, `key_archivo_gremio` | Desbloquear contenido | **0 referencias** en `lib/` ni en Edge Functions |
| `book_phrasal_verbs`, `book_grimorio_tiempos`, `book_pronunciacion` | Contenido de estudio | **0 referencias** |
| `skin_*`, `theme_fondo_abismo`, `guild_dec_*` | Cosmético | Categoría **mal clasificada como `consumable`** |
| `pet_*`, `aura_*`, `frame_*`, `title_*`, `theme_mesa_*` | Cosmético | Sin sistema de equipado visible en la economía (a verificar en perfil) |

`item_effect` y `item_meta` existen como columnas pero tienen **0 usos** en Dart
y **0 en Edge Functions**: la metadata de efecto está declarada y nunca se lee.

---

### F-5 · MEDIO — El modificador se aplica sin consumo verificable del item

`mission_repository.dart` escribe el efecto basándose en un código de item. No
se ha encontrado la llamada que **descuente** el item del inventario en el mismo
paso. Si no existe, el usuario puede aplicar el modificador sin tenerlo (salvo
que lo impida un RLS que no se ve desde el repo).

---

### F-6 · BAJO — Categorías del catálogo inconsistentes

`skin_cazador`, `theme_fondo_abismo`, `guild_dec_*` y `book_*` están declarados
como `consumable`, cuando son cosméticos o contenido. Rompe cualquier análisis
de «cuánto inventario es funcional vs estético» y afecta a la UI que agrupa por
categoría.

---

## 3. Lo que está bien y no hay que tocar

1. **Ledger idempotente por `(user_id, ref_key)`** en `currency_ledger`: el
   patrón correcto para una economía.
2. **RPC `SECURITY DEFINER` con validación de precio en servidor**
   (`purchase_cosmetic` lee el precio del catálogo, no del cliente).
3. **Trigger que descarta campos de moneda enviados por el cliente**
   (`guard_language_profile`).
4. **Maná cobrado en servidor** por turno, independiente del plan.
5. **Trazabilidad**: `reward_history`, `mana_transactions`, `session_reward_ledger`
   y vista `v_economy_flow` para conciliar.

## 4. Priorización técnica

| # | Hallazgo | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| F-1 | Multiplicador inflable | Crítico (inflación) | Bajo (2 líneas de trigger + clamp) | **P0 inmediato** |
| F-2 | Auto-completar misiones | Alto (rompe el aprendizaje) | Medio | P0 |
| F-3 | Items sin efecto a la venta | Alto (cobro sin valor) | Bajo (retirar del catálogo) | P0 |
| F-5 | Modificador sin consumo | Medio (duplicación) | Medio | P1 |
| F-4 | Efectos declarados sin implementar | Medio | Alto (producto) | P2 |
| F-6 | Categorías mal clasificadas | Bajo | Bajo | P3 |

## 5. Qué falta para cerrar esta auditoría técnica

- Contrastar en producción: políticas reales de `mission_instances`, cuerpo
  vigente de `guard_mission_instance` y si existe algún trigger adicional
  aplicado solo por SQL Editor.
- Confirmar que ningún otro `SECURITY DEFINER` hace `UPDATE` de saldos sin pasar
  por `economy_apply_currency`.
- Revisar `player_inventory`: quién escribe `quantity`, si hay consumo de items y
  si el inventario y el saldo pueden desincronizarse (no verificable sin
  producción).
