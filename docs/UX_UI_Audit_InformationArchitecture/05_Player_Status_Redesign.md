# Rediseño del Estado del Aventurero — Hallazgo 05

> **Ámbito:** Pantalla `/hunter-status` y tab «Estado» del dashboard
> **Archivos:**
> - `lib/features/dashboard/presentation/screens/hunter_status_screen.dart`
> - `lib/features/dashboard/presentation/widgets/progress_tab_view.dart`
> - `lib/features/dashboard/presentation/widgets/charts/skills_radar_chart.dart`
> **Tipo:** Información arquitectónica (IA) / distribución de atributos / descubrimiento de funcionalidad
> **Estado:** Propuesta — sin cambios de código

---

## 1. Estado actual

### Pantalla `/hunter-status` (`hunter_status_screen.dart`)
Es una pantalla de **edición** del Estado del Cazador:

| # | Bloque | Evidencia |
|---|--------|-----------|
| 1 | Header «ESTADO DEL CAZADOR» + back | `hunter_status_screen.dart:138-157` |
| 2 | Tarjeta avatar + nombre + **título equipado** + **rango CEFR + XP** | `hunter_status_screen.dart:165-211` |
| 3 | Pool de puntos disponibles | `hunter_status_screen.dart:215-234` |
| 4 | Grid de 4 atributos editables **STR / INT / DEX / LUK** (`SegmentedBar` + `AnimatedCounter` + botones −/+) | `hunter_status_screen.dart:237-244`, `_buildStatRow` en `:267-325` |
| 5 | Botón guardar «DISTRIBUIR PUNTOS» (persiste stats en la `bio` del perfil) | `hunter_status_screen.dart:248-255`, `_saveStats` `:85-111`, formato `_formatBio` `:81-83` |

### Tab «Estado» del dashboard (`progress_tab_view.dart`)
Es la pantalla de **visualización de progreso**:

- Header de perfil editable (→ `/profile-edit`): `progress_tab_view.dart:64-108`.
- Banner «RACHA EN RIESGO» (LIVE-02): `progress_tab_view.dart:113-187`.
- Botón épico «VENTANA DE ESTADO DEL MONARCA» (→ `/hunter-status`), que promete **«matriz de 11 atributos, títulos equipados y radar de poder»**: `progress_tab_view.dart:190-241`.
- Grid de stats clave (XP / Racha / Nivel): `progress_tab_view.dart:246-305`.
- Charts de análisis avanzado (D-06), **incluido el radar**: `_buildAdvancedAnalysis()` en `progress_tab_view.dart:658-688`, con `SkillsRadarChart` en `:683`.

---

## 2. Hallazgos con evidencia

### Hallazgo 5.1 — El radar de habilidades vive en el tab «Estado», no en la pantalla que se vende como el HUD del cazador

**Evidencia:**
- `SkillsRadarChart` se instancia en `progress_tab_view.dart:683` (dentro de `_buildAdvancedAnalysis`).
- La clase está en `lib/features/dashboard/presentation/widgets/charts/skills_radar_chart.dart:10-11`.
- La pantalla `/hunter-status` **no** importa ni instancia el radar (ver imports y árbol en `hunter_status_screen.dart:1-14` y `:159-258`).
- Sin embargo, el botón que lleva a `/hunter-status` promete «radar de poder»: `progress_tab_view.dart:227-233` («Ver matriz de 11 atributos, títulos equipados y radar de poder»).

**Problema:**
- La promesa del botón no se cumple: el radar está en el tab ESTADO, no en la pantalla del cazador. El usuario que entra por `/hunter-status` buscando su radar no lo encuentra; el que está en el tab Estado ve el radar pero sin el contexto de atributos editables ni títulos.
- La funcionalidad está repartida en dos superficies con narrativa opuesta (edición vs visualización), pero ninguna ofrece la vista completa «tú como aventurero».

**Justificación:**
- La pantalla del cazador es la identidad del personaje: debe ser el lugar canónico para ver el **perfil de poder** (radar + atributos + rango + logros), no solo un formulario de stats.

**Impacto (qué se gana):**
- Una única fuente de verdad de la identidad del personaje: `hunter-status` = perfil del aventurero.
- Se cumple la promesa del botón «VENTANA DE ESTADO DEL MONARCA».
- El radar, al estar junto a los atributos editables, muestra su efecto en vivo al redistribuir puntos (feedback inmediato).

---

### Hallazgo 5.2 — Los 4 atributos consumen todo el viewport con filas de alto desperdicio

**Evidencia:**
- Cada atributo es una fila de `margin bottom 12`, `padding 12/16`, con una `SegmentedBar` de **10 segmentos** y **alto 5px** (barras casi invisibles): `hunter_status_screen.dart:267-325`, barra en `:287-291`.
- Los botones −/+ y el `AnimatedCounter` de 18px dominan visualmente la fila (`:296-321`), dejando la barra como elemento decorativo.
- Cuatro filas consecutivas (`:239-242`) producen ~600px de contenido para representar 4 números del 5 al 25.

**Problema:**
- Desproporción grave entre superficie utilizada y densidad de información: 4 atributos ocupan más espacio que todo el resto del perfil (título, rango, XP).
- Las `SegmentedBar` de 10 segmentos a 5px de alto no comunican el valor con claridad; el valor real se lee en el contador.

**Justificación:**
- En el formato móvil, una cuadrícula compacta de 4 widgets (ícono + valor + badge de nivel) transmite los atributos de un vistazo y deja espacio para el resto de la identidad (radar, XP, títulos, logros, rango).

**Impacto (qué se gana):**
- El estado del cazador se ve **completo** en una pantalla, no como un formulario interminable.
- Mejora la legibilidad del valor de cada atributo (el número pasa a ser protagonista).

---

### Hallazgo 5.3 — La información de identidad está repartida de forma ineficiente (XP / títulos / logros / atributos / rango)

**Evidencia:**
- **Título equipado y rango CEFR/XP:** solo en `hunter_status_screen.dart:191-205` (dentro de la tarjeta de avatar) y de forma breve.
- **Logros (achievements):** el dashboard lee `userAchievementsProvider` en `dashboard_screen.dart:48`, pero `/hunter-status` no los muestra en absoluto (imports/árbol en `hunter_status_screen.dart`).
- **XP / racha / nivel:** viven en el tab Estado (`progress_tab_view.dart:257-300`) y en el HUD (`HunterHudHeader`), no en la pantalla del cazador.
- **Atributos:** solo en `/hunter-status`.
- **Radar:** solo en el tab Estado (ver Hallazgo 5.1).

**Problema:**
- El concepto de «Estado del Aventurero» está fragmentado: cada dato vive en una pantalla distinta y ninguna reúne la ficha completa. El usuario debe saltar entre tab ESTADO y `/hunter-status` para recomponer su personaje.

**Justificación:**
- El rediseño propone que `/hunter-status` sea la **ficha del aventurero**: radar (identidad de poder), atributos compactos (edición), XP/nivel/rango (progreso numérico) y títulos/logros (reconocimiento), todos en una sola superficie con jerarquía clara.

**Impacto (qué se gana):**
- Un solo lugar de consulta del personaje → menos navegación entre superficies.
- El botón «VENTANA DE ESTADO DEL MONARCA» cumple su promesa y se justifica su existencia.

---

## 3. Cambios propuestos

1. **Reincorporar el radar a `/hunter-status`** como sección visible: mover `SkillsRadarChart` (hoy en `progress_tab_view.dart:683`) a la pantalla del cazador, ubicado tras los atributos o como sección destacada «RADAR DE PODER» (diseño HUD holo, acorde al `CyberBgMode.hunterStatus` usado en `hunter_status_screen.dart:131-132`).
2. **Compactar los atributos STR/INT/DEX/LUK** en widgets pequeños: tarjeta por atributo con iconografía propia, badge numérico y mini-control +/− (manteniendo `SegmentedBar` solo como mini-barra de contexto si se desea), en una cuadrícula 2×2 o 4×1 compacta.
3. **Distribuir eficientemente** en `/hunter-status`:
   - **Rango / nivel:** tarjeta superior (ya existe `:200-205`) → elevar a chip prominente.
   - **XP:** barra/contador dedicado (hoy solo textual en `:200`).
   - **Títulos equipados:** ya presente (`:191-197`) → mantener como selector visible.
   - **Logros:** nueva sección corta alimentada por `userAchievementsProvider` (ya consumido en el dashboard, `dashboard_screen.dart:48`).
   - **Atributos:** bloque compacto de edición.
   - **Radar:** sección de visualización de poder.
4. **Mantener intacta la edición de stats** (lógica de pool de puntos `:24-28`, `_parseBio` `:50-79`, `_formatBio` `:81-83`, persistencia vía `dashboardRepositoryProvider.updateUserProfile` `:91-97`, y el botón «DISTRIBUIR PUNTOS»). El rediseño es **solo presentacional** sobre los mismos `_str/_int/_dex/_luk` y `_pointsPool`.
5. **En el tab Estado** (`progress_tab_view.dart`): retirar el radar del bloque `_buildAdvancedAnalysis` (quedará `FluencyLatencyChart` y `PracticeHeatmap`), y ajustar el copy del botón para que la promesa coincida con la nueva realidad (p. ej. «Ver ficha completa del cazador»).

## 4. Riesgos (lo que NO debe perderse)

| Riesgo | Mitigación |
|--------|-----------|
| Romper la persistencia de stats en `bio` | No tocar `_saveStats`/`_formatBio` ni el formato `[Stats|STR:x|INT:x|DEX:x|LUK:x]` (`hunter_status_screen.dart:53`, `:81-83`). |
| Romper el cálculo del pool de puntos | Reutilizar exactamente la aritmética actual `(val - 5)` y el tope de 10 (`:63-65`). |
| Perder el radar en el tab Estado sin reemplazo | El tab conserva fluidez y heatmap (`progress_tab_view.dart:681-685`); el radar gana contexto real en `/hunter-status`. |
| Duplicar el radar (dos instancias = dos cargas) | Mover, no copiar: una única instancia de `SkillsRadarChart`. |
| Que el radar dependa de datos que solo se cargan en el tab Estado | Verificar que el provider del radar pueda resolverse en el contexto de `/hunter-status` (mismo feature `dashboard`); si no, montarlo bajo demanda con el mismo `ref.watch` que usa `progress_tab_view.dart`. |
| Perder legibilidad al compactar las barras de 10 segmentos | El valor numérico pasa a ser el elemento primario; la mini-barra queda como refuerzo, no como fuente de lectura. |

## 5. Resultado esperado

- `/hunter-status` se convierte en la **ficha completa del aventurero**: radar de poder + atributos compactos editables + XP/nivel/rango + título equipado + logros.
- La promesa del botón «VENTANA DE ESTADO DEL MONARCA» se cumple.
- Pantalla de edición que se ve y se entiende de un vistazo, con la misma lógica de persistencia.
- Tab Estado enfocado en tendencias (fluidez semanal, heatmap, vocabulario) sin el radar huérfano.

## 6. Decisiones abiertas

- ¿Los logros se traen completos o se muestra un top-3 con acceso «VER TODOS» en `/hunter-status`?
- ¿Los atributos quedan en cuadrícula 2×2 (más compacta) o 4×1 horizontal (más legible en móvil)?
- ¿El radar se muestra siempre o solo cuando el usuario tiene ≥1 punto distribuido (estado vacío motivador)?
