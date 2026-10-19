# Lista de Tareas — Simplificación del Onboarding

**Fecha:** 2026-08-02
**Documento de trabajo:** 08 de la serie `docs/Onboarding-Simplification/`.
**Cambios implementados:** 2026-07-31. **Documentación final:** en curso (este doc y el 09).

---

## 1. Resumen

Backlog de la simplificación del onboarding tras la migración a i18n. Cada tarea incluye su estado, los archivos tocados y la evidencia de cierre. Las tareas `OB-01` a `OB-05` están **hechas**; la `OB-06` (documentación final) está **en curso**.

---

## 2. Backlog

| ID | Tarea | Estado | Archivos |
|---|---|---|---|
| OB-01 | **Eliminar switch "App Interface Language"** del Paso 0 y su variable `_switchInterfaceToNative` | ✅ Hecho | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` |
| OB-02 | **Eliminar persistencia que forzaba `uiLanguage = idioma nativo`** al completar el onboarding | ✅ Hecho | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` (en `_completeOnboardingAndPurchase`, ya no se llama a `setUiLanguage`) |
| OB-03 | **Eliminar ruta huérfana `/oracle-quiz`** del router (widget `PlacementTestScreen` queda sin navegación) | ✅ Hecho | `lib/app/router.dart` (ruta e import de `PlacementTestScreen` removidos) |
| OB-04 | **Limpiar imports sin uso** del onboarding (p. ej. `locale_provider`) | ✅ Hecho | `lib/features/onboarding/presentation/screens/onboarding_screen.dart`; `lib/core/i18n/locale_provider.dart` (−1 línea residual) |
| OB-05 | **Verificar 0 rutas huérfanas** / cero referencias muertas en el flujo | ✅ Hecho | `lib/app/router.dart` (revisión de rutas registradas vs. navegación real del onboarding: solo `/oracle-test`) |
| OB-06 | **QA y validación** (analyze + tests) | ✅ Hecho | `flutter analyze` (0 errores), `flutter test` (73/73) |
| OB-07 | **Documentación final** (testing report, task list e informe final) | 🔄 En curso | `docs/Onboarding-Simplification/07_Testing_Report.md`, `08_Task_List.md`, `09_Final_Implementation_Report.md` |

---

## 3. Detalle de las tareas realizadas

### OB-01 · Switch "App Interface Language" eliminado
- **Qué:** se eliminó el switch de idioma de interfaz del Paso 0 (idioma del despertar) y su estado local `_switchInterfaceToNative`.
- **Por qué:** obsoleto tras la i18n — la interfaz se resuelve sola con `effectiveUiLanguageProvider` (`lib/core/i18n/language_settings.dart:133-140`), que prioriza el idioma del dispositivo cuando `followDeviceLanguage` está activo (default `true`).
- **Evidencia de cierre:** grep en `lib/` no encuentra ninguna referencia a `_switchInterfaceToNative` (solo restos en caches de `graphify-out/` y docs previos).

### OB-02 · Persistencia forzada de `uiLanguage` eliminada
- **Qué:** al completar el onboarding ya **no** se fuerza `uiLanguage = idioma nativo`.
- **Evidencia de cierre:** en `_completeOnboardingAndPurchase` solo se persisten `learningLanguage` y `aiExplanationsInNative`; `setUiLanguage` solo se invoca desde Configuración (`lib/features/dashboard/presentation/screens/settings_screen.dart`).

### OB-03 · Ruta `/oracle-quiz` eliminada
- **Qué:** se eliminó del router la ruta `/oracle-quiz` y su import de `PlacementTestScreen`.
- **Por qué:** ruta huérfana (nadie navegaba a ella) que duplicaba la evaluación canónica por voz con una mecánica de opción múltiple y reglas de nivel inconsistentes (hallazgo H4 de `docs/Onboarding_Revamp/01_Current_Onboarding_Audit.md:121-126`).
- **Evidencia de cierre:** `router.dart` registra `/oracle-test` → `OracleConversationScreen`; no existe `/oracle-quiz` ni import de `PlacementTestScreen`.
- **Nota:** el archivo `placement_test_screen.dart` permanece como código no referenciado (ver pendientes).

### OB-04 · Imports limpiados
- **Qué:** se retiró el import muerto de `locale_provider.dart` del onboarding y una referencia residual (−1 línea) en `locale_provider.dart`.
- **Por qué:** tras la migración a `AppLocalizations`, el onboarding no usa el helper legacy `t()` ni `localeProvider`/`languageCodeProvider`.

### OB-05 · Verificación de rutas huérfanas
- **Qué:** se revisó que toda ruta registrada en el router tenga un origen de navegación real y que el onboarding solo navegue a rutas internas soportadas (`/oracle-test`).
- **Evidencia de cierre:** el único `push` del onboarding a una pantalla externa es `context.push('/oracle-test')`; las rutas internas del `redirect` son `/splash`, `/onboarding`, `/oracle-test`, `/disruption`.

### OB-06 · QA
- **Resultado:** `flutter analyze` → **0 errores**; `flutter test` → **73/73 tests en verde**. Detalle por escenario en `07_Testing_Report.md`.

---

## 4. Pendientes / trabajo futuro

| # | Pendiente | Prioridad | Notas |
|---|---|---|---|
| 1 | **Eliminar `placement_test_screen.dart`** (código muerto no referenciado) | Media | No se eliminó en esta pasada para no romper imports de módulos o tests externos; candidato a borrado en una limpieza dedicada. Re-verificar con grep antes de borrar. |
| 2 | **Retirar definitivamente `locale_provider.dart` como stub** | Baja | Conservado como stub legacy para otros módulos (AGENTS.md §i18n); eliminarlo requiere migrar primero esos módulos a `AppLocalizations`. |
| 3 | **Cobertura de dispositivos reales** para la detección de idioma del dispositivo (`en/es/pt` y caída a `es`) | Baja | El pase actual fue por revisión de código; recomendar prueba en dispositivo con locale de sistema distinto. |
| 4 | **Test automatizado de regresión del flujo de 5 pasos** | Baja | La suite cubre saneamiento y Oracle; un widget-test específico del `PageView` de onboarding daría mayor red de seguridad. |

---

## 5. Estado global

| Categoría | Estado |
|---|---|
| Tareas de implementación | 6/6 completadas (OB-01 → OB-06) |
| Documentación | OB-07 en curso |
| Validación | 0 errores analyze · 73/73 tests |
