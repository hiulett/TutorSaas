# Sistema del Gran Salón del Gremio — Documento Unificado

> **Versión:** 1.0 — Julio 2026
> **Propósito:** Unificar la auditoría, el diseño conceptual y la implementación del módulo de moderación del Guild Hall de Dungeon of English.

---

## Índice

1. [Auditoría Completa](#1-auditoría-completa)
2. [Concepto Ideal](#2-concepto-ideal)
3. [Sistema de Moderación — Implementación](#3-sistema-de-moderación)
4. [Base de Datos — Scripts](#4-base-de-datos)
5. [Blueprint Final](#5-blueprint-final)
6. [Priorización e Impacto](#6-priorización)

---

## 1. Auditoría Completa

### Puntuación General: 21/100

| Dimensión | Puntaje | Diagnóstico |
|---|---|---|
| **Diseño visual** | 25/100 | Layout genérico de listas. Sin zonas ni jerarquía espacial |
| **Experiencia de usuario** | 30/100 | Funcional pero sin emociones. No hay "hogar" |
| **Inmersión RPG** | 15/100 | Sin NPC Maestro, sin tablón de misiones, sin zonas |
| **Narrativa** | 10/100 | El título "Guild" no está respaldado por contenido |
| **Gamificación** | 10/100 | Sin recompensas, cofres, misiones visibles |
| **Arquitectura de información** | 35/100 | La info que hay está bien organizada pero falta casi todo |
| **Consistencia temática** | 25/100 | Colores correctos pero cero elementos System HUD |

### Problemas Raíz

1. **No hay NPC Maestro del Gremio** — el alma del lugar está ausente
2. **No hay tablón de misiones** — el jugador no sabe qué hacer al llegar
3. **No hay progreso visible** — el jugador no ve su nivel, XP, rango
4. **Es una lista de salas, no un "lugar"** — no hay arquitectura espacial
5. **No hay recompensas inmediatas** — no hay cofres diarios, notificaciones
6. **No hay sistema de moderación real** — cualquier usuario podía crear salas sin control

---

## 2. Concepto Ideal

### El Guild Hall debe ser:

```
┌──────────────────────────────────────────────────────┐
│  🧭 MAPA  │  [Panel del Cazador]  │  Rango 💠 B1  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌─ ★ MAESTRO DEL GREMIO ─────────────────────────┐  │
│  │  [Avatar] "Bienvenido, Cazador. Tu racha de    │  │
│  │   7 días es impresionante. El tablón tiene      │  │
│  │   una misión urgente para ti."                  │  │
│  │  [Hablar] [Ir a Misión] [Recompensa Diaria 🎁]  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                       │
│  ┌─ 📋 MISIÓN DIARIA ──┐  ┌─ 🏆 SALÓN DE LA FAMA ─┐ │
│  │  Habla 10 min       │  │  #1  CazadorX  4500 XP │ │
│  │  en sala de voz     │  │  #2  Eldarin    3200 XP │ │
│  │  [Aceptar → +50 XP] │  │  #3  Tú         2800 XP │ │
│  └──────────────────────┘  └────────────────────────┘ │
│                                                       │
│  ┌─ 🎙️ MESAS DEL GREMIO ACTIVAS ────────────────────┐ │
│  │                                                    │ │
│  │  Mesa 1: Taberna del Aprendiz      🤖 | 2/6 🟢    │ │
│  │  Mesa 2: Estrategas B1             🤖 | 4/6 🟢    │ │
│  │  Mesa 3: Pronunciación             👑 | 1/6 🟡    │ │
│  │  [+ Crear Nueva Mesa]                             │ │
│  └────────────────────────────────────────────────────┘ │
│                                                       │
│  ┌─ [📚 Biblioteca] [⚔️ Forja] [🎒 Tienda] ────────┐ │
│  │  142 palabras      Entrena fonética  Visitar      │ │
│  └────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────┤
│  [🧭 Mazmorras]  [🤝 Gremio]  [📊 Estado]  [⚙️]    │
└──────────────────────────────────────────────────────┘
```

### Principios de Diseño

| Principio | Aplicación |
|---|---|
| **Un lugar, no una lista** | Zonas visuales diferenciadas con fondos y decoración propios |
| **NPC siempre presente** | El Maestro del Gremio es el centro emocional |
| **Propósito diario** | Tablón de misiones siempre visible |
| **Progresión visible** | El jugador se ve a sí mismo en el panel superior |
| **Social proof** | Ver otros jugadores activos motiva a participar |
| **Recompensa inmediata** | Cofre diario, notificaciones, loot |
| **Control de moderación** | El creador elige cómo se modera su mesa |

---

## 3. Sistema de Moderación

### 3.1 ¿Qué se implementó?

Se agregó un sistema completo de moderación para las mesas de conversación del gremio.

### 3.2 Tipos de Moderación

| Tipo | Descripción | Quién modera | Icono |
|---|---|---|---|
| **🤖 IA** | El Tutor IA modera automáticamente. Recomendado para principiantes | Sistema IA (`system_ai`) | `smart_toy` |
| **👑 Creador** | El creador de la sala modera. Decide turnos, remueve oradores | El usuario que creó la sala | `admin_panel_settings` |
| **🎯 Asignado** | Un usuario específico (elegido por el creador) modera | Usuario designado por email | `person` |

### 3.3 Archivos Modificados

| Archivo | Cambio |
|---|---|
| `lib/features/chat_rooms/domain/repositories/chat_rooms_repository.dart` | + `moderatorType`, `assignedModeratorId` en `createRoom`; + `updateRoomModeration()`; + `getRoom()` |
| `lib/features/chat_rooms/data/repositories/chat_rooms_repository_impl.dart` | Implementación completa con lógica de moderación, slots, transferencia |
| `lib/features/chat_rooms/presentation/providers/chat_rooms_providers.dart` | + `chatRoomProvider` para obtener info de sala individual |
| `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | Nuevo diálogo de creación con selector de tipo de moderación y descripción |
| `lib/features/chat_rooms/presentation/screens/voice_room_screen.dart` | Panel de moderador, slot de IA/Moderador visible, botón para remover oradores (solo moderador) |

### 3.4 Flujo de Creación de Mesa

```
1. Usuario hace clic en "Establecer Mesa de Gremio"
2. Se abre diálogo con:
   - Nombre de la mesa
   - Descripción (opcional)
   - Categoría
   - TIPO DE MODERACIÓN (nuevo):
     ○ 🤖 IA (default)
     ○ 👑 Creador
     ○ 🎯 Asignado → requiere email del moderador
3. Usuario selecciona tipo
4. Usuario hace clic en "Crear Mesa"
5. Se crea la sala en Supabase con moderator_type y assigned_moderator_id
6. El creador entra automáticamente como orador slot 1
7. Se redirige a la sala de voz
```

### 3.5 Flujo de Moderación en Sala de Voz

```
MODERADOR (creador o asignado):
├── Ve un icono de escudo en el slot del moderador
├── Puede REMOVER cualquier orador (icono ✕ rojo)
├── Puede TRANSFERIR la moderación a otro usuario
└── El tip banner muestra "Tú moderas esta mesa"

ORADORES:
├── Ven quién modera en el header
├── No ven botones de remover
└── Solicitan turno con "Pedir Hablar"

MESA CON IA:
├── Slot 1: Tutor IA (color dorado, glow)
├── Tips rotativos cada 8 segundos
└── Banner: "Moderado por Tutor IA"
```

---

## 4. Base de Datos — Scripts

### 4.1 Migration: Moderación + Chat Rooms + Pricing + Equipped Title

**Archivo:** `supabase/migrations/20260729_full_chat_system.sql`

Este script incluye:

| Sección | Contenido |
|---|---|
| 1. Creación de tablas | `chat_rooms`, `chat_room_participants`, `chat_room_messages` (con nuevos campos) |
| 2. Migraciones | `moderator_type`, `assigned_moderator_id`, `description`, `updated_at`, `message_type` |
| 3. Foreign Keys | FK para `assigned_moderator_id` |
| 4. Realtime | Publicación para streaming en vivo |
| 5. RLS | Políticas de seguridad para lectura/escritura/actualización con permisos de moderador |
| 6. Precios | Planes de suscripción con precios agresivos ($1.99 mensual) |
| 7. Equipped Title | Columna para títulos equipables en status window |

### 4.2 Cómo ejecutar

1. Ir al **SQL Editor** de Supabase dashboard
2. Copiar el contenido de `supabase/migrations/20260729_full_chat_system.sql`
3. Ejecutar (Ctrl+Enter)

### 4.3 Esquema final de las tablas

#### `chat_rooms`
```sql
chat_rooms (
    id                  UUID PRIMARY KEY,
    title               VARCHAR(200) NOT NULL,
    category            VARCHAR(50) NOT NULL,
    moderator_id        UUID NOT NULL → users(id),
    moderator_type      TEXT NOT NULL DEFAULT 'ai' CHECK ('ai','creator','assigned'),
    assigned_moderator_id UUID → users(id) NULL,
    description         TEXT,
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW()
)
```

#### `chat_room_participants`
```sql
chat_room_participants (
    id              UUID PRIMARY KEY,
    room_id         UUID → chat_rooms(id) ON DELETE CASCADE,
    user_id         UUID → users(id) ON DELETE CASCADE,
    is_speaker      BOOLEAN DEFAULT FALSE,
    speaker_slot    INTEGER NULL CHECK (1-10),
    joined_at       TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(room_id, speaker_slot),
    UNIQUE(room_id, user_id)
)
```

#### `chat_room_messages`
```sql
chat_room_messages (
    id              UUID PRIMARY KEY,
    room_id         UUID → chat_rooms(id) ON DELETE CASCADE,
    user_id         UUID → users(id) ON DELETE CASCADE,
    message_text    TEXT NOT NULL,
    message_type    TEXT DEFAULT 'text' CHECK ('text','system','moderation'),
    created_at      TIMESTAMPTZ DEFAULT NOW()
)
```

---

## 5. Blueprint Final

### Distribución del Guild Hall

```
┌─────────────────────────────────────────────────────────────┐
│  TOP HUD                                                    │
│  [🧭 Volver]  Nivel 12  ●  Rango B1  ●  🔥 7 días racha    │
│  ─━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─── SECCIÓN 1: MAESTRO DEL GREMIO ─────────────────────┐  │
│  │  "Bienvenido... tienes 2 misiones pendientes"          │  │
│  │  [💬 Hablar con Maestro]  [🎁 Cofre Diario]            │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─── SECCIÓN 2: MISIÓN ACTIVA ──────────────────────────┐  │
│  │  📋 "Habla 10 minutos en inglés"        [3/10] ▰▰▰▰▰▰▰▰▰▰▰  │
│  │  🏅 Recompensa: +50 XP │ 🔥 Racha protegida            │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─── SECCIÓN 3: MESAS DEL GREMIO ───────────────────────┐  │
│  │  [🤖 IA] Taberna A1-A2             3/6  🟢 Unirme     │  │
│  │  [🤖 IA] Estrategas B1-B2          5/6  🟢 Unirme     │  │
│  │  [👑 Creador] Pronunciación        1/6  🟡 Unirme     │  │
│  │  [+ Crear Nueva Mesa]                                   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─── SECCIÓN 4: SERVICIOS ──────────────────────────────┐  │
│  │  [📚 Biblioteca] [⚔️ Forja] [🎒 Tienda] [🏆 Ranking]  │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─── SECCIÓN 5: SALÓN DE LA FAMA ───────────────────────┐  │
│  │  1. ⚔️ CazadorX    Lv.24    4,500 XP                  │  │
│  │  2. 🗡️ Eldarin     Lv.22    3,200 XP                  │  │
│  │  3. 🛡️ TÚ          Lv.12    2,800 XP 🟢               │  │
│  └────────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│  BOTTOM NAV                                                 │
│  [🗺️ Mazmorras] [🤝 Gremio] [📊 Estado] [⚙️ Config]      │
└─────────────────────────────────────────────────────────────┘
```

### Conexión con el Resto del Juego

| Desde el Guild Hall | Va a | Medio |
|---|---|---|
| Maestro del Gremio → Hablar | `ConversationScreen` | Conversación IA con prompt de personaje |
| Misión Activa → Aceptar | `ConversationScreen` | Escenario específico |
| Mesas → Unirme | `VoiceRoomScreen` | Sala de voz con moderación |
| Biblioteca | `HunterStatusScreen` solo vocabulario | SRS review |
| Forja | Práctica de fonética | Speech DNA integrado |
| Tienda | `PaywallScreen` | Cosméticos y suscripciones |
| Ranking | Leaderboard global | Logros y puntuación |
| Mazmorras (bottom nav) | Dashboard tab 0 | Mapa de escenarios |

---

## 6. Priorización e Impacto

### 🔴 IMPRESCINDIBLES (MVP)

| # | Componente | Impacto esperado | Esfuerzo |
|---|---|---|---|
| 1 | **NPC Maestro del Gremio** (conversación IA) | +40% retención semanal | 2 semanas |
| 2 | **Tablón de Misiones diarias** | +60% sesiones/día | 1 semana |
| 3 | **Panel de progreso del jugador** | +35% tiempo en app | 3 días |
| 4 | **Sistema de Moderación** ✅ | +25% confianza en salas | 2 días |
| 5 | **Cofre diario con recompensa** | +50% DAU | 3 días |

### 🟠 MUY IMPORTANTES

| # | Componente | Impacto | Esfuerzo |
|---|---|---|---|
| 6 | **Rediseño visual de mesas** (cartas de juego + glow) | +25% joins | 1 semana |
| 7 | **Mapa del Mundo integrado** | +20% navegación | 1 semana |
| 8 | **Salón de Trofeos / Logros** | +30% orgullo | 1 semana |
| 9 | **Ranking / Liga semanal** | +25% competencia | 4 días |

### 🟡 DESEABLES

| # | Componente | Esfuerzo |
|---|---|---|
| 10 | Biblioteca del Sabio (vocabulario + SRS) | 1 semana |
| 11 | Forja de Habilidades (fonética + gramática) | 1 semana |
| 12 | Tienda de Cosméticos | 1 semana |
| 13 | Compañero IA en el gremio | 2 semanas |
| 14 | Calendario de Eventos | 3 días |

### 🟢 FUTURAS EXPANSIONES

| # | Componente |
|---|---|
| 15 | Noticias del Mundo (lore narrativo) |
| 16 | Estatua del Héroe 3D |
| 17 | Mascotas de gremio |
| 18 | Sistema de clanes / gremios de jugadores |
| 19 | Temporadas competitivas |
| 20 | Mazmorras cooperativas en gremio |

### Roadmap Recomendado

```
Semana 1-2:   🟡 NPC Maestro del Gremio + Tablón de Misiones
              🟡 Panel de progreso del jugador
              
Semana 3:     🟢 Sistema de Moderación (IMPLEMENTADO ✅)
              🟢 Cofre diario
              
Semana 4-5:   🟠 Rediseño visual del Guild Hall
              🟠 Ranking y Salón de Trofeos
              
Semana 6-7:   🟡 Biblioteca + Forja
              🟡 Tienda
              
Semana 8+:    🟢 Expansiones futuras
```

---

## Resumen de Archivos Modificados/Creados

### Flutter (Dart)

| Archivo | Estado | Propósito |
|---|---|---|
| `lib/features/chat_rooms/domain/repositories/chat_rooms_repository.dart` | ✅ Modificado | Interfaz con nuevos métodos de moderación |
| `lib/features/chat_rooms/data/repositories/chat_rooms_repository_impl.dart` | ✅ Modificado | Implementación completa |
| `lib/features/chat_rooms/presentation/providers/chat_rooms_providers.dart` | ✅ Modificado | + `chatRoomProvider` |
| `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` | ✅ Modificado | Diálogo de creación con selector moderación |
| `lib/features/chat_rooms/presentation/screens/voice_room_screen.dart` | ✅ Modificado | Panel de moderador en sala de voz |

### Base de Datos (SQL)

| Archivo | Estado | Propósito |
|---|---|---|
| `supabase/migrations/20260728_add_equipped_title.sql` | ✅ Creado | Columna equipped_title_code |
| `supabase/migrations/20260728_aggressive_pricing.sql` | ✅ Creado | Precios $1.99 mensual |
| `supabase/migrations/20260729_add_room_moderation.sql` | ✅ Creado | Moderación de salas |
| **`supabase/migrations/20260729_full_chat_system.sql`** | ✅ **Creado** | **UNIFICADO — todo en uno** |

### Documentos

| Archivo | Estado | Propósito |
|---|---|---|
| `MONETIZATION_STRATEGY.md` | ✅ Creado | Estrategia de monetización completa |
| `GUILD_HALL_AUDIT.md` | ✅ Creado | Auditoría del Guild Hall |
| **`GUILD_HALL_COMPLETE.md`** | ✅ **Creado** | **UNIFICADO — este documento** |
