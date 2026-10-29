# Propuestas P-44 a P-48 (con datos reales)

> Datos leídos de producción el 29-oct-2026 (`subscription_plans`, `ai_action_costs`,
> `ai_usage_logs`). Los precios reales de Play no se consultaron en esta pasada.

## Estado real del catálogo

| Plan | Precio/mes | Anual | Maná/mes | Min. audio | Activo |
|---|---|---|---|---|---|
| PLEBEYO | $0 | — | 3 000 (tope diario 200) | 30 | sí |
| NOBLE | $4.99 | $53.99 | 17 000 | 300 | sí |
| REALEZA | $9.99 | $107.99 | 20 500 | 1 200 | sí |
| DIVINO | $12.99 | $132.99 | 25 500 | 2 000 | sí |
| free/monthly/annual/lifetime | — | — | — | — | **no** (legado) |

Costes de maná por acción: `free_chat_turn 8` · `dungeon_turn 12` · `oracle_turn 15`
· `oracle_eval 30` · `lesson_generation 100` · `correction_turn 3` · `vocabulary_curation 2`.

## P-44 · Valor premium diferenciado

**Problema medido:** NOBLE, REALEZA y DIVINO tienen **la misma lista de features**;
solo cambian maná y minutos de audio. Y el precio por 1 000 de maná es **mejor en el
plan barato**:

| Plan | $ por 1 000 de maná |
|---|---|
| NOBLE | **$0.29** |
| REALEZA | $0.49 |
| DIVINO | $0.51 |

Es decir: hoy el usuario racional compra NOBLE; los otros dos no se justifican con
números.

**Opciones**
1. **Reequilibrar cantidades** para que el $/maná mejore al subir (p. ej. 17k / 26k / 40k).
2. **Diferenciar por capacidad, no por volumen** (lo que el usuario percibe): exámenes
   de jefe por semana, lecciones de refuerzo/mes, historial, “Modo Boss”, títulos y
   cosméticos exclusivos, prioridad de voz en salas.
3. **Retirar DIVINO** hasta que exista algo que lo justifique (menos SKUs, menos soporte).

**Recomendación:** 2 + 1 (features reales primero, cantidades después). Sin features,
triplicar SKUs solo añade confusión y carga de soporte.

## P-45 · Prueba gratuita y gestión de planes

- En la base **no hay trial**: la prueba debe configurarse en Play Console (7 días en
  NOBLE) y reflejarse en RevenueCat.
- La app **sí** sabe leer el entitlement (`sync-entitlement`), pero no gestiona
  cancelaciones ni cambios de plan dentro de la app.
- **Recomendación:** trial de 7 días solo en NOBLE (el plan que ya gana por precio),
  botón “Gestionar suscripción” que abra Play (`https://play.google.com/store/account/subscriptions`),
  y un aviso claro antes de que termine el trial. Requiere acción en Play Console.

## P-46 · Compra de maná opcional

- Ya existen el saldo comprado (`purchased_mana_balance`), los elixires (`mana_items`)
  y la tienda; lo que falta es un **producto consumible de Play**.
- **Recomendación:** no abrir consumibles hasta tener datos de uso real: el turno de
  gracia y el tope diario ya cubren el caso “me quedé a medias”. Si se abre, empezar por
  **un solo SKU** (p. ej. 2 000 de maná) con conversión clara a turnos (“≈166 turnos”).

## P-47 · Análisis de margen

Con los datos actuales:

- Coste medido por turno de mazmorra: **≈ $0.00002** (5 llamadas reales).
- Coste medido por `oracle_eval`: **≈ $0.0008** (3 llamadas reales).
- Peor caso teórico de NOBLE: 17 000 de maná gastados **solo** en `oracle_eval`
  (30 cada uno) = 566 evaluaciones × $0.0008 ≈ **$0.45/mes**.
- Sobre $4.99: margen bruto **≈ 91 %** antes de la comisión de Play; con 15 % de Play
  (≈ $0.75) queda **≈ 76 %**.

**Conclusión provisional:** el coste de IA **no** es el riesgo del negocio; lo son la
comisión de la tienda, el soporte y los reembolsos. La muestra es de **8 llamadas**:
hay que repetir el cálculo con ≥ 2 semanas de uso real (`ai_cost_by_session`).

**Falta para cerrarlo:** precios reales por país de Play Console y coste de LiveKit
(salas de voz), que no están en Supabase.

## P-48 · Decisión sobre gremio y salas

- `livekit-token` existe y funciona; las misiones de gremio no tienen flujo (13
  plantillas `secondary` nunca se asignan).
- **Recomendación:** conservar **salas de voz** (valor social real, ya pagado), y
  **ocultar** las misiones de gremio hasta que exista un evento programado validado
  (el criterio de #84). No borrar tablas.
