# Design System — Dungeon of English

> Documento maestro de diseño. Sincronizado: 2026-07-30 (Fases 2-10). Fuente visual: `PlantillaHtml/`.

## Paleta (AppColors — `lib/core/theme/app_colors.dart`)
| Token | Valor | Uso |
|---|---|---|
| voidBg | #05070E | Fondo |
| manaCyan | #00E5FF | Acento primario, energía |
| royalGold | #FFC700 | Recompensas, prestigio, NPC |
| runeViolet | #9D4EDD | Acciones, botones, títulos |
| emeraldGreen | #00E676 | Éxito, metas completadas |
| crimsonRed | #FF1744 | Error/emergencia |

## Tipografía (google_fonts)
- **SpaceGrotesk**: headlines, botones.
- **Inter**: cuerpo.
- **JetBrainsMono**: stats, etiquetas, HUD.
- Regla: NO introducir otras familias (orbitron y hankenGrotesk deprecados; onboarding aún usa hankenGrotesk — migrar).

## Geometría y espaciado
- Radio estándar 4px; >20px solo avatares/orbes.
- Grid 4px (margen 20px, padding 24px, gutter 16px).

## Animación (`lib/core/theme/app_motion.dart`)
| Token | Valor |
|---|---|
| micro | 150ms (hover/press) |
| fast | 300ms (estados) |
| standard | 600ms (contadores, metas) |
| reward | 1200ms (recompensas) |
| ambient | 2000ms (glow/pulso) |
| curveStandard / curveSpring / curvePress | easeOutCubic / easeOutBack / easeInOut |
| reduceMotion / scaled | accesibilidad |

## Componentes core (`lib/core/widgets/`)
| Widget | Uso |
|---|---|
| GlassCard | Ventana flotante (borderColor, showRunicCorners, shadow) |
| SystemWindow | Modal con header + esquinas rúnicas |
| SegmentedBar | Barra de progreso segmentada (HUD) |
| AnimatedCounter | Contador animado |
| FloatingReward | Recompensa flotante "+XP" |
| RunicButton | Botón primario con micro-interacción |
| RpgAvatar | Avatar/orbe |
| CyberManhwaBackground | Fondo manhwa (13 modos) |

## Pantallas clave (paridad PlantillaHtml)
- Hunter HUD → `hunter_control_center_dashboard`
- Mapa de mazmorras → `learning_dungeon_map_gateways`
- Oracle conversacional → `guild_evaluation`
- Gran Salón → `social_hall_guild`
- Battle Pass → `s_rank_system_upgrade`
