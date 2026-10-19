# Auditoría del Onboarding tras el i18n

**Fecha:** 2026-08-02
**Alcance:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (977 líneas verificadas), `lib/app/router.dart`, `lib/core/i18n/language_settings.dart`.
**Método:** revisión del código actual + `git diff` respecto al commit base.

---

## 1. Resumen ejecutivo

El onboarding sigue siendo un `PageView` de **5 pasos** (`onboarding_screen.dart:343-353`) que termina con una tarjeta final del aventurero (`_buildHeroWelcomeScreen`, línea 408). Tras la migración a i18n:

- **Se eliminó** el switch "App Interface Language" (y su variable `_switchInterfaceToNative`) del Paso 0.
- **Se eliminó** la persistencia que forzaba `uiLanguage = idioma nativo` al completar el onboarding.
- **Se eliminó** la ruta huérfana `/oracle-quiz` del router.
- **Se eliminó** el import sin uso de `locale_provider`.

El idioma de la interfaz ya **no se pregunta**: se detecta automáticamente desde el dispositivo (`followDeviceLanguage` + `deviceLocaleProvider`) y se puede cambiar en Configuración.

---

## 2. Estado actual por paso

### Paso 0 — Idioma del Despertar · `_buildNativeLanguagePage` (línea 589)
- Selecciona el **idioma nativo** del usuario.
- Lista `_nativeLanguages` de **8 idiomas**: `es, en, fr, de, pt, it, zh, ja` (líneas 56-65).
- **✅ Cambio aplicado:** se eliminó el switch "App Interface Language" que vivía en este paso (ver Doc 02, §1). El Paso 0 ahora solo pregunta el idioma nativo.
- La detección del idioma del dispositivo se comunica al usuario al primer inicio mediante un `SystemSnack` informativo (`initState`, líneas 78-91).

### Paso 1 — País de Origen · `_buildCountryPage` (línea 676)
- Autocomplete sobre el **catálogo ISO completo** `CountryCatalog.countries` (línea 717), **sin lista de "sugeridos"** (ya aplicado en la simplificación previa).
- El filtro busca por nombre localizado o por código ISO (línea 720).

### Paso 2 — Idioma a Aprender · `_buildTargetLanguagePage` (línea 812)
- Selecciona el **idioma objetivo** de aprendizaje.
- Lista `_targetLanguages` de **4 idiomas**: `en, fr, de, it` (líneas 67-72).

### Paso 3 — Clasificación del Oráculo · `_buildAiClassificationPage` (línea 885)
- Evaluación **por voz** (conversacional) vía `/oracle-test` (`_startOracleEvaluation`, línea 147: `context.push('/oracle-test')`).
- Paso **opcional**: si el usuario la omite, al guardar se parte de `A1` (línea 171).
- Al volver de la evaluación se captura `cefrLevel` y `gameRank` (líneas 151-154).

### Paso 4 — Creación del Personaje · `_buildCharacterCreationPage` (línea 575)
- `CharacterCreationWizard` (widget externo): **8 clases** + selección de avatar.
- El wizard tiene su propio botón; el botón inferior del onboarding se oculta en este paso (línea 358).

### Pantalla final — Tarjeta del Aventurero · `_buildHeroWelcomeScreen` (línea 408)
- Resumen del héroe: nombre, clase, píldoras `CEFR` y rango de juego, y descripción del rango.
- CTA "Entrar al Reino" → `context.go('/home')` (línea 536).

---

## 3. Cambios ya implementados (2026-07-31)

| Cambio | Evidencia |
|---|---|
| **Switch "App Interface Language" eliminado** | No existe ninguna referencia a `_switchInterfaceToNative` en `lib/` (grep: solo aparece en caches obsoletos de `graphify-out/` y documentación previa). El Paso 0 solo renderiza el selector de idioma nativo (líneas 615-667). |
| **Persistencia forzada de `uiLanguage=nativo` eliminada** | En `_completeOnboardingAndPurchase` (líneas 163-238) solo se persisten `learningLanguage` y `aiExplanationsInNative` (líneas 188-190). **No** hay ninguna llamada a `setUiLanguage` desde el onboarding (grep confirma que `setUiLanguage` solo se usa en `settings_screen.dart:1341`). |
| **Ruta `/oracle-quiz` eliminada del router** | `router.dart` solo registra `/oracle-test` → `OracleConversationScreen` (línea 73-76). No existen `oracle-quiz` ni import de `PlacementTestScreen` en `lib/app/router.dart`. |
| **Import de `locale_provider` limpiado** | Los imports de `onboarding_screen.dart` (líneas 1-20) no incluyen `locale_provider.dart`. `locale_provider.dart` solo perdió 1 línea en el diff (referencia residual). |

---

## 4. Qué quedó obsoleto y por qué

### 4.1 El switch de idioma de interfaz (obsoleto por i18n)
- **Motivo de obsolescencia:** con la i18n, la interfaz se resuelve automáticamente mediante `effectiveUiLanguageProvider` (`language_settings.dart:133-140`), que prioriza el idioma del dispositivo cuando `followDeviceLanguage` está activo (default `true`, línea 16). `TutorSaaSApp` aplica ese idioma a `MaterialApp.locale` (`app.dart:13-28`).
- El switch era un estado local (`_switchInterfaceToNative`) que **no persistía** un valor útil fuera del widget (documentado en `docs/02_User_Experience/Analysis.md:30`) y pedía al usuario algo que la app ya resuelve sola.

### 4.2 Evaluaciones de nivel
- La **evaluación canónica** es la **Conversación del Oráculo por voz** (`/oracle-test`).
- `/oracle-quiz` (quiz escrito de opción múltiple, `PlacementTestScreen`) **duplicaba** ese propósito con una mecánica y reglas de cálculo distintas, y no se navegaba a él desde ningún punto del flujo (ver Doc 02, §2).

---

## 5. Qué se mantiene (sin cambios)

- Los **5 pasos** del `PageView` y su barra de progreso segmentada (líneas 298-338).
- La **evaluación por voz** del Oráculo (`/oracle-test`, paso opcional).
- La **creación de personaje** (8 clases + avatares) y la **tarjeta final del aventurero**.
- La persistencia de `learningLanguage`, `aiExplanationsInNative`, `country_code`, `game_rank`/`character_class`/`avatar_index` y el perfil del héroe (líneas 173-217).
- El `paywall` **post-sesión** (UX-02): el onboarding siempre arranca en plan free (línea 220).

---

## 6. Conclusión

El onboarding queda **más corto en fricción pero funcionalmente intacto**: eliminó los elementos que la i18n volvió redundantes (switch de interfaz, persistencia de `uiLanguage`, ruta huérfana e import muerto) sin tocar la experiencia nuclear de los 5 pasos ni la creación del personaje.
