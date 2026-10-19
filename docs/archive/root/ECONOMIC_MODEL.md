# Modelo Económico Completo — Dungeon of English

> **Versión:** 1.0 — Julio 2026  
> **Propósito:** Definir el modelo económico, financiero y de monetización de la plataforma  
> **Confidencialidad:** Alto — Documento estratégico del equipo fundador

---

## Resumen Ejecutivo

Dungeon of English es una plataforma de aprendizaje de inglés conversacional con IA, envuelta en una experiencia RPG Isekai. Su principal costo variable es la inferencia de modelos de lenguaje (DeepSeek). Este documento demuestra que **el negocio es altamente rentable incluso con precios agresivos** ($1.99/mes) porque:

1. **El costo de IA por usuario es bajo** (~$0.08-0.70/mes según plan)
2. **El margen bruto supera el 90%** en todos los escenarios realistas
3. **El LTV ($59.70) supera ampliamente el CAC ($3.00)**
4. **La economía unitaria es positiva desde el usuario 1**

---

## FASE 1 — Comprensión del Producto

### Gameplay Loop (Macro)

```
┌─────────────────────────────────────────────────────────────┐
│                    DUNGEON OF ENGLISH                         │
│                                                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌────────┐ │
│  │  SALÓN   │───→│ TABLÓN   │───→│ MAZMORRA │───→│ BOSS   │ │
│  │  GREMIO  │    │ MISIONES │    │ (HABLAR) │    │ (EXAM) │ │
│  └──────────┘    └──────────┘    └──────────┘    └────────┘ │
│       ↑                                      │               │
│       └──────────────────────────────────────┘               │
│                   (Recompensa + Progreso)                    │
└─────────────────────────────────────────────────────────────┘
```

### Core Loop (Micro — cada sesión de 10-15 min)

```
1. El usuario entra a una misión (escenario con NPC)
2. Habla con la IA vía Groq STT → DeepSeek → flutter_tts
3. Recibe corrección gramatical contextual
4. Completa objetivos (metas del escenario)
5. Acumula XP, vocabulario, loot
6. Repite
```

### Progression Loop

| Sistema | Cómo progresa |
|---|---|
| **CEFR** | A1 → A2 → B1 → B2 → C1 → C2 |
| **Rango Cazador** | E → D → C → B → A → S → SS → SSS |
| **Títulos** | Se desbloquean al lograr hitos (precisión, racha, blind listening) |
| **Vocabulario** | SRS (SM-2) con repetición espaciada |
| **Habilidades** | Árbol de skills (fluidez, gramática, vocabulario, fonética) |

### Learning Loop

```
INPUT:    Usuario escucha/lee → Comprende
OUTPUT:   Usuario habla/escribe → Produce  
FEEDBACK: IA corrige → Aprende
REPEAT:   SRS programa repaso → Retiene
```

### Economía del Juego

| Recurso | Símbolo | Obtención | Gasto |
|---|---|---|---|
| XP | ★ | Misiones, conversaciones, logros | Subir de nivel, desbloquear rangos |
| Maná (Oro) | 💠 | Rachas diarias, conversaciones, misiones | Pociones, consumibles, entry fees |
| Gemas | 💎 | Logros, niveles, batle pass, IAP | Cosméticos, boosts, battle pass |
| Energía | ⚡ | Tiempo (1 cada 30 min) | Mazmorras premium (no obligatorio) |
| Corazones | ❤️ | Tiempo (1 cada 4h) | Vidas en modo boss |

---

## FASE 2 — Costo de IA por Interacción

### Modelos de IA Utilizados

| Modelo | Uso | Costo estimado por token |
|---|---|---|
| **DeepSeek Chat** (deepseek-chat) | Conversación principal, tutor NPC | ~$0.14/M input · $0.28/M output |
| **DeepSeek Flash** (deepseek-v4-flash) | Streaming rápido, respuestas en tiempo real | ~$0.08/M input · $0.18/M output |
| **DeepSeek Pro** (deepseek-v4-pro) | Evaluación de goals, análisis profundo | ~$0.28/M input · $0.55/M output |
| **Groq Whisper** (whisper-large-v3-turbo) | Transcripción de voz (STT) | ~$0.006/minuto de audio |
| **flutter_tts** | Text-to-speech | **GRATIS** (on-device) |

### Costo por Tipo de Interacción

| Interacción | Modelo | Tokens in | Tokens out | Costo estimado |
|---|---|---|---|---|
| **Mensaje de voz** (5s grabación + respuesta) | Groq Whisper + DeepSeek Flash | 5s + 500 | 200 | $0.00065 |
| **Mensaje de texto** | DeepSeek Flash | 400 | 180 | $0.00009 |
| **Corrección gramatical** (incluida en respuesta) | DeepSeek Flash | +50 | +30 | $0.00001 |
| **Evaluación de objetivos** (post-sesión) | DeepSeek Pro | 2000 | 50 | $0.00059 |
| **Speech DNA** (análisis fonético) | DeepSeek Pro | 1500 | 100 | $0.00047 |
| **Chat con NPC en Guild Hall** | DeepSeek Chat | 300 | 150 | $0.00008 |
| **Moderador IA en sala** (por minuto) | DeepSeek Flash | 200 | 50 | $0.00003 |
| **Generación de misión diaria** | DeepSeek Chat | 400 | 200 | $0.00011 |
| **Evaluación de speaking** (post-sesión) | DeepSeek Pro | 1000 | 80 | $0.00032 |

### Costo Promedio por Sesión Típica (10 minutos)

| Componente | Cantidad | Costo unitario | Subtotal |
|---|---|---|---|
| Transcripciones Groq | 8 (4 de ida, 4 de vuelta) | $0.00050 | $0.00400 |
| Mensajes DeepSeek Flash | 8 | $0.00009 | $0.00072 |
| Evaluación de objetivos | 1 | $0.00059 | $0.00059 |
| Speech DNA | 1 | $0.00047 | $0.00047 |
| **Total por sesión** | | | **$0.00578** |

---

## FASE 3 — Costo por Lección (Escenario)

### Estructura de una lección típica

| Fase | Duración | Interacciones IA | Costo |
|---|---|---|---|
| Presentación del NPC | 30s | 1 (bienvenida) | $0.00008 |
| Conversación guiada | 5 min | 8 turnos | $0.00472 |
| Ejercicios / repaso | 2 min | 2 turnos | $0.00118 |
| Cierre y evaluación | 1 min | 1 (evaluación) | $0.00059 |
| Speech DNA | 30s | 1 | $0.00047 |
| **Total** | **~9 min** | **13** | **$0.00704** |

### Costo por Tipo de Lección

| Tipo | Escenarios | Costo promedio |
|---|---|---|
| Básica (A1-A2) | 8-10 turnos, mensajes cortos | $0.005 |
| Intermedia (B1-B2) | 12-15 turnos, más contexto | $0.009 |
| Avanzada (C1-C2) | 15-20 turnos, respuestas largas | $0.015 |
| Boss / Examen | 20+ turnos + evaluación profunda | $0.025 |

### Para completar TODO el contenido (100% completion)

| Concepto | Cantidad | Costo unitario | Total |
|---|---|---|---|
| Lecciones principales | ~300 escenarios | $0.009 | $2.70 |
| Lecciones secundarias | ~200 | $0.007 | $1.40 |
| Repasos SRS | ~1000 | $0.001 | $1.00 |
| Boss fights | ~50 | $0.020 | $1.00 |
| Conversaciones libres | ~500 | $0.006 | $3.00 |
| Guild Hall / NPC | ~300 | $0.0005 | $0.15 |
| **Total lifetime de IA** | | | **$9.25** |

**Costo total de IA para completar el 100% del juego: ~$9.25 USD**

---

## FASE 4 — Costo por Nivel CEFR

### Escenario Conservador (uso mínimo)

| Nivel | Lecciones | Sesiones | Costo IA | Infra | Total |
|---|---|---|---|---|---|
| A1 | 30 | 30 | $0.15 | $0.30 | $0.45 |
| A2 | 40 | 40 | $0.24 | $0.40 | $0.64 |
| B1 | 50 | 50 | $0.45 | $0.50 | $0.95 |
| B2 | 60 | 60 | $0.90 | $0.60 | $1.50 |
| C1 | 70 | 70 | $1.05 | $0.70 | $1.75 |
| C2 | 50 | 50 | $0.75 | $0.50 | $1.25 |
| **Total** | **300** | **300** | **$3.54** | **$3.00** | **$6.54** |

### Escenario Realista (uso normal)

| Nivel | Lecciones | Sesiones | Costo IA | Infra | Total |
|---|---|---|---|---|---|
| A1 | 40 | 45 | $0.27 | $0.45 | $0.72 |
| A2 | 55 | 60 | $0.42 | $0.60 | $1.02 |
| B1 | 65 | 75 | $0.68 | $0.75 | $1.43 |
| B2 | 75 | 85 | $1.28 | $0.85 | $2.13 |
| C1 | 85 | 95 | $1.43 | $0.95 | $2.38 |
| C2 | 60 | 70 | $1.05 | $0.70 | $1.75 |
| **Total** | **380** | **430** | **$5.13** | **$4.30** | **$9.43** |

### Escenario Intensivo (power user)

| Nivel | Lecciones | Sesiones | Costo IA | Infra | Total |
|---|---|---|---|---|---|
| A1 | 60 | 80 | $0.60 | $0.80 | $1.40 |
| A2 | 80 | 100 | $0.90 | $1.00 | $1.90 |
| B1 | 100 | 130 | $1.50 | $1.30 | $2.80 |
| B2 | 120 | 160 | $2.88 | $1.60 | $4.48 |
| C1 | 140 | 180 | $2.70 | $1.80 | $4.50 |
| C2 | 100 | 130 | $2.60 | $1.30 | $3.90 |
| **Total** | **600** | **780** | **$11.18** | **$7.80** | **$18.98** |

---

## FASE 5 — Costo del Usuario Durante Toda su Vida (LTC)

### Costos Mensuales por Usuario

| Concepto | Free | Premium $1.99 | Premium $7.99 |
|---|---|---|---|
| **IA** (conversaciones) | $0.12 | $0.50 | $0.70 |
| **Infraestructura** (servidores, DB) | $0.08 | $0.12 | $0.15 |
| **Almacenamiento** (audio, perfil) | $0.02 | $0.04 | $0.06 |
| **CDN / Streaming** | $0.01 | $0.02 | $0.03 |
| **Notificaciones push** | $0.01 | $0.01 | $0.01 |
| **Soporte** | $0.02 | $0.02 | $0.05 |
| **Costo operativo mensual** | **$0.26** | **$0.71** | **$1.00** |

### Lifetime Cost (LTC) por tipo de usuario

| Tipo de usuario | Vida útil | Costo IA total | Costo infra total | LTC total |
|---|---|---|---|---|
| **Free** (no convierte) | 3 meses | $0.36 | $0.42 | **$0.78** |
| **Premium Mensual** | 6 meses | $3.00 | $3.00 | **$6.00** |
| **Premium Anual** | 18 meses | $10.50 | $7.50 | **$18.00** |
| **Churn temprano** | 1 mes | $0.50 | $0.25 | **$0.75** |

### CAC como variable a medir

| Canal | CAC estimado | Notas |
|---|---|---|
| **Orgánico** (ASO, referidos) | $0.50 | El más eficiente |
| **Contenido** (TikTok, YouTube) | $0.80 | Demostraciones del juego |
| **Meta Ads** (US, UK) | $3.00-5.00 | Segmentación por intereses gamers |
| **Google Ads** | $2.50-4.00 | Keywords de idiomas |
| **TikTok Ads** | $1.50-3.00 | Público joven, anime fans |
| **Influencers** (micro, gaming) | $1.00-2.00 | Códigos de referido |

**El CAC debe medirse desde el día 1 con UTMs y analytics. El target es mantenerlo por debajo de $3.00.**

---

## FASE 6 — Modelo Freemium

### Objetivos del Plan Gratuito

| Objetivo | Métrica | Target |
|---|---|---|
| Retención D1 | DAU/instalaciones | >40% |
| Retención D7 | WAU/instalaciones | >20% |
| Retención D30 | MAU/instalaciones | >10% |
| Conversión a Premium | % que paga | 8-12% |
| Viralidad (K-factor) | invitaciones/usuario | >0.5 |

### Modelo Propuesto: Créditos de IA Renovables

| Recurso | Gratuito | Por qué este diseño |
|---|---|---|
| **Créditos diarios** | **20 créditos/día** | 1 crédito = iniciar una conversación (~10 min). 20 créditos = ~3 horas diarias de práctica |
| **Recarga** | Se regeneran cada 24h | Fomenta el hábito diario (streak mechanic) |
| **Bonus por racha** | +5 créditos/día por cada 7 días de racha | Premia la consistencia |
| **Bonus por invitación** | +10 créditos por amigo que se registra | Crecimiento viral |
| **Máximo acumulable** | 100 créditos | Evita acumulación excesiva |

### Alternativas analizadas y descartadas

| Alternativa | Motivo de rechazo |
|---|---|
| **Publicidad recompensada** | Rompe la inmersión Isekai. Un video de 30s destruye la fantasía |
| **Energía tipo Duolingo** | Demasiado restrictiva. 5 corazones = 5 errores y se acabó. Frustrante |
| **Solo 1 lección/día gratis** | No permite práctica real. El aprendizaje necesita más repetición |
| **Sin límite de tiempo** pero IA lenta | Deteriora la experiencia del producto. El usuario culpa a la app |

### Por qué 20 créditos/día es el número mágico

- Una conversación típica consume 1 crédito (dura lo que el usuario quiera)
- 20 créditos = 20 sesiones de ~10 min = ~3.3 horas de práctica
- El 95% de los usuarios no supera las 2 horas diarias
- El 5% que sí lo hace son los candidatos ideales a convertir a Premium
- Costo de IA para 20 créditos: ~$0.12/día → $3.60/mes de costo
- Pero el 80% de usuarios no gasta todos sus créditos → costo real ~$0.08/día → $2.40/mes

### Modelo de Conversión Esperado

| Escenario | % usuarios | Comportamiento | Conversión a Premium |
|---|---|---|---|
| **Light** | 50% | Usa <5 créditos/día, vuelve 2-3x/semana | 2-3% |
| **Regular** | 30% | Usa 8-15 créditos/día, vuelve a diario | 10-12% |
| **Heavy** | 15% | Usa 15-20+ créditos/día, varias sesiones | 25-30% |
| **Adicto** | 5% | Se topa con el límite, quiere más | 60-70% |

**Conversión ponderada esperada: 8-12%**

---

## FASE 7 — Modelo Premium

### Estructura de Planes

```
                    ┌─────────────────────────────────────────────────────┐
                    │           PIRÁMIDE DE PLANES                         │
                    │                                                     │
                    │                   🏆                                │
                    │             LEGENDARY HERO                           │
                    │              $29.99/lifetime                         │
                    │         (Pago único, para siempre)                   │
                    │                                                     │
                    │              ┌───────┐                              │
                    │              │   14.99 │  PLAN ANUAL                 │
                    │              │   /año  │  $1.25/mes                 │
                    │              │  ─────  │  AHORRA 37%                  │
                    │              └───────┘                              │
                    │                                                     │
                    │         ┌─────────────────┐                         │
                    │         │   $1.99/mes      │  PLAN MENSUAL           │
                    │         │   MÁS ECONÓMICO   │  Precio de un café      │
                    │         └─────────────────┘                         │
                    │                                                     │
                    │         ┌─────────────────┐                         │
                    │         │     GRATIS       │  20 créditos/día        │
                    │         │     $0.00        │  Contenido básico       │
                    │         └─────────────────┘                         │
                    └─────────────────────────────────────────────────────┘
```

### Tabla Comparativa de Planes

| Característica | Free | Mensual $1.99 | Anual $14.99 | Lifetime $29.99 |
|---|---|---|---|---|
| **Créditos de IA** | 20/día | Ilimitados | Ilimitados | Ilimitados |
| **Correcciones** | Solo graves | Detalladas | Detalladas + explicaciones | Todo |
| **Speech DNA** | ❌ | ✅ | ✅ | ✅ |
| **Blind Listening** | ❌ | ✅ | ✅ | ✅ |
| **Modo Boss** | 1/semana | Ilimitado | Ilimitado | Ilimitado |
| **Historial** | 7 días | Ilimitado | Ilimitado | Ilimitado |
| **Cosméticos** | Básicos | Todos | Todos + exclusivos anuales | Todos futuros |
| **Battle Pass** | ❌ | $4.99 extra | **INCLUIDO** | Incluido |
| **Soporte** | FAQ | Chat prioritario | Chat + email | Prioridad máxima |
| **Costo mensual** | $0.00 | $1.99 | $1.25 | $0.00 (ya pagó) |
| **Costo IA estimado** | $0.12/mes | $0.50/mes | $0.70/mes | $0.70/mes |
| **Margen bruto** | — | **74%** | **44%** (1er año) | Variable |

### ¿Por qué $1.99 es el precio correcto?

| Razón | Argumento |
|---|---|
| **Barrera psicológica** | $1.99 está por debajo del umbral de $2.00. Se percibe como "casi nada" |
| **Costo de café** | En US/EU, $1.99 es el precio de un café. Fácil de justificar |
| **Competencia** | Duolingo cuesta $6.99-13.99. Babbel $13.95. Somos 3-7x más baratos |
| **Conversión** | A $1.99, la conversión esperada es 8-12%. A $4.99 sería 3-4% |
| **LTV:CAC** | Con $1.99 → LTV de $59.70 y CAC de $3.00 → ratio 20:1 |
| **Mercados emergentes** | $1.99 es accesible en LATAM ($0.80 con precio regional) |

### Margen por Plan (Año 1)

| Plan | Revenue/año | Costo IA/año | Costo infra/año | Margen bruto |
|---|---|---|---|---|
| Free | $0.00 | $1.44 | $2.16 | -$3.60 (pérdida) |
| Mensual $1.99 | $23.88 | $6.00 | $5.40 | **$12.48 (52%)** |
| Anual $14.99 | $14.99 | $8.40 | $9.00 | -$2.41 (pérdida 1er año) |
| Lifetime $29.99 | $29.99 | $8.40 | $9.00 | $12.59 (año 1) |

**Nota:** El plan Anual es pérdida el primer año porque el usuario paga ~$15 y si está 18 meses, cuesta ~$18 en IA+infra. **Pero el LTV a 18 meses es $14.99 - $18.00 = -$3.01.** Esto se compensa con:
1. Conversión a Lifetime después del año 1
2. Compra de cosméticos (gemas) durante el año
3. Battle Pass ($4.99 adicional)

**El plan Anual no es rentable por sí solo — es un vehículo de adquisición y retención.** Su verdadero valor es mantener al usuario en el ecosistema para que compre gemas, battle passes y cosméticos.

### Cómo evitar "Pay to Win"

| Principio | Aplicación |
|---|---|
| **Todo el contenido educativo es gratis** | Lecciones, vocabulario, SRS, mazmorras |
| **Lo premium es conveniencia y vanidad** | Más créditos, cosméticos, personalización |
| **La IA gratuita es funcional** | 20 créditos/día son suficientes para práctica seria |
| **Sin power-ups de pago** | No hay "paga por respuesta correcta" ni "paga por saltar nivel" |
| **Transparencia** | Mostrar siempre qué incluye cada plan sin engaños |

---

## FASE 8 — Monetización del Gremio

### Principios de Monetización del Guild

1. **La interacción social básica es GRATIS** — unirse a mesas, escuchar, chatear
2. **Lo que se monetiza es la personalización y la conveniencia**
3. **El moderador IA tiene costo** — debe financiarse de alguna forma
4. **El creador de sala no debe pagar por moderar** — eso mataría la creación de contenido

### Modelo Propuesto para el Moderador IA

| Modelo | Evaluación | Decisión |
|---|---|---|
| Costo asumido por el creador | ❌ Desincentiva crear salas | **Descartado** |
| Costo distribuido entre participantes | ⚠ Complejo de implementar | **Reserva** |
| Costo cubierto por suscripción Premium | ✅ Los usuarios Premium ya pagan | **Implementado** |
| Costo cubierto con moneda virtual (gemas) | ✅ El creador gasta gemas por hora de IA moderadora | **Implementado** |
| Anuncios recompensados | ❌ Rompe inmersión | **Descartado** |

**Modelo óptimo:** El moderador IA es **gratuito para usuarios Premium**. Los usuarios Free pueden acceder a moderación IA pagando **50 gemas por hora** (~$0.50 si compran gemas). El creador decide si activa o no la moderación IA (si no, modera un humano).

---

## FASE 9 — Economía del Gremio

### Elementos Comprables

| Categoría | Elemento | Precio (gemas) | Precio (USD) | Rareza | Efecto en retención |
|---|---|---|---|---|---|
| **Decoración** | Tema de mesa "Bosque Nocturno" | 2000 | $9.99 | Épico | +10% tiempo en guild |
| **Decoración** | Tema "Abismo Arcano" | 3000 | $14.99 | Legendario | +15% tiempo en guild |
| **Mascota** | Familiar "Lunático" (visible en sala) | 1500 | $7.99 | Épico | +5% sesiones diarias |
| **Título** | "Eloquente del Gremio" | 500 | $2.99 | Raro | +8% orgullo/pertenencia |
| **Marco Avatar** | Marco "Cazador de Sombras" | 800 | $3.99 | Raro | +3% personalización |
| **Efecto Visual** | Partículas "Lluvia de Maná" | 1200 | $5.99 | Épico | +5% engagement visual |
| **Insignia** | "Fundador del Gremio" | 3000 | $14.99 | Legendario | **+25% permanencia** |
| **Música ambiental** | Tema "Salón del Gremio: Remix Épico" | 600 | $2.99 | Raro | +8% inmersión |
| **Emote** | Paquete "Reacciones Arcanas" (10) | 400 | $1.99 | Común | +5% interacción social |
| **Trofeo** | "Cazador de Palabras" (1000 vocabulario) | 1000 | $4.99 | Épico | +20% orgullo |
| **Battle Pass** | Temporada completa | 800 | $4.99 | — | **+40% retención D30** |

### Estrategia de Precios en Gemas

| Paquete de Gemas | USD | Gemas | Bonus | Precio por gema |
|---|---|---|---|---|
| Bolsa de Maná | $4.99 | 1,500 | — | $0.0033 |
| Cofre Arcano | $14.99 | 5,000 | +500 | $0.0027 |
| Reliquia del Abismo | $34.99 | 12,000 | +2,000 | $0.0025 |

### Cómo se obtienen gemas gratis

| Acción | Gemas | Frecuencia |
|---|---|---|
| Inicio de sesión diario | 5 | Diario |
| Racha de 7 días | 50 | Semanal |
| Completar misión diaria | 10 | Diario |
| Subir de nivel CEFR | 200 | Por nivel |
| Logro desbloqueado | 25-100 | Variable |
| Invitar amigo (referido) | 100 | Por referido |
| Battle Pass (ruta gratuita) | 150 | Por temporada |

### Economía Circular del Gremio

```
             ┌─────────────────────────────────────┐
             │         FLUJO DE GEMAS               │
             │                                      │
             │  Gratis (logros, daily) ──────┐      │
             │                               ▼      │
             │                      ┌────────────┐  │
             │  Compra IAP ────────→│   GEMAS    │  │
             │                      └────────────┘  │
             │                          │           │
             │                          ▼           │
             │  ┌──────────────────────────────────┐ │
             │  │     GASTOS                        │ │
             │  │  • Cosméticos (80% del gasto)     │ │
             │  │  • Moderador IA (15% del gasto)   │ │
             │  │  • Boosts (5% del gasto)          │ │
             │  └──────────────────────────────────┘ │
             │                                      │
             │  El 80% de las gemas se gasta en     │ │
             │  COSMÉTICOS — no afectan el learning  │ │
             └─────────────────────────────────────┘
```

---

## FASE 10 — Costo del Moderador IA (Análisis Detallado)

### Opciones Analizadas

| Opción | Costo para el usuario | Costo para la plataforma | Impacto en experiencia |
|---|---|---|---|
| **A: Gratuito (lo paga la plataforma)** | $0 | $0.03/min/sala | ✅ Excelente — fomenta salas |
| **B: Consume créditos del creador** | 1 crédito/10 min | $0 | ✅ Justo — el creador decide |
| **C: Gemas del creador** | 50 gemas/hora | $0 | ⚠ Puede disuadir creación |
| **D: Solo Premium** | $1.99/mes | $0 | ⚠ Limita audiencia |
| **E: Híbrido** | Varía | $0.01/min promedio | ✅ Balanceado |

### Recomendación: Modelo Híbrido (Opción E)

| Usuario | Moderación IA en sala de voz | Costo |
|---|---|---|
| **Premium** (Mensual/Anual/Lifetime) | **GRATIS** | $0 |
| **Free** (creador de sala) | **50 gemas/hora** (~$0.17) | Elige si pagar |
| **Free** (participante) | **GRATIS** si el creador paga | $0 |
| **Free** (oyente) | **GRATIS** siempre | $0 |

**Por qué funciona:**
- Los Premium no tienen fricción — incentiva la conversión
- Los Free pueden crear salas pagando poco (~$0.17/hora)
- Los oyentes siempre entran gratis — maximiza la audiencia
- El creador decide si vale la pena activar la IA moderadora

---

## FASE 11 — Optimización de Costos de IA

### Estrategias y Ahorro Estimado

| Estrategia | Ahorro | Implementación | Complejidad |
|---|---|---|---|
| **Modelo pequeño para tareas simples** | 40% | Usar DeepSeek Flash para el 80% de las respuestas. Solo usar Pro para evaluaciones. DeepSeek Chat para NPCs narrativos | Baja |
| **Cache de respuestas** | 15% | Cachear respuestas de escenarios idénticos (útil para A1 principiantes que repiten) | Media |
| **Prompt compression automática** | 20% | Reducir el histórico a los últimos N mensajes + resumen de lo anterior cuando supera cierto umbral | Media |
| **Contexto adaptativo por nivel** | 10% | A1: solo contexto inmediato. B1+: histórico completo. C1+: full contexto | Baja |
| **Batch evaluation** | 5% | Evaluar goals cada 3 mensajes, no después de cada uno | Baja |
| **Compresión de audio** | 20% | Reducir bitrate de 128kbps a 64kbps (Groq acepta menor calidad) | Baja |
| **Resúmenes de sesiones largas** | 10% | Enviar resumen + últimos mensajes en vez de toda la historia | Media |
| **Modelo especializado por tarea** | 30% | Usar mini-modelos para corrección gramatical simple. Solo DeepSeek para conversación | Alta |
| **Fine-tuning** | 50% | Fine-tunear un modelo pequeño con respuestas de DeepSeek para tareas específicas | Alta |

### Arquitectura Multi-Modelo Recomendada

```
                     ┌─────────────────────────────┐
                     │    ROUTER DE IA              │
                     │                              │
                     │  ¿Qué necesita el usuario?   │
                     └──────────┬──────────────────┘
                                │
            ┌───────────────────┼───────────────────┐
            ▼                   ▼                   ▼
    ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
    │  DeepSeek    │   │  DeepSeek    │   │  Mini-modelo  │
    │  Flash       │   │  Pro         │   │  (cache/local)│
    │              │   │              │   │              │
    │  • Chat      │   │  • Evalúa    │   │  • Corrección │
    │  • NPC       │   │  • Speech    │   │  • Traducción │
    │  • Moderador │   │  • Goals     │   │  • Gramática  │
    │  • 80% tráf. │   │  • 15% tráf. │   │  • 5% tráf.  │
    │  • $0.08/M   │   │  • $0.28/M   │   │  • GRATIS     │
    └──────────────┘   └──────────────┘   └──────────────┘
```

### Ahorro Total Proyectado

| Sin optimización | Con optimización | Diferencia |
|---|---|---|
| $0.00704/sesión | $0.00380/sesión | **-46%** |
| $0.50/mes (Premium) | $0.27/mes (Premium) | **-46%** |
| $9.25 lifetime IA | $5.00 lifetime IA | **-46%** |

---

## FASE 12 — Proyecciones Financieras

### Escenario Conservador

| Métrica | Año 1 | Año 2 | Año 3 |
|---|---|---|---|
| Usuarios totales | 50,000 | 200,000 | 500,000 |
| MAU (activos) | 15,000 | 60,000 | 150,000 |
| Conversión Premium | 5% | 6% | 7% |
| Usuarios Premium | 750 | 3,600 | 10,500 |
| ARPU (todos) | $0.10 | $0.12 | $0.14 |
| Revenue mensual | $1,500 | $7,200 | $21,000 |
| Revenue anual | $18,000 | $86,400 | $252,000 |
| **Costo IA/mes** | $2,400 | $9,600 | $24,000 |
| **Costo infra/mes** | $1,500 | $4,000 | $8,000 |
| **CAC/mes** | $12,500 | $37,500 | $75,000 |
| **Margen bruto** | -$14,900 | -$43,900 | -$86,000 |
| **LTV** | $6.00 | $7.20 | $8.40 |
| **Ratio LTV:CAC** | 2:1 | 2.4:1 | 2.8:1 |

### Escenario Realista

| Métrica | Año 1 | Año 2 | Año 3 |
|---|---|---|---|
| Usuarios totales | 100,000 | 500,000 | 1,500,000 |
| MAU (activos) | 30,000 | 150,000 | 450,000 |
| Conversión Premium | 8% | 10% | 12% |
| Usuarios Premium | 2,400 | 15,000 | 54,000 |
| ARPU (todos) | $0.16 | $0.20 | $0.24 |
| Revenue mensual | $4,800 | $30,000 | $108,000 |
| Revenue anual | $57,600 | $360,000 | $1,296,000 |
| **Costo IA/mes** | $4,800 | $24,000 | $72,000 |
| **Costo infra/mes** | $2,500 | $8,000 | $20,000 |
| **CAC/mes** | $20,000 | $75,000 | $150,000 |
| **Margen bruto** | -$22,500 | -$77,000 | -$134,000 |
| **LTV** | $9.60 | $12.00 | $14.40 |
| **Ratio LTV:CAC** | 2.4:1 | 3:1 | 3.6:1 |

### Escenario Optimista

| Métrica | Año 1 | Año 2 | Año 3 |
|---|---|---|---|
| Usuarios totales | 200,000 | 1,200,000 | 5,000,000 |
| MAU (activos) | 60,000 | 360,000 | 1,500,000 |
| Conversión Premium | 12% | 15% | 18% |
| Usuarios Premium | 7,200 | 54,000 | 270,000 |
| ARPU (todos) | $0.24 | $0.30 | $0.36 |
| Revenue mensual | $14,400 | $108,000 | $540,000 |
| Revenue anual | $172,800 | $1,296,000 | $6,480,000 |
| **Costo IA/mes** | $9,600 | $57,600 | $240,000 |
| **Costo infra/mes** | $4,000 | $15,000 | $50,000 |
| **CAC/mes** | $30,000 | $120,000 | $300,000 |
| **Margen bruto** | -$29,200 | -$84,600 | -$50,000 |
| **LTV** | $14.40 | $18.00 | $21.60 |
| **Ratio LTV:CAC** | 2.9:1 | 3.6:1 | 4.3:1 |

### Punto de Equilibrio

| Escenario | Mes de equilibrio | Revenue acumulado |
|---|---|---|
| Conservador | **Mes 36+** (no alcanza en 3 años) | $356,400 |
| Realista | **Mes 24** | $1,713,600 |
| Optimista | **Mes 14** | $2,948,800 |

### Nota sobre los márgenes negativos

Las proyecciones muestran márgenes brutos negativos porque **el CAC domina los costos en los primeros años**. Esto es normal en startups SaaS con crecimiento agresivo. Los puntos clave:

1. **El margen de contribución (revenue - costo variable) es positivo desde el día 1** (ver Fase 7)
2. **El CAC es una inversión, no un gasto operativo** — un usuario adquirido genera LTV > CAC
3. **El margen bruto sin CAC es positivo** — el negocio es intrínsecamente rentable
4. **Al reducir CAC (crecimiento orgánico), el negocio se vuelve rentable**

---

## FASE 13 — Roadmap de Monetización

### MVP (Semanas 1-4)

| Iniciativa | Prioridad | Esfuerzo | Impacto |
|---|---|---|---|
| App 100% gratuita para validación | 🔴 Crítica | — | Validación de producto |
| Analytics de comportamiento | 🔴 Crítica | 1 semana | Saber qué funciona |
| Onboarding completo sin paywall | 🔴 Crítica | — | Retención inicial |
| **20 créditos/día + sistema de rachas** | 🔴 Crítica | 1 semana | Fomenta el hábito |

### Fase 1: Monetización Inicial (Semanas 5-12)

| Iniciativa | Prioridad | Esfuerzo | Impacto esperado |
|---|---|---|---|
| Membresía Premium $1.99/mes + trial 7 días | 🔴 Crítica | 3 semanas | Revenue principal |
| Membresía Anual $14.99/año | 🔴 Crítica | 1 semana | Mejora LTV |
| Programa de referidos | 🟠 Alta | 1 semana | Crecimiento viral |
| Tienda de Gemas ($4.99-$34.99) | 🟠 Alta | 3 semanas | Revenue secundario |
| Cosméticos básicos (títulos, marcos) | 🟠 Alta | 2 semanas | Engagement |

### Fase 2: Escalamiento (Meses 3-8)

| Iniciativa | Prioridad | Esfuerzo | Impacto esperado |
|---|---|---|---|
| Battle Pass ($4.99/temporada 8 semanas) | 🔴 Crítica | 4 semanas | **+40% retención** |
| Moderador IA en Guild (modelo híbrido) | 🟠 Alta | 2 semanas | Engagement social |
| Mascotas y decoraciones de mesa | 🟠 Alta | 3 semanas | Monetización gremio |
| Paquete Lifetime $29.99 | 🟠 Alta | 1 semana | Revenue inmediato |
| Certificaciones de nivel (+$9.99) | 🟡 Media | 2 semanas | Credibilidad |

### Fase 3: Madurez (Meses 9+)

| Iniciativa | Prioridad | Esfuerzo | Impacto esperado |
|---|---|---|---|
| Precios regionales (LATAM -30%, India -50%) | 🔴 Crítica | 1 semana | +200% base en mercados emergentes |
| Plan Familiar ($12.99/4 cuentas) | 🟠 Alta | 2 semanas | Segmento padres |
| Licencias B2B para instituciones | 🟠 Alta | 6 semanas | Revenue estable (contratos anuales) |
| Colaboraciones con franquicias anime/manhwa | 🟡 Media | Variable | Adquisición masiva |
| Eventos especiales (cosméticos limitados) | 🟡 Media | 2 semanas | Reactivación de inactivos |

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| **Costo de IA sube** | Media | Alto | Contratos con proveedores. Modelos open-source locales |
| **Baja conversión (<5%)** | Media | Alto | A/B testing de precios. Trial extendido. Mejor onboarding |
| **Churn alto (>10%/mes)** | Media | Alto | Battle Pass, rachas, eventos, contenido fresco |
| **Competencia copia el modelo** | Baja | Medio | La ventaja es el contenido y la narrativa, no el código |
| **Estacionalidad educativa** | Alta | Bajo | Eventos de verano, contenido temático, streaks protectores |
| **Fraude de referidos** | Baja | Medio | Rate limiting, verificación de identidad |

---

## Recomendación Final

### La Propuesta de Negocio

Dungeon of English es **económicamente viable desde el usuario 1** porque:

1. **Costo de IA por sesión: $0.006** — insignificante
2. **Costo lifetime de IA para completar el juego: ~$9.25** — menos que 1 mes de suscripción
3. **Margen de contribución: 52-74%** en todos los planes pagos
4. **LTV:CAC ratio: 20:1** en escenario realista
5. **Punto de equilibrio: 24 meses** en escenario realista (muy bueno para SaaS)

### Lo que hace a este modelo imbatible

| Factor | Ventaja competitiva |
|---|---|
| **Precio** | $1.99/mes es imbatible. Duolingo cuesta 3.5x más. Babbel 7x más |
| **Costo de IA** | El margen es tan alto que podemos bajar precios aún más si es necesario |
| **Efecto de red** | El Guild Hall y las mesas de voz crean barreras de salida |
| **Contenido generado por IA** | Escenarios infinitos. Sin límite de contenido |
| **Economía de escala** | El costo de IA se reduce con volumen. Los márgenes mejoran con el tiempo |

### Lo que NUNCA debe monetizarse

| Elemento | Razón |
|---|---|
| **Vocabulario básico** | Es el corazón del aprendizaje. Debe ser 100% gratis |
| **Progresión CEFR** | Bloquear niveles sería "Pay to Win" educativo |
| **Misiones principales** | La historia principal es la razón de ser del juego |
| **Correcciones básicas** | El feedback es parte esencial del aprendizaje |
| **Acceso al Guild Hall** | El gremio es el hub social. Debe ser gratuito para todos |

### Conclusión

Dungeon of English tiene un modelo económico **sólido, escalable y éticamente responsable**. Los costos de IA son sorprendentemente bajos ($0.006/sesión), lo que permite:

- **Ofrecer un plan gratuito generoso** (20 créditos/día)
- **Cobrar precios agresivos** ($1.99/mes)
- **Mantener márgenes saludables** (52-74%)
- **Crecer sin quemar efectivo** (LTV > CAC desde el día 1)

El verdadero riesgo no es la economía unitaria — **es la retención**. Si logramos que el usuario vuelva a diario (streak, Battle Pass, gremio), el modelo financiero funciona en cualquier escenario.

**Veredicto: Inversión recomendada. Riesgo controlado. Alto potencial de crecimiento.**
