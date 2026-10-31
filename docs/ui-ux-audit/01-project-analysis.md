# 01 — Análisis del proyecto (UX/UI)

**Fecha:** 30-oct-2026 · **Base:** `origin/master` @ `f9cffb2` · **Rama:** `docs/ui-ux-audit`
**Worktree:** `C:\Users\GbitCorp\.local\share\opencode\worktree\6708f0\p14-ai-usage`
**Alcance:** auditoría de **solo lectura**. No se modificó `lib/`, `test/` ni configuración.

---

## 0. Límite de esta auditoría (léelo antes que nada)

El móvil estuvo conectado y la app corrió, pero **en este entorno el agente no puede
ver imágenes**: no hay preview ni visión disponible. Consecuencias que afectan a
todos los documentos:

| Afirmación | Cómo se obtuvo | Estado |
|---|---|---|
| Contraste, tamaños, tokens, rutas, estados | Lectura de código + cálculo WCAG | **Verificado por código** |
| Overflow a 312 px y a `textScaler` 1.5×/2× | Ejecución de `flutter test` (725 casos) | **Verificado por test** |
| Jerarquía visual, ritmo, "se ve bien", glow, legibilidad real en pantalla | Requiere ojos humanos | **No verificable** |
| Capturas por pantalla | Solo existe `screenshots/01-arranque.png` y **está corrupta** (ver §5) | **No verificable** |

Cada pantalla del inventario (`02-screen-inventory.md`) lleva marca
`verificado por código` o `no verificable (requiere revisión visual humana)`.
**No se describe ninguna imagen que el agente no haya podido abrir.**

---

## 1. Estado medido del repositorio

| Métrica | Valor | Evidencia |
|---|---|---|
| Pantallas (`*_screen.dart`) | **20** | `lib/**/screens/*_screen.dart` + `lib/app/splash_screen.dart` |
| Rutas registradas | **20** | `lib/app/router.dart:33-140` (`appRoutes`) |
| Features | **16** | `lib/features/` |
| Archivos de test | **87** | `test/**/*_test.dart` |
| Casos de test | **725, todos en verde** | `flutter test` (30-oct-2026) |
| `flutter analyze` | **0 errores, 0 warnings, 126 infos** | medido en este worktree |
| Líneas UI más grandes | `conversation_screen.dart` 2 281 · `settings_screen.dart` 1 557 · `conversation_providers.dart` 2 712 | conteo de líneas |

> **Corrección a los datos de partida:** el encargo citaba 2 362 / 1 611 / 2 956
> líneas y 461 `withValues`. Medido ahora: **2 281 / 1 557 / 2 712** y **467**.
> La diferencia es deriva normal del árbol; manda el código (regla de `AGENTS.md`).

### 1.1 Tokens: lo que dice el sistema vs lo que hace el código

| Token | Definición | Usos reales en `lib/` | Lectura |
|---|---|---|---|
| `AppSpacing` | `app_spacing.dart:12-19` (4·8·12·16·20·24·32·48) | **3** (+1 autodefinición) — `app_theme.dart:96,111,125` | El token existe y **casi no se usa** |
| `EdgeInsets.*` literales | — | **419 coincidencias / 366 objetos** | Ritmo escrito a mano |
| `AppRadius` | `app_radius.dart:9-18` (4/8/12/999) | **68** | Adoptado a medias |
| `AppElevation` | `app_elevation.dart:8-23` | **0** usos (solo la definición) | Token muerto |
| `AppTypography` | `app_typography.dart` (8 estilos) | **114** | Convivie con llamadas directas |
| `GoogleFonts.*` directas | — | **384** (190 mono · 125 grotesk · 68 inter) | La tipografía se salta el token 3,4× más que usarlo |
| `AppMotion` | `app_motion.dart` (duraciones/curvas + reduce-motion) | **17** | Animaciones a mano en 23 `AnimationController` |

### 1.2 Espaciado: el "grid de 4" no se cumple

De los 366 objetos `EdgeInsets` literales, 631 valores numéricos:

- **442 (70 %)** caen en múltiplos de 4.
- **189 (30 %)** están **fuera de rejilla**: `2, 3, 5, 6, 7, 10, 11, 14, 18, 26, 30, 58`.
- Valores más usados: `16` (125), `8` (83), `12` (82), `20` (58), `10` (49), `14` (43), `24` (37), `6` (36).

Esto no es "falta de tokens" en abstracto: la app ya tiene una escala de facto
`6/10/14` que **no está** en `AppSpacing`. Cualquier design system que ignore esos
valores va a requerir 189 retoques manuales (ver `04` y `06`, ID `UX-02`).

### 1.3 Tipografía: 31 tamaños distintos y 243 textos < 12 px

Histograma real de `fontSize` en `lib/` (603 declaraciones):

| Tamaño | Usos | | Tamaño | Usos |
|---|---|---|---|---|
| 7 px | 2 | | 14 px | 23 |
| 8 px | 17 | | 15 px | 28 |
| 9 px | 48 | | 16 px | 32 |
| 10 px | 85 | | 18 px | 26 |
| 11 px | 92 | | 20 px | 9 |
| 12 px | 103 | | 22–48 px | 16 |
| 13 px | 51 | | 11.5 / 12.5 | 2 |

- **243 usos por debajo de 12 px** (40 % de las declaraciones), con mínimo de
  **7 px** en `chat_rooms_screen.dart:1063` y `voice_room_screen.dart:914`.
- `app_theme.dart` define **11 de los 15** estilos de `TextTheme`.
  `headlineSmall`, `titleSmall`, `bodySmall`, `labelSmall` quedan en **Roboto**
  (no empaquetada). **Matiz verificado:** esos 4 estilos tienen **0 usos** en el
  código (`textTheme.*` aparece solo 4 veces: `headlineMedium`, `titleMedium` ×3).
  Es **deuda latente**, no un defecto visible hoy. Está fijada a propósito en
  `test/golden/design_tokens_test.dart:238-261`.

### 1.4 Color: los literales viven mayormente en el archivo de tokens

95 `Color(0x…)` en `lib/`: **78** están en `app_colors.dart` (correcto), **17**
fuera de él:

| Archivo | Literales | Ejemplo |
|---|---|---|
| `conversation_screen.dart` | 10 | `Color(0xFF0F172A)` (×4), `0xFFFFD700`, `0xFFF1C40F` (×2), `0xFFFF00FF` (×2), `0xFF1E60FF` |
| `hunter_class_data.dart` | 3 | colores de clase |
| `app_elevation.dart` | 3 | sombras (correcto) |
| `conversation_mic_button.dart` | 1 | `0xFF0F172A` |

Además **72 usos de `Colors.white*`/`black*`**, de los cuales **39 están en
`conversation_screen.dart`** y 22 en sus sheets (`help_phrases_sheet.dart:10`,
`tts_settings_sheet.dart:10`). `test/golden/design_tokens_test.dart:67-97` solo
vigila `Color(0x…)`, **no** `Colors.*` — por eso pasan.

### 1.5 Estados y navegación (resumen; detalle en `02` y `03`)

- 20 rutas, pero **`SettingsScreen` no tiene ruta**: solo existe como pestaña 3
  del dashboard (`dashboard_screen.dart:378`). No es enlazable.
- 4 pantallas hacen `context.pop()` **sin** `canPop()` de respaldo
  (`my_errors_screen.dart:40`, `weekly_report_screen.dart:46`,
  `inventory_screen.dart:122`, `shop_screen.dart:377`): en deep-link quedan en
  un callejón sin salida.
- Métodos de volver: dos glifos (`arrow_back_rounded` vs
  `arrow_back_ios_new_rounded`) y cuatro tamaños de caja (24/40/44 px y el
  `IconButton` por defecto); solo `missions_screen.dart:94-107` añade
  `tooltip`.

---

## 2. Arquitectura de UI observada

```
MaterialApp.router (app.dart:63-75)
  └─ AppTheme.darkTheme (app_theme.dart:8-218)  ← solo dark, ThemeMode.dark
       ├─ ColorScheme.dark (8 roles definidos de ~30)
       ├─ TextTheme (11/15 estilos: SpaceGrotesk / Inter / JetBrainsMono)
       ├─ Elevated/Outlined/TextButton (radio 4, JetBrainsMono 14/w700)
       ├─ InputDecoration (fill surfaceContainerLow, borde 1.5, foco 2.0)
       └─ SnackBar / Chip / Dialog / BottomNavigationBar
  └─ GoRouter (router.dart:146-175) — redirect por NavigationDecisionEngine
       └─ 20 GoRoute (router.dart:33-140)
  └─ 20 pantallas → 100 GlassCard → 14 widgets en core/widgets
```

- **Sin `useMaterial3:` explícito**; con Flutter 3.41 el valor por defecto es
  M3, así que conviven componentes M3 (`NavigationBar` no usado) con HUD propio.
- **Fuentes:** `GoogleFonts` con `allowRuntimeFetching = false`
  (`main.dart:24`) y 23 `.ttf` en `assets/google_fonts/` declarados como asset
  (`pubspec.yaml:63-64`), no como `fonts:`. Funciona por la convención de
  `google_fonts`; lo blinda `test/bundled_fonts_test.dart`.
- **i18n:** 1 292 claves idénticas en `en/es/pt` (verificado: 0 faltantes).
  Pero hay **369** construcciones `l10n?.clave ?? 'TEXTO'` con el fallback en
  español hardcodeado, y 8 `Text('…')` directos (`profile_edit_screen.dart:523-527`
  lista de idiomas, `conversation_screen.dart:1733,1745`).

---

## 3. Cobertura de evidencia (qué se puede afirmar y con qué)

| Tipo de afirmación | Fuente permitida | Test que la respalda |
|---|---|---|
| Contraste | fórmula WCAG sobre `app_colors.dart` | — (cálculo reproducible) |
| Overflow horizontal | `test/overflow_test.dart` | 5 pantallas/widgets a 312 px |
| Escalado de texto | `test/text_scale_test.dart` | 3 pantallas a 1.5× y 2 pantallas a 2× |
| Contrato de tokens | `test/golden/design_tokens_test.dart` | color/radio/familia |
| Regresión de `SegmentedBar` | `test/golden/goldens/segmented_bar.png` | 1 pixel-golden |
| Estados de pantalla | código (`when`, `isEmpty`, `_ErrorState`) | parcial |

**Pantallas con al menos un widget test que las monte** (9 de 20):
Dashboard, Welcome, ChatRooms, DungeonGuardian, Shop, ListeningQuiz,
BossExamResult, MiniConversation, Paywall.
**Sin test de widget**: Splash, Onboarding, Conversation, SessionSummary,
ProfileEdit, VoiceRoom, Inventory, MyErrors*, Missions, Settings, WeeklyReport*
(*solo lógica/modelos).

---

## 4. Riesgos estructurales (no visuales) que condicionan la UI

1. **God files**: `conversation_screen.dart` 2 281 líneas, `settings_screen.dart`
   1 557, `session_summary_screen.dart` 1 238, `chat_rooms_screen.dart` 1 228.
   Cada uno mezcla layout, estado y reglas; cualquier rediseño toca un archivo
   que no cabe en una revisión.
2. **La pantalla más crítica no tiene test de widget.** `ConversationScreen`
   (pipeline de voz, 2 281 líneas) no se instancia en ningún test
   (`grep 'screens/.*_screen.dart' test/` no la lista). El pipeline de voz está
   cubierto por tests de notifier/repositorio, la **UI** no.
3. **Tokens sin enforcement**: `design_tokens_test` vigila color/radio/fuente,
   pero **no** espaciado, ni `Colors.*`, ni tamaños táctiles, ni `Semantics`.
4. **Superficies de sistema mezcladas**: 48 `SystemSnack.show` conviven con 4
   `SnackBar` crudos (`welcome_screen.dart` ×30 en total, `settings_screen.dart`
   ×4, `profile_edit_screen.dart` ×6, `mission_card.dart` ×6).

---

## 5. Capturas: estado real

`docs/ui-ux-audit/screenshots/01-arranque.png` existe (58 222 bytes) pero **no es
un PNG válido**: empieza con BOM UTF-16LE `FF FE` y el texto `PNG` en UTF-16,
en lugar de la firma `89 50 4E 47`. Se generó con una redirección de PowerShell
(`adb exec-out screencap -p > archivo.png`), que en PowerShell **no escribe
bytes**: re-codifica la salida como texto UTF-16 y además traduce `0x0A/0x0D`.
La recuperación byte a byte no es posible (la decodificación de texto ya perdió
los bytes ≥ 0x80). **No se ha inventado ninguna otra captura.**

Cómo obtener capturas válidas (móvil conectado, `adb` en
`%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`):

```powershell
# Windows PowerShell: usar cmd, o redirigir bytes explícitamente
cmd /c "adb exec-out screencap -p > docs\ui-ux-audit\screenshots\01-arranque.png"
# alternativa recomendada (sin redirección de shell):
adb exec-out screencap -p | Set-Content -Encoding Byte -Path docs\ui-ux-audit\screenshots\01-arranque.png
```

Nombres propuestos (solo cuando exista la captura real):

| Archivo | Pantalla | Ruta |
|---|---|---|
| `01-arranque.png` | Splash | `/splash` |
| `02-welcome.png` | Login | `/` |
| `03-onboarding.png` | Wizard paso 1 | `/onboarding` |
| `04-dashboard.png` | Dashboard pestaña 1 | `/home` |
| `05-conversacion.png` | Conversación | `/conversation` |
| `06-resumen.png` | Resumen de sesión | `/summary` |
| `07-paywall.png` | Paywall | `/paywall` |
| `08-gremio.png` | Guild | `/chat-rooms` |
| `09-tienda.png` | Tienda | `/shop` |
| `10-misiones.png` | Misiones | `/missions` |

Verificación mínima de una captura:
`(Get-Content -Encoding Byte -TotalCount 8 archivo.png)` debe empezar `137 80 78 71`.

---

## 6. Conclusión del análisis

El sistema visual **existe** (paleta completa, 4 radios, 8+4 espaciados, 3
familias empaquetadas, `GlassCard` usado 100 veces, 725 tests verdes). El
problema no es ausencia de diseño sino **adopción desigual**: 3 usos de
`AppSpacing` frente a 419 literales, 384 llamadas tipográficas directas frente a
114 tokenizadas, 0 usos de `AppElevation`, y una capa de accesibilidad de 5
`Semantics` reales para 20 pantallas.

Ese es el eje de los documentos siguientes: no proponer una paleta nueva, sino
**cerrar la brecha entre el sistema declarado y el implementado**, con el código
como única fuente de verdad.
