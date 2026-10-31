# 13 — Auditoría UX/UI (resumen enlazado)

> **Este documento no sustituye la auditoría.** La auditoría completa está en
> `docs/ui-ux-audit/` y aquí sólo se **resume, actualiza y enlaza**:
>
> | Documento | Contenido | Enlace |
> |---|---|---|
> | `01-project-analysis.md` | conteos de código, tipografía, espaciado | `docs/ui-ux-audit/01-project-analysis.md` |
> | `02-screen-inventory.md` | inventario previo de pantallas | `docs/ui-ux-audit/02-screen-inventory.md` |
> | **`03-ux-ui-audit.md`** | **los 49 hallazgos con evidencia** | `docs/ui-ux-audit/03-ux-ui-audit.md` |
> | `04-design-system-proposal.md` | propuesta de sistema | `docs/ui-ux-audit/04-design-system-proposal.md` |
> | `05-redesign-proposals.md` | propuestas de rediseño | `docs/ui-ux-audit/05-redesign-proposals.md` |
> | **`06-improvement-backlog.md`** | **39 entradas accionables UX-01…UX-39** | `docs/ui-ux-audit/06-improvement-backlog.md` |
> | `07-executive-summary.md` | resumen ejecutivo | `docs/ui-ux-audit/07-executive-summary.md` |
>
> Épica de trabajo: **issue #239**. Issues hijos: **#240–#261**.
>
> ## Aviso metodológico
>
> **No hay visión de imágenes** y el móvil está desconectado. Todo lo que sigue
> se sostiene en: (a) lectura de widgets y tokens, (b) **contrastes calculados**
> con la fórmula WCAG que implementa `lib/core/theme/app_contrast.dart:19-31`,
> (c) estado real de los issues en GitHub consultado hoy. **No** hay juicio
> visual: ni jerarquía, ni ritmo, ni legibilidad percibida, ni calidad de
> animación.

---

## 1. Estado real del backlog #240–#261 (verificado hoy)

Los 22 issues cubren las 39 entradas del backlog. **4 cerrados, 18 abiertos.**

| Issue | Entrada(s) | Sev. | Estado GitHub | ¿Resuelto en código? |
|---|---|---|---|---|
| **#240** | UX-01 design system no usado | P0 | OPEN | ❌ sigue: `AppSpacing` 4 refs / `AppElevation` 0 usos |
| #241 | UX-02 botón primario y destructivos AA | P0 | CLOSED | ⚠️ **parcial**: `RunicButton` ya usa blanco (`runic_button.dart:26`), pero **13 call sites** siguen con `onSurface` sobre violeta (§2.1) |
| #242 | UX-03 objetivos táctiles < 48 dp | P0 | CLOSED | ⚠️ **parcial**: `_RoundIconButton` sigue con `size = 40` por defecto (`session_summary_screen.dart:1048`), y la cabecera del resumen usa ese default |
| #243 | UX-04 animaciones ignoran reduce-motion | P0 | CLOSED | ❌ **no resuelto**: 12 de 14 `repeat()` siguen sin gate (§3) |
| #244 | UX-05 destructivos y avisos AA | P1 | CLOSED | ✅ corregido donde se tocó: `settings_screen.dart:1536-1538` usa `crimsonRed` + `voidBg` (5.23:1) |
| #245 | UX-06 escala tipográfica | P1 | OPEN | ⚠️ mejoró: 31 → **21** tamaños; siguen 225 usos < 12 px y mínimo **7 px** |
| #246 | UX-07 migrar `GoogleFonts.*` | P1 | OPEN | ❌ 384 `GoogleFonts.*` vs 114 `AppTypography.*` |
| #247 | UX-08 espaciados fuera de rejilla | P1 | OPEN | ❌ 419 `EdgeInsets` literales |
| #248 | UX-09 unificar botones | P1 | OPEN | ❌ `RunicButton` 12 vs 20 `ElevatedButton` + 38 `IconButton` + 41 `GestureDetector` + 24 `InkWell` |
| #249 | UX-10 `SnackBar` crudos | P1 | OPEN | ❌ 48 `SystemSnack.show` vs 52 `SnackBar(` |
| #250 | UX-11 `QuestCard` vs `MissionCard` | P1 | OPEN | ❌ ambos vivos |
| #251 | UX-12 cobertura semántica | P1 | OPEN | ❌ 9 `Semantics(` en todo `lib/` |
| #252 | UX-13 mic hold-to-talk sin acción semántica | P1 | CLOSED | ⚠️ **parcial**: `Semantics(button: true, label: …)` sigue **sin `onTap`/`onLongPress`** (`conversation_mic_button.dart:167-171`) |
| #253 | UX-14 matriz responsive 20×2 | P1 | OPEN | ❌ 5/20 pantallas a 312 px, 0 `textScalerOf` |
| #254 | UX-15 conversación sin widget tests | P1 | OPEN | ❌ 2 362 líneas sin test de pantalla |
| #255 | UX-16 tienda: error = vacío | P1 | OPEN | ❌ `shop_screen.dart:657-665` no consulta `hasError` |
| #256 | UX-17 dashboard miente en error | P1 | OPEN | ❌ `dashboard_screen.dart:194-231` |
| #257 | UX-18 hint de inputs 3.50:1 | P1 | CLOSED | ✅ `app_theme.dart:132-134` sube a α 0.7 |
| #258 | UX-19…21 superficies, radios, sheets | P2 | OPEN | ❌ `AppElevation` sin usar; 177 radios literales; 14 `showModalBottomSheet` |
| **#259** | UX-22…28 accesibilidad y navegación | P2 | OPEN | ❌ 4 `pop()` sin fallback; 0 `Semantics(selected:)` en el dock |
| **#260** | UX-24…30 layout, resumen e i18n | P2 | OPEN | ⚠️ **solapa con #259 en UX-24…28** (taxonomía duplicada) |
| **#261** | UX-31…37 detalles estéticos | P3 | OPEN | ❌ `ChatRoomsScreen` sin `SafeArea`, `.toUpperCase()` sobre traducciones |

**Lectura del tablero:**

- De 6 entradas marcadas como cerradas, **3 están sólo parcialmente resueltas**
  (#241, #242, #252) y **1 no está resuelta** (#243). El cierre se hizo por
  "arreglé el componente", no por "no queda ningún call site".
- **UX-38 y UX-39 no tienen issue** en el rango #240–#261, aunque están en
  `06-improvement-backlog.md`. Quedan fuera de seguimiento.
- **Criterio de cierre de la épica #239**: "0 hallazgos CRÍTICO y ALTO abiertos"
  + "un test que impida la regresión de cada corrección". Hoy: **1 crítico
  (UX-01) y 11 altos** siguen abiertos.

---

## 2. Los 5 hallazgos más graves (con evidencia)

### 2.1 El par violeta + `onSurface` sigue en 13 sitios pese a que #241 está cerrado

`RunicButton` se corrigió (`runic_button.dart:25-26`: blanco sobre violeta =
**4.60:1**, AA). Pero el par antiguo se replica a mano en pantallas de primer
nivel:

| Archivo:línea | Pantalla / control |
|---|---|
| `onboarding_screen.dart:536-537` | CTA «continuar» de los 4 pasos |
| `session_summary_screen.dart:713-714` | botón **LISTO** del resumen |
| `settings_screen.dart:289-290` | botón de guardar ajustes |
| `welcome_screen.dart:309-310, 459-460, 582-583` | REGISTER WITH GOOGLE, login con email, confirmación |
| `chat_rooms_screen.dart:643-644` | «CREAR MESA» |
| `profile_edit_screen.dart:620-621` | guardar perfil |
| `mini_conversation_screen.dart:460-461` | CTA de la prueba de valor |
| `progress_tab_view.dart:230-231`, `ai_pick_hero_card.dart:222-223`, `paywall_screen.dart:394-395`, `welcome_back_card.dart:155,174` | acentos varios |

**Ratio: 3.57:1** (`#E1E2ED` sobre `#9D4EDD`) < 4.5 → **falla AA** en texto de
16 px. Con blanco serían 4.60. Es un cambio de **una propiedad por sitio**.

**Por qué es grave:** son los botones que más se pulsan del embudo (crear
cuenta, empezar el onboarding, terminar la sesión). El test de contraste
(`app_contrast_test.dart:41`) valida el par del componente, **no** los call
sites; por eso el issue se pudo cerrar con la regresión viva.

### 2.2 `reduce-motion` no funciona en 12 de las 14 animaciones infinitas

| Foco | Gate |
|---|---|
| `glass_card.dart:60` (esquinas rúnicas de **las 100 tarjetas**) | ❌ |
| `cyber_manhwa_background.dart:55,60,65,70` (fondo de **16 archivos**) | ❌ |
| `draggable_monster_widget.dart:46,52,58,64` | ❌ |
| `voice_waveform_visualizer.dart:30` | ❌ |
| `learning_path_roadmap.dart:553,561` | ❌ |
| `dungeon_guardian_screen.dart:46,47` | ✅ |
| `runic_button.dart:84` | ✅ |

`AppMotion.reduceMotion` / `AppMotion.of` existen y están bien implementados
(`app_motion.dart:53-66`), con **3 referencias reales** en todo `lib/`. #243
está cerrado; la cobertura real es **2 de 14**.

**Por qué es grave:** es la única preferencia de accesibilidad que el sistema
operativo ofrece para usuarios con sensibilidad vestibular; incumplirla no es un
detalle estético.

### 2.3 Dos pantallas mienten sobre su estado (error pintado como vacío / como caché)

| ID | Hallazgo | Evidencia | Efecto en el usuario |
|---|---|---|---|
| **UX-16** (#255) | La tienda no consulta `hasError`: si la red falla, muestra «AÚN NO HAY OBJETOS» | `shop_screen.dart:657-665` (`catalog.isEmpty → _buildEmpty`) | Cree que la tienda está vacía y no reintenta. No hay forma de recuperarse salvo salir y volver |
| **UX-17** (#256) | El dashboard dice «Mostrando el último progreso guardado» justo en la rama `hasError && !hasValue`, donde **no hay** progreso guardado | `dashboard_screen.dart:194-231` | Copy que promete datos que no existen |

**Por qué es grave:** no es un problema de píxeles: destruye la confianza en la
cifra. El resto de pantallas sí distinguen estados (ver matriz en
`docs/product-discovery/03-screen-inventory.md` §4.1), así que el patrón correcto
ya existe y no se reutiliza: **no hay `HudState` compartido**.

### 2.4 Objetivos táctiles por debajo de 48 dp (y #242 cerrado con 40)

`_RoundIconButton` de `session_summary_screen.dart:1038-1051` mantiene
`size = 40` por defecto (`:1048`) y la cabecera del resumen lo usa así
(`:142-145`). Otros restos medidos en la auditoría:

| Control | Tamaño | Evidencia |
|---|---|---|
| Volver / siguiente del resumen | 40 | `session_summary_screen.dart:1048` |
| Volver del guardián | 40 | `dungeon_guardian_screen.dart:740` (default fijo) |
| Volver de perfil | 44 | `profile_edit_screen.dart:282-285` |
| Botones del resultado de jefe | alto 46 | `boss_exam_result_screen.dart:129,141` |
| Acción de la tienda | 48×40 | `shop_screen.dart:559` |

**Por qué es grave:** 40 dp está por debajo del mínimo recomendado (48 dp) y del
que el propio repo usa en otros sitios (p. ej. el dock del dashboard fuerza
`minHeight: 48`, `dashboard_screen.dart:622`). Es inconsistencia, no criterio.

### 2.5 La accesibilidad semántica es prácticamente inexistente

| Métrica | Valor |
|---|---|
| `Semantics(` en `lib/` | **9** |
| `Tooltip(` en `lib/` | **6** |
| `textScalerOf` | **0** |
| Botones de volver con etiqueta | sólo `missions_screen.dart:106` |
| Dock del dashboard con `Semantics(selected:)` | 0 (`dashboard_screen.dart:611-663`) |
| Micrófono hold-to-talk | `Semantics(button: true, label:)` **sin acción** (`conversation_mic_button.dart:167-171`) |

Con TalkBack, un control icon-only sin etiqueta se anuncia como «botón» y nada
más; el micrófono en modo mantener-para-hablar **se puede enfocar pero no
activar** por doble toque (issue #252, cerrado, sigue igual).

**Por qué es grave:** el micrófono es el control central del producto; si un
usuario de lector de pantalla no puede usarlo, la app no le sirve para su función
principal.

---

## 3. Contraste: resultados calculados

Resumen; tabla completa y pares de todos los tokens en
`docs/product-discovery/04-ui-design-system.md` §9.

| Par | Ratio | AA normal (4.5) | Dónde |
|---|---|---|---|
| `onSurface` / `voidBg` | 15.63 | ✅ AAA | texto base |
| `onSurfaceVariant` / `surface` | 10.87 | ✅ AAA | copy secundario |
| `manaCyan` / `surface` | 12.05 | ✅ AAA | acentos |
| `royalGold` / `surface` | 11.85 | ✅ AAA | recompensas |
| `errorRed` / `containerHigh` | 8.45 | ✅ AAA | texto de error (**usar este**) |
| `outline` / `containerHigh` | 4.51 | ✅ (justo) | bordes/labels |
| `crimsonRed` / `containerHigh` | 3.73 | ❌ | texto de error actual |
| **`onSurface` / `runeViolet`** | **3.57** | ❌ | **13 call sites** (§2.1) |
| **`onSurface` / `crimsonRed`** | **2.99** | ❌ | `progress_tab_view.dart:230` |
| blanco / `crimsonRed` | 3.85 | ❌ | `profile_edit_screen.dart:160` |
| `onSurface` / `manaCyan` | 1.19 | ❌ | rol latente (sin uso) |
| blanco / `royalGold` (`onSecondary`) | 1.56 | ❌ | `app_theme.dart:19` (rol sin uso) |

**Lo bueno:** la paleta base es AAA en todo el texto principal y el par
`voidBg`/`manaCyan` del botón del tema es 13.09. **Lo malo:** los dos acentos
"de peligro/magia" no funcionan como fondo de texto claro y el código los sigue
usando.

---

## 4. Accesibilidad

| ID | Hallazgo | Evidencia | Estado |
|---|---|---|---|
| A-01 | Objetivos táctiles < 48 dp | §2.4 | **parcial** |
| A-02 | 12/14 animaciones ignoran reduce-motion | §2.2 | **abierto** |
| A-03 | 9 `Semantics` en 20 pantallas | `lib/` | **abierto** (#251) |
| A-04 | Mic hold-to-talk sin acción semántica | `conversation_mic_button.dart:167-171` | **abierto de facto** (#252 cerrado) |
| A-05 | Volver sin etiqueta salvo en Misiones | 7 cabeceras | **abierto** |
| A-06 | 0 `textScalerOf`: el texto escala sin límite | `lib/` | **abierto** (#253) |
| A-07 | 6 `Tooltip` en toda la app | `lib/` | **abierto** (#259) |
| A-09 | Dock sin `Semantics(selected:)` | `dashboard_screen.dart:611-663` | **abierto** (#259) |
| A-10 | `ExcludeSemantics` global en tests de overflow | `test/overflow_test.dart` | **abierto** (#261) |

**Protección existente que sí funciona:** `RunicButton` declara
`Semantics(button: true, label:)` (`runic_button.dart:73-75`) y `GlassCard`
acepta `semanticLabel` (`glass_card.dart:118-124`); `SegmentedBar` no expone
valor, así que una barra de progreso es invisible para TalkBack.

---

## 5. Responsive

| Métrica | Valor |
|---|---|
| Pantallas | 20 |
| Con test a 312×800 o 312×576 | **5** (Dashboard, ChatRooms, Welcome, DungeonGuardian, Shop) |
| Con test a `textScaler` 1.5× | **3** (Welcome, Dashboard, DungeonGuardian) |
| Con test a 2.0× | **2** (Welcome, DungeonGuardian) |
| `LayoutBuilder` en `lib/` | **2** |
| `constraints.maxWidth` | **0** |
| `SystemChrome` / bloqueo de orientación | **0** |
| `RefreshIndicator` | **3** |

**Sin ninguna red de layout:** Splash, Onboarding, MiniConversation,
**Conversación**, **Resumen**, Paywall, ProfileEdit, **Sala de voz**,
Inventory, BossExamResult, MyErrors, WeeklyReport, ListeningQuiz, **Misiones**,
**Ajustes** (15 pantallas). Las dos más grandes del producto (Conversación
2 362 líneas y Resumen 1 325) están en ese grupo.

La conversación, además, fija anchos relativos y alturas absolutas
(`conversation_screen.dart:897, 1622, 1657`) sin `LayoutBuilder`, y no hay
diseño de landscape.

---

## 6. Estados y flujos

| ID | Hallazgo | Evidencia | Estado |
|---|---|---|---|
| E-01 | Tienda: error = vacío | `shop_screen.dart:657-665` | **abierto** (#255) |
| E-02 | Dashboard: copy falso en error | `dashboard_screen.dart:194-231` | **abierto** (#256) |
| E-03 | 4 `context.pop()` sin fallback | `shop_screen.dart:377`, `inventory_screen.dart:122`, `my_errors_screen.dart:40`, `weekly_report_screen.dart:46` | **abierto** (#259) |
| E-04 | 1 solo `RefreshIndicator` en 20 pantallas | `chat_rooms_screen.dart` | **parcial** (Misiones e Informe ya lo tienen) |
| E-05 | Ajustes sin estado de carga/error de página | `settings_screen.dart:300` | **abierto** |
| E-06 | Resumen distingue loading/error/pendiente **sin test** | `session_summary_screen.dart:631-673` | **mejoró**, sigue sin test |

**Bien resuelto y no se debe perder:** Mis errores (`:75-101`), Informe semanal
(`:81-141`), Listening (`:241-266`), Inventario (`:194-258`), Misiones
(`:152-236`), Resumen (`:631-673`), Conversación (error nunca se pinta como
mensaje del tutor, `conversation_providers.dart:1867-1912`).

---

## 7. Qué cambió desde la auditoría (medido hoy)

| Métrica | Auditoría (30-oct) | Hoy | Δ |
|---|---|---|---|
| Tamaños de `fontSize` distintos | 31 | **21** | −10 |
| `EdgeInsets` literales | 419 | **419** | 0 |
| `Color(0x…)` literales | 95 | **95** | 0 |
| `GoogleFonts.*` | 384 | **384** | 0 |
| `AppTypography.*` | 114 | **114** | 0 |
| `Semantics(` | 9 | **9** | 0 |
| `SystemSnack.show` | 48 | **48** | 0 |
| `SnackBar(` crudos | 52 | **52** | 0 |
| `AppElevation` usos | 0 | **0** | 0 |
| `textScalerOf` | 0 | **0** | 0 |
| `repeat()` con gate | 2/14 | **2/14** | 0 |

**Conclusión:** lo único que se movió de forma medible es la **escala
tipográfica** (de 31 a 21 tamaños) y los **pares de contraste del tema**
(`RunicButton`, hint al 70 %, destructivo de ajustes). El resto del sistema sigue
igual: los tokens existen y no se usan.

---

## 8. Discrepancias entre documentación, issues y código

| Discrepancia | Detalle |
|---|---|
| **#241, #242, #252 cerrados con regresión viva** | §1 y §2 |
| **#243 cerrado sin arreglar** | 12/14 loops sin gate |
| **#259 y #260 se solapan en UX-24…28** | la misma entrada está en dos issues; el cierre de una no cierra la otra |
| **UX-38 y UX-39 sin issue** | están en el backlog pero fuera del rango #240–#261 |
| **El épico #239 exige capturas** | `docs/ui-ux-audit/screenshots/README.md` documenta el método; no existen capturas válidas y este entorno tampoco puede generarlas |
| **La auditoría dice "5/20 pantallas a 312 px"** | sigue siendo cierto hoy; no hay tests nuevos de layout |

---

## 9. Prioridad recomendada (y por qué)

| Orden | Trabajo | Por qué primero |
|---|---|---|
| **1** | Reemplazar `onSurface` por blanco en los **13 call sites** de §2.1 | Cambio de 1 propiedad; desbloquea AA en el embudo de entrada y salida |
| **2** | Gate de `AppMotion.reduceMotion` en los 12 loops | Preferencia de accesibilidad del sistema ignorada; arreglo mecánico (`if (!reduce) …`) |
| **3** | `HudState` compartido + usarlo en Tienda y Dashboard | Elimina dos mentiras de estado y evita la tercera |
| **4** | `Semantics` en micrófono (acción), volver (label) y dock (`selected`) | El micrófono es la función principal |
| **5** | Subir los 5 objetivos táctiles a 48 dp | Barato y medible |
| **6** | Adoptar `AppSpacing`/`AppElevation` con lint de fuente | Sin esto, los 3 primeros se re-rompen |

---

## 10. Qué no se puede afirmar desde este entorno

1. **Nada visual.** Jerarquía, ritmo vertical, alineación óptica, densidad,
   legibilidad del glow, calidad de las animaciones: requieren revisión humana
   sobre dispositivo.
2. **TalkBack real:** orden de foco, anuncios de cambio de estado y activación
   por switch access.
3. **Escalado de texto real** a 1.5× y 2.0× en las 15 pantallas sin test.
4. **Contraste sobre fondos animados**: los ratios asumen superficie plana y
   `CyberManhwaBackground` dibuja partículas.
5. **Rendimiento/jank**: 23 `AnimationController`, 14 `repeat()`, 8
   `BackdropFilter` (uno por `GlassCard`, hasta 100 instancias) son candidatos;
   sin perfilado no se afirma.
6. **Estado del entitlement Pro en producción**: depende de RevenueCat y de
   `sync-entitlement`; no se consultó.
