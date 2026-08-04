# 04 — Plan de Implementación

> **Ruta:** `Docs/UX_Audits/CharacterCreation/04_Implementation_Plan.md`
> **Estado:** PROPUESTA — pendiente de aprobación

---

## Fases

### Fase 1 — Datos (stats en BD y modelo)
1. Migración `supabase/migrations/20260804_hunter_stats.sql`:
   - 6 columnas `stats_*` (int 0-100) en `hunter_classes`.
   - `UPDATE` con valores coherentes por clase (ataque/defensa/magia/velocidad/soporte/
     supervivencia).
2. `HunterClassData`: añadir 6 campos `stats*` + `fromMap` con defaults + fallback
   estático con valores por clase.

### Fase 2 — Tema medieval (tokens de color)
3. Añadir a `AppColors` (o reutilizar existentes) tokens medievales sin fluorescentes:
   - `iron`, `stone`, `darkWood`, `agedGold` (dorado envejecido), `arcanePurple`,
     `magicBlue`, `bloodRed`. Sin cambiar tokens existentes usados por otras pantallas
     (evitar romper coherencia del resto de la app).
   - Alternativa: reutilizar `royalGold`, `runeViolet`, `crimsonRed`, `surface*`
     atenuados — menor riesgo.

### Fase 3 — Nuevo layout del wizard
4. Reescribir `character_creation_wizard.dart`:
   - Eliminar nombre.
   - Avatar grande protagonista (fade+escala+halo).
   - Selector horizontal compacto (mini-tarjetas).
   - **Ficha RPG grande de ancho completo con GRÁFICO DE RADAR de 6 stats**
     (`fl_chart` RadarChart, patrón de `skills_radar_chart.dart`).
   - Botón continuar.
5. Mantener persistencia (`CharacterCreationData`) sin cambios.

### Fase 4 — Validación
6. `flutter analyze` (0 errores).
7. `flutter test` (73/73).
8. `flutter build apk --debug`.
9. Revisión de accesibilidad (tamaños, contraste).

---

## Criterios de aceptación
- El carrusel no queda abajo; todo cabe en una pantalla (idealmente sin scroll).
- El panel de stats es grande, de ancho completo, visible al cambiar de clase y muestra
  las **6 stats en un gráfico de radar** (fl_chart).
- Tema medieval: sin cian fluorescente, sin glow moderno.
- Sin campo de nombre.
- Persistencia intacta.
- 0 errores analyze, 73/73 tests, build OK.

---

## Riesgos
- Romper el layout en pantallas muy pequeñas → usar `SingleChildScrollView` como fallback.
- La migración de stats no aplicada en la BD live → defaults seguros (50 o por clase) en
  el modelo.

---

## Estado de implementación (2026-08-04) — ✅ IMPLEMENTADO
- Fase 1: migración `20260804_hunter_stats.sql` creada + `HunterClassData` con 6 stats
  (`stats_attack/defense/magic/speed/support/survival`, 0-100) + `fromMap` + fallback.
- Fase 2: tokens medievales en `AppColors` (`medievalBg`, `medievalIron`, `medievalStone`,
  `medievalAgedGold*`, `medievalText*`, etc.). Sin romper tokens existentes.
- Fase 3: wizard reescrito — avatar protagonista con halo (AnimatedSwitcher fade+escala),
  selector horizontal compacto de mini-tarjetas (scroll auto-centrado), ficha RPG de ancho
  completo con **gráfico de radar** (`ClassStatsRadar`, fl_chart, 6 ejes), sin campo nombre.
- i18n: 6 claves `character_stat_*` en en/es/pt.
- Validación: 0 errores analyze · 73/73 tests · APK OK.
- Pendiente BD: aplicar `supabase/migrations/20260804_hunter_stats.sql` (los defaults 50
  aplican hasta entonces).
