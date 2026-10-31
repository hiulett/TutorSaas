# 07 — Resumen ejecutivo

**Auditoría UX/UI de solo lectura · 30-oct-2026**
Base `origin/master` @ `f9cffb2` · rama `docs/ui-ux-audit` · app **Dungeon of
English** (`1.0.21+22`, Android, Flutter 3.41.9).

---

## 1. Qué se hizo y qué no se pudo hacer

Se auditaron **20 pantallas, 20 rutas, 16 features y ~52 componentes** leyendo
código, calculando contraste WCAG y ejecutando la suite completa.

**Límite declarado:** el móvil estuvo conectado y la app corrió, pero **este
entorno no puede ver imágenes**. Por eso:

- Los hallazgos **visuales** salen de código, tokens y tests, no de mirar
  capturas.
- Cada pantalla está marcada `verificado por test` (9), `verificado por código`
  (1) o **`no verificable (requiere revisión visual humana)`** (10).
- `screenshots/01-arranque.png` **no es un PNG válido**: empieza con BOM
  UTF-16LE (`FF FE`) en vez de `89 50 4E 47`, porque se generó con una
  redirección de PowerShell sobre `adb exec-out`. No se ha inventado ninguna
  otra captura; en `screenshots/README.md` están los comandos para obtenerlas.

Por tanto: **nada de lo que sigue afirma cómo "se ve" la app**, solo cómo está
construida y qué ratios/tamaños produce.

---

## 2. Verificación técnica (sin tocar código)

| Comando | Resultado |
|---|---|
| `flutter analyze` | **0 errores · 0 warnings · 126 infos** |
| `flutter test` | **725 pruebas · todas en verde** (~1 min 44 s) |
| Cambios en `lib/` o `test/` | **ninguno** (`git status` solo muestra `docs/ui-ux-audit/`) |

> `AGENTS.md` dice "34 warnings + 129 infos / 171 pruebas" y `docs/HISTORY.md:42`
> dice "127 infos y 530 pruebas". Ambas cifras están **desactualizadas**; las
> reales medidas hoy son 0/126 y 725.

---

## 3. Los 5 hallazgos más graves

### 1) El design system existe, pero el código no lo usa (CRÍTICO, sistémico)

`AppSpacing` tiene **3 usos reales** (`app_theme.dart:96,111,125`) frente a
**419 `EdgeInsets` literales** con **366 objetos**; el **30 %** de sus valores
está fuera de la rejilla de 4 (2, 3, 5, 6, 7, 10, 11, 14, 18, 26, 30, 58).
`AppElevation` tiene **0 usos**. La tipografía se escribe a mano **384 veces**
(`GoogleFonts.*`) frente a 114 (`AppTypography.*`).

**Por qué importa:** cualquier rediseño futuro se aplica sobre 41 archivos con
valores únicos; no hay una fuente de verdad efectiva. Evidencia completa en
`01` §1.1-1.2.

### 2) El botón primario no pasa AA (CRÍTICO)

`RunicButton` usa por defecto fondo `runeViolet #9D4EDD` con texto
`onSurface #E1E2ED`: **3.57:1** a 16 px bold (el umbral de "texto grande" es
18.66 px bold, así que no aplica la excepción). Falla WCAG AA.
`runic_button.dart:13-25`; el mismo par aparece en `chat_rooms_screen.dart:452,643-644`.

Peor aún, los botones **destructivos** usan `crimsonRed` con `onSurface`:
**2.99:1** (`settings_screen.dart:1536-1537`, `progress_tab_view.dart:230-231`).

### 3) Objetivos táctiles de 24 dp (CRÍTICO)

El resumen de sesión —el momento de recompensa— tiene cerrar y siguiente de
**24×24** (`session_summary_screen.dart:524-530,544-550`). También: 40×40 en
`_RoundIconButton` (`:1045-1051`) y en el guardián (`dungeon_guardian_screen.dart:752-760`),
44×44 para volver en perfil (`profile_edit_screen.dart:282-285`), 46 de alto en
resultado de jefe (`boss_exam_result_screen.dart:129,141`).

Mínimo recomendado por Material/Android: **48×48 dp**.

### 4) 12 de 14 animaciones infinitas ignoran "reducir movimiento" (CRÍTICO)

Solo `RunicButton` (`runic_button.dart:67`) y `DungeonGuardianScreen`
(`:44-47`) consultan `MediaQuery.disableAnimationsOf`. Siguen animando en
infinito: `GlassCard` (`glass_card.dart:60`), fondo `CyberManhwaBackground`
(`:55,60,65,70`), monstruo arrastrable (`:46,52,58,64`), waveform
(`voice_waveform_visualizer.dart:30`) y roadmap (`learning_path_roadmap.dart:553,561`).
Para usuarios con sensibilidad vestibular es un bloqueo real, no un detalle.

### 5) La pantalla más importante no tiene ni un test de UI (ALTO)

`ConversationScreen` tiene **2 281 líneas**, es el corazón del producto (voz,
tutor, correcciones) y **no se instancia en ningún test de widget** ni en
`overflow_test` ni en `text_scale_test`. Tampoco `SessionSummaryScreen`
(1 238 líneas), `OnboardingScreen` (1 219), `SettingsScreen` (1 557),
`VoiceRoomScreen` (1 185). Solo 5 de 20 pantallas están probadas a 312 px y 2 a
escala 2×. Cualquier regresión de layout en la conversación llega a producción
sin red.

---

## 4. Tabla de contraste (resumen)

Fórmula: `L = 0.2126R + 0.7152G + 0.0722B` con linealización
`c/12.92` si `c ≤ 0.03928`, si no `((c+0.055)/1.055)^2.4`;
`ratio = (L₁+0.05)/(L₂+0.05)`.

| Combinación | Ratio | Veredicto |
|---|---|---|
| `onSurface` sobre `voidBg` | **15.63** | AAA ✅ |
| `onSurface` sobre glass (94 %) | **14.48** | AAA ✅ |
| `onSurfaceVariant` sobre `voidBg` | **11.80** | AAA ✅ |
| `manaCyan` sobre `voidBg` | **13.09** | AAA ✅ |
| `royalGold` sobre `voidBg` | **12.87** | AAA ✅ |
| `emeraldGreen` sobre `voidBg` | **12.06** | AAA ✅ |
| `outline` sobre `containerHigh` | **4.51** | AA (límite) ⚠️ |
| `crimsonRed` sobre `containerHigh` | **3.73** | AA-large ❌ texto normal |
| `runeViolet` sobre `voidBg` (como texto) | **4.38** | AA-large ❌ texto normal |
| **`onSurface` sobre `runeViolet` (RunicButton)** | **3.57** | **FALLA** ❌ |
| **`onSurface` sobre `crimsonRed` (destructivo)** | **2.99** | **FALLA** ❌ |
| **`white` sobre `royalGold` (`onSecondary`)** | **1.56** | **FALLA** ❌ |
| **hint al 50 % sobre `containerLow`** | **3.50** | **FALLA** ❌ |
| `white` sobre `runeViolet` (propuesta) | **4.60** | AA ✅ |
| `voidBg` sobre `crimsonRed` (propuesta) | **5.23** | AA ✅ |

La paleta base es sólida. El fallo está en **usar acentos como texto** y en los
`on-colors` de violeta/carmesí/dorado. Detalle en `03` §1 y corrección en `04` §2.

---

## 5. Estado por pantalla y verificabilidad

| Estado | Nº | Pantallas |
|---|---|---|
| Verificado por test de widget | 9 | Dashboard, Welcome, ChatRooms, DungeonGuardian, Shop, ListeningQuiz, BossExamResult, MiniConversation, Paywall |
| Verificado solo por código | 1 | Splash |
| **No verificable (revisión visual humano)** | **10** | Onboarding, Conversación, Resumen, Perfil, VoiceRoom, Inventario, Mis errores, Informe semanal, Misiones, Ajustes |

---

## 6. Reconciliación con la documentación previa (gana el código)

| Documento dice | Código real | Veredicto |
|---|---|---|
| `03-PANTALLAS…:10` "Rutas registradas (14)" | **20** rutas (`router.dart:34-139`) | **Desactualizado** |
| `03-PANTALLAS…:218` "No hay pantalla de misiones" | Existe `/missions` (`router.dart:136-139`, `missions_screen.dart`, 228 líneas) | **Obsoleto** |
| `03-PANTALLAS…:209` "+80 XP fijo" y botón de vocabulario que no navega | Recompensas reales de `apply_session_rewards` (`session_summary_screen.dart:588-660`) y el botón abre `SrsFlashcardModal` (`:691-692`) | **Obsoleto** |
| `03-PANTALLAS…:208` herramienta de desarrollo destructiva accesible en producción | El bloque está dentro de `if (kDebugMode)` (`settings_screen.dart:203`) | **Corregido en el código; el doc está mal** |
| `03-PANTALLAS…:213` el onboarding no permite volver atrás | Hay botón "atrás" (`onboarding_screen.dart:193-198`); lo que no hay es *swipe* (`PageView` con `NeverScrollableScrollPhysics`, `:518-520`) | **Parcialmente obsoleto** |
| `03-PANTALLAS…:121` `conversation_screen.dart` 1 462 líneas | **2 281** | Desactualizado |
| `03-PANTALLAS…:179` `settings_screen.dart` 1 361 líneas | **1 557** | Desactualizado |
| `03-PANTALLAS…:207` `/disruption` referenciada y no registrada | Solo existe como mapeo de sección de presencia (`presence_providers.dart:61`); no hay navegación a esa ruta | **Sin efecto práctico** |
| `HISTORY.md:42` "127 infos y 530 pruebas" | **126 infos y 725 pruebas** (30-oct) | Desactualizado |
| `HISTORY.md:40` solo `SegmentedBar` conserva pixel-golden | Cierto: `test/golden/goldens/segmented_bar.png` es el único PNG de referencia | ✅ Vigente |
| `AGENTS.md` "34 warnings + 129 infos / 171 pruebas" | 0 warnings, 126 infos, 725 pruebas | Desactualizado |

Ninguna de estas discrepancias cambia la conclusión de la auditoría; sí cambian
las cifras que un revisor debería citar.

---

## 7. Qué propone el rediseño (sin inventar paleta)

1. **Completar el sistema**: 4 estilos tipográficos que faltan (20/14/12/11 px),
   tokens `hairline(2)`/`compact(6)`, `AppElevation` en uso, `onTertiary`/
   `onError` explícitos (`04`).
2. **Un componente por rol**: `RunicButton`, `HudHeader`, `HudIconButton`,
   `SystemSnack`, `MissionCard`, `HudState` (cargando/vacío/error/offline/pendiente).
3. **Accesibilidad como contrato**: 48 dp, `Semantics` con acción, reduce-motion y
   2× de texto verificados por lint/test, no por inspección.
4. **Rediseños concretos** en Dashboard, Conversación, Resumen, Ajustes y
   Misiones/Tienda (`05`), todos con archivos y criterio de verificación.
5. **39 entradas de backlog** priorizadas en 5 sprints (`06`); el sprint 1
   (8 entradas) elimina los 4 críticos sin tocar la identidad visual.

Referentes (Airbnb, Uber, Revolut, Spotify, Notion, Duolingo) se usan **solo
como principios** —una acción primaria, divulgación progresiva, color semántico,
reanudación, superficies tranquilas, camino único— nunca como plantillas.

---

## 8. Cómo cerrar la parte no verificable

1. Reconectar el móvil y ejecutar los comandos de `screenshots/README.md`.
2. Revisar las 10 pantallas marcadas y anotar solo lo que se vea: jerarquía,
   glow, densidad, alineación óptica.
3. Repetir Dashboard, Conversación y Ajustes con la fuente del sistema al máximo.
4. Pasar TalkBack por Conversación (mic), Resumen (cerrar/siguiente) y Ajustes
   (borrar cuenta).
5. Solo entonces mover las entradas 🔍 de `06` a "hecho".

---

## 9. Entregables

| Documento | Contenido |
|---|---|
| `01-project-analysis.md` | Alcance, límite de visión, métricas medidas, arquitectura UI |
| `02-screen-inventory.md` | 20 pantallas: ruta, propósito, entrada/salida, estados, tests, verificabilidad |
| `03-ux-ui-audit.md` | Contraste WCAG, tipografía, espaciado, componentes, a11y, responsive, estados, i18n (49 hallazgos) |
| `04-design-system-proposal.md` | Tokens, 15 estilos, roles de color, componentes, motion, gobernanza |
| `05-redesign-proposals.md` | 6 principios de referentes + 5 rediseños con archivos y verificación |
| `06-improvement-backlog.md` | 39 entradas CRÍTICO/ALTO/MEDIO/BAJO con complejidad y archivos |
| `07-executive-summary.md` | Este documento |
| `screenshots/README.md` | Estado real de la captura y cómo obtenerlas |

**Pull request:** https://github.com/hiulett/TutorSaas/pull/238 (`--base master`, sin merge)
