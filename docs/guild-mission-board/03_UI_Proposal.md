# 03 — Propuesta UI/Visual (UI Proposal)

## Concepto
**Tablón de Misiones del Gremio** — un tablón físico medieval donde los pergaminos (`Mision.png`) están fijados con chinchetas invisibles, cada uno mostrando la misión como un anuncio. No es una lista, no son tarjetas modernas: es un tablero.

## Componente principal: pergamino `MissionParchment`

Reutiliza `assets/images/avatars/Mision.png` (306×229) como imagen base de **cada** pergamino. El diseño del pergamino NO se modifica; los datos se superponen como overlays legibles sobre una capa oscura sutil.

### Overlays por pergamino
| Dato | Presentación |
|---|---|
| Tipo de misión | Etiqueta superior (`DAILY` / `WEEKLY` / `COLLABORATIVE`) |
| Rareza | Sello circular pequeño + marco del borde |
| Nombre | Título SpaceGrotesk w800, 2 líneas máx |
| Rango | Icono militar + rango (E..SSS) |
| Dificultad/Objetivo | Icono velocidad + valor objetivo |
| XP | Icono + `N XP` |
| Oro | Icono diamante + cantidad |
| Estado | Badge inferior con color de estado |

### Rarezas (discretas, nunca fluorescentes)
| Rareza | Color | Detalle |
|---|---|---|
| COMÚN | `rarityCommon` (#9E9E9E) | Borde fino gris |
| POCO COMÚN | `rarityUncommon` (#4CAF50) | Borde verde apagado |
| RARO | `rarityRare` (#2196F3) | Borde azul |
| ÉPICO | `rarityEpic` (#9C27B0) | Borde púrpura + sello |
| LEGENDARIO | `rarityLegendary` (#FF9800) | Borde dorado-naranja + sello |
| ESPECIAL DEL GREMIO | `guildAmber` | Borde ámbar + sello |

### Estados
| Estado | Color |
|---|---|
| DISPONIBLE | `emeraldGreen` |
| ACEPTADA | `manaCyan` |
| EN PROGRESO | `runeViolet` |
| COMPLETADA | `royalGold` |
| REPETIBLE | `rarityEpic` |
| BLOQUEADA | `crimsonRed` |
| RECOMENDADA | `guildAmber` |
| ESPECIAL | `rarityLegendary` |

## Pantalla Tablón (`GuildMissionBoardScreen`)
- Fondo: `CyberBgMode.guildTable` (taberna medieval oscura).
- Header: "TABLÓN DE MISIONES" + "AVENTURERO · RANGO X".
- Filtros: TODAS / DIARIAS / SEMANALES / COLABORATIVAS (chips).
- **Cuadrícula adaptativa**: 2 col (móvil <650px), 3 col (tablet ≥650px), 4 col (≥1000px). `GridView.builder` con lazy loading.
- Pergaminos con relación de aspecto ~1.0 (el pergamino base es 306×229 → se recorta con `BoxFit.cover` sin deformar).

## Pantalla Detalle (`MissionDetailScreen`)
- Pergamino grande centrado (220×180).
- Título + rareza + tipo.
- Descripción completa.
- NPC asignador (derivado de categoría).
- Stats en filas: NIVEL / XP / ORO / TIEMPO / OBJETIVO / CEFR.
- Botones: **RECHAZAR** (outline, vuelve) + **ACEPTAR MISIÓN** (relleno dorado; si rango insuficiente muestra "RANGO X REQUERIDO").

## Paleta (AppColors)
| Token | Valor | Uso |
|---|---|---|
| `medievalDarkWood` | #1B1512 | Fallback de pergamino |
| `medievalAgedGold` / `Light` | #B8860B / #D4A93F | Acentos, filtros activos |
| `medievalText` | #D8CBB0 | Texto sobre pergamino |
| `medievalTextDim` | #9A8F7A | Texto secundario |
| `voidBg` | #05070E | Overlay oscuro |
