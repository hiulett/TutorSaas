# Rediseño Estratégico — Dungeon of English

> **Filosofía Central:** *"Cada compra debe hacer que el jugador disfrute más de su aventura, nunca que aprenda más que otro jugador."*

---

## PARTE 1 — Rediseño del Onboarding

### Estado Actual ❌

El usuario selecciona manualmente su nivel de inglés (A1-C2). Esto:
- Asume que el usuario conoce su nivel real (no es así)
- Rompe la inmersión al sentir que "está haciendo un test"
- No genera narrativa ni emoción

### Nuevo Flujo: "La Prueba del Oráculo del Gremio"

```
REGISTRO → PERSONALIZACIÓN DEL PERSONAJE → PRIMERA MISIÓN → RANGO INICIAL
```

#### Paso 1: Creación del Personaje (Nuevo)

El usuario no se registra como estudiante. **Crea su personaje aventurero:**

| Campo | Propósito | Implementación |
|---|---|---|
| **Nombre del Cazador** | El nombre que verán otros en el gremio | Texto libre |
| **Clase inicial** | Berserker (extrovertido), Mago (analítico), Pícaro (práctico) | 3 opciones visuales |
| **Avatar** | Selección de estilo básico | 8 opciones predefinidas |
| **Idioma nativo** | Para traducciones y correcciones | Selector |

La clase inicial NO afecta el aprendizaje real. Afecta:
- El estilo de las misiones iniciales
- La personalidad del NPC mentor
- La estética del personaje

#### Paso 2: Cinemática de Bienvenida (Nuevo)

Una transición animada (tipo visual novel) donde el **Maestro del Gremio** aparece y dice:

> "Ah, un nuevo rostro. El Oráculo me dijo que llegarías. Tengo una primera misión para ti. No te preocupes por tu nivel — el Oráculo lo determinará mientras hablamos."

#### Paso 3: "La Prueba del Oráculo" — Conversación de Evaluación Silenciosa

El usuario conversa con el NPC Maestro del Gremio durante **3-5 minutos** sobre:
- Su nombre, de dónde viene
- Por qué quiere aprender inglés
- Sus intereses y hobbies
- Una pregunta sorpresa (ej: "¿Qué harías si encontraras un dragón?")

**Durante la conversación, la IA evalúa:**

| Dimensión | Evaluación | Cómo se mide |
|---|---|---|
| Speaking | Fluidez, velocidad, pausas | WPM, duración de pausas |
| Listening | Comprensión de instrucciones | ¿Responde coherentemente? |
| Grammar | Precisión gramatical | Ratio de errores vs aciertos |
| Vocabulary | Rango léxico | Palabras únicas, sofisticación |
| Pronunciación | Claridad fonética | Score de Groq Whisper |
| Confianza | Seguridad al hablar | Pausas, muletillas, repeticiones |

#### Paso 4: Resultado — Rango, No Nota

Al finalizar, **NO hay nota ni aprobado/reprobado**. En su lugar:

| Elemento | Descripción |
|---|---|
| **Rango Inicial** | E, D o C según desempeño (todos empiezan en E-D) |
| **Rol en el Gremio** | Aprendiz, Explorador, Guerrero (según clase + desempeño) |
| **Título Inicial** | "Novato del Abismo" — todos lo reciben |
| **Misión Siguiente** | Desbloqueada automáticamente según nivel |

#### Paso 5: Onboarding del Guild Hall (Nuevo)

El Maestro del Gremio guía al usuario por el Guild Hall:
1. "Este es el Tablón de Misiones" → Destaca visualmente
2. "Estas son las Mesas del Gremio" → Muestra salas activas
3. "Aquí está tu Progreso" → Panel con rango y estadísticas
4. "Buena suerte, Cazador" → Primera misión lista

### Cambios Técnicos Requeridos

| Archivo | Cambio |
|---|---|
| `onboarding_screen.dart` | Reemplazar step de "seleccionar nivel" por creación de personaje |
| `hunter_license_screen.dart` | Mantener pero conectar a evaluación real |
| `conversation_providers.dart` | Nuevo modo "onboarding assessment" con evaluación silenciosa |
| `user_language_profiles` | Agregar `player_class`, `guild_role` |
| `router.dart` | Ajustar flujo de onboarding |
| **NUEVO** `widgets/character_creation_wizard.dart` | Creación de personaje visual |

---

## PARTE 2 — Rediseño de las Misiones

### Sistema Actual ❌

Misiones = escenarios de conversación. Funcional pero plano. No hay variedad.

### Nuevo Sistema: 7 Tipos de Misiones

#### 1. 📜 Historia Principal (Main Quest)
- Secuencia lineal que lleva al usuario A1→C2
- Cada "capítulo" tiene un jefe final (boss)
- **Narrativa:** El Reino de Inglés está fragmentado. Debes restaurar los 6 Cristales del Lenguaje (uno por nivel CEFR)
- **Gratis para todos**

#### 2. 📋 Misiones Secundarias (Side Quests)
- Escenarios específicos (restaurante, aeropuerto, entrevista)
- Desbloqueables según nivel
- Recompensa: XP, oro, objetos
- **Gratis para todos**

#### 3. 🔮 Misiones Secretas (Hidden Quests) — NUEVO
Generadas dinámicamente por IA basándose en:
- Errores frecuentes del usuario
- Tiempo sin practicar una habilidad
- Patrones de la conversación anterior
- Intereses del usuario

**Ejemplo:** Si el usuario falló el pasado simple 3 veces → Aparece una misión: "El Viejo Mago del Tiempo" que solo habla en pasado simple.

**Nunca se siente como ejercicio.** Es parte de la historia.

#### 4. ⚡ Misiones Dinámicas (IA-Generated) — NUEVO
- La IA genera escenarios únicos cada vez
- "Un viajero necesita ayuda en la taberna..."
- **Ilimitadas** para Premium, 2/día para Free

#### 5. 🏆 Misiones del Gremio (Guild Quests)
- Retos colectivos: "Entre todos, hablen 100 minutos hoy"
- Recompensa compartida (cofre del gremio)
- **Gratis para todos**

#### 6. 🎯 Retos Diarios / Semanales
- "Habla 10 minutos", "Usa 5 palabras nuevas"
- Recompensa: gemas, oro, XP
- **Gratis para todos**

#### 7. 👻 Misiones de Evento (Limited Time)
- Temporales (Halloween, Navidad, colaboraciones)
- Cosméticos exclusivos como recompensa
- **Gratis para participar.** Cosméticos exclusivos para completar

### Gameplay Loop Rediseñado

```
┌──────────────────────────────────────────────────────────────────┐
│                    MAPA DEL MUNDO                                │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐  │
│  │ 📜 Historia │  │ 📋 Secun-  │  │ 🔮 Misión  │  │ ⚡ Diná- │  │
│  │ Principal  │  │ darias     │  │ Secreta!   │  │ mica     │  │
│  │ Cap. 4/6   │  │ 3 disp.    │  │ (NUEVA)    │  │ 2/2 hoy  │  │
│  │ [Continuar]│  │ [Explorar] │  │ [Aceptar]  │  │ [Generar]│  │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘  │
│                                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐  │
│  │ 🏆 Gremio  │  │ 🎯 Diario  │  │ 👻 Evento  │  │ 🗺️ Todas │  │
│  │ Reto: 50%  │  │ 3/4 retos  │  │ Sabana     │  │ las      │  │
│  │ [Ver]      │  │ [Ver]      │  │ Sagrada    │  │ misiones │  │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

---

## PARTE 3 — Misiones Secretas (Hidden Quests)

### Cómo funciona

1. **Trigger:** Después de cada sesión, la IA analiza el desempeño
2. **Detección:** Identifica un patrón de mejora o error recurrente
3. **Generación:** Crea una mini-misión que aborda ese patrón
4. **Entrega:** Aparece como "Misión Secreta Descubierta" con efecto visual especial

### Ejemplos Reales

| Patrón detectado | Misión Generada | Cómo se presenta |
|---|---|---|
| Usuario duda con "th" | "El Tesoro del Dragón Tartamudo" — un dragón que solo habla con /th/ | NPC dragón con lisp exagerado |
| Tiempo sin practicar (3 días) | "El Mensajero del Reino" — un NPC aparece con una carta urgente | Notificación en el Guild Hall |
| Vocabulario repetitivo | "El Poeta Aburrido" — un poeta pide ayuda con sinónimos | Misión en la Biblioteca |
| Buen desempeño en gramática | "El Guardián del Grammaticón" — libro parlante que da un título cosmético | Logro sorpresa |
| El usuario dijo "I want" muchas veces | "El Rey Caprichoso" — NPC que solo responde si usas "I would like" | Misión de etiqueta |

### Reglas de Generación

| Regla | Descripción |
|---|---|
| **1 secreta por día máximo** | Evita saturación |
| **Aparece con efecto especial** | Partículas doradas, sonido de descubrimiento |
| **Tiempo límite** | 24h para aceptar. Si no, desaparece |
| **Recompensa mayor** | 2x XP de una misión normal |
| **Costo IA** | Casi nulo — reusa el análisis post-sesión |

---

## PARTE 4 — Rediseño de la Economía

### Recursos Rediseñados

| Recurso | Obtención | Gasto | ¿Se puede comprar? |
|---|---|---|---|
| **💠 Oro** (Monedas de Maná) | Misiones, conversaciones, rachas, logros | Pociones, entry fees, decoraciones menores | ❌ No |
| **💎 Cristales del Sistema** | Logros, niveles, batle pass, eventos | Cosméticos, objetos exclusivos, battle pass | ✅ Sí — Tienda |
| **🔮 Reliquias** (NUEVO) | Misiones secretas, eventos, logros raros | Títulos legendarios, efectos únicos | ❌ No — solo se ganan |
| **📜 Pergaminos** (NUEVO) | Rachas diarias, misiones del gremio | Boost temporal de XP (cosmético) | ❌ No |
| **🏆 Trofeos** (NUEVO) | Logros permanentes, hitos | Nada — son coleccionables | ❌ No |

### Principios de la Nueva Economía

| Principio | Aplicación |
|---|---|
| **El conocimiento no se compra** | El XP solo se gana practicando |
| **Lo premium es cosmético y social** | Las gemas solo compran apariencia y conveniencia |
| **Lo raro es ganado, no comprado** | Las reliquias solo se obtienen con logros reales |
| **Sin inflación** | El oro tiene sumideros constantes (pociones, entry fees) |
| **Sin pay-to-win** | No hay objeto que acelere el aprendizaje |

### Flujo económico

```
         ┌──────────────────────────────────────────────┐
         │              ECONOMÍA DEL JUEGO               │
         │                                                │
         │  ENTRADAS              SALIDAS                 │
         │  ─────────           ─────────                 │
         │  • Misiones → Oro    • Pociones → Oro          │
         │  • Rachas → Oro      • Entry fees → Oro        │
         │  • Logros → Cristales • Cosméticos → Cristales │
         │  • Eventos → Reliquias • Boosts → Cristales    │
         │  • IAP → Cristales   • Battle Pass → Cristales │
         │  • Nivel → Cristales • Misiones secretas → nada│
         │                                                │
         │  El oro se gasta en consumibles.               │
         │  Los cristales se gastan en vanidad.           │
         │  Las reliquias son recuerdo de logros.         │
         └──────────────────────────────────────────────┘
```

---

## PARTE 5 — Rediseño de los Items

### Filosofía

Los objetos NO dan ventaja educativa. Los objetos **cambian cómo se vive la aventura**.

### Catálogo de Objetos

#### Consumibles (se compran con oro o gemas)

| Objeto | Efecto | Precio | Rareza |
|---|---|---|---|
| **Poción de Maná** | +1 crédito de IA adicional | 100 oro | Común |
| **Pergamino de Concentración** | +50% XP por 30 min (cosmético: aura brillante) | 50 gemas | Raro |
| **Brújula del Explorador** | Revela 1 misión secreta adicional | 80 gemas | Raro |
| **Llave del Conocimiento** | Acceso a 1 ítem de la tienda exclusiva | 150 gemas | Épico |
| **Cristal de Recuerdo** | Guarda una conversación como recuerdo (cosmético) | 30 gemas | Común |

#### Equipamiento Cosmético (permanente, con gemas)

| Objeto | Efecto visual | Precio | Rareza |
|---|---|---|---|
| **Espada de Maná** | Cambia el icono del personaje en el chat | 200 gemas | Raro |
| **Escudo del Abismo** | Marco de avatar con glow violeta | 300 gemas | Épico |
| **Capa del Errante** | Efecto de partículas al enviar mensajes | 500 gemas | Épico |
| **Corona del Monarca** | Título dorado visible en el gremio | 1000 gemas | Legendario |
| **Alas de Dragón** | Animación al desplazarse entre pantallas | 2000 gemas | Legendario |

#### Reliquias (no se compran — solo se ganan)

| Reliquia | Cómo se obtiene | Efecto |
|---|---|---|
| **Fragmento del Oráculo** | Completar la prueba inicial | Título "Evaluado por el Oráculo" |
| **Gema del Políglota** | Alcanzar 500 palabras de vocabulario | Marco especial |
| **Corazón del Dragón** | Completar un nivel CEFR completo | Efecto visual al completar misiones |
| **Llave del Tiempo** | Racha de 30 días | Título "Imparable" |
| **Alma del Gremio** | Participar en 50 horas de mesa de gremio | Insignia en perfil |

---

## PARTE 6 — Personalización

### Catálogo de Personalización (Todo Cosmético)

| Categoría | Elementos | Precio sugerido | Potencial comercial |
|---|---|---|---|
| **🎨 Skins de Avatar** | 10 estilos iniciales, más por temporada | 300-800 gemas | 🔥 Alto |
| **🛡️ Marcos de Avatar** | 12 marcos (por nivel, logros, tienda) | 100-500 gemas | 🔥 Alto |
| **✨ Auras y Efectos** | Partículas al escribir, glow en avatar | 200-1000 gemas | 🟠 Medio-Alto |
| **🎵 Música Ambiental** | Temas para Guild Hall, mazmorras | 150-400 gemas | 🟡 Medio |
| **📜 Títulos** | "Cazador Novato", "Elocuente", "Imparable" | 100-500 gemas | 🔥 Alto |
| **👾 Mascotas** | Acompañantes visuales en el gremio | 300-1500 gemas | 🔥🔥 Muy alto |
| **💬 Emotes** | Reacciones visuales en mesas de gremio | 50-200 gemas | 🟠 Medio-Alto |
| **🎭 Temas de UI** | Colores del HUD, fondos de pantalla | 500-2000 gemas | 🟡 Medio |
| **🏠 Decoración Gremio** | Muebles, estatuas, banners | 200-3000 gemas | 🔥 Alto |
| **👗 Outfits de Personaje** | Sets completos de armadura/ropa | 800-2500 gemas | 🔥🔥 Muy alto |

### Principio de Personalización

> Todo lo que se vende debe ser visible para otros jugadores.  
> Si no se ve, no tiene valor social.  
> Si no tiene valor social, no se vende.

---

## PARTE 7 — Rediseño del Gremio

### Estructura del Nuevo Guild Hall

```
┌─────────────────────────────────────────────────────────────┐
│  🗺️ GREMIO DE CAZADORES — SALÓN PRINCIPAL                    │
│                                                              │
│  ┌─ MAESTRO DEL GREMIO (NPC vivo) ────────────────────────┐ │
│  │  [Avatar] "Bienvenido. Hoy hay 3 misiones nuevas."     │ │
│  │  [💬 Conversar] [📋 Misiones] [🎁 Recompensas]          │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─ ZONA SOCIAL ──────────────────────────────────────────┐  │
│  │  [Mesas de Voz]  [Salón de Trofeos]  [Ranking]         │  │
│  │  🟢 3 activas      🏆 12/30 trofeos   👑 #3 esta semana │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ SERVICIOS ────────────────────────────────────────────┐  │
│  │  [📚 Biblioteca] [⚔️ Forja] [🎒 Tienda] [🏟️ Eventos]  │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ TU PROGRESO ──────────────────────────────────────────┐  │
│  │  Rango B1 ● Lv.12 ● 🔥7 días ● 📖142 palabras          │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Nuevas Funcionalidades del Gremio

| Funcionalidad | Descripción | Monetización |
|---|---|---|
| **Salones Privados** | Mesas con contraseña para grupos de amigos | ❌ Gratis |
| **Mascotas del Gremio** | Mascota compartida que aparece en la mesa | ✅ Cosmético |
| **Calendario de Eventos** | Torneos semanales, eventos especiales | ❌ Gratis |
| **Mercader del Gremio** | Tienda rotativa con objetos exclusivos | ✅ Gemas |
| **Subastas** | Pujar por objetos raros con oro del gremio | ❌ Gratis (usa oro) |
| **Biblioteca Compartida** | Vocabulario descubierto por el gremio visible para todos | ❌ Gratis |
| **Salón de la Fama** | Top jugadores del gremio por semana/mes | ❌ Gratis |
| **Noticias del Mundo** | Lore semanal que avanza la historia | ❌ Gratis |

---

## PARTE 8 — Sistema de Mesas (Rediseñado)

### Modelo Operativo

```
┌──────────────────────────────────────────────────────────┐
│  MESA: "Estrategias B1"  [🤖 IA Asiste] [👑 Mod: Juan]  │
│                                                           │
│  ORADORES (hasta 8):                                      │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐              │
│  │Tú│ │M2│ │M3│ │  │ │  │ │  │ │  │ │  │              │
│  │🔊│ │🔇│ │🔊│ │➕│ │➕│ │➕│ │➕│ │➕│              │
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘ └──┘              │
│                                                           │
│  ESPECTADORES (ilimitados): 🧑 12 👤  👤  👤             │
│                                                           │
│  💬 Chat: "Buena pronunciación, María!"                   │
│                                                           │
│  [✋ Pedir turno] [🤚 Ceder asiento] [👋 Salir]          │
└──────────────────────────────────────────────────────────┘
```

### Mecánica de Turnos

1. Un espectador pide turno (✋)
2. El moderador ve la solicitud
3. Cuando un orador abandona, el siguiente en la cola ocupa el asiento
4. El moderador puede priorizar, saltar o denegar solicitudes
5. La IA sugiere: "María lleva 15 min esperando" o "Juan ha hablado 20 min seguidos"

### Moderación

| Rol | Quién lo ejerce | Permisos |
|---|---|---|
| **Creador** | Dueño de la sala | Todo: asignar mods, remover, cerrar sala |
| **Moderador** | Asignado por el creador | Gestionar turnos, remover oradores |
| **IA Asistente** | Sistema (opcional) | Sugerencias, no acciones directas |

---

## PARTE 9 — Monetización del Gremio

### Lo que es GRATIS

| Funcionalidad | Por qué |
|---|---|
| Unirse a cualquier mesa | La interacción social básica es un derecho |
| Ser espectador ilimitado | Escuchar es parte del aprendizaje |
| Chatear en el chat de texto | La comunicación escrita también es práctica |
| Ver el ranking del gremio | La competencia sana es motivación gratuita |
| Recibir recompensas del gremio | Fomenta la participación colectiva |

### Lo que se MONETIZA (cosmético/social)

| Elemento | Precio | Por qué funciona |
|---|---|---|
| **Personalizar el nombre de la mesa** | 100 gemas | Los creadores quieren mesas únicas |
| **Tema visual de la mesa** | 300-800 gemas | Cada mesa se ve diferente |
| **Mascota del gremio visible** | 500 gemas | Estatus social |
| **Efectos al hablar (auras)** | 200-400 gemas | Verse "mágico" al hablar |
| **Insignia de "Anfitrión"** | 150 gemas | Reconocimiento social |
| **Salón privado (con contraseña)** | 200 gemas/creación | Grupos de amigos |
| **Emotes premium en chat** | 50-100 gemas cada uno | Reacciones únicas |
| **Battle Pass del Gremio** | 800 gemas ($4.99) | Temporada con recompensas exclusivas |

### Battle Pass del Gremio

| Nivel | Recompensa (Free) | Recompensa (Premium) |
|---|---|---|
| 1 | 50 gemas | Título "Miembro del Gremio" |
| 5 | 100 gemas | Efecto "Maná del Gremio" |
| 10 | 150 gemas | Marco "Escudo del Gremio" |
| 15 | 200 gemas | Mascota "Espíritu del Gremio" |
| 20 | Título "Veterano" | Corona "Rey del Gremio" |

---

## PARTE 10 — IA Premium

### Funcionalidades Premium que Justifican Modelos Más Avanzados

| Funcionalidad | Modelo | Costo adicional | Valor percibido |
|---|---|---|---|
| **Mentor Personal** | DeepSeek Pro + memoria persistente | +$0.02/sesión | 🔥🔥 Muy alto |
| **Coach de Pronunciación** | DeepSeek Pro + análisis fonético | +$0.01/sesión | 🔥 Alto |
| **Simulaciones Laborales** | DeepSeek Pro + contexto largo | +$0.03/sesión | 🔥🔥 Muy alto |
| **Entrevistas de Trabajo** | DeepSeek Pro + prompt especializado | +$0.04/sesión | 🔥🔥🔥 Altísimo |
| **Debates / Negociaciones** | DeepSeek Pro + rol complex | +$0.03/sesión | 🔥 Alto |
| **Preparación TOEFL/IELTS** | DeepSeek Pro + structure evaluator | +$0.05/sesión | 🔥🔥🔥 Altísimo |

### Modelo de Precios para IA Premium

| Funcionalidad | Disponible en | Precio efectivo |
|---|---|---|
| Coach de Pronunciación | Premium $1.99 | Incluido |
| Mentor Personal | Premium $1.99 | Incluido |
| Simulaciones Laborales | Premium Anual $14.99 | Incluido |
| Debates y Negociaciones | Premium Anual $14.99 | Incluido |
| Preparación TOEFL/IELTS | **+$4.99 extra** (costo alto) | Add-on |
| Entrevistas con feedback | Premium $1.99 | Incluido |

---

## PARTE 11 — Costos de IA (Optimización)

### Arquitectura Multi-Modelo Final

```
USUARIO HABLA
    │
    ▼
┌─────────────────┐
│ Groq Whisper    │  $0.006/min → solo cuando habla
│ (STT)           │
└────────┬────────┘
         │ texto transcrito
         ▼
┌─────────────────┐
│ ROUTER DE IA     │  Decide qué modelo usar según:
│                  │  • Tipo de interacción
│                  │  • Nivel CEFR del usuario
│                  │  • Plan (Free/Premium)
│                  │  • Urgencia (real-time vs batch)
└──┬──────────────┘
   │
   ├──→ DeepSeek Flash (80% tráfico)
   │     Conversación normal, NPC, moderador
   │     $0.08/M input · $0.18/M output
   │
   ├──→ DeepSeek Pro (15% tráfico)
   │     Evaluaciones, speech DNA, coaching
   │     $0.28/M input · $0.55/M output
   │
   └──→ Cache Local (5% tráfico)
         Correcciones comunes, frases hechas
         GRATIS
```

### Estrategias de Reducción de Costos

| Estrategia | Ahorro | Aplicación |
|---|---|---|
| **Modelo diferencial por plan** | 30% | Free usa Flash. Premium usa Pro cuando es necesario |
| **Cache de respuestas comunes** | 15% | Correcciones frecuentes, frases de saludo |
| **Prompt compression automática** | 20% | Enviar solo últimos N mensajes + resumen |
| **Batch evaluation** | 5% | Evaluar goals cada 3 mensajes |
| **Fine-tuned mini-model** | 50% | Modelo pequeño para tareas de corrección gramatical |
| **Contexto adaptativo por nivel** | 10% | A1: contexto corto. C1: contexto completo |
| **Audio compression** | 20% | 64kbps en vez de 128kbps para Groq |

---

## PARTE 12 — Nuevas Oportunidades

### Mecánicas RPG No Implementadas Aún

| Mecánica | Descripción | Impacto |
|---|---|---|
| **Gremios de Jugadores** (guilds creadas por usuarios) | Jugadores se agrupan, compiten, tienen chat propio | 🔥 Retención social |
| **Mazmorras Cooperativas** | 2-4 jugadores contra un boss IA | 🔥🔥 Engagement |
| **Duelos 1v1** | Dos jugadores conversan, la IA evalúa al mejor | 🔥 Competencia |
| **Comercio entre Jugadores** | Intercambio de objetos cosméticos | 🟠 Economía |
| **Misiones con Compañero IA** | Mascota que evoluciona según desempeño | 🟠 Progresión |
| **Forja de Objetos** | Combinar ítems para crear objetos únicos | 🟠 Economía |
| **Mundo Abierto** | Mapa con zonas desbloqueables por nivel | 🔥 Exploración |
| **Diario del Aventurero** | Historial de toda la aventura con estadísticas | 🟡 Retención |

### Oportunidades de IA No Exploradas

| Oportunidad | Descripción | Costo |
|---|---|---|
| **Clon de Voz** | TTS con la voz del usuario para respuestas | Medio |
| **Traducción Simultánea** | Mostrar traducción en tiempo real de lo que dice el NPC | Bajo |
| **Análisis de Sentimiento** | Detectar frustración y ajustar dificultad | Bajo |
| **Generación de Lore Personalizado** | La historia se adapta a las decisiones del usuario | Medio |
| **Compañero de Estudio IA** | Un NPC que "aprende" junto al usuario | Medio |

---

## PARTE 13 — Impacto en el Sistema Actual

### Resumen de Cambios por Módulo

| Módulo | Cambios | Archivos afectados |
|---|---|---|
| **Onboarding** | Reemplazar selección de nivel por evaluación silenciosa + creación de personaje | `onboarding_screen.dart`, `conversation_providers.dart`, **NUEVO** `character_creation_wizard.dart` |
| **Misiones** | Agregar tipos: secreta, dinámica, gremio, evento. Mapa visual de misiones | `lesson_catalog.dart`, **NUEVO** `mission_map_widget.dart` |
| **Economía** | Agregar Cristales, Reliquias, Pergaminos, Trofeos. Repensar consumibles | `hunter_catalog.dart`, **NUEVO** `inventory_system.dart` |
| **Items** | Implementar objetos cosméticos funcionales. Catálogo de personalización | **NUEVO** `shop_screen.dart`, **NUEVO** `cosmetic_system.dart` |
| **Gremio** | Agregar salones privados, mascotas, eventos, subastas, battle pass del gremio | `chat_rooms_screen.dart`, `voice_room_screen.dart` |
| **IA Premium** | Mentor personal, coach pronunciación, simulaciones, TOEFL/IELTS | `conversation_providers.dart`, **NUEVO** `premium_coach_screen.dart` |
| **Perfil** | Agregar personalización completa: skins, marcos, mascotas, títulos | `profile_screen.dart`, `hunter_status_screen.dart` |

### Nuevas Tablas de Base de Datos

```sql
-- Personajes de jugadores
CREATE TABLE player_characters (
    id UUID PRIMARY KEY,
    user_id UUID UNIQUE REFERENCES users(id),
    class VARCHAR(50), -- 'berserker', 'mage', 'rogue'
    guild_role VARCHAR(50),
    title_equipped VARCHAR(100),
    avatar_skin VARCHAR(100),
    aura_effect VARCHAR(100),
    pet_equipped VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventario de objetos cosméticos
CREATE TABLE player_inventory (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    item_code VARCHAR(100) NOT NULL,
    item_type VARCHAR(50), -- 'title','skin','aura','pet','emote','theme'
    is_equipped BOOLEAN DEFAULT false,
    acquired_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reliquias (logros no comprables)
CREATE TABLE player_relics (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    relic_code VARCHAR(100) NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, relic_code)
);

-- Misiones secretas generadas por IA
CREATE TABLE hidden_quests (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    quest_data JSONB NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de personalización (catálogo de tienda)
CREATE TABLE cosmetic_catalog (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50), -- 'skin','title','pet','aura','emote','theme'
    description TEXT,
    price_gems INTEGER NOT NULL DEFAULT 0,
    rarity VARCHAR(20), -- 'common','rare','epic','legendary'
    is_limited BOOLEAN DEFAULT false,
    season VARCHAR(50),
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## PARTE 14 — Roadmap de Implementación

### Fase 1: MVP Fundamental (Semanas 1-4)

| Iniciativa | Dependencias | Esfuerzo | Impacto |
|---|---|---|---|
| Sistema de economía (oro, cristales, reliquias) | Ninguna | 2 semanas | 🔴 Crítico |
| Personalización básica (títulos, marcos) | Sistema economía | 1 semana | 🔴 Crítico |
| Creación de personaje en onboarding | Ninguna | 2 semanas | 🔴 Crítico |
| Evaluación silenciosa por IA | Sistema IA existente | 1 semana | 🔴 Crítico |
| Mapa visual de misiones | Ninguna | 1 semana | 🟠 Alto |
| Tablas DB de inventario y catálogo | Ninguna | 2 días | 🔴 Crítico |

### Fase 2: Social y Gremio (Semanas 5-8)

| Iniciativa | Dependencias | Esfuerzo | Impacto |
|---|---|---|---|
| Mesas con turnos y espectadores | Sistema gremio existente | 2 semanas | 🔴 Crítico |
| Moderador humano + IA asistente | Sistema gremio | 1 semana | 🔴 Crítico |
| Misiones secretas generadas por IA | Sistema IA + misiones | 2 semanas | 🟠 Alto |
| Misiones del gremio (colaborativas) | Sistema gremio | 1 semana | 🟠 Alto |
| Ranking del gremio | Sistema gremio | 3 días | 🟡 Medio |

### Fase 3: Monetización Premium (Semanas 9-12)

| Iniciativa | Dependencias | Esfuerzo | Impacto |
|---|---|---|---|
| Tienda de cosméticos (gemas) | Sistema economía + inventario | 2 semanas | 🔴 Crítico (revenue) |
| Battle Pass del gremio | Sistema economía | 2 semanas | 🔴 Crítico (retención) |
| Coach de pronunciación (IA Premium) | Sistema IA | 1 semana | 🟠 Alto (upsell) |
| Mentor personal (IA Premium) | Sistema IA | 2 semanas | 🟠 Alto (upsell) |
| Sistema de mascotas | Sistema inventario | 1 semana | 🟡 Medio |

### Fase 4: Expansiones (Mes 4+)

| Iniciativa | Dependencias | Esfuerzo | Impacto |
|---|---|---|---|
| Simulaciones laborales y TOEFL/IELTS | Sistema IA Premium | 2 semanas | 🟠 Alto |
| Gremios de jugadores (user-created guilds) | Sistema gremio | 3 semanas | 🔥 Muy alto |
| Mazmorras cooperativas | Sistema multijugador | 4 semanas | 🔥 Muy alto |
| Subastas entre jugadores | Sistema economía | 2 semanas | 🟡 Medio |
| Mundo abierto con mapa navegable | Sistema misiones | 3 semanas | 🟠 Alto |
| Eventos temporales con cosméticos limitados | Tienda + economía | 1 semana | 🟠 Alto |

---

## Conclusión: El Lema del Producto

> **"Dungeon of English no vende inglés. Vende una aventura donde aprender inglés es la consecuencia."**

Cada decisión de producto, cada línea de UI, cada ítem en la tienda, cada mecánica de juego debe responder a una pregunta:

> **"¿Esto hace que el jugador disfrute más su aventura, o solo aprende más?"**

Si la respuesta es "aprende más" → debe ser gratis.
Si la respuesta es "disfruta más" → puede monetizarse.

Esa es la regla que protege la reputación, mantiene la equidad y construye un negocio sostenible.
