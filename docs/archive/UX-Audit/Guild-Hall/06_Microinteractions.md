# Auditoría UX/UI — Microinteracciones (Guild Hall)

**Proyecto:** TutorSaas / Dungeon of English
**Archivo auditado:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (1121 líneas)
**Fecha de auditoría:** 2026-08-01
**Estado:** Borrador de auditoría — sin cambios de código aplicados

---

## 1. Principio de diseño

Las microinteracciones del Guild Hall deben **enriquecer sin degradar**. Criterios de aceptación para cada una:

- **Cero rebuilds continuos** de subárboles grandes (evitar `AnimatedBuilder` globales que repinten la lista de mesas).
- **Aislar el repaint** con `RepaintBoundary` por tarjeta/fila animada.
- **Animaciones de 1 solo disparo** (pulse, glow, scale) en lugar de loops infinitos salvo que sean estéticas intencionales y de coste despreciable (p. ej. breathing del NPC sobre su propio `RepaintBoundary`).
- **Durar ≤ 600 ms** para feedback; respetar `MediaQuery.disableAnimations` (accesibilidad / batería).
- **No bloquear input** durante la animación (usar efectos no obstructivos).

El fondo ya tiene un `BackdropFilter` con blur 120 sobre `CyberManhwaBackground` (`:371–374`) de coste conocido; las microinteracciones propuestas **no añaden** nuevos `BackdropFilter`.

---

## 2. Tabla de microinteracciones

| Elemento | Efecto propuesto | Severidad | Coste |
|---|---|---|---|
| Mesa seleccionada / fila de mesa | **Glow** sutil (`manaCyan`) en el borde de la fila al pulsar/entrar | Media | Bajo |
| Botón `ENTRAR` / fila de mesa | **Pulse** (scale 1.0 → 1.03 → 1.0, ~300 ms) al entrar en la sala | Alta | Bajo |
| Selector de categorías | **Fade** suave (120–200 ms) al cambiar de categoría | Media | Bajo |
| Botón `INITIALIZE` | **Scale** (1.0 → 0.95 → 1.0, ~200 ms) al presionar | Media | Bajo |
| NPC Maestre de Mesa | **Breathing** (opacidad/scale suave, loop 2.5–3 s) sobre el avatar 🔮 | Baja | Bajo |
| Header compacto | **Partículas flotantes** sutiles (2–4 puntos `manaCyan`/`royalGold`) sobre el fondo del header | Baja | Medio |
| Badge de rango (header) | **Glow** dorado temporal al tocar (abre `_showRankModal`) | Media | Bajo |
| Categoría activa (chips) | **AnimatedContainer** para color/borde ya existente → añadir `curve` suave | Baja | Bajo |
| Tablón fusionado (emergencia) | **Pulse** intermitente en el banner de emergencia (crimsonRed) mientras esté activo | Media | Bajo |
| Recompensas por reclamar | **Glow** en el botón `RECLAMAR` al aparecer el aviso | Baja | Bajo |

---

## 3. Detalle por microinteracción

### 3.1 Glow en mesas seleccionadas (Media · Bajo)
- **Elemento:** fila de mesa en la lista compacta (`chat_rooms_screen.dart:514–643`).
- **Efecto:** borde `manaCyan` con `alpha 0.2 → 0.6` y `boxShadow` difuminado en la fila al hacer tap/entrar; fade-out al salir de la sala.
- **Severidad:** Media — da confirmación visual de la selección, clave para un listado con toda la fila tappable.
- **Coste:** Bajo — animación de un solo disparo sobre `RepaintBoundary` de la fila; sin blur de fondo.

### 3.2 Pulse en botón ENTRAR (Alta · Bajo)
- **Elemento:** acción de entrada a `/voice-room` (botón `ENTRAR` `:627–636` y/o tap de fila `:526–528`).
- **Efecto:** escala 1.0 → 1.03 → 1.0 (~300 ms) al presionar, indicando que la acción fue registrada antes de la navegación.
- **Severidad:** Alta — la navegación es la acción principal del salón; el pulse reduce la percepción de "tap perdido".
- **Coste:** Bajo — `AnimatedScale` puntual; la navegación ya dispara transición propia.

### 3.3 Fade en transiciones de categoría (Media · Bajo)
- **Elemento:** `_selectedCategory` y la lista filtrada (`:448–453`, `:496–660`).
- **Efecto:** al cambiar de categoría, `AnimatedSwitcher` con fade 150 ms sobre la lista de mesas (el contenido no salta).
- **Severidad:** Media — suaviza el cambio de contexto sin reflow.
- **Coste:** Bajo — un `AnimatedSwitcher` que reemplaza el `when(data:...)`; sin animar cada fila individualmente.

### 3.4 Scale en INITIALIZE (Media · Bajo)
- **Elemento:** botón `INITIALIZE` (`:411–421`) y su diálogo `_showCreateRoomDialog` (`:198–352`).
- **Efecto:** scale 1.0 → 0.95 → 1.0 (~200 ms) al presionar; el diálogo ya entra con fade/scale del `showDialog`.
- **Severidad:** Media — feedback táctil en el botón principal de creación.
- **Coste:** Bajo — transformación puntual sobre el botón.

### 3.5 Breathing en NPC (Baja · Bajo)
- **Elemento:** avatar 🔮 del `GuildMasterNpcBanner` (`guild_master_npc_banner.dart:66–74`).
- **Efecto:** escala 1.0 → 1.05 → 1.0 y glow dorado oscilante en loop (~2.5–3 s), dando "vida" al Maestre sin distraer del texto de sugerencia.
- **Severidad:** Baja — refuerzo narrativo; puede respetar `disableAnimations`.
- **Coste:** Bajo — loop sobre un único contenedor pequeño dentro de su propio `RepaintBoundary`; no repinta el resto del banner.

### 3.6 Partículas flotantes en header (Baja · Medio)
- **Elemento:** header compacto (`:389`, propuesto en doc 05).
- **Efecto:** 2–4 puntos `manaCyan`/`royalGold` (1.5–2 px) flotando lentamente (drift vertical ±10 px, loop 6–8 s) detrás del header.
- **Severidad:** Baja — ambiente "System HUD"; opcional y desactivable.
- **Coste:** Medio — requiere un `AnimationController` con 2–4 `Transform`/`Opacity`. Para no afectar rendimiento: pre-renderizar las partículas en un `CustomPaint` sobre el propio widget del header (un único paint por frame, aislado con `RepaintBoundary`), **no** como widgets animados en el `Column` principal.

---

## 4. Notas de rendimiento (reglas de oro)

- **Nunca** envolver la lista de mesas completa (`:496–660`) en una animación continua; si se anima el glow de la fila, hacerlo solo en la fila activa con `RepaintBoundary`.
- **Evitar** `AnimatedBuilder` en el nivel de `Column` principal (`:385–712`); aislar cada microinteracción en el widget afectado.
- **Preferir** `AnimatedContainer`, `AnimatedScale` y `AnimatedOpacity` (tween implícito) sobre `AnimatedBuilder` manual cuando el cambio es de una sola propiedad.
- **No añadir** `BoxShadow` con blur alto en múltiples filas simultáneamente (coste de composición); limitarlo a la fila activa.
- **Respetar** `MediaQuery.disableAnimations` (accesibilidad, ahorro de batería): loops (breathing, partículas) deben desactivarse cuando está habilitado.

---

## 5. Orden de implementación sugerido (por coste/impacto)

1. **Fase de pulso/scale** (3.2, 3.4): máxima mejora perceptible, coste mínimo.
2. **Glow de selección** (3.1) y **fade de categoría** (3.3): feedback de contexto.
3. **Glow de rango + emergencia + reclamar** (2ª mitad de la tabla): refuerzos puntuales.
4. **Breathing del NPC** (3.5): pulido narrativo.
5. **Partículas del header** (3.6): opcional, solo si el presupuesto de rendimiento lo permite (medir con DevTools pre/post).

---

*Documento de auditoría. Sin cambios de código aplicados. Referencias: `chat_rooms_screen.dart` (1121 líneas), `guild_master_npc_banner.dart`, `mission_board_widget.dart`.*
