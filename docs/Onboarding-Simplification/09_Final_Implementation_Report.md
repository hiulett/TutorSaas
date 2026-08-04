# Informe Final de Implementación — Simplificación del Onboarding

**Fecha:** 2026-08-02
**Serie:** `docs/Onboarding-Simplification/` (07 = testing, 08 = task list, 09 = este informe final).
**Cambios implementados:** 2026-07-31 · **Validación:** `flutter analyze` 0 errores · `flutter test` 73/73.
**Proyecto:** TutorSaas / Dungeon of English — Flutter mobile SaaS de conversación en inglés con HUD RPG Isekai.

---

## 1. Resumen ejecutivo

Tras la migración completa a i18n (`AppLocalizations`), el onboarding conservaba elementos que la nueva estrategia de localización había vuelto **redundantes o contradictorios**: un switch de idioma de interfaz en el Paso 0 con estado local sin persistencia, una persistencia que forzaba `uiLanguage` al idioma nativo del usuario, y una ruta huérfana de evaluación alternativa (`/oracle-quiz`) que duplicaba a la evaluación canónica con reglas inconsistentes.

Esta simplificación **elimina la fricción y el código muerto** sin tocar la experiencia nuclear de los 5 pasos: el idioma de la interfaz ahora **se detecta automáticamente del dispositivo** (configurable desde Configuración) y la evaluación de nivel queda **canonizada en una sola vía: la Conversación del Oráculo por voz**.

**Resultado:** onboarding más corto en decisiones (menos fricción), una única fuente de verdad para el idioma de la UI y para la clasificación de nivel, y un router sin rutas obsoletas.

---

## 2. Estado del onboarding tras la simplificación

Flujo de **5 pasos** (`PageView`) + tarjeta final:

```
1. Nativo ──► 2. País ──► 3. Objetivo ──► 4. Evaluación Oráculo (voz) ──► 5. Personaje ──► Tarjeta del Aventurero
```

| Paso | Contenido | Notas |
|---|---|---|
| 1 | Idioma nativo (8 idiomas) | Antes: idioma nativo **+ switch de interfaz**. Ahora solo pregunta el idioma nativo. |
| 2 | País de origen | Autocomplete sobre catálogo ISO completo. |
| 3 | Idioma a aprender / objetivo | 4 idiomas. |
| 4 | Clasificación del Oráculo | Evaluación **por voz** conversacional (`/oracle-test`), paso **opcional** (default `A1` si se omite). Devuelve `cefrLevel` y `gameRank`. |
| 5 | Creación del personaje | `CharacterCreationWizard`: 8 clases + avatar. |
| Final | Tarjeta del Aventurero | Nombre, clase, píldoras CEFR y rango; CTA → `/home`. |

---

## 3. Cambios implementados

### 3.1 Eliminado el switch "App Interface Language" (Paso 0)
- **Código:** `_switchInterfaceToNative` y su switch removidos de `onboarding_screen.dart`.
- **Motivo:** obsoleto por i18n. La UI se resuelve automáticamente con `effectiveUiLanguageProvider` (`language_settings.dart:133-140`): si `followDeviceLanguage` está activo (default `true`) se usa el idioma del dispositivo; si no, `uiLanguage`. `TutorSaaSApp` aplica ese locale a `MaterialApp.locale` (`app.dart:13-28`). El switch era un estado local que **no persistía** ninguna preferencia.
- **Funcionalidad preservada:** el idioma de interfaz se detecta del dispositivo y sigue siendo editable desde **Configuración** (`settings_screen.dart`).

### 3.2 Eliminada la persistencia que forzaba `uiLanguage = nativo`
- **Código:** en `_completeOnboardingAndPurchase` ya **no** se llama a `setUiLanguage`. Solo se persisten `learningLanguage` y `aiExplanationsInNative`.
- **Motivo:** forzar `uiLanguage` al idioma nativo entraba en conflicto con la nueva estrategia (la UI sigue al dispositivo).
- **Funcionalidad preservada:** `setUiLanguage` sigue disponible y se invoca únicamente desde Configuración.

### 3.3 Eliminada la ruta huérfana `/oracle-quiz`
- **Código:** `router.dart` ya no registra `/oracle-quiz` ni importa `PlacementTestScreen`.
- **Motivo:** ruta huérfana (nadie navegaba a ella) que duplicaba la evaluación canónica por voz con mecánica de opción múltiple y **reglas de nivel inconsistentes** (H4 del audit previo). Ambas terminaban en `/home` sin devolver el resultado al flujo, "perdiendo" al usuario.
- **Funcionalidad preservada:** la evaluación canónica **por voz** (`/oracle-test` → `OracleConversationScreen`) sigue activa y devuelve `cefrLevel`/`gameRank` al onboarding.

### 3.4 Limpieza de código muerto
- Import muerto de `locale_provider.dart` retirado del onboarding; `locale_provider.dart` conserva su rol de **stub legacy** (AGENTS.md §i18n).
- `placement_test_screen.dart` queda como archivo no referenciado (pendiente de borrado — ver §7).

---

## 4. Criterios de aceptación

| Criterio | Estado | Evidencia |
|---|---|---|
| **0 textos hardcodeados de interfaz** en el flujo simplificado | ✅ | El onboarding usa `AppLocalizations.of(context)!`; se eliminó el import del helper legacy `t()`. |
| **Selección manual de idioma de interfaz eliminada del onboarding** | ✅ | Sin switch en el Paso 0; la UI se detecta del dispositivo (`deviceLocaleProvider`), editable solo en Configuración. |
| **Navegación sin rutas obsoletas** | ✅ | `/oracle-quiz` fuera del router; las rutas internas del `redirect` son `/splash`, `/onboarding`, `/oracle-test`, `/disruption`. |
| **Código muerto limpio** (dentro del alcance) | ✅ | Imports muertos retirados; `/oracle-quiz` y su wiring eliminados. Queda `placement_test_screen.dart` como archivo huérfano (pendiente). |
| **Experiencia más corta / inmersiva** | ✅ | Una decisión menos en el Paso 0 (el idioma de UI ya no se pregunta); una sola evaluación de nivel (por voz, opcional); los 5 pasos + tarjeta final quedan intactos. |

---

## 5. Verificación

| Comando | Resultado |
|---|---|
| `flutter analyze` | **0 errores** |
| `flutter test` | **73/73 tests en verde** |

### Escenarios verificados (detalle en Doc 07)
- Usuario nuevo completo.
- Abandona el onboarding (sin persistencia parcial).
- Continúa / vuelve a abrir la app (redirect correcto por sesión/modo dev).
- Vuelve atrás entre pasos.
- Modo desarrollador.
- Idioma del dispositivo ≠ nativo del usuario (UI sigue al dispositivo; nativo queda para aprendizaje/IA).
- Cambio de idioma de interfaz desde Configuración (`followDeviceLanguage` + `setUiLanguage`).

---

## 6. Archivos afectados

| Archivo | Cambio |
|---|---|
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Switch e `_switchInterfaceToNative` eliminados; persistencia de `uiLanguage` retirada; import de `locale_provider` limpiado. |
| `lib/app/router.dart` | Ruta `/oracle-quiz` e import de `PlacementTestScreen` eliminados. |
| `lib/core/i18n/language_settings.dart` | Sin cambios funcionales en esta pasada (es la base de la nueva estrategia: `followDeviceLanguage`, `deviceLocaleProvider`, `effectiveUiLanguageProvider`). |
| `lib/core/i18n/locale_provider.dart` | −1 línea residual (referencia sin uso). |
| `lib/features/dashboard/presentation/screens/settings_screen.dart` | Sin cambios; es donde sigue viviendo el cambio de idioma de interfaz. |
| `lib/features/onboarding/presentation/screens/placement_test_screen.dart` | **Sin tocar** (código no referenciado; pendiente). |
| `docs/Onboarding-Simplification/` | 01 auditoría, 02 pantallas/controles eliminados, 07 testing, 08 task list, 09 este informe. |

---

## 7. Pendientes y recomendaciones

| # | Pendiente | Prioridad |
|---|---|---|
| 1 | **Eliminar `placement_test_screen.dart`** (código muerto no referenciado), previa re-verificación de imports con grep. | Media |
| 2 | Retirar definitivamente el stub `locale_provider.dart` cuando los módulos restantes migren a `AppLocalizations`. | Baja |
| 3 | Prueba en dispositivo real del idioma del dispositivo (locales `en/es/pt` y caída a `es`). | Baja |
| 4 | Widget-test de regresión del `PageView` de 5 pasos. | Baja |

---

## 8. Conclusión

La simplificación alcanzó sus objetivos: **menos fricción en el primer uso** (una decisión menos; el idioma de la UI se resuelve sola), **una sola evaluación de nivel** canónica por voz, **cero rutas obsoletas** y **código muerto retirado** dentro del alcance. El flujo nuclear de 5 pasos + tarjeta del aventurero permanece funcionalmente intacto, con 0 errores en `analyze` y 73/73 tests en verde. La única deuda técnica de relevancia es el archivo `placement_test_screen.dart`, que queda pendiente de borrado en una limpieza futura.
