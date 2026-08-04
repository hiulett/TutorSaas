# Pantallas y Controles Eliminados del Onboarding

**Fecha:** 2026-08-02
Este documento detalla los tres elementos eliminados durante la simplificación del onboarding tras la migración a i18n. Para cada uno: **motivo**, **impacto** y **confirmación de que no se pierde funcionalidad**.

---

## 1. Switch "App Interface Language" (Paso 0)

**Archivo afectado:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (Paso 0, `_buildNativeLanguagePage`).

### Motivo
- La variable `_switchInterfaceToNative` y su switch quedaron **obsoletos por la i18n**:
  - La interfaz ahora se resuelve automáticamente con `effectiveUiLanguageProvider` (`lib/core/i18n/language_settings.dart:133-140`): si `followDeviceLanguage` está activo (default `true`, línea 16), se usa `deviceLocaleProvider`; si no, se usa `uiLanguage`.
  - `TutorSaaSApp` aplica ese idioma efectivo a `MaterialApp.locale` (`lib/app/app.dart:13-28`).
- El switch solo manejaba un estado local que **no persistía** ninguna preferencia real (el estado `_switchInterfaceToNative` no se guardaba en SharedPreferences ni en Supabase).
- Pedirle el idioma de interfaz a un usuario que aún no ha usado la app añadía fricción innecesaria al Paso 0.

### Impacto
- El Paso 0 queda reducido a **una sola pregunta**: el idioma nativo (`_nativeLanguages`, 8 idiomas).
- Se eliminó la única referencia a `_switchInterfaceToNative` del código; el grep confirma que no queda ninguna ocurrencia en `lib/` (solo restos en caches de `graphify-out/` y docs antiguos).
- Eliminada también la **persistencia** que, al completar el onboarding, forzaba `uiLanguage = idioma nativo`. En `_completeOnboardingAndPurchase` solo se persisten `learningLanguage` y `aiExplanationsInNative`.

### Confirmación de que no se pierde funcionalidad
- **Detección automática:** el idioma de interfaz se elige solo a partir del idioma del dispositivo (sin intervención del usuario).
- **Sigue siendo configurable:** el usuario puede sobreescribir la detección y elegir un idioma de interfaz desde **Configuración** (`lib/features/dashboard/presentation/screens/settings_screen.dart:1205-1341`, selector con `followDeviceLanguage` + `setUiLanguage`).
- `setUiLanguage` sigue vivo y disponible para ese caso (persiste en SharedPreferences y en `user_settings` de Supabase).

---

## 2. Ruta `/oracle-quiz` (PlacementTestScreen huérfano)

**Archivos afectados:** `lib/app/router.dart` (ruta eliminada) y `lib/features/onboarding/presentation/screens/placement_test_screen.dart` (widget que queda sin navegación).

### Motivo
- La ruta era **huérfana**: ninguna pantalla ni flujo navegaba a `/oracle-quiz`. El onboarding navega únicamente a `/oracle-test` (`onboarding_screen.dart:147`, `context.push('/oracle-test')`).
- **Duplicaba** el propósito de `/oracle-test` con otra mecánica: el quiz escrito de opción múltiple (`PlacementTestScreen`) frente a la **Conversación del Oráculo por voz** (`OracleConversationScreen`), que es la evaluación canónica del producto.
- Las dos evaluaciones usaban **reglas de cálculo de nivel distintas e inconsistentes entre sí** (hallazgo H4 de `docs/Onboarding_Revamp/01_Current_Onboarding_Audit.md:121-126`): el mismo usuario podía obtener niveles divergentes según la ruta.
- Ambas terminaban en `/home` sin devolver el resultado al flujo de creación de personaje, lo que "perdía" al usuario.

### Impacto
- `lib/app/router.dart` ya no contiene la ruta `/oracle-quiz` ni el import de `PlacementTestScreen` (verificado en el archivo actual, 193 líneas).
- El router mantiene las rutas internas de onboarding en `internalRoutes` (`/splash`, `/onboarding`, `/oracle-test`, `/disruption`) — ya **sin** `/oracle-quiz`.
- **Nota de limpieza pendiente:** el archivo `placement_test_screen.dart` (clase `PlacementTestScreen`) sigue existiendo en el repo como código no referenciado. No se eliminó el archivo para no romper imports de módulos o tests externos; es candidato a eliminación en una pasada de limpieza futura.

### Confirmación de que no se pierde funcionalidad
- La evaluación canónica sigue disponible: **Conversación del Oráculo por voz** (`/oracle-test` → `OracleConversationScreen`), que es conversacional (no opción múltiple) y **devuelve `cefrLevel` y `gameRank` al onboarding** (`onboarding_screen.dart:151-154`), actualizando el paso de clasificación y la tarjeta final del héroe.
- Si el usuario omite la evaluación, se parte de `A1` (`onboarding_screen.dart:171`).
- No existía ningún enlace en la UI hacia `/oracle-quiz`, por lo que su retirada no quita ningún acceso visible al usuario final.

---

## 3. Import de `locale_provider` sin uso

**Archivos afectados:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (import removido); `lib/core/i18n/locale_provider.dart` (solo se retiró una referencia residual, −1 línea en el diff).

### Motivo
- Tras la migración a `AppLocalizations`, el onboarding ya no usa `localeProvider` / `languageCodeProvider` ni el helper legacy `t()`.
- El import de `locale_provider.dart` quedó **muerto** (referencia sin uso), añadiendo ruido y una dependencia innecesaria al widget más grande del flujo.

### Impacto
- Los imports de `onboarding_screen.dart` (líneas 1-20) quedan limpios; toda la localización pasa por `AppLocalizations.of(context)!` y por `UserLanguageSettings` (`userLanguageProvider` / `deviceLocaleProvider`).

### Confirmación de que no se pierde funcionalidad
- El onboarding lee el idioma del dispositivo desde `deviceLocaleProvider` (`language_settings.dart:124-127`), no desde `localeProvider`.
- `locale_provider.dart` se conserva como **stub legacy** (`t()` devuelve la clave, `localeProvider`/`languageCodeProvider` siguen exportados) para compatibilidad de otros módulos que aún lo referencian — ver AGENTS.md §i18n.

---

## Tabla resumen

| Elemento eliminado | Motivo | ¿Pérdida de funcionalidad? |
|---|---|---|
| Switch "App Interface Language" | Obsoleto por i18n; detección automática por dispositivo; estado local sin persistencia | No — se detecta solo; configurable en Configuración |
| Persistencia `uiLanguage = nativo` al completar | La interfaz ya sigue al dispositivo | No — `setUiLanguage` sigue disponible en Configuración |
| Ruta `/oracle-quiz` | Huérfana; duplicaba `/oracle-test` con reglas inconsistentes | No — evaluación canónica por voz sigue activa |
| Import de `locale_provider` en onboarding | Import muerto tras la migración a `AppLocalizations` | No — `locale_provider` queda como stub legacy para otros módulos |
