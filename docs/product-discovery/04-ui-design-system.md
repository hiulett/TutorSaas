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
| No mide `EdgeInsets` | 419 `EdgeInsets.*` frente a **4** referencias a `AppSpacing` | ver §5 |
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
| Cian (primario) | `manaCyan #00E5FF`, `manaCyanDim #00DAF3`, `manaCyanLight #9CF0FF`, `manaCyanText #C3F5FF` | `manaCyan` es el acento dominante (bordes, labels, CTAs del tema); los otros 3 **sin uso** |
| Dorado (recompensa) | `royalGold #FFC700`, `royalGoldDim #F5BF00`, `royalGoldLight #FFDF94` | `royalGold` en recompensas y avisos; los otros 2 **sin uso** |
| Violeta (secundario/mágico) | `runeViolet #9D4EDD`, `runeVioletContainer #E6C3FF`, `runeVioletText #F8E7FF` | `runeViolet` en botones primarios/acentos; `runeVioletText` aparece tras UX-05; `Container` **sin uso** |
| Verde | `emeraldGreen #00E676`, `emeraldGreenDim #3CDDC7`, `successGreen #00E676` | `emeraldGreen` en éxito; los otros 2 **sin uso** |
| Rojo | `crimsonRed #FF1744`, `errorRed #FFB4AB`, `errorContainer #93000A` | `crimsonRed` en errores/destructivos (contraste bajo, §10); `errorRed` en texto de error |
| Texto | `onBackground` = `onSurface` `#E1E2ED`, `onSurfaceVariant #BAC9CC` | dos niveles de texto |
| Bordes | `outline #849396`, `outlineVariant #3B494C` | |
| CEFR | `cefrPreA1…cefrC2` (7) | mapa de mazmorras |
| Rareza | `rarityCommon…rarityLegendary` (5) | **5 sin uso** fuera de la definición |
| Medieval | `medievalBg/Stone/Iron/DarkWood/AgedGold/AgedGoldDim/AgedGoldLight/MagicBlue/ArcanePurple/BloodRed/Text/TextDim` (12) | sólo `Bg`, `AgedGold`, `Text`, `TextDim` se usan; **5 sin uso** |

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

`AppTypography` **no** cubre los cuerpos 16/20/22/24/12/10 con semántica; por eso
las pantallas escriben `GoogleFonts.*` a mano.

### 3.3 La escala real (medida hoy)

| Métrica | Valor | Fuente |
|---|---|---|
| Referencias a `AppTypography.*` | **114** | grep |
| Referencias a `GoogleFonts.*` | **384** (353 fuera de `core/theme`) | grep |
| `fontSize` literales en `lib/` | **536** usos | grep |
| … excluyendo `core/theme` | **508** usos en **21 tamaños distintos** | grep |
| Usos por debajo de 12 px | **225** (9 px = 47, 10 px = 82, 11 px = 91, 8 px = 17, 7 px = 2) | histograma |
| Tamaño mínimo real | **7 px** (2 usos) | histograma |
| Fracciones raras | 11.5 px, 12.5 px | histograma |

Distribución completa (sin `core/theme`):

```
 7 → 2     8 → 17    9 → 47   10 → 82   11 → 91   12 → 99   13 → 50
14 → 18   15 → 26   16 → 30   17 → 2    18 → 24   20 → 8    22 → 2
24 → 2    28 → 1    32 → 2    40 → 1
```

**Diagnóstico.** El sistema existe (114 usos) pero **convive con 508 decisiones
ad-hoc**. El 44 % del texto de la app está por debajo de 12 px. La buena noticia:
el número de tamaños bajó de 31 (auditoría) a 21, y el mínimo ya no domina.

### 3.4 `TextTheme` del tema y el hueco de Roboto

`app_theme.dart:22-83` define 12 estilos. Cuatro **no** se asignan y caen al
`TextTheme` por defecto (Roboto, **no empaquetada**): `headlineSmall`,
`titleSmall`, `bodySmall`, `labelSmall`.

Hoy nadie los usa (0 llamadas a `Theme.of(context).textTheme.bodySmall`), así que
el riesgo es **latente**, no visible. Si una pantalla futura los usa, se rompe la
identidad tipográfica sin fallar ningún test.

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

### 4.2 Espaciado (`AppSpacing`)

Escala de 4 px: `xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32 ·
huge 48`, más presets `screen`, `card`, `compact`, `button`.

| Métrica | Valor |
|---|---|
| Referencias a `AppSpacing.*` | **4** en total; **3** son `AppSpacing.button` dentro de `app_theme.dart:96, 111, 125` y **1** es la definición |
| `EdgeInsets.*` literales | **419** |
| Presets `screen`/`card`/`compact` usados | **0** |

Es el hallazgo más duro del sistema: **la escala de espaciado no se usa**. El
`GlassCard` usa `EdgeInsets.all(24)` por defecto (`glass_card.dart:107`)
mientras el preset equivalente (`AppSpacing.card`) es 16.

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
| **`onSurface` sobre `runeViolet`** | **3.57** | **FALLA AA** ❌ | **13 sitios**: `onboarding_screen.dart:536-537`, `session_summary_screen.dart:713-714`, `settings_screen.dart:289-290`, `welcome_screen.dart:309-310, 459-460, 582-583`, `chat_rooms_screen.dart:643-644`, `profile_edit_screen.dart:620-621`, `mini_conversation_screen.dart:460-461`, `progress_tab_view.dart:230-231`, `ai_pick_hero_card.dart:222-223`, `paywall_screen.dart:394-395`, `welcome_back_card.dart:155,174` |
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
del tema y del botón, **no** los 13 call sites que replican el par fallido.

---

## 10. Lo que se usa vs lo que existe sin usar

| Token / componente | Existe | Se usa | Comentario |
|---|---|---|---|
| `AppColors` (89 tokens) | ✅ | 64 | 25 nunca salen de su archivo |
| `AppTypography` (8 estilos) | ✅ | 114 refs | convive con 384 `GoogleFonts.*` |
| `AppSpacing` | ✅ | **4 refs (3 reales)** | 419 `EdgeInsets` literales |
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
