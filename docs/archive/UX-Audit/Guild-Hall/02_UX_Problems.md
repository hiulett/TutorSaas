# Auditoría del Guild Hall — Problemas de UX priorizados

> **Componente:** `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart` (1.121 líneas)
> **Fecha:** 2026-08-01
> **Método:** Hallazgos verificados con evidencia `archivo:línea`. Cada problema se prioriza y se mapea a la ley de UX que viola.

---

## 1. Tabla priorizada

| # | Código | Problema | Severidad | Impacto | Evidencia | Ley de UX violada |
|---|--------|----------|-----------|---------|-----------|-------------------|
| 1 | **C** | Dos tablones de misiones consecutivos (`GuildQuestBoard` + `MissionBoardWidget`): información duplicada y confusa | 🔴 Alta | Confusión funcional: el usuario no sabe cuál es la fuente de verdad de misiones | `:665` y `:669` | **Ley de la redundancia / densidad** — contenido repetido que exige doble procesamiento sin aportar valor |
| 2 | **F** | Saturación de bloques en scroll (11 bloques) → el "salón vivo" no se percibe; el contenido principal queda diluido | 🔴 Alta | Abandono / pérdida de foco en el objetivo (encontrar y unirse a una mesa) | `:389`→`:710` | **Ley de densidad + Ley de la carga cognitiva** — a mayor densidad, menor comprensión |
| 3 | **A** | Prestigio (tarjeta completa) antes que las mesas: compite con el contenido principal | 🟠 Media-alta | El usuario llega al objetivo (mesas) más tarde de lo necesario | `:394` precede a `:399–496` | **Ley de la jerarquía visual** — lo prominente no es lo principal |
| 4 | **D** | Cartel decorativo "MISIONES DEL GREMIO" sin `onTap`, redundante con los tablones reales de arriba | 🟠 Media | Ruido visual; confunde (parece interactivo y no lo es) | `:689–694` | **Ley de Fitts** — un elemento parecido a un botón sin zona activa engaña al objetivo; **ley de proximidad** — está lejos de la información que duplica |
| 5 | **B** | NPC (`GuildMasterNpcBanner`) enterrado tras dos tablones de misiones | 🟡 Media | El NPC es ambientación clave del "gremio" y queda en posición secundaria | `:665–669` antes de `:674` | **Ley de la jerarquía** — el elemento de marca/identidad pierde relevancia |
| 6 | **E** | Botón INITIALIZE usa `ElevatedButton` en lugar de `RunicButton` | 🟡 Media-baja | Inconsistencia del design system; percepción de menor calidad visual | `:411–421` | **Ley de la consistencia** — el usuario aprende un lenguaje visual que aquí se rompe |
| 7 | **G** | Archivo monolítico de 1.121 líneas (UI + lógica + diálogos) | 🟡 Media-baja | Mantenibilidad, pero también riesgo de UX: cambios localizados golpean bloques no relacionados | total: 1.121 líneas | **Ley de modularidad (proceso)** — dificulta el rediseño iterativo seguro |
| 8 | **H** | Falta sensación de "gremio vivo": sin eventos dinámicos, contador de conectados ni anuncios | 🟢 Baja (carencia) | Oportunidad de producto: el salón no transmite actividad social | pantalla completa | **Ley del contexto** — sin señales dinámicas no hay sensación de espacio habitado |
| 9 | — | Cartel "TABLA DE RANGO" es el único acceso al modal de rango; sin label de navegación primaria | 🟢 Baja | Descubrimiento pobre de una funcionalidad ya implementada | `:698–704`, modal en `:139` | **Ley de descubrimiento progresivo** — el acceso queda oculto tras un elemento decorativo |

---

## 2. Análisis detallado

### 2.1 Problema C — Dos tablones de misiones (🔴 Alta)
- **Evidencia:** `GuildQuestBoard` en `:665` y `MissionBoardWidget` en `:669`, separados por un solo `SizedBox(height: 20)` (`:667`).
- **Por qué importa:** El usuario ve dos superficies de "misiones" casi idénticas en la misma pantalla. Violan la ley de densidad (información duplicada sin valor añadido) y la ley de la claridad: la fuente de verdad queda ambigua.
- **Recomendación:** Consolidar en un único tablón con filtros (el que tenga filtros es candidato natural) o delegar las misiones a su propia sección/pestaña, liberando el scroll.

### 2.2 Problema F — Saturación del scroll (🔴 Alta)
- **Evidencia:** 11 bloques consecutivos desde `:389` hasta `:710`: header → prestigio → mesas → categorías → lista → tablón 1 → tablón 2 → NPC → trofeos → 2 carteles.
- **Por qué importa:** El contenido principal (las mesas) ocupa solo 3 de 11 bloques. El usuario se enfrenta a una pared de secciones sin jerarquía de importancia.
- **Recomendación:** Reordenar para que la lista de mesas sea lo primero tras la cabecera, compactar prestigio, y agrupar ambientación (NPC, trofeos, carteles) en una zona inferior o en un patrón de tarjetas plegables.

### 2.3 Problema A — Prestigio antes que mesas (🟠 Media-alta)
- **Evidencia:** `_GuildPrestigeHud` (`:394`) se renderiza antes del título "MESAS DEL GREMIO" (`:399`) y de la lista de mesas (`:496`).
- **Por qué importa:** El objetivo principal del Guild Hall es encontrar/unirse a una mesa de voz. El HUD de prestigio es información de estado secundaria. Violación de jerarquía visual: lo visualmente prominente no es lo prioritario.
- **Recomendación:** Convertir el HUD en una barra compacta (stats inline) colocada bajo la lista de mesas o en la cabecera, o moverla a la pestaña de estado del usuario.

### 2.4 Problema D — Cartel decorativo "MISIONES DEL GREMIO" (🟠 Media)
- **Evidencia:** `_GuildPoster` con `title: 'MISIONES DEL GREGIO'` sin `onTap` (`:689–694`), situado justo debajo de dos tablones reales de misiones.
- **Por qué importa:** Ley de Fitts: se percibe como zona interactiva y no lo es. Ley de proximidad: repite información que ya está encima, en el mismo scroll.
- **Recomendación:** Eliminarlo o convertirlo en un CTA funcional que lleve a un tablón consolidado.

### 2.5 Problema B — NPC enterrado (🟡 Media)
- **Evidencia:** NPC en `:674`, después de ambos tablones (`:665`, `:669`).
- **Matiz (OK parcial):** los trofeos al final (`:679`) sí son correctos como vitrina de cierre. El problema es solo la posición del NPC, que es pieza de ambientación/identidad del gremio.
- **Recomendación:** Subir el NPC junto a la cabecera (patrón "maestre recibiendo al aventurero") o integrarlo en el header.

### 2.6 Problema E — Botón INITIALIZE inconsistente (🟡 Media-baja)
- **Evidencia:** `ElevatedButton.icon` con `backgroundColor: AppColors.runeViolet` (`:411–421`).
- **Por qué importa:** El resto de la app usa `RunicButton`; un botón "distinto" se percibe como no-clic-able o de menor calidad.
- **Recomendación:** Sustituir por `RunicButton` respetando la variante rúnica.

### 2.7 Problema G — Monolito de 1.121 líneas (🟡 Media-baja)
- **Evidencia:** 1.121 líneas totales; widgets privados (`_GuildPrestigeHud` :758, `_GuildHallHeader` :811, `_GuildPoster` :879, `_GuildTrophies` :963) y lógica (providers, diálogos) conviven en un único fichero.
- **Por qué importa:** Dificulta rediseños aislados y aumenta el riesgo de regresiones en una pantalla ya saturada.
- **Recomendación:** Extraer cada bloque a su propio widget de presentación y separar la lógica en un controlador/notifier.

### 2.8 Problema H — Sin sensación de "gremio vivo" (🟢 Carencia)
- **Evidencia:** La pantalla es 100% estática en render (solo cambia la lista de mesas vía `roomsAsync`). No hay eventos, contadores de conectados ni anuncios.
- **Por qué importa:** El "salón vivo" es el alma del producto; sin señales dinámicas (X cazadores conectados, última cacería, aviso de evento) el gremio se siente vacío.
- **Recomendación (de producto):** Añadir una franja superior con estado en vivo vía Realtime de Supabase: número de conectados por mesa, actividad reciente, anuncios del Maestre.

### 2.9 Descubrimiento del modal de rango (🟢 Baja)
- **Evidencia:** El modal `_showRankModal` ya existe (`:139`) pero solo se alcanza desde el cartel decorativo "TABLA DE RANGO" (`:698–704`).
- **Por qué importa:** Ley de descubrimiento progresivo: la funcionalidad queda oculta tras un cartel de aspecto decorativo.
- **Recomendación:** Exponer el acceso a rango en la cabecera (junto al emblema CEFR de `_GuildHallHeader`) y no solo en el cartel.

---

## 3. Prioridad de intervención sugerida

| Fase | Acciones | Problemas cubiertos |
|------|----------|---------------------|
| **P0 (rápida, alto impacto)** | Consolidar tablones de misiones; eliminar cartel decorativo "MISIONES DEL GREMIO" | C, D |
| **P1 (reordenar)** | Mover mesas a posición primaria; compactar prestigio; subir el NPC junto al header | A, B, F |
| **P2 (consistencia + descubrimiento)** | `RunicButton` en INITIALIZE; exponer acceso al modal de rango desde el header | E, 9 |
| **P3 (producto + mantenimiento)** | Franja de estado en vivo (Realtime); extraer widgets y lógica del monolito | H, G |

---

## 4. Resumen en una frase

> El Guild Hall **muestra 11 bloques en scroll sin jerarquía de importancia** (el contenido principal —las mesas— va tercero), **duplica el tablón de misiones**, oculta el modal de rango tras un cartel decorativo, y **no transmite actividad en vivo**; además se mantiene en un único archivo de 1.121 líneas que dificulta el rediseño iterativo.
