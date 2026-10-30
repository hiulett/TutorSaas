# Propuestas P-44 a P-48 (con datos reales)

> Datos leídos de producción el 29-oct-2026 (`subscription_plans`, `ai_action_costs`,
> `ai_usage_logs`). Los precios reales de Play no se consultaron en esta pasada.
>
> **P-44 (#129) y P-45 (#130) aplicados el 30-oct-2026** en
> `20261030005704_plans_capabilities_p44_p45.sql`: DIVINO retirado
> (`is_active = false`) y diferenciación por capacidad (historial del informe +
> títulos exclusivos). Ver [PRODUCT.md](PRODUCT.md) y
> [runbooks/TRIAL_NOBLE_P45.md](runbooks/TRIAL_NOBLE_P45.md). Lo que falta es
> configuración de Play Console (trial), no código.

## Estado real del catálogo

> Tras P-44: **activos = PLEBEYO, NOBLE, REALEZA**. DIVINO sigue en la tabla con
> `is_active = false` (histórico), no se borra.

| Plan | Precio/mes | Anual | Maná/mes | Min. audio | Activo |
|---|---|---|---|---|---|
| PLEBEYO | $0 | — | 3 000 (tope diario 200) | 30 | sí |
| NOBLE | $4.99 | $53.99 | 17 000 | 300 | sí |
| REALEZA | $9.99 | $107.99 | 20 500 | 1 200 | sí |
| DIVINO | $12.99 | $132.99 | 25 500 | 2 000 | **no** (retirado) |
| free/monthly/annual/lifetime | — | — | — | — | **no** (legado) |

Costes de maná por acción: `free_chat_turn 8` · `dungeon_turn 12` · `oracle_turn 15`
· `oracle_eval 30` · `lesson_generation 100` · `vocabulary_curation 2` ·
`correction_turn 0` (gratuita desde P-40-c/#222; fila inactiva en `ai_action_costs`).

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

**Decisión aplicada (30-oct-2026):** 2 + 3. DIVINO fuera y dos palancas reales,
gateadas en servidor:

| Capacidad | PLEBEYO | NOBLE | REALEZA | Enforcement |
|---|---|---|---|---|
| Semanas en el informe semanal | 1 | 4 | 52 | `get_weekly_report` (`weekly_report_weeks`) |
| Cosméticos exclusivos | — | — | 2 (título + aura) | `purchase_cosmetic` / `craft_cosmetic` (`min_plan`) |

El paywall pinta solo `is_active = true` y las capacidades salen de la tabla
(maná, semanas de historial, nº de exclusivos del plan).

## P-45 · Prueba gratuita y gestión de planes

- En la base **no hay trial**: la prueba debe configurarse en Play Console (7 días en
  NOBLE) y reflejarse en RevenueCat.
- La app **sí** sabe leer el entitlement (`sync-entitlement`), pero no gestiona
  cancelaciones ni cambios de plan dentro de la app.
- **Recomendación:** trial de 7 días solo en NOBLE (el plan que ya gana por precio),
  botón “Gestionar suscripción” que abra Play (`https://play.google.com/store/account/subscriptions`),
  y un aviso claro antes de que termine el trial. Requiere acción en Play Console.
- **Aplicado (30-oct-2026):** `subscription_plans.trial_days` (NOBLE = 7, resto 0) y el
  paywall muestra «7 días gratis, luego $4.99/mes» **solo** si el plan tiene trial.
  La app no promete nada mientras la base diga 0. Falta configurar la oferta en Play
  Console/RevenueCat: [runbooks/TRIAL_NOBLE_P45.md](runbooks/TRIAL_NOBLE_P45.md).
  El recordatorio previo al cobro sigue pendiente (requiere distinguir trial en
  `user_subscriptions`).

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
