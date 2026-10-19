# Modo Desarrollador (Mostrar Onboarding Siempre) — Hallazgo 06

> **Ámbito:** Flujo de redirección post-login + pantalla de Configuración
> **Archivos:**
> - `lib/features/onboarding/presentation/screens/welcome_screen.dart`
> - `lib/features/dashboard/presentation/screens/settings_screen.dart`
> - `lib/features/dashboard/presentation/providers/dashboard_providers.dart`
> - `lib/features/dashboard/domain/models/user_settings.dart`
> - `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`
> - `supabase/migrations/` (nueva migración propuesta)
> **Tipo:** Tooling QA / configuración de usuario / persistencia
> **Estado:** Propuesta — sin cambios de código

---

## 1. Estado actual

### 1.1 Redirección del Welcome (`welcome_screen.dart`)

`_redirectUser(nextUser)` (`welcome_screen.dart:25-49`) decide el destino tras login:

- Si `isRegisteringProvider == true` → consulta `user_language_profiles` en busca del perfil del usuario:
  - existe perfil → `context.go('/home')` (`:36-37`)
  - sin perfil → `context.go('/onboarding')` (`:38-39`)
- Si `isRegisteringProvider == false` → **siempre** `context.go('/home')`, sin consultar el perfil (`:41-44`).
- Cualquier error en la consulta → `context.go('/onboarding')` (`:45-48`).

El disparo se hace desde el `build` cuando `currentUserProvider != null` (`:58-62`), vía `addPostFrameCallback`.

### 1.2 No existe flag de «mostrar siempre»

Búsqueda exhaustiva en `lib/` por `show_onboarding | developer_mode | always_show | force_onboarding | modo_desarrollador`: **sin coincidencias**. No hay interruptor de QA para forzar el onboarding.

### 1.3 Configuración del usuario (settings + persistencia)

- `SettingsScreen` es el tab Config del dashboard (`dashboard_screen.dart:166-167`) y consume `userSettingsProvider` (`settings_screen.dart:31`).
- `userSettingsProvider` es un `StateNotifierProvider` (`dashboard_providers.dart:85-89`) que construye `UserSettingsNotifier` (`:52-83`):
  - Inicializa con `UserSettings.initial()` (`:56`).
  - Carga desde DB en `_loadSettings` (`:60-68`) — **sin await en el constructor** (fire-and-forget).
  - `updateSetting(key, value)` persiste una clave (`:70-76`).
  - `updateAllSettings(settings)` persiste el mapa completo (`:78-82`).
- Modelo `UserSettings` (`user_settings.dart`): campos actuales `correctionLevel, correctionStyle, tutorPersonality, dailyGoalMinutes, notificationsEnabled, notificationTime, interests, motivation` (`:2-9`). **No incluye ningún flag de desarrollador.**
- Persistencia vía `DashboardRepositoryImpl`:
  - `getUserSettings(userId)` → `SELECT * ... maybeSingle()` (`dashboard_repository_impl.dart:474-485`), devolviendo `{}` si no hay fila.
  - `updateUserSettings(userId, settings)` → `upsert` con `onConflict: 'user_id'`, quitando `id` (`:488-500`).
- **Columnas reales de `user_settings` (verificadas en Supabase, project `sipiumfdpvnszthykyog`):**

  `id` (uuid PK, default `gen_random_uuid()`), `user_id` (uuid, NOT NULL), `correction_style` (varchar, default `'balanced'`), `tutor_personality` (varchar, default `'friendly'`), `tutor_voice_id` (varchar), `daily_goal_minutes` (int, default `15`), `notifications_enabled` (bool, default `true`), `notification_time` (time, default `'09:00:00'`), `interests` (text[]), `motivation` (text, default `'general'`), `correction_level` (varchar, default `'short'`), `ui_language` (varchar, default `'es'`), `learning_language` (varchar, default `'en'`), `ai_explanations_native` (bool, default `true`).

  **No existe columna tipo `always_show_onboarding`.**

---

## 2. Hallazgos con evidencia

### Hallazgo 6.1 — No hay forma de re-testear el onboarding tras completarlo

**Evidencia:**
- La única rama a `/onboarding` es la de `isRegisteringProvider == true` + sin perfil, o un error de red (`welcome_screen.dart:38-39`, `:45-48`).
- Un usuario con perfil completo (`user_language_profiles` poblado) **siempre** va a `/home`.

**Problema:**
- QA, producto y el propio usuario no pueden repetir el wizard de onboarding (test de colocación, idiomas, intereses) sin borrar el perfil en DB o tocar RLS directamente. No existe flag de «mostrar siempre».

**Justificación:**
- Un switch «Modo desarrollador / Mostrar onboarding siempre» habilita loops de QA sin tocar datos de producción y sirve como modo demostración.

**Impacto (qué se gana):**
- QA puede validar el onboarding completo tantas veces como quiera; facilita capturas y demos.

### Hallazgo 6.2 — El flag debe vivir donde ya persisten los ajustes (tabla `user_settings`)

**Evidencia:**
- Toda la configuración persistente del usuario vive en `user_settings`, con upsert idempotente por `user_id` (`dashboard_repository_impl.dart:488-500`).
- La columna propuesta `always_show_onboarding` seguiría el patrón de las existentes (`notifications_enabled`, `ai_explanations_native`) con default booleano.

**Problema (alternativa descartada):**
- Un flag solo local (`shared_preferences`) sería más rápido para QA pero no sobrevive a reinstalaciones ni se comparte entre dispositivos; además fragmenta la fuente de verdad de configuración (SFX ya es local vía `sfxEnabledProvider`, pero eso es cosmético).

**Justificación:**
- Persistir en `user_settings` mantiene la configuración del usuario en un solo lugar, sincronizada y respetuosa de RLS (columnas nuevas heredan las políticas existentes de la tabla).

**Impacto (qué se gana):**
- El flag sobrevive a reinstalaciones, es visible en la web admin si se desea, y se reutiliza el camino de escritura ya probado (upsert).

### Hallazgo 6.3 — Riesgo de carrera al leer el flag en `welcome_screen`

**Evidencia:**
- `UserSettingsNotifier._loadSettings` se dispara en el constructor sin `await` (`dashboard_providers.dart:56-68`).
- `_redirectUser` se dispara vía `addPostFrameCallback` (`welcome_screen.dart:58-62`), que puede ejecutarse **antes** de que termine la carga asíncrona del notifier.
- Un usuario recién registrado puede no tener fila en `user_settings` → `getUserSettings` devuelve `{}` (`dashboard_repository_impl.dart:481`) → el flag debe leerse como `false` por defecto.

**Problema:**
- Si el switch se lee del `userSettingsProvider` (notifier) puede devolver el default inicial (`false`) aunque el flag real sea `true` en DB, según el orden de los microtasks.

**Justificación (mitigación de diseño):**
- Leer el flag en `welcome_screen` a través de un **`FutureProvider.autoDispose` dedicado** que haga la consulta directa a `user_settings` (con fallback `false`), y `await`-arlo dentro de `_redirectUser` **antes** de decidir `/onboarding` vs `/home`. Así se elimina la dependencia del estado interno del notifier.

**Impacto (qué se gana):**
- Decisión de redirección determinista y sin carreras; el onboarding nunca se fuerza por un default incorrecto ni se omite por una carga tardía.

---

## 3. Diseño propuesto

### 3.1 Base de datos (migración)

```sql
-- Migración propuesta (aplicar vía SQL editor o supabase/migrations/<timestamp>_add_always_show_onboarding.sql)
alter table public.user_settings
  add column if not exists always_show_onboarding boolean not null default false;
```

- Default `false` = comportamiento actual (no rompe a usuarios existentes).
- Las políticas RLS existentes de la tabla cubren automáticamente la nueva columna (misma tabla, mismo `user_id`).

### 3.2 Modelo (`user_settings.dart`)

- Nuevo campo `final bool alwaysShowOnboarding;` con default `false`.
- `UserSettings.initial()` → `alwaysShowOnboarding: false`.
- `fromJson` → `json['always_show_onboarding'] as bool? ?? false`.
- `toJson` → `'always_show_onboarding': alwaysShowOnboarding`.
- `copyWith` → parámetro `bool? alwaysShowOnboarding`.

> Nota: `updateSetting('always_show_onboarding', value)` ya persiste vía upsert sin tocar el repo (el mapa `toJson()` incluirá la nueva clave y `updateUserSettings` limpia solo `id`).

### 3.3 Provider (`dashboard_providers.dart`)

Opción A (recomendada, evita la carrera del Hallazgo 6.3):

```dart
final alwaysShowOnboardingProvider = FutureProvider.autoDispose<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  try {
    final supabase = ref.read(supabaseClientProvider);
    final data = await supabase
        .from('user_settings')
        .select('always_show_onboarding')
        .eq('user_id', user.id)
        .maybeSingle();
    return data?['always_show_onboarding'] as bool? ?? false;
  } catch (_) {
    return false;
  }
});
```

Opción B (más simple, si se acepta la carga del notifier): exponer getter en `UserSettingsNotifier` (`state.alwaysShowOnboarding`) y leer `userSettingsProvider` con el default de `UserSettings.initial()`.

### 3.4 Pantalla de configuración (`settings_screen.dart`)

- Nueva sección (p. ej. «QA / DEVELOPER») bajo «AUDIO & COMMUNICATIONS» y sobre «ACCOUNT» (`settings_screen.dart:135-142`).
- Tile `GlassCard` con `Switch` (mismo patrón que `_buildNotificationTiles`, `:676-795`), etiqueta «MODO DESARROLLADOR» + subtítulo «Mostrar onboarding siempre al iniciar sesión».
- Persistencia **inmediata** al alternar (como el SFX, `:717-719`), vía `ref.read(userSettingsProvider.notifier).updateSetting('always_show_onboarding', value)` — sin depender del botón «SAVE CONFIGURATION», para que QA no tenga que guardar manualmente.

### 3.5 Redirección (`welcome_screen.dart`)

Dentro de `_redirectUser` (`:25-49`), **antes** de la rama actual:

```dart
final alwaysShow = await ref.read(alwaysShowOnboardingProvider.future);
if (alwaysShow) {
  context.go('/onboarding');
  return;
}
// … rama actual sin cambios
```

- ON → `/onboarding` siempre (haya perfil o no).
- OFF → comportamiento actual intacto (incluida la rama `isRegisteringProvider`).

---

## 4. Análisis de persistencia / almacenamiento

| Aspecto | Decisión | Justificación |
|---------|----------|---------------|
| Dónde persiste | Columna `user_settings.always_show_onboarding` | Coherente con el resto de configuración; upsert idempotente ya probado (`dashboard_repository_impl.dart:488-500`) |
| Default | `false` | No altera el comportamiento de usuarios existentes |
| Ciclo de vida | Por usuario, en Supabase | Sobrevive reinstalaciones; sincronizado entre dispositivos |
| Lectura en welcome | `FutureProvider` con `await` | Evita la carrera con `_loadSettings` del notifier (Hallazgo 6.3) |
| Usuarios sin fila | `maybeSingle()` devuelve `null` → `false` | Mismo comportamiento que hoy (fallback elegante) |
| Facilidad para QA | Switch de persistencia inmediata en Config | QA no depende del botón guardar; el próximo login muestra el onboarding |

Alternativa considerada: `shared_preferences` (local). Se descarta como fuente principal por fragmentar la fuente de verdad; podría añadirse como override local de emergencia si se requiere QA sin red, pero no es la propuesta.

---

## 5. Impacto

- **QA:** validación repetible del wizard de onboarding (test de colocación, idiomas, intereses) sin tocar DB.
- **Producto:** modo demo para presentaciones.
- **Usuarios:** sin impacto (flag OFF por defecto = comportamiento actual).
- **Arquitectura:** sin dependencias nuevas; se reutiliza `supabaseClientProvider`, `userSettingsProvider` y el patrón de `StateNotifierProvider`/`FutureProvider.autoDispose`.
- **Seguridad:** la nueva columna hereda las políticas RLS de `user_settings`; el flag es por usuario.

---

## 6. Riesgos

| Riesgo | Mitigación |
|--------|-----------|
| Carrera de carga al leer el flag en welcome (ver Hallazgo 6.3) | Usar `FutureProvider` dedicado + `await` dentro de `_redirectUser`; no depender del estado interno del notifier |
| Olvidar regenerar l10n tras añadir claves | Añadir claves en `app_en.arb`, `app_es.arb`, `app_pt.arb` y ejecutar `flutter gen-l10n` |
| `updateAllSettings` sobrescriba el flag con el valor local stale | El modelo incluye el campo en `toJson()`, y `SettingsScreen` guarda `currentSettings` completo; mantener el flag en el `copyWith` para no pisarlo |
| Migración no aplicada a la DB de producción | Aplicar vía SQL editor o `supabase/migrations/`; verificar con `select` antes de probar el switch |
| Olvidar el default `false` y forzar onboarding a todos | Columna con `not null default false`; lectura con `?? false` |
| Loop infinito onboarding ↔ welcome | El flag solo redirige a `/onboarding`; completar el wizard no apaga el flag (es manual en Config). Documentar que el flujo normal (OFF) es el de producción |

---

## 7. Resultado esperado

- Un switch «Modo desarrollador / Mostrar onboarding siempre» en Config (`settings_screen.dart`) que persiste en `user_settings.always_show_onboarding`.
- Con el flag ON, `welcome_screen` redirige **siempre** a `/onboarding` (haya perfil o no); con OFF, comportamiento actual intacto.
- QA puede iterar el onboarding tantas veces como necesite, sin borrar `user_language_profiles` ni usar credenciales de admin.
- Cero regresiones para usuarios finales (default `false`).
