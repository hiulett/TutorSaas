# Trial de 7 días en NOBLE (P-45 / #130)

> El trial **no se crea desde el repositorio**: vive en Google Play Console y se
> refleja en RevenueCat. Este runbook es el paso a paso, cómo comprobarlo y qué
> hace la app en cada caso.

## Regla de honestidad

`subscription_plans.trial_days` es **la única fuente** que usa la app para
anunciar la prueba (`lib/features/subscription/`). Si Play no ofrece el trial,
el valor debe ser `0` y la app no muestra ninguna promesa. Si Play lo ofrece y
la base dice `0`, el usuario no ve el trial aunque lo tenga: se pierde venta,
pero nunca se miente.

Estado actual (aplicado en `20261030005704_plans_capabilities_p44_p45`):

| Plan | `trial_days` | Precio |
|---|---|---|
| `plebeyo` | 0 | $0.00 |
| `noble` | **7** | $4.99 |
| `realeza` | 0 | $9.99 |
| `divino` | 0 (inactivo) | — |

## 1. Play Console

1. Play Console → app **Dungeon of English** → *Monetizar con Play* →
   *Productos* → *Suscripciones*.
2. Abre la suscripción `dungeonsspeak_noble_monthly` (plan base mensual,
   $4.99). **No** añadas el trial al producto anual: la decisión es solo NOBLE
   mensual.
3. En el plan base → *Ofertas* → **Añadir oferta**:
   - Tipo: **Prueba gratuita**.
   - Duración: **7 días** (`P1W`).
   - Elegibilidad: **Nuevos suscriptores** (no "todos los usuarios": repetir
     trial en cada reinstalación no es el objetivo).
   - Fases: una sola fase de 7 días a $0 y después el precio base.
4. Guarda y **activa** la oferta. Una oferta en borrador no viaja a la tienda.
5. Confirma que el SKU `dungeonsspeak_realeza_monthly` **no** tiene oferta de
   prueba.

## 2. RevenueCat

1. RevenueCat → *Product catalog* → *Products*: confirma que
   `dungeonsspeak_noble_monthly:monthly` está importado y **sin** el aviso de
   "producto no encontrado".
2. *Entitlements* → `DungeonsSpeak Pro`: el producto NOBLE mensual debe estar
   adjunto.
3. *Offerings* → `default`: el paquete `$rc_monthly` apunta a NOBLE mensual
   (es el que presenta el paywall nativo).
4. En el detalle del producto, RevenueCat debe mostrar la **fase de prueba**
   importada de Play. Si no aparece, Play todavía no la publicó: vuelve al
   paso 1.5 y espera la propagación (puede tardar horas).
5. *Webhooks*: el endpoint `revenuecat-webhook` ya está configurado; el
   entitlement y el trial llegan por los mismos eventos
   (`INITIAL_PURCHASE`, `RENEWAL`, `EXPIRATION`).

## 3. Base de datos

Si el trial de Play **todavía no** está activo, apaga la promesa en la app:

```sql
-- Solo si Play NO ofrece el trial.
update public.subscription_plans set trial_days = 0 where id = 'noble';
```

Cuando Play y RevenueCat estén listos:

```sql
update public.subscription_plans set trial_days = 7 where id = 'noble';
```

Comprobación (solo lectura):

```sql
select id, is_active, trial_days, weekly_report_weeks, price
  from public.subscription_plans
 where is_active
 order by order_index;
```

`sync_entitlement` no necesita cambios: el trial llega como suscripción activa
con `expires_at` = fin de la prueba, así que `user_subscriptions.period_end`
queda en la fecha de cobro y `premium_status.dart` lo trata como premium.

## 4. Comprobación en la app

1. Compila con la cuenta de *license tester* de Play (las pruebas internas no
   cobran y sí muestran el trial).
2. Abre el paywall (`/paywall`): la tarjeta de NOBLE debe mostrar
   **«7 días gratis, luego $4.99/mes»**. Si no aparece, `trial_days` es 0.
3. Compra el trial y verifica en la base:

```sql
select us.plan_id, us.status, us.period_end, us.rc_product_id,
       us.rc_expires_at, us.store
  from public.user_subscriptions us
 where us.user_id = '<uuid>';
```

Esperado: `plan_id = 'noble'`, `status = 'active'`, `period_end` ≈ hoy + 7
días, `rc_product_id` con `noble`.

4. Cancela el trial desde Play (Cuenta → Suscripciones) y comprueba que
   `sync-entitlement` sigue devolviendo premium hasta `period_end`.
5. Deja que expire: el webhook (`EXPIRATION`) devuelve el usuario a
   `plebeyo`/`expired` y el paywall vuelve a ofrecer el trial (si Play lo
   permite para ese usuario).

## 5. Rollback

```sql
update public.subscription_plans set trial_days = 0 where id = 'noble';
```

La app deja de anunciar el trial al instante (lee la tabla al abrir el
paywall). En Play, desactiva la oferta; los trials ya empezados no se cortan.

## 6. Pendiente (no cubierto por este cambio)

- **Aviso antes del cobro.** P-45 pide un recordatorio previo al fin del
  trial. Requiere una notificación programada a `period_end - 1 día`; el
  sistema de notificaciones locales existe (`notifications`) pero necesita
  saber que la suscripción es un trial (hoy no se distingue de una compra).
  Queda como issue aparte.
- Precio por país: la app muestra el precio de `subscription_plans` (USD). El
  paywall nativo ya muestra el precio local de Play; la tarjeta comparativa no
  lo traduce.
