# Aplicar secretos al revenuecat-webhook (ejecutar manualmente)

Configura la Edge Function `revenuecat-webhook` del proyecto
`sipiumfdpvnszthykyog` para recibir eventos de RevenueCat de la app
**DungeonsSpeak**.

## Paso 0 — Requisitos

```sh
supabase login   # access token de https://supabase.com/dashboard/account/tokens
```

## Paso 1 — Setear secretos

```sh
supabase secrets set \
  REVENUECAT_AUTH_TOKEN=<tu-auth-token-de-revenuecat> \
  SUPABASE_URL=https://sipiumfdpvnszthykyog.supabase.co \
  SUPABASE_SERVICE_ROLE_KEY=<tu-service-role-key> \
  --project-ref sipiumfdpvnszthykyog
```

> `REVENUECAT_AUTH_TOKEN` lo defines tú (es el "Authorization Token" del
> endpoint de webhooks de RevenueCat). Debe coincidir en ambos lados.
> `SUPABASE_SERVICE_ROLE_KEY` es el rol de servicio (¡nunca en el cliente!).

## Paso 2 — Desplegar la función

```sh
supabase functions deploy revenuecat-webhook --project-ref sipiumfdpvnszthykyog
```

## Paso 3 — Crear el endpoint en RevenueCat

En RevenueCat Dashboard → Settings → Integrations → **Webhooks**:

- **URL**: `https://sipiumfdpvnszthykyog.functions.supabase.co/revenuecat-webhook`
- **Authorization header**: `Bearer <REVENUECAT_AUTH_TOKEN>`
- Suscribirse a los eventos:
  - `INITIAL_PURCHASE`, `RENEWAL`, `PRODUCT_CHANGE`, `TRANSFER`,
    `UNCANCELLATION`, `CANCELLATION`, `EXPIRATION`

RevenueCat valida el endpoint con un `GET` antes de guardarlo (la función
responde `{"received":true}` a GET).

## Paso 4 — API key pública en el build (cliente)

La key pública de RevenueCat se inyecta en el build. En `config.json`
(no versionado):

```json
{
  "REVENUECAT_API_KEY": "appl_..._YOUR_PUBLIC_KEY"
}
```

Compilar con:

```sh
flutter build apk --release --dart-define-from-file=config.json
```

El default del código es la **test key** (`test_...`) — solo para dev/tests.

## Productos y entitlement (DungeonsSpeak)

**Modelo de negocio: 2 estamentos × 2 ciclos = 4 productos. NO hay Lifetime**
(no cubre el costo recurrente de la IA). Un único entitlement `DungeonsSpeak_Pro`.

Crea en RevenueCat Dashboard → **Products** (Test mode):

| Store product ID | Estamento | Ciclo | Package ID (RC) | Plan BD | Maná |
|---|---|---|---|---|---|
| `dungeonsspeak_noble_monthly` | NOBLE | Mensual | `$noble_monthly` | `noble` | 18,000 |
| `dungeonsspeak_noble_yearly` | NOBLE | Anual | `$noble_yearly` | `noble` | 18,000 |
| `dungeonsspeak_realeza_monthly` | REALEZA | Mensual | `$realeza_monthly` | `realeza` | 72,000 |
| `dungeonsspeak_realeza_yearly` | REALEZA | Anual | `$realeza_yearly` | `realeza` | 72,000 |

Asigna los 4 products al **entitlement** `DungeonsSpeak_Pro` (el único).

Configura un **Offering** principal ("Current") con los 4 packages. El paywall
nativo de RevenueCat los agrupa en 2 tarjetas (NOBLE y REALEZA), cada una con su
ciclo mensual/anual y el descuento anual.

> El webhook deriva el plan y el ciclo desde el `product_id`:
> `...realeza...` → plan `realeza`; `...noble...` → plan `noble`;
> `...yearly...` → ciclo `annual`; si no → `monthly`.
> Renueva el maná con `renew_mana_cycle` usando el `mana_allowance` del plan.

## Customer Center (opcional pero recomendado)

Para habilitar "Gestionar suscripción" (cancelar/cambiar/reembolsar) desde la
app, activa **Customer Center** en RevenueCat Dashboard → Settings → Customer
Center, y configura los modos (Manage Subscriptions, Restore, Refund) según tu
política. La app lo presenta con `RevenueCatUI.presentCustomerCenter()`.

## 🧪 Pruebas en sandbox (sin publicar en producción)

La app usa por defecto la **test key** de RevenueCat (`test_...`), así que el
SDK ya apunta al entorno de pruebas. Para probar el flujo completo de compra:

### 1. Configuración previa en RevenueCat (modo test)

En RevenueCat Dashboard → **Products** (asegúrate de estar en **Test mode**):

1. Añade los 4 products (`dungeonsspeak_noble_monthly`, `dungeonsspeak_noble_yearly`,
   `dungeonsspeak_realeza_monthly`, `dungeonsspeak_realeza_yearly`) con sus IDs de
   producto de Google Play / App Store. En modo test no necesitan existir aún en los
   stores para que RevenueCat los reconozca.
2. Crea el entitlement `DungeonsSpeak_Pro` y asigna los 4 products.
3. Crea un Offering **"Current"** con los 4 packages.

### 2. Android (Google Play Billing sandbox)

1. Crea un **Internal Testing track** en Google Play Console (no requiere
   revisión de Google; es privado).
2. Sube la app (`flutter build apk --release` firmado con debug sirve para
   internal testing) o usa `flutter install` con el APK debug.
3. Añade tu cuenta de Gmail como **tester** en el grupo de internal testing.
4. Para probar suscripciones: Google Play Console → **Monetización → Productos
   → Suscripciones** → crea las suscripciones con los mismos IDs y un **precio
   de sandbox** (p. ej. $0.99) y acepta el "consentimiento para precios".
   En **Licencias → License testing** añade tu cuenta como tester.
5. Instala la app desde el track interno (o con el APK) e inicia la compra.

### 3. iOS (App Store sandbox)

1. En **App Store Connect** crea los productos in-app (Auto-Renewable
   Subscription) con los IDs `dungeonsspeak_noble_monthly`,
   `dungeonsspeak_noble_yearly`, `dungeonsspeak_realeza_monthly`,
   `dungeonsspeak_realeza_yearly` y un precio sandbox.
2. Crea una **cuenta Sandbox Apple ID** (App Store Connect → Users → Sandbox
   testers).
3. En el dispositivo: Cierra sesión de tu Apple ID real y usa la cuenta sandbox
   al comprar. Las compras sandbox **no cobran**.
4. Configura el esquema de Xcode para el `Bundle ID` correcto y ejecuta
   `flutter run` en el simulador/dispositivo.

### 4. Probar desde la app

```sh
# Android debug (usa la test key por defecto)
flutter run -d <device>

# iOS
flutter run -d <simulator>
```

Abre `/paywall` → pulsa "SUSCRIBIRSE" → se presenta el paywall nativo con los
3 packages → completa la compra sandbox.

### 5. Verificar que llegó al backend

Tras la compra, el webhook `revenuecat-webhook` debe activar el plan:

```sh
# Tabla user_subscriptions (debe aparecer plan_id noble/realeza, status active)
curl -s "https://sipiumfdpvnszthykyog.supabase.co/rest/v1/user_subscriptions?user_id=eq.<UID>" \
  -H "apikey: <SERVICE_ROLE_KEY>" -H "Authorization: Bearer <SERVICE_ROLE_KEY>"

# Maná renovado (renew_mana_cycle)
curl -s -X POST "https://sipiumfdpvnszthykyog.supabase.co/rest/v1/rpc/get_mana_state" \
  -H "apikey: <ANON_KEY>" -H "Authorization: Bearer <ANON_KEY>" \
  -H "Content-Type: application/json" -d '{"p_user_id":"<UID>"}'
```

> ⚠️ En modo sandbox, los eventos de RevenueCat llegan con `test: true`.
> El webhook los procesa igual (activa el plan). Para **no ensuciar la BD** de
> producción en pruebas, se puede filtrar `event['test']` si se prefiere
> (ver `revenuecat-webhook/index.ts`).

## Verificación

```sh
supabase secrets list --project-ref sipiumfdpvnszthykyog
curl -s https://sipiumfdpvnszthykyog.functions.supabase.co/revenuecat-webhook
# → {"received":true}
```
