# 06 — Refactoring de Código — Simplificación del Onboarding

> Proyecto: TutorSaas · Fecha: 2026-08-02
> Estado: documentación de refactoring ya realizado (verificado contra código, sin modificar código)
> Archivo clave: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

---

## 1. Resumen

Se simplificó la lógica de cierre del onboarding eliminando la forzadura del idioma de la interfaz y desvinculando del router la pantalla `PlacementTestScreen`, que estaba registrada bajo la ruta `/oracle-quiz` sin que el flujo real la usara. El refactoring es **de eliminación (código muerto / comportamiento no deseado)**, no de reestructuración.

## 2. Cambios realizados

### 2.1 Eliminado `_switchInterfaceToNative()`

- Se eliminó el método que forzaba `setUiLanguage(idiomaNativo)` al completar el onboarding.
- La interfaz ahora respeta `follow_device_language = true` (idioma del dispositivo) y el idioma de UI se cambia únicamente desde **Configuración** (`settings_screen.dart:1341`).
- Se mantiene `setLearningLanguage(...)` (onboarding_screen.dart:188 y 223).

### 2.2 Eliminado el import de `locale_provider`

- Se removió el import de `lib/core/i18n/locale_provider.dart` en `onboarding_screen.dart`.
- Verificación: el archivo `onboarding_screen.dart` ya no referencia `locale_provider`, `_switchInterfaceToNative` ni `uiLanguageProvider` (grep sin coincidencias en `lib/features/onboarding/`).

### 2.3 Eliminada la ruta `/oracle-quiz` (ver doc 04)

- Se eliminó la entrada `path: '/oracle-quiz'` de `lib/app/router.dart`.
- La pantalla `PlacementTestScreen` ya no es alcanzable desde el router; el flujo real de evaluación usa `/oracle-test` → `OracleConversationScreen`.

## 3. Estado de widgets / modelos / servicios

| Componente | Archivo | Estado |
|---|---|---|
| `PlacementTestScreen` | `lib/features/onboarding/presentation/screens/placement_test_screen.dart` | **Huérfano** — clase definida pero sin ruta que la instancie y sin imports en el código |
| `OnboardingScreen` | `onboarding_screen.dart` | Activo — flujo principal (5 pasos + Oráculo) |
| `OracleConversationScreen` | `oracle_conversation_screen.dart` | Activo — ruta `/oracle-test` |
| `_switchInterfaceToNative` | `onboarding_screen.dart` | Eliminado |
| `locale_provider` | `lib/core/i18n/locale_provider.dart` | Import eliminado del onboarding; el helper `t()` sigue siendo un stub (AGENTS.md) |
| `NavigationDecisionEngine` | `lib/app/navigation_resolver.dart` | Sin cambios |

## 4. Código muerto que quedó y plan de limpieza

| Ítem | Archivo | Acción planeada |
|---|---|---|
| `PlacementTestScreen` | `placement_test_screen.dart` | **Eliminar** el archivo (nadie lo importa; `flutter analyze` no da error porque es un widget privado no referenciado) |
| `_PlacementTestScreenState` | ídem | Eliminar junto con el widget |
| Imports de `placement_test_screen` en `router.dart` | — | Ya eliminados junto con la ruta |
| Posibles ayudantes del test de colocación (modelos/servicios exclusivos de la pantalla huérfana) | revisar en `lib/features/onboarding/` | Auditar dependencias del archivo antes de borrar para evitar importaciones colgantes |

### Pasos planeados de limpieza

1. Confirmar que ninguna otra parte del código importa `placement_test_screen.dart` (verificado: sin referencias).
2. Eliminar el archivo `placement_test_screen.dart`.
3. Ejecutar `flutter analyze` → objetivo: 0 errores.
4. Ejecutar `flutter test` → suite verde.
5. Verificar que no queden imports colgantes del antiguo `locale_provider` en el flujo de onboarding.

## 5. Criterios de verificación

- `flutter analyze` → 0 errores.
- `flutter test` → 5 archivos de test en verde.
- Navegación manual: completar onboarding sin que la interfaz cambie de idioma automáticamente; cambiarlo desde Configuración si se desea.
- `grep -r "oracle-quiz" lib/` → sin resultados.
- `grep -r "PlacementTestScreen" lib/` → solo dentro de `placement_test_screen.dart` (hasta su eliminación).
