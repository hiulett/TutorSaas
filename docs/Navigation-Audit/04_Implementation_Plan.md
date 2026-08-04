# Auditoría de Navegación — Documento 4: Plan de Implementación

> Proyecto: TutorSaas / Dungeon of English (Flutter)
> Fecha: 2026-08-02
> Alcance: Implementación del rediseño de navegación centralizada (Splash + Navigation Decision Engine + redirect/refreshListenable + simplificación de WelcomeScreen).
> Precedente: Documento 03 — `03_Navigation_Redesign.md`

---

## 0. Resumen del plan

| Fase | Entregable | Archivos principales | Salida verificable |
|------|------------|----------------------|--------------------|
| **F1** | SplashScreen | `lib/app/splash_screen.dart` | Pantalla de marca 1-2 s. |
| **F2** | NavigationDecisionEngine + Listenable | `lib/app/navigation_resolver.dart` | `navigationRedirect(...)` + `navigationRefreshListenable`. |
| **F3** | Router centralizado | `lib/app/router.dart` | `initialLocation: '/splash'`, `redirect`, `refreshListenable`, ruta `/splash`. |
| **F4** | Simplificar WelcomeScreen | `welcome_screen.dart` | `_redirectUser` eliminado; registro → `context.go('/onboarding')`. |
| **F5** | QA | — | `flutter analyze` (0 errores), `flutter test`, build OK. |

Regla de oro durante toda la implementación (ver AGENTS.md): **nunca usar `git checkout`/`git restore`** sobre archivos Dart para "deshacer". Si algo falla, se corrige editando.

---

## F1 — Crear `SplashScreen`

### Objetivo
Mostrar la marca del juego durante 1-2 s mientras la sesión (`currentUserProvider`) y el modo dev (`devAlwaysShowOnboardingProvider`) se resuelven.

### Pasos
1. Crear `lib/app/splash_screen.dart` con un `ConsumerStatefulWidget` (o `StatefulWidget` + `Consumer`).
2. En `initState` (o `build` con timer), programar una pausa mínima de **1-2 s** (p. ej. `Timer` o `Future.delayed`).
3. Renderizar el branding del juego siguiendo el tema Isekai (usar `AppColors` — nunca hex hardcodeado — y tipografías del tema). Reutilizar `CyberManhwaBackground` si se desea.
4. **No contener ninguna lógica de navegación.** El Splash solo espera; el destino lo decide el `redirect` del router (que actúa sobre `/splash`).
5. Opcional: mostrar el log `"Splash iniciado"` (ver Doc 05, sección de logs).

### Verificación
- `flutter analyze`: 0 errores.
- Navegación manual: al abrir la app se ve el Splash 1-2 s antes del destino.

### Riesgos
- Riesgo: añadir aquí la decisión de destino (repetiría el bug de WelcomeScreen). **Mitigación:** el Splash no recibe providers ni llama a `context.go`; el router decide.
- Riesgo: parpadeo si el timer es muy corto y la sesión aún se resuelve. **Mitigación:** el Splash espera también a que `currentUserProvider` deje de estar en loading antes de permitir que el redirect lo reemplace (o el redirect devuelve `null` mientras el estado de sesión es loading).

---

## F2 — Crear `NavigationDecisionEngine` (provider/helper central)

### Objetivo
Centralizar en **un solo lugar** las 4 reglas de navegación en orden estricto.

### Pasos
1. Crear `lib/app/navigation_resolver.dart`.
2. Definir la función central:

```dart
Future<String?> navigationRedirect(
  GoRouterState state,
  User? currentUser,
  bool devAlwaysShowOnboarding,
)
```

   Que implementa, en orden:
   - **Regla 1 — Modo Desarrollo:** si `devAlwaysShowOnboarding` → `/onboarding` (o `null` si ya está en `/onboarding`).
   - **Regla 2 — Autenticación:** si `currentUser == null` → `/` (o `null` si ya está en `/`).
   - **Regla 3 — Onboarding:** si no existe fila en `user_language_profiles` → `/onboarding`.
   - **Regla 4 — Dashboard:** si existe perfil → `/home`.
   - **Regla 0 (Splash):** si `state.matchedLocation == '/splash'` → resolver al destino correspondiente, o `null` mientras la sesión está en loading.
   - Guardia anti-bucle: devolver `null` cuando `matchedLocation` ya es el destino correcto.
3. Añadir cache del resultado de `user_language_profiles` por `user.id` (invalidar cuando cambie el usuario) para no golpear Supabase en cada re-evaluación.
4. Crear `navigationRefreshListenable` (un `Listenable`, p. ej. `ChangeNotifier` o un `ValueNotifier`), que se actualiza cuando cambia `currentUserProvider` o `devAlwaysShowOnboardingProvider`. Puede vivir en el mismo archivo o en un provider de `lib/app/`.

### Verificación
- Unit test (en `test/`): `navigationRedirect` devuelve la ruta esperada para cada combinación de (usuario, modo dev, perfil), sin depender de un widget ni de frames.
- `flutter analyze`: 0 errores.

### Riesgos
- Riesgo: lógica duplicada si se deja código de decisión en otro sitio. **Mitigación:** todo el redireccionamiento de arranque pasa por esta función; WelcomeScreen deja de decidir (F4).
- Riesgo: consulta de perfil lenta bloqueando el redirect. **Mitigación:** cache por sesión y degradación segura a `/onboarding` ante error de red/RLS.

---

## F3 — Añadir `redirect` + `refreshListenable` + ruta `/splash` al router

### Objetivo
Que el router sea el **único** mecanismo de decisión de navegación.

### Pasos
1. En `lib/app/router.dart`:
   - Cambiar `initialLocation: '/'` → `initialLocation: '/splash'`.
   - Añadir `refreshListenable: navigationRefreshListenable`.
   - Añadir `redirect: (context, state) => navigationRedirect(state, usuario, devMode)`.
   - Leer dentro del redirect los providers `currentUserProvider` y `devAlwaysShowOnboardingProvider` (el router debe tener acceso a un `ProviderContainer`/`ref`; típicamente se expone el `ProviderScope`/container en `main.dart` y se pasa al crear `appRouter`, o `appRouter` se construye como función que recibe `ref`).
   - Registrar la ruta nueva:
     ```dart
     GoRoute(
       path: '/splash',
       builder: (context, state) => const SplashScreen(),
     ),
     ```
   - Mantener `/` → `WelcomeScreen`; `/onboarding` y `/home` sin cambios.
2. Confirmar que go_router ^14.0.0 soporta `FutureOr<String?>` en `redirect` (sí: redirect async). Si el redirect lanza excepción en la consulta, capturarla y devolver `/onboarding` (seguro) con `debugPrint`.
3. Asegurarse de que `refreshListenable` notifique también tras login/logout (el flujo de auth que ya invalida/actualiza `currentUserProvider` debe propagar la notificación).

### Verificación
- Navegación manual de arranque:
  - Sin sesión → `/splash` → `/`.
  - Con sesión y sin perfil → `/splash` → `/onboarding`.
  - Con sesión y perfil → `/splash` → `/home`.
- Activar el modo dev en Ajustes → vuelve a `/onboarding` automáticamente (vía `refreshListenable`).
- `flutter analyze`: 0 errores.

### Riesgos
- Riesgo: **bucle de redirect** (más común en esta fase). **Mitigación:** guardia `matchedLocation == destino ? null : destino` en todas las reglas.
- Riesgo: la sesión aún en loading produce un redirect agresivo hacia `/`. **Mitigación:** durante loading, en `/splash`, devolver `null` y esperar al `refreshListenable`.
- Riesgo: el router no tiene acceso a Riverpod. **Mitigación:** construir `appRouter` dentro de un lugar con `ref` (o pasar un `ProviderContainer`), y registrarlo en `MaterialApp.router` igual que hoy (`lib/app/app.dart`).

---

## F4 — Simplificar `WelcomeScreen`

### Objetivo
Eliminar la decisión del widget; `WelcomeScreen` solo muestra login/registro.

### Pasos
1. En `lib/features/onboarding/presentation/screens/welcome_screen.dart`:
   - **Eliminar** el método `_redirectUser` (líneas 26-55 actuales).
   - **Eliminar** el bloque `if (user != null) { WidgetsBinding.instance.addPostFrameCallback((_) => _redirectUser(user)); }` del `build` (líneas 64-68 actuales).
   - Eliminar import/uso de `devAlwaysShowOnboardingProvider`, `isRegisteringProvider`, `Supabase` y `currentUserProvider` **solo si dejan de usarse** en el resto de la pantalla (verificar antes de quitar imports).
   - Al completar el registro (donde hoy se hacía parte de la decisión), llamar `context.go('/onboarding')` de forma explícita. El router tomará el control después (regla 3: sin perfil → `/onboarding`; con perfil → `/home`).
2. El `isRegisteringProvider` puede seguir existiendo si el formulario de registro lo usa para UI, pero **ya no participa en la navegación**.

### Verificación
- `flutter analyze`: 0 errores.
- Flujo manual: registro → aterriza en `/onboarding` (ya no depende de `isReg`).
- Reabrir la app con sesión persistida y sin onboarding → **ya no** va a `/home`; va a `/onboarding` (bug Corregido).

### Riesgos
- Riesgo: quitar imports usados en otra parte de la pantalla → error de compilación. **Mitigación:** revisar usos restantes de cada provider/import antes de eliminarlos.
- Riesgo: algún `context.go` residual que salte el guard. **Mitigación:** el único `context.go` que queda en WelcomeScreen apunta a `/onboarding` (seguro) y el redirect valida el destino de todos modos.

---

## F5 — QA

### Objetivo
Garantizar que la refactorización no rompa compilación, tests ni el flujo de arranque.

### Pasos
1. `flutter gen-l10n` **solo si** se tocaron archivos `.arb` (no es el caso esperado; confirmar que no se añadieron textos).
2. `flutter analyze`: bar de calidad = **0 errores** (los ~56 infos/warnings existentes no son bloqueantes).
3. `flutter test`: ejecutar la suite actual (`test/`) — 5 archivos. Añadir test unitario de `navigationRedirect` (si se desea en esta fase).
4. Build: `flutter build apk --debug` (o `flutter run -d <device>`) para validar compilación completa.
5. Prueba manual end-to-end de los casos de la tabla del Doc 05.

### Verificación
- Salida de los 3 comandos sin errores.
- Recorrido manual de los 10 casos de la tabla de casos (Doc 05).

### Riesgos
- Riesgo: `flutter test` rompe por `currentUserProvider.overrideWithValue(null)` en `test/widget_test.dart` si el widget testado ahora depende del redirect. **Mitigación:** ajustar el test para que el router se construya con el container sobreescrito (o testear el engine por separado).
- Riesgo: sesiones de RLS/red al consultar `user_language_profiles` en el redirect async. **Mitigación:** cache + degradación a `/onboarding` + `debugPrint`.

---

## Resumen de archivos tocados

| Archivo | Fase | Cambio |
|---------|------|--------|
| `lib/app/splash_screen.dart` | F1 | **Nuevo** — SplashScreen. |
| `lib/app/navigation_resolver.dart` | F2 | **Nuevo** — `navigationRedirect` + `navigationRefreshListenable`. |
| `lib/app/router.dart` | F3 | `initialLocation`, `redirect`, `refreshListenable`, ruta `/splash`. |
| `lib/app/app.dart` | F3 (si aplica) | Ajustar si la construcción del router requiere un container/ref. |
| `lib/features/onboarding/.../welcome_screen.dart` | F4 | Eliminar `_redirectUser` y el callback del build; registro → `/onboarding`. |
| `test/` (opcional) | F2/F5 | Test unitario de `navigationRedirect`. |

---

*Siguiente documento: `05_Test_Cases.md` — casos de prueba exhaustivos y logs de navegación.*

---

## 9. Cambios implementados (2026-07-31)

> Validado: 0 errores analyze � 73/73 tests � build APK OK.

### F1 � Splash Screen (lib/app/splash_screen.dart, nuevo)
- Pantalla de arranque con la marca del juego (icono auto_awesome + "DUNGEON OF ENGLISH" + "SISTEMA HUD � DESPERTANDO...") + spinner. Log [Splash] Splash iniciado.

### F2 � Navigation Decision Engine (lib/app/navigation_resolver.dart, nuevo)
- NavigationDecisionEngine.resolve(user, devMode) ? NavDestination {welcome, onboarding, home}.
- Reglas en orden: (1) Modo Desarrollo ? onboarding; (2) sin sesi�n ? welcome; (3) sesi�n sin perfil ? onboarding; (4) sesi�n con perfil ? home.
- 
avDestinationToPath() convierte el destino en ruta.

### F3 � Router centralizado (lib/app/router.dart)
- ppRouter (global) ? outerProvider (Provider<GoRouter> con acceso a ef).
- initialLocation: '/splash' + nueva ruta /splash.
- edirect async que resuelve con el NavigationDecisionEngine (ignora rutas internas: /splash, /onboarding, /oracle-test, /oracle-quiz, /disruption).
- efreshListenable (_NavigationRefreshListenable) que re-eval�a el redirect al cambiar sesi�n o modo dev.
- lib/app/app.dart usa ef.watch(routerProvider).

### F4 � WelcomeScreen simplificado (welcome_screen.dart)
- Eliminado _redirectUser y el watch de sesi�n (la decisi�n ahora es del router).
- Limpieza de imports sin uso (go_router, supabase, onboarding_providers). isRegisteringProvider se mantiene (flujo de registro).

### F5 � QA
- Test de smoke actualizado: verifica el SplashScreen (antes buscaba texto en Welcome).
- lutter analyze 0 errores � lutter test 73/73 � lutter build apk --debug OK.
- L�gica de auth/onboarding/supabase/dashboard intacta (solo se reorganiz� el flujo).
