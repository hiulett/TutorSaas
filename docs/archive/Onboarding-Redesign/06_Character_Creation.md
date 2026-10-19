# Auditoría Estratégica del Onboarding — Documento 06

# Rediseño de la Creación de Personaje

> **Proyecto:** TutorSaas / Dungeon of English
> **Base:** hallazgos verificados (docs 01–02) — sin modificar código
> **Alcance:** `character_creation_wizard.dart` (231 líneas) + tarjeta de héroe (`onboarding_screen.dart`) + asset pipeline (Stitch)
> **Fase:** F4 del plan (doc 08)

---

## 1. Estado actual (verificado)

El wizard vive en `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`
y ya está migrado a tokens (`GlassCard`, `AppColors`, `AppTypography`, `AppRadius`, `RunicButton`).

| Elemento | Detalle | Evidencia |
|---|---|---|
| Datos | `CharacterCreationData{name, playerClass, avatarIndex=0}` | `character_creation_wizard.dart:11-21` |
| Clases | 3 (`warrior`/`mage`/`rogue`) con icono + color + desc | `character_creation_wizard.dart:37-41` |
| Avatares | 6 orbes (icono Material + color), **índice 3 y 5 ambos `royalGold`** (duplicado cromático) | `character_creation_wizard.dart:43-50` |
| Validación | `_isValid => name.trim().length >= 2` | `character_creation_wizard.dart:58` |
| Botón | `RunicButton` «EL ORÁCULO TE ESPERA» | `character_creation_wizard.dart:212-226` |
| **Gap** | `avatarIndex` se recoge pero **no se persiste**; `avatarUrl` = clase (no imagen) | `onboarding_screen.dart:206-215`; `dashboard_repository_impl.dart:776-785` |

Tarjeta de héroe actual (`_buildHeroWelcomeScreen`, `onboarding_screen.dart:432-569`):
«¡BIENVENIDO, CAZADOR!» + nombre + orbe de 72 px con icono de clase + píldoras CEFR/RANGO.
Sin avatar, sin nivel inicial, sin elemento/aura, sin iluminación — se lee como resumen de
formulario, no como carta coleccionable.

**Referencias útiles ya existentes:** `RpgAvatar` (`lib/core/widgets/rpg_avatar.dart:27-28`)
resuelve nombres de clase (`warrior`/`mage`/`assassin`/`necromancer`/`priest`) y acepta URLs
HTTP; `assets/images/` ya registrado en `pubspec.yaml:68-69` (fondos `.jpg`).

---

## 2. Propuesta: 8 clases con arquetipo RPG

Ampliar de 3 → 8 clases. Cada una lleva: **id**, **nombre UI (l10n)**, **icono Material**,
**color (token)**, **elemento**, **arquetipo de aprendizaje** y **descripción gamificada**.

### 2.1 Tabla de las 8 clases

| # | id | Nombre UI (ES) | Icono | Color (token) | Elemento | Arquetipo de aprendizaje |
|---|---|---|---|---|---|---|
| 1 | `warrior` | Berserker | `Icons.shield_rounded` | `crimsonRed` `#FF1744` | 🔥 Fuego | Extrovertido, habla primero — perder el miedo |
| 2 | `mage` | Mago Arcano | `Icons.auto_awesome_rounded` | `runeViolet` `#9D4EDD` | 🔮 Arcano | Analítico, estructura antes de hablar — gramática |
| 3 | `assassin` | Asesino | `Icons.colorize` | `collabBlue` `#42A5F5` | 🗡️ Sombra | Observador táctico — vocabulario de precisión |
| 4 | `knight` | Caballero | `Icons.military_tech_rounded` | `royalGold` `#FFC700` | 🛡️ Tierra | Constante y metódico — rachas y constancia |
| 5 | `archer` | Arquero | `Icons.gps_fixed` | `emeraldGreen` `#00E676` | 🌪️ Viento | Ágil, aprende en contexto — expresiones útiles |
| 6 | `summoner` | Invocador | `Icons.auto_fix_high_rounded` | `blindMagenta` `#FF00FF` | ⭐ Estelar | Creativo, asocia ideas — frases idiomáticas |
| 7 | `paladin` | Paladín | `Icons.volunteer_activism` | `tutorBubbleBlue` `#1E60FF` | ☀️ Luz | Guiado por objetivos — conversación formal |
| 8 | `necromancer` | Nigromante | `Icons.gavel` | `gemPurple` `#E0B6FF` *(nuevo token propuesto)* | 🕯️ Óseo | Curioso por la etimología — raíces latinas |

**Notas de compatibilidad:**
- `RpgAvatar` ya mapea `assassin` → `Icons.colorize`/`rarityRare` y `necromancer` →
  `Icons.gavel`/`runeViolet` (`rpg_avatar.dart:100-114`): los ids nuevos encajan sin tocar el widget.
- `_heroClassIcon`/`_heroClassName`/`_heroClassColor` en `onboarding_screen.dart:393-427`
  usan switch por clase → habrá que extender los 3 helpers (o moverlos a un modelo de dominio `HunterClass`).
- Propuesta: **añadir tokens de clase a `AppColors`** para `necromancer` y evitar la colisión
  cromática con `mage` (ambos tienden a violeta). No reintroducir hex sueltos.

### 2.2 Migración de datos (retrocompatibilidad)

Los `playerClass` ya persistidos son `warrior`/`mage`/`rogue`. El modelo debe mapear
`rogue → assassin` en lectura (fallback) y mantener `warrior`/`mage` tal cual:

| id persistido (legacy) | Nuevo id |
|---|---|
| `warrior` | `warrior` (sin cambio) |
| `mage` | `mage` (sin cambio) |
| `rogue` | `assassin` (alias de migración) |

### 2.3 Estado seleccionado RPG (mejora de presentación)

Reutilizar el lenguaje del doc 04 (`Onboarding_Revamp`):
- Borde del color de clase + glow (`BoxShadow` color α 0.3–0.4, blur 12–16).
- `GlassCard.showRunicCorners: true` + `runicColor` = color de clase (ya soportado, doc 04 §2.1).
- Check animado (`AnimatedSwitcher` → `check_circle_rounded`, `AppMotion.curveSpring`).
- Escala press 0.97 con `AppMotion.micro` (patrón `RunicButton`).
- Icono de clase 40–48 px como punto focal.

---

## 3. Avatares: guía de generación con Stitch (Google)

### 3.1 Decisiones de consistencia (antes de generar)

Definir 4 variables que fijan el estilo de TODOS los avatares. Cambiarlas después
invalida el set completo:

| Variable | Valor canónico propuesto |
|---|---|
| Formato | PNG o WebP, 512×512, fondo transparente (o `voidBg` `#05070E`) |
| Estilo | Manhwa/Webtoon System HUD — retrato de torso, iluminación dramática azul/morada, líneas limpias, sin texto |
| Composición | Cabeza + hombros centrados, halo/runa del elemento detrás, aura del color de clase |
| Piel/raza | Multicultural (es la app de idiomas) — 6 variantes de piel por avatar donde aplique |

### 3.2 Prompt tipo para Stitch (una plantilla por avatar)

```
Retrato estilo webtoon "System HUD" oscuro, torso y cabeza centrados.
Cazador ${CLASE} con armadura ${estilo_armadura}, elemento ${ELEMENTO}
(glifo/aura ${COLOR} detrás), iluminación dramática con acentos ${manaCyan #00E5FF}.
Fondo transparente / negro puro #05070E. Estilo consistente con la serie
"Void Hunters". 512x512, sin texto, sin logo.
```

Ejemplo concretado (Berserker):
```
Retrato webtoon "System HUD" oscuro, torso y cabeza centrados. Berserker
con armadura de placas agrietada y espada al hombro, elemento fuego
(aura carmesí #FF1744 y brasas), iluminación dramática con acentos cian
#00E5FF. Fondo transparente. Estilo consistente con la serie "Void Hunters".
512x512, sin texto.
```

**Material de referencia:** los 6 avatares actuales son iconos Material (`person`,
`face_3_rounded`… `face_2_rounded`, `character_creation_wizard.dart:43-50`). Los renders de
Stitch los **reemplazan** por retratos; los iconos Material se conservan solo como fallback
offline dentro del orbe (patrón `RpgAvatar._buildFallback`, `rpg_avatar.dart:91-154`).

### 3.3 Integración al flujo de desarrollo

```
Stitch (genera) → tooling (exporta) → assets/images/avatars/ → pubspec → Dart (catalog)
```

1. **Generar** en Stitch 8 avatares de clase (1 por clase) + 6–8 avatares de jugador
   (variantes de rostro/color, los que hoy son `face_*`). Total ~14–16 renders.
2. **Exportar** a `assets/images/avatars/` con nombres `class_warrior.webp`,
   `player_0.webp` … `player_5.webp`.
3. **Registrar** en `pubspec.yaml:68` la carpeta `assets/images/avatars/`.
4. **Referenciar** vía catálogo Dart: nuevo modelo `HunterClassCatalog` / `avatar_catalog.dart`
   en `lib/features/onboarding/domain/` que mapea `classId → assetPath + color + elemento`,
   consumido por el wizard, la tarjeta de héroe y `RpgAvatar`.
5. **Fallback:** si el asset no existe (release viejo), caer al icono Material + color
   (cero regresión visual).

### 3.4 Tamaño objetivo de assets

| Asset | Resolución | Peso objetivo |
|---|---|---|
| Retrato de clase (tarjeta héroe) | 512×512 → recorte ~400×560 (3:4) | < 120 KB (WebP) |
| Orbe de jugador (selector) | 128×128 | < 30 KB (WebP) |
| Fondo de tarjeta de héroe | 1080×1440 (3:4) | < 200 KB (WebP) |

---

## 4. Tarjeta del Aventurero premium (carta coleccionable)

Reemplazar `_buildHeroWelcomeScreen` (`onboarding_screen.dart:432-569`) por una **carta
coleccionable System HUD** con jerarquía vertical de arriba abajo:

### 4.1 Estructura de la carta (proporción 3:4, estilo TCG)

```
┌──────────────────────────────┐
│  ◆ TARJETA DE CAZADOR ◆      │  ← JetBrainsMono, letterSpacing, royalGold
│  ┌────────────────────────┐  │
│  │  (imagen principal     │  │  ← retrato Stitch de la clase (3:4)
│  │   + aura de elemento)  │  │     + aura del color de clase (BoxShadow/glow)
│  └────────────────────────┘  │
│  avatar orbe  (RpgAvatar)    │  ← 64–72 px, anillo de clase + glow
│  NOMBRE (SpaceGrotesk bold)  │  ← displayName
│  Berserker  ·  Lv. 1         │  ← clase + nivel inicial (chips)
│  [RANGO E] [CEFR A1]         │  ← píldoras gold (reusar _buildHeroRankPill)
│  elemento: 🔥 Fuego          │  ← glifo de elemento + aura
│  ⬡ aura: carmesí             │  ← color de aura (hex/token legible)
│  ─────────────────────────── │
│  desc del rango (1 línea)    │  ← CefrRank.rankDescription
└──────────────────────────────┘
```

### 4.2 Campos y fuente de datos

| Campo | Fuente actual / propuesta |
|---|---|
| Imagen principal | `assets/images/avatars/class_<id>.webp` (Stitch) |
| Avatar orbe | `avatar_index` → `player_<i>.webp` o fallback icono Material |
| Nombre | `_characterName` → `users.display_name` |
| Clase | `playerClass` → `user_language_profiles.character_class` |
| Nivel inicial | Nuevo: constante `1` o derivar de rango (propuesta: `Lv.1` a `Lv.3` según CEFR) |
| Rango | `game_rank` o `CefrRank.gameRankFromCefr(cefr)` (`cefr_rank.dart:45-48`) |
| CEFR | `_selectedCefrCode` (default A1, `onboarding_screen.dart:166-168`) |
| Elemento | Derivado de clase vía catálogo (mapa clase→elemento) |
| Aura | Color de clase vía catálogo + `BoxShadow` glow |
| Iluminación | `CyberManhwaBackground` existente + orbes de glow (patrón `onboarding_screen.dart:443-467`) |

### 4.3 Mejoras System HUD de bajo riesgo

- **Esquinas rúnicas:** `GlassCard(showRunicCorners: true, runicColor: royalGold)` — patrón ya
  usado en el paso Oráculo (`onboarding_screen.dart:954`).
- **Nivel inicial animado:** `AnimatedCounter` (`lib/core/widgets/`) para el `Lv. X`.
- **Aura de elemento:** `BoxShadow` del color de clase alrededor del retrato (blur 24–32).
- **Gradiente de rareza** en el borde de la carta (reusar `rarity*` de `AppColors`, `app_colors.dart:57-61`).
- **Accesibilidad:** `Semantics` en orbes y chips; reducir a `AppMotion.of(context, …)`
  para respetar `MediaQuery.disableAnimationsOf`.

---

## 5. Integración de Stitch para la imagen principal

1. **Orquestación:** `stitch-ui-design` skill para redactar el prompt exacto; `image-generator`
   para variantes. Regenerar solo cuando cambie la dirección de arte (no por iteración menor).
2. **Guardar artefactos en repo:** `assets/images/avatars/` + `docs/Onboarding-Redesign/
   stitch_prompts.md` (los prompts aprobados como single source of truth).
3. **Validación de estilo:** comparar los 8 retratos lado a lado (mismo fondo, misma luz,
   misma composición). Si 2 rompen la consistencia, regenerar esos 2 (no todo el set).
4. **Verificación de integración:** los assets se referencian desde el catálogo Dart y se
   muestran en el wizard + tarjeta de héroe. No depender de URLs remotas (sin red en onboarding
   de prueba) — a diferencia del actual fallback de DiceBear, que `RpgAvatar` ignora
   deliberadamente (`rpg_avatar.dart:25-26`).

---

## 6. Resumen de decisiones

| # | Elemento | Estado actual | Propuesta | Impacto | Riesgo |
|---|---|---|---|---|---|
| 2.1 | Clases | 3 hardcodeadas | 8 clases con elemento + arquetipo + catálogo | Alto (identidad) | Medio (mapa legacy `rogue→assassin`) |
| 2.3 | Estado seleccionado | Borde + opacidad sutil | Glow + runic corners + check animado + press-scale | Alto | Bajo |
| 3 | Avatares | 6 orbes Material, 1 color duplicado | Retratos Stitch consistentes + catálogo + fallback | Alto | Medio (assets/consistencia) |
| 4 | Tarjeta héroe | Resumen de formulario | Carta coleccionable 3:4 con aura/elemento/nivel | Alto | Medio (layout móvil) |
| 5 | Assets | Fondos `.jpg` únicamente | `assets/images/avatars/*.webp` + prompts versionados | Medio | Bajo |

**Nota:** la descripción de clase (1–2 líneas) debe vivir en l10n (`app_en/es/pt.arb`), no en
el código Dart — ver F1 del doc 08.
