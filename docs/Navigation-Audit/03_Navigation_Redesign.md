# Auditoría de Navegación — Documento 3: Rediseño de Navegación Centralizada

> Proyecto: TutorSaas / Dungeon of English (Flutter)
> Fecha: 2026-08-02
> Alcance: Rediseño del flujo de arranque (`/splash`, `/`, `/onboarding`, `/home`) con decisión de navegación centralizada en el router.
> Método: Diseño propuesto sobre datos verificados de `lib/app/router.dart`, `welcome_screen.dart`, `auth_providers.dart` y `onboarding_providers.dart`.

---

## 1. Objetivo

Trasladar la decisión de "a dónde va el usuario al abrir la app" desde el widget `WelcomeScreen` (donde hoy vive de forma distribuida y con un bug) hacia **un único mecanismo centralizado** en `GoRouter`: un `redirect` global + `refreshListenable`.

Se incorpora además un **Splash Screen** como estado de carga que evita el parpadeo actual de la pantalla de Bienvenida mientras se resuelve la sesión.

---

## 2. Arquitectura propuesta (centralizada)

```
                 ┌────────────────────────────────────────────┐
                 │              GoRouter (router.dart)        │
                 │   redirect  +  refreshListenable  +  /splash│
                 └────────────────────────────────────────────┘
                                   │
          ┌────────────────────────┴──────────────────────────┐
          │                                                   │
          ▼                                                   ▼
  SplashScreen                                          NavigationDecisionEngine
  (lib/app/splash_screen.dart)                          (lib/app/navigation_resolver.dart)
  1-2 s mostrando la marca                                │
  │                                                        │  Resuelve la pantalla destino
  │                                                        │  aplicando las reglas en orden
  ▼                                                        ▼
  Navegación dirigida por el redirect                1. Modo Desarrollo
  (el redirect usa el engine para decidir)           2. Autenticación
                                                     3. Onboarding
                                                     4. Dashboard
```

**Principio rector:** la decisión se resuelve **una sola vez y en un solo lugar**. Las pantallas no navegan por sí solas según su estado; solo el router decide, y cualquier cambio de estado (sesión, modo dev) vuelve a ejecutar el `redirect`.

### 2.1 Componentes nuevos

| Componente | Archivo propuesto | Responsabilidad |
|------------|-------------------|-----------------|
| `SplashScreen` | `lib/app/splash_screen.dart` | Pantalla de marca del juego (1-2 s). No decide nada; solo da tiempo a que la sesión y el modo dev se resuelvan, y deja que el `redirect` actúe. |
| `NavigationDecisionEngine` | `lib/app/navigation_resolver.dart` | Función/clase pura que, dados (usuario, modo dev, perfil), devuelve la ruta destino. Contiene el orden de reglas. |
| `navigationRefreshProvider` (o similar) | `lib/app/navigation_resolver.dart` | `Listenable` que el router observa vía `refreshListenable`; se notifica cada vez que cambian `currentUserProvider` / `devAlwaysShowOnboardingProvider`. |

### 2.2 Componentes modificados

| Componente | Cambio |
|------------|--------|
| `lib/app/router.dart` | `initialLocation: '/splash'`; añadir `redirect` global; añadir `refreshListenable`; registrar la ruta `/splash`; mantener `/` → `WelcomeScreen`. |
| `lib/features/onboarding/.../welcome_screen.dart` | **Eliminar `_redirectUser`** y el `addPostFrameCallback` del `build`. La pantalla solo muestra login/registro y, al completar registro, llama `context.go('/onboarding')` (la siguiente decisión la toma el router). |

---

## 3. Diagrama de flujo correcto (destino)

```
                ARRANQUE DE LA APP
                      │
                      ▼
        router.dart: initialLocation: '/splash'
                      │
                      ▼
              SplashScreen (1-2 s)
              ─ se resuelve sesión (currentUserProvider)
              ─ se resuelve modo dev (devAlwaysShowOnboardingProvider)
                      │
                      ▼
        GoRouter ejecuta redirect (para '/splash' y cualquier navegación)
                      │
      ┌───────────────┴──────────────────────────┐
      ▼                                          ▼
  devAlwaysShowOnboarding == true       devAlwaysShowOnboarding == false
      │                                          │
      ▼                                          ▼
  SIEMPRE /onboarding                    ¿hay sesión (User != null)?
      │                                          │            │
      │                                        SÍ             NO
      │                                          │            │
      │                                          ▼            ▼
      │                               ¿existe perfil en       /
      │                               user_language_profiles  │
      │                                    │           │       │
      │                                  SÍ            NO      │
      │                                    │           │       │
      │                                    ▼           ▼       │
      │                                 /home       /onboarding
      │                                              │
      │                                              │
      └───────────────► (dev siempre gana sobre todo) ┘
```

Reglas de prioridad aplicadas en orden:

```
1. Modo Desarrollo   →  /onboarding   (gana SIEMPRE, ignora sesión)
2. Autenticación     →  sin sesión → /  (WelcomeScreen)
3. Onboarding        →  con sesión y SIN perfil → /onboarding
4. Dashboard         →  con sesión y CON perfil → /home
```

---

## 4. Reglas de navegación (orden obligatorio)

| # | Regla | Condición | Destino |
|---|-------|-----------|---------|
| 1 | **Modo Desarrollo** | `devAlwaysShowOnboardingProvider == true` | `/onboarding` — prioridad máxima, ignora la sesión y el perfil. |
| 2 | **Autenticación** | `currentUserProvider == null` (sin sesión) | `/` (WelcomeScreen). |
| 3 | **Onboarding** | Sesión activa **y** no existe fila en `user_language_profiles` para el `user.id` | `/onboarding`. |
| 4 | **Dashboard** | Sesión activa **y** existe perfil en `user_language_profiles` | `/home`. |

### 4.1 Notas sobre el invariante

- **Invariante del producto:** ningún usuario con sesión puede llegar a `/home` sin haber completado el onboarding.
- En el flujo actual este invariante se viola (Caso 2: `isReg == false` → siempre `/home` sin consultar perfil). El rediseño lo garantiza porque la consulta de perfil pasa a ser **obligatoria e incondicional** en las reglas 3 y 4.
- El `isRegisteringProvider` **ya no forma parte de la decisión**. La existencia del perfil se consulta siempre que haya sesión, independientemente de si el usuario acaba de registrarse o está reabriendo la app.

---

## 5. Cómo implementan las reglas `redirect` + `refreshListenable` (go_router v14)

### 5.1 `redirect` centralizado

`go_router` v14.0.0 permite un **`redirect` global** (`FutureOr<String?>`), es decir, **puede ser `async`**. Esto es clave: la regla 3 necesita consultar `user_language_profiles` (llamada a Supabase), y el `redirect` async de go_router 14 lo soporta sin necesidad de trucos.

Firma propuesta (pseudo-código Dart):

```dart
// lib/app/navigation_resolver.dart
Future<String?> navigationRedirect(
  GoRouterState state,
  User? currentUser,
  bool devAlwaysShowOnboarding,
) async {
  // 1) Modo Desarrollo — prioridad máxima, ignora sesión y perfil.
  if (devAlwaysShowOnboarding) {
    return state.matchedLocation == '/onboarding' ? null : '/onboarding';
  }

  // 2) Sin sesión → WelcomeScreen (salvo que ya esté ahí).
  if (currentUser == null) {
    return state.matchedLocation == '/' ? null : '/';
  }

  // Con sesión: si ya está en la pantalla "correcta" según perfil, no redirigir.
  final hasProfile = await _hasLanguageProfile(currentUser.id); // consulta Supabase

  // 3) Onboarding pendiente.
  if (!hasProfile) {
    return state.matchedLocation == '/onboarding' ? null : '/onboarding';
  }

  // 4) Dashboard.
  return state.matchedLocation == '/home' ? null : '/home';
}

bool _hasLanguageProfile(String userId) async {
  final row = await Supabase.instance.client
      .from('user_language_profiles')
      .select('id')
      .eq('user_id', userId)
      .maybeSingle();
  return row != null;
}
```

### 5.2 Conectarlo en `router.dart`

```dart
final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: navigationRefreshListenable, // Listenable de Riverpod/ChangeNotifier
  redirect: (context, state) {
    final user = ref.read(currentUserProvider);
    final dev = ref.read(devAlwaysShowOnboardingProvider);
    return navigationRedirect(state, user, dev); // Future<String?> — async OK en v14
  },
  routes: [ /* 23 rutas existentes + '/splash' */ ],
);
```

### 5.3 `refreshListenable`

El `refreshListenable` le dice a `GoRouter` **cuándo re-evaluar el `redirect`**:

- **Qué observa:** un `Listenable` que notifica cada vez que cambia `currentUserProvider` (login, logout, restauración de sesión) o `devAlwaysShowOnboardingProvider` (toggle del modo dev en Ajustes).
- **Cómo se implementa en Riverpod:** un `ChangeNotifier` / `Listenable` que hace `ref.listen` sobre ambos providers y llama `notifyListeners()` (o un `StateProvider` puente). Cuando ocurre el evento, `GoRouter` re-ejecuta el `redirect` sobre la ruta actual.
- **Por qué importa:** sin `refreshListenable`, el `redirect` solo correría al navegar; el `Listenable` garantiza que el router actúe también ante cambios de estado **no** derivados de una navegación (p. ej. cerrar sesión, caducar la sesión, o activar el modo dev).

### 5.4 `initialLocation: '/splash'`

- La app arranca en `/splash` en lugar de `/`.
- `SplashScreen` se muestra 1-2 s; durante ese tiempo la sesión y el modo dev se resuelven.
- El `redirect` actúa sobre `/splash`: al resolverse el estado, navega al destino correcto (regla 1-4). El Splash nunca "decide", solo espera.
- Como el Splash no requiere sesión ni perfil, el `redirect` debe **no redirigir** mientras `matchedLocation == '/splash'` (o devolver `null` para `/splash`), para no romper el arranque. Se recomienda:
  - Si `state.matchedLocation == '/splash'`: consultar el estado y reenviar al destino, salvo que el estado aún esté resolviéndose (sesión `null` en estado loading), en cuyo caso devolver `null` y esperar a que `refreshListenable` dispare.

---

## 6. Beneficios frente al flujo actual

| Aspecto | Hoy | Rediseño |
|---------|-----|----------|
| Lugar de la decisión | `WelcomeScreen._redirectUser` (widget) | `redirect` del router (un solo lugar) |
| Bug Caso 2 (sesión sin onboarding) | ❌ se salta a `/home` | ✅ el router consulta siempre el perfil |
| Parpadeo de Welcome | ❌ flash con sesión persistida | ✅ Splash absorbe la resolución |
| Cambio de sesión en runtime | Decisión por frame (`addPostFrameCallback`) | `refreshListenable` re-ejecuta el guard |
| Modo dev | Tratado como caso aparte dentro del widget | Regla 1, prioridad máxima, central |
| Testeabilidad | Difícil (acoplada a widget y frame) | Fácil (engine puro + casos en tabla, ver Doc 05) |

---

## 7. Riesgos y mitigaciones del rediseño

| Riesgo | Mitigación |
|--------|-----------|
| `redirect` en bucle infinito (ej. `/onboarding` → `/home` → `/onboarding`). | Devolver `null` cuando `matchedLocation` ya es el destino correcto (ver pseudo-código). Es la guardia estándar de go_router. |
| Consulta extra a Supabase en cada re-evaluación del redirect. | Cachear el resultado por sesión (ej. invalidar al cambiar de `user.id`); el `redirect` solo debe consultar perfil cuando hay sesión y no está cacheado. |
| Sesión aún cargando (estado intermedio) → redirect agresivo. | Durante `/splash` y mientras el estado de sesión es loading, devolver `null`; dejar que `refreshListenable` dispare cuando el estado se resuelva. |
| Perfil consultado con sesión válida pero `user_language_profiles` inaccesible (RLS/red). | Lógica de degradación: si la consulta falla, no redirigir a `/home`; redirigir a `/onboarding` (seguro) y registrar el error (ver logs en Doc 05). |
| `isRegisteringProvider` usado en otro flujo. | No se elimina el provider, solo se **quita de la decisión de navegación**; el flujo de registro lo puede seguir usando si lo necesita. |
| `redirect` async puede ejecutarse varias veces con resultados distintos si cambia el estado a mitad de la consulta. | El `redirect` debe ser idempotente (basarse en el estado leído en ese momento) y el router ya maneja las re-evaluaciones vía `refreshListenable`. |

---

*Siguiente documento: `04_Implementation_Plan.md` — plan por fases para implementar el rediseño.*
