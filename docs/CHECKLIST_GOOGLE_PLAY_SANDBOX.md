# Checklist — Salir a pruebas en Google Play (sandbox + RevenueCat)

Estado al momento: **Play Console en validación de datos** · **Cuenta RevenueCat creada** ·
**SDK RevenueCat integrado en la app** (paywall nativo + entitlement + Customer Center) ·
**RevenueCat configurado vía API (products/entitlement/offering 2×2)**.

Leyenda de columnas:
- **App** = trabajo sobre el código del proyecto (lo hago yo/IA).
- **Tú** = acciones en dashboards (Play Console, RevenueCat, Supabase) que solo tú puedes hacer.
- **Mixta** = requiere coordinar ambos lados (p. ej. IDs de producto).

---

## 🔴 BLOQUEANTE para el ciclo completo (compra → plan activo)

| # | Tarea | App | Tú | Mixta | Estado |
|---|-------|-----|----|----|--------|
| 1 | Desplegar la edge function `revenuecat-webhook` en Supabase | ✅ (puedo hacer el deploy) | | | ⬜ |
| 2 | Setear secrets del webhook: `REVENUECAT_AUTH_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_URL` | ✅ (ejecuto `supabase secrets set`) | 🔑 me pasas el `REVENUECAT_AUTH_TOKEN` y el `SERVICE_ROLE_KEY` | | ⬜ |
| 3 | Crear el endpoint de webhook en RevenueCat Dashboard (URL + Authorization Bearer) | | ✅ | | ⬜ |
| 4 | Verificar que `noble`/`realeza` tienen `mana_allowance` correcto | ✅ (ya verificado: 18000/72000) | | | ✅ |

> Sin el webhook, la compra sandbox **se registra en RevenueCat pero no activa el plan ni renueva el maná** en Supabase. Para probar SOLO la UI de compra no es necesario.

---

## 📦 Configuración de productos (deben coincidir los IDs)

| # | Tarea | App | Tú | Mixta | Estado |
|---|-------|-----|----|----|--------|
| 5 | Definir IDs de producto canónicos (2×2, sin Lifetime): `dungeonsspeak_noble_monthly`, `dungeonsspeak_noble_yearly`, `dungeonsspeak_realeza_monthly`, `dungeonsspeak_realeza_yearly` | ✅ (webhook mapea por `product_id`: `realeza`→realeza, `noble`→noble, `yearly`→annual) | | ⚠️ **Deben ser idénticos** en Play Console y RevenueCat | ✅ |
| 6 | Crear las 4 suscripciones en Google Play Console (IDs del paso 5, precio sandbox ~$0.99-2.99) + aceptar consentimiento de precio | | ✅ | | ⬜ |
| 7 | Crear los 4 products en RevenueCat (Test mode) con los MISMOs IDs | ✅ (creados vía API v2) | | ⚠️ | ✅ |
| 8 | Crear el entitlement `DungeonsSpeak Pro` en RevenueCat y asignarle los 4 products | ✅ (existía + 4 products adjuntos vía API) | | | ✅ |
| 9 | Crear un Offering **"Current"** con los 4 packages (`noble_monthly`, `noble_yearly`, `realeza_monthly`, `realeza_yearly`) | ✅ (ofrng25d28afd63, is_current) | | | ✅ |
| 9b | Archivar los products viejos (`monthly`, `yearly`, `lifetime`) | ✅ (inactivos vía API) | | | ✅ |
| 9c | MCP de RevenueCat configurado en opencode (`~/.config/opencode/opencode.json`) | ✅ (requiere reiniciar opencode) | | | ✅ |

---

## 🚀 Publicación y testers (Google Play)

| # | Tarea | App | Tú | Mixta | Estado |
|---|-------|-----|----|----|--------|
| 10 | Terminar la **validación de datos** de la cuenta Play Console | | ✅ | | ⬜ |
| 11 | Crear la aplicación en Play Console con **ID de app**: `com.tutorsaas.tutorsaas` | | ✅ | | ⬜ |
| 12 | Compilar el APK para subir: `flutter build apk --release` | ✅ (compilado: `app-release.apk` 138MB) | | | ✅ |
| 13 | Subir el APK al track **Pruebas internas** (internal testing) | | ✅ | | ⬜ |
| 14 | Crear lista de **testers** y añadir tu Gmail | | ✅ | | ⬜ |
| 15 | Aceptar el enlace de tester desde el dispositivo (instalar la app) | | ✅ | | ⬜ |

---

## 📱 App (código) — revisado y listo

| # | Tarea | App | Estado |
|---|-------|-----|--------|
| 16 | `purchases_flutter` + `purchases_ui_flutter` instalados (v10.9.0) | ✅ | ✅ |
| 17 | Test key configurada por defecto (`test_pZvnwshDFcmtFESTyYwBSYFGdCN`) + `config.sample.json` actualizado | ✅ | ✅ |
| 18 | Paywall nativo de RevenueCat (`presentPaywall`) en `/paywall` | ✅ | ✅ |
| 19 | Entitlement checking: `DungeonsSpeak Pro` → `isPremiumProvider` | ✅ | ✅ |
| 20 | Customer Center (`presentCustomerCenter`) para gestionar suscripción | ✅ | ✅ |
| 21 | Manejo de customer info + purchases + errores (cancelación incluida) | ✅ | ✅ |
| 22 | APK release compila con el plugin nativo | ✅ | ✅ |
| 23 | Webhook `revenuecat-webhook` reescrito al modelo 2×2 (sin Lifetime) | ✅ | ✅ |

---

## 🧪 Pruebas (una vez todo arriba)

| # | Tarea | Estado |
|---|-------|--------|
| 24 | `flutter run -d <device>` → abrir `/paywall` → SUSCRIBIRSE → completar compra sandbox | ⬜ |
| 25 | Verificar entitlement activo en RevenueCat (Dashboard → Customers) | ⬜ |
| 26 | Verificar `user_subscriptions` actualizada en Supabase (plan + status active) | ⬜ |
| 27 | Verificar maná renovado (`get_mana_state`) | ⬜ |
| 28 | Probar "GESTIONAR SUSCRIPCIÓN" (Customer Center) | ⬜ |

---

## Resumen por responsable

- **App (IA):** ✅ código de pago completo (paywall, entitlement, Customer Center, webhook 2×2, APK release, RevenueCat products/offering vía API). ⬜ Pendiente: deploy del webhook + secrets (con tu aporte).
- **Tú:** validación de datos, crear app + suscripciones en Play, testers, webhook en RevenueCat Dashboard, y la compra de prueba.
- **Mixta:** IDs de producto coincidentes (paso 5 — ya definidos) y secrets del webhook (paso 2).
