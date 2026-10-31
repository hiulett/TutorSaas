# 04 — Sistema de diseño (tokens y componentes reales)

> **Alcance:** `lib/core/theme/*` y `lib/core/widgets/*` del worktree
> `p14-ai-usage` (`origin/master`, octubre 2026), más los patrones que las 20
> pantallas replican a mano.
> **Método:** lectura de los 8 archivos de tokens, conteo de uso en todo `lib/`,
> cálculo WCAG con la misma fórmula que `lib/core/theme/app_contrast.dart:19-31`
> y contraste de valores contra los tests del repo.
>
> ## Aviso metodológico
>
> **No hay visión de imágenes** y el móvil está desconectado. Este documento
> describe el sistema **por definición y por uso en el árbol de widgets**
> (qué token, qué widget, cuántas veces, con qué evidencia). **No** describe
> píxeles observados, ni cómo se siente la animación, ni si el contraste
> calculado se percibe igual sobre los fondos animados
> (`CyberManhwaBackground` dibuja partículas y orbes: el cálculo asume
> superficie plana).
>
> Etiquetas: `[IMPLEMENTADO]` · `[PARCIAL]` · `[CONCEPTUAL]` ·
> `[PROPUESTA]` · `[PENDIENTE DE VALIDAR]`.

---

## 1. Arquitectura del design system

```
lib/core/theme/
├── app_colors.dart        89 tokens de color (8 366 B)
├── app_typography.dart    7 estilos semánticos (Space Grotesk / Inter / JetBrains Mono)
├── app_spacing.dart       escala 4·n (unit, xs…huge) + 4 presets de EdgeInsets
├── app_radius.dart        sm 4 · md 8 · lg 12 · circle 999 + 3 BorderRadius
├── app_elevation.dart     4 conjuntos de BoxShadow (none/flat/accent/reward)
├── app_motion.dart        5 duraciones + 3 curvas + gate de reduce-motion
├── app_contrast.dart      fórmula WCAG (luminancia, ratio, meetsAA)
└── app_theme.dart         ThemeData oscuro: ColorScheme, TextTheme, botones,
                           inputs, switch, chip, dialog, snackbar, bottom nav
```

**Fuente de verdad declarada:** `test/golden/design_tokens_test.dart:13-24`
("la fuente de verdad es el código, no un documento"). Ese test:

1. Parsea `app_colors.dart` y **falla si aparece un `Color(0x…)` cuyo valor no
   esté en la paleta** (`:67-97`).
2. Afirma los valores de `AppRadius` y que `GlassCard` usa `AppRadius.sm`
   (`:99-111`).
3. Falla si `lib/` pide una familia tipográfica fuera de las 3 empaquetadas
   (`:143-190`).
4. Afirma que el `ThemeData` sólo usa familias y colores del sistema
   (`:195-…`).

**Lo que ese guard NO protege (medido):**

| Hueco | Evidencia | Consecuencia |
|---|---|---|
| Comprueba el **valor**, no el token: `Color(0xFF0F172A)` pasa porque `surfaceDeep` vale eso | `design_tokens_test.dart:62-65, 81-86` | 16 literales duplican tokens existentes en lugar de usarlos (p. ej. `conversation_screen.dart:473, 901, 1754, 1811` = `surfaceDeep`) |
| No mide `EdgeInsets` | 419 `EdgeInsets.*` frente a **3** usos reales de `AppSpacing` | ver §4.2 |
| No mide `BorderRadius.circular(n)` | 177 literales frente a 68 referencias a `AppRadius` | ver §6 |
| No mide animaciones ni reduce-motion | 12 de 14 `repeat()` sin gate | ver §9 |
| No mide `Semantics` | 9 en todo `lib/` | doc 13 |

---

## 2. Color

### 2.1 Base de superficies

| Token | Valor | Nota |
|---|---|---|
| `voidBg` | `#05070E` | fondo de `Scaffold` y del `MaterialApp` |
| `background` = `surface` = `surfaceDim` | `#11131B` | **tres nombres, un valor** |
| `surfaceGlass` | `#11131B` (α 0.94 + blur 4) | identidad de tarjeta (`glassOpacity`, `glassBlur`, `glassBorderAlpha 0.8`) |
| `surfaceContainerLowest` | `#0B0E16` | |
| `surfaceContainerLow` | `#191B23` | fondo de inputs |
| `surfaceContainer` | `#1D1F27` | **sin uso** |
| `surfaceContainerHigh` | `#272A32` | snackbar, chips, barras |
| `surfaceContainerHighest` = `surfaceVariant` | `#32343D` | |
| `surfaceBright` | `#373942` | **sin uso** |
| `surfaceDeep` | `#0F172A` | sheets, dropdowns, diálogos (y 4 literales duplicados) |
| `arenaVoid` / `screenBg` / `statusWindowBg` | `#04060C` / `#090D16` / `#060A14` | fondos de examen, gremio y HUD |

### 2.2 Acentos y semántica

| Familia | Tokens | Uso real |
|---|---|---|
| Cian (primario) | `manaCyan #00E5FF`, `manaCyanDim #00DAF3`, `manaCyanLight #9CF0FF`, `manaCyanText #C3F5FF` | `manaCyan` es el acento dominante (bordes, labels, CTAs del tema); `manaCyanDim` en el diff de texto y la barra de metas; `manaCyanLight` y `manaCyanText` **sin uso** |
| Dorado (recompensa) | `royalGold #FFC700`, `royalGoldDim #F5BF00`, `royalGoldLight #FFDF94` | `royalGold` en recompensas y avisos; `royalGoldLight` en sala de voz, mini-conversación y onboarding; `royalGoldDim` **sin uso** |
| Violeta (secundario/mágico) | `runeViolet #9D4EDD`, `runeVioletContainer #E6C3FF`, `runeVioletText #F8E7FF` | `runeViolet` en botones primarios/acentos; `runeVioletText` aparece tras UX-05; `Container` **sin uso** |
| Verde | `emeraldGreen #00E676`, `emeraldGreenDim #3CDDC7`, `successGreen #00E676` | `emeraldGreen` en éxito; los otros 2 **sin uso** |
| Rojo | `crimsonRed #FF1744`, `errorRed #FFB4AB`, `errorContainer #93000A` | `crimsonRed` en errores/destructivos (contraste bajo, §10); `errorRed` en texto de error |
| Texto | `onBackground` = `onSurface` `#E1E2ED`, `onSurfaceVariant #BAC9CC` | dos niveles de texto |
| Bordes | `outline #849396`, `outlineVariant #3B494C` | |
| CEFR | `cefrPreA1…cefrC2` (7) | mapa de mazmorras |
| Rareza | `rarityCommon…rarityLegendary` (5) | 3 en uso (`Rare`, `Epic`, `Legendary`); `Common` y `Uncommon` **sin uso** |
| Medieval | `medievalBg/Stone/Iron/DarkWood/AgedGold/AgedGoldDim/AgedGoldLight/MagicBlue/ArcanePurple/BloodRed/Text/TextDim` (12) | 7 en uso (`Bg`, `Stone`, `Iron`, `AgedGold`, `AgedGoldLight`, `Text`, `TextDim`); **5 sin uso** (`DarkWood`, `AgedGoldDim`, `MagicBlue`, `ArcanePurple`, `BloodRed`) |

### 2.3 Los 25 tokens que existen y **nunca** se usan fuera de `app_colors.dart`

`surfaceBright`, `surfaceContainerLowest`, `surfaceContainer`,
`surfaceContainerHighest`, `surfaceVariant`, `manaCyanLight`, `manaCyanText`,
`royalGoldDim`, `runeVioletContainer`, `emeraldGreenDim`, `successGreen`,
`xpBarGreen`, `rarityCommon`, `rarityUncommon`, `progressYellow`,
`vocabularyBlue`, `presencePink`, `aiGold`, `hostingAmber`, `chatBlue`,
`medievalDarkWood`, `medievalAgedGoldDim`, `medievalMagicBlue`,
`medievalArcanePurple`, `medievalBloodRed`.

> **Lectura:** 28 % de la paleta es decorado. No es un problema de contraste;
> es un problema de **mantenimiento**: el siguiente que necesite "un naranja de
> rareza" creará `rarityLegendary` otra vez con otro hex.

### 2.4 Alias (deuda declarada)

`aiGold`, `triumphGold`, `rankGold` = `trophyGold`; `deepSlate`,
`sheetBackground`, `monsterAvatarBg` = `surfaceDeep`; `easyGreen`, `liveGreen`
= `accentGreen`; `rankMagenta` = `blindMagenta`; `hostingAmber` = `guildAmber`;
`chatBlue` = `collabBlue` (`app_colors.dart:110-120`). Son alias reales, no
tokens nuevos: sirven para no romper llamadas antiguas.

### 2.5 Token → uso real (hex y dónde se pinta)

Recuento del 31-oct-2026 sobre `lib/**/*.dart` excluyendo `app_colors.dart`
(cada aparición de `AppColors.<token>` cuenta una vez). «Top» son los dos
archivos con más apariciones: sirve para saber **quién manda** en cada color.

| Token | Hex | Refs | Dónde se usa (top 2) | Lectura |
|---|---|---|---|---|
| `onSurface` | `#E1E2ED` | 336 | `settings_screen.dart` (28) · `profile_edit_screen.dart` (28) | es el **texto**, no un acento: cualquier pantalla nueva lo usa por defecto |
| `manaCyan` | `#00E5FF` | 315 | `chat_rooms_screen.dart` (18) · `voice_room_screen.dart` (18) | acento **de sistema**: bordes, labels, CTAs del tema (`app_theme.dart:86-87`) |
| `runeViolet` | `#9D4EDD` | 223 | `conversation_screen.dart` (15) · `shop_screen.dart` (15) | acento **de acción/magia**: botones primarios de pantalla, no del tema |
| `onSurfaceVariant` | `#BAC9CC` | 199 | `settings_screen.dart` (24) · `chat_rooms_screen.dart` (19) | copy secundario y subtítulos |
| `royalGold` | `#FFC700` | 181 | `chat_rooms_screen.dart` (19) · `onboarding_screen.dart` (18) | **recompensa/gremio**: trofeos, misión de sala, Oráculo |
| `emeraldGreen` | `#00E676` | 70 | `shop_screen.dart` (9) · `session_summary_screen.dart` (8) | éxito y «completada» |
| `glassOpacity` (α) | `0.94` | 69 | `settings_screen.dart` (12) · `progress_tab_view.dart` (7) | se pasa a mano a `GlassCard`; el default ya es 0.94 |
| `crimsonRed` | `#FF1744` | 61 | `draggable_monster_widget.dart` (11) · `dungeon_guardian_screen.dart` (11) | peligro/bloqueo (guardián, jefe, destructivos) |
| `voidBg` | `#05070E` | 36 | `shop_screen.dart` (6) · `app_theme.dart` (4) | fondo y **texto sobre acento** (`onPrimary`, `app_theme.dart:14`) |
| `medievalTextDim` | `#9A8F7A` | 33 | `weekly_report_screen.dart` (12) · `listening_quiz_screen.dart` (9) | segunda paleta de texto en las pantallas «pergamino» |
| `errorRed` | `#FFB4AB` | 29 | `settings_screen.dart` (7) · `voice_room_screen.dart` (5) | texto de error |
| `medievalText` | `#D8CBB0` | 21 | `weekly_report_screen.dart` (8) · `character_creation_wizard.dart` (4) | texto de las pantallas «pergamino» |
| `guildAmber` | `#FFAB00` | 12 | `voice_room_screen.dart` (4) · `hunter_catalog.dart` (2) | aviso de demo/limitación en la sala |
| `medievalAgedGold` | `#B8860B` | 12 | `character_creation_wizard.dart` (9) · `conversation_screen.dart` (3) | botón CONTINUAR del Oráculo (`:1988`) |
| `accentGreen` | `#10B981` | 11 | `mission_card.dart` (6) · `ai_pick_hero_card.dart` (3) | verde «suave» alternativo a `emeraldGreen` |
| `surfaceDeep` | `#0F172A` | 11 | `settings_screen.dart` (2) · `dashboard_screen.dart` (1) | diálogos y sheets |
| `runeVioletText` | `#F8E7FF` | 8 | `correction_chip.dart` (3) · `my_errors_screen.dart` (1) | texto sobre violeta (contraste alto) |
| `outline` | `#849396` | 8 | `mission_card.dart` (4) · `app_theme.dart` (4) | deshabilitado / secundario de tema |
| `surfaceContainerLow` | `#191B23` | 8 | `guild_master_floating_banner.dart` (2) · `app_theme.dart` (2) | relleno de inputs (`app_theme.dart:130`) |

**Lectura:** el color más usado de la app **no es un acento, es el texto**
(`onSurface`). El segundo es `manaCyan`, que sí se comporta como color de
sistema. `runeViolet` es el acento de **decisión** (comprar, continuar, ser
premium) y es justo el token cuyo texto falla AA (§9.2).

### 2.6 Fondo de cada pantalla (asset o color)

`CyberManhwaBackground` no elige el fondo por pantalla: lo elige por
`bgMode`. La tabla siguiente es la traducción real **modo → asset** que hace
`cyber_manhwa_background.dart:117-160`.

Capas que pinta el fondo animado, siempre en este orden
(`cyber_manhwa_background.dart:172-268`):

1. `arenaVoid #04060C` a pantalla completa (`:176-180`).
2. `Image.asset(fit: cover)` con **zoom de cámara** (`Transform.scale`, 12 s,
   `:44-46`, `:185-207`). Si el asset falla → `RadialGradient` de
   `themeColor` al 35 % (`:196-206`).
3. Viñeta vertical `arenaVoid` α 0.82 / 0.65 / 0.90 (`:210-223`).
4. Círculo mágico + runas: rotación 25 s + pulso 3 s (`:36-41`, `:226-240`).
5. 35 partículas de maná, 8 s en bucle (`:48-51`, `:243-258`).
6. El contenido de la pantalla (`:261-263`).

| Pantalla | Contenedor de fondo | Modo | Asset resultante | Extras propios |
|---|---|---|---|---|
| SCR-01 Splash | `Scaffold(backgroundColor: voidBg)` | — | **ninguno** (sin imagen) | 3 orbes radiales + rejilla `CustomPaint` paso 34 px (`splash_screen.dart:92-126`) |
| SCR-02 Welcome | `Scaffold` (fondo del tema = `voidBg`) | — | **ninguno** | 2 orbes con `BackdropFilter` blur 120/140 (`welcome_screen.dart:81-122`) |
| SCR-03 Onboarding | `CyberManhwaBackground` | `onboardingStep0/2/7/3` | `onboarding_interview_bg.jpg` → `dungeon_ruins_a2_bg.jpg` → `onboarding_license_delivery_bg.jpg` → `dungeon_wind_b1_bg.jpg` | 2 orbes (`onboarding_screen.dart:399-412`, `:424-452`) |
| SCR-04 Mini-conv. | `CyberManhwaBackground` | `onboardingStep3` | `dungeon_wind_b1_bg.jpg` | — (`mini_conversation_screen.dart:170-171`) |
| SCR-05 Conversación | `CyberManhwaBackground` | `dynamicLevel` + `levelCode` = nivel de la lección | A1/PRE-A1 `dungeon_forest_a1`; A2 `dungeon_ruins_a2`; B1 `dungeon_wind_b1`; B2 `cyber_manhwa_portal`; C1/C2 `dungeon_boss_arena` | orbe violeta (`conversation_screen.dart:1159-1160`, `:1175-1186`) |
| SCR-06 Dashboard | `CyberManhwaBackground` | tab 2 → `hunterStatus`; resto → `dashboardGate` | `hunter_status_matrix_bg.jpg` / `dashboard_dungeon_gate_bg.jpg` | 2 orbes (`dashboard_screen.dart:234-237`, `:241-264`) |
| SCR-07 Gremio | `CyberManhwaBackground` | `guildHall` | `guild_hall_adventurers_bg.jpg` | — (`chat_rooms_screen.dart:955-956`) |
| SCR-08 Sala de voz | `CyberManhwaBackground` | `guildTable` | `guild_table_adventurers_bg.jpg` | 2 orbes con blur (`voice_room_screen.dart:564-565`, `:568-600`) |
| SCR-09 Misiones | `Scaffold(backgroundColor: screenBg)` | — | **ninguno** | color `#090D16` (`missions_screen.dart:25-26`) |
| SCR-10 Tienda | `CyberManhwaBackground` | `dashboardGate` | `dashboard_dungeon_gate_bg.jpg` | — (`shop_screen.dart:339-340`) |
| SCR-11 Inventario | `CyberManhwaBackground` | `hunterStatus` | `hunter_status_matrix_bg.jpg` | — (`inventory_screen.dart:104-105`) |
| SCR-12 Guardián | `CyberManhwaBackground` | `dashboardGate` | `dashboard_dungeon_gate_bg.jpg` | 2 orbes **pulsantes** carmesí/violeta (`dungeon_guardian_screen.dart:110-132`) |
| SCR-13 Resumen | `Scaffold` (tema) | — | **ninguno** | 2 orbes planos violeta α .07 / cian α .06 (`session_summary_screen.dart:93-120`) |
| SCR-14 Perfil | `CyberManhwaBackground` | `hunterStatus` | `hunter_status_matrix_bg.jpg` | — (`profile_edit_screen.dart:260-261`) |
| SCR-15 Ajustes | `CyberManhwaBackground` **sin `bgMode`** | `dynamicLevel` (default) | `dungeon_forest_a1_bg.jpg` (A1 por defecto) | 2 orbes con blur (`settings_screen.dart:66`, `:70-101`) |
| SCR-16 Paywall | `CyberManhwaBackground` **sin `bgMode`** | `dynamicLevel` (default) | `dungeon_forest_a1_bg.jpg` | — (`paywall_screen.dart:213-214`) |
| SCR-17 Boss result | `Scaffold(backgroundColor: voidBg)` | — | **ninguno** | color plano (`boss_exam_result_screen.dart:27-28`, `:58-59`) |
| SCR-18 Mis errores | `CyberManhwaBackground` | `hunterStatus` | `hunter_status_matrix_bg.jpg` | — (`my_errors_screen.dart:29-30`) |
| SCR-19 Informe semanal | `CyberManhwaBackground` | `hunterStatus` | `hunter_status_matrix_bg.jpg` | — (`weekly_report_screen.dart:35-36`) |
| SCR-20 Listening | `CyberManhwaBackground` | `hunterStatus` | `hunter_status_matrix_bg.jpg` | — (`listening_quiz_screen.dart:199-200`) |

**Hallazgos de fondo:**

- **5 de 20 pantallas (Splash, Welcome, Misiones, Resumen, Boss result) no
  usan imagen**: 2 son color plano con orbes y 3 son literalmente
  `Scaffold(color)` sin textura. Son justamente pantallas de **cierre de flujo**
  (resumen, resultado del jefe) y de **entrada** (splash, welcome).
- **Ajustes y Paywall caen en el fondo de A1** (`dungeon_forest_a1_bg.jpg`)
  porque llaman a `CyberManhwaBackground()` sin `bgMode` y el default es
  `dynamicLevel` con `levelCode = 'A1'` (`cyber_manhwa_background.dart:32,34`).
  Ninguna de las dos es una mazmorra de A1: es un default, no una decisión.
- **4 modos nunca se instancian desde una pantalla**: `onboardingStep1`,
  `onboardingStep4`, `onboardingStep5` y `onboardingStep6` (de 13 modos, 9 se
  usan; `dynamicLevel` sólo por default). El onboarding usa 0, 2, 7 y 3
  (`onboarding_screen.dart:399-412`): el paso 1 se pinta con el fondo del paso 2.
- **9 de 20 pantallas comparten 2 assets** (`hunterStatus` en 6 y
  `dashboardGate` en 3). Las 11 imágenes de fondo del bundle
  (`assets/images/*_bg.jpg`) son alcanzables, pero la variedad real es de 11
  imágenes para 20 pantallas.

---

## 3. Tipografía

### 3.1 Familias

| Familia | Rol | Empaquetada |
|---|---|---|
| **Space Grotesk** | títulos y titulares | ✅ `assets/google_fonts/` (25 archivos) |
| **Inter** | cuerpo y copy | ✅ |
| **JetBrains Mono** | etiquetas, stats, HUD | ✅ |

`google_fonts` **no descarga en runtime**: las 3 familias están en el bundle y
`test/bundled_fonts_test.dart` lo verifica.

### 3.2 Tokens semánticos (`AppTypography`)

| Estilo | Familia | Tamaño | Peso | Uso |
|---|---|---|---|---|
| `headline` | Space Grotesk | 26 | w800 | títulos de pantalla |
| `title` | Space Grotesk | 18 | w700 | cabeceras de tarjeta |
| `subtitle` | Space Grotesk | 15 | w600 | subtítulos |
| `body` | Inter | 14 | w400 | cuerpo |
| `bodyMuted` | Inter | 13 | w400 (`onSurfaceVariant`) | copy secundario |
| `label` | JetBrains Mono | 11 | w700 (letterSpacing 1.0, cian) | etiquetas HUD |
| `stat` | JetBrains Mono | 12 | w800 | cifras |
| `tiny` | JetBrains Mono | 9 | w600 (letterSpacing 0.8) | micro-etiquetas |

`AppTypography` **no** cubre los cuerpos 16/20/22/24/10 con semántica; por eso
las pantallas escriben `GoogleFonts.*` a mano.

### 3.3 La escala real (medida hoy)

| Métrica | Valor | Fuente |
|---|---|---|
| Referencias a `AppTypography.*` | **114** | grep |
| Referencias a `GoogleFonts.*` | **384** (353 fuera de `core/theme`) | grep |
| `fontSize` literales en `lib/` | **536** usos | grep |
| … excluyendo `core/theme` | **508** usos en **21 tamaños distintos** | grep |
| Usos por debajo de 12 px | **239** (7 px = 2, 8 px = 17, 9 px = 47, 10 px = 82, 11 px = 91) | histograma |
| Tamaño mínimo real | **7 px** (2 usos) | histograma |
| Fracciones raras | 11.5 px, 12.5 px | histograma |

Distribución completa (sin `core/theme`):

```
 7 → 2     8 → 17    9 → 47   10 → 82   11 → 91   12 → 99   13 → 50
14 → 18   15 → 26   16 → 30   17 → 2    18 → 24   20 → 8    22 → 2
24 → 2    28 → 1    32 → 2    40 → 1
```

**Diagnóstico.** El sistema existe (114 usos) pero **convive con 508 decisiones
ad-hoc**. El **47 %** del texto de la app está por debajo de 12 px. La buena
noticia: el número de tamaños bajó de 31 (auditoría) a 21, y el mínimo de 7 px
sólo aparece 2 veces.

### 3.4 `TextTheme` del tema y el hueco de Roboto

`app_theme.dart:22-83` define 12 estilos. Cuatro **no** se asignan y caen al
`TextTheme` por defecto (Roboto, **no empaquetada**): `headlineSmall`,
`titleSmall`, `bodySmall`, `labelSmall`.

Hoy nadie los usa (0 llamadas a `Theme.of(context).textTheme.bodySmall`), así que
el riesgo es **latente**, no visible. Si una pantalla futura los usa, se rompe la
identidad tipográfica sin fallar ningún test.

### 3.5 Jerarquía tipográfica real (qué tamaño hace qué)

La jerarquía **no** sale de los tokens (`AppTypography` tiene 8 estilos, 114
usos) sino de 508 `fontSize` literales. Traducida a roles, esto es lo que el
código hace de verdad:

| Rol | Tamaño / peso observado | Familia | Ejemplo real |
|---|---|---|---|
| Marca (splash) | 24 w900, tracking 3.5 | Space Grotesk | `splash_screen.dart:182-185` |
| Título de pantalla | 18–24 w800/w900 | Space Grotesk | `missions_screen.dart:114-119` (18) · `settings_screen.dart:127-132` (24) · `inventory_screen.dart:127-132` (20) |
| Título de héroe/bloque | 20 w700 | Space Grotesk | `boss_exam_result_screen.dart:82-87` · `listening_quiz_screen.dart:291-295` |
| Cabecera de tarjeta | 15–17 w700 | Space Grotesk | `dashboard_screen.dart:103-107` (15) · `:335-340` (17) |
| Subtítulo de pantalla | 12–13 w400 | Inter | `my_errors_screen.dart:66-71` · `weekly_report_screen.dart:73-77` |
| Cuerpo | 12–14 w400 | Inter | `mini_conversation_screen.dart:280-283` · `my_errors_screen.dart:225-230` (13) |
| Etiqueta HUD | 9–11 w600/w700 mono, tracking 0.5–2.5, mayúsculas | JetBrains Mono | `splash_screen.dart:199-204` (10) · `inventory_screen.dart:137-141` (10) · `missions_screen.dart:124-128` (9) |
| Cifra / stat | 12 w800 mono | JetBrains Mono | `onboarding_screen.dart:508-510` |
| Micro-etiqueta | 8–9 mono | JetBrains Mono | `inventory_screen.dart:381-385` (8) · `voice_room_screen.dart:760-765` (8) |

**Lectura de jerarquía:** hay **3 niveles claros** (26/20/18 títulos, 12–15
cuerpo, 8–11 etiquetas) y **dos huecos**: (a) el mismo rol usa tamaños distintos
según la pantalla (título 18 en Misiones, 20 en Inventario, 24 en Ajustes); (b)
el 47 % del texto está por debajo de 12 px, es decir, la mayor parte de la UI
está en el nivel de «etiqueta».

Los `Theme.of(context).textTheme.*` se usan poco: el único uso relevante
encontrado es `titleMedium` en la cabecera de la conversación
(`conversation_screen.dart:1234`).

---

## 4. Tokens de superficie y forma

### 4.1 Radios (`AppRadius`)

| Token | Valor | Referencias | Rol |
|---|---|---|---|
| `sm` | 4 | **42** | cards, botones, inputs (estándar del producto) |
| `md` | 8 | 2 | contenedores destacados |
| `lg` | 12 | 20 | pills/chips |
| `circle` | 999 | 0 directas | avatares y orbes |
| `card` | `circular(4)` | 3 | alias |
| `pill` / `circleBorder` | `circular(12)` / `circular(999)` | 0 | alias |

**Total referencias a `AppRadius`: 68.** Enfrente, **177**
`BorderRadius.circular(<n>)` literales en `lib/`.

Valores literales que rompen la escala: `1.5` (`segmented_bar.dart:33`),
`16` (toolbar del chat), `24` (botón CONTINUAR del Oráculo,
`conversation_screen.dart:1987`), `30` y `999` manuales.

#### 4.1.1 Radio real por componente

| Componente | Radio | Evidencia |
|---|---|---|
| `GlassCard` (superficie estándar) | **4** por defecto, configurable | `glass_card.dart:31,103-110` |
| `RpgAvatar` (marco) / imagen interior | **4** / **2** | `rpg_avatar.dart:91,102` |
| Dock flotante del dashboard | **4** (envuelto en `ClipRRect`) | `dashboard_screen.dart:563-565` |
| Tarjeta de oferta / item de inventario | **4** | `inventory_screen.dart:337,400,432` |
| Chip de moneda | **4** (`AppRadius.sm`) | `shop_screen.dart:417` |
| Chip «PRO / IR PRO» | **12** (`AppRadius.lg`) | `dashboard_screen.dart:438-441` |
| Botón CONTINUAR del Oráculo | **24** (pill manual, fuera de escala) | `conversation_screen.dart:1987` |
| Toolbar de modos de la conversación | **16** (manual) | `conversation_screen.dart:1372,1386,1435,1449` |
| Segmento de `SegmentedBar` | **1.5** (manual) | `segmented_bar.dart:33` |
| Diálogo del tema | **4** + borde violeta 1.5 | `app_theme.dart:190-193` |
| Burbuja de chat (mini-conversación) | **12** con esquina de emisor a **3** | `mini_conversation_screen.dart:273-278` |

**Lectura:** el radio 4 es la firma del producto y se respeta en las
superficies; las **excepciones son todas de la conversación** (24 y 16), la
pantalla más grande del repo. Un componente nuevo no necesita decidir radio: usa
`AppRadius.sm`.

### 4.2 Espaciado (`AppSpacing`)

Escala de 4 px: `xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32 ·
huge 48`, más presets `screen`, `card`, `compact`, `button`.

| Métrica | Valor |
|---|---|
| Usos reales de `AppSpacing.*` | **3**, todos `AppSpacing.button` (`app_theme.dart:96, 111, 125`) |
| `EdgeInsets.*` literales | **419** |
| Presets `screen`/`card`/`compact` usados | **0** |

Es el hallazgo más duro del sistema: **la escala de espaciado no se usa**. El
`GlassCard` usa `EdgeInsets.all(24)` por defecto (`glass_card.dart:107`)
mientras el preset equivalente (`AppSpacing.card`) es 16.

> **Reconciliación con la baseline:** `_baseline.md` anota «`AppSpacing` 4
> usos». El recuento del 31-oct da **3** referencias, todas
> `AppSpacing.button` en `app_theme.dart:96, 111, 125`. Manda el código; la
> baseline queda desfasada en 1.

**El espaciado real, por pantalla**, se decide a mano con tres valores que se
repiten:

| Valor literal | Dónde | Ejemplo |
|---|---|---|
| 24 horizontal | margen de pantalla | `dashboard_screen.dart:301-304` · `inventory_screen.dart:111-114` |
| 16–20 horizontal | pantallas hijas con cabecera | `missions_screen.dart:32` · `my_errors_screen.dart:36` |
| 8–12 entre bloques | ritmo vertical | `mini_conversation_screen.dart:179-192` |

Es decir: existe un grid de facto (4·n) pero **no se invoca**; el `24` de
`GlassCard` compite con el `16` declarado como preset de tarjeta.

### 4.3 Elevación (`AppElevation`)

| Preset | Definición | Usos |
|---|---|---|
| `none` | `[]` | 0 |
| `flat` | negro 8 % · blur 4 · offset (0,1) | 0 |
| `accent` | cian 35 % · blur 12 · offset (0,2) | 0 |
| `reward` | dorado 35 % · blur 16 · offset (0,2) | 0 |

**`AppElevation` tiene 0 usos fuera de su propio archivo** (verificado: la única
coincidencia es `AppElevation._();`). Las sombras se escriben a mano; p. ej.
`GlassCard` genera por defecto
`BoxShadow(color: bColor.withValues(alpha: 0.3), blurRadius: 8)`
(`glass_card.dart:100`), que **no coincide con ningún preset**.

### 4.4 Movimiento (`AppMotion`)

| Token | Valor | Referencias |
|---|---|---|
| `micro` | 150 ms | 2 |
| `fast` | 300 ms | 1 |
| `standard` | 600 ms | 4 |
| `reward` | 1200 ms | 1 |
| `ambient` | 2 s | 1 |
| `curveStandard` | `easeOutCubic` | 2 |
| `curveSpring` | `easeOutBack` | 2 |
| `curvePress` | `easeInOut` | 2 |
| `reduceMotion(context)` | `MediaQuery.disableAnimationsOf` | 1 |
| `of(context, duration)` | devuelve `Duration.zero` si reduce-motion | 2 |
| `scaled(...)` | alias de `of` | **0** |

**Total: 19 referencias** para animar una app con **23 `AnimationController`** y
14 `repeat()` infinitos. La mayoría de animaciones usan duraciones literales
(200, 300, 400, 800 ms…).

---

## 5. Componentes compartidos

`lib/core/widgets/` — **13 archivos**. Conteo de uso en todo `lib/`:

| Widget | Usos | Archivos | Estado | Rol real |
|---|---|---|---|---|
| **`GlassCard`** | **100** | **44** | ✅ `[IMPLEMENTADO]` | La superficie única: blur 4, α 0.94, borde cian α 0.8, radio 4, escala 0.98 al pulsar, esquinas rúnicas opcionales |
| **`CyberManhwaBackground`** | 17 | 16 | ✅ | Fondo animado con **13 modos** (`CyberBgMode`: `dynamicLevel`, `onboardingStep0…7`, `dashboardGate`, `guildHall`, `guildTable`, `hunterStatus`) |
| **`SystemSnack`** | **48** | **14** | ✅ con competencia | Snackbar con acento semántico (`success/error/warning/info/reward`) y borde de color |
| **`RunicButton`** | 12 | 6 | ⚠️ infrautilizado | Botón primario con escala 0.96 y `isBusy`; por defecto violeta + **blanco** (4.60:1) |
| **`RpgAvatar`** | 9 | 8 | ✅ | Avatar por clase con borde de marco cosmético |
| **`SegmentedBar`** | 8 | 7 | ✅ | Progreso por segmentos (único golden de píxeles) |
| **`SystemWindow`** | 5 | 3 | ✅ | Ventana HUD con cabecera (`chat_rooms_screen.dart:268,328`, `daily_reward_modal.dart:84`) |
| **`AnimatedCounter`** | 8 | 2 | ✅ | Cifras animadas |
| **`ManaMeterWidget`** | 3 | 2 | ⚠️ duplica `OracleManaBar` | Medidor de maná |
| **`QuestCard`** | 3 | 2 | ⚠️ duplica `MissionCard` | Tarjeta de misión (sólo `learning_path_roadmap.dart:699`) |
| **`FloatingReward`** | 2 (`show`) | 1 (`hunter_hud_header.dart:131,185`) | ✅ | Toast de recompensa |
| **`ConfigurationErrorWidget`** | 2 | 2 | ✅ | Error de arranque (falta de config) |
| **`DraggableMonsterWidget`** | 7 refs | 2 | ⚠️ 390 líneas para 1 uso | Monstruo arrastrable en conversación |

### 5.1 Componentes que **no existen** aunque se citan

| Nombre citado | Estado real |
|---|---|
| **`HudState`** (loading/error/empty unificado) | **`[PROPUESTA]`** — no hay archivo ni clase; el backlog (`UX-16`, `UX-17`, `UX-28`) lo propone. Cada pantalla reimplementa sus estados (ver matriz en doc 03 §4.1) |
| `HudIconButton` | `[PROPUESTA]` (`UX-03`) |
| `HudSheet` | `[PROPUESTA]` (`UX-21`) |
| `HudHeader` | `[PROPUESTA]` (`UX-12`); hoy hay **7 cabeceras con "volver" escritas a mano** |

### 5.2 Duplicaciones reales de componente

| Componente | Implementación A | Implementación B |
|---|---|---|
| Cabecera con volver | `missions_screen.dart:82` (con tooltip) | `my_errors_screen.dart:35`, `weekly_report_screen.dart:41`, `inventory_screen.dart:110`, `shop_screen.dart:363`, `profile_edit_screen.dart:267`, `session_summary_screen.dart:140` |
| «Recompensa» | `_RewardChip` (`session_summary_screen.dart:1206`) | `mission_card.dart:396` |
| Estado de error | `_ErrorState` (`my_errors_screen.dart:323`) | `_ErrorState` (`weekly_report_screen.dart:627`), `_LoadErrorState` (`listening_quiz_screen.dart`), `_ErrorRow` (`session_summary_screen.dart`) |
| Orbe decorativo | `_GlowOrb` (`splash_screen.dart:247`) | `_GlowOrb` (`dungeon_guardian_screen.dart:650`) — copia literal |
| Métrica/tile | `_Metric` (`weekly_report_card.dart:151`) | `_StatTile` (`weekly_report_screen.dart:536`) |
| Botón redondo | `_RoundIconButton` (`session_summary_screen.dart:1038`, parametrizable) | `_RoundIconButton` (`dungeon_guardian_screen.dart:740`, 40 fijo) |

---

## 6. Iconografía e imágenes

| Recurso | Medida | Nota |
|---|---|---|
| `Icons.*` (Material) | **453 referencias**, **173 iconos distintos** | No hay set propio: se usa Material tal cual |
| Iconos con `Tooltip` | 6 en toda la app | `UX-22` |
| Emojis usados como icono | 3 focos: selector de temas (`conversation_screen.dart:142-163`), toggle de chat oculto (`:1396-1403`), toggle de modo (`:1461`) | Rompen la identidad mono/cian y no tienen `semanticsLabel` |
| Avatares | `assets/images/avatars/` 10 archivos (`oracle_01.png` en cabecera del chat) | |
| Imágenes de tienda | `assets/images/shop/` 10 archivos **fuera del bundle** (decisión de peso, `pubspec.yaml:67-69`) | |
| Música | 1 archivo (`assets/music/`) para la taberna | |
| Fuentes | 25 archivos en `assets/google_fonts/` | |

**Patrón de color por ícono:** el color del icono **es** la semántica: cian =
sistema/primario, dorado = recompensa, violeta = magia/premium, verde = éxito,
rojo = peligro. No hay un mapa documentado; se deduce del uso (p. ej.
`dashboard_screen.dart:497-528`).

### 6.1 Los iconos que de verdad se usan

453 referencias a `Icons.*` y **173 iconos distintos**: **121 de 173 (70 %)** se
usan 1–2 veces. Los 25 más usados concentran el vocabulario visual real:

| # | Icono | Usos | Dónde se ve |
|---|---|---|---|
| 1 | `auto_awesome_rounded` | 26 | marca/IA/magia: splash (`splash_screen.dart:165`), Oráculo, auras |
| 2 | `check_circle_rounded` | 14 | éxito y «reclamado» (`dashboard_screen.dart:511`) |
| 3 | `military_tech_rounded` | 11 | rango/títulos (`inventory_screen.dart:282`) |
| 4 | `chevron_right_rounded` | 10 | navegación de lista |
| 5 | `arrow_back_ios_new_rounded` | 10 | **cabecera de pantalla hija** (7 implementaciones) |
| 6 | `diamond_rounded` | 9 | gemas/tienda (`dashboard_screen.dart:497`) |
| 7 | `tune_rounded` | 8 | ajustes de voz (`conversation_screen.dart:1252`) |
| 8 | `close_rounded` | 8 | cerrar/saltar (`mini_conversation_screen.dart:229`) |
| 9 | `refresh_rounded` | 8 | reintentar |
| 10 | `lock_rounded` | 8 | bloqueo (aura, nivel, cofre) |
| 11 | `bolt_rounded` | 7 | maná (`shop_screen.dart:393`) |
| 12 | `local_fire_department_rounded` | 7 | racha |
| 13 | `arrow_forward_rounded` | 7 | CTA «continuar» |
| 14 | `mic_rounded` | 7 | voz (`dashboard_screen.dart:79`) |
| 15 | `shield_rounded` | 6 | gremio/clase |
| 16 | `spellcheck_rounded` | 5 | errores (`dashboard_screen.dart:524`) |
| 17 | `explore_rounded` | 5 | objetivos de misión |
| 18 | `chat_bubble_outline_rounded` | 5 | chat de sala / chat barato |
| 19 | `record_voice_over_rounded` | 5 | turnos/pronunciación |
| 20 | `send_rounded` | 5 | enviar |
| 21 | `mic_off_rounded` | 5 | micrófono denegado |
| 22 | `emoji_events_rounded` | 5 | victoria/trofeo |
| 23 | `school_rounded` | 5 | «qué aprendiste» |
| 24 | `keyboard_arrow_down_rounded` | 4 | desplegables |
| 25 | `flag_rounded` | 4 | misión de sala |

**Lectura:** el set es **Material puro**, sin iconografía propia. La
`auto_awesome` es el logo de facto (splash, avatar de mago, auras, IA), lo que
mezcla «marca» y «magia/IA» en el mismo glifo.

### 6.2 Avatares

| Aspecto | Realidad | Evidencia |
|---|---|---|
| Assets | **10** archivos en `assets/images/avatars/`: 8 por clase + `oracle_01.png` (retrato del tutor) + `Mision.png` | `assets/images/avatars/` |
| Clase → asset | mapa fijo de 8 clases: `warrior→berserker`, `mage`, `assassin`, `knight`, `archer`, `summoner`, `paladin`, `necromancer` | `rpg_avatar.dart:24-33` |
| Forma | **cuadrado con radio 4** (no círculo), borde de **2 px** y glow `blurRadius 8` α 0.4 | `rpg_avatar.dart:86-99` |
| Color del borde | por clase/rareza: `isBoss` rojo, `monarch/legendary` naranja legendario, `elite/epic` morado, `assassin` azul rare, `warrior` rojo HP, `mage` cian, `necromancer` violeta, `knight/paladin` dorado, `archer` verde, `summoner` magenta | `rpg_avatar.dart:45-84` |
| Fallback | degradado `containerLow→containerHigh` + icono de clase + iniciales **sólo si `size ≥ 45`** | `rpg_avatar.dart:163-193` |
| Tamaños en uso | 30 (cabecera de la conversación y sala), 32 (dashboard), 50 (default), 80 (ficha de perfil) | `conversation_screen.dart:1261` · `dashboard_screen.dart:318` · `rpg_avatar.dart:17` · `profile_edit_screen.dart:332` |
| Avatar remoto | sólo si `avatarUrl` empieza por `http` y **no** es DiceBear (DiceBear se descarta a propósito) | `rpg_avatar.dart:38-40` |
| Avatar del tutor | `oracle_01.png` recortado en `ClipOval` 30×30 — **el único avatar circular** | `conversation_screen.dart:1258-1265` |

> **Riesgo de contraste/aspecto:** el avatar es cuadrado con radio 4 pero el del
> tutor es circular; la app no tiene una regla única de forma de avatar. Además,
> el asset por clase solo lo usa `RpgAvatar`; no hay selector de avatar en el
> onboarding más allá de la clase (`character_creation_wizard.dart:125-300`).

---

## 7. Animaciones

| Foco | Tipo | Reduce-motion |
|---|---|---|
| `glass_card.dart:60` | `repeat(reverse: true)` para esquinas rúnicas | ❌ **sin gate** |
| `cyber_manhwa_background.dart:55,60,65,70` | 4 loops de partículas/magia | ❌ |
| `draggable_monster_widget.dart:46,52,58,64` | 4 loops del monstruo | ❌ |
| `voice_waveform_visualizer.dart:30` | loop de onda | ❌ |
| `learning_path_roadmap.dart:553,561` | 2 loops de nodos | ❌ |
| `dungeon_guardian_screen.dart:46,47` | anillo + sello | ✅ **gated** (`:44-47`) |
| `runic_button.dart:84` | escala al pulsar | ✅ **gated** (`:67`) |

**14 `repeat()` en total; sólo 2 focos (los 2 últimos) consultan
`AppMotion.reduceMotion`.** El resto sigue animando con "quitar animaciones"
activado en Android.

> ⚠️ El issue **#243 (UX-04) está cerrado**, pero el gate sólo se aplicó en
> `dungeon_guardian` y `runic_button`; `glass_card`, el fondo, el monstruo, la
> onda y el roadmap siguen sin respetar la preferencia del sistema.

Microinteracciones buenas y consistentes:

- **Pulsación con escala**: 0.98 en `GlassCard`, 0.96 en `RunicButton`, 150 ms
  con `easeInOut`. Es la firma táctil del producto.
- **Aparición de mensajes**: burbujas animadas en la conversación.
- **Recompensa**: `FloatingReward.show` + `AnimatedCounter` (600 ms).

---

## 8. Patrones visuales replicados

| Patrón | Cómo se reconoce en el código | Dónde |
|---|---|---|
| **Superficie de vidrio** | `GlassCard` con blur y borde de acento | 100 usos |
| **Esquinas rúnicas** | `showRunicCorners: true` + 4 marcas de 10×10 con opacidad animada | CTA del dashboard, tarjetas destacadas |
| **Etiqueta HUD** | mono 9–11 px, `letterSpacing` 0.5–2.5, mayúsculas | toda la app |
| **Barra de progreso segmentada** | `SegmentedBar` | splash (14), guardián, sala de voz |
| **Fondo temático por contexto** | `CyberBgMode` (13 modos) | 16 archivos |
| **Glow de acento** | `BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 8…16)` escrito a mano | 44+ sitios |
| **Chip de moneda** | icono 14 + cifra mono 12 + borde del color de la moneda | tienda, wallet |
| **Cabecera "volver + título + acción"** | `Row` con `IconButton` + `Expanded(Text)` | 7 implementaciones |
| **Sheet modal** | `showModalBottomSheet` con `AppColors.surfaceDeep` | 14 llamadas |
| **Mayúsculas forzadas** | `.toUpperCase()` sobre cadenas traducidas | `missions_screen.dart:47`, `shop_screen.dart:636,686`, `system_window.dart:63,74` → rompe acentos y portugués (`UX-33`) |

---

## 9. Contraste (calculado, no observado)

Fórmula idéntica a `app_contrast.dart`. Umbral AA = 4.5 (texto normal) / 3.0
(texto ≥ 18.66 px bold o ≥ 24 px).

### 9.1 Texto sobre superficie

| Primer plano | `voidBg` | `surface` | `containerLow` | `containerHigh` | Veredicto |
|---|---|---|---|---|---|
| `onSurface` `#E1E2ED` | 15.63 | 14.39 | 13.34 | 11.14 | **AAA** |
| `onSurfaceVariant` `#BAC9CC` | 11.80 | 10.87 | 10.07 | 8.41 | **AAA** |
| `outline` `#849396` | 6.32 | 5.82 | 5.40 | **4.51** | AA justo |
| `manaCyan` `#00E5FF` | 13.09 | 12.05 | 11.17 | 9.33 | **AAA** |
| `royalGold` `#FFC700` | 12.87 | 11.85 | 10.98 | 9.17 | **AAA** |
| `emeraldGreen` `#00E676` | 12.06 | 11.11 | 10.29 | 8.60 | **AAA** |
| `errorRed` `#FFB4AB` | 11.86 | 10.92 | — | 8.45 | **AAA** |
| `crimsonRed` `#FF1744` | 5.23 | 4.82 | 4.47 | **3.73** | AA-large |
| `runeViolet` `#9D4EDD` | **4.38** | **4.03** | **3.74** | **3.12** | **falla AA normal** |
| `medievalText` `#D8CBB0` sobre `medievalBg` | 12.02 | — | — | — | **AAA** |
| `medievalTextDim` `#9A8F7A` sobre `medievalBg` | 6.05 | — | — | — | **AA** |

### 9.2 Pares acento/fondo que el código usa de verdad

| Combinación | Ratio | Veredicto | Dónde |
|---|---|---|---|
| `voidBg` sobre `manaCyan` | **13.09** | AAA ✅ | `app_theme.dart:86-87` (botón elevado del tema) |
| **blanco sobre `runeViolet`** | **4.60** | AA ✅ | `runic_button.dart:26` (default correcto tras #241) |
| **`onSurface` sobre `runeViolet`** | **3.57** | **FALLA AA** ❌ | **12 sitios**: `onboarding_screen.dart:536-537`, `session_summary_screen.dart:713-714`, `settings_screen.dart:289-290`, `welcome_screen.dart:309-310, 459-460, 582-583`, `chat_rooms_screen.dart:643-644`, `profile_edit_screen.dart:620-621`, `mini_conversation_screen.dart:460-461`, `progress_tab_view.dart:230-231`, `ai_pick_hero_card.dart:222-223`, `paywall_screen.dart:394-395` |
| `onSurface` sobre `crimsonRed` | **2.99** | **FALLA** ❌ | `settings_screen.dart:1536`, `progress_tab_view.dart:230` |
| blanco sobre `crimsonRed` | **3.85** | FALLA ❌ | `profile_edit_screen.dart:160` |
| `crimsonRed` como texto sobre `containerHigh` | **3.73** | FALLA ❌ | `system_snack.dart:20` (borde) |
| `onSurface` sobre `manaCyan` | **1.19** | FALLA ❌ | riesgo latente (nadie lo usa) |
| blanco sobre `royalGold` (`onSecondary`) | **1.56** | FALLA ❌ | `app_theme.dart:19` (rol sin uso) |
| `blindMagenta` `#FF00FF` sobre `voidBg` | 6.42 | AA ✅ | toggle de chat oculto |

**Conclusión:** la paleta base es excelente (todo AAA). El problema es
**semántico**: dos acentos (`runeViolet`, `crimsonRed`) no sirven como fondo de
texto claro salvo con blanco, y el código todavía usa el par antiguo en 13+
sitios aunque el token `runic_button` ya se corrigió.

### 9.3 Qué sí está protegido

`test/app_contrast_test.dart` fija por test: texto principal sobre fondos base,
acentos sobre `voidBg`, **blanco sobre violeta (UX-02)**, **`voidBg` sobre
carmesí (UX-05)** y **hint al 70 % (UX-18)**. Es decir: el guard cubre los pares
del tema y del botón, **no** los 12 call sites que replican el par fallido.

---

## 10. Lo que se usa vs lo que existe sin usar

| Token / componente | Existe | Se usa | Comentario |
|---|---|---|---|
| `AppColors` (89 tokens) | ✅ | 64 | 25 nunca salen de su archivo |
| `AppTypography` (8 estilos) | ✅ | 114 refs | convive con 384 `GoogleFonts.*` |
| `AppSpacing` | ✅ | **3 usos reales** (todos `AppSpacing.button`) | 419 `EdgeInsets` literales |
| `AppRadius` | ✅ | 68 refs | 177 `BorderRadius.circular` literales |
| `AppElevation` | ✅ | **0** | sombras a mano |
| `AppMotion` | ✅ | 19 refs | 23 controllers con duraciones literales |
| `AppContrast` | ✅ | sólo en tests | no se usa en runtime (correcto) |
| `GlassCard` | ✅ | 100 | identidad del producto |
| `CyberManhwaBackground` | ✅ | 17 | 13 modos |
| `SystemSnack` | ✅ | 48 | pero siguen 52 `SnackBar` crudos |
| `RunicButton` | ✅ | 12 | frente a 20 `ElevatedButton` + 38 `IconButton` + 41 `GestureDetector` + 24 `InkWell` |
| `SystemWindow` | ✅ | 5 | |
| `QuestCard` | ✅ | 3 | duplica `MissionCard` |
| `DraggableMonsterWidget` | ✅ | 1 pantalla | 390 líneas |
| **`HudState`** | ❌ | — | propuesto, no implementado |

### 10.1 Recuento propio del 31-oct (donde no coincide con la tabla anterior)

Se recontaron **sitios de construcción** (`NombreWidget(`), no referencias ni
imports. Donde hay diferencia, este es el número que manda:

| Medida | Tabla anterior | Recuento 31-oct | Comentario |
|---|---|---|---|
| `GlassCard(` | 100 | **100** | coincide |
| `CyberManhwaBackground(` | 17 | **17** | coincide (13 modos, 9 instanciados) |
| `SystemSnack.show` | 48 | **48** | coincide |
| `RunicButton(` | 12 | **12** | coincide |
| `RpgAvatar(` | 9 | **9** | coincide |
| `SegmentedBar(` | 8 | **7** | 7 archivos, 1 por archivo |
| `SystemWindow(` | 5 | **4** | 3 archivos |
| `AnimatedCounter(` | 8 | **2** | sólo 2 sitios lo construyen; el 8 no se reproduce |
| `QuestCard(` | 3 | **2** | |
| `ManaMeterWidget(` | 3 | **2** | |
| `SnackBar(` crudos | 52 | **53** | |
| Referencias a `AppRadius` | 68 | **67** (`sm` 42 · `lg` 20 · `card` 3 · `md` 2) | |

Estas diferencias **no cambian ninguna conclusión** (el patrón «componente
compartido infrautilizado» se mantiene), pero conviene citar el número correcto
en propuestas.

---

## 11. Reglas para no romperlo (derivadas del código)

**Haz:**

1. Toca superficies con `onTap:` **del propio `GlassCard`**; su
   `GestureDetector` interno gana la arena de gestos
   (`glass_card.dart:89-93`; regla repetida en `AGENTS.md`).
2. Usa `AppRadius.sm` (4) para cards/botones/inputs. Es el estándar del producto.
3. Texto sobre violeta: **blanco** (4.60), nunca `onSurface` (3.57).
4. Texto destructivo: `voidBg` sobre `crimsonRed` (5.23) o `errorRed` sobre
   `surfaceContainerHigh` (8.45).
5. Para recompensas: `royalGold` + `AppMotion.reward` (1200 ms) + `curveSpring`.
6. Usa `AppMotion.reduceMotion(context)` en cualquier `repeat()`.

**No hagas:**

1. No escribas `EdgeInsets` numéricos nuevos sin consultar la escala de 4 px
   (30 % de los existentes está fuera de rejilla).
2. No añadas un color literal: el test lo bloquea **si el valor no está en la
   paleta**, pero si está, pasará aunque dupliques el token. Usa el nombre.
3. No uses `SnackBar` directo: usa `SystemSnack` (48 vs 52 hoy).
4. No crees una cabecera con volver nueva: hay 7 y ninguna compartida.
5. No uses emojis como icono de estado: no tienen semántica ni contraste
   garantizado.

---

## 12. Qué no se pudo verificar

> El **inventario de audio de §13 sí está verificado por código** (servicios,
> assets y llamadas). Esta sección lista lo que **no** se pudo comprobar.

1. **Nada visual**: ni jerarquía, ni ritmo vertical, ni alineación óptica, ni
   legibilidad del glow, ni densidad percibida. Sin visión de imágenes ni
   dispositivo.
2. **Contraste sobre fondos animados**: `CyberManhwaBackground` dibuja
   partículas y orbes; los ratios de §9 asumen superficie plana.
3. **Rendimiento de las animaciones**: 23 `AnimationController`, 14 `repeat()`
   y 8 `BackdropFilter` (uno por cada `GlassCard` = hasta 100 instancias) son
   candidatos a jank; **no se perfiló**.
4. **Escalado de texto en dispositivo**: 0 usos de `textScalerOf`; los tests
   cubren 1.5× y 2.0× en 3 pantallas (Welcome, Dashboard, DungeonGuardian).
5. **`AppElevation` como "no usado"**: se verificó por grep de
   `AppElevation.` en `lib/` y `test/`; la única coincidencia es el constructor
   privado.
6. **Tokens de color "no usados"**: el conteo excluye `app_colors.dart`; un
   token podría usarse desde un archivo generado o fuera de `lib/` (no hay
   consumidores fuera de `lib/`).
7. **Audio percibido**: no se escuchó nada (sin dispositivo). Se describe qué
   servicio se invoca, no cómo suena (§13).

---

## 13. Música, sonidos y hápticos (inventario real)

> Esta sección responde a «qué existe de verdad» y no a «qué dice el diseño».
> Todo lo que sigue está en el código; nada se infiere de una captura.

### 13.1 Música

| Aspecto | Realidad | Evidencia |
|---|---|---|
| Archivo | **1**: `assets/music/tavermusic.mp3` (601 920 B ≈ 0,6 MB) | `assets/music/` |
| Empaquetado | sí, `assets/music/` está en `pubspec.yaml:70` | `pubspec.yaml:70` |
| Reproducción | `just_audio` (`AudioPlayer`), **loop infinito** (`LoopMode.one`) | `tavern_music_service.dart:3,65-68` |
| Volumen | **0.15** fijo (no hay control de volumen) | `tavern_music_service.dart:69` |
| Auto-play | **NO**: se enciende a mano para no interferir con el primer render | `tavern_music_service.dart:8-10` |
| Único punto de entrada | atajo **MÚSICA** del Salón del Gremio | `chat_rooms_screen.dart:606-613` |
| Persistencia del estado | sólo en memoria (`_playing`); al matar la app se apaga | `tavern_music_service.dart:20,59` |
| Al salir del gremio | `stop()` al `dispose` de la pantalla | `chat_rooms_screen.dart:170` |
| Ajuste de usuario | **no hay** switch de música en Ajustes (sí de SFX/hápticos) | `settings_screen.dart:1270-1289` |

**Consecuencia:** la música existe, suena en bucle a volumen bajo y **muere al
cambiar de pestaña del dashboard** si el gremio se desmonta. No hay música de
combate, de mazmorra ni de recompensa: una sola pista para todo el juego.

### 13.2 Sonidos

| Tipo | Existe | Detalle | Evidencia |
|---|---|---|---|
| Efectos (SFX) | ❌ **no hay assets** | Cero archivos de efecto en `assets/`. El comentario del servicio lo dice: «No hay assets de audio en el proyecto» | `sensory_feedback.dart:62-63` |
| «Sonido» de celebración | ✅ pero es el **clic del sistema** | `SystemSound.play(SystemSoundType.click)` | `sensory_feedback.dart:89-91` |
| Voz del tutor (TTS) | ✅ | `flutter_tts` en la conversación; velocidad configurable, voz seleccionable | `conversation_providers.dart:116` · `tts_preferences.dart` |
| Voz del listening | ✅ | `flutter_tts` aislado: `en-US`, rate 0.45, volume 1.0, pitch 1.0 | `listening_tts.dart:33-37` |
| Cinemática | ⚠️ asset **fuera del bundle** | `assets/videos/cinematica.mp4` (2,6 MB) no está en `pubspec.yaml` y no se referencia | `assets/videos/` · `pubspec.yaml:63-70` |
| Grabación | ✅ | `record` AAC-LC 128 kbps / 16 kHz (mini-conversación); el pipeline principal usa su propio grabador | `mini_conversation_screen.dart:128-133` |

### 13.3 Hápticos

| Aspecto | Realidad | Evidencia |
|---|---|---|
| Implementación | `HapticFeedback` de Flutter (3 intensidades) | `sensory_feedback.dart:79-88` |
| Intensidades | `heavy` (meta cumplida) · `medium` (subir de nivel) · `selectionClick` (selección/repaso) | `sensory_feedback.dart:33-56,80-87` |
| Eventos definidos | 4: `goalCompleted`, `levelUp`, `reviewCompleted`, `selection` | `sensory_feedback.dart:7` |
| Eventos **disparados** | **2 de 4**: `levelUp` y `goalCompleted` | `hunter_hud_header.dart:182` · `daily_goal_ring_card.dart:67` |
| Eventos muertos | `reviewCompleted` y `selection` se definen y **nunca se emiten** | grep: sólo aparecen en la definición |
| Ajustes | `haptics_enabled` y `sound_enabled` en `user_settings`, con 2 switches | `settings_screen.dart:1270-1289` |
| Permiso Android | no requiere permiso explícito (`VIBRATE` en manifest) | fuera de alcance de este documento `[PENDIENTE DE VALIDAR]` |

**Lectura:** el sistema sensorial está **bien diseñado y poco cableado**. Hay
plan para 4 eventos y ejecución en 2; el usuario puede apagar hápticos y
«sonidos», pero el «sonido» es un clic del sistema, no un diseño sonoro. La
música de taberna es el único audio ambiental y no se puede apagar desde Ajustes.

> **Contradicción de producto:** Ajustes dice «Sonido del sistema en las
> celebraciones» y la música de la taberna **no** aparece en Ajustes. Un usuario
> que busca silenciar la taberna no tiene interruptor: debe volver al gremio y
> pulsar MÚSICA.

### 13.4 Lo que **no** existe (y se suele suponer)

| Suposición habitual | Realidad |
|---|---|
| Música por escena/mazmorra | ❌ una sola pista, sólo en el gremio |
| SFX de monedas/cofres/nivel | ❌ el clic del sistema |
| Voz del tutor en el resumen de sesión | ❌ no hay TTS en `/summary` |
| Narración de la intro del Oráculo | ⚠️ depende del primer turno del LLM; no hay audio pregrabado `[PENDIENTE DE VALIDAR]` |
| Vibración en acierto de quiz (listening) | ❌ no se dispara `SensoryEvent` en `/listening` |
| Control de volumen general | ❌ no existe |
