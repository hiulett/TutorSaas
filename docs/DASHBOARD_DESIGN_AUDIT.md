# DASHBOARD_DESIGN_AUDIT.md — Auditoría y Unificación del Dashboard

> Fuente de verdad visual: `PlantillaHtml/hunter_control_center_dashboard/code.html` (Design System oficial).
> Fecha: 2026-07-31 · Equipo: Lead UI · Senior UX · Design System Architect · Flutter Expert.
> Objetivo: que el Dashboard parezca diseñado desde cero con el estilo oficial (no una mezcla).

---

## 1. Resumen Ejecutivo

El Dashboard ya fue **migrado en tipografía y color** (Fase MV-01..08: 0 refs `orbitron`/`hankenGrotesk`, 0 hex fuera de AppColors). Sin embargo, la **estructura de información y la jerarquía** aún no reflejan el Design System de la plantilla `hunter_control_center_dashboard`.

**Hallazgo central:** la plantilla es **minimalista y orientada a la siguiente acción** (Urgent Quest → Active Quests → BottomNav). El Dashboard actual **sobrecarga** el tab MAZMORRAS con 8+ secciones (HUD, accesos, hero, sala de voz, roadmap, historial, misiones, logros, fluidez), compitiendo por la atención y duplicando métricas que ya viven en el tab ESTADO.

**Decisión de diseño:** reordenar por jerarquía, fusionar redundancias, y dar al tab MAZMORRAS la claridad de "¿qué hago ahora?" de la plantilla.

---

## 2. Estado Actual del Dashboard

| Sección (tab MAZMORRAS) | Líneas aprox. | Valor | Problema |
|---|---|---|---|
| HUD central (`HunterHudHeader`) | ~180 | Alto | ✅ ya alineado (mana, XP, racha, título) |
| Accesos rápidos (5) | ~60 | Medio | Mapa/Tienda/Oráculo/Rango/Diaria — útil, ok |
| Hero "Siguiente Lección" | ~50 | **Alto** | CTA principal — debe dominar |
| Sala de Chat de Voz | ~75 | Bajo | Compite con el hero; el Guild ya está en nav |
| Roadmap A1-C2 | widget | Alto | Progresión visible |
| Historial de Lecciones | widget | Medio | **Redundante con Roadmap** (ver §7) |
| Mission Board | widget | Alto | Motor de misiones |
| Mis Logros | ~170 | Medio | **Redundante con tab ESTADO** |
| Fluidez & Latencia | ~120 | Medio | **Redundante con tab ESTADO** |

| Sección (tab ESTADO) | Valor |
|---|---|
| Perfil + XP/racha/nivel | Alto |
| Weekly practice | Medio |
| SRS review | Alto |

---

## 3. Componentes analizados

1. Menú inferior de navegación.
2. Tarjeta "Siguiente Paso" (hero).
3. Tarjeta "Sala de Chat de Voz".
4. Historial de Lecciones.
5. Tarjetas "Mis Logros".
6. Tarjetas de Estadísticas (fluidez/latencia).
7. Evolución de Fluidez (chart).
8. Radar Holográfico.
9. Consistencia de Prácticas.

---

## 4. Componentes fuera del Design System

Tras la migración de color/fuente (MV-01..08), **ningún componente usa tipografías o colores del diseño antiguo**. Lo que aún NO cumple el DS es la **estructura**:

| Componente | Incumplimiento |
|---|---|
| BottomNav | El activo usa "pill" (radio 16, glow); la plantilla usa **borde superior 4px cyan + barra inferior** (`border-t-4`, `bg-primary-container/20`) |
| Hero "Siguiente Paso" | Sin el tratamiento "URGENT QUEST" (borde dorado, runas ※, badge de rango) |
| Sala de Voz | Compite con el hero; la plantilla no lo tiene en el flujo principal |
| Estadísticas | La plantilla NO muestra charts en el flujo principal — viven en detalle |

---

## 5. Comparación con la Plantilla HTML

### Design System oficial (`hunter_control_center_dashboard`)
- **TopAppBar**: avatar + `LVL 12` + `PLAYER` · **MP bar segmentada** (8 segmentos, `mana-bar-segment`) · streak `7 DAYS CLEAR` · **badge de rango** `B1` (borde dorado).
- **Urgent Quest Card** (`system-window-gold`): borde dorado + glow, runas `※` pulsantes, título `URGENT QUEST`, **badge de rango letra** (`A`), descripción con `border-l-2`, botón `ENTER GATEWAY BATTLE`.
- **Active Quests**: lista de quests con badge tipo (`DAILY`/`WEEKLY`) + barra fina (h-1) con glow.
- **BottomNav**: 3 items (DUNGEONS/GUILD/STATUS), activo con `border-t-4` cyan + `bg-primary-container/20`, label-caps.
- **Scanlines**: overlay CRT sutil (opción de ambientación).

### Contraste con el Dashboard actual
| Aspecto | Plantilla | Dashboard actual | Decisión |
|---|---|---|---|
| Siguiente acción | Urgent Quest al tope, inconfundible | Hero + sala de voz + accesos compiten | **Hero domina**; sala de voz se reduce |
| Métricas | Solo MP + streak + rango en barra | 2 charts + 2 stat cards en tab principal | **Mover al tab ESTADO** |
| Nav | Borde superior + barra inferior | Pill con glow | **Alinear a la plantilla** |

---

## 6. Inconsistencias visuales detectadas

1. **BottomNav**: el estilo "pill" activo no coincide con el `border-t-4` de la plantilla.
2. **Hero**: no tiene el framing "URGENT QUEST" (dorado + runas + badge rango).
3. **Radar/Heatmap/Charts**: estilos de gráfico propios (fl_chart) sin equivalencia en la plantilla → mantener pero **solo en tab ESTADO**.
4. **Sala de voz**: usa `Colors.redAccent` (Material) para "EN VIVO" → reemplazar por token (`alertRed`/`crimsonRed`).
5. **Redundancia de métricas**: XP/racha/nivel en HUD + hero + tab ESTADO → el HUD es la fuente; el hero no repite racha.

---

## 7. Redundancias funcionales

### 📍 CASO ESPECÍFICO: Roadmap A1-C2 vs Historial de Lecciones
**Análisis:**
- **Roadmap A1-C2** (`LearningPathRoadmap`): muestra la **progresión por nivel** (dónde estás, qué sigue). Valor alto de motivación.
- **Historial** (`CompletedLessonsHistoryList` con `completedLessons: []`): hoy está **vacío** (lista hardcodeada vacía) → **cero valor real**.

**Conclusión:** el Historial es un componente **muerto** (recibe `[]`). Debe **eliminarse del flujo principal** o fusionarse dentro del Roadmap (mostrar el último hito completado dentro de la progresión). Recomendación: **eliminar del tab MAZMORRAS**; el Roadmap ya comunica el progreso.

### Otras redundancias
- **Achievements + Fluidez** (tab MAZMORRAS) duplican el tab ESTADO → **mover al tab ESTADO** (o eliminar del principal).
- **XP/racha/nivel**: 3 fuentes (HUD, hero, ESTADO) → **el HUD es la única en el principal**.
- **Accesos rápidos vs nav**: "MAZMORRAS" del quick access duplica el tab actual → eliminar ese acceso (quedan Tienda/Oráculo/Rango/Diaria).

---

## 8. Recomendaciones de simplificación

| Acción | Componente | Justificación |
|---|---|---|
| **Eliminar del principal** | Historial de lecciones (vacío) | Cero valor; el Roadmap ya muestra progreso |
| **Mover al tab ESTADO** | Mis Logros + Fluidez + Radar | La plantilla no los muestra en el flujo principal |
| **Reducir** | Sala de Voz → banner compacto | No debe competir con el hero |
| **Quitar** | Acceso rápido "MAZMORRAS" | Duplica el tab actual |
| **Alinear** | BottomNav | Estilo `border-t-4` de la plantilla |
| **Framing** | Hero como "URGENT QUEST" | Dominancia de la siguiente acción |

---

## 9. Nuevo orden jerárquico del Dashboard (tab MAZMORRAS)

1. **HUD** (mana, XP, racha, rango) — estado global.
2. **Hero "SIGUIENTE RAID"** (framing URGENT QUEST: dorado + runa + badge CEFR + CTA) — **la acción principal**.
3. **Accesos rápidos** (Tienda/Oráculo/Rango/Diaria) — acciones secundarias.
4. **Mission Board** — misiones activas (equivalente a "Active Quests" de la plantilla).
5. **Roadmap A1-C2** — progresión (bajo las misiones, como contexto).
6. *(Eliminado)* sala de voz a banner compacto / logros / fluidez / historial.

**Regla UX:** en 3 segundos, el usuario sabe que su siguiente acción es el botón del hero.

---

## 10. Plan de migración visual

### Tareas (ordenadas para minimizar retrabajo)
| # | Tarea | Prioridad | Complejidad | Impacto | Dependencias |
|---|---|---|---|---|---|
| D-01 | Alinear BottomNav a la plantilla (border-t-4) | Alta | Baja | Medio | — |
| D-02 | Framing del hero como "SIGUIENTE RAID" (URGENT QUEST) | **Crítica** | Media | **Alto** | — |
| D-03 | Quitar acceso rápido "MAZMORRAS" | Media | Baja | Bajo | — |
| D-04 | Reducir sala de voz a banner compacto | Media | Baja | Medio | — |
| D-05 | Eliminar historial (vacío) del principal | Media | Baja | Bajo | — |
| D-06 | Mover logros + fluidez al tab ESTADO | Alta | Media | **Alto** | REF-01 |
| D-07 | Token de "EN VIVO" (redAccent → crimsonRed) | Baja | Baja | Bajo | — |

### Widgets reutilizables (a usar)
`GlassCard` (borde/grow/rúnico), `SegmentedBar`, `AnimatedCounter`, `FloatingReward`, `RunicButton`, `AppSpacing`, `AppTypography`, `AppColors`.

---

## 11. Plan de refactorización

1. **D-01**: reescribir `_buildNavItem` con estilo plantilla (borde superior + barra inferior).
2. **D-02**: envolver el hero en `GlassCard` con `borderColor: royalGold`, `showRunicCorners`, y badge CEFR.
3. **D-03**: quitar el item "MAZMORRAS" del `_buildQuickAccess` row.
4. **D-04**: convertir la sala de voz en una fila compacta (icono + "GUILD EN VIVO" + chevron).
5. **D-05**: quitar `CompletedLessonsHistoryList` del flujo principal.
6. **D-06**: dejar logros/fluidez solo en `_ProgressTabView` (ya están ahí) → quitar del principal.
7. **D-07**: `Colors.redAccent` → `AppColors.crimsonRed`.

**Regla:** mantener lógica de negocio intacta; solo reordenar/reducir presentación.

---

## 12. Checklist de validación

- [ ] `flutter analyze` 0 errores.
- [ ] `flutter test` 13/13.
- [ ] `flutter build apk --debug` OK.
- [ ] Nav activo con borde superior cyan (plantilla).
- [ ] Hero domina visualmente (framing URGENT).
- [ ] 0 refs `Colors.redAccent` en dashboard.
- [ ] Tab MAZMORRAS: HUD → Hero → Accesos → Misiones → Roadmap.
- [ ] Sin duplicación de XP/racha/nivel en el principal.
- [ ] Sin historial vacío en el principal.

---

## 13. Conclusiones

El Dashboard ya cumple la **capa visual** del Design System (tipografía/color). La unificación real requiere corregir la **jerarquía y la redundancia**: la plantilla prioriza la siguiente acción (URGENT QUEST → ACTIVE QUESTS), mientras el Dashboard actual dispersa la atención en 8+ secciones.

La implementación de D-01..D-07 convertirá el tab MAZMORRAS en un flujo claro: **estado → siguiente acción → acciones secundarias → misiones → progresión**, con el tab ESTADO como destino de métricas avanzadas. Resultado: un Dashboard que parece diseñado desde cero con el lenguaje oficial.

---

## 14. Estado de implementación (2026-07-31)

| Tarea | Estado | Nota |
|---|---|---|
| D-01 Nav alineado (border-t-4 cyan) | ✅ | Estilo plantilla aplicado |
| D-02 Hero framing "SIGUIENTE RAID" | ✅ | Etiqueta + runas + badge CEFR + GlassCard dorado |
| D-03 Quitar acceso "MAZMORRAS" | ⛔ Descartado | Va a /dungeon-map (mapa real, no duplica el feed) |
| D-04 Sala de voz compacta | ⬜ | Banner actual ya es compacto; se mantiene |
| D-05 Eliminar historial vacío | ✅ | Fuera del flujo principal |
| D-06 Mover logros/fluidez/radar/heatmap | ✅ | `_buildAdvancedAnalysis()` en tab ESTADO; charts ya no huérfanos |
| D-07 redAccent → crimsonRed | ✅ | 0 refs en dashboard |

**Verificación:** `flutter analyze` 0 errores (66 infos) · `flutter test` 13/13 · build apk OK.

**Dashboard (tab MAZMORRAS) ahora:** HUD → SIGUIENTE RAID (hero con framing) → accesos rápidos → sala de voz → roadmap → mission board. **Sin historial vacío ni métricas duplicadas.** El tab ESTADO concentra perfil + práctica + SRS + análisis avanzado.
