# Fase 3 — Analysis

> Análisis del estado actual del Dashboard del Aventurero.

## 1. DashboardScreen (`dashboard_screen.dart`, 2018 líneas)

Estructura principal: `Scaffold` con `CyberManhwaBackground` + navegación inferior con 4 tabs:

| Tab | Label | Contenido |
|---|---|---|
| 0 | MAZMORRAS | Dungeons: learning path roadmap, lecciones recomendadas, daily quests, hero pick |
| 1 | GUILD | → empuja `/chat-rooms` (guild hall / raid rooms) |
| 2 | ESTADO | → empuja `/hunter-status` |
| 3 | CONFIG | → empuja `/settings` |

Nota: la navegación de GUILD/ESTADO/CONFIG **empuja rutas** en lugar de mostrar contenido
inline (líneas 804–822 del bottom nav).

## 2. HunterStatusScreen (`hunter_status_screen.dart`, 316 líneas)

- Pantalla `/hunter-status` implementada y registrada en el router.
- Carga: `userProfileProvider` (bio) + `userProgressProvider` (XP, level, título equipado).
- Stats STR/INT/DEX/LUK con pool de 10 puntos; guardado en `users.bio` con formato
  `[Stats|STR:n|INT:n|DEX:n|LUK:n] texto`.
- Título equipado desde `HunterCatalog.titles` (persistido en `user_progress.equipped_title_code`).
- Usa `RpgAvatar`, `GlassCard`, `GoogleFonts.orbitron/spaceGrotesk/jetBrainsMono`.
- **Observación**: usa `GoogleFonts.orbitron` (fuera del estándar SpaceGrotesk/Inter/JetBrainsMono).

## 3. Widgets del dashboard

- `status_window_modal.dart`: modal de ventana del sistema (base del HUD).
- `daily_quests_widget.dart`: misiones diarias.
- `league_leaderboard_widget.dart`: leaderboard (test de overflow falla con pumpAndSettle).
- `learning_path_roadmap.dart`: roadmap de nivel.
- `next_recommended_lesson_hero.dart` / `recommended_lessons_hub.dart`: recomendación IA.

## 4. Paridad con PlantillasHTML

| Plantilla | Pantalla | Estado |
|---|---|---|
| `hunter_control_center_dashboard` | DashboardScreen | Parcial — HUD central (mana gem, party, notifications) no se corresponde |
| `hunter_status_profile_system` | HunterStatusScreen | Alta — profile/stats implementados |
| `social_hall_guild` | ChatRoomsScreen | Media (Fase 3 unifica Dashboard+Guild) |

## 5. Conclusión

El dashboard ya tiene núcleo funcional. Gaps:
1. HUD central del `hunter_control_center_dashboard` (mana gem, party strip, notifications, runas).
2. Tab GUILD no muestra contenido inline (empuja ruta).
3. `orbitron` fuera de tipografía estándar.
4. Leaderboard test con timeout (deuda QA).
