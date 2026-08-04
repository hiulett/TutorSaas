# Auditoría de Navegación — Documento 5: Casos de Prueba y Logs de Navegación

> Proyecto: TutorSaas / Dungeon of English (Flutter)
> Fecha: 2026-08-02
> Alcance: Validación del flujo centralizado de navegación (Splash → Navigation Decision Engine → pantalla destino).
> Precedente: Documentos 03 (`03_Navigation_Redesign.md`) y 04 (`04_Implementation_Plan.md`).

---

## 1. Escenarios de prueba exhaustivos

> **Convenciones de la tabla**
> - **Estado inicial** = estado de sesión/perfil/modo dev antes de la acción.
> - **Perfil** = fila en `user_language_profiles` para el `user.id`.
> - El resultado esperado se deriva de las reglas en orden: **Modo Desarrollo → Autenticación → Onboarding → Dashboard**.
> - `/splash` es la primera ruta; el redirect resuelve el destino real.

| # | Escenario | Estado inicial | Acción | Resultado esperado |
|---|-----------|----------------|--------|--------------------|
| 1 | **Usuario nuevo** | Sin sesión, sin perfil, modo dev OFF | Abre la app | `/splash` (1-2 s) → `/` (WelcomeScreen con login/registro). |
| 2 | **Registrado sin onboarding** | Sesión activa tras registro, SIN perfil, modo dev OFF | Completa el registro / reabre la app | `/splash` → `/onboarding`. **Nunca `/home`** (bug actual corregido). |
| 3 | **Registrado con onboarding** | Sesión activa, CON perfil, modo dev OFF | Reabre la app | `/splash` → `/home`. |
| 4 | **Registro en curso (durante el flujo de registro)** | `isRegisteringProvider == true`, sesión activa, sin perfil aún | Termina el registro y WelcomeScreen llama `context.go('/onboarding')` | `/onboarding`. El router re-verifica con la regla 3 (sin perfil → onboarding). |
| 5 | **Modo dev activado** | `devAlwaysShowOnboarding == true`, sesión activa o no, con o sin perfil | Abre la app o cambia el toggle en Ajustes | `/onboarding` **siempre**. Regla 1 gana sobre todo (ignora sesión y perfil). |
| 6 | **Cerrar sesión (logout)** | Sesión activa, en `/home`, modo dev OFF | Usuario cierra sesión | `refreshListenable` notifica → redirect → `/` (WelcomeScreen). Ya no puede ver `/home`. |
| 7 | **Eliminar sesión / borrar datos de la app** | Sesión persistida en el dispositivo | El SO limpia los datos de la app / se borra la sesión | Arranca sin sesión → `/splash` → `/`. Si quedó modo dev ON, irá a `/onboarding` (regla 1). |
| 8 | **Reinstall** | App desinstalada y reinstalada | Instala y abre | Sin sesión persistida → `/splash` → `/` (WelcomeScreen). `SharedPreferences` también reseteado → modo dev OFF. |
| 9 | **Primer inicio** | App instalada, nunca abierta | Abre por primera vez | `/splash` → `/` (WelcomeScreen). No hay sesión. |
| 10 | **Reinicio con sesión guardada** | Sesión persistida, perfil existente | Cierra y reabre la app | `/splash` → `/home` (sin parpadeo de Welcome; el Splash absorbe la resolución de sesión). |
| 11 | **Sesión caducada / token inválido** | Sesión persistida pero expirada | Abre la app | `currentUserProvider` resuelve a `null` → `/splash` → `/` (WelcomeScreen). Opcional: mensaje de "sesión expirada". |
| 12 | **Sesión válida pero consulta de perfil falla (red/RLS)** | Sesión activa, consulta a `user_language_profiles` lanza excepción | Abre la app | Degradación segura → `/onboarding` + `debugPrint` del error. **Nunca** `/home` a ciegas. |
| 13 | **Acceso directo (deep link) a `/home` sin sesión** | Sin sesión | Navega a `/home` | Redirect → `/` (regla 2). |
| 14 | **Acceso directo a `/home` con sesión pero sin perfil** | Sesión activa, SIN perfil | Navega a `/home` | Redirect → `/onboarding` (regla 3). |
| 15 | **Modo dev activado y acceso directo a `/`** | `devAlwaysShowOnboarding == true` | Navega a `/` | Redirect → `/onboarding` (regla 1, prioridad máxima). |
| 16 | **Ya en la pantalla destino** | Cualquier estado consistente | El redirect evalúa la ruta actual | `null` (sin redirección). Guardia anti-bucle (`matchedLocation == destino`). |
| 17 | **Navegación interna tras completar onboarding** | Sesión activa, acaba de crearse el perfil en el onboarding | Onboarding completa y navega | Redirect re-evalúa: con perfil → `/home`. |
| 18 | **Modo dev desactivado después de estar en onboarding** | `devAlwaysShowOnboarding == true → false`, sin perfil | Toggle OFF en Ajustes | `refreshListenable` notifica → re-evalúa: sin perfil → sigue `/onboarding` (regla 3); con perfil → `/home`. |

### 1.1 Resultado por prioridad (matriz de referencia)

| Modo dev | Sesión | Perfil | Destino | Regla ganadora |
|----------|--------|--------|---------|----------------|
| ON | — | — | `/onboarding` | 1 (siempre) |
| OFF | NO | — | `/` | 2 |
| OFF | SÍ | NO | `/onboarding` | 3 |
| OFF | SÍ | SÍ | `/home` | 4 |

---

## 2. Logs de navegación sugeridos

> Propuesta de `debugPrint` (patrón existente en el proyecto: "All API calls wrapped in try-catch with `debugPrint`"). Sirven para diagnosticar el flujo en QA y producción.

### 2.1 Ciclo de vida del Splash

```
[Splash] Splash iniciado (/splash)
[Splash] Estado de sesión: loading → resolviendo
[Splash] Estado de sesión: sin sesión | con sesión (userId: ...)
[Splash] Permitiendo que el redirect resuelva el destino...
```

### 2.2 Motor de decisión (NavigationDecisionEngine)

```
[Nav] Modo Desarrollo = true → Redirigiendo a /onboarding (regla 1)
[Nav] Sin sesión → Redirigiendo a / (regla 2)
[Nav] Usuario autenticado (userId: ...) → consultando user_language_profiles...
[Nav] Perfil NO encontrado → Redirigiendo a /onboarding (regla 3)
[Nav] Perfil encontrado → Redirigiendo a /home (regla 4)
[Nav] Error consultando perfil → degradando a /onboarding (error: $e)
[Nav] Ya en destino (${state.matchedLocation}) → sin redirección (null)
```

### 2.3 Eventos disparados por `refreshListenable`

```
[Nav] Cambio detectado en currentUserProvider (sesión) → re-evaluando redirect
[Nav] Cambio detectado en devAlwaysShowOnboardingProvider → re-evaluando redirect
[Nav] Usuario cerró sesión → redirigiendo a /
[Nav] Sesión expirada → redirigiendo a /
```

### 2.4 Flujo de WelcomeScreen (tras simplificación)

```
[Welcome] Pantalla de bienvenida mostrada (login / registro)
[Welcome] Registro completado → context.go('/onboarding')
[Welcome] Login completado → la sesión cambia → el redirect resuelve el destino
```

### 2.5 Convención de prefijos

| Prefijo | Origen |
|---------|--------|
| `[Splash]` | `lib/app/splash_screen.dart` |
| `[Nav]` | `lib/app/navigation_resolver.dart` (engine + redirect) |
| `[Welcome]` | `welcome_screen.dart` |

---

## 3. Criterios de aceptación (QA final, fase F5)

1. **Ningún caso con sesión sin perfil termina en `/home`** (casos 2, 12, 14). ✓ Invariante del producto.
2. El modo dev siempre gana (casos 5, 15, 18). ✓
3. Cualquier estado sin sesión termina en `/` (casos 1, 6, 7, 8, 9, 11, 13). ✓
4. No hay bucles de redirección: siempre se llega a un destino estable (caso 16). ✓
5. No hay parpadeo de la pantalla de Bienvenida al arrancar con sesión (casos 3, 10). ✓ (el Splash lo absorbe)
6. `flutter analyze` con **0 errores**, `flutter test` verde, build correcto. ✓
7. Los logs de la sección 2 aparecen en el orden esperado en cada escenario. ✓

---

*Fin de la serie Navigation-Audit. Siguientes documentos sugeridos: `06_` (detalle técnico del `refreshListenable` con Riverpod) o pasar directamente a implementación con `04_Implementation_Plan.md`.*
