# 04 — Mejoras de la Creación de Personaje

> Documento de propuesta (no ejecución). No modifica código.
> Archivo objetivo: `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`
> (211 líneas).

---

## 1. Estado actual (datos reales del código)

El wizard de creación de personaje vive en `character_creation_wizard.dart` y ya está
migrado a tokens: usa `GlassCard`, `AppColors` y `GoogleFonts` (sin hex hardcodeados).
Flujo completo: título + subtítulo → campo de nombre → selector de avatar → selector de
clase → botón continuar.

### Estructura de datos

| Elemento | Detalle |
|---|---|
| `CharacterCreationData` | `name: String`, `playerClass: String`, `avatarIndex: int` (default 0) |
| Estado local | `_selectedClass = 'warrior'`, `_selectedAvatar = 0`, `_nameController` |
| Validación | `_isValid => _nameController.text.trim().length >= 2` |
| Animación existente | `_pulseController` (`AnimationController`, duración 2 s, `repeat(reverse: true)`) — actualmente declarado pero **no aplicado a ningún widget** en el build |

### Selección de clase (3 opciones)

| id | Nombre UI | Icono (Material) | Color | Descripción |
|---|---|---|---|---|
| `warrior` | Berserker | `Icons.shield_rounded` | `AppColors.crimsonRed` | "Extrovertido, hablas primero y piensas después…" |
| `mage` | Mago Arcano | `Icons.auto_awesome_rounded` | `AppColors.runeViolet` | "Analítico, observas y estructuras antes de hablar…" |
| `rogue` | Pícaro | `Icons.explore_rounded` | `AppColors.emeraldGreen` | "Práctico, aprendes sobre la marcha…" |

Implementación actual: cada tarjeta es un `GlassCard` dentro de un `GestureDetector`
(`onTap` → `setState`). Diferenciación de estado:

- `blur: 4`, `opacity`: `0.12` si seleccionado / `0.03` si no.
- `border`: 2 px del color de la clase si seleccionado / 1 px `onSurface` α 0.08 si no.
- Layout: `Row` → caja de icono (bg color α 0.2, radio 4 px) + `Column` (nombre bold + desc 12 px) + check final (`check_circle_rounded` / `radio_button_unchecked_rounded`).

### Selección de avatar (6 opciones)

| # | Icono | Color |
|---|---|---|
| 0 | `Icons.person` | `manaCyan` |
| 1 | `Icons.face_3_rounded` | `runeViolet` |
| 2 | `Icons.face_4_rounded` | `emeraldGreen` |
| 3 | `Icons.face_5_rounded` | `royalGold` |
| 4 | `Icons.face_6_rounded` | `presencePink` |
| 5 | `Icons.face_2_rounded` | `royalGold` (**duplicado de #3**) |

Implementación actual: `Row` con `GestureDetector` + `AnimatedContainer` (200 ms),
círculo de 48×48, `BoxDecoration` (fondo color α 0.2 seleccionado / `onSurface` α 0.04 no;
borde 2 px color si seleccionado / 1 px si no; `boxShadow` blur 8 cuando seleccionado).
Icono a color si seleccionado / `onSurface` α 0.38 si no.

### Campo de nombre

- Etiqueta `JetBrainsMono` 10 bold (α 0.7) — ya estilo System HUD.
- `TextField` con `SpaceGrotesk` 20 bold; `filled`, `fillColor` `onSurface` α 0.05.
- Borde radio 4 px: `enabledBorder` `onSurface` α 0.1 / `focusedBorder` `manaCyan` pleno /
  borde base `manaCyan` α 0.3.
- `onChanged` → `setState` (habilita/deshabilita continuar).

### Botón continuar

- `ElevatedButton` con `backgroundColor: AppColors.manaCyan`, `foregroundColor: onSurface`,
  padding 48×16, deshabilitado `onSurface` α 0.12.
- Texto `'EL ORÁCULO TE ESPERA'` (`JetBrainsMono` 14 bold, letterSpacing 1.5).

### Puntos débiles detectados

1. El estado "seleccionado" de las tarjetas de clase es sutil (solo borde + opacidad); no
   hay glow, check animado ni feedback de press/hover. No se siente como selección de clase
   inicial de un RPG moderno.
2. Los avatares son círculos 48 px con `AnimatedContainer`; sin anillo de selección
   prominente ni escala.
3. `_pulseController` se declara y descarta pero **nunca se usa** en el build (código
   muerto / animación prevista sin aplicar).
4. El botón continuar es un `ElevatedButton` plano; el patrón del proyecto es `RunicButton`
   (`lib/core/widgets/runic_button.dart`), ya usado p. ej. en `hunter_status_screen.dart:279`.
5. Sin animaciones de entrada (`AppMotion` existe en `lib/core/theme/app_motion.dart` con
   `micro/fast/standard/reward/ambient` y soporte `reduce-motion`).

---

## 2. PROPUESTA

Guía: las tarjetas deben leerse como **selección de clase inicial de un RPG moderno**
(Final Fantasy / Genshin / Diablo aesthetic): estado seleccionado inconfundible, respuesta
táctil inmediata y jerarquía visual clara.

### 2.1 Tarjetas de selección de clase → selección de clase RPG

**Cómo:**

- **Estado seleccionado con borde rúnico + glow + check:**
  - Borde del color de la clase con glow exterior (`BoxShadow` color de clase α 0.3–0.4,
    blur 12–16, offset (0,2)) — mismo lenguaje de glow que `RunicButton` (`runic_button.dart:87-95`).
  - Opcional: `GlassCard.showRunicCorners: true` con `runicColor` = color de la clase para
    las esquinas rúnicas en el seleccionado.
  - Check: animar a `Icons.check_circle_rounded` con `AnimatedSwitcher` o `TweenAnimationBuilder`
    (scale in, `AppMotion.curveSpring`).
- **Hover/press feedback (patrón RunicButton):**
  - Envolver el `GlassCard` con un `GestureDetector` que gestione `onTapDown/onTapUp/onTapCancel`
    y escale la tarjeta a ~0.97 con `AppMotion.micro` / `AppMotion.curvePress` (mismo patrón que
    `_RunicButtonState`, `runic_button.dart:60-62`).
  - En desktop/web añadir estado hover (`MouseRegion`) que eleve la opacidad/glow de la tarjeta
    como feedback previo.
- **Icono grande:** subir el contenedor del icono de 24 → 40–48 px, redondeado (radio 4 px o
  círculo), con doble capa (fondo α 0.2 + glow) para que el símbolo de clase sea el punto focal.
- **Descripción corta:** mantener el `Column` (nombre bold + desc 12 px), pero reservar
  espacio fijo en las 3 tarjetas para que el layout no "brinque" al seleccionar (las
  descripciones tienen longitudes distintas).

**Impacto:** la decisión de clase pasa de un toggled-list genérico a un momento de "build"
memorable; refuerza la fantasía del System HUD. Riesgo bajo: es solo presentación.

**Riesgos:**
- `GlassCard.showRunicCorners` con blur alto puede competir visualmente con el texto si no se
  prueba en dispositivos pequeños.
- Escala en press puede "salir" del padding del `SingleChildScrollView` si se combina con
  transform; asegurar `clipBehavior` / márgenes.
- Cuidar el contraste del texto de descripción sobre el fondo α 0.12 + glow.

### 2.2 Avatares → orbes con anillo de selección

**Cómo:**

- Convertir cada avatar en un **orbe**: círculo de ~56–64 px con gradiente sutil del color
  del avatar, icono centrado y un **anillo de selección** concéntrico (`Container` con borde
  del color, `ring` gap de 3 px, posiblemente un segundo anillo exterior α 0.3).
- Estado seleccionado: anillo + glow del color (como ya hay boxShadow) + escala 1.1 con
  `AppMotion.fast` / `curveSpring`.
- Estado no seleccionado: atenuar a α 0.45 con borde `onSurface` α 0.12.
- Eliminar la duplicación de color del avatar #5 (`royalGold` repetido) → usar un color libre
  (p. ej. `collabBlue` / `vocabularyBlue` / `tutorBubbleBlue`) para que los 6 orbes sean
  cromáticamente distinguibles.
- Añadir `Semantics(selected: isSelected, label: 'Avatar ${i+1}')` para accesibilidad.

**Impacto:** los orbes se leen como identidad visual (no como checkboxes circulares); la
duplicación cromática desaparece. Riesgo bajo.

**Riesgos:**
- 6 orbes de 64 px en `spaceEvenly` pueden apretar en pantallas angostas (<360 dp); evaluar
  `Wrap` o tamaño adaptativo (48 px en móvil pequeño).
- Más superficie de toque = revisar que no se pisen los hit-boxes (los `GestureDetector` son
  del tamaño del contenedor).

### 2.3 Animaciones de entrada (AppMotion)

**Cómo:**

- Aplicar entradas escalonadas a cada sección (título → nombre → avatares → clases →
  botón) usando `TweenAnimationBuilder` o `AnimatedSlide+FadeTransition` con `AppMotion.fast`
  y `AppMotion.curveStandard`, con `Interval`/delay escalonado (~40–60 ms por sección).
- **Materializar `_pulseController`** (hoy es código muerto): usarlo para un pulso ambiental
  del glow del avatar/clase seleccionados (loop, `AppMotion.ambient` 2 s) — coincide con la
  duración ya declarada.
- Toda duración debe pasar por `AppMotion.of(context, duration)` para respetar
  `MediaQuery.disableAnimationsOf` (reduce-motion), patrón A11Y-04.

**Impacto:** percepción de calidad "polished" sin coste de lógica. Riesgo bajo si se
respetan los tokens y el reduce-motion.

**Riesgos:**
- Acumular `AnimationController`s (pulse + entradas) requiere `SingleTickerProviderStateMixin`
  → pasar a `TickerProviderStateMixin` o usar `TweenAnimationBuilder` (sin controllers extra).
- Entradas escalonadas + `SingleChildScrollView` pueden recalcular layout al aparecer;
  usar `Opacity+Transform` (no reconstrucción) para no invalidar el scroll.

### 2.4 Botón continuar → RunicButton

**Cómo:**

- Sustituir el `ElevatedButton` por `RunicButton` (`lib/core/widgets/runic_button.dart`):
  `label: 'EL ORÁCULO TE ESPERA'`, `icon: Icons.auto_awesome_rounded` (opcional),
  `backgroundColor: AppColors.manaCyan`, `foregroundColor: AppColors.voidBg`,
  `onPressed: _isValid ? ... : null`, `isBusy` para el estado de guardado si se añade.
- `RunicButton` ya aporta scale-on-press (150 ms), glow y radio 4 px por defecto; se obtiene
  consistencia con el resto del onboarding/dashboard (p. ej. `hunter_status_screen.dart:279`).
- Mantener el estado deshabilitado: `RunicButton` ya degrada a `onSurface` α 0.12 cuando
  `onPressed == null` (`runic_button.dart:68`).

**Impacto:** consistencia de micro-interacción y ahorro de código duplicado. Riesgo nulo.

**Riesgos:**
- `RunicButton` usa `ElevatedButton.styleFrom` interno con `padding vertical: 16` fijo; el
  ancho/padding horizontal actual (48) se pierde → envolver en `SizedBox`/`ConstrainedBox` si
  se quiere mantener la silueta.

### 2.5 Campo de nombre → estilo System HUD

**Cómo (ajuste fino, ya está a medio camino):**

- Mantener la etiqueta `JetBrainsMono` 10 bold como "NOMBRE DEL CAZADOR" (ya correcta).
- Reforzar el estilo HUD: `fillColor` `onSurface` α 0.05 → `surfaceContainerLow`
  (`#191B23`) para alinear con el `inputDecorationTheme` global de `app_theme.dart:128-150`
  (que usa `surfaceContainerLow` + `outlineVariant`).
- Alinear bordes con el tema global: `enabledBorder` `outlineVariant` α 1.5 / `focusedBorder`
  `manaCyan` 2.0 / `errorBorder` `crimsonRed` (reutilizar el `InputDecorationTheme` en vez de
  bordes ad-hoc).
- Opcional: contador de caracteres mono (p. ej. "4/16") con `JetBrainsMono` 10 para
  feedback de validación estilo terminal.
- Mantener radio 4 px (estándar del DS).

**Impacto:** el input se integra con el resto del sistema (ya no usa bordes "personalizados"
que divergen del tema). Riesgo nulo-bajo.

**Riesgos:**
- Cambiar el `fillColor` altera el contraste visual del hint (α 0.24); verificar legibilidad
  sobre `surfaceContainerLow`.
- Si se hereda `inputDecorationTheme`, el hint pasa a `JetBrainsMono` (el tema global lo
  define así) en vez de `SpaceGrotesk` actual — decidir si es deseable.

---

## 3. Resumen de decisiones por elemento

| # | Elemento | Estado actual | Propuesta | Impacto | Riesgo |
|---|---|---|---|---|---|
| 2.1 | Tarjetas de clase | Borde + opacidad sutil | Borde rúnico + glow + check animado + hover/press (RunicButton pattern) + icono grande | Alto (moment RPG) | Medio (layout/contraste) |
| 2.2 | Avatares | Círculos 48 px, sin anillo, 1 color duplicado | Orbes con anillo de selección + glow + escala + color único | Alto | Bajo-Medio (pantallas angostas) |
| 2.3 | Animaciones | `_pulseController` muerto, sin entradas | Entradas escalonadas con AppMotion + pulso ambiental real + reduce-motion | Medio | Bajo (controllers) |
| 2.4 | Botón continuar | `ElevatedButton` plano manaCyan | `RunicButton` (press-scale + glow) | Medio | Nulo-Bajo (padding fijo) |
| 2.5 | Nombre | Casi HUD, bordes ad-hoc | Alinear a `inputDecorationTheme` global + contador mono | Bajo | Nulo-Bajo |

---

## 4. Notas de implementación (para la fase de ejecución)

- No reintroducir hex: usar solo `AppColors` (paleta vigente: `voidBg #05070E`, `manaCyan
  #00E5FF`, `royalGold #FFC700`, `runeViolet #9D4EDD`, `emeraldGreen #00E676`).
- Aprovechar `AppMotion` (`lib/core/theme/app_motion.dart`) para duraciones/curvas y
  `AppMotion.of(context, …)` para reduce-motion.
- `GlassCard` (`lib/core/widgets/glass_card.dart`) soporta `borderColor`, `showRunicCorners`
  y `runicColor` para el estilo rúnico.
- Validar con `flutter analyze` (barra: 0 errores) y en dispositivo con `flutter run`.
