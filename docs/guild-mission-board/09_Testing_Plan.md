# 09 — Plan de pruebas (Testing Plan)

## Pruebas automatizadas

### `test/mission_parchment_test.dart` (NUEVO — 12 tests)
| # | Caso | Verificación |
|---|---|---|
| 1 | `QuestRarity.fromRank('E')` | `common` |
| 2 | `QuestRarity.fromRank('D')` | `uncommon` |
| 3 | `QuestRarity.fromRank('C')` | `rare` |
| 4 | `QuestRarity.fromRank('B')` | `epic` |
| 5 | `QuestRarity.fromRank('A')` | `legendary` |
| 6 | `QuestRarity.fromRank('S'/'SS'/'SSS')` | `guild` |
| 7 | `QuestRarity.fromRank(null/'ZZ')` | `common` |
| 8 | `questStatusFor` completada | `completed` |
| 9 | `questStatusFor` activa | `inProgress` |
| 10 | `questStatusFor` recomendada | `recommended` |
| 11 | `questStatusFor` rango insuficiente | `blocked` |
| 12 | `questStatusFor` rango suficiente | `available` |
| 13 | `sortQuestSmart` recomendada→aceptable→bloqueada | orden `[rec, ok, blk]` |
| 14 | `sortQuestSmart` sin recomendada | aceptables antes que bloqueadas |
| 15 | `sortQuestSmart` desempate por rango menor | `[E, D]` primero menor |

## Mejoras implementadas (v2)
| Mejora | Estado |
|---|---|
| Historial CUMPLIDAS (toggle en header) | ✅ |
| Mini-barra de progreso en pergaminos activos (`currentValue/targetValue`) | ✅ |
| Orden inteligente: recomendadas → disponibles → bloqueadas | ✅ (`sortQuestSmart`) |
| Filtro por rareza (COMÚN…ESPECIAL DEL GREMIO) | ✅ |

## Mejoras implementadas (v3 — inmersión)
| Mejora | Estado |
|---|---|
| Skeleton loading con `shimmer` (`MissionBoardSkeleton`) | ✅ |
| Animación de entrada: fade + leve rotación escalonada por índice | ✅ |
| Badge "NUEVA" (disponibles top-3) y "RECOMENDADA" | ✅ |
| Haptic feedback (`mediumImpact`) al aceptar | ✅ |
| Confirmación diálogo para misiones de rango alto (S/SS/SSS) | ✅ |

## Mejoras implementadas (v4 — profundidad)
| Mejora | Estado |
|---|---|
| COBRAR recompensa al completar (claimReward + FloatingReward) | ✅ |
| Búsqueda por texto en el tablón | ✅ |
| Retrato del NPC en el detalle (avatar Oráculo) | ✅ |
| Sello de cera rojo para BLOQUEADA + franjas "enrollado" para COMPLETADA | ✅ |
| Rareza editorial desde BD (columna `rarity`) con prioridad sobre el rango | ✅ |
| Botón "EN PROGRESO · IR AL CHAT" cuando la misión ya está activa | ✅ |

## Correcciones v5
| Corrección | Estado |
|---|---|
| **Cuota de gremio independiente**: máx 3 misiones del pool activas a la vez, sin competir con las 10 misiones diarias automáticas (`maxActiveGuildQuests`). Esto arreglaba que un jugador con 10 diarias activas no pudiera aceptar NINGUNA misión del gremio (incluidas las de su rango). | ✅ |
| **Paginación incremental**: el tablón muestra **6 pergaminos por defecto** (visualmente amigable) con botón "VER MÁS MISIONES (N restantes)" que amplía de 6 en 6. Los filtros/búsqueda resetean la paginación. | ✅ |

## Correcciones v6
| Corrección | Estado |
|---|---|
| **Duplicados en BD**: el seed de la serie se re-ejecutó parcialmente → `guild_quest_pool` tenía 192 filas pero solo 156 combinaciones únicas (36 duplicadas; 39 títulos únicos por idioma en vez de 48). Se generó `supabase/misionesgremio/20260805_fix_duplicates.sql` que TRUNCATE + re-aplica la serie → 48 títulos únicos por idioma. | ✅ (script listo, pendiente aplicar) |

## Casos de aceptación (funcionales)

| # | Criterio | Estado |
|---|---|---|
| CA1 | Tablón es pantalla independiente del Salón | ✅ ruta `/guild-quest-board` |
| CA2 | Acceso único desde el Salón | ✅ poster "TABLÓN DE MISIONES" |
| CA3 | Cuadrícula de pergaminos con `Mision.png` | ✅ `MissionParchment` |
| CA4 | Tap pergamino → detalle completo | ✅ `/guild-quest-detail` |
| CA5 | Aceptar persiste y navega a chat | ✅ `acceptGuildQuest` → `/voice-room` |
| CA6 | Rechazar vuelve sin aceptar | ✅ `pop` |
| CA7 | Toda la info desde BD, sin hardcodeo | ✅ `guild_quest_pool` |
| CA8 | Reutiliza lógica de misiones | ✅ repo/providers/CEFR |
| CA9 | Identidad medieval consistente | ✅ paleta `medieval*` + `guildTable` |
| CA10 | Compila, sin regresiones, tests OK | ✅ analyze + test + build |

## Pruebas manuales
1. Dashboard → tab Guild → Salón: ver el poster "TABLÓN DE MISIONES" y que las salas/trofeos están visibles sin scroll largo.
2. Tap al poster → tablón con cuadrícula de pergaminos (2 col en móvil).
3. Filtros TODAS/DIARIAS/SEMANALES/COLABORATIVAS → la cuadrícula se filtra.
4. Tap a un pergamino de rango aceptable → detalle → ACEPTAR → snack + navegación a `/voice-room`.
5. Tap a un pergamino de rango insuficiente → detalle con botón "RANGO X REQUERIDO" deshabilitado.
6. RECHAZAR → vuelve al tablón sin aceptar.
7. Completar una misión → aparece en `player_completed_quests` → desaparece del pool (rotación).
8. Tablet (≥650px) → 3 columnas; pantalla grande (≥1000px) → 4 columnas.

## Rendimiento
- Cuadrícula lazy (`GridView.builder`).
- Providers `autoDispose` (liberan memoria al salir).
- Sin paginación extra (pool <100 misiones/idioma).
- Imagen de pergamino cacheada por el framework.

## Accesibilidad
- Texto sobre pergamino con overlay oscuro (contraste).
- Hit areas de pergamino grandes (celda completa).
- Tipografía legible: nombres 12px+, badges 7-8px JetBrains (estilo HUD).
- Filtros y botones ≥48px de alto.
