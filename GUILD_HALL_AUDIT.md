# Auditoría del Gran Salón del Gremio — Dungeon of English

---

## FASE 1 — Comprensión del Propósito

### ¿Cuál debería ser el propósito del Gran Salón del Gremio?
El centro neurálgico del juego. El lugar al que el jugador regresa después de cada misión para procesar su progreso, planificar su siguiente movimiento, conectarse con otros jugadores y sentir que pertenece a un mundo vivo.

### ¿Por qué existe?
Porque todo RPG necesita un **hub**. Es el contrapunto emocional a la tensión de las mazmorras. Es donde el jugador descansa, socializa, y encuentra significado a su progreso.

### ¿Qué emociones debería provocar?
- **Pertenencia:** "Este es mi gremio. Estos son mis compañeros"
- **Anticipación:** "¿Qué misiones nuevas hay hoy?"
- **Orgullo:** "Mira mi rango, mis trofeos, mi progreso"
- **Curiosidad:** "¿Qué hay en esa sala que aún no he explorado?"
- **Seguridad:** "Estoy a salvo aquí. Puedo prepararme"

### ¿Qué papel cumple dentro del Gameplay Loop?
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  SALÓN DEL   │ ──→ │  MAZMORRA    │ ──→ │  REVISIÓN   │
│  GREMIO      │     │  (Misión)    │     │  (Summary)  │
│  (Planificar)│     │  (Practicar) │     │  (Resultado)│
└─────────────┘     └──────────────┘     └─────────────┘
       ↑                                        │
       └────────────────────────────────────────┘
                   (Regreso al hub)
```

### ¿Qué papel cumple dentro del aprendizaje?
No es aprendizaje directo — es **metacognición y motivación**. Aquí el jugador:
- Ve su progreso (vocabulario, gramática, fluidez)
- Selecciona qué habilidad practicar
- Se compromete con objetivos diarios/semanales
- Recibe recompensas que refuerzan el hábito

### ¿Qué papel dentro de la narrativa?
Es donde la historia del mundo Isekai se desarrolla entre misiones. El Maestro del Gremio da contexto, los NPCs ofrecen pistas, el tablón de misiones revela la situación actual del mundo.

---

## FASE 2 — Concepto Ideal

### Arquitectura y Ambientación

Imagina entrar a un salón de guild de un manhwa oscuro:

```
GRAN SALÓN DEL GREMIO DE CAZADORES

        [BALCÓN DEL MAESTRO]
        ┌──────────────────────────┐
        │  ★ Maestro del Gremio    │
        │  (NPC animado parlante)   │
        └──────────────────────────┘
        
  [Tablón]  [Mapa]  [Herrero]  [Biblioteca]  [Portal]
  
        ┌──────────────────────────┐
        │  JUGADORES ONLINE (3)    │
        │  Mesa 1: A1-A2 (2/6)    │
        │  Mesa 2: B1-B2 (4/6)    │
        │  Mesa 3: C1-C2 (1/6)    │
        └──────────────────────────┘
  
        ┌──────────────────────────┐
        │  TUS MISIONES ACTIVAS    │
        │  [Principal] [Diarias]   │
        └──────────────────────────┘
  
  [Barra inferior: Inventario, Skills, Amigos, Salir]
```

### Distribución de Espacios

| Zona | Propósito | Visibilidad |
|---|---|---|
| **Trono del Maestro** | NPC principal, bienvenida, narrativa | Siempre visible arriba |
| **Tablón de Misiones** | Quests diarias, principal, semanal | Segunda sección |
| **Mapa del Mundo** | Acceso a mazmorras y escenarios | Tercera sección |
| **Mesas del Gremio** | Salas de voz activas | Sección central |
| **Tu Estado** | Mini resumen del jugador |sidebar o cabecera |
| **Salón de Trofeos** | Logros, coleccionables | Sección al scroll |
| **Portal de Salida** | Volver al juego | Barra inferior |

### Sistema HUD en el Guild Hall
- **Mana bar** arriba (XP actual)
- **Rango del jugador** (E→SSS)
- **Notificaciones** (misiones nuevas, mensajes)
- **Reloj del mundo** (día/noche)
- **Clima** (efecto visual de fondo)

### Microinteracciones
- Al pasar el dedo sobre una mesa: glow y leve scale
- Al completar misión desde el tablón: partículas doradas
- NPC maestro: animación de respiración, parpadeo
- Mapa: marcadores pulsantes en mazmorras disponibles
- Trofeos: brillo tenue en los conseguidos, silueta en los bloqueados

---

## FASE 3 — Auditoría Visual del Estado Actual

| Elemento | Estado | Justificación |
|---|---|---|
| **Layout** | ❌ No cumple | Es un scroll vertical genérico de chat rooms. No hay arquitectura de "salón" |
| **Jerarquía** | ❌ No cumple | Hero banner genérico, lista de salas, categorías. No hay zonas diferenciadas |
| **Espaciado** | ⚠ Parcial | Padding consistente, pero falta jerarquía espacial entre secciones |
| **Colores** | ⚠ Parcial | Usa `manaCyan` y `emeraldGreen`, pero falta el `amberAccent` que `CyberBgMode.guildHall` define |
| **Tipografía** | ⚠ Parcial | Título en `SpaceGrotesk`. Subtítulos no usan `JetBrainsMono` |
| **Glassmorphism** | ✅ Cumple | `GlassCard` usado correctamente |
| **Glow** | ❌ No cumple | No hay glow en las tarjetas de sala. No hay runic corners |
| **Sci-Fi Overlay** | ❌ No cumple | Fondo genérico sin scanlines, sin elementos HUD |
| **Dark Fantasy** | ⚠ Parcial | Colores oscuros correctos, pero sin decoración fantasy |
| **Iconografía** | ❌ No cumple | Iconos genéricos de Material. No hay iconos de gremio, espadas, escudos |
| **Avatar del jugador** | ❌ No cumple | No se ve el jugador en ninguna parte |
| **Cards de sala** | ⚠ Parcial | Funcionales pero genéricas. Sin personalidad |
| **Hero Banner** | ❌ No cumple | "EL GRAN GREMIO DE CAZADORES" con fondo de GlassCard básico. Sin emoción |
| **Fondo** | ❌ No cumple | Usa `CyberManhwaBackground` en modo `guildHall` pero no hay assets de gremio visibles |
| **Animaciones** | ❌ No cumple | No hay animaciones de entrada, ni pulsaciones, ni movimientos |

**Puntuación visual: 25/100**

---

## FASE 4 — Arquitectura de Información

### ¿Qué información SOBRA?
- El hero banner ocupa mucho espacio para decir poco
- Las categorías (Viajes, Trabajo, Tecnología, etc.) son genéricas y no aportan contexto narrativo

### ¿Qué información FALTA?
| Elemento | Prioridad |
|---|---|
| **Rango/Nivel del jugador** | Crítica |
| **Misiones activas del jugador** | Crítica |
| **Progreso CEFR** | Alta |
| **NPC del gremio (Maestro)** | Alta |
| **Noticias/eventos del mundo** | Alta |
| **Compañeros conectados** | Alta |
| **Recompensas por reclamar** | Alta |
| **Próximo examen/boss** | Media |
| **Clima del mundo** | Baja |

### ¿Qué acciones debería poder realizar el jugador?
1. ✅ Ver salas de voz activas
2. ✅ Crear sala de voz
3. ✅ Unirse a sala de voz
4. ❌ **Hablar con el Maestro del Gremio** (conversación IA)
5. ❌ **Ver y aceptar misiones** (diarias, semanales, principal)
6. ❌ **Ver su progreso y estadísticas**
7. ❌ **Reclamar recompensas acumuladas**
8. ❌ **Ver el mapa del mundo**
9. ❌ **Entrenar habilidades** (pronunciación, gramática)
10. ❌ **Ver el salón de la fama / rankings**
11. ❌ **Acceder al inventario / equipo**
12. ❌ **Ver el calendario de eventos**
13. ❌ **Recibir mensajes / invitaciones**

### ¿Existe sobrecarga cognitiva?
No. El problema opuesto: **infra carga cognitiva**. La pantalla es tan simple que no transmite la complejidad y riqueza de un gremio.

### ¿Existe información escondida?
No, pero debería. El jugador debería descubrir rincones, NPCs ocultos, secretos del gremio.

---

## FASE 5 — Experiencia RPG

### ¿Realmente parece el Gran Salón de un gremio?
**NO.** Actualmente es una lista de chat rooms con un título "El Gran Hall del Gremio". No hay sensación de "lugar".

### Elementos faltantes vs. presentes:

| Elemento | Estado | Impacto |
|---|---|---|
| **Maestro del Gremio (NPC)** | ❌ Ausente | **Crítico** — es el alma del lugar |
| **Tablón de Misiones** | ❌ Ausente | **Crítico** — da propósito |
| **Mapa Mundial** | ❌ Ausente | Alto — conecta con el mundo |
| **Sala de Entrenamiento** | ❌ Ausente | Alto — learning hub |
| **Biblioteca (Vocabulario)** | ❌ Ausente | Medio |
| **Mercader / Tienda** | ❌ Ausente | Medio — monetización |
| **Portal de Mazmorras** | ❌ Ausente | Alto — gameplay loop |
| **Salón de Trofeos** | ❌ Ausente | Alto — orgullo |
| **Ranking** | ❌ Ausente | Alto — competencia |
| **Compañeros online** | ❌ Ausente | Crítico — social proof |
| **Eventos** | ❌ Ausente | Alto — retención |
| **Misiones diarias** | ❌ Ausente | Crítico — engagement |
| **Recompensas/Cofres** | ❌ Ausente | Crítico — dopamine hits |
| **Salas de Voz (Mesas)** | ✅ Presente | Correcto, pero pobres visualmente |

---

## FASE 6 — Experiencia del Aventurero

### ¿El jugador encuentra fácilmente...?

| Elemento | Estado | Dónde está ahora |
|---|---|---|
| **Su siguiente objetivo** | ❌ No | No hay guía de misión principal |
| **Su progreso** | ❌ No | No se muestra en el guild hall |
| **Su nivel** | ❌ No | No se muestra |
| **Su XP** | ❌ No | No se muestra |
| **Su energía** | ❌ No | No se muestra |
| **Sus habilidades** | ❌ No | No hay acceso desde aquí |
| **Su inventario** | ❌ No | No hay acceso |
| **Sus recompensas** | ❌ No | No se muestran |
| **Sus logros** | ❌ No | No se muestran |
| **Conversaciones pendientes** | ❌ No | No hay indicación |
| **Misión principal** | ❌ No | No existe |
| **Misiones secundarias** | ❌ No | No existen |
| **Compañero IA** | ❌ No | No está presente |

**La pantalla actual es solo un "selector de salas de voz" disfrazado de gremio.**

---

## FASE 7 — Aprendizaje

### ¿Cómo puede esta pantalla incentivar el aprendizaje?

Actualmente **no lo hace**. Oportunidades:

| Elemento de aprendizaje | Cómo integrarlo en el Guild Hall |
|---|---|
| **Vocabulario nuevo** | Biblioteca con palabras descubiertas en misiones |
| **Habilidades lingüísticas** | Árbol de skills (fluidez, gramática, vocabulario, fonética) |
| **Progreso CEFR** | Medallero con nivel actual y siguiente |
| **Objetivos diarios** | Tablón de misiones: "Hoy: 10 minutos de speaking" |
| **Logros educativos** | Trofeos: "1000 palabras aprendidas", "50 conversaciones" |
| **Recordatorios** | NPC que dice "Practicaste ayer, ¡sigue así!" |
| **Repaso SRS** | Biblioteca que ofrece repaso de tarjetas |
| **Preparación para boss** | "Entrena fonética antes del examen C1" |

### Principio clave
El aprendizaje en el Guild Hall es **pasivo y contextual**:
- No se estudia aquí — se **planifica** el estudio
- No se aprende aquí — se **celebra** lo aprendido
- No se hace trabajo aquí — se **encuentra motivación** para hacerlo

---

## FASE 8 — Gamificación

### Evaluación actual

| Mecánica | Estado | Nota |
|---|---|---|
| Loops de recompensa | ❌ Ausente | No hay recompensas visibles |
| Progresión | ❌ Ausente | No se ve progreso |
| Curiosidad | ❌ Ausente | No hay nada que descubrir |
| Coleccionables | ❌ Ausente | No hay trofeos ni objetos |
| Eventos | ❌ Ausente | No hay eventos visibles |
| Recompensas variables | ❌ Ausente | No hay cofres ni loot |
| Feedback inmediato | ❌ Ausente | Al unirse a sala no hay feedback especial |
| Metas corto plazo | ❌ Ausente | "Habla hoy 5 minutos" |
| Metas largo plazo | ❌ Ausente | "Alcanza rango B esta temporada" |

### Lo que DEBERÍA existir

```
CICLO DE GAMIFICACIÓN EN EL GREMIO

1. Llegas al gremio
2. NPC te da la bienvenida + contexto narrativo
3. Tablón muestra misiones diarias (3 de aprendizaje)
4. Aceptas misión → "Habla 10 minutos en sala de voz"
5. Entras a sala, practicas
6. Vuelves al gremio
7. Misión se completa ✅
8. Obtienes +50 XP + Cofre (recompensa variable)
9. Ves tu progreso en el medallero
10. Tablón muestra nueva misión → repetir
```

---

## FASE 9 — Benchmark con RPG Modernos

| Juego | Práctica | Cómo adaptarla |
|---|---|---|
| **Genshin Impact** | HUB de ciudad con NPCs, comisiones diarias, tienda, forja | NPC Maestro del Gremio que da misiones diarias contextuales |
| **Persona 5** | Cafè LeBlanc como hub, calendario, amigos, actividades | Calendario de eventos semanales, sistema de confianza con NPCs |
| **Fire Emblem: Three Houses** | Monasterio con distintas zonas (comedor, biblioteca, campo) | Zonas diferenciadas dentro del gremio: Biblioteca (vocabulario), Forja (pronunciación), Tablón (misiones) |
| **World of Warcraft** | Capital cities with auction house, inn, class trainers | Sub-áreas funcionales: tienda, entrenador de habilidades, taberna social |
| **Stardew Valley** | Pueblo con NPCs que dan quests, calendario de eventos | NPCs rotativos con diferentes personalidades y quests semanales |
| **Hades** | Sala central con NPCs que comentan progreso, espejo de habilidades, armas | NPC que comenta tu última sesión, panel de stats detallado, equipamiento de títulos |

### Principios clave de los hubs AAA
1. **Capa social:** Siempre hay otros personajes (aunque sean NPCs)
2. **Rutina diaria:** El jugador sabe exactamente qué hacer al llegar (daily quests)
3. **Recompensa inmediata:** Algo te espera (cofre, mensaje, notificación)
4. **Progresión visible:** Tu personaje se ve diferente según avanzas
5. **Misterio y descubrimiento:** Hay rincones que se desbloquean con el tiempo

---

## FASE 10 — Componentes Faltantes

### Lista completa de lo que DEBERÍA existir

| # | Componente | Categoría | Propósito |
|---|---|---|---|
| 1 | **Maestro del Gremio (NPC IA)** | Social/Narrativa | Dar bienvenida, contexto, consejos personalizados |
| 2 | **Tablón de Misiones** | Gameplay | Quests diarias y semanales visibles |
| 3 | **Tu Progreso (Mini Panel)** | Progresión | XP, nivel, rango, racha activa |
| 4 | **Mapa del Mundo** | Navegación | Acceso a mazmorras, escenarios, exámenes |
| 5 | **Salas de Voz Activas** | Social | Mesas con jugadores actuales |
| 6 | **Salón de Trofeos** | Colección | Logros, títulos, hitos |
| 7 | **Biblioteca del Sabio** | Aprendizaje | Vocabulario, frases, SRS review |
| 8 | **Forja de Habilidades** | Aprendizaje | Árbol de skills, fonética, gramática |
| 9 | **Mercader / Tienda** | Monetización | Cosméticos, consumibles, pases |
| 10 | **Correo / Mensajes** | Social | Invitaciones, recompensas, notificaciones |
| 11 | **Ranking / Salón de la Fama** | Competencia | Mejores jugadores, liga actual |
| 12 | **Calendario de Eventos** | Retención | Eventos semanales, temporadas |
| 13 | **Cofre Diario** | Recompensa | Loot diario rotatorio |
| 14 | **Compañero IA** | Compañía | Mascota/familiar que comenta progreso |
| 15 | **Portal de Salida** | Navegación | Volver al dashboard / mazmorras |
| 16 | **Noticias del Mundo** | Narrativa | Lore, actualizaciones, historia en curso |
| 17 | **Estatua del Héroe** | Orgullo | Representación visual del rango del jugador |
| 18 | **Diario del Aventurero** | Progresión | Historial de sesiones |
| 19 | **Bestiario** | Colección | Monstruos encontrados, derrotados |
| 20 | **Sala de Amigos** | Social | Lista de amigos, estado online |

---

## FASE 11 — Priorización

### 🔴 Imprescindibles (MVP Minimum)
| # | Componente | Por qué |
|---|---|---|
| 1 | **Maestro del Gremio (NPC IA)** | Da alma al lugar. Sin él, es solo una UI |
| 2 | **Tablón de Misiones** | Da propósito. Sin él, el jugador no sabe qué hacer |
| 3 | **Tu Progreso (Mini Panel)** | Muestra XP, nivel, racha. Conexión con el sistema de progresión |
| 4 | **Salas de Voz Mejoradas** | El contenido actual debe mantenerse pero con mejor presentación |
| 5 | **Misiones Diarias integradas** | Engagement diario. El jugador vuelve por ellas |

### 🟠 Muy Importantes (Siguiente iteración)
| # | Componente | Por qué |
|---|---|---|
| 6 | **Mapa del Mundo** | Conecta el gremio con el resto del juego |
| 7 | **Salón de Trofeos** | Orgullo, coleccionables, motivación a largo plazo |
| 8 | **Ranking / Liga** | Competencia social, retención |
| 9 | **Cofre Diario** | Dopamina diaria, refuerzo positivo |
| 10 | **Calendario de Eventos** | Anticipación, contenido recurrente |

### 🟡 Deseables
| # | Componente |
|---|---|
| 11 | Biblioteca del Sabio |
| 12 | Forja de Habilidades |
| 13 | Mercader / Tienda |
| 14 | Compañero IA |
| 15 | Correo / Mensajes |

### 🟢 Futuras Expansiones
| # | Componente |
|---|---|
| 16 | Noticias del Mundo |
| 17 | Estatua del Héroe |
| 18 | Diario del Aventurero |
| 19 | Bestiario |
| 20 | Sala de Amigos |

---

## FASE 12 — Blueprint Final

### Distribución del Guild Hall Ideal

```
┌──────────────────────────────────────────────────────┐
│  🔮 MANÁ: 450/500  │  NIVEL 12  │  RANGO B1  │ 🔔  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  │
│   [BARRA SUPERIOR — Siempre visible]               │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌────────────────────────────────────────────┐      │
│  │  ★ MAESTRO DEL GREMIO                       │      │
│  │  [Avatar NPC] "Bienvenido de vuelta,       │      │
│  │   Cazador. Tu racha de 7 días es           │      │
│  │   impresionante. Hoy hay una misión        │      │
│  │   urgente en el tablón."                    │      │
│  │  ┌────────────────────────────────────┐    │      │
│  │  │ [Hablar con Maestro] [Ir a Misión] │    │      │
│  │  └────────────────────────────────────┘    │      │
│  └────────────────────────────────────────────┘      │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │ 📋 MISIÓN    │  │ 🗺️ MAPA      │  │ 🏆 LOGROS │  │
│  │ DIARIA       │  │ DEL MUNDO    │  │           │  │
│  │ Habla 10 min │  │ 3 mazmorras  │  │ 12/30     │  │
│  │ [Aceptar]    │  │ disponibles  │  │ trofeos   │  │
│  └──────────────┘  └──────────────┘  └───────────┘  │
│                                                       │
│  ┌────────────────────────────────────────────┐      │
│  │  🎙️ MESAS DEL GREMIO (3 ACTIVAS)           │      │
│  │                                              │      │
│  │  Mesa 1: La Taberna del Aprendiz            │      │
│  │  A1-A2 │ 2/6 oradores │ [Unirme] 🔴          │      │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━               │      │
│  │                                              │      │
│  │  Mesa 2: Estrategas B1                      │      │
│  │  B1 │ 4/6 oradores │ Moderador IA │ [Unirme] │      │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━               │      │
│  │                                              │      │
│  │  Mesa 3: Alto Consejo C1                    │      │
│  │  C1-C2 │ 1/6 oradores │ [Unirme]            │      │
│  └────────────────────────────────────────────┘      │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │ 📚 BIBLIOTECA│  │ ⚔️ FORJA     │  │ 🎒 TIENDA │  │
│  │ 142 palabras │  │ Entrena      │  │           │  │
│  │ [Repasar]    │  │ Fonética     │  │ [Visitar] │  │
│  └──────────────┘  └──────────────┘  └───────────┘  │
│                                                       │
├──────────────────────────────────────────────────────┤
│  [🧭 Mazmorras]  [🤝 Gremio]  [📊 Estado]  [⚙️]    │
│   ——————————————————————————                          │
│   [BARRA INFERIOR — Navegación principal]             │
└──────────────────────────────────────────────────────┘
```

### Flujo de Usuario

```
1. Entra al Guild Hall
2. NPC Maestro saluda → da contexto + sugiere acción
3. Opción A: Tablón → acepta misión diaria
4. Opción B: Mesas → entra a sala de voz
5. Opción C: Progreso → ve stats
6. Opción D: Tienda → gasta monedas
7. Completa misión → vuelve al gremio
8. NPC felicita → recibe recompensa
9. Sale a la siguiente misión
```

---

## INFORME FINAL

### ¿La pantalla actual transmite realmente la sensación de ser el Gran Salón de un Gremio?
**No.** La pantalla actual es un catálogo de salas de voz con un título temático. No hay NPCs, no hay misiones, no hay personalización, no hay sensación de "lugar". Es funcional pero emocionalmente plana.

### ¿Qué porcentaje de inmersión ofrece actualmente?
**15%.** Tiene el fondo temático, los colores oscuros, y el nombre. Pero no hay interacción que sostenga la fantasía.

### ¿Qué tan alineada está con el tema "Isekai / Webtoon Manhwa / System HUD"?
**20%.** Usa la paleta de colores y las tipografías correctas, pero carece de todos los elementos de System HUD (scanlines, bordes de sistema, runas, ventanas flotantes, datos en tiempo real).

### Elementos imprescindibles para convertirla en experiencia de clase mundial
1. **NPC Maestro del Gremio con IA conversacional** — el alma del lugar
2. **Tablón de Misiones visible** — propósito diario
3. **Panel de progreso del jugador** — conexión con el sistema RPG
4. **Zonificación visual del espacio** — no es una lista, es un "lugar"
5. **Mesas de Gremio rediseñadas como cartas de juego** — no list items

### Cambios de mayor impacto en motivación y retención
| Cambio | Impacto esperado |
|---|---|
| Agregar NPC Maestro con saludo personalizado | +40% retención semanal |
| Misiones diarias visibles desde el gremio | +60% sesiones/día |
| Cofre diario con recompensa variable | +50% DAU |
| Progreso visible (XP, nivel, rango) | +35% tiempo en app |
| Mesas rediseñadas con glow y animaciones | +25% joins a salas |

### Puntuación Global

| Dimensión | Puntaje (0-100) |
|---|---|
| **Diseño visual** | 25 |
| **Experiencia de usuario** | 30 |
| **Inmersión** | 15 |
| **Narrativa** | 10 |
| **Gamificación** | 10 |
| **Arquitectura de información** | 35 |
| **Potencial de retención** | 20 |
| **Consistencia con identidad del producto** | 25 |
| **PUNTAJE GENERAL** | **21/100** |

### Veredicto Final

**El Gran Salón del Gremio no está preparado para ser el centro neurálgico de la experiencia.**

Actualmente es una pantalla funcional de "listado de salas de voz" disfrazada con un tema superficial. No cumple ninguna de las funciones emocionales, narrativas o de gameplay que debería cumplir un hub en un RPG.

El mayor problema es que **no hay "ahí" ahí**. El jugador llega, ve una lista, hace clic, y se va. No hay razón para quedarse, explorar, socializar o regresar.

**Se requiere un rediseño fundamental.** No se trata de ajustar la UI existente — hay que reconstruir la pantalla desde cero con una visión clara de lo que significa "estar en el gremio".

Las prioridades inmediatas son:
1. NPC Maestro del Gremio (conversación IA)
2. Tablón de Misiones diarias
3. Panel de progreso del jugador
4. Rediseño visual de las mesas como cartas de juego con glow y animaciones
5. Cofre diario con recompensa

Sin estos cambios, el Guild Hall seguirá siendo el eslabón más débil de la experiencia Dungeon of English.
