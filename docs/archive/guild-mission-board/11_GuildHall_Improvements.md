# 11 — Mejoras del Salón del Gremio (Guild Hall Improvements)

## Contexto
El Salón del Gremio (`chat_rooms_screen.dart`) era un scroll largo donde convivían: header, banner de conectados, salas de voz, tablón embebido, trofeos y posters. Tras separar el Tablón de Misiones a una pantalla dedicada, se aplicaron mejoras de "hub real" (bloque de alta prioridad).

## Mejoras implementadas

### 1. Roster de cazadores en línea (banner vivo)
- El banner "X CONECTADOS" ahora muestra una **fila de avatares** (`RpgAvatar`) de cazadores en línea (hasta 5), derivados de las clases activas.
- Reutiliza `RpgAvatar` (sin nuevo componente) y rota con el anuncio activo.

### 2. Anuncios dinámicos del gremio
- El anuncio rotativo ya no es solo estático: `_currentAnnouncementText` consulta `weeklyRaidProvider` y muestra el **raid/evento semanal** si está activo (`⚔️ RAID: ...`).
- Fallback elegante a los anuncios estáticos del gremio cuando no hay raid.

### 3. Salas con estado de ocupación en vivo
- Cada sala muestra un **badge de ocupación** según `speakers/max_speakers`:
  | Ratio | Etiqueta | Color |
  |---|---|---|
  | ≥100% | LLENA | crimsonRed |
  | ≥66% | CASI LLENA | royalGold |
  | ≥33% | OCUPADA | manaCyan |
  | <33% | ESPACIO | emeraldGreen |
- Complementa el contador `X/6` speakers + listeners existente.

### 4. Atajos rápidos (hub real)
- Nueva fila horizontal de **accesos rápidos** (`_GuildShortcut`) justo bajo el banner:
  - **MISIONES** → `/guild-quest-board`
  - **PASE DEL GREMIO** → `/battle-pass`
  - **RANGO** → modal de rango
  - **COLECCIONES** → `/collections`
- Reemplaza los posters grandes verticales ("TABLÓN DE MISIONES" y "TABLA DE RANGO") que ocupaban espacio vertical → se eliminaron para reducir duplicación y carga visual.

## Código
| Archivo | Cambio |
|---|---|
| `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | Roster, anuncios dinámicos, badge de ocupación, fila de atajos; eliminado `_GuildPoster` (muerto); nuevo `_GuildShortcut`. |

## Reutilización (sin duplicar)
- `RpgAvatar` para el roster.
- `weeklyRaidProvider` (misiones) para el anuncio.
- Rutas existentes (`/guild-quest-board`, `/battle-pass`, `/collections`).
- `_showRankModal` existente para el atajo RANGO.

## Mejoras implementadas (bloque 2 — interacción)
5. **NPC Maestre de Mesa interactivo**: el flotante ahora incluye **mini-chat IA** ("HABLAR CON EL MAESTRE") que reutiliza `getTutorResponseStream` (pipeline DeepSeek SSE, sin TTS). El NPC responde a nivel CEFR del aventurero con tono RPG, y se pueden hacer preguntas de práctica/misión/rango.
6. **Anuncios persistidos en BD**: nueva tabla `guild_announcements` (migración `supabase/misionesgremio/20260806_guild_announcements.sql`) + provider `guildAnnouncementsProvider` + `getGuildAnnouncements` en el repo. El banner prioriza anuncios de BD (editables desde web_admin), luego el raid semanal, luego los estáticos.
7. **Música ambiente de taberna** (`assets/music/tavermusic.mp3`): nuevo `TavernMusicService` con `just_audio` y **contador de referencias**. Reproduce en loop a **volumen bajo (0.15)**; cada pantalla del gremio (Salón, Tablón de Misiones, Detalle) llama `play()` al abrirse y `stop()` al cerrarse. **La música se detiene automáticamente al salir** de cualquiera de ellas (refcount llega a 0), y no se corta al navegar entre Salón → Tablón → Detalle.

## Correcciones (bugfix)
- **RenderBox was not laid out** en el chat del NPC: el `ListView(shrinkWrap)` con solo `maxHeight` fallaba durante el streaming. Reemplazado por `SizedBox(height:130)` + `SingleChildScrollView` + `Column` (layout estable).
- **Volumen de la música** bajado de 0.35 → **0.15**.
- **Música desacoplada del renderizado**: la auto-reproducción en `initState` de las pantallas del gremio causaba un layout loop (`_RenderSingleChildViewport NEEDS-PAINT` en bucle) que impedía renderizar el Salón. Ahora la música es un **toggle manual** (botón en la fila de atajos) y `TavernMusicService` es no-bloqueante (diferido + try-catch), sin tocar jamás el widget tree durante el primer build.

## Verificación
```
flutter analyze            → 0 errores
flutter test               → 114 passed
flutter build apk --debug  → OK (asset tavermusic.mp3 incluido)
```

## Pendiente BD
Aplicar `supabase/misionesgremio/20260806_guild_announcements.sql` en el SQL Editor para que el banner use anuncios de BD.
