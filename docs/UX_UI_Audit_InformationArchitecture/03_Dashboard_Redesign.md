# Rediseño del Dashboard — Hallazgo 03

> **Ámbito:** Tab «Dungeons» (índice 0) de `DashboardScreen`
> **Archivo principal:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
> **Tipo:** Información arquitectónica (IA) / densidad de contenido / duplicación de fuentes de verdad
> **Estado:** Propuesta — sin cambios de código

---

## 1. Estado actual (inventario de bloques, en orden de render)

| # | Bloque | Widget | Evidencia | Destino |
|---|--------|--------|-----------|---------|
| 1 | Header + badges (gemas, racha, PRO) | `HunterHudHeader` / `Row` de badges | `dashboard_screen.dart:178`, `:183` | Se mantiene |
| 2 | Accesos rápidos del sistema (5 accesos) | `_buildQuickAccess` | `dashboard_screen.dart:310-344` | Se mantiene (bloque 4 de la propuesta) |
| 3 | Hero «SIGUIENTE RAID» | `NextRecommendedLessonHero` | `dashboard_screen.dart:349-395` | **Eliminar** |
| 4 | Banner «Salas de Chat de Voz» (→ `/chat-rooms`) | `GlassCard` con `GestureDetector` | `dashboard_screen.dart:399-471` | **Eliminar** |
| 5 | Ruta de Aprendizaje por Etapas (A1-C2) | `LearningPathRoadmap` | `dashboard_screen.dart:476-478` | **Fuente oficial de progreso — mantener y priorizar** |
| 6 | Tablón de Misiones | `MissionBoardWidget` | `dashboard_screen.dart:483` | **Evaluar mover fuera** |
| 7 | Bottom nav (MAZMORRAS / GUILD / ESTADO / CONFIG) | `_buildNavItem` | `dashboard_screen.dart:499-540` | Se mantiene |

---

## 2. Hallazgos con evidencia

### Hallazgo 3.1 — El hero «SIGUIENTE RAID» duplica la primera etapa del LearningPathRoadmap

**Evidencia:**
- El hero se construye a partir de `recommendedLessonsProvider` y del nivel CEFR activo: `dashboard_screen.dart:61-74` (selección de `heroLesson`).
- El hero se renderiza en `dashboard_screen.dart:349-395`, con etiqueta interna «SIGUIENTE PASO • ETAPA ${lesson.level}» (`next_recommended_lesson_hero.dart:90`).
- El `LearningPathRoadmap` renderiza **la misma lección** como nodo `isNextLesson` dentro de la etapa activa: `learning_path_roadmap.dart:242-243` (`isNextLesson = !isCompleted && (index == 0 || ...)`), con botón que abre exactamente el mismo flujo `/conversation?scenarioId=...` (`learning_path_roadmap.dart:378-386`).

**Problema:**
- Dos componentes del mismo tab muestran «cuál es la siguiente lección»: el hero como tarjeta destacada y el roadmap como nodo marcado. Ambas apuntan a la misma lección y al mismo flujo de conversación.
- El dashboard no tiene una única fuente de verdad para «siguiente paso»; la Ruta por Etapas (CEFR) es la fuente oficial del progreso A1→C2 (`learning_path_roadmap.dart:29` define la escala `['A1','A2','B1','B2','C1','C2']`).

**Justificación:**
- La ruta ya indica de forma explícita (nodo con borde `manaCyan`, sombra violeta e ícono `play`) cuál es el siguiente paso, incluyendo score y progreso de la etapa (`learning_path_roadmap.dart:300-339`). El hero añade peso visual y longitud de scroll sin añadir información única: título, descripción, `mainObjective` y botón de voz ya están en el nodo `QuestCard` de la ruta.

**Impacto (qué se gana):**
- Un solo punto de decisión de «siguiente paso» → menos carga cognitiva.
- Se libera ~1 viewport de scroll (el hero es alto: `padding 20`, tarjeta de objetivos, botón de 46px en `next_recommended_lesson_hero.dart:227-266`).
- La ruta pasa a ser la heroína visual del tab, reforzando el modelo mental de progresión por etapas.

---

### Hallazgo 3.2 — El banner «Salas de Chat de Voz» duplica la navegación GUILD del menú inferior

**Evidencia:**
- El banner navega a `/chat-rooms` mediante `context.push('/chat-rooms')`: `dashboard_screen.dart:409`.
- El ítem «GUILD» del bottom nav también navega a `/chat-rooms`: `dashboard_screen.dart:518-523`.

**Problema:**
- Mismo destino, dos accesos en la misma pantalla. El banner consume espacio vertical (`GlassCard` con padding 16, ícono circular 26px, dos líneas de texto en `dashboard_screen.dart:400-471`) y compite con el contenido de progreso.

**Justificación:**
- El menú inferior (barra flotante persistente) ya cumple la función de descubrimiento del gremio. El banner dentro del scroll añade redundancia sin aportar un affordance nuevo; la etiqueta «EN VIVO» (`dashboard_screen.dart:449-452`) es cosmética y no refleja estado real de ocupación.

**Impacto (qué se gana):**
- Menos ruido visual entre la ruta de progreso y el acceso al gremio.
- Se elimina la ambigüedad de «¿voy por el banner o por el menú?».
- Espacio vertical recuperado para el contenido educativo (ruta + mapa).

---

### Hallazgo 3.3 — Misiones de gremio dentro del tab «Dungeons» (evaluar movimiento)

**Evidencia:**
- `MissionBoardWidget` se renderiza en `dashboard_screen.dart:483`.
- El componente vive en el feature `missions`: `lib/features/missions/presentation/widgets/mission_board_widget.dart:11`.

**Problema:**
- El tablón de misiones de gremio se muestra en el tab de mazmorras/progreso, pero el concepto «gremio» tiene su propio destino (`/chat-rooms`, tab GUILD). Hay una fractura conceptual: el usuario administra gremio en un lugar y consume misiones de gremio en otro.

**Justificación:**
- Las misiones de gremio pertenecen al dominio del gremio; su contenedor natural es la pantalla del gremio (tab GUILD). Mantenerlas en Dungeons obliga a renderizar un bloque alto de contenido de dominio ajeno en una pantalla cuyo objetivo propuesto es el progreso.

**Impacto (qué se gana):**
- Coherencia de información (cada dominio vive en su pantalla).
- El dashboard queda enfocado: **ruta (progreso) + mapa (accesos) + quick access**.
- Reduce la carga de datos/RLS en el primer render del dashboard si el widget se mueve a un contexto bajo demanda.

---

### Hallazgo 3.4 — Orden de prioridad visual actual favorece contenido de marketing sobre progreso

**Evidencia:**
- El orden de render en `dashboard_screen.dart`: header (`:178`) → badges (`:183`) → quick access (`:310`) → hero RAID (`:349`) → banner chat de voz (`:399`) → LearningPathRoadmap (`:476`) → MissionBoardWidget (`:483`).
- La ruta, que es la fuente oficial del progreso, aparece por debajo del hero y del banner.

**Problema:**
- Los dos primeros bloques «de empuje» (RAID + chat de voz) empujan la información de progreso real fuera de la primera pantalla (below the fold).

**Justificación:**
- El modelo mental del producto es «aprender hablando por etapas». La ruta A1-C2 con su nodo «siguiente paso» es el corazón del dashboard; debe ser el primer bloque de contenido tras el HUD.

**Impacto (qué se gana):**
- El usuario ve progreso y siguiente acción al primer vistazo → mejora de la métrica «time to next action».

---

## 3. Cambios propuestos

1. **Eliminar** el bloque hero «SIGUIENTE RAID» (`dashboard_screen.dart:349-395`) y su lógica de selección de `heroLesson` (`:61-74`) si no se reutiliza en otro lugar.
2. **Eliminar** el banner «Salas de Chat de Voz» (`dashboard_screen.dart:399-471`).
3. **Mover** `MissionBoardWidget` al flujo del gremio (pantalla destino de `/chat-rooms`), evaluando si el widget se puede montar bajo demanda.
4. **Reordenar** el tab Dungeons como: HUD (`HunterHudHeader`) → badges/quick access → **LearningPathRoadmap** (primera fuente de progreso) → mapa/quick access secundario.
5. **Mantener intactos** todos los destinos de navegación: `/dungeon-map`, `/shop`, `/oracle-test`, `/level-exam`, `/chat-rooms` siguen accesibles (quick access + bottom nav).

## 4. Riesgos (lo que NO debe perderse)

| Riesgo | Mitigación |
|--------|-----------|
| Perder el atajo directo a la siguiente conversación de voz | La ruta ya lo provee vía nodo `isNextLesson` → `/conversation?scenarioId=...` (`learning_path_roadmap.dart:378-386`). Verificar que el nodo siga siendo el primer tile de la etapa. |
| Perder la visibilidad de gemas/racha/premium | Se conserva el HUD y la fila de badges (`dashboard_screen.dart:178-305`). |
| Perder el acceso a misiones | Se mueve, no se elimina: el tablón pasa a vivir en el flujo del gremio. |
| Que «SIGUIENTE RAID» usara un fallback distinto a la ruta (recomendación de `recommendedLessonsProvider`) | Si la recomendación debe primar sobre el orden de catálogo, incorporar esa lógica de prioridad dentro del propio `LearningPathRoadmap`, no en un bloque duplicado. |
| Cambiar el orden sin revalidar scroll/infinite layout | Aceptar a nivel de diseño; medir que el primer viewport muestre ruta + quick access sin scroll. |

## 5. Resultado esperado

- Tab Dungeons enfocado en **progreso**: Ruta por Etapas (fuente oficial) como protagonista, apoyada por mapa y accesos rápidos.
- Eliminación de la duplicación «siguiente paso» (hero vs ruta) y «gremio» (banner vs bottom nav).
- Reducción de longitud de scroll estimada en **~1,5 viewports** (hero + banner).
- Menor carga cognitiva y una única fuente de verdad para la progresión A1→C2.

## 6. Decisiones abiertas

- ¿El `MissionBoardWidget` queda como un acceso (chip/badge) dentro del tab o se integra directamente en la pantalla del gremio?
- ¿El «SIGUIENTE RAID» desaparece por completo o se transforma en una variante compacta (badge) integrada en el header de la ruta?
