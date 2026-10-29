# Runbook — tests de calidad y red de regresión visual

> Verificado el 29-oct-2026 sobre `master` `f595fcf` (Flutter 3.41.9 local,
> `ubuntu-latest` + stable en CI).
> Números medidos, no heredados: `flutter test` → **530 pruebas en verde, 0
> saltadas**; `flutter analyze --no-fatal-infos` → **0 errores, 0 warnings, 127
> infos**.

---

## 1. Capas de la red

| Capa | Archivo | Tests | Qué detecta |
|---|---|---|---|
| Tokens del design system | `test/golden/design_tokens_test.dart` | 5 | Colores, radios o familias tipográficas fuera de `app_colors.dart` / `app_radius.dart` / `app_typography.dart` |
| Estructura de widgets | `test/golden/glass_card_test.dart` | 6 | Vidrio de `GlassCard`: color, alfa, blur, borde, radio, sombra, padding, tamaño, animación de prensado, `onTap`, semántica, esquinas rúnicas |
| Estructura de widgets | `test/golden/rpg_chips_test.dart` | 4 | Chips del HUD: color de borde por token, tamaño, separación, estilo de texto |
| Pixel-golden | `test/golden/segmented_bar_test.dart` | 1 | Píxeles reales de `SegmentedBar` (`test/golden/goldens/segmented_bar.png`) |
| Resto del producto | `test/*.dart` | 514 | Lógica, pantallas, i18n, overflow, fuentes… |

`flutter test test/golden` ejecuta las 16 pruebas de esta carpeta en cualquier SO.

## 2. Regla de pixel-goldens

**Un pixel-golden solo es válido si el widget no pinta texto ni blur/sombras**
(y, por tanto, su rasterizado no depende de la plataforma).

En #207 se retiraron los de `GlassCard` y de los chips RPG: sus PNG se generaron
en Windows y en Linux diferían un 0,04 % y un 0,53 % (medición del issue). El de
`GlassCard` no tenía texto: la diferencia venía de `BackdropFilter` + `BoxShadow`.
Se sustituyeron por aserciones estructurales (árbol de widgets, `BoxDecoration`,
tipografía, tamaños).

`SegmentedBar` sí conserva pixel-golden porque solo pinta `Row` de `Container`
planos, sin texto ni blur: el mismo PNG pasa en Windows y en `ubuntu-latest`
(CI en verde sobre `f595fcf` con el test **sin** `skip`).

**No se admite `skip:` en `test/golden/`.** Si un test no puede correr en algún
SO, se reescribe como aserción estructural o se borra.

## 3. Cómo se actualiza la baseline

### Camino recomendado: regenerar en Linux (el mismo entorno que valida)

El job `goldens-baseline` de `.github/workflows/ci.yml` solo se ejecuta a mano:

```sh
# 1. Lanzar el job sobre la rama que quieras (workflow_dispatch + update_goldens)
gh workflow run ci.yml --ref <rama> -f update_goldens=true

# 2. Esperar y localizar el run
gh run list --workflow=ci.yml --limit 5

# 3. Descargar el artefacto (contiene test/golden/goldens/*.png)
gh run download <run-id> -n goldens-baseline -D test/golden/goldens

# 4. Commitear la baseline con el diff revisado
git add test/golden/goldens
git commit -m "test(golden): baseline Linux (Flutter <versión>)"
```

El artefacto se genera en `ubuntu-latest` con `flutter test test/golden
--update-goldens`, el mismo runner y canal (`stable`) que valida el CI.

### Camino alternativo: local

```sh
flutter test test/golden --update-goldens
```

Solo es aceptable si después el CI queda en verde: el PNG actual se validó así
(pasa en Windows y en Linux). Con un SDK de Flutter distinto al de CI, usa el
camino recomendado.

### Cuando el CI falla por un golden

`flutter_test` escribe los diffs junto al PNG esperado (`test/golden/failures/`)
y el job `Flutter (analyze + test)` los sube como artefacto `golden-failures`
(`if: failure()`). Descárgalo antes de tocar el PNG: `*_testImage.png` es lo
renderizado, `*_masterImage.png` la baseline y `*_isolatedDiff.png` la
diferencia.

## 4. Qué vigila el guard de tokens

`test/golden/design_tokens_test.dart` lee la fuente de verdad **del código**, no
de este documento:

- **Paleta:** parsea `lib/core/theme/app_colors.dart` en tiempo de test. Un
  literal `Color(0x…)` en `lib/` (fuera de ese archivo) solo se acepta si su
  ARGB es un token; si es translúcido, si su RGB es de la paleta o negro puro.
  Blancos y negros puros se aceptan como neutros.
- **Radios:** `AppRadius.sm/md/lg/circle` = 4/8/12/999; `AppRadius.card`,
  `pill`, `circleBorder` y las formas del `ThemeData` (botones, chip, diálogo,
  input) deben usar `AppRadius.card`.
- **Tipografías:** `lib/` solo puede pedir `spaceGrotesk`, `inter` y
  `jetBrainsMono`, `fontFamily:` no puede declarar otra familia y las tres tienen
  que estar empaquetadas en `assets/google_fonts/` (variantes verificadas en
  `test/bundled_fonts_test.dart`).

Añadir un token es un cambio de una línea en `app_colors.dart` /
`app_radius.dart`: el guard lo toma automáticamente.

### Deuda registrada (verificada en el código)

- `app_theme.dart` define 11 de los 15 estilos de `textTheme`: `headlineSmall`,
  `titleSmall`, `bodySmall` y `labelSmall` siguen en la tipografía por defecto de
  Material (Roboto, no empaquetada). El test lista esos cuatro explícitamente:
  si aparece otro, falla; si se tokenizan, también falla hasta actualizar la
  lista.
- Hay literales que duplican tokens de `AppColors`: 11 en
  `lib/features/conversation/presentation/screens/conversation_screen.dart`
  (p. ej. `0xFF0F172A` = `surfaceDeep`) y 2 en
  `lib/features/onboarding/domain/models/hunter_class_data.dart` (`0xFF00E5FF` =
  `manaCyan` y negro). Pasan el guard porque su ARGB coincide con un token;
  al tocar esos ficheros, usa el token.

## 5. Al añadir un test visual nuevo

1. Prefiere **aserciones estructurales**: `BoxDecoration`, `ClipRRect`,
   `padding`, `tester.getSize`, `TextStyle`, semántica.
2. Usa tokens (`AppColors`, `AppRadius`, `AppSpacing`, `AppTypography`) en el
   propio test: así un cambio de token se propaga sin romper el test, y un
   cambio de valor se ve en el diff.
3. Si de verdad necesitas pixel-golden, el widget tiene que ser texto-libre y
   blur-libre, y el PNG se genera con el camino del apartado 3.
