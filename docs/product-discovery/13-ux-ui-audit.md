# 13 — Auditoría UX/UI · Parte D (jerarquía, contraste, tacto, estados, a11y)

> **Este documento no sustituye la auditoría.** La auditoría completa (49
> hallazgos, 39 entradas de backlog) vive en `docs/ui-ux-audit/`. Aquí se
> **verifica contra el código de hoy** qué sigue siendo cierto, se calculan los
> ratios y se marca lo que sólo puede cerrarse en dispositivo.
>
> | Documento | Contenido |
> |---|---|
> | `docs/ui-ux-audit/01-project-analysis.md` | conteos de código, tipografía, espaciado |
> | `docs/ui-ux-audit/02-screen-inventory.md` | inventario de pantallas |
> | **`docs/ui-ux-audit/03-ux-ui-audit.md`** | **los 49 hallazgos con evidencia (C-, T-, K-, A-)** |
> | `docs/ui-ux-audit/04-design-system-proposal.md` | propuesta de sistema |
> | `docs/ui-ux-audit/05-redesign-proposals.md` | propuestas de rediseño |
> | **`docs/ui-ux-audit/06-improvement-backlog.md`** | **UX-01…UX-39** (fuente de los issues #240–#261) |
> | `docs/ui-ux-audit/07-executive-summary.md` | resumen ejecutivo |
> | `docs/ui-ux-audit/screenshots/README.md` | método de captura y nombres |
> | **`docs/product-discovery/23-visual-validation-checklist.md`** | **checklist ejecutable de la validación humana (D-13)** |
>
> Épica: **#239**. Hijos: **#240–#261**.

## Aviso metodológico

Medido el **31-oct-2026** sobre el worktree `p14-ai-usage` (base `origin/master`).
Todo lo que sigue se sostiene en: (a) lectura de widgets y tokens, (b)
**contrastes calculados** con la fórmula WCAG 2.1 que implementa
`lib/core/theme/app_contrast.dart:19-36`, (c) conteos sobre `lib/` y `test/`.

**No hay visión de imágenes y no hay dispositivo conectado.** Por eso no se
emite juicio visual (jerarquía percibida, ritmo, alineación óptica, calidad del
glow, animación): eso queda como `[PENDIENTE DE VALIDAR]` y se resuelve con
`23-visual-validation-checklist.md` (D-13).

**Estado de los issues:** la columna «GitHub» es la del **cierre de la
auditoría** (4 cerrados / 18 abiertos); no se reconsultó la API en esta sesión.
La columna «¿Vive la corrección?» es la **verificación en código** de hoy, que es
lo que el cierre debía garantizar.

---

## 1. Jerarquía visual

### 1.1 Medición objetiva (lo que sí se puede afirmar)

| ID | Hecho medido | Valor | Evidencia |
|---|---|---|---|
| J-01 | **No existe cabecera compartida** | 1 `AppBar(` en 24 `Scaffold(`; 14 archivos dibujan su propio «volver» a mano | `lib/core/widgets/` (14 archivos, ninguno de cabecera); conteo de `arrow_back` en `lib/` |
| J-02 | **Cuatro tratamientos distintos del mismo control** | icono 18 vs 24 · color `onSurface` vs `medievalText` · padding `12/12/20/8` vs `24/16` vs `16/12/0` · tooltip sí/no | `my_errors_screen.dart:39-47` · `weekly_report_screen.dart:45-53` · `inventory_screen.dart:117-123` · `shop_screen.dart:372-378` |
| J-03 | **20 pantallas, 6,35 niveles tipográficos de media; máximo 11** | `chat_rooms` 11 · `conversation` 10 · `dungeon_guardian` 10 · `settings` 9 · `dashboard`/`voice_room`/`shop` 8 · `summary`/`mini_conversation` 2 | conteo de `fontSize:` por `*_screen.dart` |
| J-04 | **El `TextTheme` se usa 4 veces en toda la app** | 5 referencias a `textTheme`, 1 es la definición | `app_theme.dart:22` (def.) · usos en `configuration_error_widget.dart:28`, `conversation_screen.dart:1234`, `ai_pick_hero_card.dart:155`, `learning_path_roadmap.dart:242` |
| J-05 | **Dos sistemas de superficie** | `GlassCard` **100** usos vs `SystemWindow` **4**; además 172 `BoxDecoration(` a mano | conteo `lib/`; `quest_card.dart`, `system_window.dart` |
| J-06 | **La elevación no existe como lenguaje** | `AppElevation` declarado, **0 usos** | `core/theme/app_elevation.dart:4-5` |
| J-07 | **Títulos por «más negrita»**: 23 `FontWeight.w900` y 133 `letterSpacing` sueltos | — | conteo `lib/` |

**Lectura:** la app tiene identidad (vidrio + esquinas rúnicas + mono para
etiquetas), pero **no tiene gramática de jerarquía**: cada pantalla decide
tamaños (J-03), la cabecera se reescribe (J-01/J-02) y el `TextTheme` se ignora
(J-04). Los elementos que compiten en la misma pantalla usan escalas continuas
(7, 8, 9, 10, 11, 11.5, 12, 12.5, 13, 14, 15, 16, 17, 18, 20, 22, 24, 26, 28,
32, 40, 48) en lugar de 4–5 roles.

### 1.2 Lo que no se puede afirmar

`[PENDIENTE DE VALIDAR]` — si el ojo encuentra el CTA en < 2 s en cada pantalla,
si el HUD superior (avatar + nombre + nivel + maná) domina sobre el contenido, si
la densidad de `chat_rooms` (11 niveles) se lee o se ve como ruido. Requiere
captura + revisión humana (ítems V-01…V-20 del checklist).

---

## 2. Contraste (ratios WCAG calculados)

Fórmula: `app_contrast.dart:19-36`. Umbral AA texto normal **4.5**, texto grande
**3.0** (≥ 24 px, o ≥ 18.66 px en negrita), **3.0** para componentes/bordes
(1.4.11).

### 2.1 Pares que el tema usa de verdad — todos pasan

| Par | Ratio | Veredicto | Dónde |
|---|---|---|---|
| `onSurface` `#E1E2ED` / `voidBg` `#05070E` | **15.63** | AAA | texto base |
| `onSurface` / `surface` `#11131B` | **14.39** | AAA | texto sobre tarjeta |
| `onSurfaceVariant` `#BAC9CC` / `surface` | **10.87** | AAA | copy secundario (`bodyMedium`) |
| `onSurfaceVariant` / `surfaceContainerLow` `#191B23` | **10.07** | AAA | dentro de tarjetas |
| `outline` `#849396` / `surface` | **5.82** | AA | `labelLarge/Medium` |
| `manaCyan` `#00E5FF` / `surface` | **12.05** | AAA | acentos, títulos de estado |
| `royalGold` `#FFC700` / `surface` | **11.85** | AAA | recompensas |
| `emeraldGreen` `#00E676` / `surface` | **11.11** | AAA | éxito |
| `errorRed` `#FFB4AB` / `surfaceContainerHigh` | **8.45** | AAA | **texto de error correcto** |
| `crimsonRed` `#FF1744` / `voidBg` | **5.23** | AA | destructivo de Ajustes |
| blanco / `runeViolet` `#9D4EDD` | **4.60** | AA (justo) | `RunicButton` |
| `outline` / `surfaceContainerHigh` `#272A32` | **4.51** | AA (justo) | etiquetas en diálogo |

### 2.2 Pares que el código usa y fallan

| Par | Ratio | Sitios | Evidencia |
|---|---|---|---|
| `onSurface` / `runeViolet` | **3.57** ❌ | **13** | §6.2 R-01 |
| `onSurface` / `crimsonRed` | **2.99** ❌ | 1 | `progress_tab_view.dart:229-231` |
| `onSurface` / `crimsonRed` (SnackBar hereda `snackBarTheme`) | **2.99** ❌ | 1 | `profile_edit_screen.dart:155-163` (blanco daría 3.85, también falla) |
| `voidBg` / `runeViolet` | **4.38** ❌ (casi) | 1 | `shop_screen.dart:819-837` — el único call site «arreglado» **no llega a 4.5** |
| `runeViolet` como **texto** / `surface` | **4.03** ❌ | varios | p. ej. `onboarding_screen.dart:1104` (los iconos a 4.03 sí pasan 3:1) |
| `manaCyan` @ α 0.5 / `surface` | **3.78** ❌ | 1 | `voice_room_screen.dart:914` (7 px) |
| `onSurface` / `manaCyan` | **1.19** ❌ | 0 (rol latente) | sería el par de un FAB cian; hoy nadie lo usa |
| blanco / `royalGold` (`onSecondary`) | **1.56** ❌ | 0 (rol latente) | `app_theme.dart:19` |

### 2.3 Contraste de componentes (no texto, umbral 3.0) — hallazgo nuevo

| Elemento | Par | Ratio | Veredicto |
|---|---|---|---|
| Borde de input (`enabledBorder`) | `outlineVariant` `#3B494C` / `surfaceContainerLow` | **1.84** | ❌ 1.4.11 |
| Borde de tarjeta/diálogo | `outlineVariant` / `surface` | **1.98** | ❌ |
| Borde sobre fondo profundo | `outlineVariant` / `voidBg` | **2.15** | ❌ |

Con el campo relleno a `#191B23` y borde a `#3B494C`, **el contorno del input se
distingue un 1.84:1**: para baja visión o luz de día el campo se ve como una
mancha. `app_theme.dart:139-144` es el sitio; el borde de foco (`manaCyan`,
12.05) sí es correcto, así que el usuario sólo «ve» el campo cuando ya está
dentro.

### 2.4 Dos correcciones que la documentación da por buenas y no lo están

| Afirmación previa | Verificación |
|---|---|
| «Hint al 70 % = **7.77:1**» (`app_theme.dart:132`, `06-improvement-backlog.md:39`) | **No se reproduce.** Compuesto real: `#BAC9CC`@0.7 sobre `#191B23` = `#8A9599` → **5.60:1** (pasa AA, pero no 7.77). Al 50 % sería **3.51** (coincide con el 3.50 original) |
| «El test bloquea la regresión del hint» (`app_contrast_test.dart:56-64`) | **El test es ciego al alfa**: pasa `withValues(alpha: 0.7)` a `ratio()`, que lee sólo `r/g/b` (`app_contrast.dart:19-27`). Mide el color opaco (**10.07**), no el renderizado (5.60). No protege el par |

### 2.5 Lo que no se puede afirmar

`[PENDIENTE DE VALIDAR]` — contraste **sobre fondo animado**
(`CyberManhwaBackground` pinta 35 partículas y 4 loops), sobre `BackdropFilter`
real y con brillo de pantalla bajo. Los ratios de arriba asumen superficie plana.

---

## 3. Objetivos táctiles (mínimo 48 dp)

| Control | Tamaño | Evidencia | Veredicto |
|---|---|---|---|
| Replay TTS de la burbuja del tutor | **20×20** | `conversation_screen.dart:2223-2232` (`constraints: BoxConstraints()` + `padding: zero`, icono 20) | ❌ **nuevo, el peor** |
| «Volver» del resumen (cabecera) | **40×40** | `session_summary_screen.dart:1048` (default) usado en `:142-145` | ❌ |
| «Volver» del guardián | **40×40** | `dungeon_guardian_screen.dart:752-754` | ❌ |
| «Volver» de perfil | **44×44** | `profile_edit_screen.dart:282-284` | ❌ |
| Botones del resultado de jefe | alto **46** | `boss_exam_result_screen.dart:129,141` | ❌ |
| «RECLAMAR» de la tienda | **48×40** | `shop_screen.dart:559` | ❌ (alto) |
| `IconButton` estándar (volver de tienda, ajustes, inventario…) | 48 | `shop_screen.dart:372`, `settings_screen.dart:113` | ✅ |
| Micrófono hold-to-talk | 72 | `conversation_mic_button.dart:130-131` | ✅ |
| Dock del dashboard | alto ≥ 48 | `dashboard_screen.dart:622` | ✅ |

**Corrección a la auditoría previa:** los `_RoundIconButton` de **24×24** del
resumen (`session_summary_screen.dart:524-529,544-549`) **no son objetivos
táctiles** — se usan como marcas decorativas (`onTap` nulo). No cuentan como
fallo de A-01; sí como ruido visual (parecen botones y no lo son).

**Patrón:** el tamaño mínimo aparece donde el control es «de sistema»
(`IconButton`, dock) y se pierde en cuanto alguien dibuja el control a mano
(`InkWell` + `SizedBox`, `constraints: BoxConstraints()`). No es criterio: es
copy-paste con números distintos.

---

## 4. Estados: cargando / vacío / error / sin red

### 4.1 Matriz por pantalla (verificado)

| Pantalla | Cargando | Vacío | Error | Reintento | Pull-to-refresh |
|---|---|---|---|---|---|
| Dashboard | ❌ (sin spinner propio) | ❌ | ⚠️ copy falso (`:194-231`) | ✅ botón | ❌ |
| Conversación | ✅ indicador de escritura (`conversation_screen.dart:2172-2191`) | n/a | ✅ nunca se pinta como turno del tutor (`conversation_providers.dart:1867-1912`) | ✅ | n/a |
| Resumen | ✅ `:631-649` | n/a | ✅ `:650-656` | ✅ | ❌ |
| Tienda | ✅ `:660-664` | ✅ `:665` | ❌ **error pintado como vacío** | ❌ | ❌ |
| Gremio (ChatRooms) | ✅ | ✅ | ✅ `.when` | ❌ | ✅ `:497` |
| Misiones | ✅ | ✅ | ✅ `.when` | ❌ | ✅ `:174` |
| Mis errores | ✅ | ✅ | ✅ `.when` | ❌ | ✅ `:127` |
| Informe semanal | ✅ | ✅ | ✅ `.when` | ❌ | ❌ (la auditoría previa decía que sí) |
| Inventario | ✅ | ✅ | ✅ `.when` | ❌ | ❌ |
| Paywall | ✅ | n/a | ✅ `.when` | ❌ | ❌ |
| Sala de voz | ✅ | ✅ | ✅ `.when` | ❌ | ❌ |
| Listening | ✅ | ✅ | ✅ `hasError`/`isLoading` (7 referencias) | ✅ | ❌ |
| Ajustes | ❌ (spinner sólo del botón guardar, `:300`) | n/a | ❌ | ❌ | ❌ |
| Onboarding / MiniConv / Welcome / Splash / Perfil / Guardián / Resultado de jefe | ❌ | n/a | ❌ | ❌ | ❌ |

### 4.2 Sin red

- **No hay paquete de conectividad** en `pubspec.yaml` (ni `connectivity_plus`
  ni equivalente): la app **infiere** el offline del fallo de consulta.
- Ese estado sólo existe en el dashboard: `progressOfflineProvider`
  (`dashboard_providers.dart:193-227`) + banner `royalGold` (`dashboard_screen.dart:270-298`,
  contraste 10.13 ✅).
- En el resto, «sin red» = «error de la consulta», y en la tienda eso significa
  «no hay objetos».

### 4.3 Hallazgos de estado

| ID | Hallazgo | Evidencia | Estado |
|---|---|---|---|
| E-01 | Tienda: error = vacío; sin `hasError` | `shop_screen.dart:657-665` | **abierto** (#255) |
| E-02 | Dashboard: «Mostrando el último progreso guardado» en la rama `hasError && !hasValue` (no hay caché) | `dashboard_screen.dart:194-231` | **abierto** (#256) |
| E-03 | 4 `context.pop()` sin `canPop()` → deep-link sin salida | `shop_screen.dart:377`, `inventory_screen.dart:122`, `my_errors_screen.dart:40`, `weekly_report_screen.dart:46` | **abierto** (#259); los otros 10 sí tienen guarda |
| E-04 | `RefreshIndicator` en **3** de 20 pantallas | gremio, misiones, mis errores | **abierto** |
| E-05 | Ajustes sin estado de página | `settings_screen.dart:300` (spinner del botón) | **abierto** |
| E-06 | Resumen distingue loading/error/pendiente **sin test de pantalla** | `session_summary_screen.dart:631-673` | **abierto** (#260) |
| E-07 | **No hay `HudState` compartido**: cada pantalla reimplementa el trío | no existe `core/widgets/hud_state.dart`; 30 `CircularProgressIndicator`, 0 skeletons | **abierto** |

**Bien resuelto y no se debe perder:** conversación (un fallo de IA nunca se
narra como tutor, `conversation_providers.dart:1869-1876`), resumen
(`:631-673`), mis errores, informe, inventario, misiones, listening.

---

## 5. Accesibilidad

### 5.1 Cobertura semántica real

| Métrica | Valor | Nota |
|---|---|---|
| `Semantics(` en `lib/` | **9 ocurrencias** | pero **5 son widgets `Semantics` reales**; 4 son `ExcludeSemantics` de las esquinas de `GlassCard` |
| Widgets con semántica | 5 | `RunicButton` (`runic_button.dart:73`), `GlassCard.semanticLabel` (`glass_card.dart:119`, opcional), chip de corrección (`correction_chip.dart:44`), anillo de meta (`daily_goal_ring_card.dart:98`, sólo label), micrófono (`conversation_mic_button.dart:167`) |
| `tooltip:` (propiedad) | **19** | `Tooltip(` widget: 6 |
| «Volver» con etiqueta | **4 de 14** | misiones `:106`, mis errores `:46`, informe `:52`, listening `:223`. El resto, icono mudo |
| `Semantics(selected:)` | **0** | dock `dashboard_screen.dart:611-663` |
| `textScalerOf` / clamp | **0** | el texto escala sin límite |
| `SegmentedBar` | sin `value` ni rol | `segmented_bar.dart:23-42`: 7 barras de progreso invisibles para TalkBack |
| `ExcludeSemantics` en tests | 4 | `test/overflow_test.dart:108,193,239,304` |

### 5.2 Accesibilidad, punto por punto

| ID | Hallazgo | Evidencia | Estado |
|---|---|---|---|
| A-01 | Objetivos táctiles < 48 dp | §3 (6 controles, incluido uno de 20×20) | **parcial**, con un caso nuevo |
| A-02 | 12/14 `repeat()` ignoran reduce-motion | §6.2 R-02 | **abierto** (#243 cerrado) |
| A-03 | 5 widgets con semántica en 20 pantallas | §5.1 | **abierto** (#251) |
| A-04 | Micrófono: `Semantics(button)` **sin acción** | `conversation_mic_button.dart:160-172` | **abierto de facto** (#252 cerrado) |
| A-05 | «Volver» sin etiqueta en 10 de 14 | §5.1 | **abierto** |
| A-06 | 0 `textScalerOf`; sólo 3 pantallas probadas a 1.5× | `test/text_scale_test.dart:78-100` | **abierto** (#253) |
| A-07 | `Tooltip` en 19 propiedades | mejoró desde 6 | **parcial** |
| A-08 | Contraste: 13 call sites violeta + 2 destructivos + bordes 1.84 | §2 | **abierto** |
| A-09 | Dock sin `Semantics(selected:)` | `dashboard_screen.dart:611-663` | **abierto** (#259) |
| A-10 | `ExcludeSemantics` global en tests de overflow | `overflow_test.dart:108,193,239,304` | **abierto** |
| A-11 | **Texto mínimo 7 px** en 2 sitios | `chat_rooms_screen.dart:1063`, `voice_room_screen.dart:914` | **abierto** (#245) |
| A-12 | **`.toUpperCase()` sobre 16 cadenas traducidas** | p. ej. `chat_rooms_screen.dart:627,890,967,1022`, `dashboard_screen.dart:691,698`, `splash_screen.dart:180` | **abierto** (#260/#261) |

### 5.3 Lo que sólo se comprueba con el lector

`[PENDIENTE DE VALIDAR]` — orden de foco de TalkBack, anuncio de cambio de
estado (grabando / pensando / error), activación del micrófono por doble toque,
`switch access`, y si el escalado 1.5×/2× rompe las 17 pantallas sin test. Está
en el checklist §7 (TalkBack) y §8 (escalado) de
`23-visual-validation-checklist.md`.

---

## 6. Estado real de #240–#261 (verificado en código)

### 6.1 Tablero

**4 cerrados / 18 abiertos** al cierre (cifra canónica de la épica). Ojo: la
tabla heredada marca **6** como `CLOSED` (#241, #242, #243, #244, #252, #257) y
**16** como `OPEN`, así que el recuento interno no cuadra y no se pudo
reconsultar la API (§6.3). En cualquier caso, lo que importa es la columna
«¿Vive?»: **1 corrección completa (#257)**, **3 parciales (#241, #242, #244)** y
**2 sin arreglar aunque cerradas (#243, #252)**.

| Issue | Entrada | GitHub | ¿Vive la corrección? | Evidencia |
|---|---|---|---|---|
| **#240** | UX-01 design system sin usar | OPEN | ❌ sigue | `AppSpacing`: **3 usos reales**, todos en `app_theme.dart:96,111,125`; `AppElevation`: **0** |
| #241 | UX-02 primario y destructivos AA | CLOSED | ⚠️ **parcial** | `RunicButton` blanco ✅ (`runic_button.dart:25-26`) pero **13 call sites** con `onSurface`/violeta (§6.2 R-01) y el «arreglado» de tienda da 4.38 |
| #242 | UX-03 objetivos táctiles | CLOSED | ⚠️ **parcial** | 6 controles < 48 dp, incluido uno nuevo de **20×20** (`conversation_screen.dart:2223-2232`) |
| #243 | UX-04 reduce-motion | CLOSED | ❌ **no resuelto** | 12 de 14 `repeat()` sin gate (§6.2 R-02) |
| #244 | UX-05 destructivos y avisos AA | CLOSED | ⚠️ **parcial** | Ajustes ✅ 5.23 (`settings_screen.dart:1536-1538`); siguen `progress_tab_view.dart:230` (2.99) y `profile_edit_screen.dart:160` (2.99) |
| #245 | UX-06 escala tipográfica | OPEN | ⚠️ mejoró | 31 → **22** tamaños (sin contar `fontSize: 0` de los ejes); **247** usos < 12 px; mín **7 px**; 4 estilos del `TextTheme` ausentes → Roboto |
| #246 | UX-07 migrar `GoogleFonts.*` | OPEN | ❌ | **384** vs **114** `AppTypography.*` |
| #247 | UX-08 espaciados fuera de rejilla | OPEN | ❌ | **419** `EdgeInsets` literales |
| #248 | UX-09 unificar botones | OPEN | ❌ | `RunicButton` 12 · `ElevatedButton` 20 · `IconButton` 38 · `GestureDetector` 41 · `InkWell` 24 |
| #249 | UX-10 `SnackBar` crudos | OPEN | ❌ | 48 `SystemSnack.show` vs **53** `SnackBar(` |
| #250 | UX-11 `QuestCard` vs `MissionCard` | OPEN | ❌ | `quest_card.dart:7` usado en `learning_path_roadmap.dart:699`; `MissionCard` en misiones |
| #251 | UX-12 cobertura semántica | OPEN | ❌ | 5 widgets con `Semantics` (§5.1) |
| #252 | UX-13 mic sin acción semántica | CLOSED | ❌ **no resuelto** | §6.2 R-04 |
| #253 | UX-14 matriz responsive | OPEN | ❌ | 312 px: **5** pruebas (4 pantallas + 1 widget); 1.5×: **3** pantallas; 2.0×: **2**; `textScalerOf` **0** |
| #254 | UX-15 conversación sin tests | OPEN | ❌ | 2 362 líneas; ningún test monta `ConversationScreen` |
| #255 | UX-16 tienda: error = vacío | OPEN | ❌ | `shop_screen.dart:657-665` |
| #256 | UX-17 dashboard miente en error | OPEN | ❌ | `dashboard_screen.dart:194-231` |
| #257 | UX-18 hint 3.50:1 | CLOSED | ✅ **vive**, con matiz | α 0.7 en `app_theme.dart:132-135`; real **5.60**, no 7.77 (§2.4) |
| #258 | UX-19…21 superficies, radios, sheets | OPEN | ❌ | `AppElevation` 0 · 177 `BorderRadius.circular` · 14 sheets, 12 `isScrollControlled`, **0** `useSafeArea` |
| **#259** | UX-22…28 a11y y navegación | OPEN | ❌ | 4 `pop()` sin `canPop` · 0 `Semantics(selected:)` · 3 `RefreshIndicator` · **sin ruta `/settings`** (`dashboard_screen.dart:378`, es pestaña) |
| **#260** | UX-24…30 layout, resumen e i18n | OPEN | ⚠️ solapa | Misma entrada que #259 en UX-24…28; 369 fallbacks `l10n?.clave ?? '…'` |
| **#261** | UX-31…37 detalles estéticos | OPEN | ⚠️ parcial | `medievalText` en `my_errors_screen.dart:43` · 16 `toUpperCase()` sobre l10n · `ChatRoomsScreen` sin `SafeArea` propia, **pero** las dos rutas de entrada sí la cubren (ver §6.2) |

**Lectura:** el patrón de cierre es «arreglé el componente», no «no queda ningún
call site»: #241 corrigió `RunicButton` y dejó 13 usos a mano; #242 subió un
botón y dejó 5; #252 añadió `Semantics` sin acción. #243 se cerró sin tocar los
loops. Sólo #257 tiene la corrección viva y coherente con lo que pedía el issue.

### 6.2 Regresiones: confirmadas y descartadas

**Las cuatro que pedía verificar:**

| ID | Regresión | Veredicto | Evidencia |
|---|---|---|---|
| **R-01** | `onSurface` sobre `runeViolet` en call sites | ✅ **CONFIRMADA — 13 sitios** | ver lista abajo |
| **R-02** | `repeat()` sin gate de reduce-motion | ✅ **CONFIRMADA — 12 de 14** | ver lista abajo |
| **R-03** | `_RoundIconButton` de 40 dp | ✅ **CONFIRMADA** | `session_summary_screen.dart:1048` (default) usado en `:142-145`; y `dungeon_guardian_screen.dart:752-754` (fijo) |
| **R-04** | Micrófono con `Semantics` sin acción | ✅ **CONFIRMADA** | `conversation_mic_button.dart:160-172`: `Listener` (sólo puntero) + `Semantics(button: true, label:)` **sin `onTap`/`onLongPress`** |

**R-01 — los 13 sitios (14 fondos violeta, 1 corregido):**

| Archivo:línea | Control |
|---|---|
| `welcome_screen.dart:308-317` | REGISTER WITH GOOGLE |
| `welcome_screen.dart:458-460` | iniciar sesión con correo |
| `welcome_screen.dart:581-583` | confirmar reset |
| `onboarding_screen.dart:535-537` | CTA «continuar» de los 4 pasos |
| `mini_conversation_screen.dart:459-461` | CTA de la prueba de valor |
| `paywall_screen.dart:393-395` | CTA del paywall |
| `session_summary_screen.dart:712-714` | botón LISTO del resumen |
| `settings_screen.dart:288-290` | guardar ajustes |
| `profile_edit_screen.dart:619-621` | guardar perfil |
| `chat_rooms_screen.dart:642-644` | «CREAR MESA» |
| `chat_rooms_screen.dart:451-458` | «inicializar mesa» (texto `onSurface`, sin `foregroundColor`) |
| `ai_pick_hero_card.dart:221-223` | CTA de la tarjeta de héroe IA |
| `srs_flashcard_modal.dart:193-206` | «cerrar» del repaso SRS (texto `onSurface`) |

Corregido: `shop_screen.dart:819-820` usa `voidBg` → **4.38**, sigue por debajo
de 4.5 (el valor correcto es blanco, 4.60). **`progress_tab_view.dart:229-231`
NO es violeta**: es `crimsonRed` + `onSurface` = 2.99 — la edición anterior lo
contaba en este grupo; son dos fallos distintos.

**R-02 — los 12 loops sin gate:**

| Foco | Gate | Evidencia |
|---|---|---|
| `glass_card.dart:60` (esquinas de las 100 tarjetas) | ❌ | `..repeat(reverse: true)` directo en `initState` |
| `cyber_manhwa_background.dart:55,60,65,70` (fondo de 15 archivos) | ❌ | 4 `..repeat()` |
| `draggable_monster_widget.dart:46,52,58,64` | ❌ | 4 `..repeat()` |
| `voice_waveform_visualizer.dart:30` | ❌ | `..repeat()` |
| `learning_path_roadmap.dart:553,561` | ❌ | `repeat` en `initState`/`didUpdateWidget` |
| `dungeon_guardian_screen.dart:45-47` | ✅ | `if (!_reduceMotion)` con `disableAnimationsOf` |
| `runic_button.dart:84` | ✅ | `reducedMotion ? 1.0 : _scale.value` (no es loop) |

`AppMotion.reduceMotion` está bien implementado (`app_motion.dart:37-38`) y tiene
**3 referencias reales** (`runic_button.dart:68`, `mission_card.dart:139,504`).

**Regresiones descartadas / correcciones a la edición anterior:**

| Afirmación previa | Veredicto | Por qué |
|---|---|---|
| «12 call sites violeta» incluyendo `progress_tab_view` | ❌ **descartada** | son **13** violeta y `progress_tab_view` es carmesí (2.99), no violeta |
| «La tienda quedó corregida» | ❌ **descartada** | usa `voidBg` = **4.38** < 4.5 |
| «Volver con etiqueta sólo en Misiones» | ❌ **descartada** | **4 de 14** tienen `tooltip` (misiones, mis errores, informe, listening) |
| «`Tooltip(` = 6 en toda la app» | ⚠️ matiz | 6 widgets `Tooltip`, **19** propiedades `tooltip:` |
| «1 solo `RefreshIndicator`, y el informe ya lo tiene» | ❌ **descartada** | hay **3** (gremio, misiones, mis errores); el informe **no** tiene |
| «`Semantics(` = 9 en `lib/`» | ⚠️ matiz | 9 ocurrencias, **5 widgets reales** (4 son `ExcludeSemantics`) |
| «Hint al 70 % = 7.77» | ❌ **descartada** | real **5.60**; el test no compone el alfa |
| «Los 24×24 del resumen son objetivos táctiles» | ❌ **descartada** | son marcas decorativas sin `onTap` |
| «El dashboard sí distingue loading» | ❌ **descartada** | no tiene rama de carga propia |
| «`ChatRoomsScreen` sin `SafeArea` (UX-37)» | ⚠️ **no demostrable** | 0 `SafeArea(` propias, pero en pestaña va dentro del `SafeArea` del dashboard (`dashboard_screen.dart:267-268` con la pestaña en `:372-374`) y en ruta tiene `Scaffold` + `AppBar` (`chat_rooms_screen.dart:953-977`). Queda `[PENDIENTE DE VALIDAR]` en dispositivo (V-10) |
| «La tipografía bajó a 21 tamaños / 239 usos < 12» | ⚠️ **desactualizada** | hoy **22** tamaños y **247** usos < 12 px (Δ +1 y +8 respecto a la medición previa; aparecen 11.5 y 12.5 en `dungeon_guardian_screen.dart:196,594`) |

### 6.3 Discrepancias documentación ↔ código

| Discrepancia | Detalle |
|---|---|
| **El recuento de la épica no cuadra con el tablero** | «4 cerrados / 18 abiertos» vs **6 `CLOSED` / 16 `OPEN`** en la tabla heredada. Sin acceso a la API en esta sesión: se registra, no se resuelve |
| **#241, #242, #252 cerrados con regresión viva** | §6.2 |
| **#243 cerrado sin arreglar** | 12/14 loops |
| **#244 parcial**: dos de sus tres sitios siguen en 2.99 | `progress_tab_view.dart:230`, `profile_edit_screen.dart:160` |
| **#259 y #260 se solapan en UX-24…28** | cerrar una no cierra la otra |
| **UX-38 y UX-39 sin issue** | están en el backlog y fuera de #240–#261 |
| **`docs/ui-ux-audit/screenshots/` sin capturas** | el épico #239 las exige; no existen y este entorno no puede generarlas |
| **`app_theme.dart:132` documenta un ratio irreal (7.77)** | el test asociado es ciego al alfa |
| **`SegmentedBar` no expone `value`** | 7 barras de progreso invisibles para TalkBack |

---

## 7. Prioridad recomendada

| Orden | Trabajo | Por qué primero |
|---|---|---|
| **1** | `onTertiary = white` en el tema + sustituir los 13 call sites (y `shop` a blanco) | 1 propiedad por sitio; desbloquea AA en todo el embudo. Hoy **no existe token** para texto sobre violeta: ésa es la causa raíz |
| **2** | Gate de `AppMotion.reduceMotion` en los 12 loops | Preferencia de accesibilidad del sistema ignorada; arreglo mecánico |
| **3** | `HudState` + `HudHeader` compartidos; usarlos en Tienda, Dashboard y las 14 cabeceras | Elimina dos mentiras de estado y la deriva de jerarquía |
| **4** | Semántica: acción en el micrófono, etiqueta en los 10 «volver», `selected` en el dock, `value` en `SegmentedBar` | El micrófono es la función principal del producto |
| **5** | Objetivos táctiles: el replay de 20×20 y los 6 controles < 48 dp | Barato y medible |
| **6** | Bordes `outlineVariant` a ≥ 3:1 y corregir el test de contraste para que componga alfa | Sin esto, el «arreglo» vuelve a ser cosmético |
| **7** | Adoptar `AppSpacing`/`AppElevation` con lint de fuente | Sin esto, 1–6 se re-rompen |

---

## 8. Qué no se puede afirmar desde este entorno

1. **Nada visual.** Jerarquía percibida, ritmo vertical, alineación óptica,
   densidad, legibilidad del glow, calidad de animación → `[PENDIENTE DE VALIDAR]`.
2. **TalkBack real:** orden de foco, anuncios de estado, activación por switch
   access, doble toque en el micrófono.
3. **Escalado real** a 1.5× y 2.0× en las 17 pantallas sin test.
4. **Contraste sobre fondos animados** y con `BackdropFilter` real.
5. **Jank / rendimiento:** 23 `AnimationController`, 14 `repeat()`, 8
   `BackdropFilter` (uno por `GlassCard`, hasta 100 instancias) son candidatos;
   sin perfilado no se afirma.
6. **Estado del entitlement Pro en producción:** depende de RevenueCat y
   `sync-entitlement`; no se consultó.

Todo lo anterior se cierra con **`23-visual-validation-checklist.md`**, que es la
pieza operativa de D-13.
