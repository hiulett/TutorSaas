# 06 — Backlog de mejora

**39 entradas** derivadas de los 49 hallazgos de `03` (varios comparten arreglo).
Complejidad: **S** ≤ 1 día · **M** 2–4 días · **L** ≥ 5 días.

Ninguna entrada requiere cambiar la paleta ni las familias tipográficas.
Las marcadas con 🔍 necesitan validación visual humana antes de cerrarse.

---

## CRÍTICO (4)

| ID | Sev. | Pantalla/módulo | Problema (evidencia) | Solución | Compl. | Archivos Flutter |
|---|---|---|---|---|---|---|
| **UX-01** | CRÍTICO | `RunicButton` (global) | Botón primario por defecto violeta + `onSurface` = **3.57:1**, falla AA a 16 px (`runic_button.dart:24-25`); mismo par en `chat_rooms_screen.dart:452,643-644` | `onTertiary = white` (4.60) y validar par en el constructor; o primario cian/`voidBg` (13.09). Lint que prohíba violeta+onSurface | S | `runic_button.dart`, `app_theme.dart:12-21`, `chat_rooms_screen.dart` |
| **UX-02** | CRÍTICO | Sistema (espaciado) | `AppSpacing` tiene **3 usos** vs **419** `EdgeInsets` literales; el 30 % de valores fuera de rejilla (`01` §1.2) | Adoptar `AppSpacing` + `hairline(2)`/`compact(6)`; normalizar 10→8/12 y 14→12/16; **lint de fuente** que falle con `EdgeInsets` numérico | L | `app_spacing.dart`, 41 archivos de UI |
| **UX-03** | CRÍTICO | Resumen, guardián, perfil, tienda, jefe | Objetivos táctiles < 48 dp: **24×24** en cerrar/siguiente del resumen (`session_summary_screen.dart:524-530,544-550`), 40 (`_RoundIconButton :1045-1051`, guardián `:752-760`), 44 (`profile_edit_screen.dart:282-285`), alto 46 (`boss_exam_result_screen.dart:129,141`), 48×40 (`shop_screen.dart:559`) | `HudIconButton` 48×48 y `minimumSize: Size(48,48)`; lint `tap_target` | M | `core/widgets/hud_icon_button.dart` (nuevo), 5 pantallas |
| **UX-04** | CRÍTICO | Animaciones globales | **12 de 14** `repeat()` infinitos ignoran reduce-motion (`glass_card.dart:60`, `cyber_manhwa_background.dart:55-70`, `draggable_monster_widget.dart:46-64`, `voice_waveform_visualizer.dart:30`, `learning_path_roadmap.dart:553,561`) | Gate `if (!AppMotion.reduceMotion(context))`; helper `AppMotion.loop(context)`; test con `disableAnimations: true` | S | 6 archivos + `app_motion.dart` |

---

## ALTO (14)

| ID | Sev. | Pantalla/módulo | Problema (evidencia) | Solución | Compl. | Archivos Flutter |
|---|---|---|---|---|---|---|
| **UX-05** | ALTO | Ajustes, progreso, perfil | Destructivos con carmesí + `onSurface` = **2.99** (`settings_screen.dart:1536-1537`, `progress_tab_view.dart:230-231`); SnackBar carmesí + blanco 3.85 (`profile_edit_screen.dart:160`); violeta como texto 3.12–4.38 (`chat_rooms_screen.dart:886`, `boss_exam_result_screen.dart:333`) | `onError = voidBg` (5.23), blanco solo sobre violeta (4.60), texto violeta → `runeVioletText` | S | `app_theme.dart`, 4 pantallas |
| **UX-06** | ALTO | Tipografía (global) | **31 tamaños** distintos; 243 usos < 12 px (mínimo **7 px**, `chat_rooms_screen.dart:1063`); 4 estilos del `TextTheme` en Roboto; `AppTypography` no coincide con el tema | Definir los 4 estilos que faltan (20/14/12/11), mínimo 11 px, alinear `AppTypography` a los 15 estilos (`04` §3) | M | `app_theme.dart:22-83`, `app_typography.dart`, ~40 pantallas |
| **UX-07** | ALTO | Tipografía (global) | **384** llamadas `GoogleFonts.*` frente a 114 `AppTypography.*`; 0 usos de `textTheme` salvo 4 | Migrar a `Theme.of(context).textTheme.*`/`AppTypography`; lint que prohíba `GoogleFonts.` fuera de `core/theme` | L | 40+ archivos de feature |
| **UX-08** | ALTO | Sistema (espaciado) | 189 valores fuera de rejilla: 2 (22), 3 (13), 6 (36), 7, 10 (49), 11 (10), 14 (43), 18, 26, 30, 58 | Normalizar según mapa de `04` §4.2; conservar 2 y 6 como tokens | L | 41 archivos de UI |
| **UX-09** | ALTO | Botones | Dos sistemas: `RunicButton` (12 usos) vs `ElevatedButton` 20 + `IconButton` 38 + `GestureDetector` 41 + `InkWell` 24 | `RunicButton` con variantes primary/secondary/danger/ghost; prohibir `ElevatedButton` fuera de `core/widgets` | M | `runic_button.dart`, ~20 pantallas |
| **UX-10** | ALTO | Notificaciones | 48 `SystemSnack.show` vs **52 `SnackBar`** crudos: 30 en `welcome_screen.dart:303-684`, 6 en `profile_edit_screen.dart`, 6 en `mission_card.dart`, 4 en `settings_screen.dart:281,530` | Migrar todo a `SystemSnack`; lint que prohíba `SnackBar(` fuera de `system_snack.dart` | M | 5 archivos |
| **UX-11** | ALTO | Misiones | `QuestCard` (`quest_card.dart:48-162`) y `MissionCard` (`mission_card.dart:44`) representan lo mismo con distinto layout/radios | `MissionCard` única; `QuestCard` → `MissionCard.compact` o deprecado | M | `quest_card.dart`, `mission_card.dart`, `learning_path_roadmap.dart` |
| **UX-12** | ALTO | Global (a11y) | Solo **5 `Semantics(`** reales; botones de volver sin etiqueta salvo `missions_screen.dart:106` | `HudHeader`/`HudIconButton` con `tooltip` obligatorio; auditoría de controles icon-only | M | `core/widgets/*`, 7 cabeceras |
| **UX-13** | ALTO | Conversación | Mic hold-to-talk expone `Semantics(button: true)` **sin acción** (`conversation_mic_button.dart:160-172`): TalkBack puede enfocar pero no activar | Añadir `onTap`/`onLongPress` al `Semantics` y probar con TalkBack | S | `conversation_mic_button.dart` |
| **UX-14** | ALTO | Layout (global) | Solo **5/20** pantallas a 312 px y **2/20** a 2× (`text_scale_test.dart`); 0 `textScalerOf` | Matriz de tests 20×312 px y 20×2×; layouts con `Flexible`/`maxLines`; sin `clamp` | M | `test/*`, todas las pantallas |
| **UX-15** | ALTO | Conversación | 2 281 líneas, **cero widget tests**; anchos 78 %/85 % y alturas fijas (`:897,1622,1657`) | Extraer 4 widgets; `conversation_screen_smoke_test.dart`; `LayoutBuilder` para la barra inferior | L | `conversation_screen.dart`, `conversation_mic_button.dart` |
| **UX-16** | ALTO | Tienda | Error de red se pinta como tienda vacía ("AÚN NO HAY OBJETOS") porque no hay `hasError` (`shop_screen.dart:657-665`) | `HudState.error` con reintento; rama `catalogAsync.hasError` antes de vacío | S | `shop_screen.dart` |
| **UX-17** | ALTO | Dashboard | El estado de error dice "Mostrando el ultimo progreso guardado" cuando `!hasValue` (`dashboard_screen.dart:194-213`) | Copy honesto + `HudState.error`; si hay caché, mostrarla de verdad | S | `dashboard_screen.dart` |
| **UX-18** | ALTO | Inputs (global) | Hint al 50 % de alfa = **3.50** (`app_theme.dart:132`) | Subir a 70 % (7.77) y unificar `contentPadding` con `AppSpacing` | S | `app_theme.dart:128-150` |

---

## MEDIO (14)

| ID | Sev. | Pantalla/módulo | Problema (evidencia) | Solución | Compl. | Archivos Flutter |
|---|---|---|---|---|---|---|
| **UX-19** | MEDIO | Superficies | `AppElevation` **sin usar** (`app_elevation.dart`); glow cian hardcodeado (`glass_card.dart:100`); 7 overrides de `opacity`/`radius` (`conversation_screen.dart:516,1027,2175`, `dungeon_guardian_screen.dart:424,495,574`) | Usar `AppElevation.flat/accent/reward`; fijar radio 4 y opacidad 0.94 en `GlassCard` | S | `glass_card.dart`, `app_elevation.dart`, 2 pantallas |
| **UX-20** | MEDIO | Sistema (radios) | Persisten `BorderRadius.circular(1.5)` y `999` manuales (`segmented_bar.dart:33`, `glass_card.dart:103`) | Tokenizar `hairlineRadius` 1.5 o usar 2; `AppRadius.circleBorder` | S | `segmented_bar.dart`, `glass_card.dart` |
| **UX-21** | MEDIO | Sheets/diálogos | 10 `showModalBottomSheet`, 1 `showDialog`, 1 `DraggableScrollableSheet` sin patrón común | `HudSheet.show()` con `isScrollControlled`, `useSafeArea`, cabecera `SystemWindow` | M | `core/widgets/hud_sheet.dart` (nuevo) + 10 llamadas |
| **UX-22** | MEDIO | Global (a11y) | Solo 6 `Tooltip`; iconos de moneda/stat sin explicación | Tooltip obligatorio en icon-only; `semanticLabel` en cifras compuestas | M | HUD, tienda, gremio |
| **UX-23** | MEDIO | Dashboard dock | Los 4 destinos no declaran `Semantics(selected:)` ni rol de tab (`dashboard_screen.dart:617-660`) | `Semantics(selected: isActive, button: true)` + label | S | `dashboard_screen.dart` |
| **UX-24** | MEDIO | Layout | Solo 2 `LayoutBuilder` y 0 `constraints.maxWidth`: sin adaptación a tablet/plegable | `LayoutBuilder` en dashboard/conversación; ancho máximo 640 centrado | M | `dashboard_screen.dart`, `conversation_screen.dart` |
| **UX-25** | MEDIO | Layout | No hay bloqueo ni diseño de landscape (`SystemChrome` = 0) | Bloquear retrato en `main.dart` **o** diseñar landscape; decidir y documentar | S | `main.dart` |
| **UX-26** | MEDIO | Mis errores, informe, inventario, tienda | `context.pop()` sin `canPop()` → sin salida en deep-link (`my_errors_screen.dart:40`, `weekly_report_screen.dart:46`, `inventory_screen.dart:122`, `shop_screen.dart:377`) | Helper `popOrHome(context)`; usar en las 4 | S | 4 pantallas |
| **UX-27** | MEDIO | Listas | Solo 1 `RefreshIndicator` en 20 pantallas (Guild) | Refresco por gesto en dashboard, misiones, tienda, informe | M | 4 pantallas |
| **UX-28** | MEDIO | Ajustes | `SettingsScreen` **sin ruta** (`router.dart`), sin estado de carga de página (`settings_screen.dart:300`) | Registrar `/settings`, abrir desde dock/notificación; `HudState.loading` | S | `router.dart`, `dashboard_screen.dart`, `settings_screen.dart` |
| **UX-29** | MEDIO | Resumen | 1 238 líneas, sin widget test; estados de recompensa sin red de seguridad (`:639-660`) | Test de loading/error/pendiente + tamaño de botones | S | `session_summary_screen.dart`, `test/` |
| **UX-30** | MEDIO | i18n | **369** `l10n?.clave ?? 'TEXTO'` con fallback en español hardcodeado | Eliminar fallbacks donde `l10n` es no-nulo; lint de `?? '` en Text | L | ~40 pantallas |
| **UX-31** | MEDIO | i18n | 8 textos sin localizar (lista de idiomas, botones de conversación) (`profile_edit_screen.dart:523-527`, `conversation_screen.dart:1733,1745`) | Claves en los 3 `.arb` + `flutter gen-l10n` | S | 2 pantallas + 3 `.arb` |
| **UX-32** | MEDIO | Contraste | `crimsonRed` como texto sobre `containerHigh` = 3.73 (`system_snack.dart:20` y textos de error) | Usar `errorRed #FFB4AB` (8.45) para texto de error | S | `system_snack.dart`, textos de error |

---

## BAJO (7)

| ID | Sev. | Pantalla/módulo | Problema (evidencia) | Solución | Compl. | Archivos Flutter |
|---|---|---|---|---|---|---|
| **UX-33** | BAJO | i18n/estilo | `.toUpperCase()` sobre cadenas traducidas rompe acentos y portugués (`system_window.dart:63,74`, `shop_screen.dart:686,697`, `quest_card.dart:88`) | Usar el estilo con `letterSpacing` en vez de transformar el texto | S | 4 widgets |
| **UX-34** | BAJO | `GlassCard` | Padding por defecto 24 frente a `AppSpacing.card` 16 (`glass_card.dart:107`); opacidades 0.94/0.95/0.96 (`dungeon_guardian_screen.dart:424,495,574`) | Padding 16 por defecto; opacidad única | S | `glass_card.dart`, `dungeon_guardian_screen.dart` |
| **UX-35** | BAJO | Mis errores | Icono de volver usa `medievalText`, token de otra temática (`my_errors_screen.dart:43`) | `onSurface` | S | `my_errors_screen.dart` |
| **UX-36** | BAJO | Splash | Sin superficie de error si el warm-up falla (`splash_screen.dart:70-120`) | Log a Sentry + estado silencioso documentado | S | `splash_screen.dart` |
| **UX-37** | BAJO | Guild | `ChatRoomsScreen` sin `SafeArea` pese a `TabBar` + listas | Envolver en `SafeArea` | S | `chat_rooms_screen.dart` |
| **UX-38** | BAJO | Tests | `ExcludeSemantics` global en los tests de overflow (`overflow_test.dart:108,193,239,304`) oculta fallos de semántica | Añadir un test de semántica separado sin exclusión | S | `test/` |
| **UX-39** | BAJO | Observabilidad UX | No hay métrica de éxito por pantalla (solo eventos de analytics de producto) | Instrumentar `screen_view` + embudo onboarding/conversación/paywall | M | `analytics_taxonomy.dart`, router |

---

## Orden de ejecución sugerido

| Sprint | Entradas | Resultado medible |
|---|---|---|
| **S1** | UX-01, UX-03, UX-04, UX-05, UX-16, UX-17, UX-18, UX-26 | 0 críticos de contraste/tacto/animación; errores honestos |
| **S2** | UX-02, UX-08, UX-06, UX-07, UX-19, UX-20, UX-34 | Sistema de tokens adoptado y protegido por lints |
| **S3** | UX-09, UX-10, UX-11, UX-12, UX-13, UX-21, UX-23 | Un botón, un snack, una tarjeta, una cabecera |
| **S4** | UX-14, UX-15, UX-24, UX-25, UX-29, UX-38 | Cobertura de layout 20/20 y las 2 pantallas grandes testeadas |
| **S5** | UX-22, UX-27, UX-28, UX-30, UX-31, UX-32, UX-33, UX-35, UX-36, UX-37, UX-39 | Consistencia fina y observabilidad |

## Definición de "hecho" por entrada

1. Cambio en `lib/` con `flutter analyze` en 0 errores/0 warnings.
2. Test nuevo o existente que falle sin el cambio.
3. Si es visual (🔍), captura con el comando de `screenshots/README.md` y
   revisión humana; sin captura, la entrada queda **abierta**.
