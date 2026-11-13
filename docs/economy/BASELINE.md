# Línea base de economía (producción)

_Medición del **13-nov-2026** contra `sipiumfdpvnszthykyog`, solo lectura vía REST
con clave de servicio. Cierra #369._

**Método.** Consultas `select` a PostgREST con `Prefer: count=exact`. Ninguna
escritura. El secreto usado no se guarda en el repo.

---

## 1. Volumen del sistema

| Tabla | Filas |
|---|---|
| `user_language_profiles` | **65** |
| `mission_instances` | **637** |
| `reward_history` | **15** |
| `revenuecat_events` | 1 |
| `cosmetic_catalog` | **40** |
| `currency_ledger` | **0** |
| `player_inventory` | **0** |
| `payments` | **0** |

## 2. Saldos (65 perfiles)

| Recurso | Máximo | Mediana | Media | Total |
|---|---|---|---|---|
| Oro | **180** | 100 | 103 | 6.698 |
| Gemas | **172** | 0 | 3,7 | 242 |
| Fragmentos | **398** | 0 | 7,5 | 488 |
| XP | **3.773** | 0 | 65 | 4.228 |

Lectura: XP máximo 3.773 → **nivel 4** como techo (nivel = 1 + XP/1000), frente a
`required_level` que llega a **20**. La mayoría del catálogo está bloqueada por
nivel, no por precio.

## 3. ¿Pueden comprar?

| Comprobación | Resultado |
|---|---|
| Perfiles con oro ≥ 60 (item de entrada) | **65 de 65** |
| Perfiles con gemas ≥ 350 (cosmético premium más barato) | **0 de 65** |
| Perfiles con fragmentos > 0 | 5 de 65 |

## 4. Catálogo: estructura de precios

| Tipo | Items |
|---|---|
| Con oro **y** gemas a la vez | **14** |
| Solo oro | 3 |
| Solo gemas | 17 |
| Gratis (0/0, reliquias y similares) | 6 |
| Rango de precio en oro | 0–1.200 |

**Confirmado en producción**: el doble precio que la auditoría señaló no es una
hipótesis, son 14 items.

## 5. Actividad que genera moneda

| Estado de misión | Filas |
|---|---|
| `active` | 629 |
| `completed` | **8** |
| Recompensas reclamadas | 8 |

`reward_history`: 15 filas, **todas de tipo `mission`** (ninguna de nivel, sesión
u otra fuente).

## 6. Integridad

| Comprobación | Resultado |
|---|---|
| `mission_instances.reward_multiplier > 2` | **0** |
| `reward_multiplier = 2` | **0** |
| `cosmetic_catalog.is_active` | **no existe aún** → migración de #368 sin aplicar |

El exploit de #367 **no se ha explotado todavía**, pero la vía sigue abierta
hasta aplicar la migración `20261113010000`.

## 7. Conclusiones que cambian el plan

1. **El precio no es el problema.** 65 de 65 perfiles pueden pagar el item de
   entrada (60 oro) y **nadie ha comprado nunca**: `player_inventory` = 0 y
   `currency_ledger` = 0. Ajustar precios sin arreglar descubrimiento/motivación
   no moverá nada.
2. **El sumidero de gemas es inalcanzable.** Nadie llega a 350 gemas (máximo 172)
   y no hay fuente de gemas fuera de las misiones.
3. **La economía no está en uso, no solo sin balancear.** 629 misiones activas
   frente a **8 completadas** y 15 recompensas históricas: el sistema se ha usado
   de forma casi testimonial.
4. **El techo de nivel es 4** sobre un catálogo que pide hasta nivel 20: la
   escalera de desbloqueo no acompaña al uso real.
5. **`sink_ratio` no es calculable**: no hay movimientos en el libro mayor. El
   criterio «oro entre 0.4 y 0.7» necesita primero que exista gasto.

## 8. Qué hacer con este dato

- **No tocar precios todavía.** Con 8 misiones completadas no hay señal para
  calibrar.
- Priorizar **descubrimiento y utilidad del gasto** (#377 equipado visible,
  #375 repaso con pergaminos) antes que cualquier ajuste numérico.
- Aplicar `20261113010000` (hardening) y `20261113020000` (payments) para poder
  medir en la siguiente ventana.
- Volver a medir cuando haya al menos **una semana de uso real** y compras > 0.

## 9. Consultas usadas

```sql
-- conteos: REST con Prefer: count=exact sobre cada tabla
-- saldos: select total_gold, total_gems, fragments, xp_points from user_language_profiles
-- catálogo: select id, price_gold, price_gems, required_level from cosmetic_catalog
-- misiones: select status, is_reward_claimed from mission_instances
-- exploit: select count(*) from mission_instances where reward_multiplier > 2
```
