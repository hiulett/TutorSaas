# 03 — Auditoría UX/UI

**Base:** `origin/master` @ `f9cffb2` · **Fecha:** 30-oct-2026
**Método:** código + cálculo WCAG + 725 tests. **Sin inspección visual** (§9).

Severidad: **CRÍTICO** (bloquea o discrimina) · **ALTO** (degrada tarea
principal) · **MEDIO** (inconsistencia visible) · **BAJO** (pulido).

---

## 1. Contraste real (WCAG 2.1)

Fórmula usada (una línea): para cada canal `c ∈ {R,G,B}` normalizado a `[0,1]`,
`c_lin = c/12.92` si `c ≤ 0.03928`, si no `((c+0.055)/1.055)^2.4`;
`L = 0.2126·R_lin + 0.7152·G_lin + 0.0722·B_lin`;
`ratio = (L_claro + 0.05) / (L_oscuro + 0.05)`.
Umbrales: **AA** 4.5 (texto normal) / 3.0 (≥24 px o ≥18.66 px bold); **AAA** 7.0 / 4.5.

`glass` se calculó como `surface #11131B` al 94 % sobre `voidBg #05070E`
(composición α), que es lo que hace `glass_card.dart:109`
(`surfaceGlass.withValues(alpha: 0.94)`).

### 1.1 Texto sobre superficies (ratios calculados)

| Primer plano | voidBg `#05070E` | surface `#11131B` | containerLow `#191B23` | containerHigh `#272A32` | glass (94 %) | Peor veredicto |
|---|---|---|---|---|---|---|
| `onSurface` `#E1E2ED` | 15.63 | 14.39 | 13.34 | 11.14 | 14.48 | **AAA** |
| `onSurfaceVariant` `#BAC9CC` | 11.80 | 10.87 | 10.07 | 8.41 | 10.94 | **AAA** |
| `outline` `#849396` | 6.32 | 5.82 | 5.40 | 4.51 | 5.86 | **AA** (justo en containerHigh) |
| `manaCyan` `#00E5FF` | 13.09 | 12.05 | 11.17 | 9.33 | 12.12 | **AAA** |
| `royalGold` `#FFC700` | 12.87 | 11.85 | 10.98 | 9.17 | 11.92 | **AAA** |
| `emeraldGreen` `#00E676` | 12.06 | 11.11 | 10.29 | 8.60 | 11.17 | **AAA** |
| `crimsonRed` `#FF1744` | 5.23 | 4.82 | 4.47 | **3.73** | 4.85 | **AA-large** (falla AA normal en containerLow/High) |
| `runeViolet` `#9D4EDD` | 4.38 | 4.03 | **3.74** | **3.12** | 4.06 | **AA-large** (falla AA normal en todas las superficies) |
| `errorRed` `#FFB4AB` | 11.86 | 10.92 | — | 8.45 | — | **AAA** |

**Lectura:** la paleta base es excelente. El problema está en **dos acentos**
(`runeViolet`, `crimsonRed`) cuando se usan como **texto**, y en los **textos con
alfa**.

### 1.2 Rellenos de acento con su texto (los pares que el código usa de verdad)

| Combinación | Dónde | Ratio | Veredicto |
|---|---|---|---|
| `voidBg` sobre `manaCyan` (CTA primario del tema) | `app_theme.dart:86-87` | **13.09** | AAA ✅ |
| `voidBg` sobre `royalGold` | `system_snack.dart:23` (borde), badges | **12.87** | AAA ✅ |
| `voidBg` sobre `emeraldGreen` | botones de éxito | **12.06** | AAA ✅ |
| **`onSurface` sobre `runeViolet`** | **`runic_button.dart:24-25` (default)**, `chat_rooms_screen.dart:452,643-644` | **3.57** | **FALLA AA** (16 px bold < 18.66 px) ❌ |
| **`onSurface` sobre `crimsonRed`** | `settings_screen.dart:1536-1537` (borrar cuenta), `progress_tab_view.dart:230-231` | **2.99** | **FALLA AA** ❌ |
| **blanco sobre `runeViolet`** | pareja recomendada en `04` §2.3 (hoy no se usa) | **4.60** | AA ✅ (única pareja válida sobre violeta) |
| **blanco sobre `crimsonRed`** | `profile_edit_screen.dart:160` (SnackBar) | **3.85** | FALLA AA ❌ |
| **blanco sobre `royalGold`** (`colorScheme.onSecondary`) | `app_theme.dart:19` | **1.56** | **FALLA incluso AA-large** ❌ (hoy sin uso directo) |
| `onSurfaceVariant` al 50 % sobre `containerLow` (hint de inputs) | `app_theme.dart:132` | **3.50** | FALLA AA ❌ |
| `onSurface` al 25 % sobre `voidBg` | `splash_screen.dart:147` | **1.88** | FALLA ❌ (texto decorativo) |
| `onSurface` al 70 % sobre `voidBg` | `configuration_error_widget.dart:55` | **7.77** | AAA ✅ |

### 1.3 Hallazgos de contraste

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| C-01 | **CRÍTICO** | El botón primario por defecto (`RunicButton`, violeta + texto claro) no alcanza AA: 3.57 | `runic_button.dart:13-25` |
| C-02 | **ALTO** | Botones destructivos (borrar cuenta, reiniciar progreso) usan carmesí con `onSurface`: **2.99** (con blanco sería 3.85; tampoco pasa) | `settings_screen.dart:1536-1537`, `progress_tab_view.dart:230-231` |
| C-03 | **ALTO** | `runeViolet` como color de texto falla AA en todas las superficies (3.12–4.38) | `chat_rooms_screen.dart:886`, `boss_exam_result_screen.dart:333`, `profile_edit_screen.dart` (labels violeta) |
| C-04 | MEDIO | Hint de inputs al 50 %: 3.50 | `app_theme.dart:128-150` |
| C-05 | MEDIO | `onSecondary` blanco sobre dorado: 1.56; hoy sin uso, pero es un rol del `ColorScheme` listo para romperse | `app_theme.dart:19` |
| C-06 | BAJO | `crimsonRed` como texto en `containerHigh` cae a 3.73 | `system_snack.dart:20` (borde), textos de error que usan `crimsonRed` |

---

## 2. Tipografía

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| T-01 | **ALTO** | **31 tamaños distintos** de `fontSize` (7 a 48 px) para 3 familias; no hay escala | histograma en `01` §1.3 |
| T-02 | **ALTO** | 243 declaraciones < 12 px (40 %), con **7 px** reales | `chat_rooms_screen.dart:1063`, `voice_room_screen.dart:914` |
| T-03 | **ALTO** | La tipografía se escribe a mano: **384** `GoogleFonts.*` vs **114** `AppTypography.*`; 0 usos de `Theme.of(context).textTheme` salvo 4 | conteo en `01` §1.1 |
| T-04 | MEDIO | 4 estilos del `TextTheme` en Roboto (no empaquetada) | `app_theme.dart:22-83` vs `design_tokens_test.dart:238-261` (deuda fijada) |
| T-05 | MEDIO | `AppTypography` no cubre los tamaños que la app usa (crea 26/18/15/14/13/11/12/9): faltan 20, 16, 12 y 10 con semántica | `app_typography.dart:14-66` |
| T-06 | BAJO | Mayúsculas forzadas con `.toUpperCase()` en titulares y etiquetas, incluidas cadenas localizadas (rompe acentos/pt) | `system_window.dart:63,74`, `shop_screen.dart:686,697`, `quest_card.dart:88` |

> T-04 no es visible hoy porque nadie usa esos 4 estilos; se documenta como
> **riesgo latente** y se resuelve en `04` §3.

---

## 3. Espaciado, radios y elevación

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| S-01 | **CRÍTICO** | `AppSpacing` tiene **3 usos** reales frente a **419** `EdgeInsets` literales | `app_spacing.dart:12-33`; usos en `app_theme.dart:96,111,125` |
| S-02 | **ALTO** | **30 %** de los valores de padding están fuera de la rejilla de 4 (2,3,5,6,7,10,11,14,18,26,30,58) | cálculo en `01` §1.2 |
| S-03 | MEDIO | Radios: 68 usos de `AppRadius`, pero persisten `BorderRadius.circular(1.5)` (barra) y `circular(999)` manuales | `segmented_bar.dart:33`, `glass_card.dart:103` |
| S-04 | MEDIO | `AppElevation` **no se usa nunca**; las sombras se escriben a mano (p. ej. glow cian en `GlassCard`) | `app_elevation.dart:4-23`; `glass_card.dart:100` |
| S-05 | BAJO | `GlassCard` mezcla opacidades 0.94/0.95/0.96 en la misma pantalla | `dungeon_guardian_screen.dart:424,495,574` |
| S-06 | BAJO | Padding por defecto de `GlassCard` (24) distinto del preset `AppSpacing.card` (16) | `glass_card.dart:107` vs `app_spacing.dart:27` |

---

## 4. Componentes: inventario, duplicaciones e inconsistencias

### 4.1 Biblioteca real

`lib/core/widgets/` — 14 archivos:

| Widget | Líneas | Usos | Rol | Estado |
|---|---|---|---|---|
| `GlassCard` | 134 | **100** (41 archivos) | Superficie única (blur + borde + esquinas rúnicas) | ✅ Identidad fuerte |
| `CyberManhwaBackground` | 327 | 20 (15 archivos) | Fondo animado | ✅ |
| `SystemSnack` | 45 | 48 | Notificaciones con acento semántico | ⚠️ convive con 4 `SnackBar` crudos |
| `RpgAvatar` | 187 | 11 | Avatar por clase | ✅ |
| `RunicButton` | 133 | 12 (5 archivos) | Botón primario | ⚠️ infrautilizado; contraste C-01 |
| `FloatingReward` | 136 | 10 | Recompensa flotante | ✅ |
| `SegmentedBar` | 36 | 8 | Progreso por segmentos | ✅ (único pixel-golden) |
| `AnimatedCounter` | 60 | 6 | Números animados | ✅ |
| `SystemWindow` | 107 | 5 | Ventana HUD con cabecera | ✅ |
| `QuestCard` | 157 | 3 | Tarjeta de misión | ⚠️ duplica `MissionCard` |
| `ManaMeterWidget` | 84 | 2 | Medidor de maná | ✅ |
| `ConfigurationErrorWidget` | 61 | 2 | Error de arranque | ✅ |
| `DraggableMonsterWidget` | 390 | 1 (conversación) | Monstruo arrastrable | ⚠️ 390 líneas para 1 uso |
| `glass_card.dart` (helpers) | — | — | — | — |

Además **38 widgets de feature** en 11 carpetas `presentation/widgets/`. Total
~52 componentes sin catálogo, sin barrel export y sin galería: la única red de
seguridad visual es 1 golden de píxeles (`segmented_bar.png`) y 3 tests
estructurales (`glass_card_test.dart`, `rpg_chips_test.dart`, `design_tokens_test.dart`).

### 4.2 Duplicaciones reales (mismo componente, dos implementaciones)

| Componente | Implementación A | Implementación B | Diferencia |
|---|---|---|---|
| `_SectionHeader` | `my_errors_screen.dart:149` (icono + color por tipo) | `settings_screen.dart:1595` (solo texto mono cian) | tipografía y estructura distintas |
| `_RoundIconButton` | `session_summary_screen.dart:1038` (40 por defecto, 24 en uso) | `dungeon_guardian_screen.dart:740` (40 fijo) | tamaño no parametrizable en B |
| `_RewardChip` | `session_summary_screen.dart:1206` | `mission_card.dart:396` | dos estilos de "recompensa" |
| `_ErrorState` | `my_errors_screen.dart:323` | `weekly_report_screen.dart:627` | copy y layout propios |
| `_GlowOrb` | `splash_screen.dart:247` | `dungeon_guardian_screen.dart:650` | duplicado literal |
| Métrica/tile | `weekly_report_card.dart:151` (`_Metric`) | `weekly_report_screen.dart:536` (`_StatTile`) | mismo dato, dos cajas |
| Cabecera con "volver" | 7 implementaciones a mano (`missions_screen.dart:82`, `my_errors_screen.dart:35`, `weekly_report_screen.dart:38`, `inventory_screen.dart:110`, `shop_screen.dart:365`, `profile_edit_screen.dart:267`, `session_summary_screen.dart:140`) | — | 2 glifos, 4 tamaños, 1 tooltip |

### 4.3 Inconsistencias de sistema

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| K-01 | **ALTO** | Dos sistemas de botón: `RunicButton` (12 usos) vs `ElevatedButton` (20) + `IconButton` (38) + `GestureDetector` (41) + `InkWell` (24) | conteo `lib/` |
| K-02 | **ALTO** | Notificaciones: 48 `SystemSnack.show` vs **30 `SnackBar` crudos en `welcome_screen.dart`** (+6 perfil, +6 misión, +4 ajustes) | `welcome_screen.dart:303,336,596,613…` |
| K-03 | **ALTO** | `MissionCard` (feature) y `QuestCard` (core) representan misiones con lenguajes distintos | `quest_card.dart:7-164`, `mission_card.dart:44-540` |
| K-04 | MEDIO | `GlassCard` acepta `borderRadius` y `opacity` ad hoc: 7 overrides, rompen la identidad | `conversation_screen.dart:516,1027,2175`, `dungeon_guardian_screen.dart:424,495,574` |
| K-05 | MEDIO | El cierre de sheets/diálogos no comparte patrón (10 `showModalBottomSheet`, 1 `showDialog`, 1 `DraggableScrollableSheet`) | conteo + `daily_reward_modal.dart`, `help_phrases_sheet.dart` |
| K-06 | BAJO | Color fuera de paleta en pantalla no medieval: `medievalText` como color de icono de volver | `my_errors_screen.dart:43` |

---

## 5. Accesibilidad por código

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| A-01 | **CRÍTICO** | **Tamaños táctiles < 48 dp**: botones de cerrar/siguiente del resumen **24×24**; `_RoundIconButton` 40; volver de guardián 40; volver de perfil 44; botones de resultado de jefe 46 de alto; tienda 48×**40** | `session_summary_screen.dart:524-530,544-550`; `:1045-1051`; `dungeon_guardian_screen.dart:752-760`; `profile_edit_screen.dart:282-285`; `boss_exam_result_screen.dart:129,141`; `shop_screen.dart:559` |
| A-02 | **CRÍTICO** | **12 de 14 animaciones infinitas** (`repeat()`) no respetan reduce-motion; solo `RunicButton` y `DungeonGuardianScreen` consultan `disableAnimationsOf` (2 puntos en todo `lib/`) | `glass_card.dart:60`; `cyber_manhwa_background.dart:55,60,65,70`; `draggable_monster_widget.dart:46,52,58,64`; `voice_waveform_visualizer.dart:30`; `learning_path_roadmap.dart:553,561`; gates en `runic_button.dart:67`, `dungeon_guardian_screen.dart:44-47` |
| A-03 | **ALTO** | Solo **5 `Semantics(` reales** en 20 pantallas (más 4 `ExcludeSemantics` de decoración): botón de mic, chip de corrección, anillo de meta, `RunicButton`, `GlassCard.semanticLabel` | `conversation_mic_button.dart:167`, `correction_chip.dart:44`, `daily_goal_ring_card.dart:98`, `runic_button.dart:72`, `glass_card.dart:118-124` |
| A-04 | **ALTO** | El botón de micrófono con hold-to-talk se activa por `Listener`/puntero; expone `Semantics(button: true)` **sin acción** `onTap`/`onLongPress` | `conversation_mic_button.dart:160-172` |
| A-05 | **ALTO** | Botones de volver sin etiqueta: solo `missions_screen.dart` pone `tooltip`; el resto son `InkWell`/`IconButton` con `Icon` sin `semanticLabel` | `missions_screen.dart:106` vs `profile_edit_screen.dart:274-287`, `dungeon_guardian_screen.dart:750-760` |
| A-06 | **ALTO** | **No hay `MediaQuery.textScalerOf` ni clamp** en toda la app (0 usos): el texto puede escalar sin límite y solo 3 pantallas están probadas | conteo `textScalerOf` = 0; `test/text_scale_test.dart` |
| A-07 | MEDIO | `Tooltip` solo en 6 sitios; iconos sin texto (monedas, stats, HUD) no se explican | conteo `Tooltip(` = 6 |
| A-08 | MEDIO | Contraste C-01…C-05 afecta a lectores de baja visión y exteriores | §1 |
| A-09 | MEDIO | El dock del dashboard (4 destinos) no declara `Semantics(selected:)` ni rol de tab | `dashboard_screen.dart:617-660` |
| A-10 | BAJO | `ExcludeSemantics` global en tests de overflow oculta problemas de semántica en CI | `overflow_test.dart:108,193,239,304` |

**No verificable sin dispositivo/lector:** orden de foco de TalkBack, anuncios de
cambio de estado, activación por switch access, y si el escalado 2× rompe
pantallas no cubiertas. Requiere prueba manual con TalkBack y "Escala de fuente"
del sistema.

---

## 6. Responsive y escalado de texto

### 6.1 Lo que demuestran los tests

| Test | Umbral | Pantallas/widgets cubiertos | Qué falla si rompe |
|---|---|---|---|
| `test/overflow_test.dart` | **312×800** (`:33,82,135`) y **312×576** (`:213,261`) | `LeagueLeaderboardWidget`, `DashboardScreen`, `ChatRoomsScreen`, `WelcomeScreen`, `DungeonGuardianScreen` | `RenderFlex overflowed` |
| `test/text_scale_test.dart` | **1.5×** a 360×800 (`:31`) | Welcome, Dashboard, DungeonGuardian | overflow con `textScaler` |
| `test/text_scale_test.dart` | **2.0×** | Welcome, DungeonGuardian (**no** Dashboard) | idem |
| `test/shop_screen_test.dart:171` | 312 dp | Shop | overflow |
| `test/golden/segmented_bar_test.dart` | 400×300 fijo | `SegmentedBar` | píxeles |

### 6.2 Cobertura real: 5 de 20 pantallas (25 %)

| Cubierta a 312 px | Cubierta a textScaler 1.5× | Cubierta a 2.0× |
|---|---|---|
| Dashboard, ChatRooms, Welcome, DungeonGuardian, Shop | Welcome, Dashboard, DungeonGuardian | Welcome, DungeonGuardian |

**Sin ninguna prueba de layout:** Splash, Onboarding, MiniConversation,
**Conversation**, SessionSummary, Paywall, ProfileEdit, VoiceRoom, Inventory,
BossExamResult, MyErrors, WeeklyReport, ListeningQuiz, Missions, Settings
(15 pantallas). Especialmente grave en Conversación (2 281 líneas, UI de voz) y
en SessionSummary (1 238 líneas) — ver R-02.

### 6.3 Hallazgos responsive

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| R-01 | **ALTO** | Solo 25 % de pantallas probadas a 312 px y 15 % a 2×; las más grandes no tienen red | §6.2 |
| R-02 | **ALTO** | La pantalla de conversación fija anchos por porcentaje y alturas absolutas (85 %, 78 %) sin `LayoutBuilder` | `conversation_screen.dart:897,1622,1657` |
| R-03 | MEDIO | Solo 2 `LayoutBuilder` en toda la app y **0** usos de `constraints.maxWidth`: no hay adaptación a tablet/plegable ni a landscape | conteo |
| R-04 | MEDIO | No se bloquea orientación (`SystemChrome` = 0): landscape queda sin diseño específico | conteo |
| R-05 | BAJO | `ChatRoomsScreen` no envuelve en `SafeArea` (0 usos) pese a tener `TabBar` y listas | `chat_rooms_screen.dart` |

---

## 7. Estados y flujos

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| E-01 | **ALTO** | La tienda pinta un **error de red como tienda vacía** ("AÚN NO HAY OBJETOS"): no distingue fallo de catálogo vacío | `shop_screen.dart:657-665` |
| E-02 | **ALTO** | El dashboard dice "Mostrando el ultimo progreso guardado" en la rama `hasError && !hasValue`, donde **no hay progreso guardado** que mostrar | `dashboard_screen.dart:194-213` |
| E-03 | MEDIO | 4 pantallas con `context.pop()` sin fallback → sin salida si se entra por enlace | §N-02 de `02` |
| E-04 | MEDIO | El dashboard no tiene refresco por gesto; el resto de listas tampoco salvo Guild (`RefreshIndicator` = 1 en 20 pantallas) | `chat_rooms_screen.dart` |
| E-05 | MEDIO | `SettingsScreen` carga sin estado de carga/error de página (solo spinner de guardado) | `settings_screen.dart:300` |
| E-06 | MEDIO | El resumen de sesión sí distingue loading/error/pendiente (bien) pero no tiene test que lo fije | `session_summary_screen.dart:639-660` |
| E-07 | BAJO | El splash no expone error si el warm-up falla: navega igual (decisión deliberada, pero invisible para soporte) | `splash_screen.dart:70-120` |

**Estados que sí están bien resueltos** (para no perderlo en el rediseño):
MyErrors (`:77-93`), WeeklyReport (`:83-132`), ListeningQuiz (`:244-258`),
Inventory (`:194-217`), Missions (`:154-214`), SessionSummary (`:358-660`).

---

## 8. i18n y contenido

| ID | Sev. | Hallazgo | Evidencia |
|---|---|---|---|
| L-01 | MEDIO | **369** fallbacks `l10n?.clave ?? 'TEXTO'` con el texto en español hardcodeado; si falta la localización, el usuario EN/PT ve español | conteo `l10n?.… ??` |
| L-02 | MEDIO | 8 textos sin localizar, incluida la lista de idiomas del perfil | `profile_edit_screen.dart:523-527`, `conversation_screen.dart:1733,1745` |
| L-03 | BAJO | `.toUpperCase()` sobre cadenas traducidas (rompe acentos y portugués) | `system_window.dart:63`, `shop_screen.dart:686` |
| L-04 | ✅ | Cobertura de claves: **1 292 en en/es/pt, 0 faltantes** | verificado con script sobre los `.arb` |

---

## 9. Qué NO se puede afirmar desde este entorno

1. **Nada visual**: jerarquía, ritmo, alineación óptica, legibilidad del glow,
   densidad percibida, calidad de las animaciones. Requiere revisión humana.
2. **Nada de la captura `01-arranque.png`**: el archivo no es un PNG válido
   (`01` §5).
3. **TalkBack real**: foco, orden, anuncios y activación por switch.
4. **Rendimiento percibido**: 23 `AnimationController`, 14 `repeat()` infinitos,
   8 `BackdropFilter` en código (uno dentro de `GlassCard`, instanciado 100
   veces) son candidatos a jank, pero sin perfilado en dispositivo no se afirma.
5. **Contraste sobre fondos animados/fotográficos** (`CyberManhwaBackground`
   dibuja partículas y orbes): el ratio calculado asume superficie plana.

---

## 10. Resumen cuantitativo de hallazgos

| Severidad | Nº | IDs |
|---|---|---|
| CRÍTICO | **4** | C-01, S-01, A-01, A-02 |
| ALTO | **17** | C-02, C-03, T-01, T-02, T-03, S-02, K-01, K-02, K-03, A-03, A-04, A-05, A-06, R-01, R-02, E-01, E-02 |
| MEDIO | **19** | C-04, C-05, T-04, T-05, S-03, S-04, K-04, K-05, A-07, A-08, A-09, R-03, R-04, E-03, E-04, E-05, E-06, L-01, L-02 |
| BAJO | **9** | C-06, T-06, S-05, S-06, K-06, A-10, R-05, E-07, L-03 |
| **Total** | **49** | — |

El backlog `06` los agrupa en 39 entradas accionables (varios hallazgos comparten
arreglo) con ID, complejidad y archivos.
