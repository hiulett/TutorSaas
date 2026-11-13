-- Ingresos reales en `payments` (#388).
--
-- Hasta ahora NINGUNA Edge Function escribia en `payments`: los ingresos vivian
-- solo en Play Console y RevenueCat, asi que ARPU/ARPPU no se podian calcular
-- desde Supabase (ver docs/economy/MONETIZATION_ANALYSIS.md).
--
-- Esta migracion prepara la tabla para que `revenuecat-webhook` registre compra,
-- renovacion y reembolso de forma idempotente por `event.id`.

alter table public.payments
  add column if not exists revenuecat_event_id text,
  add column if not exists store_transaction_id text,
  add column if not exists product_id text,
  add column if not exists amount numeric(10, 2);

-- Idempotencia: un mismo evento no puede generar dos pagos.
-- (En Postgres los NULL no colisionan en un indice unico, asi que las filas
-- antiguas sin `revenuecat_event_id` no dan problema.)
create unique index if not exists ux_payments_revenuecat_event
  on public.payments (revenuecat_event_id);

create index if not exists idx_payments_created_at
  on public.payments (created_at desc);

comment on column public.payments.revenuecat_event_id is
  'Id del evento de RevenueCat que origino la fila (idempotencia, #388).';
comment on column public.payments.store_transaction_id is
  'transaction_id de la tienda (Play) para conciliar reembolsos y disputas.';
comment on column public.payments.amount is
  'Importe en la moneda local de la compra (`currency`). `amount_usd` solo se rellena cuando la tienda informa USD.';
comment on column public.payments.stripe_payment_id is
  'LEGADO: Stripe se elimino en oct-2026. No escribir; pendiente de borrar cuando no queden filas.';

-- Verificacion (solo lectura):
-- select count(*), min(created_at), max(created_at) from public.payments;
-- select status, count(*) from public.payments group by status;
-- select count(*) from public.payments where revenuecat_event_id is null;
