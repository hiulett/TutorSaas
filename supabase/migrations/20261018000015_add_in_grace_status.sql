-- Issue #71: estado de gracia para BILLING_ISSUE de Google Play.
--
-- `subscription_status` solo tenía: active, cancelled, expired, trial.
-- Cuando Play no puede cobrar, concede un periodo de gracia en el que el
-- usuario conserva el acceso. Sin un estado propio no había forma de
-- representarlo sin marcarlo como `active` (que ocultaría el problema).
--
-- `isPremiumSubscription()` ya contempla `in_grace` como premium.

alter type public.subscription_status add value if not exists 'in_grace';
