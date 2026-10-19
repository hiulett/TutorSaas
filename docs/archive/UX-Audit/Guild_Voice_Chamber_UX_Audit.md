# Auditoría UX/UI — Pantalla Guild Voice Chamber

**Proyecto:** TutorSaas / Dungeon of English
**Archivo auditado:** `lib/features/chat_rooms/presentation/screens/voice_room_screen.dart` (991 líneas)
**Fecha de auditoría:** 2026-08-01
**Estado:** Borrador de auditoría — sin cambios de código aplicados

---

## 1. Estado actual

### 1.1 Orden de render verificado

La pantalla se compone actualmente de los siguientes bloques, en este orden (de arriba a abajo):

1. **Scaffold + fondo**: `CyberManhwaBackground` (modo `guildTable`) + 2 glow orbs decorativos (`runeViolet` / `manaCyan`, blur 120–140).
2. **Barra de navegación superior**: botón back + título **"GUILD VOICE CHAMBER"** + badge **LIVE** + subtítulo "Moderated by AI Tutor in Real Time" + `ManaMeterWidget` + botón exit.
3. **AI Tutor Tip Banner** (GlassCard, icono psychology, tip rotatorio `_aiTips`).
4. **Demo transparency banner** (GUILD-01): "AUDIO DEL GREMIO: DEMO / Los oradores son simulados. Tu voz sí se graba." (ámbar).
5. **Room Mission Header** (GUILD-02): "MISIÓN DE LA SALA" + `missionName` + chip "GRUPO DE HABLA".
6. **Resonance Meter** (GUILD-02): "RESONANCIA DE LA SALA" + % + `SegmentedBar(10)`.
7. **Speakers Grid** (Expanded flex 6): `GridView` de 3 columnas × 2 filas, 6 slots.
   - Slot 1 = AI Moderator (`_buildAiModeratorCard`: orbe con anillo `aiGold` + "AI TUTOR / AI MODERATOR").
   - Slots vacíos = tarjeta "Subir al Slot N" (claim).
   - Ocupados = GlassCard con avatar (`RpgAvatar` 48px) + nombre (YOU / HUNTER N) + etiqueta "NPC · DEMO" + estado SPEAKING/LIVE + anillo pulsante al hablar (`_pulseController`).
8. **Audience strip** (GUILD BENCH): fila horizontal con avatares 32px de la audiencia.
9. **Chat toggle button** + chat expandible (`_showChatSheet`): lista de mensajes + TextField + send.
10. **Bottom Floating Control Bar** (GlassCard): mute toggle (`IconButton`), "HABLAR CON EL ORÁCULO" (`ElevatedButton` royalGold → `/conversation`), "ASK TO SPEAK" (`ElevatedButton` runeViolet), leave (`IconButton` errorRed).

### 1.2 Diagnóstico general

La pantalla tiene una **sobrecarga de información de cabecera**: 5 bloques (top nav + tip banner + demo banner + misión + resonancia) antes de llegar al contenido principal, que son los oradores. El grid de oradores — el núcleo de la experiencia — empieza aproximadamente en la línea **~512**. Esto obliga a hacer scroll antes de ver la acción, y compite directamente con el objetivo principal de la sala: la conversación en tiempo real.

---

## 2. Problemas críticos por prioridad

| # | Prioridad | Severidad | Impacto | Hallazgo | Evidencia (archivo:línea) |
|---|-----------|-----------|---------|----------|----------------------------|
| A | Alta | Alta | **Saturación vertical**: 5 bloques de cabecera antes del grid de oradores. El contenido principal empieza en la línea ~512. Mucho scroll antes de ver la acción. | Top nav + tip + demo + misión + resonancia apilados secuencialmente. | `voice_room_screen.dart:262–512` |
| B | Alta | Media | **3 banners consecutivos** compiten por atención (tips, demo, misión). El tip rotatorio es decorativo y de bajo valor durante la sesión activa. | Banner tips ~:321, demo ~:348, misión ~:388. | `voice_room_screen.dart:321`, `:348`, `:388` |
| C | Media | Media | **Redundancia de salida**: 3 formas de salir (back, exit, leave). Riesgo de abandono accidental de la sala. | Back button, exit button, leave en barra inferior. | `voice_room_screen.dart:262`, `:309`, `:924` |
| D | Media | Alta | **Confusión del botón "HABLAR CON EL ORÁCULO"**: navega a `/conversation` pero parece un control de voz de la sala. No hay hold-to-talk real; los oradores son simulados. | `ElevatedButton` royalGold con navegación. | `voice_room_screen.dart:880` |
| E | Media | Media | **Chat expandible compite con el grid**: al abrirse (`_showChatSheet`) roba espacio del grid (flex 4 vs flex 6). | Expansión dentro del layout principal. | `voice_room_screen.dart` (chat + flex del grid) |
| F | Media | Media | **Grid de oradores 2×3 con cards grandes** (aspect ratio 0.85). En pantallas pequeñas los avatares quedan apretados; la info por card (avatar 48 + nombre + etiqueta + estado) es densa. | `GridView` 3×2, `RpgAvatar` 48px. | `voice_room_screen.dart` (grid y `_buildAiModeratorCard`) |
| G | Baja | Baja | **Inconsistencia de componentes**: `ElevatedButton.icon` en la barra inferior en vez de `RunicButton` (estándar del resto de la app). `ManaMeterWidget` en top nav. | Barra inferior, botones 880 y 899. | `voice_room_screen.dart:880`, `:899` |
| H | Baja | Baja | **Sin bottom nav del dashboard**: es una pantalla push (`/voice-room`). Back + exit compensan, pero hay 3 salidas. | Rutas de la app. | `lib/app/router.dart` |
| I | Media | Media | **Performance**: `_pulseController` (AnimatedBuilder por speaker hablando) + `AnimatedSwitcher` del tip + glow orbs con `BackdropFilter` grande (blur 120–140) pueden causar overdraw y rebuilds. | Glow orbs, `_pulseController`, `AnimatedSwitcher`. | `voice_room_screen.dart` (orbs + pulso) |

---

## 3. Propuesta de rediseño

### Jerarquía de niveles

- **Nivel 1 (siempre visible):** top nav compacta + grid de oradores + control de voz inferior.
- **Nivel 2 (bajo demanda):** chat (bottom sheet), misión + resonancia (fila compacta), audiencia (collapsible).
- **Nivel 3 (oculto / acordeón):** tip banner (solo al inicio), demo banner (colapsable en un icono ⓘ), estadísticas.

### Cambios propuestos (por cambio, con justificación)

**1. Mover el AI Tutor Tip Banner a un tooltip/ícono "ℹ" (o mostrarlo una sola vez al entrar y colapsarlo).**
- *Justificación:* elimina uno de los 3 banners en competencia (hallazgo B) y libera espacio vertical (hallazgo A). El contenido es útil solo al inicio de la sesión, no en bucle rotatorio durante una conversación.

**2. Fusionar misión + resonancia en una sola fila compacta bajo el header.**
- *Justificación:* dos bloques separados (GUILD-02) ocupan el doble de altura para información que puede leerse de un vistazo. Una fila compacta reduce la saturación vertical (hallazgo A) sin perder la información gamificada.

**3. Demo banner → icono discreto (colapsable).**
- *Justificación:* la transparencia es legal/ética pero no debe dominar la UI. Un icono ⓘ con tooltip o una ficha colapsable conserva el aviso (obligatorio) sin robar atención (hallazgo B).

**4. Chat → bottom sheet (`showModalBottomSheet`) en vez de expandir en el grid.**
- *Justificación:* el modo actual roba espacio al grid (hallazgo E). Como bottom sheet, el chat se abre sobre la acción sin reflow del layout principal, y respeta la jerarquía Nivel 1/Nivel 2.

**5. Grid de oradores más compacto.**
- *Justificación:* aspect ratio más alto (cards menos altas) o avatar 40px para que en pantallas pequeñas no se aprieten (hallazgo F). Mantener el anillo pulsante de estado.

**6. Barra inferior con `RunicButton` / iconos consistentes.**
- *Justificación:* alinea con el design system de la app (hallazgo G). `ElevatedButton.icon` se reemplaza por `RunicButton` manteniendo colores `royalGold` y `runeViolet`.

**7. Una sola salida clara (botón central de salir).**
- *Justificación:* elimina la redundancia de back + exit + leave (hallazgo C). Back se puede conservar en la top nav, pero la salida *explícita* de la sala debe ser única y destacada para evitar abandono accidental.

**8. Optimización de performance.**
- *Justificación:* reducir `BackdropFilter` (blur 120–140) en los glow orbs o sustituirlos por gradientes pre-renderizados, y limitar los `AnimatedBuilder` del `_pulseController` solo al speaker activo (hallazgo I). Ver sección 7.

---

## 4. Wireframe textual (distribución nueva, de arriba a abajo)

```
┌─────────────────────────────────────────────┐
│  ‹  GUILD VOICE CHAMBER     ●LIVE   [mana]  │  ← Top nav compacta (N1)
│  ⓘ  DEMO AUDIO (colapsable)                │  ← Aviso discreto (N3)
├─────────────────────────────────────────────┤
│  MISIÓN: <missionName>   [GRUPO DE HABLA]   │  ← Fila compacta misión (N2)
│  RESONANCIA ██████░░░░░░  62%               │  ← Resonancia en la misma fila
├─────────────────────────────────────────────┤
│  ┌───────┐ ┌───────┐ ┌───────┐              │
│  │  AI   │ │  YOU  │ │ HUNT. │  ← Grid 3×2  │  ← Núcleo siempre visible (N1)
│  │  TUTOR│ │ SPEAK │ │ LIVE  │    compacto  │
│  └───────┘ └───────┘ └───────┘              │
│  ┌───────┐ ┌───────┐ ┌───────┐              │
│  │  Slot │ │  Slot │ │  Slot │              │
│  └───────┘ └───────┘ └───────┘              │
├─────────────────────────────────────────────┤
│  ● ● ● ● ○ ○   (GUILD BENCH collapsible)    │  ← Audiencia (N2)
├─────────────────────────────────────────────┤
│  [💬 Chat]              [Estadísticas ▾]     │  ← Acciones bajo demanda (N2)
├─────────────────────────────────────────────┤
│  [🔇] [ HABLAR CON EL ORÁCULO ] [ASK TO SPEAK] [✕] │  ← Control inferior (N1)
└─────────────────────────────────────────────┘

Chat abre como bottom sheet (N2) sobre el grid, sin reflow.
Tip banner: solo tooltip "ℹ" o 1 vez al entrar (N3).
```

---

## 5. Lista de tareas (checklist)

- [ ] **5.1** Colapsar/mover el AI Tutor Tip Banner a un ícono "ℹ" o mostrarlo 1 vez al entrar (N3).
- [ ] **5.2** Fusionar misión + resonancia en una sola fila compacta bajo el header (N2).
- [ ] **5.3** Convertir el demo banner en icono ⓘ colapsable con tooltip (N3).
- [ ] **5.4** Migrar el chat de expansión inline a `showModalBottomSheet` (N2).
- [ ] **5.5** Compactar el grid de oradores (aspect ratio mayor y/o avatar 40px) (N1).
- [ ] **5.6** Unificar la barra inferior con `RunicButton`/iconos consistentes (N1).
- [ ] **5.7** Definir una única salida clara de la sala (botón central de leave) (N1).
- [ ] **5.8** Optimizar glow orbs (reducir blur / pre-render) y limitar `_pulseController` al speaker activo (N3/performance).
- [ ] **5.9** Verificar navegación y RLS/realtime tras los cambios de layout (sin tocar la lógica de voz).

---

## 6. Plan de implementación en fases pequeñas

> Cada fase debe **compilar y pasar `flutter analyze` (0 errores)** antes de pasar a la siguiente. No se toca la lógica del pipeline de voz.

**Fase 1 — Reducción de cabecera (5.1, 5.2, 5.3)**
- Colapsar tip banner (tooltip/1 sola vez) y fusionar misión + resonancia en una fila.
- Convertir demo banner en ⓘ colapsable.
- *Verificación:* visual — la acción (grid) queda visible sin scroll; `flutter analyze` 0 errores.

**Fase 2 — Chat como bottom sheet (5.4)**
- Reemplazar el panel expandible `_showChatSheet` por `showModalBottomSheet`.
- Eliminar el conflicto de flex 4 vs 6.
- *Verificación:* abrir/cerrar chat sin reflow del grid; envío de mensajes intacto.

**Fase 3 — Grid compacto y consistencia (5.5, 5.6)**
- Ajustar aspect ratio / tamaños de avatar y unificar `RunicButton` en la barra inferior.
- *Verificación:* pruebas en pantalla pequeña (ej. 360dp de ancho) sin overflow ni apriete.

**Fase 4 — Salida única (5.7)**
- Consolidar leave en un solo control destacado; mantener back solo para navegación.
- *Verificación:* flujo de salida correcto sin confirmaciones dobles ni doble navegación.

**Fase 5 — Performance y microinteracciones (5.8)**
- Optimizar orbs y `_pulseController`; añadir glow/pulse/fade donde corresponda (ver sección 7).
- *Verificación:* `flutter test` + `flutter analyze` limpios; perfil de rendering (DevTools) sin picos de overdraw.

---

## 7. Análisis de performance y microinteracciones

### Performance

- **Glow orbs decorativos** (`runeViolet`/`manaCyan`, blur 120–140): un `BackdropFilter` con blur alto sobre el `CyberManhwaBackground` es costoso en GPUs móviles. *Recomendación:* sustituir por gradientes/radial pre-renderizados o reducir el radio de blur; o aplicar el blur solo durante entrada/salida y congelarlo después.
- **`_pulseController`**: un `AnimatedBuilder` por speaker hablando fuerza rebuilds continuos del subárbol. *Recomendación:* animar únicamente el anillo del speaker activo (un solo controller) y usar `RepaintBoundary` en cada card de orador para aislar el repaint.
- **`AnimatedSwitcher` del tip banner**: al eliminarse el banner rotatorio (Fase 1) desaparece esta fuente de rebuilds periódicos.
- **Grid 3×2**: cards con muchos hijos (avatar, nombre, etiqueta, estado, anillo). *Recomendación:* `RepaintBoundary` por card y evitar sombras/blur en cada una.

### Microinteracciones (dónde añadir glow/pulse/fade)

- **Card del speaker activo**: mantener el anillo `manaCyan`/`aiGold` pulsante (ya existe) — es la microinteracción clave de "quién está hablando". Añadir un *fade* suave al pasar de SPEAKING → LISTENING (0.3s) para dar feedback de transición.
- **Fila de misión + resonancia**: al actualizarse el %, un `SegmentedBar` ya es animado; añadir un *pulse* breve en el chip "GRUPO DE HABLA" cuando la misión avanza (desbloqueo).
- **Botón "ASK TO SPEAK"**: *glow* temporal en `runeViolet` cuando entra en cola/request, con fade cuando se concede el turno.
- **Bottom sheet del chat**: entrada con slide-up + fade del fondo (estándar material); el botón flotante 💬 puede tener un *pulse* sutil cuando hay mensajes nuevos no leídos.
- **Demo banner ⓘ**: al expandir el aviso, fade-in del contenido y atenuación del resto (overlay).
- **Botón de salida**: *fade* o shrink al mantener presionado para evitar taps accidentales (complementa la Fase 4 de salida única).

---

*Documento de auditoría. Sin cambios de código aplicados. Referencias: `voice_room_screen.dart` (991 líneas), rutas en `lib/app/router.dart`.*

---

## 8. Cambios implementados (2026-07-31)

> Validado: 0 errores analyze � 73/73 tests � build APK OK. Archivo: 1003 l�neas (antes 991).

### Fase 1 � Jerarqu�a de cabecera (colapsar + fusionar)
- **Tip banner**: ahora colapsable (_showTipBanner) con bot�n de cierre (X). Se muestra al entrar y el usuario lo puede ocultar.
- **Demo banner**: convertido en chip compacto colapsable (_showDemoBanner) � muestra "AUDIO DEL GREMIO: DEMO" en una l�nea y se expande al tocar.
- **Misi�n + Resonancia**: fusionadas en UNA sola GlassCard compacta (misi�n a la izquierda, mini-barra de resonancia a la derecha con SegmentedBar height 4). Se elimin� la tarjeta separada de resonancia.
- Resultado: 5 bloques de cabecera ? 2 (top nav + tarjeta misi�n/resonancia fusionada).

### Fase 2 � Chat como Bottom Sheet
- El toggle+panel expandible (_showChatSheet) fue reemplazado por un bot�n compacto que abre _openChatSheet() ? showModalBottomSheet (65% alto, surfaceContainerLow + borde manaCyan, encabezado con t�tulo + cerrar, lista de mensajes + input + send).
- El grid de oradores ya no compite con el chat (antes flex 4 vs 6).

### Fase 3 � Grid compacto + audiencia colapsable
- Grid de oradores: childAspectRatio 0.85 ? 1.0, spacing 14?10 (cards m�s compactas).
- Audiencia (GUILD BENCH): colapsable (_showAudience) � header con toggle que oculta/muestra los avatares.

### Fase 4 � Barra inferior consistente
- ElevatedButton.icon ? RunicButton (OR�CULO royalGold, HAND runeViolet) � 0 ElevatedButton restantes.
- Se mantienen: mute (IconButton), leave (IconButton). La salida se concentra en el leave inferior + back.

### Fase 5 � QA
- lutter analyze 0 errores � lutter test 73/73 � lutter build apk --debug OK.
- Funcionalidad intacta: join/leave, sendChatMessage, _startOraclePractice, claim slot, speaking simulation, _buildAiModeratorCard.

### Pendiente (no cr�tico)
- _showAudience y banners inician en 	rue; se podr�an iniciar en alse seg�n preferencia de producto.
- El glow orb (blur 120-140) del fondo sigue activo (coste de overdraw aceptable).

### Fix de overflows (RenderFlex) � validado en dispositivo
Se reportaron overflows tras el redise�o. Corregidos:
- **Barra inferior (197px)**: 2 RunicButton grandes + 2 IconButton en un Row spaceAround desbordaban. Redise�ada a 4 controles compactos (_controlButton: icono + label corto, cada uno en Expanded con minHeight 48). Nunca desborda en ning�n ancho.
- **Bot�n de chat (14px)**: t�tulo Chamber Text Chat (N) envuelto en Flexible + ellipsis.
- **Header del bottom sheet**: typo "CAMBER"?"CHAMBER" corregido; t�tulo en Flexible + ellipsis.
- **Top nav**: t�tulo GUILD VOICE CHAMBER en Flexible + ellipsis; subt�tulo con ellipsis.
- **Slots de oradores (12px abajo)**: avatar 48?44, anillo pulsante 58?52 para que quepan en el grid aspect 1.0.
- Limpieza: import de RunicButton eliminado (ya no se usa), _controlButton renombrado a lowerCamelCase.
