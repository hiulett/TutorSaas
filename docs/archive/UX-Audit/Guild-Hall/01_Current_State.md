# Auditoría del Guild Hall — Estado Actual

> **Proyecto:** TutorSaas / Dungeon of English (Flutter)
> **Componente:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart`
> **Tamaño:** 1.121 líneas (monolítico)
> **Fecha de auditoría:** 2026-08-01
> **Método:** Hallazgos verificados contra el código (evidencia `archivo:línea`). No se ha modificado ningún archivo.

---

## 1. Vista general

El Guild Hall es la pantalla principal del salón de voz del gremio (voz + rol + RPG). Todo el contenido vive en un único archivo de 1.121 líneas que mezcla lógica de estado (proveedores Riverpod, llamadas a DB, diálogos) y decenas de widgets privados de presentación.

La pantalla se compone actualmente de **11 bloques de contenido en un único `SingleChildScrollView`**, en orden de render estrictamente secuencial (arriba → abajo).

---

## 2. Orden de render actual (verificado)

| # | Bloque | Tipo de componente | Definición / Render | Evidencia |
|---|--------|--------------------|---------------------|-----------|
| 1 | `_GuildHallHeader` | Cabecera: título + emblema de rango CEFR | `class _GuildHallHeader` (def. línea 811) | render en `chat_rooms_screen.dart:389` |
| 2 | `_GuildPrestigeHud` | Tarjeta completa "PRESTIGIO DEL GREMIO" | `class _GuildPrestigeHud` (def. línea 758) | render en `chat_rooms_screen.dart:394` |
| 3 | Título "MESAS DEL GREMIO" + botón INITIALIZE | `Row` con título y `ElevatedButton.icon` | botón → `_showCreateRoomDialog` (def. línea 198) | render en `chat_rooms_screen.dart:399–423`; botón en `:411–421` |
| 4 | Selector de categorías horizontal | Slider de 48px, dinámico desde DB | `_categoryLabels` (def. línea 58) | render en `chat_rooms_screen.dart:427–` y `:251` |
| 5 | Lista de mesas (lobby) | `roomsAsync.when(...)` + `ListView.separated` de tarjetas | `roomsAsync` (def. línea 356) | render en `chat_rooms_screen.dart:496` |
| 6 | `GuildQuestBoard` | Tablón del gremio con filtros | widget externo | render en `chat_rooms_screen.dart:665` |
| 7 | `MissionBoardWidget` | Otro tablón de misiones | widget externo | render en `chat_rooms_screen.dart:669` |
| 8 | `GuildMasterNpcBanner` | Banner NPC "Maestre de Mesa" (ambientación) | widget externo | render en `chat_rooms_screen.dart:674` |
| 9 | `_GuildTrophies` | Vitrina de 4 trofeos | `class _GuildTrophies` (def. línea 963) | render en `chat_rooms_screen.dart:679` |
| 10a | Cartel "MISIONES DEL GREMIO" | `_GuildPoster` decorativo, **sin `onTap`** | `class _GuildPoster` (def. línea 879) | render en `chat_rooms_screen.dart:689–694` |
| 10b | Cartel "TABLA DE RANGO" | `_GuildPoster` interactivo → `_showRankModal` | `_showRankModal` (def. línea 139) | render en `chat_rooms_screen.dart:698–704` |

> Nota: el `_showRankModal` ya existe en `chat_rooms_screen.dart:139` — la "tabla de rango" es un modal ya implementado. El cartel "TABLA DE RANGO" es el único punto de entrada visible a ese modal.

---

## 3. Diagrama del orden de render (simplificado)

```
┌─────────────────────────────────────────────┐
│ SingleChildScrollView (línea 385→710)        │
│                                              │
│ 1  _GuildHallHeader        :389  (título+CEFR)│
│ 2  _GuildPrestigeHud       :394  (tarjeta   )│
│ 3  MESAS + INITIALIZE      :399  (btn :411)  │
│ 4  Selector de categorías  :427              │
│ 5  Lista de mesas          :496              │
│ 6  GuildQuestBoard         :665  (tablón 1)  │
│ 7  MissionBoardWidget      :669  (tablón 2)  │
│ 8  GuildMasterNpcBanner    :674  (NPC)       │
│ 9  _GuildTrophies          :679  (vitrina)   │
│10a Cartel "MISIONES"       :689  (decorativo)│
│10b Cartel "TABLA DE RANGO" :698  (modal)     │
└─────────────────────────────────────────────┘
```

---

## 4. Componentes involucrados

### 4.1 Widgets privados del archivo
| Widget | Definición | Rol |
|--------|-----------|-----|
| `_GuildHallHeader` | `:811` | Cabecera con emblema de rango CEFR |
| `_GuildPrestigeHud` | `:758` | Tarjeta completa de prestigio del gremio |
| `_GuildPoster` | `:879` | Cartel decorativo/interactivo RPG (acepta `onTap` opcional) |
| `_GuildTrophies` | `:963` | Vitrina de 4 trofeos |

### 4.2 Widgets externos
| Widget | Función | Nota |
|--------|---------|------|
| `GuildQuestBoard` | Tablón de misiones del gremio con filtros | Reutilizado en otras pantallas |
| `MissionBoardWidget` | Tablón de misiones | Coexiste con el anterior |
| `GuildMasterNpcBanner` | NPC "Maestre de Mesa" | Ambientación |

### 4.3 Lógica de estado (misma pantalla)
| Símbolo | Línea | Función |
|---------|-------|---------|
| `_categoryLabels` | `:58` | Mapa slug→etiqueta de categorías (dinámico desde DB) |
| `_showRankModal` | `:139` | Modal de tabla de rango (ya implementado) |
| `_showCreateRoomDialog` | `:198` | Diálogo de creación de mesa (INITIALIZE) |
| `roomsAsync` | `:356` | Provider Riverpod de la lista de mesas |

---

## 5. Resumen de problemas identificados (A–H)

| Código | Problema | Evidencia | Tipo |
|--------|----------|-----------|------|
| **A** | Prestigio (tarjeta completa) antes que las mesas; compite con el contenido principal | `:394` precede a `:399–496` | Jerarquía / densidad |
| **B** | NPC detrás de dos tablones de misiones; el NPC es parte de la ambientación y queda enterrado | `:665–669` antes de `:674` | Jerarquía (parcial: trofeos al final sí es correcto) |
| **C** | Dos tablones de misiones consecutivos: `GuildQuestBoard` + `MissionBoardWidget` → información duplicada/confusa | `:665` y `:669` | Duplicidad / densidad |
| **D** | Cartel decorativo "MISIONES DEL GREMIO" sin `onTap`, redundante con los tablones reales de arriba | `:689–694` | Redundancia / ruido |
| **E** | Botón INITIALIZE usa `ElevatedButton`, inconsistente con `RunicButton` del resto de la app | `:411–421` | Consistencia del design system |
| **F** | Saturación: 11 bloques en scroll → el "salón vivo" no se percibe | `:389`→`:710` | Densidad / carga cognitiva |
| **G** | Archivo monolítico de 1.121 líneas (UI + lógica + diálogos mezclados) | total 1.121 líneas | Mantenibilidad |
| **H** | Falta sensación de "gremio vivo": sin eventos dinámicos, contador de conectados ni anuncios | pantalla completa | Carencia funcional |

---

## 6. Notas adicionales

- El botón INITIALIZE usa `ElevatedButton.styleFrom(backgroundColor: AppColors.runeViolet)` — correcto en color pero no es el componente `RunicButton` del design system.
- El archivo mezcla tres responsabilidades: render (widgets), negocio (providers/fetch) y navegación (diálogos) en un solo fichero.
- `_GuildPrestigeHud` y `_GuildHallHeader` son widgets privados grandes (758–811+, ~50+ líneas cada uno) que podrían extraerse.
- La lista de mesas está bajo el selector de categorías pero el orden de render de los 11 bloques hace que el contenido "funcional" (mesas) quede precedido por elementos de ambientación pesados.

---

## 7. Archivos relacionados

| Ruta | Relación |
|------|----------|
| `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | Pantalla auditada (1.121 líneas) |
| `lib/core/theme/app_colors.dart` | Paleta (manaCyan, runeViolet, royalGold, etc.) |
| `lib/core/widgets/glass_card.dart` | Tarjeta de cristal usada como base visual |
| `docs/UX-Audit/Guild-Hall/02_UX_Problems.md` | Problemas priorizados y leyes de UX |
