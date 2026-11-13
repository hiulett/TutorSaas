# Integridad económica: consultas de control

Runbook de **solo lectura** para verificar que la economía no tiene agujeros antes
de cada release. Historias: #370 (#367, #368).

**Cómo se ejecuta:** SQL Editor de Supabase o MCP, con rol de servicio, en
producción (`sipiumfdpvnszthykyog`). Todas las consultas son `select`; ninguna
modifica datos. Tiempo total: < 2 minutos.

**Qué se hace con el resultado:** se guarda la salida con fecha y se compara con
la del release anterior. Un valor distinto de «esperado» **bloquea el release**
hasta entenderlo.

---

## 1. Multiplicador de recompensa fuera de rango

```sql
select count(*) as fuera_de_rango
  from public.mission_instances
 where reward_multiplier > 2;
```

**Esperado: 0.** Un valor mayor significa que el exploit de #367 sigue vivo
(`reward_multiplier` escribible desde el cliente y pagado ×N por
`claim_mission_reward`).

## 2. Misiones reclamadas sin progreso real

```sql
select count(*) as reclamadas_sin_progreso
  from public.mission_instances
 where is_reward_claimed
   and coalesce(current_value, 0) < coalesce(target_value, 0);
```

**Esperado: 0.** Detecta misiones «completadas» sin haber llegado al objetivo
(auto-completado desde el cliente, parte pendiente de #367).

## 3. Descuadre entre saldo y libro mayor

```sql
with last_move as (
  select distinct on (user_id, currency)
         user_id, currency, balance_after
    from public.currency_ledger
   order by user_id, currency, created_at desc, id desc
), expected as (
  select user_id, 'gold' as currency, coalesce(total_gold, 0) as perfil
    from public.user_language_profiles
  union all
  select user_id, 'gems', coalesce(total_gems, 0)
    from public.user_language_profiles
  union all
  select user_id, 'fragments', coalesce(fragments, 0)
    from public.user_language_profiles
)
select l.user_id, l.currency, l.balance_after as ledger, e.perfil
  from last_move l
  join expected e using (user_id, currency)
 where l.balance_after <> e.perfil
 order by l.user_id, l.currency;
```

**Esperado: 0 filas.** El saldo del perfil debe coincidir con el último
`balance_after` del libro mayor para cada moneda. Una fila es un movimiento no
registrado o una escritura directa de saldo.

## 4. Items retirados: ni a la venta ni comprables

```sql
-- 4a. Ninguno de los 9 items muertos sigue activo
select id
  from public.cosmetic_catalog
 where is_active
   and id in (
     'consumible_invocacion5','consumible_invocacion20',
     'consumible_pergamino10','consumible_pergamino50',
     'key_mazmorra_oculta','key_archivo_gremio',
     'book_phrasal_verbs','book_grimorio_tiempos','book_pronunciacion'
   );

-- 4b. Inventario histórico sobre items retirados (informativo, no bloquea)
select c.id, count(*) as propietarios
  from public.player_inventory pi
  join public.cosmetic_catalog c on c.id = pi.item_code
 where not c.is_active
 group by c.id
 order by propietarios desc;
```

**Esperado:** 4a vacío. 4b puede tener filas legítimas (compras anteriores a
#368); sirve para dimensionar un reembolso o una compensación.

## 5. Recompensas duplicadas

```sql
select user_id, source_type, source_id, count(*) as veces
  from public.reward_history
 group by user_id, source_type, source_id
having count(*) > 1
 order by veces desc;
```

**Esperado: 0 filas.** Indica una entrega doble (fallo de idempotencia o reintento
de webhook/RPC).

## 6. Compras rechazadas sobre items retirados (posterior a #368)

```sql
select count(*) as compras_items_retirados
  from public.currency_ledger
 where reason in ('purchase_cosmetic', 'craft_cosmetic')
   and created_at > now() - interval '7 days';
```

Lectura: cruzar con `player_inventory` para ver si alguna de esas compras cayó
sobre un item inactivo. Con `trg_guard_inactive_inventory` activo, el servidor
debe rechazarlas antes de escribir en el ledger.

---

## Checklist de release

- [ ] 1. Multiplicadores > 2 → **0**
- [ ] 2. Reclamadas sin progreso → **0**
- [ ] 3. Descuadres saldo/ledger → **0 filas**
- [ ] 4a. Items retirados activos → **ninguno**
- [ ] 5. Recompensas duplicadas → **0 filas**
- [ ] 6. Revisado el inventario histórico (4b) tras #368
- [ ] Salida guardada con fecha y comparada con el release anterior

## Si algo no cuadra

1. **No** ejecutar `UPDATE` de saldo «para cuadrar»: se perdería la trazabilidad.
2. Localizar las filas (`select` con el `user_id`), no el agregado.
3. Cruzar con `reward_history` y `currency_ledger` por fecha.
4. Si es una escritura legítima sin asiento, el fallo es de la RPC que la hizo.
