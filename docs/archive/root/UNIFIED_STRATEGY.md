# Estrategia Unificada — Dungeon of English

> **Documento Final:** Julio 2026  
> **Propósito:** Rediseño completo de economía, IA, progresión, misiones, gremio y monetización  
> **Filosofía:** *"La IA no es gratuita. Es un recurso del universo del juego."*

---

## Sumario Ejecutivo

Este documento unifica todos los análisis previos — auditoría del chat, monetización, pricing, Guild Hall, modelo económico y rediseño filosófico — en una estrategia única y coherente.

**Los 3 pilares del nuevo modelo:**

| Pilar | Principio |
|---|---|
| **IA como recurso narrativo** | El límite técnico se convierte en mecánica RPG. El usuario no ve "tokens", ve "Cristales de Maná" |
| **Aprendizaje siempre gratuito** | Todo el contenido educativo esencial es accesible sin pagar |
| **Monetización de la aventura** | Se vende personalización, social, conveniencia — nunca conocimiento |

---

## PARTE 1 — Diagnóstico del Modelo Actual

### Problemas Identificados

| # | Problema | Impacto |
|---|---|---|
| 1 | **La IA no tiene límite narrativo** — el usuario ve "error de conexión" en vez de "el Oráculo está agotado" | Baja inmersión |
| 2 | **El plan gratuito es generoso sin estrategia** — 20 créditos/día sin narrativa que justifique el límite | Baja conversión a Premium |
| 3 | **La economía es plana** — solo XP y Gemas. No hay recursos intermedios que creen decisiones interesantes | Bajo engagement |
| 4 | **Las misiones secretas no existen en código** — el concepto está en los documentos pero no implementado | Oportunidad perdida |
| 5 | **El Guild Hall no genera retención** — no hay razón para volver a diario | Churn alto |
| 6 | **No hay objetos cosméticos implementados** — la tienda solo vende suscripciones | Bajo ARPU |

### Costos Actuales (Refresco)

| Concepto | Valor |
|---|---|
| Costo por sesión de 10 min | $0.006 |
| Costo mensual usuario Free activo | $0.26 |
| Costo mensual usuario Premium | $0.71 |
| Costo lifetime IA (100% del juego) | ~$9.25 |
| Margen plan $1.99/mes | 52% |

---

## PARTE 2 — IA Como Recurso del Universo

### Nueva Narrativa del Límite Técnico

| Término técnico | Traducción narrativa | Visible en UI |
|---|---|---|
| Token | **Esencia de Maná** | Barra de maná morada |
| API call | **Invocación al Oráculo** | Animación de portal |
| Rate limit | **El Núcleo Arcano se está recargando** | Barra de recarga con texto |
| Crédito diario | **Cristal de Maná Diario** | Ícono de cristal brillante |
| Modelo pequeño (Flash) | **Invocación Menor** | Brillo azul tenue |
| Modelo grande (Pro) | **Invocación Mayor** | Brillo dorado con partículas |
| Cache de respuesta | **Eco del Oráculo** | Efecto de onda |
| Error de API | **El Velo del Abismo se ha cerrado** | Pantalla con runas |

### SLA Visual (Nuevo)

Cuando un usuario Free agota sus invocaciones diarias, NO ve:

> ❌ "Has alcanzado el límite diario. Actualiza a Premium."

Ve:

> ✅ "El Núcleo Arcano necesita recargarse. Vuelve mañana cuando el sol del nuevo día alimente los Cristales de Maná. Los Cazadores de Élite pueden invocar al Oráculo sin límites."

Y se le muestran **3 opciones**:

```
┌──────────────────────────────────────────────────┐
│  EL NÚCLEO ARCANO ESTÁ AGOTÁNDOSE                │
│                                                   │
│  El Oráculo ha respondido 20 veces hoy.           │
│  Necesita recargarse con la luz del amanecer.     │
│                                                   │
│  ┌──────────────────────────────────────────┐    │
│  │ 💠 Recargar con Cristal de Maná (50 💎)   │    │
│  │   Invoca al Oráculo 5 veces más           │    │
│  └──────────────────────────────────────────┘    │
│                                                   │
│  ┌──────────────────────────────────────────┐    │
│  │ 👑 Desbloquear Invocaciones Ilimitadas    │    │
│  │   Conviértete en Cazador de Élite         │    │
│  │   Desde $1.99/mes                         │    │
│  └──────────────────────────────────────────┘    │
│                                                   │
│  ┌──────────────────────────────────────────┐    │
│  │ 🌙 Descansar hasta mañana                │    │
│  │   El Núcleo se recargará con el nuevo día │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
```

### Modelo de Invocaciones

| Recurso | Nombre en juego | Efecto |
|---|---|---|
| **Invocaciones diarias gratis** | Cristales de Maná del Amanecer | 20/día para todos |
| **Recarga con moneda** | Cristal de Maná (consumible) | +5 invocaciones por 50 gemas |
| **Premium** | Vínculo Permanente con el Oráculo | Invocaciones ilimitadas |
| **Batch sin IA** | Pergamino de Sabiduría Antigua | Contenido pre-generado que NO consume IA |

---

## PARTE 3 — Nueva Economía

### Recursos y su Propósito

```
                         ECONOMÍA DE DUNGEON OF ENGLISH
                         
    ╔═══════════════════════════════════════════════════════╗
    ║                    RECURSOS PRINCIPALES                ║
    ╠═══════════════════════════════════════════════════════╣
    ║                                                       ║
    ║  ★ XP (Experiencia)                                   ║
    ║     • Se gana: practicando, misiones, logros          ║
    ║     • Se gasta: NUNCA — solo mide progreso            ║
    ║     • COMPRABLE: ❌ No                                ║
    ║     • Propósito: Progresión real del aprendizaje      ║
    ║                                                       ║
    ║  💠 Oro (Monedas de Maná)                             ║
    ║     • Se gana: misiones, rachas, logros               ║
    ║     • Se gasta: consumibles, entry fees, decoración   ║
    ║     • COMPRABLE: ❌ No                                 ║
    ║     • Propósito: Economía del juego, sumideros        ║
    ║                                                       ║
    ║  💎 Cristales (Gemas)                                 ║
    ║     • Se gana: logros, niveles, eventos, COMPRA       ║
    ║     • Se gasta: invocaciones extra, cosméticos        ║
    ║     • COMPRABLE: ✅ Sí ($4.99-$34.99)                 ║
    ║     • Propósito: Monetización principal               ║
    ║                                                       ║
    ║  🔮 Reliquias (NUEVO)                                 ║
    ║     • Se gana: logros imposibles de comprar           ║
    ║     • Se gasta: NUNCA — son coleccionables            ║
    ║     • COMPRABLE: ❌ No — solo se ganan                ║
    ║     • Propósito: Estatus, orgullo, prueba de logro    ║
    ║                                                       ║
    ║  📜 Pergaminos de Sabiduría (NUEVO)                   ║
    ║     • Se gana: diario (5/día), rachas, tesoros        ║
    ║     • Se gasta: contenido offline (SIN IA)            ║
    ║     • COMPRABLE: ✅ Sí (paquetes)                     ║
    ║     • Propósito: Práctica sin costo de IA             ║
    ║                                                       ║
    ║  ⚡ Energía Arcana (NUEVO)                             ║
    ║     • Se gana: tiempo (1 cada 30 min, max 20)         ║
    ║     • Se gasta: mazmorras especiales, bosses extras   ║
    ║     • COMPRABLE: Sí (con oro o cristales)             ║
    ║     • Propósito: Limitar contenido premium sin         ║
    ║       bloquear el aprendizaje esencial                 ║
    ║                                                       ║
    ╚═══════════════════════════════════════════════════════╝
```

### Flujo de la Nueva Economía

```
FUENTES                          SUMIDEROS
─────────                        ──────────

★ Misiones            →    ★ XP (progresión, nunca se gasta)
★ Rachas              →    
★ Logros              →    
★ Conversaciones      →    

💠 Misiones           →    💠 Pociones, entry fees, decoración
💠 Rachas             →    💠 Pergaminos de Sabiduría
💠 Logros             →    

💎 Logros             →    💎 Invocaciones extra
💎 Niveles CEFR       →    💎 Cosméticos (skins, mascotas, auras)
💎 Eventos            →    💎 Battle Pass
💎 COMPRA IAP ($)     →    💎 Pergaminos de Sabiduría
                         →    💎 Decoraciones del Gremio

🔮 Hitos de logro     →    🔮 Colección (nunca se gasta)

📜 Diario (5/día)     →    📜 Conversaciones sin IA (offline)
📜 Rachas             →    📜 Repaso SRS sin IA
📜 Tesoros            →    
📜 Compra (💎/💰)     →    

⚡ Tiempo             →    ⚡ Mazmorras extra
⚡ Oro                →    ⚡ Bosses repetibles
⚡ Cristales          →    
```

### Economía de los Pergaminos de Sabiduría (NUEVO — Clave para reducir costos de IA)

Los Pergaminos de Sabiduría son **contenido conversacional pre-generado** que NO consume IA en tiempo real. Son fundamentales para la sostenibilidad del modelo.

| Aspecto | Detalle |
|---|---|
| **Qué son** | Diálogos pre-escritos con ramas simples (como un libro-juego) |
| **Cómo se generan** | La IA los genera por la noche (batch) para el usuario del día siguiente |
| **Cuánto cuestan** | Casi nada — solo almacenamiento |
| **Cada cuánto** | 5 pergaminos/día gratis. Se pueden comprar más |
| **Para qué sirven** | Práctica de lectura, comprensión, vocabulario |
| **Qué NO hacen** | No generan conversación libre (eso requiere IA en vivo) |

**Impacto:** Si el 30% de las interacciones diarias migran a Pergaminos, el costo de IA se reduce en **30%**.

---

## PARTE 4 — Nuevo Sistema de Misiones

### Las 3 Categorías

```
┌──────────────────────────────────────────────────────────────────┐
│                    SISTEMA DE MISIONES                            │
│                                                                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
│  │  📜 RECOMENDADAS │  │  🔮 SECRETAS     │  │  🏆 DEL GREMIO   │  │
│  │                  │  │                  │  │                  │  │
│  │ • Historia ppal  │  │ • Generadas IA   │  │ • Infinitas      │  │
│  │ • Ruta CEFR      │  │ • Según errores  │  │ • Siempre hay    │  │
│  │ • Progreso real  │  │ • 1/día máximo   │  │ • Rotan           │  │
│  │ • ~300 total     │  │ • 2x XP          │  │ • Sociales        │  │
│  │ • 100% GRATIS    │  │ • GRATIS         │  │ • Mixtas IA/est.  │  │
│  └─────────────────┘  └─────────────────┘  └──────────────────┘  │
│                                                                   │
│  PROPÓSITO:           PROPÓSITO:            PROPÓSITO:             │
│  Aprender             Reforzar              Retener                │
│  Progresar            Personalizar          Socializar             │
│  Avanzar              Sorprender            Volver cada día        │
└──────────────────────────────────────────────────────────────────┘
```

### Misiones del Gremio — Sistema Detallado (NUEVO)

#### Categorías de Misiones del Gremio

| Tipo | Descripción | Contenido | Costo IA |
|---|---|---|---|
| **🗓️ Diarias** | 3 misiones que rotan cada día | Predefinido (pool de 50) | **GRATIS** — solo rotación |
| **📅 Semanales** | 1 misión por semana | Predefinido (pool de 20) | **GRATIS** |
| **⚡ Emergencias** | Evento aleatorio, 1-2h de duración | Generado por IA | **$0.01/evento** (1-2x/día) |
| **👥 Colaborativas** | Meta del gremio: "100 min hoy" | Predefinido | **GRATIS** |
| **🌍 Invasiones** | Evento global vs IA | IA genera contexto | **$0.02/invasión** (1/semana) |
| **🏟️ Torneos** | Competencia semanal de speaking | IA evalúa | **$0.03/torneo** |

#### Tablón del Gremio (Pantalla)

```
┌──────────────────────────────────────────────────────────────┐
│  🏆 TABLÓN DEL GREMIO                                         │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ 🗓️ DIARIAS                         ⏳ Renueva en 5h │    │
│  │                                                       │    │
│  │ [📋] Habla 5 min en sala de voz    🟢 Completado     │    │
│  │ [📋] Usa 3 palabras nuevas         🟡 1/3            │    │
│  │ [📋] Saluda a un miembro           🔴 Pendiente      │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ 📅 SEMANAL                          ⏳ 3 días resto  │    │
│  │                                                       │    │
│  │ [🏆] Completa 10 misiones esta semana 🟡 7/10        │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ ⚡ EMERGENCIA — ACTIVAHORA!          ⏳ 45 min resto │    │
│  │                                                       │    │
│  │ [🔥] Un viajero necesita ayuda urgente en la taberna  │    │
│  │      Recompensa: +100 XP + Cofre del Gremio          │    │
│  │      [ACEPTAR]                                       │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ 👥 COLABORATIVA                       70% completo   │    │
│  │                                                       │    │
│  │ El gremio debe hablar 100 min hoy    ▰▰▰▰▰▰▰▰▰▰     │    │
│  │                                        70/100 min    │    │
│  │ [🎁] Cofre del Gremio: 500 XP para todos            │    │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

### Estrategia de Contenido para Reducir Costos

| Tipo de misión | % del contenido | ¿Usa IA? | Costo |
|---|---|---|---|
| Recomendadas (historia) | 20% | ✅ Sí, en vivo | $0.006/sesión |
| Secretas (IA) | 10% | ✅ Sí, generación + ejecución | $0.008/sesión |
| Del Gremio — Diarias | 25% | ❌ No, pool predefinido | **GRATIS** |
| Del Gremio — Semanales | 15% | ❌ No, pool predefinido | **GRATIS** |
| Del Gremio — Emergencias | 5% | ✅ Sí, generación IA | $0.01/evento |
| Del Gremio — Colaborativas | 15% | ❌ No, contadores simples | **GRATIS** |
| Del Gremio — Torneos | 5% | ✅ Sí, evaluación IA | $0.03/torneo |
| Pergaminos de Sabiduría | 5% | ❌ No, batch nocturno | **GRATIS** (generación previa) |

**Ahorro estimado:** ~60% de las interacciones diarias no requieren IA en vivo.

---

## PARTE 5 — Monetización del Gremio

### Catálogo de la Tienda del Gremio

| Categoría | Producto | Precio (💎) | USD aprox | Rareza |
|---|---|---|---|---|
| **🎨 Mesas** | Tema "Bosque Nocturno" | 2,000 | $9.99 | Épico |
| | Tema "Abismo Arcano" | 3,000 | $14.99 | Legendario |
| | Tema "Sabana Sagrada" (evento) | 2,500 | $12.99 | Limitado |
| **👾 Mascotas** | Familiar "Lunático" | 1,500 | $7.99 | Épico |
| | Familiar "Fénix Carbonizado" | 2,500 | $12.99 | Legendario |
| | Huevo Misterioso (random) | 500 | $2.99 | Sorpresa |
| **🏰 Salones** | Salón Privado (1 semana) | 500 | $2.99 | — |
| | Salón VIP (1 mes) | 1,500 | $7.99 | — |
| **🎭 Cosmética** | Aura "Llama de Maná" | 800 | $3.99 | Raro |
| | Efecto "Partículas Arcanas" | 1,200 | $5.99 | Épico |
| | Marco "Cazador de Sombras" | 600 | $2.99 | Raro |
| | Título "Voz del Gremio" | 400 | $1.99 | Raro |
| | Paquete Emotes (10) | 400 | $1.99 | Común |
| **🏆 Battle Pass** | Pase de Temporada | 800 | $4.99 | — |
| | Pase Premium (contenido extra) | 1,500 | $7.99 | — |
| **📜 Pergaminos** | Pack Pequeño (10) | 100 | $0.50 | — |
| | Pack Grande (50) | 400 | $1.99 | — |
| | Pack Ilimitado (1 mes) | 1,000 | $4.99 | — |

### Battle Pass del Gremio

| Nivel | Recompensa Free | Recompensa Premium (800💎) |
|---|---|---|
| 1 | 50💎 | Título "Aprendiz del Gremio" |
| 5 | Pergamino x5 | Efecto "Maná del Gremio" |
| 10 | 100💎 | Marco "Escudo del Gremio" |
| 15 | Pergamino x10 | Mascota "Espíritu del Gremio" |
| 20 | 150💎 | Corona "Rey del Gremio" + 500💎 |

### Sistema de Cofres del Gremio (NUEVO)

Cuando el gremio completa misiones colaborativas, se llena un "Cofre del Gremio":

| Nivel de cofre | Umbral | Recompensa para todos |
|---|---|---|
| Bronce | 500 XP colectivos | 50💎 + Pergamino x3 |
| Plata | 1,500 XP colectivos | 100💎 + Pergamino x5 |
| Oro | 3,000 XP colectivos | 200💎 + Pergamino x10 + Título temporal |
| Platino | 5,000 XP colectivos | 500💎 + Pergamino x20 + Cosmético exclusivo |

---

## PARTE 6 — Modelo Freemium Rediseñado

### Plan Gratuito

| Recurso | Cantidad | Propósito |
|---|---|---|
| **Invocaciones al Oráculo** (IA en vivo) | 20/día | Suficiente para 3-4 sesiones de práctica |
| **Pergaminos de Sabiduría** (sin IA) | 5/día | Práctica adicional sin costo para la plataforma |
| **Misiones Recomendadas** | Ilimitadas | Toda la historia principal es gratis |
| **Misiones Secretas** | 1/día | Personalización sin costo |
| **Misiones del Gremio** | Ilimitadas | Contenido social infinito |
| **Mesas del Gremio** | Ilimitado | Unirse, escuchar, chatear |
| **Crear mesa (con IA moderadora)** | 2/día | Suficiente para probar |
| **Battle Pass** | Sí, ruta gratuita | Recompensas básicas |
| **Cosméticos** | Solo los gratuitos | Suficiente para personalizar |

**Costo mensual de IA para un usuario Free activo: $0.26/mes**

### Plan Premium $1.99/mes

| Recurso | Cantidad |
|---|---|
| **Invocaciones al Oráculo** | Ilimitadas |
| **Pergaminos de Sabiduría** | Ilimitados |
| **Misiones Secretas** | 3/día |
| **Crear mesa con IA moderadora** | Ilimitado |
| **Battle Pass** | Ruta completa |
| **Cosméticos exclusivos** | Todos disponibles |
| **Coach de Pronunciación** | Incluido |
| **Mentor Personal** | Incluido |

**Costo mensual de IA para un usuario Premium: $0.50-0.70/mes**
**Margen bruto: 52-74%**

### Plan Anual $14.99/año

| Recurso | Cantidad |
|---|---|
| Todo lo del plan mensual | ✅ |
| Battle Pass incluido (sin costo extra) | ✅ ($4.99/mes de ahorro) |
| Simulaciones laborales | ✅ |
| Debates y negociaciones | ✅ |
| Alma del Gremio (título exclusivo) | ✅ |
| Precio efectivo | **$1.25/mes** |

**Costo mensual de IA: $0.70/mes**
**Margen: 44% (recuperado con permanencia + compras de gemas)**

### Plan Lifetime $29.99

| Recurso | Cantidad |
|---|---|
| Todo lo del plan anual | ✅ |
| Todos los cosméticos futuros | ✅ |
| Prioridad máxima en servidores | ✅ |
| Título "Fundador Legendario" | ✅ (solo para los primeros 10,000) |

**Costo total de IA: ~$0.70/mes → se recupera en ~36 meses**

---

## PARTE 7 — Estrategias de Reducción de Costos de IA

### Arquitectura Híbrida

```
INTERACCIÓN DEL USUARIO
         │
         ▼
┌──────────────────────────────────────────┐
│           ¿Requiere IA en vivo?           │
│                                          │
│  ¿Es una conversación libre?             │
│  ¿Es una evaluación?                     │
│  ¿Es generación de contenido único?      │
└────────────────┬─────────────────────────┘
                 │
      ┌──────────┴──────────┐
      ▼                     ▼
  SÍ (30%)              NO (70%)
      │                     │
      ▼                     ▼
┌──────────────┐   ┌──────────────────┐
│  DeepSeek    │   │  Contenido       │
│  Flash/Pro   │   │  Pre-generado    │
│  En vivo     │   │  • Pergaminos    │
│  $0.006/ses  │   │  • Pool misiones │
└──────────────┘   │  • Batch nocturno│
                   │  • GRATIS        │
                   └──────────────────┘
```

### Técnicas de Optimización

| Técnica | Ahorro | Implementación |
|---|---|---|
| **Pool de misiones predefinidas** | 40% | 50 diarias + 20 semanales en base de datos. Rotan sin IA |
| **Batch nocturno de Pergaminos** | 15% | IA genera contenido para el día siguiente mientras el servidor está ocioso |
| **Cache de respuestas frecuentes** | 10% | Correcciones comunes, saludos, frases hechas |
| **Prompt compression** | 20% | Enviar resumen + últimos mensajes en vez de historial completo |
| **Contexto adaptativo por nivel** | 10% | A1: solo mensaje actual. B1+: últimos 5. C1+: historial completo |
| **Fine-tuning de modelo pequeño** | 50% | Modelo especializado en corrección gramatical (tarea específica) |
| **Audio compression** | 20% | Reducir bitrate Groq de 128 a 64 kbps |

**Ahorro total estimado: 50-60% del costo actual de IA**

### Límites Inteligentes por Usuario

| Perfil | Invocaciones IA/día | Pergaminos/día | Costo IA/mes |
|---|---|---|---|
| Free nuevo (semana 1) | 30 (bonus onboarding) | 10 | $0.39 |
| Free normal | 20 | 5 | $0.26 |
| Free inactivo (<3 días) | 25 (bonus retorno) | 8 | $0.33 |
| Premium mensual | Ilimitado | Ilimitado | $0.50-0.70 |
| Premium anual | Ilimitado | Ilimitado | $0.70 (promedio) |

---

## PARTE 8 — Retención: El Motor de Engagement

### Sistemas de Retorno Diario

| Sistema | Descripción | Impacto estimado |
|---|---|---|
| **🔥 Rachas** | Bonus incremental: día 1 = 5💎, día 7 = 50💎, día 30 = 300💎 | +60% D30 |
| **🎁 Cofre Diario** | Al iniciar sesión: oro, pergaminos, chance de gema | +40% DAU |
| **📅 Calendario Mensual** | 30 días de recompensas. Día 15 = cosmético raro | +35% retención |
| **⚡ Emergencias** | Misiones de 1h que aparecen aleatoriamente | +25% sesiones/día |
| **🏆 Battle Pass** | 20 niveles por temporada de 8 semanas | +50% retención semanal |
| **👥 Misiones Colaborativas** | Meta del gremio: "100 min hoy" | +30% permanencia en guild |
| **🔮 Misiones Secretas** | Aparecen cuando menos lo esperas | +20% sorpresa/engagement |
| **🌍 Invasiones** | Evento global semanal contra IA | +40% participación |

### El Círculo Virtuoso de Retención

```
USUARIO ABRE LA APP
        │
        ▼
🎁 COFRE DIARIO → dopamina inmediata
        │
        ▼
📅 CALENDARIO → "Estoy en el día 7, no quiero perderlo"
        │
        ▼
🏆 TABLÓN DE MISIONES → "Hay 3 cosas que puedo hacer"
        │
        ▼
⚡ EMERGENCIA → "¡Solo por 1 hora! Tengo que hacerla"
        │
        ▼
🗣️ UNA CONVERSACIÓN → práctica real
        │
        ▼
🔥 RACHA +1 → "Mañana llego al día 8"
        │
        ▼
🎯 MAÑANA VUELVE → retención asegurada
```

---

## PARTE 9 — Nuevas Oportunidades de Monetización

### Resumen de Fuentes de Ingreso

| Fuente | % del revenue esperado | Tipo |
|---|---|---|
| Suscripción Mensual $1.99 | 40% | Recurrente |
| Suscripción Anual $14.99 | 25% | Recurrente |
| Compra de Gemas (IAP) | 15% | Variable |
| Battle Pass ($4.99/temporada) | 10% | Variable (2 meses) |
| Cosméticos directos | 5% | Variable |
| Pergaminos de Sabiduría | 3% | Variable |
| Lifetime $29.99 | 2% | Único |

### Nuevas Mecánicas Propuestas

| Mecánica | Descripción | Monetización |
|---|---|---|
| **Cofre Misterioso Diario** | 1 gratis. Más cofres con gemas | 💎 (gambling leve) |
| **Ruleta del Gremio** | Gira por 100💎, gana objetos aleatorios | 💎 |
| **Subastas** | Puja por objetos raros con oro | 💎 (entrada) |
| **Forja de Objetos** | Combina 3 items → 1 nuevo aleatorio | 💎 (materiales) |
| **Misiones Premium** | Misiones especiales con recompensas exclusivas | 💎 (acceso) |
| **Invocaciones Extra** | 5 invocaciones IA por 50💎 | 💎 |
| **Pergamino Ilimitado** | Pase mensual de contenido offline | $4.99/mes |

---

## PARTE 10 — Impacto Técnico

### Nuevas Tablas de Base de Datos

```sql
-- ============================================================
-- TABLAS NUEVAS
-- ============================================================

-- Objetos cosméticos del jugador
CREATE TABLE player_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_code VARCHAR(100) NOT NULL,
    item_type VARCHAR(50) NOT NULL CHECK (item_type IN (
        'title','skin','frame','aura','pet','emote','theme',
        'table_theme','guild_decoration','relic','consumable'
    )),
    is_equipped BOOLEAN DEFAULT false,
    acquired_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, item_code)
);

-- Catálogo de cosméticos
CREATE TABLE cosmetic_catalog (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    price_gems INTEGER NOT NULL DEFAULT 0,
    rarity VARCHAR(20) DEFAULT 'common' CHECK (rarity IN ('common','rare','epic','legendary','limited')),
    is_limited BOOLEAN DEFAULT false,
    season VARCHAR(50),
    image_url TEXT,
    available_from TIMESTAMPTZ DEFAULT NOW(),
    available_to TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Misiones del gremio (pool predefinido)
CREATE TABLE guild_quest_pool (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_type VARCHAR(20) NOT NULL CHECK (quest_type IN ('daily','weekly','collaborative')),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_type VARCHAR(50), -- 'speak_minutes','vocab_words','sessions','xp_earned'
    target_value INTEGER NOT NULL,
    xp_reward INTEGER DEFAULT 50,
    gem_reward INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Progreso diario del jugador (para rachas y límites)
CREATE TABLE player_daily_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    invocations_used INTEGER DEFAULT 0,
    pergaminos_used INTEGER DEFAULT 0,
    guild_quests_completed INTEGER DEFAULT 0,
    daily_reward_claimed BOOLEAN DEFAULT false,
    UNIQUE(user_id, date)
);

-- Rachas
CREATE TABLE player_streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_active_date DATE,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Misiones completadas por el jugador
CREATE TABLE player_completed_quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quest_id VARCHAR(200) NOT NULL,
    quest_type VARCHAR(20) NOT NULL,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, quest_id)
);

-- Battle Pass del gremio
CREATE TABLE guild_battle_pass (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    season VARCHAR(50) NOT NULL,
    level INTEGER DEFAULT 1,
    xp_progress INTEGER DEFAULT 0,
    is_premium BOOLEAN DEFAULT false,
    claimed_rewards TEXT[] DEFAULT '{}',
    UNIQUE(user_id, season)
);
```

### Pantallas Afectadas

| Pantalla | Cambio |
|---|---|
| `chat_rooms_screen.dart` | Agregar tablón del gremio, misiones diarias, emergencias |
| `voice_room_screen.dart` | Sistema de turnos, espectadores, moderación |
| `conversation_screen.dart` | Integrar Pergaminos de Sabiduría, modo sin IA |
| `dashboard_screen.dart` | Mapa de misiones, calendario, cofre diario |
| `hunter_status_screen.dart` | Mostrar reliquias, inventario cosmético |
| **NUEVA** `guild_quest_board.dart` | Tablón de misiones del gremio |
| **NUEVA** `shop_screen.dart` | Tienda de cosméticos |
| **NUEVA** `inventory_screen.dart` | Inventario del jugador |
| **NUEVA** `battle_pass_screen.dart` | Battle Pass del gremio |
| **NUEVA** `daily_reward_screen.dart` | Cofre diario + calendario |

### Nuevos Servicios Backend

| Servicio | Propósito | Costo |
|---|---|---|
| `batch_quest_generator` | Genera misiones diarias por la noche | Bajo (batch) |
| `pergamino_generator` | Genera contenido offline personalizado | Bajo (batch) |
| `streak_manager` | Gestiona rachas y recompensas | Muy bajo |
| `guild_quest_rotator` | Rota el pool de misiones del gremio | Muy bajo |
| `ai_cost_tracker` | Monitorea uso de IA por usuario | Muy bajo |
| `emergency_event_trigger` | Genera eventos emergentes con IA | Medio (1-2/día) |

---

## PARTE 11 — Proyecciones Financieras Finales

### Escenario Realista (Recomendado)

| Métrica | Año 1 | Año 2 | Año 3 |
|---|---|---|---|
| Usuarios totales | 100,000 | 500,000 | 1,500,000 |
| MAU | 30,000 | 150,000 | 450,000 |
| Conversión Premium | 8% | 10% | 12% |
| Premium (Ilimitado IA) | 2,400 | 15,000 | 54,000 |
| ARPU (todos los usuarios) | $0.55 | $0.70 | $0.85 |
| Revenue mensual | $16,500 | $105,000 | $382,500 |
| **Revenue anual** | **$198,000** | **$1,260,000** | **$4,590,000** |
| Costo IA/mes (con optimización) | $2,400 | $10,000 | $28,000 |
| Costo infra/mes | $2,500 | $8,000 | $18,000 |
| CAC promedio/mes | $15,000 | $50,000 | $100,000 |
| **Margen operativo** | **-$3,400/mes** | **+$37,000/mes** | **+$236,500/mes** |
| **LTV** | $19.80 | $25.20 | $30.60 |
| **Ratio LTV:CAC** | 3.3:1 | 5:1 | 6.1:1 |
| **Punto de equilibrio** | **Mes 16** | | |

### Notas sobre las Proyecciones

1. **El margen es positivo desde el mes 16** porque el CAC se reduce con el crecimiento orgánico
2. **La optimización de IA reduce el costo en 50%** vs el modelo sin optimizar
3. **El ARPU incluye compras de gemas y battle passes**, no solo suscripciones
4. **El LTV supera ampliamente el CAC** en todos los escenarios
5. **Los Pergaminos de Sabiduría** reducen el costo de IA en un 30% adicional

---

## PARTE 12 — Roadmap de Implementación

### Fase 1: Fundación (Semanas 1-4)

| # | Iniciativa | Esfuerzo | Impacto |
|---|---|---|---|
| 1 | Sistema de economía: Cristales, Reliquias, Pergaminos, Energía | 2 semanas | 🔴 Crítico |
| 2 | Tablas DB: inventario, catálogo, daily_state, streaks, guild_quest_pool | 1 semana | 🔴 Crítico |
| 3 | IA como recurso narrativo (reemplazar mensajes de error/rate-limit) | 1 semana | 🔴 Crítico |
| 4 | Sistema de invocaciones (créditos de IA con skin narrativa) | 1 semana | 🔴 Crítico |
| 5 | Cofre diario + calendario mensual | 1 semana | 🟠 Alto |

### Fase 2: Misiones y Gremio (Semanas 5-8)

| # | Iniciativa | Esfuerzo | Impacto |
|---|---|---|---|
| 6 | Pool de misiones del gremio (diarias, semanales, colaborativas) | 2 semanas | 🔴 Crítico |
| 7 | Tablón del gremio (pantalla) | 1 semana | 🔴 Crítico |
| 8 | Sistema de emergencias (eventos IA temporales) | 1 semana | 🟠 Alto |
| 9 | Misiones secretas generadas por IA | 2 semanas | 🟠 Alto |
| 10 | Battle Pass del gremio | 2 semanas | 🔴 Crítico (revenue) |

### Fase 3: Monetización (Semanas 9-12)

| # | Iniciativa | Esfuerzo | Impacto |
|---|---|---|---|
| 11 | Tienda de cosméticos (catálogo + compra con gemas) | 2 semanas | 🔴 Crítico |
| 12 | Inventario del jugador (equipar/desequipar cosméticos) | 1 semana | 🟠 Alto |
| 13 | Pergaminos de Sabiduría (batch nocturno + consumo) | 2 semanas | 🔴 Crítico (costo IA) |
| 14 | Sistema de moderación IA en mesas (híbrido) | 1 semana | 🟠 Alto |
| 15 | Coach de pronunciación + mentor personal (IA Premium) | 2 semanas | 🟠 Alto |

### Fase 4: Expansión (Mes 4+)

| # | Iniciativa | Esfuerzo | Impacto |
|---|---|---|---|
| 16 | Batle pass con ruta gratuita + premium | 2 semanas | 🔴 Crítico |
| 17 | Torneos semanales del gremio | 2 semanas | 🟠 Alto |
| 18 | Subastas entre jugadores | 2 semanas | 🟡 Medio |
| 19 | Gremios de jugadores (user-created) | 3 semanas | 🔥 Muy alto |
| 20 | Mazmorras cooperativas (2-4 jugadores vs IA) | 4 semanas | 🔥 Muy alto |

---

## Conclusión Final

### Los 3 Pilares de la Estrategia

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║  1. LA IA ES UN RECURSO DEL JUEGO                             ║
║     • El límite técnico se convierte en narrativa RPG         ║
║     • El usuario nunca ve "tokens", ve "Cristales de Maná"    ║
║     • La optimización reduce el costo de IA en 50-60%         ║
║                                                               ║
║  2. EL APRENDIZAJE ES GRATIS, LA AVENTURA SE PAGA             ║
║     • Toda la historia principal es accesible sin pagar        ║
║     • El plan gratuito es generoso (20 invocaciones/día)      ║
║     • La monetización es cosmética, social y de conveniencia  ║
║                                                               ║
║  3. EL GREMIO ES EL MOTOR DE RETENCIÓN                        ║
║     • Misiones infinitas sin IA (contenido predefinido)       ║
║     • Battle Pass, cofres, eventos, torneos                   ║
║     • La interacción social genera barreras de salida         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### La Regla que lo Gobierna Todo

> *"Cada compra debe hacer que el jugador disfrute más de su aventura, nunca que aprenda más que otro jugador."*

Esta regla garantiza:
- **Equidad educativa:** Todos pueden aprender sin pagar
- **Sostenibilidad:** Los costos de IA están controlados
- **Rentabilidad:** El ARPU supera el costo por usuario
- **Reputación:** La app nunca será percibida como "pay-to-win"
- **Escalabilidad:** Cada nuevo usuario puede ser rentable

### Veredicto Final

Dungeon of English es **económicamente viable, éticamente sólido y técnicamente factible**.

El modelo de "IA como recurso narrativo", combinado con contenido pre-generado (Pergaminos de Sabiduría) y un ecosistema social rico (Gremio), permite:

- **Reducir el costo de IA en un 50%**
- **Ofrecer un plan gratuito generoso y sostenible**
- **Mantener márgenes saludables (>50%)**
- **Alcanzar el punto de equilibrio en 16 meses**
- **Construir una comunidad que retenga usuarios a largo plazo**

El mayor riesgo no es la economía — **es la ejecución**. La estrategia es sólida. Ahora depende de la implementación.
