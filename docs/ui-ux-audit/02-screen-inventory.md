# 02 — Inventario de pantallas y navegación

**Método:** lectura de `lib/app/router.dart:33-140`, de cada `*_screen.dart` y de
`test/`. Ninguna pantalla se evaluó "mirando" una captura (ver límite en `01` §0).

- **20 archivos `*_screen.dart`**, **20 rutas** en `appRoutes`.
- 19 pantallas tienen ruta propia; **`ConversationScreen` se usa en 2 rutas**
  (`/conversation`, `/oracle-test`).
- **`SettingsScreen` no tiene ruta**: solo existe como pestaña 3 del dashboard
  (`dashboard_screen.dart:378`). No se puede enlazar ni volver a ella con URL.

---

## 1. Inventario

Leyenda de estados: ✅ implementado · ➖ no implementado · ⚠️ implementado con
defecto. "Visual" = estado de la verificación visual.

| # | Pantalla | Archivo (líneas) | Ruta | Propósito | Entrada → Salida | Carga | Vacío | Error | Test de widget | Visual |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | **Splash** | `app/splash_screen.dart` (264) | `/splash` | Warm-up de Supabase + decisión de destino | `initialLocation` → `context.go('/')` automático (`splash_screen.dart:80-120`, tope 3 s `:31`) | ✅ barra segmentada animada | ➖ | ➖ (timeout silencioso) | ➖ | verificado por código |
| 2 | **Welcome** | `onboarding/.../welcome_screen.dart` (696) | `/` | Login/registro Google + email, reset de contraseña | Splash/router → `/onboarding` (`:296,684`) o destino del `NavigationDecisionEngine` (`:73`) | ✅ spinner en botón (`:198,474`) | ➖ | ⚠️ solo `SnackBar` crudo (`:303,336,596,613`) | ✅ `overflow_test`, `text_scale_test` | verificado por test |
| 3 | **Onboarding** | `onboarding/.../onboarding_screen.dart` (1 219) | `/onboarding` | Wizard de 4 pasos (idioma nativo, idioma, nivel, personaje) | Welcome → `/mini-conversation` o `/home` (`:396`) | ✅ (`:557`) | ➖ | ⚠️ validación por `SnackBar` (`:108-118`) | ➖ | **no verificable** (requiere revisión visual humana) |
| 4 | **Mini conversación** | `onboarding/.../mini_conversation_screen.dart` (479) | `/mini-conversation` | Prueba de valor de 60 s con Mira | Onboarding → `/home` (`:157`) | ➖ | ➖ | ✅ *fallback* "continuar al reino" (no bloquea) | ✅ `mini_conversation_test` | verificado por test |
| 5 | **Dashboard** | `dashboard/.../dashboard_screen.dart` (735) | `/home` | Hub con 4 pestañas: Mazmorras, Guild, Estado, Config | Router/redirect → pushes a `/shop`, `/oracle-test`, `/my-errors` (`:500,507,528`) | ➖ (solo `progressAsync`) | ➖ | ✅ pantalla offline (`:195-231`) | ✅ `overflow_test`, `text_scale_test` | verificado por test |
| 6 | **Conversación** | `conversation/.../conversation_screen.dart` (2 281) | `/conversation`, `/oracle-test` | Lección hablada (record → STT → LLM → TTS) | Dashboard/path → `/summary`, `/dungeon-guardian` (`:220`), home (`:1218`) | ✅ mic/spinner (`:2113`) | ➖ | ✅ varios reintentos (7 `retry/error` en archivo) | ❌ **ninguno** | **no verificable** (requiere revisión visual humana) |
| 7 | **Resumen de sesión** | `dashboard/.../session_summary_screen.dart` (1 238) | `/summary` | Recompensas reales (`apply_session_rewards`), palabras aprendidas, correcciones | Conversación → `/home` (`:90`); push a siguiente lección (`:767`) y a refuerzo (`:905`) | ✅ (`:358,639`) | ✅ palabras/correcciones (`:393,405`) | ✅ (`:370,653`) | ➖ | **no verificable** (requiere revisión visual humana) |
| 8 | **Paywall** | `subscription/.../paywall_screen.dart` (638) | `/paywall` | Planes RevenueCat (NOBLE/REALEZA) | Dashboard badge → `pop()` o `/home` si no hay pila (`:233-239`) | ✅ (`:321`) | ➖ | ✅ (`:329`) | ✅ `paywall_plans_test` | verificado por test |
| 9 | **Editar perfil** | `dashboard/.../profile_edit_screen.dart` (616) | `/profile-edit` | Nombre, avatar, idiomas | Pestaña Estado (`progress_tab_view.dart:137`) → `pop()`/`/home` (`:275-281`) | ✅ guardando (`:631`) | ➖ | ⚠️ validación inline (`:478`) + `SnackBar` | ➖ | **no verificable** (requiere revisión visual humana) |
| 10 | **Guild / Chat rooms** | `chat_rooms/.../chat_rooms_screen.dart` (1 228) | `/chat-rooms` (y pestaña 1) | Salón del gremio, salas, anuncios, trofeos | Dock pestaña 1 / push → `/voice-room?roomId=` | ✅ (`:905,1187`) | ✅ (`:742`) | ⚠️ `SnackBar` crudo (`:446`) | ✅ `overflow_test` (312 px) | verificado por test |
| 11 | **Sala de voz** | `chat_rooms/.../voice_room_screen.dart` (1 185) | `/voice-room?roomId` | LiveKit, asientos, chat | Guild → `pop()`/`/chat-rooms` (`:189-192`) | ✅ (`:430,1113`) | ✅ mensajes (`:393`) | ✅ (`:1114`) | ➖ | **no verificable** (requiere revisión visual humana) |
| 12 | **Tienda** | `economy/.../shop_screen.dart` (1 069) | `/shop` | Cosmético/monedas: oro, gemas, fragmentos | Dashboard → `pop()` (`:377`) | ✅ (`:660`) | ✅ (`:665,693,1060`) | ⚠️ **error se pinta como vacío** (no hay `hasError`; `:657-665`) | ✅ `shop_screen_test` (incluye 312 dp) | verificado por test |
| 13 | **Inventario** | `economy/.../inventory_screen.dart` (435) | `/inventory` | Equipar cosméticos | (push externo) → `pop()` (`:122`) | ✅ (`:196`) | ✅ (`:205-217`) | ✅ (`:198-201`) | ➖ | **no verificable** (requiere revisión visual humana) |
| 14 | **Guardián de mazmorra** | `economy/.../dungeon_guardian_screen.dart` (719) | `/dungeon-guardian` | Bloqueo por maná + compra | Conversación al agotar maná (`conversation_screen.dart:220`) → atrás (`:740-761`) | ➖ | ✅ (`:638`) | ➖ | ✅ `overflow_test`, `text_scale_test` (1.5× y 2×) | verificado por test |
| 15 | **Resultado de jefe** | `boss_exam/.../boss_exam_result_screen.dart` (430) | `/boss-result` | Rúbrica, motivo, reintento | Conversación (promotion) con `extra: BossExamOutcome` (`router.dart:106-114`) | ➖ | ✅ sin datos (`:152`) | ➖ | ✅ `boss_exam_result_test` (5 casos) | verificado por test |
| 16 | **Mis errores** | `corrections/.../my_errors_screen.dart` (398) | `/my-errors` | Correcciones agrupadas por tipo/recurrencia | Dashboard (`:528`) → `pop()` **sin fallback** (`:40`) | ✅ (`:77`) | ✅ (`:92`) | ✅ (`:82-87`) | ➖ (solo lógica) | **no verificable** (requiere revisión visual humana) |
| 17 | **Informe semanal** | `weekly_report/.../weekly_report_screen.dart` (636) | `/weekly-report` | Progreso semanal calculado en servidor | (push desde resumen/dashboard) → `pop()` **sin fallback** (`:46`) | ✅ (`:83`) | ✅ (`:132,228`) | ✅ (`:88,98`) | ➖ (solo lógica) | **no verificable** (requiere revisión visual humana) |
| 18 | **Listening quiz** | `listening/.../listening_quiz_screen.dart` (857) | `/listening?exerciseId` | Comprensión auditiva por TTS | Dashboard/path → `pop()` | ✅ (`:244`) | ✅ (`:258`) | ✅ (`:250`, `_LoadErrorState :846`) | ✅ `listening_quiz_screen_test` | verificado por test |
| 19 | **Misiones** | `missions/.../missions_screen.dart` (228) | `/missions` | Diarias / semanales con pestañas | Push externo → `pop()`/`/home` (`:94-101`) | ✅ (`:188`) | ✅ (`:154`) | ✅ (`:214`) | ➖ | **no verificable** (requiere revisión visual humana) |
| 20 | **Ajustes** | `dashboard/.../settings_screen.dart` (1 557) | **sin ruta** (tab 3) | Cuenta, idioma, TTS, notificaciones, zona de peligro | Dock pestaña 3 (`dashboard_screen.dart:378`) | ⚠️ solo spinner de guardado (`:300`) | ➖ | ⚠️ `SnackBar` crudo (`:281,530`) | ➖ | **no verificable** (requiere revisión visual humana) |

**Resumen de verificación visual:** 9 pantallas tienen un test de widget que las
monta, 1 se verificó solo por código (Splash, sin test) y **10 quedan no
verificables** sin ojos humanos: Onboarding, Conversación, Resumen de sesión,
Editar perfil, Sala de voz, Inventario, Mis errores, Informe semanal, Misiones y
Ajustes. 9 + 1 + 10 = 20.

---

## 2. Mapa de navegación real

```
/splash ──(auto)──► /  ──(login)──► /onboarding ──► /mini-conversation ──► /home
   │                                   │
   └──(sesión)──────────────────────► /home ◄─────────────────────────────┐
                                        │                                  │
   ┌────────────────────────────────────┼──────────────────────────────┐  │
   │ dock 0        dock 1      dock 2   │ dock 3                       │  │
   │ Mazmorras     Guild       Estado    │ Config (SettingsScreen)      │  │
   │   │             │            │      │                              │  │
   │   │             └──► /voice-room?roomId                          │  │
   │   ├──► /shop        ├──► /conversation ──► /summary ──────────────┘  │
   │   ├──► /oracle-test ├──► /oracle-test?mode=promotion ──► /boss-result │
   │   ├──► /my-errors   ├──► /listening?exerciseId                        │
   │   └──► /inventory   ├──► /weekly-report                              │
   │                     └──► /missions                                   │
   └──(maná=0)──► /dungeon-guardian
```

Fuentes: `router.dart:33-140` y el grep de `context.go|context.push` (18 rutas
distintas referenciadas desde la UI). `/dungeon-guardian` solo se alcanza desde
la conversación (`conversation_screen.dart:220`); `paywall` desde el badge PRO
del dashboard y desde ajustes.

### 2.1 Hallazgos de navegación (evidencia)

| ID | Hallazgo | Evidencia |
|---|---|---|
| N-01 | `SettingsScreen` no es ruta: deep-link imposible, y "atrás" no aplica | `router.dart:33-140` (no aparece) |
| N-02 | 4 pantallas con `context.pop()` sin `canPop()` → callejón sin salida al entrar por deep-link | `my_errors_screen.dart:40`, `weekly_report_screen.dart:46`, `inventory_screen.dart:122`, `shop_screen.dart:377` |
| N-03 | Dos glifos y 4 tamaños de "volver" | `missions_screen.dart:94-107` (IconButton+tooltip) vs `profile_edit_screen.dart:282-285` (44 px, sin label) vs `dungeon_guardian_screen.dart:752-760` (40 px) vs `session_summary_screen.dart:142-144` (40 px) |
| N-04 | El botón de volver de perfil/guardián/resumen no tiene `semanticLabel` ni `tooltip` | mismos archivos |
| N-05 | El dashboard no permite refrescar con gesto; solo invalida al reintentar el error | `RefreshIndicator` = 0 en `dashboard_screen.dart` |
| N-06 | La pestaña del dashboard persiste al salir y volver (provider de módulo) | `dashboard_screen.dart:31,172` |

---

## 3. Capturas

Solo hay un archivo, `screenshots/01-arranque.png`, y **no es un PNG decodificable**
(BOM UTF-16LE; ver `01` §5). Por tanto **ninguna pantalla está verificada
visualmente**. Instrucciones y nombres propuestos en `screenshots/README.md`.
