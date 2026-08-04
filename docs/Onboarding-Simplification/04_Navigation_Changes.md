# 04 — Cambios de Navegación — Simplificación del Onboarding

> Proyecto: TutorSaas · Fecha: 2026-08-02
> Estado: documentación de cambios ya realizados (verificados contra código, sin modificar código)
> Archivo clave: `lib/app/router.dart` (GoRouter v14)

---

## 1. Resumen

Se simplificó la navegación del onboarding eliminando una ruta huérfana (`/oracle-quiz`) que apuntaba a `PlacementTestScreen`, una pantalla que nadie abría porque el flujo real de evaluación del Oráculo usa `/oracle-test`. El `redirect` centralizado (Navigation Decision Engine) nunca la tenía en su lista de rutas internas, por lo que cualquier navegación a `/oracle-quiz` habría terminado redirigida a otro destino.

## 2. Ruta eliminada

| Aspecto | Antes | Después |
|---|---|---|
| Ruta | `/oracle-quiz` → `PlacementTestScreen` | **Eliminada** (no existe en `router.dart`) |
| Pantalla huérfana | `lib/features/onboarding/presentation/screens/placement_test_screen.dart` | Sigue existiendo como archivo sin registrar (ver doc 06) |
| Flujo real | N/A | `/oracle-test` → `OracleConversationScreen` |

Evidencia: el archivo `router.dart` (líneas 60-168) solo registra `/oracle-test` (línea 74), sin ninguna entrada `path: '/oracle-quiz'`.

## 3. Redirect centralizado (sin cambios funcionales)

El `redirect` de `GoRouter` sigue resolviendo la pantalla inicial mediante el **Navigation Decision Engine** (`lib/app/navigation_resolver.dart`):

```dart
initialLocation: '/splash',
redirect: (context, state) async { ... }   // router.dart:39-59
```

Reglas del `NavigationDecisionEngine.resolve()` en orden de prioridad (sin cambios):

1. **Modo Desarrollo** (`devAlwaysShowOnboarding`) → `/onboarding`.
2. **Sin sesión** → `/` (`WelcomeScreen`).
3. **Con sesión y SIN perfil** (`user_language_profiles`) → `/onboarding`.
4. **Con sesión y CON perfil** → `/home` (dashboard).

## 4. Rutas internas del redirect (actualizadas)

El `redirect` excluye de la redirección un conjunto fijo de rutas internas. **`/oracle-quiz` ya no está y nunca debió estar**:

```dart
final internalRoutes = const {
  '/splash',
  '/onboarding',
  '/oracle-test',
  '/disruption',
};                                  // router.dart:44-49
```

Comentario del código (router.dart:42): *"Rutas internas de onboarding que no deben ser redirigidas."*

## 5. Verificación de rutas huérfanas

Inventario de rutas registradas en `router.dart` (tras el cambio) y su destino:

| Ruta | Pantalla | ¿En uso? |
|---|---|---|
| `/splash` | `SplashScreen` | Sí — ruta inicial |
| `/` | `WelcomeScreen` | Sí — login/registro |
| `/onboarding` | `OnboardingScreen` | Sí — flujo principal |
| `/oracle-test` | `OracleConversationScreen` | Sí — evaluación del Oráculo |
| `/hunter-status` | `HunterStatusScreen` | Sí |
| `/dungeon-map` | `DungeonMapScreen` | Sí |
| `/home` | `DashboardScreen` | Sí |
| `/voice-room`, `/conversation`, `/summary`, `/paywall`, `/profile`, `/settings`, `/profile-edit`, `/chat-rooms`, `/level-exam`, `/shop`, `/inventory`, `/battle-pass`, `/collections`, `/fragments-exchange`, `/leaderboard`, `/disruption` | varias | Sí |

**Conclusión:** no quedan rutas huérfanas registradas. La única pantalla sin registrar es `PlacementTestScreen` (archivo `placement_test_screen.dart`), que ya no tiene ninguna ruta que la instancie (ver 06).

## 6. Resumen de cambios

| # | Cambio | Impacto |
|---|---|---|
| N1 | Eliminada ruta `/oracle-quiz` de `router.dart` | Ninguna funcionalidad perdida (nadie la usaba) |
| N2 | `internalRoutes` queda en `/splash`, `/onboarding`, `/oracle-test`, `/disruption` | Redirect coherente con el flujo real |
| N3 | `initialLocation: '/splash'` se mantiene | Sin cambio |
| N4 | Navigation Decision Engine intacto | Sin cambio |
