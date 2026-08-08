# 02 — Análisis UX (UX Analysis)

## Principio rector
Separar **qué es el Salón del Gremio** (espacio social vivo: salas de voz, trofeos, NPC, rango) de **qué es el Tablón de Misiones** (herramienta de contenido: catálogo de misiones con estados). Cada pantalla con una sola responsabilidad.

## Análisis por agente

### Agente UX Research — Navegación actual
- **Perdida de contexto**: entrar al tablón requería scroll hasta ~mitad del Salón; el usuario no sabía que las misiones existían bajo las salas.
- **Información duplicada**: rango del jugador en 3 sitios del Salón.
- **Carga visual**: 6 tarjetas de misión a ancho completo → ninguna es "escaneable".
- **Flujo deseado**: `Dashboard → Gremio → [Tablón] → Detalle → Aceptar → Chat`. El Salón debe ser un **hub**, no un contenedor de todo.

### Agente Game UX — Patrones de Quest Boards (WoW, Skyrim, Diablo IV, GW2, FFXIV, Lost Ark, Monster Hunter, AFK Journey, Solo Leveling)

Patrones extraídos (sin copiar interfaces):
1. **Tablero = catálogo visual, no lista** → cuadrícula densa de elementos pequeños (WoW quest log, Guild Boards de Lost Ark/AFK Journey).
2. **Estado visible a golpe de vista** → color/borde/sello diferencia Disponible / Bloqueada / En progreso / Completada (Diablo IV bounties, Monster Hunter quest board).
3. **Rareza discreta** → marco/sello sutiles, nunca neon (AFK Journey, Solo Leveling gate stones).
4. **Detalle en pantalla dedicada**, no popup → Misión → Misión detallada (Skyrim quest journal, FFXIV quest window).
5. **NPC asignador visible** → "quién te encarga la misión" (WoW quest giver, Skyrim).
6. **Recompensas claras** (XP / oro / ítems) en el pergamino (Lost Ark, GW2).
7. **Acción principal única**: Aceptar (o Rechazar) — no sobrecargar (Monster Hunter).
8. **Fondo de tablero físico** (madera/piedra) ancla el marco mental de "gremio medieval" (Solo Leveling Arise guild hall).

### Decisiones UX aplicadas
| Decisión | Justificación (game UX) |
|---|---|
| Cuadrícula adaptativa 2/3/4 columnas de pergaminos | Muestra muchos elementos a la vez, escaneable (patrón 1) |
| Pergamino con overlays (nombre, rango, XP, oro, tipo, estado) | Estado y recompensa visibles sin abrir (patrón 2, 6) |
| Marco + sello de rareza discretos | Distingue rareza sin romper la estética medieval (patrón 3) |
| Detalle en pantalla `/guild-quest-detail` | Flujo de inmersión (patrón 4) |
| NPC asignador en el detalle | Contexto narrativo (patrón 5) |
| Botón único ACEPTAR (o RECHAZAR) | Acción clara (patrón 7) |
| Fondo `guildTable` + pergamino `Mision.png` | Tablero físico medieval (patrón 8) |

## Flujo de usuario final

```
Dashboard (tab Guild)
   └── Salón del Gremio (hub)
         └── Poster "TABLÓN DE MISIONES"  [1 solo punto de entrada]
               └── /guild-quest-board (cuadrícula de pergaminos)
                     ├── tap pergamino
                     │     └── /guild-quest-detail (detalle completo)
                     │           ├── ACEPTAR → persiste → /voice-room (chat de voz)
                     │           └── RECHAZAR → vuelve al tablón
                     └── filtros (TODAS/DIARIAS/SEMANALES/COLABORATIVAS)
```

## Carga visual antes/después

| Métrica | Antes (Salón embebido) | Después (Tablón dedicado) |
|---|---|---|
| Misiones visibles a la vez | 3-6 tarjetas grandes | 6-12 pergaminos compactos |
| Scroll para ver salas | cientos de px | inmediato |
| Rango duplicado | 3 veces | 1 vez (header del Salón) |
| Controles del tablón en el Salón | filtros + toggle + aceptar | 0 (solo un acceso) |
