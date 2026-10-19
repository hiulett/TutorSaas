# Informe de Pruebas — Simplificación del Onboarding

**Fecha:** 2026-08-02
**Alcance:** Simplificación del onboarding del proyecto Flutter **TutorSaas / Dungeon of English** tras la migración a i18n.
**Cambios bajo prueba (implementados 2026-07-31):**
- Eliminado el switch "App Interface Language" y `_switchInterfaceToNative` del Paso 0.
- Eliminada la persistencia que forzaba `uiLanguage = idioma nativo` al completar el onboarding.
- Eliminada la ruta huérfana `/oracle-quiz` (`PlacementTestScreen`) del router.
- Limpieza de imports muertos (p. ej. `locale_provider` en el onboarding).

---

## 1. Objetivo

Verificar que la simplificación **no rompe el flujo nuclear** del onboarding y que el cambio de estrategia de idioma (detección automática por dispositivo en lugar de pregunta manual en el flujo) se comporta correctamente en todos los escenarios de usuario relevantes.

---

## 2. Método

- **Código bajo prueba:**
  - `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (PageView de 5 pasos + tarjeta final).
  - `lib/app/router.dart` (rutas; verificación de ausencia de `/oracle-quiz`).
  - `lib/core/i18n/language_settings.dart` (`UserLanguageNotifier`, `deviceLocaleProvider`, `effectiveUiLanguageProvider`).
  - `lib/features/dashboard/presentation/screens/settings_screen.dart` (cambio de idioma desde Configuración).
- **Herramientas:** `flutter analyze` (barra de 0 errores) y `flutter test` (suite completa). Las verificaciones de escenario se realizaron por **revisión del código actual** + trazado manual del flujo; cada caso se describe en la tabla de la sección 3.
- **Entorno:** Flutter (Windows), sin dispositivo físico en este pase; la verificación de voz depende del pipeline Groq STT / DeepSeek y se asume estable (fuera del alcance de esta simplificación).

---

## 3. Escenarios de prueba

| # | Escenario | Resultado esperado | Resultado actual | Estado |
|---|---|---|---|---|
| T1 | **Usuario nuevo** completa el onboarding completo | Recorre los 5 pasos (nativo → país → objetivo → evaluación Oráculo por voz → personaje) y llega a la tarjeta del aventurero con su nivel CEFR (`A1` si omitió la evaluación); CTA "Entrar al Reino" → `/home`. No se le pregunta el idioma de interfaz en el Paso 0. | `_nextPage` valida nativo (Paso 0) y objetivo (Paso 2); el Paso 3 lanza `/oracle-test` y al volver fija `_currentPage = 4`; `_completeOnboardingAndPurchase` persiste datos y salta al `paywall` post-sesión; el Paso 0 solo pide idioma nativo. | ✅ Verificado |
| T2 | **Abandona el onboarding** antes de completarlo | No se persiste ningún dato de onboarding parcial (no hay guardado intermedio); el router redirige a `/splash` o al destino que el `NavigationDecisionEngine` resuelva según sesión/modo dev. Las rutas internas de onboarding (`/splash`, `/onboarding`, `/oracle-test`, `/disruption`) nunca se redirigen. | El guardado ocurre únicamente en `_completeOnboardingAndPurchase` (no hay autosave por paso); `router.dart:44-50` excluye las rutas internas del `redirect`. | ✅ Verificado |
| T3 | **Continúa** un onboarding después de abandono / vuelve a abrir la app | El usuario no pierde la sesión: el redirect lleva al destino correcto según `currentUserProvider` y `devModeProvider`. Si no completó onboarding, se le devuelve a `/onboarding` (decisión del `NavigationDecisionEngine`). | `routerProvider` usa `_NavigationRefreshListenable` que re-evalúa el `redirect` al cambiar sesión o modo dev. | ✅ Verificado |
| T4 | **Vuelve atrás** durante los 5 pasos | `_prevPage` decrementa la página y anima hacia atrás; en el Paso 0 no hay acción. El Paso 4 (creación de personaje) es gestionado por `CharacterCreationWizard` con su propio botón; el botón inferior del onboarding se oculta en ese paso. | `_prevPage` (`onboarding_screen.dart:130-141`) con `if (_currentPage > 0)`. Botón inferior oculto en el Paso 4 (documentado en Doc 01 §2). | ✅ Verificado |
| T5 | **Modo desarrollador** activado | El `redirect` resuelve hacia la pantalla de destino dev (`dungeon-map` según `NavigationDecisionEngine`) para usuarios con sesión; el onboarding no se ve afectado en su lógica interna. | `devModeProvider` es observado por el listenable del router y usado por `NavigationDecisionEngine.resolve(user, devMode)`. | ✅ Verificado |
| T6 | **Idioma del dispositivo ≠ nativo del usuario** | La interfaz se muestra en el idioma del dispositivo (si es `en/es/pt`) por `effectiveUiLanguageProvider` → `deviceLocaleProvider`; el idioma nativo del usuario (p. ej. `ja` o `de`) se usa solo como idioma de aprendizaje/IA, no para la UI. No hay conflicto entre el paso de idioma nativo y la UI. | `language_settings.dart:133-140`: `followDeviceLanguage` (default `true`) → idioma del dispositivo si está en `supportedUiLanguages` (`en/es/pt`), si no `es`. `TutorSaaSApp` aplica ese locale a `MaterialApp.locale`. | ✅ Verificado |
| T7 | **Cambio de idioma de interfaz desde Configuración** | `followDeviceLanguage` se puede desactivar y elegir idioma manual (bottom sheet) con `setUiLanguage`; el cambio se refleja de inmediato en `MaterialApp.locale` vía `effectiveUiLanguageProvider`. El onboarding ya no tiene switch de interfaz. | `settings_screen.dart:1238-1244` (Switch `followDeviceLanguage`) y `1250-1341` (tile "IDIOMA DE LA APLICACIÓN" + bottom sheet + `setUiLanguage`); `setUiLanguage` persiste en SharedPreferences y Supabase. | ✅ Verificado |

---

## 4. Resultados de validación automática

| Comando | Resultado |
|---|---|
| `flutter analyze` | **0 errores** (se mantienen los infos/warnings de referencia; barra de calidad del repo: 0 errores) |
| `flutter test` | **73/73 tests en verde** |

### Archivos de tests relevantes a la simplificación
- `test/oracle_conversation_test.dart` — cubre la evaluación del Oráculo (`/oracle-test`), ruta canónica que **se mantiene** tras eliminar `/oracle-quiz`.
- `test/widget_test.dart`, `test/overflow_test.dart` — saneamiento del flujo y layout del onboarding.
- Resto de la suite (`mission_models_test`, `lesson_catalog_test`, `dashboard_repository_test`, `economy_repository_helpers_test`, `latency_benchmark_test`, goldens) — regresión general de módulos afectados indirectamente por la limpieza de imports.

---

## 5. Hallazgos y observaciones

1. **Sin regresiones detectadas** en el flujo nuclear de 5 pasos ni en la navegación.
2. **`PlacementTestScreen` queda como código no referenciado:** el archivo `lib/features/onboarding/presentation/screens/placement_test_screen.dart` (692 líneas) sigue en el repo sin ninguna ruta ni import activo. No se eliminó para no romper imports externos; es candidato a limpieza (ver Doc 08).
3. **Selector de idioma de interfaz en Configuración:** el switch `followDeviceLanguage` sigue viviendo en Configuración; cuando está activo el tile de idioma muestra un candado (bloqueado) y solo es editable desactivando la detección. Comportamiento coherente con la nueva estrategia.
4. **La detección por dispositivo prioriza `en/es/pt`** y cae a `es` para cualquier otro idioma de dispositivo. Cobertura correcta con los 3 ARBs actuales.

---

## 6. Veredicto

**APTO.** La simplificación cumple los criterios de aceptación: 0 errores en `analyze`, 73/73 tests en verde y todos los escenarios de usuario verificados (usuario nuevo, abandono, continuación, retroceso, modo desarrollador, idioma de dispositivo distinto del nativo y cambio de idioma desde Configuración).
