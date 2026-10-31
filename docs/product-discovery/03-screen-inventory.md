# 03 — Inventario de pantallas

> **Alcance:** las **20** pantallas del producto (`*_screen.dart`), medidas sobre
> el worktree `p14-ai-usage` (`origin/master`, octubre 2026).
> **Método:** lectura de widgets, tokens, providers, RPC y textos localizados.
>
> ## Aviso metodológico (importante)
>
> **No hay visión de imágenes y el dispositivo está desconectado.** Este
> inventario describe la UI **a partir del árbol de widgets y de los tokens**
> (qué se construye, con qué componente, con qué color/tipografía y con qué
> dato), **no** a partir de una captura. Por tanto:
>
> - **Sí** se afirma: qué widgets existen, qué hacen al pulsarlos, qué estados
>   de carga/error/vacío están implementados, qué datos los alimentan.
> - **No** se afirma: jerarquía visual percibida, alineación óptica, densidad,
>   legibilidad real del glow, calidad de las animaciones, ni cómo se ve en un
>   móvil concreto.
>
> Etiquetas: `[IMPLEMENTADO]` (código completo y cableado a datos reales) ·
> `[PARCIAL]` (existe pero falta una rama, un dato o un test) ·
> `[CONCEPTUAL]` (sólo texto/idea, sin pantalla o sin efecto) ·
> `[PROPUESTA]` (no está en el código) · `[PENDIENTE DE VALIDAR]` (no
> verificable desde este entorno).

---

## 1. Mapa de navegación

```mermaid
graph TD
  SPLASH[/splash/] -->|context.go('/')| WELCOME[/ · Welcome/]
  WELCOME -->|sin perfil| ONB[/onboarding/]
  ONB -->|push y retorno| ORACLE[/oracle-test/]
  ONB -->|primera vez| MINI[/mini-conversation/]
  MINI --> HOME[/home/]
  ONB -->|ya vista| HOME

  HOME --> DUNGEON_TAB[[tab 0 · Mazmorras]]
  HOME --> GUILD_TAB[[tab 1 · Gremio]]
  HOME --> STATUS_TAB[[tab 2 · Estado]]
  HOME --> CONFIG_TAB[[tab 3 · Config]]

  DUNGEON_TAB -->|context.push| CONV[/conversation/]
  CONV -->|push al salir| SUMMARY[/summary/]
  SUMMARY -->|go| HOME
  CONV -->|sin maná| GUARD[/dungeon-guardian/]
  GUARD -->|push| SHOP[/shop/]
  GUARD -->|pop| CONV
  CONV -->|modo promotion y resultado boss| BOSS[/boss-result/]
  BOSS -->|go| HOME

  DUNGEON_TAB --> SHOP
  DUNGEON_TAB --> ORACLE
  DUNGEON_TAB --> ERRORS[/my-errors/]
  DUNGEON_TAB --> PAYWALL[/paywall/]
  DUNGEON_TAB --> MISSIONS[/missions/]
  DUNGEON_TAB --> WEEKLY[/weekly-report/]
  DUNGEON_TAB --> LISTEN[/listening/]

  SHOP -->|push| INV[/inventory/]
  GUILD_TAB -->|push| VOICE[/voice-room/]
  CONFIG_TAB -->|push| PROFILE[/profile-edit/]
  CONFIG_TAB -->|push| PAYWALL
```

Rutas registradas: **20** (`lib/app/router.dart:33-140`). El nodo `CONFIG_TAB`
es la única "pantalla" que no tiene ruta propia (§4.15).

---

## 2. Índice

| ID | Pantalla | Módulo | Ruta | Archivo | Líneas |
|---|---|---|---|---|---|
| SCR-01 | Splash | `app` | `/splash` | `lib/app/splash_screen.dart` | 285 |
| SCR-02 | Welcome (login/registro) | `onboarding` | `/` | `lib/features/onboarding/presentation/screens/welcome_screen.dart` | 721 |
| SCR-03 | Onboarding (wizard 4 pasos) | `onboarding` | `/onboarding` | `…/onboarding_screen.dart` | 1 273 |
| SCR-04 | Mini-conversación (prueba de valor) | `onboarding` | `/mini-conversation` | `…/mini_conversation_screen.dart` | 502 |
| SCR-05 | Conversación con el tutor / Oráculo | `conversation` | `/conversation`, `/oracle-test` | `…/conversation_screen.dart` | 2 362 |
| SCR-06 | Dashboard (4 pestañas) | `dashboard` | `/home` | `…/dashboard_screen.dart` | 768 |
| SCR-07 | Salón del Gremio (mesas) | `chat_rooms` | `/chat-rooms` + tab 1 | `…/chat_rooms_screen.dart` | 1 300 |
| SCR-08 | Sala de voz | `chat_rooms` | `/voice-room` | `…/voice_room_screen.dart` | 1 240 |
| SCR-09 | Misiones | `missions` | `/missions` | `…/missions_screen.dart` | 238 |
| SCR-10 | Tienda Arcano | `economy` | `/shop` | `…/shop_screen.dart` | 1 108 |
| SCR-11 | Inventario | `economy` | `/inventory` | `…/inventory_screen.dart` | 455 |
| SCR-12 | Guardián de la Mazmorra | `economy` | `/dungeon-guardian` | `…/dungeon_guardian_screen.dart` | 765 |
| SCR-13 | Resumen de sesión | `dashboard` | `/summary` | `…/session_summary_screen.dart` | 1 325 |
| SCR-14 | Editar perfil | `dashboard` | `/profile-edit` | `…/profile_edit_screen.dart` | 650 |
| SCR-15 | Ajustes (sin ruta) | `dashboard` | — (tab 3) | `…/settings_screen.dart` | 1 612 |
| SCR-16 | Paywall | `subscription` | `/paywall` | `…/paywall_screen.dart` | 665 |
| SCR-17 | Resultado del jefe | `boss_exam` | `/boss-result` | `…/boss_exam_result_screen.dart` | 456 |
| SCR-18 | Mis errores | `corrections` | `/my-errors` | `…/my_errors_screen.dart` | 424 |
| SCR-19 | Informe semanal | `weekly_report` | `/weekly-report` | `…/weekly_report_screen.dart` | 672 |
| SCR-20 | Comprensión auditiva | `listening` | `/listening` | `…/listening_quiz_screen.dart` | 903 |

**Concentración de código:** las 4 pantallas más grandes (SCR-05, SCR-15,
SCR-13, SCR-07) suman **6 599 líneas**, el **37 %** del total de pantallas
(17 724 líneas en 20 archivos).

---

## 3. Fichas

---

### SCR-01 · Splash — «SISTEMA HUD · DESPERTANDO»

| Campo | Valor |
|---|---|
| Módulo | `lib/app/` (fuera de `features/`) |
| Ruta | `/splash` (`initialLocation`, `router.dart:147`) |
| Archivo | `lib/app/splash_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Mostrar la marca un mínimo de 500 ms y aprovechar ese
tiempo para "despertar" el pool de Postgres con un query barato, navegando a `/`
en cuanto el warm-up termina (tope 3 s). Evita el cold start que sufría el
redirect post-login.

**Objetivo narrativo.** "El sistema HUD despierta y conecta al Gran Reino": un
emblema rúnico pulsante, rejilla de energía y una barra segmentada que avanza.

**Elementos.**
- 3 orbes de glow radial (violeta, cian, dorado) `splash_screen.dart:100-120`.
- Rejilla de energía con `CustomPaint` (`_GridPainter`, paso 34 px) `:123-126`.
- Emblema circular 128×128 con gradiente violeta→cian, glow y glifo
  `Icons.auto_awesome` que rota levemente `:136-171`.
- Marca `app_name` en Space Grotesk 24 / w900 / letterSpacing 3.5 con sombra
  cian `:179-193`.
- Subtítulo `splash_system_hud` en mono 10 `:197-205`.
- `SegmentedBar` de **14 segmentos**, altura 5 `:216-221`.
- Texto `splash_connecting(pct)` «NN% · CONECTANDO AL GRAN REINO» `:223-232`.

**Componentes interactivos.** Ninguno. Es una pantalla sin entrada de usuario.

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Éxito | barra avanza 0→100 % y navega a `/` | `:70-88` |
| Warm-up lento | timeout a 3 s y navega igual (`timedOut=true` en `StartupProbe`) | `:31, :76-84` |
| Error de red | **ninguno visible** (decisión deliberada; sólo telemetría) | `:54-62` `[PARCIAL]` — sin superficie de error (UX-36, issue #261) |

**Acceso/salida.** Entrada: `initialLocation`. Salida: `context.go('/')`, sin
posibilidad de volver.

**Relacionadas.** SCR-02. **Datos:** lectura `user_language_profiles?id` (sólo
warm-up, no se usa el valor). `StartupProbe.markReady` alimenta `app_open`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. Fondo decorativo: 3 orbes radiales (violeta α .28, cian α .18, dorado α .10)
   y rejilla `CustomPaint` paso 34 px (`splash_screen.dart:97-126`).
2. Emblema circular 128×128, gradiente violeta→cian, glow pulsante y glifo
   `auto_awesome` que rota (`:134-171`).
3. Nombre de la app en Space Grotesk 24 w900, tracking 3.5, sombra cian
   (`:177-195`).
4. Subtítulo mono 10 con tracking 2.5 (`:197-205`).
5. `Spacer` → bloque inferior: `SegmentedBar` de 14 segmentos + texto
   «NN% · CONECTANDO» (`:207-236`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `user_language_profiles` (`select id … limit 1`) — sólo warm-up, el valor se descarta (`splash_screen.dart:56-60`) |
| **Escribe** | nada en BD; `StartupProbe.markReady` (telemetría en memoria) (`:81-84`) |

**Sin red.** El warm-up tiene `catch (_)` deliberado y `timeout` de 3 s: **no hay
estado de error**, se navega igual (`:61`, `:76-84`). Es el único punto de la app
donde «sin red» es invisible por diseño.

**Destinos de acción.** No hay controles; única salida automática `go('/')`
(`:86`).

---

### SCR-02 · Welcome — login y registro

| Campo | Valor |
|---|---|
| Módulo | `onboarding` |
| Ruta | `/` (`router.dart:35`) |
| Archivo | `welcome_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Autenticar al cazador por **Google (Android)** o por
**email/contraseña**, con recuperación de contraseña y cambio de modo
login↔registro en la misma vista.

**Objetivo narrativo.** «Entrar al reino»: título y subtítulo de bienvenida, sin
ventana de sistema (se retiró el `SYSTEM MESSAGE` anterior, `:225`).

**Elementos.** Contenedor con scroll; título `login_title`; subtítulo
`login_subtitle`; formulario; separador «o continúa con Google»; dos botones de
Google; overlay de autenticación a pantalla completa; `SnackBar` de error.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Toggle de modo (texto) | alterna `_isRegisterMode` | cambia rótulos y botón | `:501-510` |
| Campo email | `TextEditingController` con `mail_outline_rounded` | validación de teclado email | `:398-425` |
| Campo contraseña | `obscureText`, `onSubmitted` | envía el formulario | `:427-454` |
| Botón principal | `_submitEmailAuth` | `signUpWithEmail` o `signInWithEmail`; muestra spinner 24×24 y desactiva | `:456-484`, `:619-700` |
| «Olvidé mi contraseña» | diálogo de reset | envío de email de recuperación | `:487-498`, `:516` |
| REGISTER WITH GOOGLE (primario violeta) | `signInWithGoogle` + `isRegisteringProvider = true` | `go('/onboarding')`; error → `SnackBar` | `:272-320` |
| LOG IN WITH GOOGLE (outlined) | `signInWithGoogle` + `_completeLogin` | resuelve destino | `:322-351` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Carga | `_buildAuthOverlay` a pantalla completa con spinner | `:156, :163-218` |
| Éxito | navegación (onboarding, home) | `:296, :54-148` |
| Error | `SnackBar` crudo (no `SystemSnack`) | `:302-304, :335-337` `[PARCIAL]` — 52 `SnackBar` crudos, UX-10 |
| Vacío | n/a | — |

**Acceso/salida.** Entrada: redirect cuando no hay sesión. Salida: `/onboarding`
o `/home` (vía `_completeLogin` / redirect).

**Relacionadas.** SCR-01, SCR-03. **Datos:** Supabase Auth
(`signInWithIdToken`, `signUp`, `signInWithPassword`, `resetPasswordForEmail`);
`isRegisteringProvider`; warm-up de `user_language_profiles`.

> **Nota de marca:** `MaterialApp.title` es `'Dungeon of English'`
> (`app.dart:64`) y existe un issue abierto de unificación de marca (P-50,
> #135).

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. Fondo del tema (`voidBg`) + 2 orbes difuminados (violeta arriba-izquierda,
   cian abajo-derecha) (`welcome_screen.dart:88-122`).
2. Cabecera de marca centrada: `auto_awesome` violeta 24 + `app_name` en 16
   w700 violeta con tracking 2 (`:128-148`).
3. Título `login_title` (Space Grotesk 26 w900) (`:226-233`).
4. Subtítulo `login_subtitle` (Inter 13, `onSurfaceVariant`) (`:235-241`).
5. Formulario email + contraseña + «olvidé mi contraseña» (`:243`).
6. Separador «o continúa con Google» (`:246-261`).
7. **REGISTER WITH GOOGLE** (violeta, elevado) (`:263`, `:272-320`).
8. **LOG IN WITH GOOGLE** (outlined) (`:265`, `:322-351`).
9. Overlay de autenticación a pantalla completa cuando `_isAuthenticating`
   (`:156-218`).

> **Hallazgo de jerarquía:** el botón de **registro** va por encima y en estilo
> primario aunque el modo sea «login»; el modo sólo cambia el formulario de
> email (`:501-510`), no los botones de Google. La acción más llamativa de la
> pantalla es crear cuenta.

| Datos | Fuente concreta |
|---|---|
| **Lee** | sesión de Supabase Auth (`currentUserProvider`); `user_language_profiles` en warm-up (`:38-48`, invocado en `:287` y `:326`); `isRegisteringProvider` |
| **Escribe** | Auth: `signUp`, `signInWithPassword`, `signInWithIdToken` (Google), `resetPasswordForEmail` (`:619-700`, `:516-616`). **No** escribe tablas propias |

**Sin red.** `catch` por acción → `SnackBar` crudo con texto genérico
(`:302-304`, `:335-339`, `:717`); no hay pantalla de error ni reintento. La
sesión puede tardar hasta 5 s en propagarse y se espera explícitamente
(`:60-65`).

**Destinos de acción.**

| Control | Destino |
|---|---|
| Registro email OK | `/onboarding` (`:684`) |
| Login email OK | `_completeLogin` → `navDestinationToPath(destination)` (`:54-74`) |
| Google registro | `/onboarding` (`:296`) |
| Google login | `_completeLogin` (`:330`) |
| «Olvidé mi contraseña» | diálogo; no navega (correo fuera de la app) (`:516-616`) |

---

### SCR-03 · Onboarding — creación del cazador

| Campo | Valor |
|---|---|
| Módulo | `onboarding` |
| Ruta | `/onboarding` (`router.dart:36-39`) |
| Archivo | `onboarding_screen.dart` (+ `character_creation_wizard.dart`, `class_stats_radar.dart`) |
| Etiqueta | **`[IMPLEMENTADO]`** (4 pasos) / **`[PARCIAL]`** (placement opcional) |

**Objetivo funcional.** Recoger idioma nativo → idioma objetivo → nivel (Oráculo
o salto manual a PRE-A1) → nombre y clase, y persistir el perfil
(`user_language_profiles` + `users`).

**Objetivo narrativo.** «Crear tu personaje»: elegir clase de cazador (guerrero,
mago, asesino, nigromante, sacerdote), rareza y habilidades, con un radar de
stats por clase.

**Elementos.** Fondo `CyberManhwaBackground` con `bgMode` distinto por paso
(`onboardingStep0/2/7/3`, `:399-409`); indicador «N/4» `:507`; `PageView` **no
deslizable** (`NeverScrollableScrollPhysics`, `:518-527`); botón inferior
«continuar» oculto en el paso 4 `:532`; botón atrás `:192-203`; diálogo de
privacidad `:157-190`; wizard de personaje con selector de clase y tarjeta
expandible (`character_creation_wizard.dart:125-300`).

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Selector de idioma nativo | set `_selectedNativeLanguageCode` | obligatorio para avanzar (valida y avisa) | `:108-117`, `:952-1067` |
| Selector de idioma objetivo | set `_selectedLanguageCode` | obligatorio | `:118-127`, `:1068-1145` |
| CTA del paso 3 | `_startOracleEvaluation` | `push('/oracle-test?target=…&native=…')` y espera resultado; al volver fija `_selectedCefrCode` y salta al paso 4 | `:208-225` |
| «Saltar como PRE-A1» | `_skipOracleAsPreA1` | asigna PRE-A1 sin examen | `:229` |
| Selector de clase | `setState(_selectedClass)` | tarjeta seleccionada + radar | `character_creation_wizard.dart:139` |
| Botón «continuar» del wizard | guarda perfil | spinner, `SystemSnack` de error accionable | `:289`, `:371-386` |
| Atrás | `_prevPage` | animación 300 ms `easeInOut` | `:192-203` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Carga | spinner 24×24 en el botón | `:553-561` |
| Error al guardar | `SystemSnack` «NO SE PUDO GUARDAR TU PERFIL. Revisa tu conexión e inténtalo de nuevo.» | `:380-384` |
| Éxito | `_showHeroWelcome = true` y `_enterRealm()` | `:358-362`, `:392-397` |
| Validación | avisos por paso (idioma no elegido) | `:89-127` |

**Acceso/salida.** Entrada: redirect con sesión sin perfil. Salida: `/home` o
`/mini-conversation` (primera vez, vía `wasSeen`, `:394-396`).

**Relacionadas.** SCR-02, SCR-04, SCR-05 (Oráculo). **Datos:**
`user_language_profiles` (upsert), `users` (perfil), `hunter_classes` (catálogo
DB), `evaluate-placement` (resultado del Oráculo),
`apply_self_declared_level` (RPC, `onboarding_repository_impl.dart:80`),
`NavigationDecisionEngine.markProfileExists`.

**Observación.** El paywall **no** aparece aquí: se fuerza `setPremium(false)`
(`:343-344`) y se mueve post-sesión. Correcto según `docs/PRODUCT.md`, pero
implica que un usuario nuevo no ve la oferta hasta después de practicar.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground` con fondo distinto por paso (0→`onboardingStep0`,
   1→`onboardingStep2`, 2→`onboardingStep7`, 3→`onboardingStep3`) + 2 orbes
   (`:399-452`).
2. Cabecera: atrás (sólo desde el paso 1), 4 barras de progreso, «N/4»
   (`:465-513`).
3. `PageView` **sin swipe** con las 4 páginas (`:517-528`).
4. Botón inferior violeta «continuar» / «empezar evaluación», **oculto en el
   paso 4** (el wizard tiene el suyo) (`:531-570`).
5. Pantalla de héroe final (licencia de gremio) con
   `CyberManhwaBackground(onboardingStep3)` (`:632`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | catálogos `languages`, `cefr_levels`, `hunter_classes`; `currentUserProvider`; `deviceLocaleProvider`; `miniConversationStoreProvider` (`wasSeen`) |
| **Escribe** | `users` (nombre, clase, avatar, bio), `user_language_profiles` (upsert), `user_ai_profiles`/`user_settings` (valores por defecto), RPC `apply_self_declared_level` (`onboarding_repository_impl.dart:80`); estado local `isPremium=false` (`:343-344`) |

**Sin red.** Fallo de guardado → `SystemSnack` accionable y **se queda** en el
wizard (`:371-386`). Si el Oráculo no puede evaluar (red/401), al volver no hay
`cefrLevel` y se asume **A1** por defecto (`:213-219`, `:215-218` del flujo).

**Destinos de acción.**

| Control | Destino |
|---|---|
| «Empezar evaluación» | `push('/oracle-test?target&native')` y espera `pop(result)` (`:208-225`) |
| «Saltar como PRE-A1» | sigue en el paso 4, sin navegar (`:229-240`) |
| Wizard `onComplete` | avanza a la tarjeta de héroe, sin navegar (`:938-949`) |
| «ENTRAR AL REINO» | `go('/mini-conversation')` o `go('/home')` según `wasSeen` (`:392-397`) |

---

### SCR-04 · Mini-conversación — prueba de valor de 60 s

| Campo | Valor |
|---|---|
| Módulo | `onboarding` |
| Ruta | `/mini-conversation` (`router.dart:42-45`) |
| Archivo | `mini_conversation_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Dar una primera experiencia real de hablar con «Mira»
(«pide un café») antes de entrar al reino, sin bloquear nunca: si el modelo o la
red fallan, se puede continuar.

**Objetivo narrativo.** La taberna: la primera conversación con un personaje
(DOC de cabecera `:163-168`).

**Elementos.** Lista de mensajes con scroll automático `:60-68`; micrófono;
campo de texto; botones de salto/continuar; `GlassCard` de contexto.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Micrófono | `_toggleRecording` | graba AAC-LC 128 kbps / 16 kHz; si no hay permiso → aviso; transcribe y responde | `:79-146` |
| Enviar texto | `_sendText` | `replyText` (acción gratuita `guild_chat`) | `:70-77` |
| Saltar / continuar | `_leave(skipped:)` | `finish()`, guarda `wasSeen` y `go('/home')` | `:148-158` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Grabando | estado local `_isRecording` + botón activo | `:135` |
| Transcribiendo | `_isTranscribing` | `:88-93` |
| Audio vacío | `SystemSnack` warning «no oímos nada» | `:95-101` |
| Fallo de transcripción | `SystemSnack` error | `:102-109` |
| Micrófono denegado/indisponible | `SystemSnack` warning | `:114-124`, `:136-145` |

**Acceso/salida.** Entrada: sólo la primera vez (`miniConversationStore
.wasSeen(userId)`), desde el onboarding. Salida: `/home`.

**Relacionadas.** SCR-03, SCR-06. **Datos:** `llm-proxy/transcribe`,
`llm-proxy/chat` con `action_code=guild_chat` (gratuita), `SharedPreferences`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(onboardingStep3)` → `dungeon_wind_b1_bg.jpg`
   (`mini_conversation_screen.dart:170-171`).
2. Cabecera: badge «60-SECOND TRIAL» (mono dorado), título «Order a coffee»,
   botón cerrar (`:205-233`).
3. Barra de progreso de turnos (una barra por turno de usuario) (`:235-257`).
4. Lista de burbujas (usuario derecha/cian, Mira izquierda/dorado) + indicador
   de escritura de 3 puntos (`:182-191`, `:259-309`).
5. Panel inferior: estado («YOUR TURN» / «TRANSCRIBING…» / «RECORDING…»), campo
   de texto, micrófono, enviar, contador y «SKIP» (`:311-421`); o panel de
   cierre con la frase desbloqueada o «MIRA IS NOT AVAILABLE» (`:424-501`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `llm-proxy/chat` (turnos en memoria) y `llm-proxy/transcribe` (`:79-146`) |
| **Escribe** | `SharedPreferences` (marca `wasSeen` al llamar `finish`) (`:148-158`). **No** escribe progreso de lección |

**Sin red.** `state.failure != null` → panel «MIRA IS NOT AVAILABLE» con CTA
«CONTINUE» que no bloquea (`:428-463`); STT vacío o fallido → `SystemSnack`
warning/error (`:95-109`).

**Destinos de acción.** Todos los caminos terminan en `go('/home')`:
cerrar (`:228`), «SKIP FOR NOW» (`:410`), «START MY ADVENTURE» (`:495`) y
«CONTINUE» del fallo (`:462`).

---

### SCR-05 · Conversación con el tutor / Oráculo / Jefe

| Campo | Valor |
|---|---|
| Módulo | `conversation` |
| Rutas | `/conversation?scenarioId&scenarioTitle`, `/oracle-test?target&native&mode=promotion` |
| Archivo | `conversation_screen.dart` (2 362) + `conversation_providers.dart` (2 956) |
| Etiqueta | **`[IMPLEMENTADO]`** — el corazón del producto |

**Objetivo funcional.** Ejecutar un turno completo de conversación: grabar →
transcribir (Groq Whisper vía proxy) → responder en streaming (DeepSeek vía
proxy) → narrar (TTS local) → evaluar metas y correcciones → persistir. En modo
Oráculo, conducir el examen de nivel; con `mode=promotion`, la capa de jefe de
mazmorra.

**Objetivo narrativo.** «Entrar a la mazmorra/escena» con un mentor-avatar
(Oráculo, retrato `oracle_01.png`, `:1258-1265`); la barra superior se llama
`oracle_title` en modo examen; el jefe muestra **barra de vida por turnos**
(`BossExamHealthBar`, `:1331-1335`).

**Elementos (de arriba abajo).**

1. Barra superior: atrás, título (nombre de escena u `oracle_title`), botón
   «voz del tutor» (`Icons.tune_rounded`), avatar circular 30×30.
2. Barra de progreso de la lección (`%` real de metas cumplidas, color
   `#F1C40F` literal) `:1269-1309`.
3. `LiveGoalsTrackerBar` con compás que abre el detalle de misión
   `:1316-1325`.
4. `BossExamHealthBar` (sólo promoción) `:1329-1336`.
5. Barra de modos con scroll horizontal: `OracleManaBar` (coste por turno 12 si
   hay escenario, 8 si chat libre) `:1345-1364`; toggle **Chat Oculto/Visible**
   (magenta `#FF00FF`) `:1366-1426`; toggle **Modo Voz/Escritura** `:1428-1489`;
   botón **«Necesito ayuda»** (frases del escenario) `:1493-1534`.
6. `VoiceWaveformVisualizer` (habla IA / habla usuario) `:1543-1548`.
7. Chip de memoria del intento anterior (si `attempts ≥ 2` y no fue éxito)
   `:1551-1580`.
8. Lista de mensajes con auto-scroll; burbujas con corrección embebida.
9. Caja de escritura (drawer) con enviar y cerrar `:1840-1866`.
10. `MicPermissionCard` accionable `:1870-1883`.
11. `ConversationStatusBar`: escuchando / pensando / hablando, detener, ajustes
    y velocidad TTS `:1886-1903`.
12. Fila de 5 controles `:1905-2090`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `_handleExit` | cierra sesión (idempotente), invalida dashboard y hace `push('/summary')` | `:1207-1221`, `:92-140` |
| Voz del tutor | `_showTtsSettingsSheet` | sheet de voz y velocidad | `:1244-1257` |
| Compás | `_showScenarioMissionModal` | objetivos de la misión | `:1918-1927` |
| Hashtag | `_showTopicsBar` | 20 temas al azar (lista hardcodeada en inglés) | `:1930-1946`, `:142-163` |
| Micrófono | tap-to-toggle **o** hold-to-talk según `user_settings` | si la IA habla, la corta; si graba, corta; si no, graba | `:2024-2058` |
| «Necesito ayuda» | `_showHelpPhrases` | sheet de frases reales del escenario | `:1493-1495` |
| Huella de voz | `_showSpeechDnaModal` | métricas biométricas de habla | `:2061-2069` |
| Teclado | abre drawer de texto | alterna con temas | `:2075-2089` |
| Enviar texto | `_submitTextMessage` | mismo pipeline que la voz | `:1841, :1850` |
| CONTINUAR (fin del Oráculo) | devuelve resultado | si `mode == 'boss'` → `push('/boss-result', extra: outcome)`; si no → `pop(result)` o `/home` | `:1949-2020` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Sin maná al entrar | `pushReplacement('/dungeon-guardian')` antes de iniciar | `:188-224` |
| Grabando | `isRecording` + waveform + barra de estado | `conversation_state.dart:10` |
| Procesando | `isProcessing` («Pensando…» medido desde el primer chunk) | `:11`, `conversation_providers.dart:1693` |
| Hablando | `isPlaying` + botón «Detener» | `:12`, `:1900` |
| Error de IA | se **elimina** el placeholder vacío, no se narra, se ofrece reintento con `canRetry` | `conversation_providers.dart:1867-1912` |
| Micrófono denegado | tarjeta con «Abrir ajustes» y «Reintentar» | `:1870-1883` |
| Oráculo terminado | botón dorado CONTINUAR | `:1949-2020` |
| Sesión sin turnos | al salir no se registra sesión ni hay resumen | `:103-106` |

**Acceso/salida.** Entrada: CTA del dashboard, roadmap, Oráculo del onboarding.
Salida: `_handleExit` por back, gesto (`PopScope`) o `dispose`; todas las rutas
de salida persisten una sola vez.

**Relacionadas.** SCR-06 (origen), SCR-13 (destino), SCR-12 (bloqueo por maná),
SCR-17 (jefe), SCR-18 (errores), SCR-20 (listening).

**Datos/RPC.** `scenarios` (carga por id o por título), `conversations`,
`messages`, `user_scenario_goals`, `llm-proxy/chat` y `/transcribe`,
`curate_session_vocabulary`, `get_session_learned_summary`,
`record_scenario_outcome`, `check_ai_audio_quota`, `track_ai_audio_time`,
`close_session` al salir, `evaluate-placement` (Oráculo),
`user_recurring_errors` (prompt).

> **Riesgo medido:** cero widget tests de esta pantalla (issue #254) y anchos
> fijados por porcentaje/altura sin `LayoutBuilder` (`:897, :1622, :1657`).

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. Cabecera (atrás, título de escena u `oracle_title`, `tune`, avatar del tutor
   30×30) (`:1199-1267`).
2. Barra de progreso de metas + `%` en `#F1C40F` literal (`:1269-1309`).
3. `LiveGoalsTrackerBar` con compás (`:1316-1325`).
4. `BossExamHealthBar` sólo en promoción (`:1329-1336`).
5. Fila de modos con scroll: `OracleManaBar` (coste 12/8), Chat Oculto, Modo
   Voz/Escritura, «Necesito ayuda» (`:1338-1537`).
6. `VoiceWaveformVisualizer` (`:1543-1548`).
7. Chip de memoria del intento anterior (`:1551-1580`).
8. Lista de mensajes con auto-scroll (`:1585+`).
9. Drawer de teclado / barra de temas (`:1840-1866`).
10. `MicPermissionCard` (`:1870-1883`).
11. `ConversationStatusBar` (escuchando/pensando/hablando, detener, velocidad)
    (`:1886-1903`).
12. Fila inferior de 5 controles (compás, hashtag, mic/CONTINUAR, huella,
    teclado) (`:1905-2090`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `scenarios`, `scenario_phrases`, `user_scenario_goals`, `user_vocabulary`, `user_settings`, `user_ai_profiles`, `lesson_progress`, `scenario_progress`, `user_recurring_errors`; providers `conversationStateProvider`, `conversationErrorProvider`, `manaStateProvider`, `scenarioProgressProvider` |
| **Escribe** | `conversations`, `messages`, `oracle_turns`, `oracle_assessments`, `scenario_progress`, `user_scenario_phrases`, `user_vocabulary`, `daily_fluency_stats`, `speech_dna_metrics`; RPC `close_session` (`economy_repository_impl.dart:798`, que además es quien aplica XP/oro/fragmentos), `record_scenario_outcome` (`conversation_providers.dart:2493`), `curate_session_vocabulary` (`conversation_repository_impl.dart:702`), `consume_mana` (`economy_repository_impl.dart:785`), `refund_failed_turn` (`:877`), `check_ai_audio_quota`/`track_ai_audio_time` (`conversation_repository_impl.dart:1094,1111`). `lesson_progress` se toca en servidor al cerrar: **`[PENDIENTE DE VALIDAR]`** qué RPC exacta lo escribe (requiere SQL de solo lectura sobre las funciones) |

**Sin red.** Error de IA → se elimina el placeholder, no se narra y se ofrece
`canRetry` (`conversation_providers.dart:1867-1912`); el mensaje de error se
muestra con `SystemSnack` salvo que sea cuota (`:1111-1117`). Micrófono denegado
→ tarjeta con «Abrir ajustes»/«Reintentar» (`:1870-1883`). Sin maná a mitad →
se abre el Guardián **encima** de la conversación (`:1101-1110`).

**Destinos de acción.**

| Control | Destino |
|---|---|
| Atrás (cabecera) | `pop()` o `go('/home')` — **sin** resumen (`:1207-1220`) |
| Back/gesto del sistema | `push('/summary')` (`PopScope`, `:1161-1171`) |
| Sin maná al entrar | `pushReplacement('/dungeon-guardian')` (`:220`) |
| CONTINUAR (jefe) | `push('/boss-result', extra: outcome)` (`:1970-1974`) |
| CONTINUAR (placement) | `pop(rawResult)` o `go('/home')` (`:1977-1981`) |
| Compás / hashtag / ayuda / huella / teclado | sheets y drawers locales (sin cambiar de ruta) |

---

### SCR-06 · Dashboard — centro de mando del cazador

| Campo | Valor |
|---|---|
| Módulo | `dashboard` |
| Ruta | `/home` (`router.dart:63`) |
| Archivo | `dashboard_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** con **`[PARCIAL]`** en el estado offline |

**Objetivo funcional.** Ser el hub: identidad + nivel, HUD, meta diaria, repaso
SRS, misión del día, upsell Pro, accesos rápidos, CTA de práctica, roadmap
A1–C2 y dock de 4 pestañas.

**Objetivo narrativo.** «Centro de control del cazador»: avatar con marco
cosmético, clase, CEFR, insignias, racha y un sendero de mazmorras por nivel.

**Elementos.**
- Banner offline ámbar con antigüedad de caché `:270-298`.
- Barra superior con `RpgAvatar` 32, nombre en mayúsculas, `cefr_level` y botón
  de logout `:300-369`.
- `HunterHudHeader`, `WelcomeBackCard`, `DailyGoalRingCard`, `SrsReviewCard`,
  `MissionSpotlightWidget` `:391-405`.
- Badge PRO / IR PRO `:408-487`.
- 4 accesos rápidos: TIENDA, ORÁCULO, DAILY, ERRORES `:492-531`.
- CTA «CONTINUAR AVENTURA» con esquinas rúnicas `:41-129`.
- `LearningPathRoadmap` A1–C2 `:539-542`.
- Dock flotante `GlassCard` con 4 destinos `:559-604`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Avatar/nombre | `GestureDetector` | **sin `onTap`** hoy | `:309-312` `[PARCIAL]` |
| Logout | `_confirmLogout` | diálogo; `signOut()` y `go('/')` | `:361-367`, `:665-712` |
| CTA principal | `context.push('/conversation?scenarioId=…')` | sigue la ruta recomendada del servidor | `:54-65` |
| Badge PRO | `push('/paywall')` sólo si no es premium | — | `:416-419` |
| TIENDA | `push('/shop')` | — | `:500` |
| ORÁCULO | `push('/oracle-test')` | — | `:506-507` |
| DAILY | `DailyRewardModal.show` | reclamo de recompensa diaria | `:519-520` |
| ERRORES | `push('/my-errors')` | — | `:528` |
| Dock 0/1/2/3 | `dashboardTabProvider` | cambia pestaña sin navegar | `:576-599` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Cargando progreso | **no** se inventan cifras: valores base 0/A1 | `:173-183` |
| Error sin caché | pantalla completa `cloud_off` + «Sin conexión. Mostrando el último progreso guardado.» + REINTENTAR | `:195-231` |
| Error con caché | banner ámbar + datos cacheados | `:270-298` |
| Teclado abierto | dock se desplaza fuera (`bottom: -160`) | `:189, :560` |

**Acceso/salida.** Entrada: redirect con perfil, `/` tras splash, `go('/home')`
desde casi todas las pantallas. Salida: pestañas o navegación.

**Relacionadas.** Todas (es el hub). **Datos:** `get_dashboard_state`,
`get_daily_goal_progress`, `claim_daily_goal_celebration`,
`learning_evidence`, `get_leaderboard`, `refresh_recommended_path`,
`completedLessonsProvider`, `equippedCosmeticsProvider`, `isPremiumProvider`.

> ⚠️ **Contradicción interna medida:** en la rama `hasError && !hasValue` el
> copy afirma «Mostrando el último progreso guardado» cuando precisamente **no
> hay** valor guardado. Issue #256 (UX-17) abierto.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. Banner ámbar de offline con antigüedad de caché (condicional)
   (`dashboard_screen.dart:270-298`).
2. Barra superior: `RpgAvatar` 32 + nombre 17 w800 + CEFR mono 9 / logout
   (`:300-369`).
3. Cuerpo (pestaña 0): `HunterHudHeader` → `WelcomeBackCard` →
   `DailyGoalRingCard` → `SrsReviewCard` → `MissionSpotlightWidget` (`:391-405`).
4. Fila de badge PRO / IR PRO alineada a la derecha (`:408-487`).
5. Fila de 4 accesos rápidos: TIENDA, ORÁCULO, DAILY, ERRORES (`:492-531`).
6. CTA «CONTINUAR AVENTURA» con esquinas rúnicas (`:536`, `:41-129`).
7. `LearningPathRoadmap` A1–C2 (`:539-542`).
8. `SizedBox(100)` de relleno + dock flotante con 4 destinos (`:546-604`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | RPC `get_dashboard_state` (`dashboard_repository_impl.dart:31`), `get_daily_goal_progress` (`dashboard_providers.dart:45`), `learning_evidence` (`:183`), `get_leaderboard` (`:652`), `refresh_recommended_path` (`dashboard_repository_impl.dart:298`); tablas `user_language_profiles`, `users`, `scenarios`, `daily_stats`, `user_vocabulary` |
| **Escribe** | RPC `claim_daily_goal_celebration` (`dashboard_providers.dart:71`); recompensa diaria: `add_gems`, `increment_pergaminos_max` y **update directo** de `player_daily_state` (`economy_repository_impl.dart:221-235`) |

> **Hallazgo (recompensa diaria):** el importe de DAILY se calcula **en el
> cliente** a partir de `current_streak` (5/50/100/300 gemas;
> `economy_repository_impl.dart:205-219`) y el `catch (_)` devuelve `{}` sin
> mensaje (`:242-244`), contra la convención del repo de no dejar `catch` vacío.
> Si el servidor valida el importe es **no verificable desde el repo** →
> `[PENDIENTE DE VALIDAR]` con MCP `supabase`.

**Sin red.** Dos ramas: sin caché → pantalla completa `cloud_off` + REINTENTAR
(`:195-231`); con caché → banner ámbar y datos guardados (`:270-298`). Es la
única pantalla con distinción explícita entre «sin red y con caché» y «sin red
sin caché».

**Destinos de acción.**

| Control | Destino |
|---|---|
| CTA principal | `push('/conversation?scenarioId&scenarioTitle')` (`:63-65`) |
| Badge PRO (si free) | `push('/paywall')` (`:418`) |
| TIENDA / ORÁCULO / ERRORES | `/shop` · `/oracle-test` · `/my-errors` (`:500,507,528`) |
| DAILY | `DailyRewardModal.show` (bottom sheet) (`:519-520`) |
| Logout | diálogo → `signOut()` → `go('/')` (`:665-712`) |
| Dock | cambia `dashboardTabProvider` (no navega) (`:576-599`) |

---

### SCR-07 · Salón del Gremio — mesas y trofeos

| Campo | Valor |
|---|---|
| Módulo | `chat_rooms` |
| Rutas | `/chat-rooms` y **pestaña 1** del dashboard (`isTab: true`) |
| Archivo | `chat_rooms_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** núcleo / **`[PARCIAL]`** en estados |

**Objetivo funcional.** Descubrir y unirse a mesas de conversación en grupo,
crear mesa nueva, ver trofeos del gremio y atajos (rango, inventario, música).

**Objetivo narrativo.** «Salón del gremio»: estandartes, trofeos por misiones
colaborativas (`GUILD-03`), Maestre de Mesa y música de taberna opcional.

**Elementos.** `CyberManhwaBackground(guildHall)` `:955-956`; `AppBar`
`:959`; cabecera del salón con trofeos `_GuildHallHeader`/`_GuildTrophies`
`:990-1270`; 3 atajos: RANGO (modal), INVENTARIO, MÚSICA `:591-613`; bloque
«MESAS» + botón CREAR MESA `:622-662`; selector de categorías horizontal
`:668-730`; lista de salas con realtime `_roomsChannel` `:59`; estado vacío
`guild_no_rooms` `:747`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| RANGO | `_showRankModal` | modal de rango/liga | `:595` |
| INVENTARIO | `push('/inventory')` | — | `:602` |
| MÚSICA | `_toggleMusic` | alterna música de taberna (`tavern_music_service`) | `:606-613` |
| CREAR MESA | `_showCreateRoomDialog` | diálogo; inserta sala | `:641`, `:264` |
| Categoría | `setState(_selectedCategory)` | filtra la lista | `:689-693` |
| Unirse a mesa | `join_table` + navegación a sala | `push` a `/voice-room?roomId=…` | `:441`, `:602` |
| Salir de mesa | `leave_table` | — | `chat_rooms_repository_impl.dart:205` |

**Estados.** Carga (spinner) `:905, :1187`; vacío `:742-748`; error en
`.when` `:736`; realtime activo.

**Acceso/salida.** Entrada: dock (tab 1) o `/chat-rooms`. Salida: dock o back.

**Datos.** `chat_rooms`, `chat_room_participants`, `chat_room_messages`,
`guild_collaborative_missions` (conteo), `join_table`, `leave_table`,
`touch_presence`, realtime channel.

> ⚠️ Sin `SafeArea` (0 usos) pese a tener `AppBar` y listas — UX-37, issue #261.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(guildHall)` → `guild_hall_adventurers_bg.jpg`
   (`chat_rooms_screen.dart:955-956`).
2. Cabecera del salón: título, línea de rango/CEFR y chip de prestigio
   (`:1017-1058`).
3. Vitrina de trofeos y atajos: RANGO (modal), INVENTARIO, MÚSICA
   (`:591-613`).
4. Bloque «MESAS» + botón CREAR MESA (`:622-663`).
5. Selector horizontal de categorías (`:668-732`).
6. Lista de mesas con ocupación (`seats/max`, de pie) y estado de ocupación
   (`:736-917`).
7. Vitrina de trofeos del gremio al final (`:932`).
8. `GuildMasterFloatingBanner` arrastrable como último hijo del `Stack`
   (`:945`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `chat_rooms`, `chat_room_participants`, `chat_room_messages`, `guild_collaborative_missions`, `guild_announcements`, `user_language_profiles`, `users`; provider de battle pass (`guild_battle_pass`) |
| **Escribe** | `createRoom` (llamado en `:431`) + RPC `join_table` (`chat_rooms_repository_impl.dart:446`), `leave_table` (`:205`), `touch_presence` (`:535`) |

**Sin red.** `.when` con `error` que imprime `Error loading active gates: $err`
en texto rojo, **sin reintento** (`:908-916`); el vacío es explícito
(`guild_no_rooms`, `:742-748`). Sin `SafeArea`, el contenido puede quedar bajo
la barra de estado.

**Destinos de acción.**

| Control | Destino |
|---|---|
| Unirse a mesa | `push('/voice-room?roomId=…')` (`:441`, `:768`, `:774`, `:880`; también `guild_master_floating_banner.dart:111,113`) |
| INVENTARIO | `push('/inventory')` (`:602`) |
| MÚSICA | alterna `TavernMusicService` (sin navegar) (`:606-613`) |
| RANGO | modal de rango (sin navegar) (`:595`) |
| Banner del Maestre | `push('/voice-room')` de la primera mesa (`guild_master_floating_banner.dart:111`) |

---

### SCR-08 · Sala de voz — mesa con asientos

| Campo | Valor |
|---|---|
| Módulo | `chat_rooms` |
| Ruta | `/voice-room?roomId` (`router.dart:64-70`) |
| Archivo | `voice_room_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** con degradación explícita |

**Objetivo funcional.** Conectar audio real por LiveKit según el estado de
presencia del usuario (sentado = puede publicar; de pie = sólo escucha),
gestionar asientos, levantar la mano y moderar.

**Objetivo narrativo.** «Mesa del gremio»: cazadores sentados alrededor de una
mesa; sólo quien tiene asiento habla.

**Elementos.** `CyberManhwaBackground(guildTable)` `:565`; cabecera de sala;
grid de participantes con estado `seated|standing` `:833-900`; `SegmentedBar`
de ocupación `:812`; controles de micrófono, mano, asiento, moderación y salida;
hoja modal con ajustes `:352`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Entrar | `joinTable` + `_connectLiveKit` | token desde `livekit-token` con `publish = seated` | `:62-68`, `:92-121` |
| Sentarse | `claim_seat` | si el servidor concede → `_presenceState='seated'` y snack «TE SENTASTE EN LA SILLA N» | `:148-227` |
| Pedir asiento | `request_seat` | si `outcome == 'seated'` actualiza estado | `:229-253` |
| Levantarse | `stand_up` | vuelve a `standing`, reconecta LiveKit (grants inmutables) | `:254-274`, `:126-130` |
| Moderar | `moderator_stand` | expulsa a otro; snack diferenciado si no eres moderador | `:275-290` |
| Salir | `leave_table` + `disconnect` | — | `:77`, `:205` |
| Heartbeat | `touch_presence` | cada ciclo de vida | `:86`, `:535` |

**Estados.** Cargando (2 spinners) `:430, :1113`; error en `.when` `:391, :830`;
sin LiveKit → «presencia sin audio» (degradación) `:119`; 10 `SystemSnack` para
resultados de asiento/permisos `:149-244`.

**Acceso/salida.** Entrada: `join_table` desde SCR-07. Salida: back/`go`.

**Datos.** `livekit-token`, `claim_seat`, `request_seat`, `stand_up`,
`moderator_stand`, `touch_presence`, `join_table`, `leave_table`, realtime de
participantes.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(guildTable)` → `guild_table_adventurers_bg.jpg` + 2
   orbes difuminados (`voice_room_screen.dart:564-600`).
2. Cabecera: atrás, título, badge «LIVE» carmesí y subtítulo
   (`:606-665`).
3. Banner de demo de audio, colapsable (`:700-723`).
4. Tarjeta «MISIÓN DE LA SALA» + «RESONANCIA» con `SegmentedBar` de 10
   (`:729-818`).
5. Grid de participantes por asientos (`:833-900`).
6. Tarjeta «DE PIE (n/8)» colapsable con avatares 30 (`:1000-1071`).
7. Tarjeta de chat de la sala → bottom sheet (`:1074-1109`).
8. Barra flotante inferior con 4 controles (`:1118+`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `chat_rooms`, `chat_room_participants`, `chat_room_messages`, `seat_requests`, `users`/`user_language_profiles` (perfiles de participantes), `manaStateProvider` |
| **Escribe** | `join_table`, `claim_seat`, `request_seat`, `stand_up`, `moderator_stand`, `touch_presence`, `leave_table` (todas en `chat_rooms_repository_impl.dart:205-535`) |

**Sin red.** `.when` de participantes con `error` → texto rojo `room_error`
(`:1114`); sin LiveKit → degradación «presencia sin audio» (`:119`). Las
acciones de asiento devuelven `SystemSnack` por resultado (10 en la pantalla).

**Destinos de acción.** Salir → `leave_table` + `pop()`, o `go('/chat-rooms')`
si no hay pila (`:190-193`); «práctica con el Oráculo» → `push('/conversation')`
**sin escenario** (`:1237`); resto de controles no navega.

---

### SCR-09 · Misiones

| Campo | Valor |
|---|---|
| Módulo | `missions` |
| Ruta | `/missions` (`router.dart:136-139`) |
| Archivo | `missions_screen.dart` (238 líneas, la más pequeña de producto) |
| Etiqueta | **`[PARCIAL]`** — sólo diarias y semanales |

**Objetivo funcional.** Listar misiones activas en dos pestañas, permitir
reclamar recompensa y refrescar por gesto.

**Objetivo narrativo.** Tablón del gremio con «renovación automática 00:05 UTC».

**Elementos.** Cabecera con atrás + `missions_reset_hint`; `TabBar` Diarias /
Semanales; `ListView.separated` de `MissionCard`; tarjeta de vacío; tarjeta de
error con «REINTENTAR»; `RefreshIndicator`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `pop()` o `go('/home')` si no puede | **tiene fallback** (bien) | `:94-107` |
| Pestañas | `TabBarView` | cambia el provider (`daily`/`weekly`) | `:57-72`, `:148-150` |
| Tarjeta de misión | `MissionCard` | reclamo vía `claim_mission_reward` | `missions_screen.dart:183`, `mission_repository.dart:189` |
| Refrescar | `invalidate(activeMissionsProvider)` | pull-to-refresh | `:174-176` |
| Tarjeta de error | `onTap` reintenta | — | `:199-203` |

**Estados.** Cargando (spinner violeta) `:187-192`; vacío con copy explicativo
por pestaña `:152-173`; error con reintento `:193-235`.

**Acceso/salida.** Entrada: `push('/missions')` (no aparece en el dock; se llega
por spotlight/widget). Salida: back con fallback.

**Datos.** `mission_instances`, `mission_templates` (`is_active`),
`secret_missions`, `emergency_missions`, `guild_quest_pool`,
`guild_collaborative_missions`, `global_events`, `player_completed_quests`,
`reward_history`, `claim_mission_reward`.

> ⚠️ **Divergencia funcional:** el repositorio implementa misiones secretas, de
> emergencia, de evento y de gremio (`mission_repository.dart:48-612`), pero la
> pantalla **sólo** muestra `daily` y `weekly` por decisión explícita
> (`missions_screen.dart:11-15`, `MissionVisibility`). Hay motor sin superficie.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `Scaffold(backgroundColor: screenBg)` — **sin** fondo animado ni imagen
   (`missions_screen.dart:25-26`).
2. Cabecera con atrás + título 18 w800 + recordatorio «00:05 UTC» en mono 9
   (`:30`, `:82-135`).
3. `TabBar` Diarias / Semanales con indicador cian (`:33-54`).
4. `TabBarView` con una lista por pestaña (`:57-72`).
5. Lista de `MissionCard` con `RefreshIndicator` (`:174-185`); vacío en
   `GlassCard` (`:159-171`); error en tarjeta tocable con `wifi_off`
   (`:193-235`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `mission_instances`, `mission_templates`, `player_completed_quests`, `reward_history` (vista de misiones activas) |
| **Escribe** | RPC `claim_mission_reward` (`mission_repository.dart:189`) → +XP y **gemas** |

**Sin red.** No distingue «sin red» de «error»: la tarjeta de error usa el icono
`wifi_off_rounded` y el texto «No pudimos cargar tus misiones. Toca para
reintentar» (`:206-215`). Reintento por tap o pull-to-refresh.

**Destinos de acción.** Único destino de navegación: atrás → `pop()` o
`go('/home')` (`:94-107`). Reclamar **no navega**: invalida providers y muestra
`SystemSnack` (`:130-144`). No hay enlace al gremio ni a la tienda desde aquí.

---

### SCR-10 · Tienda Arcano

| Campo | Valor |
|---|---|
| Módulo | `economy` |
| Ruta | `/shop` (`router.dart:95`) |
| Archivo | `shop_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** catálogo / **`[PARCIAL]`** estado de error |

**Objetivo funcional.** Tres sumideros reales, uno por moneda: **oro**
(cosméticos por nivel), **gemas** (premium + freeze de racha, máx. 3) y
**fragmentos** (crafteo con receta). Anuncia el nivel de cazador, la próxima
meta y recompensas de nivel pendientes.

**Objetivo narrativo.** «Tienda Arcano» con el mercader del reino.

**Elementos.** Cabecera: atrás, título, chip de **maná** y mochila →
`/inventory` `:363-406`; fila de wallet desplazable (nivel + 3 monedas)
`:440-...`; banner de recompensas de nivel `:348-351`; 3 pestañas por moneda
`:353`, `:630-650`; tarjeta de freeze de racha (sólo gemas) `:677`;
`shop_next_unlock` como «PRÓXIMO DESBLOQUEO» `:718-747`; tarjetas de oferta;
estado vacío por moneda `:693-705`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Mochila | `push('/inventory')` | — | `:398-402` |
| Pestaña de moneda | `setState(_selectedTab)` | filtra por `priceFor(currency) > 0` | `:667-670` |
| Comprar con oro/gemas | `purchase_cosmetic` | servidor cobra y valida `required_level` | DOC `:346-355` |
| Freeze de racha | `purchase_streak_freeze` | máximo 3 | DOC `:350`, `:677` |
| Craftear | `craft_cosmetic` | consume fragmentos y receta | DOC `:351` |
| Reclamar recompensas de nivel | `claim_level_rewards` | banner | `:348-351` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Cargando catálogo | spinner cian | `:660-664` |
| Catálogo vacío | `_buildEmpty` «AÚN NO HAY OBJETOS» | `:665` |
| **Error de red** | **también** «AÚN NO HAY OBJETOS» (no distingue) | `:657-665` ❌ issue #255 (UX-16) |
| Moneda sin ofertas | «AÚN NO HAY OBJETOS EN ESTA MONEDA» | `:693-705` |
| Nivel insuficiente | tarjeta bloqueada por `required_level` | `shop_offer.dart` |

**Acceso/salida.** Entrada: dock de accesos, guardián, inventario. Salida:
`context.pop()` **sin fallback** (`:377`) — UX-26.

**Datos.** `get_economy_wallet`, `shopCatalogProvider`, `purchase_cosmetic`,
`purchase_streak_freeze`, `craft_cosmetic`, `claim_level_rewards`,
`level_reward_status`, `cosmetic_catalog`, `player_inventory`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(dashboardGate)` → `dashboard_dungeon_gate_bg.jpg`
   (`shop_screen.dart:339-340`).
2. Cabecera: atrás, «TIENDA ARCANO» 18, chip de maná violeta y mochila
   (`:345`, `:363-406`).
3. Fila de wallet desplazable: nivel + oro + gemas + fragmentos
   (`:347`, `:440+`).
4. Banner de recompensas de nivel pendientes (condicional) (`:348-351`).
5. 3 pestañas por moneda (`:353`).
6. Contenido: tarjeta de freeze (pestaña gemas), «PRÓXIMO DESBLOQUEO» y
   tarjetas de oferta (`:355`, `:677`, `:718-747`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `cosmetic_catalog` (`:609`), `player_inventory` (propiedad), RPC `get_economy_wallet` (`economy_repository_impl.dart:590`), `level_reward_status` (`:690`), `subscription_plans`/`min_plan` |
| **Escribe** | `purchase_cosmetic` (`:627`), `craft_cosmetic` (`:653`), `purchase_streak_freeze` (`:675`), `claim_level_rewards` (`:705`), `spend_currency` (`:569`) — todas SECURITY DEFINER |

**Sin red.** El `error` cae en `_buildEmpty` («AÚN NO HAY OBJETOS»), indistinguible
del catálogo vacío (`:657-665`). Es el caso más claro de la matriz §4.1.

**Destinos de acción.** Mochila → `push('/inventory')` (`:401`); atrás →
`context.pop()` **sin fallback** (`:377`); compras → diálogo de confirmación y
snack, sin navegar (`:51-106`).

**Jerarquía por pestaña.** `_selectedTab` filtra por `priceFor(currency) > 0`
(`:667-670`): la pestaña de fragmentos sólo muestra lo crafteable, así que un
objeto puede «desaparecer» al cambiar de moneda sin explicación.

---

### SCR-11 · Inventario

| Campo | Valor |
|---|---|
| Módulo | `economy` |
| Ruta | `/inventory` (`router.dart:96-99`) |
| Archivo | `inventory_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Ver los ítems de `player_inventory`, filtrar por
categoría y equipar/desequipar cosméticos; bloquear auras si no están
despertadas.

**Objetivo narrativo.** «Inventario del Cazador» (títulos, marcos, auras,
mascotas, emotes, consumibles).

**Elementos.** Cabecera con atrás y contador «N ITEMS» `:110-145`; chips de
filtro horizontales `:148-190`; lista de tarjetas con icono y color por tipo
(`title`, `frame`, `aura`, `pet`, `emote`, `consumable`) `:279-300`; estado
vacío con enlace a tienda `:205-239`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `context.pop()` | **sin fallback** | `:122` |
| Filtro | `setState(_filter)` | filtra la lista | `:157-158` |
| Equipar/desequipar | `_toggleEquip(code)` | `equip_cosmetic` / `equip_mana_item` / `desequip_mana_item` + `SystemSnack` | `:46, :76, :252-253` |
| Ir a la tienda | `push('/shop')` | sólo en vacío | `:225-226` |

**Estados.** Cargando `:194-197`; error (texto plano, sin reintento)
`:198-203` `[PARCIAL]`; vacío con CTA `:205-239`; datos `:240-257`.

**Acceso/salida.** Entrada: tienda y gremio. Salida: `pop()` sin fallback.

**Datos.** `player_inventory`, `equip_cosmetic`, `equip_mana_item`,
`desequip_mana_item`, `auraSystemProvider` (bloqueo de auras).

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(hunterStatus)` → `hunter_status_matrix_bg.jpg`
   (`inventory_screen.dart:104-105`).
2. Cabecera: atrás, «Inventario» 20, contador «N ITEMS» en mono cian
   (`:110-145`).
3. Chips de filtro horizontales derivados de los `item_type` presentes
   (`:148-190`).
4. Lista de tarjetas: icono por tipo, nombre del `item_code` capitalizado,
   tipo, chip de aura bloqueada / equipado y botón EQUIPAR/QUITAR (`:240-257`,
   `:313-454`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `player_inventory` (select `is_equipped` + tipo) (`economy_repository_impl.dart:364-375`), `auraSystemProvider` |
| **Escribe** | RPC `equip_cosmetic` (`:376`), `equip_mana_item` (`:987`), `desequip_mana_item` (`:1001`); si el ítem es `title`, además `users.equipped_title_code` por `updateUserProfile` (`inventory_screen.dart:61-72`) |

**Sin red.** `error` → texto plano `inventory_load_error`, **sin reintento**
(`:198-203`). El vacío sí tiene CTA a la tienda (`:205-239`).

**Destinos de acción.** Atrás → `pop()` sin fallback (`:122`); vacío → `push('/shop')`
(`:226`); equipar no navega (snack + invalidación).

> **Doble modelo de equipado:** el texto del ítem no se lee del catálogo sino del
> `item_code` (`:348`), así que el nombre visible es el identificador técnico en
> mayúsculas, no el nombre comercial del `cosmetic_catalog`.

---

### SCR-12 · Guardián de la Mazmorra

| Campo | Valor |
|---|---|
| Módulo | `economy` |
| Ruta | `/dungeon-guardian` (`router.dart:100-103`) |
| Archivo | `dungeon_guardian_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Ser la **puerta de maná**: se llega aquí cuando el maná
no alcanza ni para un turno (coste mínimo 12). Ofrece obtener maná, equipar un
elixir o volver.

**Objetivo narrativo.** Un guardián colosal sella la mazmorra; anillo de runas
giratorio y sello pulsante; contador de maná segmentado.

**Elementos.** Hero cinematográfico + sello rúnico pulsante (`_buildHero`);
grito del guardián en carmesí con glow `:174-190`; descripción `:192-200`;
`_buildManaPanel` con `SegmentedBar` `:462`; CTA «obtener maná»;
inventario equipable colapsable + `ManaItemInventory` `:492-532`;
`_buildAlternatives` con **cuenta atrás de recarga** (`guardian_refill_in/at`)
`:556-570`; CTA «volver al gremio» `:228-243`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás (`_RoundIconButton`) | `pop` **y** `go('/home')` | ⚠️ hace `pop` y luego navega **siempre**, aunque el pop haya tenido éxito | `:147-152` |
| **Obtener maná** | `push('/paywall')` | abre el paywall (no la tienda) | `:208-214` |
| Inventario | `_buildInventoryToggle` | despliega `ManaItemInventory` para equipar elixir | `:218-222` |
| Equipar elixir | `equip_mana_item` | consume/equipa | `:523`, `economy_repository_impl.dart:987` |
| Repasar vocabulario | `_openVocabularyReview` | SRS con hasta 10 palabras vencidas; si no hay → `SnackBar` crudo | `:601-603`, `:632-646` |
| Chat de bajo coste (8) | `push('/conversation')` | sólo si el maná alcanza el turno barato | `:612-626` |
| Volver al gremio | `pop` + `go('/home')` | mínimos 48×48 | `:228-242` |

**Estados.** La pantalla **no tiene estado de carga propio**: se alimenta de
`manaStateProvider` y de `manaBudgetProvider`. Se llega aquí por bloqueo
(`conversation_screen.dart:218-223`) cuando el maná disponible es menor que 12,
así que «sin maná» es la premisa de la pantalla, no un error. Vacío de repaso:
`SnackBar` crudo (`:638-642`) — uno de los 52 `SnackBar` de UX-10. Tiene
`reduceMotion` real (`:44-47`), uno de los 2 únicos gates del repo, y botones con
`minimumSize: Size(48, 44)` (alto 44 < 48, UX-03).

**Acceso/salida.** Entrada: `pushReplacement` desde conversación sin maná
(`conversation_screen.dart:218-223`). Salida: paywall, inventario, chat barato o
vuelta al home.

**Datos.** `manaStateProvider` (`get_mana_state`), `manaBudgetProvider`,
`equip_mana_item`, `dueVocabularyProvider` (SRS), `ManaItemInventory`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(dashboardGate)` + 2 orbes **pulsantes** carmesí y
   violeta (`dungeon_guardian_screen.dart:110-132`).
2. Cabecera con botón redondo de volver y título dorado (`:145-166`).
3. Héroe: imagen del guardián + anillo de runas giratorio + sello
   (`:170`, `:257+`).
4. Grito del guardián en carmesí 18 w900 con glow + descripción Inter 12.5
   (`:174-200`).
5. Panel de maná con `SegmentedBar` (`:204`, `:462`).
6. CTA «Obtener maná» (cian) (`:208-214`).
7. Inventario equipable colapsable + `ManaItemInventory` (`:218-222`).
8. Alternativas sin maná: recarga (cuenta atrás), repaso SRS, chat barato de 8
   (`:224`, `:556-630`).
9. «Volver al gremio» como `TextButton` (`:228-244`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | RPC `get_mana_state` (`economy_repository_impl.dart:809`), `mana_items`/`mana_potions`, `user_vocabulary` vencido (`dueVocabularyProvider`) |
| **Escribe** | `equip_mana_item` / `desequip_mana_item` (`economy_repository_impl.dart:987,1001`) al equipar un elixir |

**Sin red.** La pantalla **no tiene carga ni error propios**: depende de
`manaStateProvider`/`manaBudgetProvider`. Si el repaso no tiene palabras →
`SnackBar` crudo (`:638-642`); no hay superficie de error de maná.

**Destinos de acción.** «Obtener maná» → `push('/paywall')` (`:211`);
chat barato → `push('/conversation')` sólo si `available >= 8` (`:562,615`);
repaso → `SrsFlashcardModal` (`:644`); volver → `pop()` **y** `go('/home')`
siempre (`:147-152`, `:228-243`).

---

### SCR-13 · Resumen de sesión

| Campo | Valor |
|---|---|
| Módulo | `dashboard` |
| Ruta | `/summary` (`router.dart:82-85`) |
| Archivo | `session_summary_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** — buen manejo de estados / **`[PARCIAL]`** en tests |

**Objetivo funcional.** Explicar el resultado real de la sesión: recompensa
aplicada (XP/oro/fragmentos), «qué aprendiste» (palabras nuevas/repasadas,
correcciones, foco), metas cumplidas/total, duración y turnos; ofrecer repaso
SRS y siguiente lección.

**Objetivo narrativo.** «Botín de la incursión»: se abre el cofre y se anota lo
aprendido en el grimorio.

**Elementos.** Cabecera compacta con `_RoundIconButton` de vuelta + pill
«COMPLETADA» `:140-158`; chips de recompensa `:600-630`; bloque de aprendido;
botón «siguiente lección» condicional `:732-739`; `SrsFlashcardModal` desde
«repasar palabras» (deshabilitado si no hay palabras) `:683-705`; botón LISTO
`:708-721`; `SessionDropController` (drop sorpresa) `:123`;
`NotificationPermissionPrompt` `:127`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `goHome()` | invalida 6 providers y `go('/home')` | `:82-91` |
| Repasar palabras | `SrsFlashcardModal.show` | sólo si `hasWords` | `:691-693` |
| LISTO | `onDone` | vuelve al dashboard | `:711` |
| Siguiente lección | push a `/conversation` | sólo si hay lección siguiente | `:732+` |
| Reintentar recompensa | `sessionResultProvider.retry()` | 2 sitios (error y pendiente) | `:655, :670` |

**Estados.**

| Estado | Qué se ve | Evidencia |
|---|---|---|
| Recompensa cargando | spinner 14×14 + `summary_reward_loading` | `:631-649` |
| Error de recompensa | `_ErrorRow` + REINTENTAR | `:650-656` |
| Recompensa pendiente | texto + botón REINTENTAR | `:657-673` |
| Sin datos de aprendizaje | mensaje explícito, no ceros | DOC `:1-13`, `:393, :405` |
| Sin palabras | botón de repaso deshabilitado | `:691` |

**Acceso/salida.** Entrada: `push('/summary')` al salir de conversación.
Salida: `go('/home')`.

**Datos.** `close_session` (resultado), `get_session_learned_summary`,
`claim_session_drop`, `learning_evidence`, SRS.

> ⚠️ **Contraste:** el botón LISTO usa `runeViolet` + `onSurface`
> (`:713-714`) = **3.57:1**, por debajo de AA. Issue #241 se cerró arreglando
> `RunicButton`, pero este call site sigue con el par antiguo (§9.2 del doc 04).

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `Scaffold` del tema (sin imagen) + 2 orbes planos violeta/cian
   (`session_summary_screen.dart:93-120`).
2. `SessionDropController` y `NotificationPermissionPrompt` como capas
   (`:123-127`).
3. Cabecera: `_RoundIconButton` atrás + título + pill «COMPLETADA» violeta
   (`:140-158`).
4. Héroe: anillo compacto 76 de metas (`Metas 3/4` o «—») + «¡Buen trabajo!» +
   palabras dichas + etiquetas de turnos/metas (`:162-217`).
5. Cuadrícula 2×2 de métricas: duración, palabras, metas, turnos
   (`:221`, `:266-294`).
6. «Qué aprendiste» con estados de carga/error propios (`:225-235`, `:331-380`).
7. Lección de refuerzo `_RemedialCard` (`:239`).
8. Tarjeta de recompensas: 3 chips (XP, oro, fragmentos), estado de recompensa y
   botones «repasar palabras» / «LISTO» (`:243-250`, `:598-727`).
9. «Siguiente lección» a ancho completo en verde (condicional) (`:253`, `:732-781`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `sessionResultProvider`, `conversationStateProvider`, `activeConversationIdProvider`, `remedialLessonProvider`; RPC `get_session_learned_summary` (`conversation_providers.dart:2906`) y `get_session_learned_summary` por id uuid (`session_summary_screen.dart:798-807`) |
| **Escribe** | RPC `claim_session_drop` (`economy_repository_impl.dart:926`) vía `SessionDropController`; la recompensa real ya se escribió al cerrar (`close_session`) |

**Sin red.** Recompensa no confirmada → `_ErrorRow` con REINTENTAR (`:650-656`)
o texto «pendiente» con REINTENTAR (`:657-673`); «qué aprendiste» tiene su propio
error/retry (`:369-374`). Sin datos → mensaje explícito, no ceros (`:393-405`).

**Destinos de acción.** Atrás y LISTO → `goHome()` → `go('/home')` (`:82-91`);
«siguiente lección» → `push('/conversation?...')` (`:767-769`); refuerzo →
`push('/conversation?scenarioId…')` (`:905-907`); repaso → sheet local (`:692`).

---

### SCR-14 · Editar perfil

| Campo | Valor |
|---|---|
| Módulo | `dashboard` |
| Ruta | `/profile-edit` (`router.dart:87-90`) |
| Archivo | `profile_edit_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Cambiar avatar (galería/cámara, subida a Storage),
clase de cazador, idioma nativo y bio; guardar en `users` +
`user_language_profiles`.

**Objetivo narrativo.** «Ficha del cazador»: retrato, clase y camino.

**Elementos.** Cabecera con atrás `:267-287`; `RpgAvatar` grande con `onTap`
`:327-336`; selector de clase con tarjetas `:413-420`; dropdown de idioma
`:517-532`; bio; previsualización; botón guardar.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Avatar | `_showAvatarPicker` | bottom sheet galería/cámara | `:169-170` |
| Elegir imagen | `_pickImage` | sube a `avatars/{user}/{file}` y obtiene URL pública | `:97-132` |
| Clase | `setState(_selectedClass)` | actualiza radar y `users.character_class` | `:417`, `:580` |
| Idioma | `setState(_selectedLanguage)` | persiste | `:517-532` |
| Guardar | update + `SystemSnack` | vuelve | `:558-609` |

**Estados.** Cargando perfil `:631`; vacío/valores por defecto `:328`; error de
guardado con `SystemSnack` `:609`; **`SnackBar` crudo** en otro punto `:160`
`[PARCIAL]`.

**Acceso/salida.** Entrada: pestaña Config → tile. Salida: `pop` con fallback
`:201-220`.

**Datos.** `users`, `user_language_profiles`, Storage `avatars`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(hunterStatus)` → `hunter_status_matrix_bg.jpg`
   (`profile_edit_screen.dart:260-261`).
2. Cabecera: botón atrás 44×44 en `Material` + «LICENSE REGISTRY» 18 w900
   (`:267-305`).
3. Tarjeta-licencia: `RpgAvatar` 80 con botón de cámara superpuesto, chip de
   rango y nombre en mayúsculas (`:318-374`).
4. Selector de clase con tarjetas y radar (`:413-420`).
5. Dropdown de idioma nativo (`:517-532`).
6. Bio y previsualización.
7. Botón guardar al final del scroll.

| Datos | Fuente concreta |
|---|---|
| **Lee** | `userProfileProvider`, `userProgressProvider`, catálogo de clases |
| **Escribe** | `users` (`updateUserProfile`: clase, nombre, bio, avatar), `user_language_profiles` (idioma) (`:558-609`), Storage `avatars/{user}/{file}` (`:97-132`) |

**Sin red.** Guardado falla → `SystemSnack` accionable (`:609`); hay un `SnackBar`
crudo en otro punto (`:160`). El avatar remoto se pinta con
`Image.network` + fallback (`rpg_avatar.dart:103-114`): con red mala el marco
aparece antes que la imagen.

**Destinos de acción.** Atrás y guardar → `pop()` con fallback a `/home`
(`:275-281`, `:602-604`); cámara/galería → `showModalBottomSheet`
(`:170`), no navega.

---

### SCR-15 · Ajustes (pestaña Config, sin ruta)

| Campo | Valor |
|---|---|
| Módulo | `dashboard` |
| Ruta | **ninguna** — pestaña 3 del dashboard (`dashboard_screen.dart:378`) |
| Archivo | `settings_screen.dart` (1 612 líneas) |
| Etiqueta | **`[IMPLEMENTADO]`** funcional / **`[PARCIAL]`** en navegación y estados |

**Objetivo funcional.** Idioma objetivo y CEFR, idioma de dispositivo e
interfaz, parámetros del tutor (corrección, personalidad, estilo, meta diaria),
audio y comunicaciones (recordatorio, hápticos, sonidos, hold-to-talk), cuenta
(exportar datos, borrar cuenta, cerrar sesión).

**Objetivo narrativo.** «SYSTEM CONFIG» del HUD.

**Elementos.** 6 secciones con `_SectionHeader` `:147-208`; `ReminderSettingsCard`
`:177`; toggles sensoriales `:1272-1296`; tiles de cuenta `:184-200`; botón de
guardar `:209, :224`; herramientas de desarrollo **sólo en `kDebugMode`**
`:203-208`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Idioma objetivo / CEFR | tile → sheet | actualiza perfil | `:147-152` |
| Idioma de dispositivo | tile | detecta/permite | `:156` |
| Idioma de interfaz | tile | cambia `locale` global | `:158` |
| Corrección / personalidad / estilo / meta | tiles con sheet | `user_settings` | `:163-169` |
| Exportar datos | `export_my_data` → archivo/portapapeles | `SystemSnack` | `:470-482` |
| Borrar cuenta | diálogo de confirmación | `delete_my_account`; error accionable | `:489-530` |
| Cerrar sesión | diálogo | `signOut` | `:537-570` |
| Guardar | `_buildSaveButton` | persiste `user_settings` | `:224-300` |

**Estados.** Spinner de guardado `:300`; **sin estado de carga/error de
página** `[PARCIAL]` (UX-28); 5 `SystemSnack` + 6 `showModalBottomSheet` +
2 `showDialog`.

**Acceso/salida.** Entrada: dock (tab 3). Salida: ninguna propia (es una
pestaña). **No** se puede abrir desde notificación o widget.

**Datos.** `user_settings`, `user_language_profiles`, `export_my_data`,
`delete_my_account`, `reminder_*`, `sensory_feedback`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground()` **sin modo** → fondo de A1
   (`dungeon_forest_a1_bg.jpg`) + 2 orbes con blur
   (`settings_screen.dart:66-101`).
2. Cabecera: atrás + «SYSTEM CONFIG» 24 w900 (`:109-139`).
3. Sección 1 «TARGET LANGUAGE & CEFR LEVEL»: idioma objetivo y nivel
   (`:147-152`).
4. Sección 2 «LANGUAGE»: idioma de dispositivo e idioma de interfaz
   (`:154-159`).
5. Sección 3 «AI TUTOR PARAMETERS»: corrección, personalidad, estilo, meta
   diaria (`:161-170`).
6. Sección 4 «AUDIO & COMMUNICATIONS»: `ReminderSettingsCard` + toggles de
   hápticos, sonidos y hold-to-talk (`:172-180`, `:1268-1305`).
7. Sección 5 «ACCOUNT»: exportar, borrar, cerrar sesión (`:182-201`).
8. «DEVELOPER TOOLS» sólo en `kDebugMode` (`:203-208`).
9. Botón guardar **al final del scroll** + `SizedBox(100)` para el dock
   (`:209-210`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `user_settings`, `user_language_profiles`, `userProgressProvider`, `deviceLocaleProvider`, `userLanguageProvider` |
| **Escribe** | `user_settings` (`updateSetting` por clave), RPC `export_my_data` (`:470`), RPC `delete_my_account` (`:522`) |

**Sin red.** No hay carga ni error de página (`[PARCIAL]`, UX-28): los tiles
pintan valores ya cargados y el guardado falla con `SystemSnack`. Exportar
escribe en **portapapeles** (`:467-484`), no genera archivo.

**Destinos de acción.** Cerrar sesión → `go('/')` (`:570`); borrar cuenta →
`delete_my_account` + `signOut` + `go('/')` (`:520-525`); atrás → `pop()` con
fallback `/home` (`:115-121`). El resto son bottom sheets locales (`:576`,
`:796`, `:897`, `:972`, `:1047`, `:1414`).

---

### SCR-16 · Paywall

| Campo | Valor |
|---|---|
| Módulo | `subscription` |
| Ruta | `/paywall` (`router.dart:86`) |
| Archivo | `paywall_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** — UI propia + paywall nativo |

**Objetivo funcional.** Presentar el paywall **nativo de RevenueCat**, comparar
planes reales, restaurar compras y, si ya es Pro, abrir el Customer Center.

**Objetivo narrativo.** «Desbloquear el poder del reino» (corona y acento
violeta).

**Elementos.** Botón cerrar + Restaurar `:227-252`; corona 64×64 `:266-286`;
título/subtítulo según `isPremium` `:290-307`; `_PlanComparison` con
`subscription_plans` activos `:314`; bloque de entitlement con
`AsyncValue.when` `:317`; bloque de error con reintento `:407+`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Cerrar | `pop` o `go('/home')` | fallback correcto | `:233-239` |
| Restaurar | `_restorePurchases` | `restore()` + snack éxito/info/error; mínimo táctil 48 | `:77-120`, `:244` |
| Comprar | `_openPaywall` | `presentPaywall()`; 5 resultados mapeados | `:139-171` |
| Gestionar | `_openCustomerCenter` | Customer Center nativo | `:189` |

**Estados.** `_isPresenting` desactiva botones `:123, :242`; `_paywallError`
deja bloque de reintento persistente `:44, :169, :177`; entitlements
loading/error/data `:317-...`; premium vs free cambia copy.

**Acceso/salida.** Entrada: badge PRO del dashboard, ajustes, guardián.
Salida: cerrar con fallback.

**Datos.** RevenueCat SDK, `subscription_plans`, `revenueCatEntitlementsProvider`,
`sync-entitlement`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground()` **sin modo** → fondo de A1
   (`dungeon_forest_a1_bg.jpg`) (`paywall_screen.dart:213-214`).
2. Barra superior: cerrar (X 28) + «Restaurar» (`:219-255`).
3. Corona 64×64 violeta (`:266-286`).
4. Título (headline w900) y subtítulo según `isPremium` (`:290-307`).
5. `_PlanComparison` con planes activos de `subscription_plans` (`:314`).
6. Bloque de entitlement: spinner / error de texto / acciones
   (`:317-335`).
7. Bloque de error persistente de paywall + CTA principal violeta
   (`:356-419`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `subscription_plans` (`is_active`), entitlement de RevenueCat (`revenueCatEntitlementsProvider`), `subscription_plans.min_plan` para la comparativa |
| **Escribe** | ninguna tabla directamente; `Purchases.presentPaywall/restore` y reconciliación por `sync-entitlement` (`paywall_screen.dart:139-171`, `:77-120`) |

**Sin red.** Entitlement en `error` → texto `paywall_load_error` **sin**
reintento propio (`:326-333`); el bloque `_paywallError` sí persiste con el
mensaje y el CTA sigue activo (`:358-386`). La compra puede fallar sin que el
usuario sepa si pagó (no hay estado «pendiente»).

**Destinos de acción.** Cerrar → `pop()` o `go('/home')` (`:233-239`);
comprar/gestionar → paywall nativo / Customer Center, **sin navegación** al
terminar (`:151-158`, `:189`).

---

### SCR-17 · Resultado del jefe de mazmorra

| Campo | Valor |
|---|---|
| Módulo | `boss_exam` |
| Ruta | `/boss-result` (`router.dart:106-114`, `extra: BossExamOutcome`) |
| Archivo | `boss_exam_result_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** — pantalla read-only |

**Objetivo funcional.** Explicar el veredicto **que ya decidió el servidor**:
puntuación por dimensión (rúbrica), motivo, qué reforzar y cuándo reintentar.

**Objetivo narrativo.** Pantalla de victoria/derrota contra el jefe; icono de
trofeo/escudo y acento verde (victoria), cian (inicial) o violeta (derrota).

**Elementos.** Icono 48 + veredicto + línea de nivel `:65-97`; aviso de
resultado forzado `:98-108`; `_RubricCard`, `_ReasonCard`, `_FocusCard`
`:110-119`; botón «reforzar» (sólo derrota) `:121-133`; botón «ir al inicio»
`:134-144`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Reforzar | `go('/home')` | vuelve a practicar | `:122-130` |
| Ir al inicio | `go('/home')` | — | `:134-143` |
| Sin `extra` | muestra `boss_result_missing` + botón | entrada por enlace no rompe | `:30-51` |

**Estados.** Sin outcome (defensivo) `:30-51`; victoria / inicial / derrota
`:75-88`. Sin carga ni error: es estática.

**Acceso/salida.** Entrada: sólo desde conversación en modo promoción. Salida:
siempre a `/home` (no hay reintento directo: el cooldown es de 12 h).

**Datos.** Ninguno propio; todo viene del `BossExamOutcome` calculado por
`evaluate-placement`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `Scaffold(backgroundColor: voidBg)` sin imagen
   (`boss_exam_result_screen.dart:58-59`).
2. Icono 48 (trofeo / `auto_awesome` / escudo) + veredicto 20 w700 + línea de
   nivel (`:61-97`).
3. Aviso de resultado forzado (condicional) (`:98-108`).
4. `_RubricCard`, `_ReasonCard`, `_FocusCard` (`:110-119`).
5. «Reforzar» outlined **sólo en derrota** (`:121-133`).
6. «Ir al inicio» `FilledButton` verde (victoria) o dorado (`:134-144`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | nada: `state.extra` con `BossExamOutcome` (`router.dart:106-114`) |
| **Escribe** | nada (la promoción ya la escribió `evaluate-placement` con service role) |

**Sin red.** No aplica: pantalla estática. La única rama defensiva es
`outcome == null` → `boss_result_missing` + botón al inicio (`:26-51`).

**Destinos de acción.** Ambos botones → `go('/home')` (`:123`, `:135`); no hay
reintento directo porque el cooldown es de servidor (`boss_exam_card.dart:149-156`).

---

### SCR-18 · Mis errores

| Campo | Valor |
|---|---|
| Módulo | `corrections` |
| Ruta | `/my-errors` (`router.dart:117-120`) |
| Archivo | `my_errors_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Agrupar las correcciones guardadas por **tipo** y
**recurrencia**, que es la misma señal que consume el prompt del tutor y las
misiones de refuerzo.

**Objetivo narrativo.** «Grimorio de errores» del cazador.

**Elementos.** Cabecera + subtítulo `:35-73`; secciones por tipo con icono y
color `:149-160`; `_ErrorCard` por grupo; `RefreshIndicator` `:127-130`; vacío
`:92-94`; error con reintento `:82-89`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `context.pop()` | **sin fallback** | `:40` |
| Refrescar | `invalidate(myCorrectionsProvider)` | pull-to-refresh | `:98-99` |
| Tarjeta de error | `onRetry` | reintenta | `:88` |

**Estados.** Cargando `:76-81`; error con mensaje del servidor si es
`CorrectionsException` `:83-87`; vacío `:92-94`; datos `:95-101`.

**Acceso/salida.** Entrada: acceso rápido ERRORES del dashboard. Salida:
`pop()` sin `canPop` (UX-26).

**Datos.** `corrections`, vista `user_recurring_errors`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(hunterStatus)` → `hunter_status_matrix_bg.jpg`
   (`my_errors_screen.dart:29-30`).
2. Cabecera: atrás + «MY ERRORS» 18 w700 en `medievalText` (`:35-62`).
3. Subtítulo explicativo Inter 12 (`:63-73`).
4. Lista agrupada por **tipo** con cabecera de sección (icono + color + línea) y
   tarjetas `GlassCard` con el error tachado, la corrección en verde y la
   explicación (`:131-144`, `:149-249`).
5. Chip de recurrencia (dorado) o de repeticiones (`:251-286`).
6. Vacío con `spellcheck` violeta (`:288-321`); error con `cloud_off` + RETRY
   (`:323-379`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `corrections` y vista `user_recurring_errors` (`corrections` feature) |
| **Escribe** | nada (read-only) |

**Sin red.** `_ErrorState` con icono `cloud_off`, mensaje del servidor si es
`CorrectionsException` y botón RETRY (`:82-89`, `:323-379`). Es una de las 5
pantallas con patrón de error «bueno».

**Destinos de acción.** Atrás → `pop()` **sin fallback** (`:40`); refrescar →
invalida provider (`:98-99`); no hay más navegación (no enlaza a la lección de
origen del error).

> **Dato de producción:** `corrections` tenía **0 filas** en la verificación
> citada en `05-navigation-and-user-flows.md:465`; la pantalla existe pero su
> vacío es el estado normal hoy.

---

### SCR-19 · Informe semanal

| Campo | Valor |
|---|---|
| Módulo | `weekly_report` |
| Ruta | `/weekly-report` (`router.dart:123-126`) |
| Archivo | `weekly_report_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Mostrar la semana calculada **en servidor**: palabras
nuevas, errores corregidos, minutos, lecciones y nivel estimado. Navegar semanas
hacia atrás según el plan.

**Objetivo narrativo.** «Pergamino del gremio» con la crónica semanal.

**Elementos.** Cabecera con atrás `:41-68`; subtítulo `:69-79`;
`_WeekSelector` con anterior/siguiente y rango de fechas `:110-127`;
`_LockedWeekCard` si la semana no está incluida en el plan `:129-130`;
`_EmptyWeekCard` si no hay actividad `:131-132`; `_ReportBody` `:133-134`;
`_HistoryLimitNote` cuando se alcanza el tope de historial `:135-137`.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `context.pop()` | **sin fallback** | `:46` |
| Semana anterior | `setState(_weekOffset + 1)` | deshabilitado en `maxWeekOffset` | `:116-121` |
| Semana siguiente | `setState(_weekOffset - 1)` | deshabilitado en la actual | `:122-126` |
| Reintentar | `invalidate(weeklyReportProvider)` | en error y en `report == null` | `:93, :103` |

**Estados.** Cargando `:82-87`; error con mensaje localizado `:88-95`; `null`
tratado como error `:97-106`; vacío explícito (no ceros) `:131-132`; bloqueado
por plan `:129-130`.

**Acceso/salida.** Entrada: dashboard (card semanal). Salida: `pop()` sin
fallback.

**Datos.** `get_weekly_report(p_week_offset)` (`weekly_report_service.dart:26`),
`weekly_stats`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(hunterStatus)` → `hunter_status_matrix_bg.jpg`
   (`weekly_report_screen.dart:35-36`).
2. Cabecera: atrás + «WEEKLY REPORT» 18 w700 (`:41-68`).
3. Subtítulo Inter 12 (`:69-79`).
4. `ListView`: selector de semana (anterior/siguiente + rango de fechas)
   (`:110-127`).
5. Cuerpo condicional: `_LockedWeekCard` (plan) → `_EmptyWeekCard` (sin
   actividad) → `_ReportBody` (`:129-134`).
6. Aviso de límite de historial si se alcanza el tope (`:135-137`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | RPC `get_weekly_report(p_week_offset)` (`weekly_report_service.dart:26`); el servidor devuelve `locked`, `maxWeekOffset`, `historyWeeks` |
| **Escribe** | nada (read-only) |

**Sin red.** `_ErrorState` con RETRY (`:88-95`); `report == null` se trata como
error, no como vacío (`:97-106`). El vacío real es `_EmptyWeekCard`, que no pinta
ceros.

**Destinos de acción.** Atrás → `pop()` sin fallback (`:46`); flechas de semana →
`setState(_weekOffset ± 1)` (no navega) (`:117-126`); flecha anterior
deshabilitada en `maxWeekOffset` (`:116`), que es el **gate de plan** de esta
pantalla.

> **Nota:** es una de las 4 pantallas cuyo back no tiene fallback (junto a
> Tienda, Inventario y Mis errores), y se llega por `push` desde una tarjeta del
> dashboard: un deep link directo dejaría al usuario sin salida.

---

### SCR-20 · Comprensión auditiva

| Campo | Valor |
|---|---|
| Módulo | `listening` |
| Ruta | `/listening?exerciseId` (`router.dart:129-135`) |
| Archivo | `listening_quiz_screen.dart` |
| Etiqueta | **`[IMPLEMENTADO]`** |

**Objetivo funcional.** Reproducir un diálogo con **TTS local (coste de IA 0)** y
corregir un quiz de opción múltiple **en servidor**
(`submit_listening_attempt`), que además escribe `lesson_progress` y avanza la
misión `listening_items`.

**Objetivo narrativo.** «Escucha a los habitantes del reino» sin ver el texto.

**Elementos.** Cabecera con atrás + chip de nivel `:205-239`; título y contexto
del ejercicio `:289-307`; controles de audio; tarjetas de pregunta; botón de
enviar; pantalla de resultado.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `stop()` del audio y `pop`/`go('/home')` | **fallback correcto** | `:210-217` |
| Reproducir | `listeningAudioProvider` (TTS) | audio del diálogo | `listening_tts.dart` |
| Responder | selección por pregunta | estado de sesión | `listening_session.dart` |
| Enviar | `submit_listening_attempt` | corrección y progreso en servidor | `:128`, DOC `:1-9` |
| Reintentar carga | `_load` | — | `:253` |

**Estados.** Cargando `:242-248`; error con reintento `:249-254`; vacío («no hay
ejercicios para tu nivel») `:255-264`; calificado `graded` con resultado
`:280-285`.

**Acceso/salida.** Entrada: dashboard/roadmap (`exerciseId`). Salida: back con
fallback.

**Datos.** `listening_exercises`, `listening_attempts`,
`submit_listening_attempt`, `lesson_progress`, misión `listening_items`,
`flutter_tts`.

**Jerarquía visual (arriba→abajo, derivada de widgets).**
1. `CyberManhwaBackground(hunterStatus)` → `hunter_status_matrix_bg.jpg`
   (`listening_quiz_screen.dart:199-200`).
2. Cabecera: atrás + «LISTENING» 18 + chip de nivel (`:205-239`).
3. Cuerpo: título del ejercicio 20 + contexto Inter 12 (`:286-307`).
4. `GlassCard` reproductor: `RunicButton` PLAY/STOP/«LISTEN AGAIN» (`:311-329`)
   y opciones de transcripción.
5. Tarjetas de pregunta con opciones (dentro del mismo `ListView`, `:286+`).
6. Pantalla de resultado cuando `graded` (fuera del `ListView`).

| Datos | Fuente concreta |
|---|---|
| **Lee** | `listening_exercises` (por `exerciseId` slug), `listeningProgressProvider` |
| **Escribe** | RPC `submit_listening_attempt` (`listening_repository.dart:128`) → escribe `listening_attempts`, `lesson_progress` y avanza la misión `listening_items` en servidor |

**Sin red.** `_LoadErrorState` con RETRY (`:249-254`); el envío falla →
`pending.fail(message)` y la sesión permite reintentar con `_retry()`
(`:171-190`), que **borra las respuestas** (`keepAnswers: false`, `:184`). El
audio es TTS local: sin red se puede escuchar, pero no se puede calificar.

**Destinos de acción.** Atrás → `stop()` del audio + `pop()`/`go('/home')`
(`:210-217`); enviar no navega (resultado en la misma pantalla); al calificar
invalida `listeningProgressProvider` y las misiones (`:163-170`).

---

## 4. Patrones y huecos transversales

### 4.1 Cómo se comportan los estados (matriz real)

| Pantalla | Carga | Error | Vacío | Reintento explícito |
|---|---|---|---|---|
| SCR-01 Splash | barra | ❌ | n/a | ❌ |
| SCR-02 Welcome | overlay | `SnackBar` | n/a | ❌ |
| SCR-03 Onboarding | spinner botón | `SystemSnack` | n/a | implícito |
| SCR-04 Mini-conv | estado local | `SystemSnack` | n/a | ❌ |
| SCR-05 Conversación | `isProcessing` | tarjeta + `canRetry` | n/a | ✅ |
| SCR-06 Dashboard | valores base | pantalla completa | n/a | ✅ |
| SCR-07 Gremio | spinner | `.when` | ✅ | ❌ |
| SCR-08 Sala de voz | spinner | `.when` | ✅ | ❌ |
| SCR-09 Misiones | spinner | tarjeta tocable | ✅ | ✅ |
| SCR-10 Tienda | spinner | **falso vacío** ❌ | ✅ | ❌ |
| SCR-11 Inventario | spinner | texto plano | ✅ | ❌ |
| SCR-12 Guardián | — | — | vacío de repaso (SnackBar) | ✅ (CTA) |
| SCR-13 Resumen | spinner | `_ErrorRow` | ✅ | ✅ |
| SCR-14 Perfil | spinner | `SystemSnack` | n/a | ❌ |
| SCR-15 Ajustes | ❌ | ❌ | n/a | ❌ |
| SCR-16 Paywall | `_isPresenting` | bloque persistente | n/a | ✅ |
| SCR-17 Boss result | n/a | pantalla defensiva | n/a | ❌ |
| SCR-18 Mis errores | spinner | tarjeta | ✅ | ✅ |
| SCR-19 Informe | spinner | `_ErrorState` | ✅ | ✅ |
| SCR-20 Listening | spinner | `_LoadErrorState` | ✅ | ✅ |

**Conclusión medible:** **10 de 20** pantallas no ofrecen reintento explícito y
2 (SCR-10, SCR-15) confunden o no implementan error. El patrón "bueno" existe
(SCR-09, SCR-13, SCR-18, SCR-19, SCR-20) pero no está extraído a un componente
compartido: **no existe `HudState`** en `lib/` (se propone en el backlog; ver
§5.1 del documento 04).

### 4.2 Salida segura

| Patrón | Pantallas |
|---|---|
| `pop()` con `canPop`/fallback a `/home` | SCR-09, SCR-16, SCR-20, SCR-14, SCR-15 |
| `pop()` **sin** fallback (falla en deep link) | SCR-10, SCR-11, SCR-18, SCR-19 |
| Sin salida propia (pestaña) | SCR-15 |
| Salida centralizada e idempotente | SCR-05 (`_handleExit`) |

### 4.3 Pantallas "casi" existentes

| Necesidad | Estado real |
|---|---|
| Ajustes accesible por ruta | ❌ es pestaña (issue #260) |
| Ranking / liga | ⚠️ widget `LeagueLeaderboardWidget` dentro de la pestaña Estado, sin pantalla propia |
| Tienda de maná | ⚠️ el guardián enlaza a `/shop`, donde el maná se **muestra** pero no se vende (chip informativo) |
| Tutorial / ayuda | ❌ no hay pantalla; sólo `help_phrases_sheet` y `tts_settings_sheet` |
| Perfil público / social | ❌ existe `user_presence` y `guild_announcements`, sin UI |
| Historial de sesiones | ❌ sólo el resumen inmediato |

### 4.4 Cobertura de pruebas por pantalla

De `test/*`, las pantallas con test directo son: Welcome/Dashboard/
DungeonGuardian/ChatRooms/Shop (`overflow_test.dart`, `text_scale_test.dart`,
`shop_screen_test.dart`), Listening (`listening_quiz_screen_test.dart`) y Boss
Result (`boss_exam_result_test.dart`). **Conversación (2 362 líneas), Resumen
(1 325), Ajustes (1 612), Gremio y Sala de voz no tienen test de pantalla**
(issue #253/#254).

### 4.5 Estado «sin red» por pantalla (lo que el código distingue)

La app **no tiene un detector de conectividad**: «sin red» sólo se manifiesta
como error de un `FutureProvider`. Esta es la traducción real, pantalla a
pantalla:

| Pantalla | «Sin red» se ve como | ¿Se distingue de «error»? |
|---|---|---|
| SCR-01 Splash | nada: `catch (_)` y navega (`splash_screen.dart:61`) | no aplica |
| SCR-02 Welcome | `SnackBar` genérico (`:302-304`) | ❌ |
| SCR-03 Onboarding | `SystemSnack` de guardado (`:380-384`) | ❌ |
| SCR-04 Mini-conv. | panel «MIRA IS NOT AVAILABLE» (`:428-463`) | ❌ (mismo panel para error de modelo) |
| SCR-05 Conversación | snack + `canRetry` (`conversation_providers.dart:1867-1912`) | parcial (cuota ≠ red) |
| SCR-06 Dashboard | **sin caché**: pantalla `cloud_off`; **con caché**: banner ámbar (`dashboard_screen.dart:195-231`, `:270-298`) | ✅ **única** |
| SCR-07 Gremio | texto rojo sin reintento (`chat_rooms_screen.dart:908-916`) | ❌ |
| SCR-08 Sala de voz | texto rojo `room_error` (`voice_room_screen.dart:1114`) | ❌ |
| SCR-09 Misiones | tarjeta con `wifi_off` + reintento (`missions_screen.dart:193-235`) | ❌ (icono de red, texto de error) |
| SCR-10 Tienda | «AÚN NO HAY OBJETOS» (`shop_screen.dart:657-665`) | ❌ **confunde con vacío** |
| SCR-11 Inventario | texto plano sin reintento (`inventory_screen.dart:198-203`) | ❌ |
| SCR-12 Guardián | no aplica: datos de maná ya cargados | — |
| SCR-13 Resumen | `_ErrorRow` de recompensa (`session_summary_screen.dart:650-656`) | ❌ |
| SCR-14 Perfil | `SystemSnack` al guardar (`profile_edit_screen.dart:609`) | ❌ |
| SCR-15 Ajustes | no hay estado de página | ❌ |
| SCR-16 Paywall | texto `paywall_load_error` (`paywall_screen.dart:326-333`) | ❌ |
| SCR-17 Boss result | no aplica | — |
| SCR-18 Mis errores | `cloud_off` + RETRY (`my_errors_screen.dart:323-379`) | ❌ (icono de red) |
| SCR-19 Informe | `_ErrorState` + RETRY (`weekly_report_screen.dart:88-95`) | ❌ |
| SCR-20 Listening | `_LoadErrorState` + RETRY (`listening_quiz_screen.dart:249-254`) | ❌ |

**Conclusión:** sólo el **Dashboard** diferencia «sin red con caché» de «sin red
sin caché». En el resto, «sin red» y «error de servidor» comparten superficie; en
Tienda comparten incluso el **vacío**. Y hay 3 pantallas donde el icono de red
(`wifi_off`/`cloud_off`) se usa como icono genérico de error (Misiones, Mis
errores, Dashboard), lo que sugiere al usuario un problema de conexión incluso
cuando el fallo es del servidor.
