# 04 — Propuesta de Design System

**Regla de oro:** no se inventa paleta ni familias nuevas. Todo sale de
`app_colors.dart`, `app_theme.dart`, `app_spacing.dart`, `app_radius.dart`,
`app_typography.dart` y del uso real medido en `lib/`.

Objetivo: **cerrar la brecha entre el sistema declarado y el implementado**
(3 usos de `AppSpacing` vs 419 literales; 0 usos de `AppElevation`; 5 `Semantics`
reales). No es un rebranding.

---

## 1. Principios

| # | Principio | Consecuencia medible |
|---|---|---|
| P1 | **Un token, un uso** | Todo `EdgeInsets` numérico pasa a `AppSpacing.*`; un lint lo impide |
| P2 | **Contraste antes que estética** | Ningún texto < 4.5:1; los acentos se usan como relleno, no como texto |
| P3 | **Ritmo de 4 px con dos excepciones declaradas** | 2 px (hairline) y 6 px (compacto) son tokens, no accidentes |
| P4 | **Mínimo legible 11 px** | Se eliminan 7/8/9/10 px como tamaños de lectura |
| P5 | **Un solo botón, un solo snack, una sola cabecera** | `RunicButton`, `SystemSnack`, `HudHeader` |
| P6 | **Accesible por defecto** | 48 dp, `Semantics`, reduce-motion y 2× de texto son parte del componente |
| P7 | **Sin capturas no hay "hecho"** | Cada componente nuevo entra con test de layout a 312 px y 2× |

---

## 2. Color

### 2.1 Estructura de roles (sin cambiar la paleta)

| Rol | Token actual | Uso | Sobre |
|---|---|---|---|
| Fondo raíz | `voidBg #05070E` | Scaffold, dock | — |
| Superficie 1 | `surface #11131B` | Cards (`surfaceGlass` 94 %) | — |
| Superficie 2 | `surfaceContainerLow #191B23` | Inputs, chips | — |
| Superficie 3 | `surfaceContainerHigh #272A32` | SnackBar, hover | — |
| Texto primario | `onSurface #E1E2ED` | Títulos, cuerpo | 11.1–15.6 ✅ |
| Texto secundario | `onSurfaceVariant #BAC9CC` | Descripciones | 8.4–11.8 ✅ |
| Texto terciario | `outline #849396` | Labels mono | 4.5–6.3 ✅ (mínimo justo) |
| Acento acción | `manaCyan #00E5FF` | CTA, foco, progreso | 9.3–13.1 ✅ |
| Acento recompensa | `royalGold #FFC700` | XP, oro, logros | 9.2–12.9 ✅ |
| Acento social | `runeViolet #9D4EDD` | Gremio, plan PRO | **solo relleno** |
| Peligro | `crimsonRed #FF1744` | Destructivo, errores | **solo relleno con `voidBg`** |
| Éxito | `emeraldGreen #00E676` | Confirmación | 8.6–12.1 ✅ |

### 2.2 Reglas de "on-color" (verificadas)

| Relleno | Texto permitido | Ratio | Texto prohibido |
|---|---|---|---|
| `manaCyan` | `voidBg` | 13.09 | `white` (1.54), `onSurface` (1.19) |
| `royalGold` | `voidBg` | 12.87 | **`white` 1.56** (`onSecondary` actual ❌) |
| `emeraldGreen` | `voidBg` | 12.06 | `white` |
| `runeViolet` | **`white` 4.60** | AA | `onSurface` 3.57 ❌, `runeVioletText` 3.91 ❌ |
| `crimsonRed` | **`voidBg` 5.23** | AA | `onSurface` 2.99 ❌, `white` 3.85 ❌ |

**Acción concreta:** cambiar `colorScheme.onSecondary` de `Colors.white` a
`voidBg` (`app_theme.dart:19`) y añadir `onTertiary`/`onError` explícitos:
`onTertiary = Colors.white`, `onError = voidBg`.

### 2.3 Texto con acento violeta

`runeViolet` **no se usa como color de texto**. Para texto violeta existen ya
los tintes: `runeVioletText #F8E7FF` (17.13 sobre `voidBg`) y
`runeVioletContainer #E6C3FF` (13.05). Regla: `textTertiary = runeVioletText`.

### 2.4 Alfa: mínimo para texto

| Alfa sobre `onSurface` | Ratio sobre voidBg | Permitido |
|---|---|---|
| 100 % | 15.63 | ✅ |
| 70 % | 7.77 | ✅ |
| 50 % | 4.36 | ⚠️ límite (solo si es ≥18.66 px bold) |
| 25 % | 1.88 | ❌ (nunca texto) |

Regla: **el texto nunca baja del 70 % de alfa**. Los velos al 5–12 % se reservan
a fondos y divisores. El caso real que incumple hoy es el hint de los inputs:
`onSurfaceVariant` al 50 % sobre `surfaceContainerLow` = **3.50**
(`app_theme.dart:132`).

---

## 3. Tipografía (15/15 estilos)

Familias empaquetadas: **Space Grotesk** (display/títulos), **Inter** (cuerpo),
**JetBrains Mono** (HUD, cifras, etiquetas). `allowRuntimeFetching = false`
(`main.dart:24`).

| Estilo | Familia | px | Peso | Tracking | Color | Estado |
|---|---|---|---|---|---|---|
| `displayLarge` | Space Grotesk | 48 | 800 | −0.96 | `onBackground` | existe |
| `displayMedium` | Space Grotesk | 32 | 800 | −0.64 | `onBackground` | existe |
| `displaySmall` | Space Grotesk | 24 | 700 | 0 | `onBackground` | existe |
| `headlineLarge` | Space Grotesk | 28 | 700 | 0 | `onSurface` | existe |
| `headlineMedium` | Space Grotesk | 22 | 600 | −0.24 | `onSurface` | existe |
| **`headlineSmall`** | **Space Grotesk** | **20** | **700** | **0** | **`onSurface`** | **NUEVO** |
| `titleLarge` | Space Grotesk | 18 | 600 | 0 | `onSurface` | existe |
| `titleMedium` | Space Grotesk | 16 | 600 | 0 | `onSurface` | existe |
| **`titleSmall`** | **Space Grotesk** | **14** | **600** | **0.2** | **`onSurface`** | **NUEVO** |
| `bodyLarge` | Inter | 16 | 400 | 0 | `onSurface` | existe |
| `bodyMedium` | Inter | 14 | 400 | 0 | `onSurfaceVariant` | existe |
| **`bodySmall`** | **Inter** | **12** | **400** | **0** | **`onSurfaceVariant`** | **NUEVO** |
| `labelLarge` | JetBrains Mono | 12 | 700 | 1.2 | `outline` | existe |
| `labelMedium` | JetBrains Mono | 10 | 600 | 1.0 | `outline` | existe |
| **`labelSmall`** | **JetBrains Mono** | **11** | **600** | **0.8** | **`outline`** | **NUEVO** |

### 3.1 Justificación de los 4 estilos nuevos (datos reales)

| Estilo nuevo | Reemplaza | Usos medidos |
|---|---|---|
| `headlineSmall` 20 | `fontSize: 20` suelto | 9 |
| `titleSmall` 14 | `fontSize: 14` suelto | 23 |
| `bodySmall` 12 | `fontSize: 12` suelto | **103** |
| `labelSmall` 11 | `fontSize: 11` suelto | **92** |

Así los 4 estilos que hoy caen en Roboto dejan de ser deuda y, además, absorben
**227 de las 243** declaraciones pequeñas. `fontSize: 7/8/9` se migra a
`labelSmall` (11) o `labelMedium` (10) con `letterSpacing` reducido.

### 3.2 Reglas de uso

1. Nunca `GoogleFonts.*` en una pantalla: solo `Theme.of(context).textTheme.*` o
   `AppTypography.*` (hoy 384 vs 114).
2. Máximo **2 tamaños** por bloque visual (título + cuerpo).
3. `height`: cuerpo 1.45; titulares 1.15; mono 1.3. Hoy se ve `height: 1.2` y
   `1.3` sueltos (`quest_card.dart:94,105`).
4. Prohibido `fontSize` < 11 para texto que se lee. 10 queda para badges;
   7/8/9 desaparecen.
5. `AppTypography.tiny` (9 px) se **depreca** y se sustituye por `labelSmall`.

### 3.3 Migración de `AppTypography`

Hoy expone 8 atajos con tamaños que no coinciden con el `TextTheme`
(26/18/15/14/13/11/12/9). Se alinea a los 15 estilos y se conservan los nombres
como alias documentados:

```dart
// app_typography.dart (propuesta)
static TextStyle headline(BuildContext c) => _t(c).headlineLarge!;   // 28
static TextStyle title(BuildContext c)    => _t(c).titleLarge!;      // 18
static TextStyle subtitle(BuildContext c) => _t(c).titleSmall!;      // 14
static TextStyle body(BuildContext c)     => _t(c).bodyMedium!;      // 14
static TextStyle bodyMuted(BuildContext c)=> _t(c).bodySmall!;       // 12
static TextStyle label(BuildContext c)    => _t(c).labelLarge!;      // 12
static TextStyle stat(BuildContext c)     => _t(c).titleMedium!;     // 16
// tiny: deprecado → labelSmall (11)
```

---

## 4. Espaciado

### 4.1 Escala propuesta (extiende `AppSpacing`, no la reemplaza)

| Token | px | Uso | Hoy |
|---|---|---|---|
| `hairline` | **2** | Separación entre icono y texto, bordes | 22 usos literales |
| `xs` | 4 | Gap mínimo | existe |
| `compact` | **6** | Chips, filas densas | 36 usos literales |
| `sm` | 8 | Gap estándar | existe |
| `md` | 12 | Padding de tarjeta compacta | existe |
| `lg` | 16 | Gutter estándar / padding de card | existe |
| `xl` | 20 | Margen móvil | existe |
| `xxl` | 24 | Padding de pantalla | existe |
| `xxxl` | 32 | Separación de secciones | existe |
| `huge` | 48 | Bloques hero | existe |

**No se añaden 10 ni 14**: los 92 usos de `10` y `14` se normalizan
(`10 → 8 o 12`; `14 → 12 o 16`) salvo cuando son tamaño de icono.

### 4.2 Mapa de normalización (medido)

| Valor actual | Usos | Destino | Nota |
|---|---|---|---|
| 2 | 22 | `hairline` | token nuevo |
| 3 | 13 | `xs` (4) | bordes internos |
| 5 | — | `xs` (4) o `compact` (6) | — |
| 6 | 36 | `compact` | token nuevo |
| 7 | — | `sm` (8) | — |
| 10 | 49 | `sm` (8) o `md` (12) | según densidad |
| 11 | 10 | `md` (12) | — |
| 14 | 43 | `md` (12) o `lg` (16) | según contenedor |
| 18 | 2 | `xl` (20) | — |
| 26 | 1 | `xxl` (24) | — |
| 30 | 1 | `xxxl` (32) | — |
| 58 | 1 | `huge` (48) + `sm` | caso aislado |

Resultado esperado: **0 valores fuera de escala** y 419 literales → ~0.

### 4.3 Presets (mantener y añadir)

```dart
static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: xxl, vertical: lg);
static const EdgeInsets card = EdgeInsets.all(lg);
static const EdgeInsets compact = EdgeInsets.all(md);
static const EdgeInsets button = EdgeInsets.symmetric(horizontal: xxl, vertical: lg);
static const EdgeInsets sheet = EdgeInsets.fromLTRB(xxl, lg, xxl, xxxl); // nuevo
static const EdgeInsets listRow = EdgeInsets.symmetric(horizontal: lg, vertical: md);
```

---

## 5. Radios y elevación

| Token | px | Uso obligatorio |
|---|---|---|
| `AppRadius.sm` | 4 | Cards, botones, inputs, diálogos, chips (identidad) |
| `AppRadius.md` | 8 | Contenedores destacados (máx. 1 por pantalla) |
| `AppRadius.lg` | 12 | Pills de estado |
| `AppRadius.circle` | 999 | Avatares y orbes **solamente** |

- Prohibido `BorderRadius.circular(1.5)` y `999` manuales
  (`segmented_bar.dart:33`, `glass_card.dart:103`).
- `AppElevation` pasa a usarse de verdad:

| Token | Valor | Uso |
|---|---|---|
| `none` | `[]` | Superficies planas |
| `flat` | sombra negra 8 % blur 4 | Cards sobre `voidBg` |
| `accent` | glow cian 35 % blur 12 | CTA primario (**hoy hardcodeado** en `glass_card.dart:100`) |
| `reward` | glow dorado 35 % blur 16 | Recompensas |

Regla: el glow **no** se aplica a contenedores de contenido (solo a CTA,
recompensa y elementos interactivos), para que el foco visual sea único.

---

## 6. Estados estándar (5, no 20 variantes)

| Estado | Componente | Especificación |
|---|---|---|
| **Cargando** | `HudLoading` | Spinner 22 px + label `labelMedium`; nunca pantalla en blanco |
| **Vacío** | `HudEmpty` | Icono 48, título `titleMedium`, hint `bodySmall`, CTA opcional |
| **Error** | `HudError` | Icono `cloud_off`, mensaje accionable, botón "REINTENTAR" (48 dp) |
| **Sin conexión con caché** | `HudOfflineBanner` | Franja superior; el contenido se muestra con datos cacheados |
| **Pendiente / confirmando** | `HudPending` | Texto + spinner inline; aplica a recompensas (`summary_reward_pending`) |

Reglas:
1. **Error ≠ vacío.** La tienda hoy muestra "AÚN NO HAY OBJETOS" ante fallo de
   red (`shop_screen.dart:657-665`); con este contrato es imposible.
2. El mensaje de error incluye **qué falló y qué hacer**, nunca solo "Error".
3. El estado vacío **no** usa cifras (ceros) como progreso.

```dart
class HudState extends StatelessWidget {
  const HudState.loading({required this.label});
  const HudState.empty({required this.title, this.hint, this.action});
  const HudState.error({required this.message, required this.onRetry});
}
```

---

## 7. Componentes

### 7.1 Botones

| Variante | Widget | Fondo / texto | Altura | Uso |
|---|---|---|---|---|
| Primario | `RunicButton` (corregido) | `manaCyan` / `voidBg` **o** `runeViolet` / **`white`** | 48 | 1 por pantalla |
| Secundario | `RunicButton.outlined` | borde `manaCyan` / texto `manaCyan` | 48 | Acción alternativa |
| Destructivo | `RunicButton.danger` | `crimsonRed` / **`voidBg`** | 48 | Borrar cuenta, reiniciar |
| Icono | `HudIconButton` | superficie 6 % / icono `onSurface` | **48×48** | Volver, cerrar |
| Enlace | `TextButton` | `manaCyan` | 48 | "Restaurar compras" |

```dart
RunicButton(
  label: l10n.continueAdventure,
  backgroundColor: AppColors.manaCyan,
  foregroundColor: AppColors.voidBg, // contraste 13.09
  onPressed: ...,
)
```

**Rompe el build del diseño** (lint): `RunicButton` con
`backgroundColor == runeViolet && foregroundColor == onSurface`.

### 7.2 Cabecera de pantalla

Hoy hay 7 cabeceras a mano con 2 glifos y 4 tamaños. Se unifica:

```dart
HudHeader(
  title: l10n.myErrorsTitle,
  subtitle: l10n.myErrorsSubtitle, // opcional, labelMedium
  onBack: () => context.canPop() ? context.pop() : context.go('/home'),
  trailing: ...,
)
```

- Altura 56, `SafeArea` superior, botón 48×48, `tooltip` obligatorio.
- **Siempre** con fallback `canPop() ? pop() : go('/home')`.

### 7.3 Inputs

Mantener `InputDecorationTheme` (`app_theme.dart:128-150`) con dos cambios:

| Propiedad | Hoy | Propuesta |
|---|---|---|
| `hintStyle` | `onSurfaceVariant` al 50 % (3.50) | `onSurfaceVariant` al 70 % (7.77) |
| `contentPadding` | `EdgeInsets.symmetric(16,16)` | `AppSpacing.card` |
| Altura mínima | — | **52** (área táctil + texto 16) |
| Error | borde carmesí | borde + texto `errorRed` 8.45 ✅ |

### 7.4 Tarjetas

`GlassCard` se mantiene como **única** tarjeta:
- `borderRadius` fijo `AppRadius.sm` (se elimina el override: 7 usos).
- `opacity` fija 0.94 (se eliminan 0.95/0.96).
- `padding` por defecto `AppSpacing.card` (16), no 24.
- `showRunicCorners` solo en superficies destacadas (hoy `QuestCard`,
  `SystemWindow`, `GlassCard` con esquinas): máximo 1–2 por pantalla.
- `semanticLabel` obligatorio si la tarjeta es tocable.
- `onTap` siempre en el widget (trampa documentada en `AGENTS.md`).

### 7.5 Chips / badges

| Tipo | Fondo | Texto | Radio |
|---|---|---|---|
| Estado | color al 15 % | color pleno | `lg` (12) |
| Moneda | `surfaceContainerLow` | `onSurface` + icono | `sm` |
| Rareza | color al 15 % + borde 1 | color pleno | `sm` |

Se unifican los 4 `_RewardChip`/`_StatusBadge`/`_Tag`/`_CountBadge` existentes
(`session_summary_screen.dart:1206`, `mission_card.dart:396,486`,
`my_errors_screen.dart:251`).

### 7.6 Navegación

- Dock del dashboard: 4 destinos, altura 48, `Semantics(selected: true)` en el
  activo, icono 20 + label `labelSmall` (11, hoy 10).
- Pantallas hijas: `HudHeader` con volver.
- `SettingsScreen` **debe ser ruta** `/settings` (hoy solo pestaña):
  requisito para deep-link, notificaciones y "atrás" coherente.

### 7.7 Notificaciones

`SystemSnack` como única vía (hoy 48 vs 52 `SnackBar`):

```dart
SystemSnack.show(context, l10n.settingsSaveError, type: SystemSnackType.error);
```

- Duración 2 s (info) / 4 s (error, con acción "REINTENTAR").
- El color de acento va en el **borde**, no en el fondo: mantiene contraste
  (`system_snack.dart:18-43` ya lo hace bien).

- Diálogos y sheets: `SystemWindow` para HUD; `showModalBottomSheet` con
  `isScrollControlled: true` y `useSafeArea: true`.

---

## 8. Movimiento

| Token | Duración | Uso |
|---|---|---|
| `micro` | 150 ms | Press de botón/card |
| `fast` | 300 ms | Cambio de estado, switch |
| `standard` | 600 ms | Contadores, barras |
| `reward` | 1200 ms | Cofre, logro |
| `ambient` | 2000 ms | Glow/pulso (**solo si reduce-motion = false**) |

Contrato de accesibilidad:

```dart
// regla: ninguna animación infinita sin este gate
if (!AppMotion.reduceMotion(context)) controller.repeat(reverse: true);
```

Hoy solo 2 de 14 `repeat()` lo cumplen (`runic_button.dart:67`,
`dungeon_guardian_screen.dart:44-47`). El resto debe pasar por
`AppMotion.of(context, duration)`.

---

## 9. Accesibilidad (contrato del componente)

| Requisito | Verificación |
|---|---|
| Área táctil ≥ 48×48 | `HudIconButton` fijo a 48; prohibido `SizedBox(24)` con `onTap` |
| Etiqueta semántica | Todo control sin texto lleva `semanticLabel`/`tooltip` |
| Rol | `Semantics(button: true, onTap: ...)` con **acción**, no solo rol |
| Texto escalable | Sin `clamp`; layouts con `Flexible`/`maxLines` y probados a 2× |
| Reduce-motion | Gate en toda animación infinita |
| Contraste | Pares de §2.2; lint en CI |

`textScaler`: **no se limita** (limitar rompe accesibilidad). La solución es
cobertura: las 20 pantallas deben pasar a 1.5× y 2× (hoy 3 y 2
respectivamente).

---

## 10. Gobernanza (tests que faltan)

`test/golden/design_tokens_test.dart` ya bloquea color literal, radio y familia.
Se añaden 4 lints de fuente, en el mismo estilo:

| Test | Qué bloquea | Basado en |
|---|---|---|
| `spacing_lint_test.dart` | `EdgeInsets.*(<número>)` fuera de `AppSpacing` | hoy 419 |
| `colors_material_test.dart` | `Colors.white/black*` (72) | `conversation_screen.dart` 39 |
| `tap_target_lint_test.dart` | `SizedBox`/`Container` < 48 con `onTap` en el árbol | hoy 24×24 en resumen |
| `semantics_lint_test.dart` | pantallas con controles tocables sin `Semantics`/`tooltip` | 5 `Semantics` |

Además:
- Matriz de capturas `20 pantallas × 312 px / 360 px / textScaler 2×` (requiere
  dispositivo; hoy no existe).
- Galería de componentes (`test/golden/component_gallery_test.dart`) para que el
  DS se vea antes de aplicarlo.

---

## 11. Plan de adopción (sin big-bang)

| Fase | Alcance | Esfuerzo | Riesgo |
|---|---|---|---|
| **0** | Corregir `onSecondary`, `onTertiary`, `onError`; `RunicButton` a 48/contraste; `HudIconButton` | 1–2 d | Bajo |
| **1** | `AppSpacing` +2/6 y normalización de 10/14 en `app_theme` y `GlassCard` | 2 d | Bajo |
| **2** | Completar los 4 estilos del `TextTheme` y migrar `AppTypography` | 1–2 d | Medio (toca todo) |
| **3** | `HudHeader`, `HudState`, `SystemSnack` único; migrar 7 cabeceras | 3 d | Medio |
| **4** | Migrar pantalla por pantalla los 419 literales (empezar por las 5 con test) | 5–8 d | Medio |
| **5** | Suite de lints + matriz de capturas | 2 d | Bajo |

Ninguna fase necesita cambiar la paleta ni las familias. Todo es adoptar lo ya
declarado.
