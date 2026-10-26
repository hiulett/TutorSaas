# 09 — Autenticación, perfiles y usuarios

> Medición: 25-oct-2026. Evidencia: `features/auth/`, `welcome_screen.dart`,
> `onboarding_screen.dart`, `settings_screen.dart`, RPC en producción.

---

## 1. Proveedores y flujos

| Flujo | Implementado | Dónde | Notas |
|---|---|---|---|
| Email + contraseña (login) | ✅ | `welcome_screen.dart:686` → `signInWithPassword` | Timeout 15 s |
| Email + contraseña (registro) | ✅ | `welcome_screen.dart:651` → `signUp` | Con confirmación de email activa, muestra "reenviar" |
| Google Sign-In | ✅ | `welcome_screen.dart:290,329` → `signInWithIdToken` | `serverClientId` hardcodeado; timeouts 25/15/15 s |
| Recuperar contraseña | ✅ | `welcome_screen.dart:516-616` → `resetPasswordForEmail` | Mensaje genérico, no muestra error del backend |
| Reenviar confirmación | ✅ | `welcome_screen.dart:674` | — |
| Anónimo | ⚠️ Repositorio sí, **sin botón** | `auth_repository_impl.dart:57-60` | Funcionalidad muerta |
| Cerrar sesión | ✅ | `dashboard_screen.dart:535`; `settings_screen.dart:430` | Vuelve a `/` |
| Borrar cuenta | ❌ **Sin UI** | RPC `delete_my_account()` existe | `settings_screen.dart` no lo expone |
| Exportar datos | ❌ **Sin UI** | RPC `export_my_data()` existe | Ídem |
| Biometría / PIN | ❌ | — | — |

**Validaciones de registro** (`welcome_screen.dart:623-641`): email no vacío,
regex `^[^@\s]+@[^@\s]+\.[^@\s]+$`, contraseña ≥6. Sin confirmación de contraseña
ni medidor de fuerza.

**Manejo de errores:** `AuthException` se traduce a mensajes accionables para
"email no confirmado" y "ya registrado" (`:697-712`). El resto de errores cae a un
mensaje genérico.

---

## 2. Flujo de autenticación

```mermaid
flowchart TD
  A[App abre] --> B[Supabase.initialize]
  B -->|falla| C[ConfigurationErrorWidget]
  B -->|ok| D[GoRouter /splash]
  D --> E{Sesión?}
  E -- no --> F[Welcome: login/registro]
  E -- sí --> G{¿Fila en user_language_profiles?}
  G -- no --> H[Onboarding 4 pasos]
  G -- sí --> I[/home]
  F -->|email o Google| J[Supabase Auth]
  J --> E
  H -->|saveOnboardingData| K[users + user_language_profiles + user_settings + user_ai_profiles]
  K --> I
```

- La decisión se cachea en memoria y en `SharedPreferences`
  (`nav_has_profile_<uid>`), con timeout de 6 s y fallback a la decisión persistida
  (`navigation_resolver.dart:26-112`).
- `NavigationDecisionEngine.markProfileExists(uid)` se llama al terminar el
  onboarding para evitar la consulta.
- El modo desarrollador **no** salta el login: sin JWT, `llm-proxy` no autentica.

---

## 3. Onboarding (4 pasos reales)

| Paso | Contenido | Se guarda |
|---|---|---|
| 0 | Idioma nativo (8 opciones, preselección por locale) | `users.native_language`, `user_settings` |
| 1 | Idioma objetivo: **solo inglés** | `languages` + `user_language_profiles.language_id` |
| 2 | Clasificación: examen del Oráculo o salto a PRE-A1 | `cefr_level_id`, `game_rank`, `placement_*` |
| 3 | Creación de personaje (clase, meta diaria, intereses) | `user_settings`, `user_language_profiles.player_class/avatar_index` |

Observaciones verificadas:

- El wizard **no pide nombre**: `CharacterCreationData.name` queda vacío
  (`character_creation_wizard.dart:13-23,291-294`); el nombre se toma del email o
  de Google.
- `motivation:'career'`, `tutorPersonality:'friendly'` y
  `learningStyle:'auditory_interactive'` están **hardcodeados**
  (`onboarding_screen.dart:218-230`), aunque existen selectores en ajustes.
- `updateUserProfile` guarda `avatar_url: _characterClass` (la clase como si fuera
  una URL) y una bio fija (`:252-263`). El avatar real es un índice de página.
- Los errores al guardar el perfil se silencian con `catch (_) {}` (`:242-263`);
  el usuario puede quedar con onboarding "completado" y datos parciales.
- El indicador dice "n/4" pero el comentario de la barra habla de 5 pasos.

**Persistencia creada en el onboarding** (`onboarding_repository_impl.dart:10-156`):
`users` (upsert), `languages` (get-or-create), `cefr_levels` (get-or-create),
`user_language_profiles` (upsert), `user_settings` (upsert), `user_ai_profiles`
(upsert con resumen pedagógico y `tutor_prompt_instructions`).

⚠️ El upsert de `user_language_profiles` en un usuario **existente** es un UPDATE:
el trigger `guard_language_profile` descarta `cefr_level_id`. En el alta (INSERT)
sí se permite, por eso el onboarding funciona la primera vez.

---

## 4. Sesiones y recuperación

- Sesión gestionada por `supabase_flutter` (persistencia y refresh automáticos).
- Tras reinstalar, el usuario vuelve a autenticarse; el progreso está en Supabase,
  no en el dispositivo. Las preferencias de idioma se re-sincronizan desde
  `user_settings` solo si no hay valor local (`language_settings.dart:82-103`).
- No hay pantalla de "sesión expirada": si el refresh falla, el router manda a
  Welcome en la siguiente navegación.
- `freezed`/`Supabase` no guardan tokens en `flutter_secure_storage` (dependencia
  declarada y sin uso): la sesión la custodia el SDK.

---

## 5. Perfiles

### Perfil de aprendizaje (`user_language_profiles`)
Nivel CEFR, rango, XP, racha, minutos, oro, gemas, fragmentos, aura, radar,
título equipado, clase, placement. Es la tabla que gobierna la progresión y está
protegida contra escritura del cliente (§ doc 08).

### Perfil social (`users`)
`display_name`, `avatar_url`, `native_language`, `bio`, `str/int/dex/luk`.
Editable en `profile_edit_screen.dart`: nombre, bio, idioma nativo, clase (5 chips
distintos de las 8 del onboarding) y avatar (cámara/galería →
`storage.from('avatars').uploadBinary('avatars/<uid>/<ts>.<ext>')`).

### Preferencias (`user_settings`)
Corrección (5 niveles), personalidad del tutor (3), cadencia (3), meta diaria
(10/15/30/60), intereses, idiomas UI/aprendizaje, explicaciones en nativo,
seguir idioma del dispositivo.

### Perfil de IA (`user_ai_profiles`)
`pedagogical_summary`, `learning_style`, `focus_areas`,
`tutor_prompt_instructions`, `recommended_path_scenarios`. Se escribe en el
onboarding; **no se lee en ningún prompt del pipeline** (el prompt usa CEFR y
`correction_level`).

---

## 6. Roles y permisos

| Rol | Cómo se determina | Alcance |
|---|---|---|
| `authenticated` | JWT de Supabase | Solo sus filas (RLS) |
| `anon` | Sin login | Catálogos públicos y funciones marcadas |
| `admin` | `auth.jwt() -> 'app_metadata' ->> 'role' = 'admin'` | `admin_all` en catálogos, `users`, `user_language_profiles` |
| `service_role` | Clave de servicio (solo Edge Functions) | Escrituras de suscripciones y maná |

El panel `web_admin/` usa el rol `admin` del JWT. No hay roles de "profesor",
"moderador de gremio" persistidos: el moderador de una sala se evalúa por
`chat_room_participants` en la RPC `moderator_stand`.

---

## 7. Hallazgos de seguridad y UX (verificables en código)

| # | Hallazgo | Evidencia | Impacto |
|---|---|---|---|
| 1 | **Herramientas de desarrollador en producción sin gate**: switch "forzar onboarding" y botón rojo que **borra `user_language_profiles`** del usuario | `settings_screen.dart:179, 1257-1346` | Un usuario puede borrar su progreso con un toque; el router lo manda a onboarding |
| 2 | Los chips de CEFR en ajustes intentan cambiar el nivel desde el cliente y el trigger lo descarta | `settings_screen.dart:509-530` → `updateLanguagePreferences` (`onboarding_repository_impl.dart:160-179`) vs `guard_language_profile:32` | El usuario cree que cambió de nivel; no cambia |
| 3 | No se puede borrar la cuenta ni exportar datos desde la app, aunque las RPC existen | `delete_my_account`, `export_my_data` (prod) | Requisito de Play/tiendas y RGPD insatisfecho |
| 4 | Errores de guardado silenciados (`catch (_) {}`) en onboarding y perfil | `onboarding_screen.dart:242-263`; `dashboard_repository_impl.dart:781-817` | Datos parciales sin aviso |
| 5 | Textos de ajustes mezclan ES/EN hardcodeado | `settings_screen.dart:403-409,1178` | Inconsistencia de idioma |
| 6 | `avatar_url` se usa como identificador de clase | `profile_edit_screen.dart:557`; `onboarding_screen.dart:257` | Modelo de datos semánticamente roto |
