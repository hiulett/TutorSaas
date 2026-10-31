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
SCR-13, SCR-07) suman **6 606 líneas**, el 45 % del total de pantallas.

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

**Elementos.** Hero cinematográfico + sello rúnico pulsante; anillo de runas +
partículas (respetan reduce-motion, DOC `:1-9`); `GlassCard` ×3; contador con
`SegmentedBar` `:462`; 3 CTAs.

**Componentes interactivos.**

| Control | Acción | Comportamiento | Evidencia |
|---|---|---|---|
| Atrás | `pop` | — | `:149-150` |
| Obtener maná | `push('/shop')` | — | `:211` |
| Equipar elixir | `equip_mana_item` | consume/equipa | `economy_repository_impl.dart:987` |
| Volver al gremio | `pop` / `go` | — | `:231` |

**Estados.** Maná insuficiente es **el estado normal** de la pantalla `:638`;
guarda `reduceMotion` real (`:44-47`) — uno de los 2 únicos gates del repo.

**Acceso/salida.** Entrada: `pushReplacement` desde conversación sin maná.
Salida: tienda o vuelta.

**Datos.** `manaStateProvider` (`get_mana_state`), `equip_mana_item`.

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
> `RunicButton`, pero este call site sigue con el par antiguo (§13 del doc 04).

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
| SCR-12 Guardián | — | — | es el estado | ✅ (CTA) |
| SCR-13 Resumen | spinner | `_ErrorRow` | ✅ | ✅ |
| SCR-14 Perfil | spinner | `SystemSnack` | n/a | ❌ |
| SCR-15 Ajustes | ❌ | ❌ | n/a | ❌ |
| SCR-16 Paywall | `_isPresenting` | bloque persistente | n/a | ✅ |
| SCR-17 Boss result | n/a | pantalla defensiva | n/a | ❌ |
| SCR-18 Mis errores | spinner | tarjeta | ✅ | ✅ |
| SCR-19 Informe | spinner | `_ErrorState` | ✅ | ✅ |
| SCR-20 Listening | spinner | `_LoadErrorState` | ✅ | ✅ |

**Conclusión medible:** 6 de 20 pantallas no ofrecen reintento explícito y 2
(SCR-10, SCR-15) confunden o no implementan error. El patrón "bueno" existe
(SCR-09, SCR-13, SCR-18, SCR-19, SCR-20) pero no está extraído a un componente
compartido: **no existe `HudState`** en `lib/` (se propone en el backlog, `04`
§5 del doc 04).

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
