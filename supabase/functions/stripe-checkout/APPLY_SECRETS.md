# Aplicar secretos de Stripe (edge functions)

Las funciones `stripe-checkout` y `stripe-webhook` requieren estos secretos.
Se configuran una sola vez por proyecto:

```sh
supabase secrets set --project-ref sipiumfdpvnszthykyog \
  STRIPE_SECRET_KEY=sk_live_... \
  STRIPE_WEBHOOK_SECRET=whsec_... \
  SUPABASE_URL=https://sipiumfdpvnszthykyog.supabase.co \
  SUPABASE_SERVICE_ROLE_KEY=... \
  PUBLIC_APP_URL=https://tu-dominio.com
```

> `SUPABASE_SERVICE_ROLE_KEY` es el rol de servicio (¡nunca debe ir en el cliente!).
> `PUBLIC_APP_URL` es el dominio de la web/landing al que redirige Stripe tras pagar
> (`/checkout-success` y `/checkout-cancel`).

## Webhook en Stripe

En el dashboard de Stripe → Developers → Webhooks, crea un endpoint:
`https://sipiumfdpvnszthykyog.functions.supabase.co/stripe-webhook`
Suscríbelo a los eventos:
- `checkout.session.completed`
- `customer.subscription.updated`
- `customer.subscription.deleted`

Usa ese secreto del webhook como `STRIPE_WEBHOOK_SECRET`.

## Precios de suscripción en Stripe

Cada plan en `subscription_plans` debe tener su Price de Stripe. Como cada tier
puede facturarse **mensual o anual**, se usan **dos precios por plan**:
- `stripe_price_id` → Price mensual recurrente.
- `stripe_price_annual_id` → Price anual recurrente (interval=year).

Edítalo desde `web_admin` o el SQL Editor:

```sql
-- Mensual
UPDATE subscription_plans SET stripe_price_id = 'price_...' WHERE id = 'noble';
UPDATE subscription_plans SET stripe_price_id = 'price_...' WHERE id = 'realeza';
-- Anual
UPDATE subscription_plans SET stripe_price_annual_id = 'price_...' WHERE id = 'noble';
UPDATE subscription_plans SET stripe_price_annual_id = 'price_...' WHERE id = 'realeza';
```
