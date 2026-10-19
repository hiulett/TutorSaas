# Pruebas de compra (Google Play + RevenueCat)

Procedimiento para validar el flujo de suscripciones en la app Android.

---

## 1. Preparación (una sola vez)

| Paso | Dónde | Detalle |
|---|---|---|
| Alta como *license tester* | Play Console → Configuración → Pruebas de licencia | La **misma** cuenta de Google que usarás para comprar |
| Suscripciones activas | Play Console → Monetizar → Productos → Suscripciones | `dungeonsspeak_noble_*`, `_realeza_*`, `_divino_*` |
| Service account conectado | RevenueCat → Project settings → Integraciones | `play_service_account_credentials_configured: true` |
| Webhook apuntando a la app correcta | RevenueCat → Integraciones → Webhooks | `app_id = app69c16b2a83` (Play), no Test Store |
| Secreto del webhook | Supabase → Edge Functions → Secrets | `REVENUECAT_AUTH_TOKEN` idéntico al del dashboard |
| Secreto de reconciliación | Supabase → Secrets | `REVENUECAT_SECRET_KEY` (`sk_…`) |

Sin la cuenta en **ambas** listas (testers de la pista y pruebas de licencia) el
diálogo de Play muestra un error en vez de la etiqueta **[TEST]**.

---

## 2. Instalación

1. Sube el `.aab` a **internal testing**.
2. Añade la cuenta como tester de la pista.
3. Instala **desde el enlace de Play**, no por `adb`.

Un APK sideloaded con el *upload key* suele funcionar para license testers, pero
solo si esa versión existe en alguna pista. Es la causa más común de
`ITEM_UNAVAILABLE`.

---

## 3. Matriz de casos

| # | Caso | Cómo | Resultado esperado |
|---|---|---|---|
| 1 | Compra mensual | Paywall → plan → pagar con tarjeta de prueba | Diálogo con **[TEST]**; entitlement activo; `user_subscriptions.plan_id` correcto en <30 s |
| 2 | Compra anual | Igual con `_yearly` | `billing_cycle = annual`, `period_end ≈ +1 año` |
| 3 | Renovación | Los tests de Play renuevan cada ~5 min | `RENEWAL` en logs; el maná se repone una sola vez |
| 4 | Cancelación | Play → Suscripciones → Cancelar | Acceso **se mantiene** hasta `period_end`; `cancel_at_period_end = true` |
| 5 | Reactivación | Cancelar y luego reactivar | `cancel_at_period_end = false` |
| 6 | Expiración | Dejar vencer la suscripción de prueba | Tras `EXPIRATION`: `plan_id = plebeyo`, `isUserPremium = false` |
| 7 | Restaurar | Desinstalar → reinstalar → «RESTAURAR» | Recupera el plan sin volver a pagar |
| 8 | Cambio de cuenta | Cerrar sesión → otra cuenta Supabase → comprar | El `appUserID` de RevenueCat cambia (`Purchases.logIn`) |
| 9 | Sin red | Modo avión → abrir paywall | Error con reintento; la app no se cierra |
| 10 | Webhook caído | Simular fallo del endpoint | Al reabrir la app, `sync-entitlement` corrige el plan |

---

## 4. Dónde mirar

| Qué | Dónde |
|---|---|
| Evento recibido | Supabase → Logs → `function_logs` (busca `revenuecat-webhook`) |
| Idempotencia | `select * from revenuecat_events order by processed_at desc` |
| Estado del plan | `select plan_id, status, rc_expires_at, last_event_id from user_subscriptions where user_id = '<uid>'` |
| Maná | `select amount, type, created_at from mana_transactions where user_id = '<uid>' order by created_at desc` |
| Cliente RevenueCat | `select * from customers` en el dashboard (busca el uid de Supabase) |

---

## 5. Runbook de incidencias

### Compra cobrada pero sin plan

1. RevenueCat → Customers → buscar el uid de Supabase.
2. Si el entitlement está activo y la tabla no:
   - la app lo corrige al abrirse (`sync-entitlement`), o
   - forzar: ejecutar la RPC `sync_entitlement(...)` con `p_service_role`.
3. Si el entitlement tampoco existe: el problema es del webhook o de Play.

### Webhook caído

```
GET https://<ref>.supabase.co/functions/v1/revenuecat-webhook  → {"received":true}
POST sin token                                                  → 401
```

Si `GET` falla, redeplegar. Si `POST` con el token correcto devuelve 401, el
`REVENUECAT_AUTH_TOKEN` de Supabase y el del dashboard no coinciden.

### Doble cobro o doble maná

1. Revisar `revenuecat_events`: si hay dos ids distintos para el mismo periodo,
   es un reintento sin idempotencia (no debería ocurrir desde #71).
2. Comparar `mana_transactions` con `purchased_at_ms` del evento.

### El usuario ve el precio equivocado

El precio mostrado debe venir del offering de RevenueCat (precio localizado de
Play), no de `subscription_plans` (#70).

---

## 6. Limpieza

Las compras de prueba quedan en producción. Para no ensuciar métricas:

```sql
-- localizar la cuenta de prueba
select id, email from auth.users where email like 'test%@mailinator.com';
```

Borrarlas implica eliminar en cascada: `user_subscriptions`, `conversations`,
`messages`, `mana_transactions`, `user_language_profiles` y el usuario de
`auth.users`.
