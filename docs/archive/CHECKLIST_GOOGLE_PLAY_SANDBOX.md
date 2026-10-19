# Checklist — Salir a pruebas en Google Play (sandbox + RevenueCat)

Estado al momento: **MCP Play Console conectado** · **Keystore release creado** ·
**AAB subido a track `internal` (versionCode 1)** · **Service account con acceso** ·
**Cuenta RevenueCat + SDK + webhook + edge functions OK** · **Display names PLUS/PRO/MAX OK**.

Leyenda de columnas:
- **App** = trabajo sobre el código del proyecto (lo hago yo/IA).
- **Tú** = acciones en dashboards (Play Console, RevenueCat, Supabase) que solo tú puedes hacer.
- **Mixta** = requiere coordinar ambos lados (p. ej. IDs de producto).

---

## 🔴 BLOQUEANTE para el ciclo completo (compra → plan activo)

| # | Tarea | App | Tú | Mixta | Estado |
|---|-------|-----|----|----|--------|
| 1 | Edge functions `revenuecat-webhook` + `lesson-generator` desplegadas | ✅ | 🔑 deploy + secrets | | ✅ |
| 2 | Secrets: `REVENUECAT_AUTH_TOKEN`, `SERVICE_ROLE_KEY`, `DEEPSEEK_API_KEY` | ✅ | 🔑 ejecutadas | | ✅ |
| 3 | Scripts SQL `20260818_01..06` (esquema + PRE-A1 + RPCs + planes) | ✅ | 🔑 SQL Editor | | ✅ |
| 4 | Endpoint webhook en RevenueCat Dashboard (URL + Bearer) | | ✅ | | ⬜ |
| 5 | `mana_allowance`/planes en BD (17/20.5/25.5K) | ✅ (script 01+05) | 🔑 | | ✅ |

## 📦 RevenueCat y Play (modelo 3×2)

| # | Tarea | Estado |
|---|---|---|
| 6 | Products 3×2 en RevenueCat (noble/realeza/divino × monthly/yearly) | ✅ (vía API v2) |
| 7 | Offering "Current" con 6 packages | ✅ (vía API v2) |
| 8 | Display names PLUS/PRO/MAX en RevenueCat | ✅ (vía API v2) |
| 9 | Suscripciones en Play Console con los 6 IDs (`dungeonsspeak_*`) + precios | ⬜ Tú |

## 🔐 Firma y distribución (Google Play)

| # | Tarea | Estado |
|---|---|---|
| 10 | MCP Play Console conectado (service account `dungeonspeak-play-console`) | ✅ |
| 11 | Keystore release generado (`upload-keystore.jks`) + `key.properties` (gitignored) | ✅ |
| 12 | APK release firmado (verificado, no-debug) | ✅ |
| 13 | AAB release firmado + subido a track `internal` (versionCode 1) | ✅ |
| 14 | **Play App Signing** activado (upload key = keystore, coinciden SHA-256) | ✅ |
| 15 | Lista de testers internos (8 emails) — enlace: `https://play.google.com/apps/internaltest/4701139087867465278` | ✅ |
| 16 | Terminar validación de datos Play Console | ⬜ Tú |
| 17 | Aceptar enlace de tester | ⬜ Tú |
| 17b | (Opcional) Digital Asset Links / App Links con SHA-256 `1A:0D:E7:...` | ⬜ Tú |

## 📱 App (código) — implementado ✅

| # | Tarea | Estado |
|---|---|---|
| 18 | Maná: free 200/día + 3,000/mes · pagos 17/20.5/25.5K sin límite diario | ✅ |
| 19 | Inventario equipable de maná (elixires/gemas, 48h/15d) | ✅ |
| 20 | Mapa de mazmorras (título, 12 visibles, sub misiones, tarjeta Oráculo) | ✅ |
| 21 | Superación ≥80% + `lesson_progress` + cierre robusto de sesión | ✅ |
| 22 | Oráculo promotion (contexto, no baja, reto 80%) | ✅ |
| 23 | Generador de sub misiones (lesson-generator, 100 maná) + idioma único EN | ✅ |
| 24 | `flutter analyze` 0 errores · `flutter test` 136 OK | ✅ |

## 🧪 Pruebas (una vez todo arriba)

| # | Tarea | Estado |
|---|---|---|
| 25 | Comprar sandbox → plan activo → maná renovado | ⬜ |
| 26 | Completar lección → superación 80% → siguiente desbloqueada | ⬜ |
| 27 | No superar lección → sub misión generada (100 maná) | ⬜ |
| 28 | Reto del Oráculo desde 80% → subir nivel | ⬜ |
| 29 | Free llega a 200/día → sello → comprar gema/elixir | ⬜ |

## Resumen por responsable

- **App (IA):** ✅ código (maná, mapa, superación, Oráculo, generador, EN) + scripts SQL + edge functions + keystore + AAB subido + MCP conectado + display names.
- **Tú:** endpoint webhook RevenueCat, suscripciones Play Console, Play App Signing, testers, validación de datos, pruebas sandbox.
- **Mixta:** nada pendiente en este momento.
