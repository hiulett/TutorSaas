# 02 — Propuesta de Rediseño

> **Ruta:** `Docs/UX_Audits/CharacterCreation/02_Redesign_Proposal.md`
> **Fecha:** 2026-08-04
> **Estado:** PROPUESTA — pendiente de aprobación

---

## Alternativas evaluadas

### A. Carrusel actual (mantener, solo subir)
- **Pro:** cambio mínimo.
- **Contra:** sigue siendo un PageView que oculta stats; el panel sigue debajo.
- **Veredicto:** ❌ no resuelve el problema de fondo (stats ocultas + scroll).

### B. Selector tipo "Cover Flow" + ficha grande
- Avatar central grande (héroe) con tarjetas laterales en perspectiva.
- **Pro:** muy inmersivo, protagonismo del avatar.
- **Contra:** implementación compleja; en pantallas pequeñas las laterales se cortan.
- **Veredicto:** ⚠️ visualmente atractivo pero arriesgado.

### C. Selector horizontal compacto (miniatura) + avatar grande arriba + ficha abajo (RECOMENDADA)
```
Título
Descripción (1 línea)

[ AVATAR GRANDE — protagonista, halo + glow suave ]

[  Selector horizontal compacto: mini-tarjetas (imagen + nombre)  ]

[  FICHA RPG (ancho completo, siempre visible):
     Clase · Rol · Rarity
     ▶ GRÁFICO DE RADAR (6 stats) ◀
       Ataque · Defensa · Magia · Velocidad · Soporte · Supervivencia
     Descripción · Especialidad · Estilo de juego · Habilidades ]
[  Botón Continuar  ]
```
- **Pro:** todo en una pantalla, sin scroll, feedback inmediato, protagonismo del avatar,
  ficha grande y siempre visible. Reutiliza componentes (GlassCard, HunterAvatar).
- **Contra:** el selector compacto muestra menos contexto por tarjeta (solo imagen+número).
- **Veredicto:** ✅ **ELEGIDA** — mejor equilibrio inmersión/eficiencia/1 sola pantalla.

### D. Selector radial / circular
- **Pro:** original.
- **Contra:** difícil de usar con 8 opciones; poco conocido.
- **Veredicto:** ❌.

---

## Visualización de stats: GRÁFICO DE RADAR

En lugar de una tarjeta de stats con barras, las **6 estadísticas del personaje se muestran
en un gráfico de radar** (tipo ficha de RPG). El proyecto **ya usa `fl_chart`** con un
`RadarChart` (`skills_radar_chart.dart`), así que se reutiliza el mismo patrón.

- **Ejes del radar (6):** Ataque · Defensa · Magia · Velocidad · Soporte · Supervivencia.
- **Forma:** polígono con relleno del color de la clase (atenuado, no fluorescente).
- **Valores:** 0-100, leídos de la BD (`stats_*`).
- **Ancho:** ocupa el ancho disponible de la ficha; altura ~180-200px.
- **Tema:** bordes gris/piedra, relleno dorado envejecido/púrpura arcano atenuado.
- El radar cambia con **fade + redibujado** al cambiar de personaje.

---

## Animaciones (discretas, medievales)
- Halo dorado envejecido detrás del avatar seleccionado (pulso suave).
- Fade + slide del panel de stats al cambiar de clase.
- Fade + escala del avatar grande al cambiar.
- Partículas mágicas muy discretas (2-3 motas) — opcional.

---

## Accesibilidad
- Texto de stats ≥ 11px, etiquetas ≥ 10px.
- Mini-barras con valores numéricos legibles.
- Contraste: `onSurfaceVariant` (no alpha < 0.5).
- Áreas táctiles del selector ≥ 44px.
