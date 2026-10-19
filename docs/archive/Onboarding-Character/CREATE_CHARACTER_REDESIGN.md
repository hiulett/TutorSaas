# Rediseño de la Pantalla 5 — Create Your Character

> **Ruta:** `docs/Onboarding-Character/CREATE_CHARACTER_REDESIGN.md`
> **Alcance:** Auditoría UX/UI e implementación de la pantalla "Create Your
> Character" del onboarding, alineada con la plantilla `PlantillaHtml/hunter_class_selection`.
> **Tema:** TutorSaas / Dungeon of English

---

## 0. V2 — Carrusel horizontal de avatares + estadísticas (2026-08-04)

Tras incorporar los avatares definitivos (PNG 2816×1536, fondo transparente), la
pantalla se rediseñó al concepto **carrusel horizontal + panel de estadísticas**.

### Decisiones V2
1. **Carrusel horizontal (`PageView`, viewportFraction 0.62)**: el usuario desliza
   para elegir clase. La tarjeta activa se escala a 1.0 con **glow** del color de
   la clase; las laterales se ven a escala 0.86 (efecto "tarjeta al frente").
2. **Avatar como protagonista**: cada tarjeta muestra el arte completo del
   personaje (fondo transparente), con un gradiente oscuro inferior donde se
   superponen **nombre + rol**. Indicador de selección (check) en la esquina.
3. **Estadísticas debajo del carrusel** (`_ClassStatsPanel`): nombre, rol, rareza,
   descripción, **barra de dificultad (1-3)**, tipo de combate, afinidad,
   habilidades y estilo de juego. Cambia con **fade** (AnimatedSwitcher) al
   deslizar.
4. **Puntos indicadores** bajo el carrusel: barra activa con el color de la clase.
5. **Fondo oscuro de tarjetas**: `surfaceContainerHigh` (0xFF272A32) con
   transparencia 0.5 + borde luminoso del color de la clase — alineado con las
   plantillas (glass dark con glow).
6. **Persistencia**: `playerClass` (id) y `avatarIndex` (índice del carrusel) se
   guardan en `user_language_profiles.character_class` / `avatar_index`. Las
   clases vienen de la tabla `hunter_classes` (BD) con fallback estático.

### Archivos V2
- `character_creation_wizard.dart` — reescrito con carrusel + stats.
- `hunter_avatar.dart` — widget reutilizable de encuadre de avatar.
- `hunter_classes_providers.dart` / `hunter_class_data.dart` — BD + fallback.
- `supabase/migrations/20260804_hunter_classes.sql` — migración de clases.

---

## 1. Análisis previo

### 1.1 Estado actual (antes del cambio)
`lib/features/onboarding/presentation/widgets/character_creation_wizard.dart` presentaba:

| Elemento | Problema |
|---|---|
| Campo nombre **obligatorio** (`_isValid` ≥2 chars) | Bloqueaba continuar sin nombre (`_isValid` gate en el botón). |
| Cada tarjeta de clase mostraba 4 datos a la vez | Imagen+número, chip de elemento, "Aura: …", archetype (2 líneas) → **saturación visual**. |
| Grid 8 clases + preview 152px + highlight card | **Excesivo scroll vertical** y altura total. |
| Descripción duplicada | Aparecía en cada tarjeta (archetype) Y en la highlight card inferior. |
| Sin "rol" explícito | Solo se mostraba elemento/aura; el rol en el grupo no se comunicaba. |
| Clases **hardcodeadas** | `HunterClass.catalog` (const) — añadir clase = tocar código. |
| Diseño | No coincidía con la plantilla `hunter_class_selection` (grid 2 col compacto + panel inferior). |

### 1.2 Referencia visual (PlantillaHtml/hunter_class_selection)
La plantilla define el lenguaje del Design System para esta pantalla:
- **Grid 2 columnas** de Glass Cards compactas.
- Tarjeta = icono grande + nombre + chip de bonus + rol corto.
- Selección activa con **borde cian luminoso** (`ring-2 ring-primary`).
- **Panel inferior fijo**: "SELECTED CLASS" / "PROJECTED RANK" + CTA "CLAIM HUNTER CLASS".
- Fondo oscuro `#05070E`, acentos `#00E5FF` (manaCyan) y `#FFC700` (royalGold).
- Tipografía: Space Grotesk (títulos), JetBrains Mono (labels/stats), Inter (body).

---

## 2. Decisiones de UX/UI

### 2.1 Nombre del aventurero → OPCIONAL
**Estrategia elegida:** si el campo queda vacío, se usa el **nombre de la cuenta**
(`userMetadata.full_name` → `email` → `'Hunter'`). El botón de continuar ya no se
deshabilita. El nombre es editable después desde el perfil (`profile_edit_screen`).

*Por qué esta estrategia:* usar el nombre de la cuenta mantiene identidad real y
evita "generador automático" que puede sonar arbitrario. El fallback `'Hunter'`
solo aplica a usuarios sin email ni metadata (guest).

### 2.2 Reducción de carga cognitiva
- Cada tarjeta muestra **solo 3 elementos**: imagen, nombre, rol (en mayúsculas
  estilo JetBrains). Se eliminaron: chip de elemento, "Aura:", archetype inline.
- La información detallada **solo aparece al seleccionar** en un panel expandido
  colapsable (AnimatedSwitcher con fade).
- El preview de avatar se redujo de 152px a 120px y se coloca entre nombre y grid.

### 2.3 Grid compacto + panel expandido
- Grid `2` columnas, `childAspectRatio 1.05` (tarjetas compactas).
- Tarjeta seleccionada: borde 2px con el color de la clase, **glow** y gradiente
  sutil + punto indicador luminoso en la esquina.
- **Panel expandido** (`_ClassDetailPanel`): nombre + rol + chip de rareza +
  descripción + chips de dificultad/combate/afinidad + habilidades + estilo de
  juego. Ocupa poco espacio (ancho completo, contenido compacto).

### 2.4 Microinteracciones
- `AnimatedScale` en tarjetas (0.98→1.0 al seleccionar).
- `AnimatedContainer` para borde/glow/gradiente (250ms).
- `AnimatedSwitcher` con fade para el panel al cambiar de clase.
- Punto indicador con glow en la clase activa.
- Mantiene el sistema HUD (GlassCard, AppRadius, AppTypography).

### 2.5 Fuente de datos desde BD (escalable)
Se creó `hunterClassesProvider` (`FutureProvider.autoDispose`) que consulta la
tabla `hunter_classes` con **fallback** al catálogo estático si la migración no
está aplicada (proyecto read-only / pre-migración). Patrón idéntico al de
`oracleQuestionsProvider`.

---

## 3. Nueva estructura de datos (tabla `hunter_classes`)

Migración: `supabase/migrations/20260804_hunter_classes.sql`

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | text PK | id técnico (`warrior`, `mage`…) |
| `name_en/es/pt` | text | nombre localizado |
| `role_en/es/pt` | text | rol / archetype localizado |
| `description_en/es/pt` | text | descripción larga localizada |
| `image_url` | text | arte del avatar (asset Stitch) |
| `icon` | text | nombre del icono Material |
| `element` | text | elemento (Fuego, Arcano…) |
| `aura` | text | color del aura (legible) |
| `rarity` | text | `comun`/`raro`/`epico`/`legendario` |
| `color` | text | color representativo (hex) |
| `display_order` | int | orden en la UI |
| `is_active` | bool | visible |
| `is_starter` | bool | disponible en onboarding vs desbloqueable |
| `difficulty` | int | 1 (fácil) a 3 (difícil) |
| `combat_type_en/es/pt` | text | tipo de combate |
| `affinity_en/es/pt` | text | afinidad de aprendizaje |
| `abilities_en/es/pt` | jsonb | lista de habilidades principales |
| `playstyle_en/es/pt` | text | estilo de juego |

**RLS:** lectura para `authenticated`; escritura solo con `service_role`.

**Seed:** las 8 clases iniciales (Berserker, Arcane Mage, Assassin, Knight,
Archer, Summoner, Paladin, Necromancer) con metadatos completos en 3 idiomas.

### Modelo Dart
`lib/features/onboarding/domain/models/hunter_class_data.dart` — `HunterClassData`
con getters localizados (`nameFor/roleFor/descriptionFor/combatTypeFor/affinityFor/
abilitiesFor/playstyleFor`) y `fromMap`.

### Provider
`lib/features/onboarding/presentation/providers/hunter_classes_providers.dart`
— `hunterClassesProvider` (BD con fallback al catálogo estático).

---

## 4. Relación futura con el sistema de progresión

La estructura ya contempla la asociación posterior con:
- **Árbol de habilidades / pasivas / especializaciones** → columna `abilities_*`
  (jsonb) lista para expandirse a tabla `hunter_skills` FK a `hunter_classes.id`.
- **Equipamiento / inventario / cosméticos** → `hunter_classes.id` como FK en
  catálogos de items (patrón de `hunter_collection_catalog`).
- **Misiones exclusivas / logros / títulos** → filtros por `id` de clase.
- **Estadísticas del personaje** → `difficulty`, `affinity_*` y `combat_type_*`
  alimentan balances futuros.
- **Clases desbloqueables** → `is_starter=false` (no aparecen en onboarding,
  se desbloquean por juego).

Añadir una clase nueva = **un INSERT** en `hunter_classes` + (opcionalmente) el
arte en `assets/images/avatars/`. La UI se adapta automáticamente.

---

## 5. Archivos modificados/creados

| Archivo | Cambio |
|---|---|
| `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart` | Rediseño completo (nombre opcional, grid compacto, panel expandido, microinteracciones). |
| `lib/features/onboarding/domain/models/hunter_class_data.dart` | **Nuevo** modelo de clase desde BD. |
| `lib/features/onboarding/presentation/providers/hunter_classes_providers.dart` | **Nuevo** provider BD + fallback. |
| `supabase/migrations/20260804_hunter_classes.sql` | **Nueva** migración + seed 8 clases. |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Fallback del nombre usa el de la cuenta en vez de `'Hunter'`. |
| `lib/l10n/app_en/es/pt.arb` | 6 claves nuevas por idioma (nombre opcional, etiquetas de panel). |

---

## 6. Internacionalización

- Textos de la UI: claves l10n (`character_name_optional`, `character_*_label`,
  `character_class_unavailable`).
- Contenido de clases: **traducido en la BD** (columnas `_en/_es/_pt`), no en ARB.
- El `locale` se resuelve con `Localizations.localeOf(context)`.

---

## 7. QA

- `flutter analyze`: 0 errores.
- `flutter test`: 73/73.
- `flutter build apk --debug`: OK.
- Fallback verificado: sin migración aplicada, la pantalla usa el catálogo estático.

---

## 8. Extensibilidad

- Nueva clase → INSERT en BD (sin recompilar).
- Nuevo idioma → columnas `_xx` en `hunter_classes` + `HunterClassData`.
- Sistema de progresión → FKs desde tablas futuras a `hunter_classes.id`.
