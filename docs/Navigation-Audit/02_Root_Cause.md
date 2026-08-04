# Auditoría Forense de Navegación — Documento 2: Causa Raíz

> Proyecto: TutorSaas / Dungeon of English (Flutter)
> Fecha de auditoría: 2026-08-02
> Alcance: Causa raíz del Caso 2 (registrado sin onboarding salta a `/home`) y fragilidad de la arquitectura de navegación.
> Método: Hallazgos verificados sobre el código fuente (con evidencia `archivo:línea`).

---

## 1. Causa raíz definitiva

El usuario registrado que reabre la app (sesión persistida) **se salta el onboarding** porque la rama que debería decidir —la consulta a `user_language_profiles`— **solo se ejecuta cuando `isRegisteringProvider == true`**. En la apertura normal de la app con sesión guardada, `isRegisteringProvider` es `false`, y la lógica asume erróneamente que el usuario "ya está onboarded" simplemente porque tiene sesión.

Esta causa raíz se apoya en **tres defectos estructurales** que se detallan en las siguientes secciones:

1. No hay Splash Screen ni estado de carga al arrancar.
2. La decisión de redirección está distribuida en un widget (`WelcomeScreen`) y depende del flag transitorio `isRegisteringProvider`.
3. No existe `redirect` en `GoRouter`, por lo que `/home` y `/onboarding` son directamente alcanzables sin ningún guard.

---

## 2. Evidencia con `archivo:línea`

### 2.1 La rama que rompe el Caso 2

`lib/features/onboarding/presentation/screens/welcome_screen.dart`, método `_redirectUser(User)`:

```
líneas 26-55
  - lee devAlwaysShowOnboardingProvider       → si true → context.go('/onboarding')
  - lee isRegisteringProvider (default false)
  - SI isReg == true:
        consulta user_language_profiles por user_id
            → existe perfil → context.go('/home')
            → no existe     → context.go('/onboarding')
  - SI isReg == false (líneas 47-49):
        context.go('/home')   ← SIN consultar user_language_profiles
```

**Evidencia clave:** en las líneas 47-49, la rama `isReg == false` redirige a `/home` de forma incondicional. Esa rama es la que se ejecuta en el arranque normal de la app con sesión guardada.

### 2.2 Por qué `isReg` es `false` en el arranque normal

`lib/features/auth/.../auth_providers.dart`:

```
currentUserProvider (Provider<User?>) →
    lee authStateProvider (StreamProvider<session>) →
        devuelve state.session?.user
```

```
isRegisteringProvider (StateProvider<bool>) → default false; se pone true SOLO durante el registro
```

- La sesión se restaura de forma persistente por Supabase (sin pasar por el flujo de registro).
- `isRegisteringProvider` se pone a `true` únicamente durante el registro activo y vuelve a `false` al terminar o al reiniciar la app.
- Por lo tanto, **abrir la app con una sesión guardada siempre ejecuta la rama `isReg == false`**, es decir, siempre `context.go('/home')`.

### 2.3 El disparador que hace esto invisible

`welcome_screen.dart`, `build()` (líneas 64-68):

```
if (currentUserProvider no es null) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectUser(user));
}
```

- `currentUserProvider` devuelve un `User` en cuanto la sesión persistida está disponible.
- El `postFrameCallback` dispara `_redirectUser` sin consultar el perfil de idioma en la rama que se ejecuta normalmente.

### 2.4 Ausencia de Splash Screen

`lib/main.dart`:

```
1. inicializa Supabase
2. runApp(ProviderScope(child: TutorSaaSApp()))
```

- No existe ninguna pantalla de carga intermedia entre `runApp` y la primera ruta.

### 2.5 Ausencia de guard centralizado

`lib/app/router.dart` (138 líneas):

```
GoRouter(
  initialLocation: '/',
  routes: [...23 rutas...]
)
```

- No existe la propiedad `redirect` en `GoRouter`.
- No existe ningún `redirect` por ruta ni guard que compruebe sesión/perfil.

---

## 3. Por qué se rompe cada caso

| Caso | ¿Se rompe? | Explicación |
|------|-----------|-------------|
| **Caso 1** (sin sesión) | ❌ No | `currentUserProvider == null` → no se dispara `_redirectUser` → `WelcomeScreen` se queda visible. Correcto. |
| **Caso 2** (sesión persistida, sin onboarding) | ✅ **SÍ** | `isReg == false` → `context.go('/home')` sin consultar `user_language_profiles`. **El usuario nunca ve el onboarding.** |
| **Caso 3** (registro activo, sin perfil) | ❌ No | `isReg == true` → consulta el perfil → no existe → `/onboarding`. Correcto, **pero depende de que `isRegisteringProvider` siga en `true` durante todo el registro**. |
| **Caso 4** (sesión persistida, onboarding completo) | ❌ No (por coincidencia) | `isReg == false` → `context.go('/home')`. Aterriza bien porque el usuario **ya** tenía perfil, no porque la lógica lo verifique. |
| **Caso 5** (dev, `devAlwaysShowOnboarding == true`) | ⚠️ Parcial | Fuerza `/onboarding` siempre, incluso para usuarios ya onboarded. Aceptable solo en dev. |

**Lectura crítica del Caso 4:** el hecho de que "funcione" refuerza la falsa sensación de que la rama `isReg == false` es correcta. En realidad esa rama **nunca valida el requisito de producto** y solo aterriza bien por casualidad.

---

## 4. Análisis de fragilidad de la arquitectura actual

### 4.1 La decisión de navegación vive en un widget (mala separación de responsabilidades)

- La lógica de "a dónde va cada usuario al arrancar" está embebida en `WelcomeScreen.build()` + `_redirectUser()`, no en un lugar dedicado a la navegación.
- Consecuencias:
  - Cualquier cambio de producto (p. ej. "si no tiene perfil, mandar a `/oracle-test` antes que a `/onboarding`") obliga a tocar el widget de Bienvenida.
  - La responsabilidad de la pantalla (mostrar bienvenida/login) se mezcla con la política de navegación global.
  - Es imposible navegar a `/home` o `/onboarding` de forma segura desde cualquier otra parte de la app: **el guard solo existe cuando se pasa por `WelcomeScreen`**.

### 4.2 Dependencia de un flag transitorio (`isRegisteringProvider`)

- `isRegisteringProvider` es un `StateProvider<bool>` con semántica de **estado efímero de la UI del registro**.
- Usarlo como **fuente de verdad de navegación** es frágil porque:
  - No sobrevive al reinicio de la app.
  - Puede quedar en `false` aunque el registro no haya terminado de persistir el perfil (race condition: `_redirectUser` lee `false` antes de que se cree `user_language_profiles`).
  - La decisión correcta no debería depender de "cómo llegó el usuario aquí" (¿registro o login persistido?), sino de un **estado persistido y estable**: ¿existe el perfil de idioma del usuario?

### 4.3 Ausencia de `redirect` en `GoRouter`

- Sin `redirect`, el router permite **accesos directos** a rutas protegidas:
  - `/home` es alcanzable aunque el usuario no tenga perfil (Caso 2).
  - Cualquier deep link futuro a `/home`, `/oracle-test`, `/shop`, etc. sortea la lógica de `WelcomeScreen` por completo.
- Un guard centralizado (`redirect`) resolvería:
  - El arranque: `/` → decidir entre `/onboarding` y `/home`.
  - La protección: cualquier ruta "tras el onboarding" redirige a `/onboarding` si falta el perfil.
  - El deep-linking: el guard se aplica a toda navegación, no solo al arranque.
- Flutter/GoRouter permite declarar esto de forma declarativa; su ausencia es una deuda técnica directa.

### 4.4 Ausencia de Splash Screen (estado de carga)

- `initialLocation: '/'` + `postFrameCallback` produce:
  - **Parpadeo**: la primera frame pinta `WelcomeScreen` y luego salta al destino.
  - **Ventana de inconsistencia**: durante el tiempo que `authStateProvider` tarda en resolver la sesión, `currentUserProvider` es `null` y la UI muestra Bienvenida aunque haya sesión guardada.
- Un Splash (o un loader condicional sobre la resolución de la sesión) eliminaría el parpadeo y evitaría "decidir" antes de tener datos.

### 4.5 Resumen de debilidades

| # | Debilidad | Impacto | Gravedad |
|---|-----------|---------|----------|
| 1 | Decisión de navegación en `WelcomeScreen` | El guard solo aplica si pasas por esa pantalla | Alta |
| 2 | Rama `isReg == false` sin verificar perfil | Caso 2: se salta el onboarding | **Crítica** |
| 3 | Uso de `isRegisteringProvider` como fuente de verdad | Race conditions, estado efímero | Alta |
| 4 | Sin `redirect` en `GoRouter` | Rutas accesibles sin guard, deep links desprotegidos | Alta |
| 5 | Sin Splash / estado de carga | Parpadeo y decisión sin datos | Media |

---

## 5. Condiciones que deben cumplirse en una corrección (recomendaciones, sin implementar)

> Nota: esta sección es orientativa y **no modifica código**. No se ha implementado nada.

1. La pregunta de navegación debe ser única y estable: **¿existe `user_language_profiles` para el `user_id` de la sesión?**
   - Sí → `/home`
   - No → `/onboarding`
   - Sin sesión → `WelcomeScreen`
2. Esta decisión debe vivir en un **guard centralizado** (p. ej. `redirect` en `GoRouter` o un provider de navegación), nunca en un widget.
3. Debe existir un **estado de carga inicial** (Splash / loader) que espere a que la sesión y la consulta de perfil se resuelvan, para eliminar el parpadeo.
4. El flag `isRegisteringProvider` debe dejar de ser la condición de navegación (puede seguir existiendo para la UI del registro).
5. El modo dev `devAlwaysShowOnboardingProvider` debe evaluarse **después** del estado de carga y de forma explícitamente acotada a entornos de desarrollo.

---

## 6. Conclusión

La causa raíz del defecto es **arquitectónica**: la navegación de arranque está distribuida en un widget y condicionada a un flag transitorio de registro, en lugar de estar centralizada en el router y basada en un estado persistido. El síntoma visible (usuario registrado que salta el onboarding) es solo la punta de un problema estructural que además produce parpadeo, expone rutas sin protección y hará que cualquier cambio futuro de flujo sea frágil y propenso a nuevos bugs.
