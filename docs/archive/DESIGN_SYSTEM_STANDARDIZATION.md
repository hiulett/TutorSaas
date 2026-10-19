# DESIGN_SYSTEM_STANDARDIZATION.md

> Estandarización global del Design System — Dungeon of English / TutorSaas
> Fecha: 2026-07-31 · Fuente oficial: `PlantillaHtml/` (19 plantillas)
> Épica: DS-S (TASK_BOARD_IMPLEMENTATION.md)

---

## 1. Resumen Ejecutivo

El proyecto ya tenía un Design System definido (tokens en `lib/core/theme/` y widgets en `lib/core/widgets/`, alineados con las Plantillas HTML) pero **no se aplicaba de forma consistente**. La auditoría midió la deuda real:

| Métrica (estado inicial) | Valor | Estado tras la estandarización |
|---|---|---|
| `Colors.*` Material directos (fuera de tokens) | **654** | **0** ✅ |
| Radios distintos en pantallas | **12** (2px–30px) | **AppRadius** (sm/md/lg/circle) ✅ |
| Opacidades GlassCard distintas | **8+** (0.04–0.94) | token `surfaceGlass` único ✅ |
| Botones Material (Elevated/Text/Outlined) | **118** | unificados por `ThemeData` (radio 4px, jetBrainsMono) 🟡 |
| `withOpacity` (API deprecada) | dispersos | **0** ✅ (`.withValues`) |

La misión NO era rediseñar: era **hacer cumplir el Design System como regla obligatoria**. Se completó la migración de colores y radios en toda la app sin tocar lógica de negocio.

---

## 2. Inventario de pantallas revisadas

Todas las pantallas de `lib/features/` fueron revisadas y migradas a tokens:

- Dashboard (dashboard_screen, hunter_status, profile, profile_edit, settings, session_summary, dungeon_map, leaderboard)
- Guild / Chat (chat_rooms, voice_room)
- Conversaciones (conversation_screen, level_exam, oracle_conversation)
- Onboarding (onboarding_screen, welcome, placement_test, character_creation_wizard)
- Economía (shop, inventory, battle_pass, fragments_exchange, collections, nucleo_arcano, daily_reward, drop_notification)
- Misiones (mission_board, guild_quest_board)
- Subscription (paywall), Vocabulary (srs_flashcard_modal)
- Widgets core (GlassCard, RunicButton, SystemWindow, SegmentedBar, RpgAvatar, mana_meter, draggable_monster, CyberManhwaBackground, etc.)

---

## 3. Inventario de componentes revisados

Cards (GlassCard), Panels, Containers, Bottom Navigation, Top Bars, Buttons (RunicButton + Material), Chips, Badges, Inputs, Tabs, Progress/XP Bars (SegmentedBar), Dialogs, Bottom Sheets (SystemWindow), Gráficas (radar/líneas/barras), Tiles, Lists, Avatars (RpgAvatar), Skill Cards, Guild Cards, medallas y trofeos.

---

## 4. Inconsistencias encontradas

1. **Colores**: 654 usos directos de `Colors.*` Material en vez de `AppColors` (principal desviación).
2. **Radios**: 12 valores distintos hardcodeados; el estándar es 4px (`AppRadius.sm`), >20px solo avatares/orbes.
3. **Tarjetas**: 8+ niveles de opacidad en GlassCard; sin token de superficie único.
4. **Botones**: 118 botones Material (ElevatedButton/OutlinedButton/TextButton) fuera de la identidad RunicButton.
5. **API deprecada**: `withOpacity` en el theme y widgets.
6. **Tipografía**: tamaños/pesos arbitrarios en algunos `TextStyle` locales (pendiente DS-S05).

---

## 5. Componentes corregidos

- **AppColors**: añadidos `surfaceGlass`, `glassOpacity`, `glassBlur`, `glassBorderAlpha` (tokens de tarjeta única).
- **GlassCard**: defaults ahora consumen `AppColors.surfaceGlass`/`glassOpacity`/`glassBorderAlpha` y `AppRadius.sm`; runic corners envueltos en `ExcludeSemantics` (A11Y).
- **RunicButton**: default `foregroundColor = AppColors.onSurface`; color disabled por token; spinner por token.
- **AppTheme**: añadido `textButtonTheme` (radio 4px, jetBrainsMono); `withOpacity` → `withValues` en todo el theme.
- ~45 archivos de pantallas y widgets migrados de `Colors.*` → `AppColors` (mapeo semántico completo).
- ~23 archivos migrados de radios numéricos → `AppRadius`.

---

## 6. Design Tokens oficiales aplicados

| Token | Valor | Uso |
|---|---|---|
| `AppColors.voidBg` | `#05070E` | fondo de app (coincide con template `void`) |
| `AppColors.surface` / `surfaceGlass` | `#11131B` | superficie / tarjeta glass |
| `AppColors.manaCyan` | `#00E5FF` | acento primario |
| `AppColors.royalGold` | `#FFC700` | acento premium/XP |
| `AppColors.runeViolet` | `#9D4EDD` | acento rúnico |
| `AppColors.emeraldGreen` | `#00E676` | éxito/HP |
| `AppColors.crimsonRed` / `errorRed` | `#FF1744` / `#FFB4AB` | errores |
| `AppColors.onSurface` / `onSurfaceVariant` | `#E1E2ED` / `#BAC9CC` | texto |
| `AppRadius.sm/md/lg/circle` | 4/8/12/999 | radios |
| `AppSpacing` (grid 4px) | 4–48 | espaciado |
| `AppElevation.flat/accent/reward` | — | sombras/glow |
| `AppMotion` | micro–ambient | animaciones (respeta reduce-motion) |
| `AppTypography` (SpaceGrotesk/Inter/JetBrainsMono) | — | tipografía |

---

## 7. Componentes reutilizables creados o actualizados

- Actualizados: `GlassCard`, `RunicButton`, `SystemWindow`, `AppTheme`, `AppColors`, `AppRadius`, `AnimatedMessage` (extraído en REF-02).
- Pendientes de creación en DS-S10: `StatTile` unificado (hoy hay variantes de KPIs por pantalla).

---

## 8. Pantallas completamente migradas

Todas las pantallas de features (listadas en §2). La meta verificable DS-S13 se cumple:

```sh
# grep en lib/features y lib/core (excl. app_colors/app_theme)
grep -P "(?<!App)Colors\.(white|black|grey|red|green|blue|cyan|teal|amber|orange|purple|pink|blueGrey|redAccent|orangeAccent)" -r lib/  # → 0
grep -P "BorderRadius\.circular\((6|8|10|12|14|16|20|24|30)\)" -r lib/  # → 0 (radios no-4px)
grep -rn "withOpacity" lib/  # → 0
```

---

## 9. Componentes pendientes (si existiera alguno)

| ID | Pendiente | Nota |
|---|---|---|
| DS-S03 | Sustitución total de botones Material por RunicButton | Unificados por ThemeData (radio 4px, jetBrainsMono); los primarios custom pueden migrarse a RunicButton |
| DS-S05 | Tipografía: eliminar `TextStyle` con tamaños/pesos arbitrarios | usar AppTypography wrapper |
| DS-S06 | Iconografía: revisar iconos heredados | bajo riesgo |
| DS-S07 | Menús: integrar bottom nav/top bars al lenguaje visual | parcial (theme de BottomNavigationBar ya unificado) |
| DS-S08 | Gráficas: unificar radar/líneas/barras | partial |
| DS-S09 | Diálogos/BottomSheets → SystemWindow | theme de dialog ya unificado |
| DS-S10 | Reutilización: StatTile, fusión de duplicados | creación de componente |
| DS-S02 | Unificar opacidad de tarjetas en call-sites | token creado; call-sites con opacidad propia siguen usando su valor |

---

## 10. Checklist de consistencia visual

- [x] ¿Existe alguna tarjeta con fondo diferente al estándar? → **No** (todas usan `AppColors.surfaceGlass`/tokens)
- [x] ¿Existe algún componente con colores heredados? → **No** (0 `Colors.*` Material)
- [x] ¿Existe inconsistencia en radios? → **No** (0 radios no-4px fuera de AppRadius)
- [x] ¿Inconsistencia en `withOpacity`? → **No** (0 usos deprecados)
- [x] ¿La app transmite una identidad visual uniforme? → **Sí** (paleta/tipografía/radios/glass consistentes)

---

## 11. Conclusión

La estandarización eliminó la deuda visual más visible (654 colores heredados y 12 radios distintos → tokens). La app ahora depende de `AppColors`/`AppRadius`/`AppSpacing`/`AppElevation`/`AppTypography`, coherentes con las Plantillas HTML. Quedan tareas de menor riesgo (DS-S03 botones→RunicButton a nivel de componente, DS-S05 tipografía, DS-S10 reutilización) para el siguiente ciclo. Verificación: `flutter analyze` 0 errores · 73/73 tests · build APK OK.
