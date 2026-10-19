# Auditoría Forense de Navegación — Documento 1: Flujo Actual

> Proyecto: TutorSaas / Dungeon of English (Flutter)
> Fecha de auditoría: 2026-08-02
> Alcance: Navegación de arranque (`/`, `/onboarding`, `/home`) y guardias de onboarding
> Método: Hallazgos verificados sobre el código fuente (no se re-analizó el código en esta sesión)

---

## 1. Resumen ejecutivo

La navegación de la app depende de **una decisión distribuida dentro de un widget** (`WelcomeScreen`), no de un mecanismo centralizado. El router `GoRouter` no tiene `redirect` ni guard global, y la app no tiene Splash Screen. Esto produce un flujo de arranque incoherente y rompe el **Caso 2** (usuario registrado que todavía no completó el onboarding), que es justamente el caso crítico de la primera apertura después del registro.

---

## 2. Mapa de rutas actual (código)

### 2.1 `lib/app/router.dart` (138 líneas)

```
GoRouter(
  initialLocation: '/',
  routes: [
    ... 23 rutas registradas
  ],
)
```

- `initialLocation: '/'` → la primera pantalla renderizada es `WelcomeScreen`.
- **NO existe `redirect`** en el objeto `GoRouter`.
- **NO existe guard centralizado** de autenticación ni de onboarding.
- Rutas relevantes para esta auditoría:
  - `/` → `WelcomeScreen`
  - `/onboarding` → `OnboardingScreen`
  - `/home` → `DashboardScreen`

### 2.2 `lib/app/app.dart`

```
MaterialApp.router(routerConfig: appRouter)
```

La app delega toda la navegación al `appRouter`. No hay `home:` alternativo ni lógica de arranque en el widget raíz.

### 2.3 `lib/main.dart`

```
1. Inicializa Supabase
2. runApp(ProviderScope(child: TutorSaaSApp()))
```

- **NO hay Splash Screen** entre la inicialización y la primera pantalla.
- `ProviderScope` se monta en la raíz, por lo que los providers de Riverpod (incluida la sesión) ya están vivos al arrancar.

### 2.4 `lib/features/onboarding/presentation/screens/welcome_screen.dart`

`_redirectUser(User)` (líneas 26-55):

| Paso | Líneas | Lógica |
|------|--------|--------|
| 1 | ~27-29 | Lee `devAlwaysShowOnboardingProvider` → si `true`, `context.go('/onboarding')` (modo dev). |
| 2 | ~31-33 | Lee `isRegisteringProvider` (`StateProvider<bool>`, default `false`). |
| 3 | ~35-44 | Si `isReg == true` (registro en curso): consulta `user_language_profiles` por `user_id`. Si existe perfil → `/home`; si no → `/onboarding`. |
| 4 | ~47-49 | Si `isReg == false`: **SIEMPRE `context.go('/home')`**, SIN comprobar `user_language_profiles`. |

`build()` (líneas 64-68):

```
if (currentUserProvider no es null) {
  WidgetsBinding.instance.addPostFrameCallback((_) => _redirectUser(user));
}
```

### 2.5 Providers involucrados

| Provider | Tipo | Comportamiento |
|----------|------|----------------|
| `currentUserProvider` (`auth_providers.dart`) | `Provider<User?>` | Lee `authStateProvider` (`StreamProvider` de sesión Supabase) → `state.session?.user`. Con sesión persistida, devuelve `User` (no-null). |
| `isRegisteringProvider` | `StateProvider<bool>` | Default `false`. Se pone a `true` solo durante el registro. |
| `devAlwaysShowOnboardingProvider` | `StateNotifier<bool>` | Modo dev. Persistido en `SharedPreferences` con clave `'dev_always_show_onboarding'`. |

---

## 3. Diagrama de texto del flujo actual

```
                ARRANQUE DE LA APP
                      │
                      ▼
        main.dart: init Supabase → ProviderScope → runApp
                      │
                      ▼
        router.dart: initialLocation: '/'  (SIN redirect)
                      │
                      ▼
        WelcomeScreen.build()
                      │
          ┌───────────┴───────────────┐
          │                           │
    currentUserProvider == null    currentUserProvider != null
      (sin sesión)                   (sesión persistida)
          │                           │
          ▼                           ▼
  Se muestra la pantalla      addPostFrameCallback
  de Bienvenida (login /       → _redirectUser(user)
  registro)     ┌──────────────────────────────────────┐
                │                                      │
    devAlwaysShowOnboarding == true               devAlwaysShowOnboarding == false
                │                                      │
                ▼                                      ▼
       context.go('/onboarding')              isRegisteringProvider?
                                                 │            │
                                            true           false
                                                 │            │
                                                 ▼            ▼
                                   ¿existe perfil en          context.go('/home')
                                   user_language_profiles?      (SIN verificar perfil)
                                        │           │
                                      sí            no
                                        │           │
                                        ▼           ▼
                                  context.go   context.go
                                   ('/home')    ('/onboarding')
```

---

## 4. Tabla de escenarios: qué pasa HOY

| Caso | Descripción | `isRegisteringProvider` | Perfil en `user_language_profiles` | Qué pasa HOY | Resultado |
|------|-------------|-------------------------|-----------------------------------|--------------|-----------|
| **Caso 1** | Usuario nuevo, sin sesión. | `false` | n/a | `currentUserProvider == null` → no se ejecuta `_redirectUser`. Se muestra `WelcomeScreen` (login/registro). | ✅ Correcto |
| **Caso 2** | Usuario con sesión persistida que **nunca completó el onboarding** (primera apertura tras registrarse). | `false` (lo normal al abrir la app con sesión guardada) | NO existe | `_redirectUser` → rama `isReg == false` → **`context.go('/home')` directamente**. | ❌ **ROTO**: se salta el onboarding. |
| **Caso 3** | Registro en curso (flujo de registro activo). | `true` | NO existe todavía | Consulta `user_language_profiles` → no existe perfil → `context.go('/onboarding')`. | ✅ Correcto (depende de que `isRegisteringProvider` esté en `true` durante todo el registro). |
| **Caso 4** | Usuario con sesión persistida que **ya completó el onboarding** (reabre la app). | `false` | SÍ existe | `_redirectUser` → rama `isReg == false` → `context.go('/home')`. | ✅ Correcto por coincidencia (no por diseño: nunca consulta el perfil). |
| **Caso extra** | Modo dev con `devAlwaysShowOnboarding == true`. | cualquiera | cualquiera | `context.go('/onboarding')` siempre. | ⚠️ Solo dev. |

**Conclusión de la tabla:** el Caso 2 es el único que falla, pero es el más importante del producto: la **primera experiencia de un usuario recién registrado**. El Caso 4 "funciona" solo por coincidencia — la rama `isReg == false` no distingue entre un usuario que completó el onboarding y uno que no.

---

## 5. Comparación: flujo esperado vs flujo actual

### Flujo esperado (contrato del producto)

```
Arranque
  → Splash Screen (mientras se resuelve la sesión)
    → sin sesión            → WelcomeScreen (login / registro)
    → con sesión            → ¿existe user_language_profiles?
                              ├─ no  → /onboarding
                              └─ sí  → /home
```

Reglas de negocio esperadas:

1. **Ningún usuario con sesión puede llegar a `/home` sin haber completado el onboarding** (invariante de producto).
2. La decisión de a dónde ir debe tomarse **una sola vez, en un solo lugar** (guard centralizado en el router).
3. Mientras la sesión se resuelve, debe mostrarse un **estado de carga** (Splash) para evitar parpadeos.

### Flujo actual

| Regla esperada | Estado actual | Evidencia |
|----------------|---------------|-----------|
| 1. Invariante: no llegar a `/home` sin onboarding | ❌ **Incumplida** | `_redirectUser`, rama `isReg == false` → siempre `/home` (líneas 47-49 de `welcome_screen.dart`). |
| 2. Decisión centralizada (guard en router) | ❌ **No existe** | `router.dart` no tiene `redirect` ni guard. |
| 3. Splash / estado de carga mientras resuelve sesión | ❌ **No existe** | `main.dart` → `runApp` directo; `initialLocation: '/'`. |

---

## 6. Parpadeo de la pantalla de Bienvenida

Dado que `WelcomeScreen.build()` redirige mediante `addPostFrameCallback` cuando hay sesión:

- La primera frame renderiza `WelcomeScreen`.
- Tras el callback del frame, `context.go('/home')` reemplaza la pantalla.
- En la práctica el usuario ve un **flash / parpadeo** de la pantalla de Bienvenida antes de aterrizar en el destino real.
- Con sesión persistida y sin onboarding, el usuario ve el flash de Bienvenida y luego cae en `/home` sin haber hecho onboarding (Caso 2).

---

## 7. Datos de referencia para el equipo

| Archivo | Rol en la navegación |
|---------|----------------------|
| `lib/app/router.dart` | Define `GoRouter` (138 líneas, 23 rutas, sin `redirect`). |
| `lib/app/app.dart` | `MaterialApp.router(routerConfig: appRouter)`. |
| `lib/main.dart` | Init Supabase → `ProviderScope` → `runApp` (sin Splash). |
| `lib/features/onboarding/presentation/screens/welcome_screen.dart` | Aloja la lógica de redirección (`_redirectUser`, líneas 26-55; `build`, 64-68). |
| `lib/features/auth/.../auth_providers.dart` | `currentUserProvider` (sesión) y `isRegisteringProvider`. |
| `lib/core/...` (modo dev) | `devAlwaysShowOnboardingProvider`, key `'dev_always_show_onboarding'`. |

---

*Siguiente documento: `02_Root_Cause.md` — causa raíz y análisis de fragilidad arquitectónica.*
