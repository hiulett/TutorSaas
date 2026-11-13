# Métricas, KPIs y dashboard de economía

_Auditoría económica · Fase 13. Definición de medición._

> Regla que ordena este documento: **toda métrica económica necesita una métrica
> de daño educativo al lado**. Si el gasto sube y las lecciones completadas
> bajan, el sistema está funcionando mal aunque el dashboard esté verde.

---

## 1. Qué se puede medir hoy (verificado)

| Fuente | Qué aporta | Estado |
|---|---|---|
| `currency_ledger` | Todo movimiento de oro, gemas y fragmentos con `reason`, `ref_key`, `balance_after` | ✅ Listo |
| Vista `v_economy_flow` | `earned` / `spent` por moneda y motivo | ✅ Existe |
| `reward_history` | Recompensas de misión (XP, gemas, item) | ✅ |
| `mana_transactions` | Consumo de maná por turno | ✅ |
| `ai_usage_logs` | Tokens y modelo por llamada | ✅ |
| `get_economy_wallet` | `earned`/`spent` por usuario (lo mismo que la vista) | ✅ |
| `analytics_taxonomy.dart` + `retention_analytics.dart` | Taxonomía de eventos de producto | ⚠️ Existe, cobertura no verificada |
| `payments` | Ingresos reales | ❌ **Nadie la escribe** |
| `session_reward_ledger` | Ingresos de sesión | ✅ |

## 2. KPIs de producto

| KPI | Definición | Fuente | Frecuencia |
|---|---|---|---|
| DAU / MAU | Usuarios con al menos una sesión/actividad | eventos de sesión | Diaria |
| Retención D1 / D7 / D30 | % que vuelve tras registro | analítica de sesión | Cohortes |
| Sesiones por usuario/semana | Media | sesiones | Semanal |
| Lecciones completadas / usuario | Objetivos cerrados | `lesson_progress` / sesión | Semanal |
| Racha media y % con racha ≥7 | `player_streaks` | Diaria | |
| Conversión a suscripción | Suscritos / activos | `user_subscriptions` | Semanal |
| Trial → pago | Trials que pagan / trials iniciados | RevenueCat | Semanal |
| Churn mensual | Bajas / suscritos mes anterior | Play/RevenueCat + `user_subscriptions` | Mensual |
| ARPU | Ingresos / usuarios activos | **externo** (Play/RevenueCat) | Mensual |
| ARPPU | Ingresos / usuarios de pago | **externo** | Mensual |
| LTV | ARPPU × vida media | derivado | Trimestral |

## 3. KPIs de economía virtual

| KPI | Fórmula | Umbral de alerta |
|---|---|---|
| **Sink ratio por moneda** | `Σ spent / Σ earned` | Oro **< 0.2** = precios altos; **> 0.8** = catálogo corto |
| Monedas generadas / usuario activo | `Σ earned / DAU` | Salto > 50 % semana a semana = fuente desequilibrada |
| Monedas gastadas / usuario activo | `Σ spent / DAU` | Caída sostenida = sumidero agotado |
| Saldo medio y mediana | `total_gold`, `total_gems`, `fragments` | Mediana creciente sin gasto = inflación |
| % usuarios con saldo > 5× precio medio | stock acumulado | > 20 % = el catálogo no absorbe |
| Compradores de cosmético / activos | `player_inventory` / DAU | < 5 % = sumidero inalcanzable o invisible |
| Items vendidos vs items equipados | `player_inventory` vs uso | Brecha grande = se compra y no se usa |
| Time-to-first-purchase | horas desde registro a primera compra | > 72 h = entrada cara o poco visible |
| Gemas ganadas vs gemas gastadas | `Σ` por moneda | Ratio < 0.2 = gemas sin uso |
| Freezes comprados / perdidas de racha evitadas | `reason='streak_freeze'` | Sirve para valorar el precio de 30 |

Consultas base (ya documentadas en `ECONOMY_SINKS.md` §4):

```sql
select currency, sum(earned) earned, sum(spent) spent,
       round(sum(spent)::numeric / nullif(sum(earned),0), 3) sink_ratio
  from public.v_economy_flow
 group by currency;
```

## 4. KPIs de integridad (los que faltan y son urgentes)

| KPI | Qué detecta | Alerta |
|---|---|---|
| `reward_multiplier` > 2 en `mission_instances` | Exploit F-1 | **cualquier fila** |
| Recompensas reclamadas sin `reward_history` previo de actividad | Auto-completado F-2 | > 0 |
| `currency_ledger` sin `balance_after` coherente con el saldo actual | Desincronización | > 0 |
| Items vendidos cuyo `item_code` no tiene consumidor en código | Items muertos | > 0 |
| Compras con `ref_key` duplicada | Fallo de idempotencia | > 0 |

Estas cinco son **consultas de solo lectura** y deberían estar en el checklist de
release.

## 5. Guardarraíles educativos (no negociables)

| Métrica | Por qué |
|---|---|
| Lecciones iniciadas vs completadas (abandono) | El maná no debe expulsar a mitad de misión |
| Duración media de sesión | Sesiones que se alargan por grind, no por práctica = mala señal |
| Objetivos cerrados por sesión | Si bajan mientras sube el tiempo, el diseño empuja a farmear |
| Diferencia de progreso gratuito vs premium | La suscripción debe dar capacidad, no ventaja |
| % de sesiones con corrección aplicada | La corrección es el valor educativo real |
| Palabras nuevas / semana | Indicador de aprendizaje, no de actividad |
| Errores repetidos tras corrección | Calidad del feedback, no volumen |

**Regla de decisión:** si una iniciativa económica sube ingresos pero baja
lecciones completadas o sube el abandono, se revierte. No se negocia.

## 6. Dashboard propuesto

Una pantalla (admin o notebook) con cuatro bloques:

1. **Dinero**: MRR, conversión, churn, ARPPU (fuera de Supabase hoy).
2. **Flujo**: `sink_ratio` por moneda, generado/gastado por usuario, saldo medio.
3. **Catálogo**: items vendidos, items equipados, items muertos, time-to-first-purchase.
4. **Aprendizaje**: lecciones completadas, abandono, palabras nuevas, correcciones.

Lectura saludable: bloque 2 con ratios en banda 0.4–0.7, bloque 3 con
compradores > 5 % y equipado > 50 % de lo comprado, bloque 4 estable o creciente.

## 7. Qué recopilar antes de cualquier decisión de precio

1. `sink_ratio` de las tres monedas (hoy desconocido).
2. Saldo medio y mediana por cohorte de antigüedad.
3. % de activos que abren la tienda y % que compran.
4. Conversión trial → pago y churn mensual.
5. Tiempo hasta la primera compra.

Sin estos cinco, cualquier ajuste es una corazonada.
