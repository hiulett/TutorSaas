# Arquitectura Objetivo de Internacionalización

> Documento de diseño (objetivo). Complementa `docs/Internationalization/01_Current_Audit.md`.
> No modifica código: define el modelo, el flujo y el patrón a implementar.

---

## 1. Modelo: 3 idiomas independientes

La app maneja **tres ejes de idioma que deben poder configurarse y resolverse de forma independiente**:

| Eje | Rol | Default deseado |
|---|---|---|
| **`uiLanguage`** | Idioma de la interfaz (textos ARB de la app) | **Detección automática del dispositivo** en el primer inicio |
| **`learningLanguage`** | Idioma que se está aprendiendo (contenido de las lecciones, L2) | `en` (inglés) |
| **`aiExplanationsInNative`** | Si las explicaciones del tutor IA se dan en el idioma nativo del usuario | `true` |
| **`followDeviceLanguage`** *(nuevo)* | Override maestro: si `true`, la UI sigue al idioma del dispositivo en cada arranque, ignorando `uiLanguage` guardado | `true` (por defecto) |

Regla de resolución de la UI:

```
uiLanguage_efectivo =
    if (followDeviceLanguage)  → locale del dispositivo (si está soportado, si no 'es')
    else                       → uiLanguage guardado
```

- Los tres ejes **se almacenan y sincronizan por separado** (prefs locales + tabla `user_settings`).
- `learningLanguage` y `aiExplanationsInNative` no dependen del dispositivo: siempre usan el valor guardado (o default), porque reflejan preferencias de aprendizaje, no del entorno.
- Cuando `followDeviceLanguage` está activo, `uiLanguage` **no se sobrescribe**: la detección es en memoria para la sesión; el valor guardado se conserva por si el usuario desactiva el flag.

---

## 2. Detección automática del dispositivo

- Fuente: `PlatformDispatcher.instance.locale` (accede al locale del sistema operativo sin contexto de widget).
- Normalización: mapear a las locales soportadas (`es`, `en`, `pt`); si el idioma del dispositivo no está en la lista → fallback a `es` (idioma base).
- Momento de resolución: **al primer inicio** (cuando no hay valor previo en prefs) y **en cada arranque** si `followDeviceLanguage == true`.
- El onboarding ya pregunta por el idioma nativo (aprendizaje); **la UI nunca pide idioma de interfaz** — se resuelve siempre por detección u override.

```
PlatformDispatcher.instance.locale.languageCode
        │
        ▼
┌─────────────────────────────┐
│ ¿followDeviceLanguage?      │── no → usa uiLanguage guardado
└─────────────────────────────┘
        │ sí
        ▼
┌─────────────────────────────┐
│ ¿deviceLocale ∈ {es,en,pt}? │── no → 'es'
└─────────────────────────────┘
        │ sí
        ▼
     uiLanguage_efectivo = deviceLocale
```

---

## 3. Sincronización bidireccional prefs ↔ Supabase

### 3.1 Escritura (prefs → Supabase)

Cada setter muta localmente y luego hace upsert remoto, como hoy (`_persistToSupabase`), **extendido a los 4 campos**:

| Campo | Setter | Persistencia |
|---|---|---|
| `uiLanguage` | `setUiLanguage(code)` | prefs + Supabase |
| `learningLanguage` | `setLearningLanguage(code)` | prefs + Supabase |
| `aiExplanationsInNative` | `setAiExplanationsInNative(bool)` | prefs + **Supabase** *(hoy no — brecha G8)* |
| `followDeviceLanguage` | `setFollowDeviceLanguage(bool)` | prefs + Supabase |

### 3.2 Lectura (Supabase → prefs) — nueva

Al arrancar **con sesión iniciada**, antes de construir la UI:

1. `fetch` de `user_settings` filtrando por `user_id`.
2. Si existen filas → poblar prefs (y el estado del provider) con los valores remotos.
3. Si no existen → escribir un primer registro con los defaults resueltos (incluida la detección de dispositivo).
4. Mecanismo idempotente: no sobrescribir `uiLanguage` si `followDeviceLanguage` está activo y hay preferencia local previa (el remoto solo aplica en la primera sesión del dispositivo).

**Caso sin sesión**: se usan solo prefs + detección; al iniciar sesión se re-sincroniza.

### 3.3 Reglas de conflicto

- `followDeviceLanguage == true` → `uiLanguage_efectivo` lo gobierna la detección; el valor almacenado en prefs/DB se respeta solo para el futuro.
- `followDeviceLanguage == false` → `uiLanguage_efectivo = uiLanguage` (último cambio gana: local si hubo interacción, remoto si es la primera sesión del dispositivo).

---

## 4. Patrón provider (Riverpod)

### 4.1 Estado y modelo

```dart
class UserLanguageSettings {
  final String uiLanguage;
  final String learningLanguage;
  final bool aiExplanationsInNative;
  final bool followDeviceLanguage;   // nuevo
}
```

### 4.2 Providers

| Provider | Tipo | Responsabilidad |
|---|---|---|
| `userLanguageProvider` | `StateNotifierProvider<UserLanguageNotifier, UserLanguageSettings>` | Estado canónico del modelo (persistido) |
| `effectiveUiLanguageProvider` *(nuevo)* | `Provider<Locale>` | Resuelve `uiLanguage_efectivo` aplicando la regla de detección + `followDeviceLanguage`; **este es el que alimenta `MaterialApp.locale`** |
| `deviceLocaleProvider` *(nuevo)* | `Provider<String>` | Expone `PlatformDispatcher.instance.locale.languageCode` normalizado (testeable con fake platform dispatcher) |

### 4.3 Flujo del notifier

```
UserLanguageNotifier
 ├─ constructor
 │    ├─ _loadFromPrefs()            (valores guardados; sin detección)
 │    ├─ _detectDeviceLanguage()     (resuelve default del 1er inicio)
 │    └─ _syncFromSupabase()         (si hay sesión: fetch → poblar prefs/estado)
 │
 ├─ setUiLanguage(code)
 │    ├─ prefs.setString('ui_language', code)
 │    ├─ state = copyWith(uiLanguage: code)
 │    ├─ _persistToSupabase()
 │    └─ (opcional) followDeviceLanguage = false  → la UI deja de seguir al dispositivo
 │
 ├─ setFollowDeviceLanguage(bool)    (idem, con columna nueva en DB)
 │
 └─ _persistToSupabase()             (upsert de los 4 campos)
```

### 4.4 Consumo en la app

`lib/app/app.dart` pasa a leer de `effectiveUiLanguageProvider` en lugar de `userLanguageProvider.select((s) => s.uiLanguage)`:

```
final uiLocale = ref.watch(effectiveUiLanguageProvider);   // Locale ya resuelto
MaterialApp.router(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: uiLocale,
)
```

### 4.5 Retirada del legado

- `LocaleNotifier` / `localeProvider` / `languageCodeProvider` / `t()` (`lib/core/i18n/locale_provider.dart`) quedan **deprecados** y se eliminan en cuanto no existan referencias.
- Migración de la clave `interface_language` → `ui_language` en el primer arranque tras el cambio (lectura one-shot en `_loadFromPrefs`).
- El bloque vacío `try {} catch (_) {}` de sincronización se sustituye por la lógica real de 3.2.

---

## 5. Sección "Language" en Settings

Nueva sección en `settings_screen.dart` (junto a las secciones existentes `_SectionHeader`), con los 3 controles:

1. **Interruptor "Seguir idioma del dispositivo"** → `setFollowDeviceLanguage(bool)`.
   - `true`: la UI muestra un texto informativo ("El idioma se detecta automáticamente de tu dispositivo") y **oculta/deshabilita** el selector de `uiLanguage`.
   - `false`: muestra el selector de **Idioma de interfaz** (`es`/`en`/`pt`).
2. **Selector "Idioma de la interfaz"** (visible solo con `followDeviceLanguage = false`).
3. **Selector "Idioma que aprendo"** → `setLearningLanguage(code)` (idioma objetivo de las lecciones).
4. **Interruptor "Explicaciones en mi idioma"** → `setAiExplanationsInNative(bool)`.

El selector de idioma del perfil (`profile_edit_screen.dart:608-612`) queda redirigido o eliminado en favor de esta sección (evita dos puntos de edición del mismo ajuste).

---

## 6. Base de datos — cambios necesarios

| Objeto | Cambio |
|---|---|
| `user_settings` | **Añadir columna `follow_device_language BOOLEAN NOT NULL DEFAULT true`** |
| Migración | Nueva migración (p.ej. `YYYYMMDD_add_follow_device_language.sql`) |
| RLS | Verificar política de lectura para el `select` descendente (3.2) — debe permitir `user_id = auth.uid()` |

Los tres campos existentes (`ui_language`, `learning_language`, `ai_explanations_native`) no cambian de contrato.

---

## 7. Diagrama de flujo completo (arranque)

```
[App init]
     │
     ├─ 1. deviceLocale = PlatformDispatcher.locale.languageCode        (normalizado: es|en|pt → default 'es')
     │
     ├─ 2. loadFromPrefs()  ── ui_language / learning_language / ai_explanations_native / follow_device_language
     │        └─ si vacío → aplicar deviceLocale como uiLanguage inicial (1er inicio) y persistir
     │
     ├─ 3. ¿sesión Supabase activa?
     │        └─ sí → fetch user_settings (user_id)
     │                 ├─ existen → poblar prefs + estado (salvo uiLanguage si followDeviceLanguage=true)
     │                 └─ no existen → upsert del registro con defaults resueltos
     │
     └─ 4. effectiveUiLanguageProvider
              ├─ followDeviceLanguage == true  → Locale(deviceLocale)   (si soportado, si no Locale('es'))
              └─ followDeviceLanguage == false → Locale(uiLanguage)
                       │
                       ▼
              MaterialApp.router(locale: ...)   → AppLocalizations resuelve es/en/pt
```

---

## 8. Impacto y orden de implementación

| Paso | Entregable |
|---|---|
| 1 | Añadir `followDeviceLanguage` al modelo + prefs + providers de detección (`deviceLocaleProvider`, `effectiveUiLanguageProvider`). |
| 2 | Migración DB (`follow_device_language`) + política RLS de lectura. |
| 3 | `_syncFromSupabase()` en `UserLanguageNotifier` (lectura descendente + primer registro). |
| 4 | `app.dart` consume `effectiveUiLanguageProvider`. |
| 5 | Sección "Language" en Settings; desactivar el selector duplicado del perfil. |
| 6 | Retirar `LocaleNotifier`/`t()` tras eliminar referencias; migrar `interface_language` → `ui_language`. |
| 7 | (Paralelo, independiente) Externalizar los ~69 textos de UI hardcodeados (inventario en `01_Current_Audit.md`, sección 4) a los ARB. |

**Criterio de aceptación de la arquitectura**: un usuario nuevo con dispositivo en francés ve la UI en francés sin tocar nada (siempre que FR entre en `supportedLocales`), y si desactiva `followDeviceLanguage` y elige "es", la app permanece en español aunque el dispositivo cambie a inglés.
