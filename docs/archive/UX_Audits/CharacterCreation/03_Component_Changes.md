# 03 — Cambios de Componentes

> **Ruta:** `Docs/UX_Audits/CharacterCreation/03_Component_Changes.md`
> **Estado:** PROPUESTA — pendiente de aprobación

---

## Componentes a modificar

### 1. `lib/features/onboarding/presentation/widgets/character_creation_wizard.dart`
Reescritura del layout:
- Eliminar campo de nombre (`_nameController` y bloque).
- Reordenar: avatar grande → selector compacto → ficha RPG → botón.
- Quitar `SingleChildScrollView` (o mantenerlo solo como fallback en pantallas muy
  pequeñas; el objetivo es que quepa en una pantalla).
- Usar `Column` + `Expanded` en lugar de apilar todo con scroll.

### 2. `HunterClassData` (`lib/features/onboarding/domain/models/hunter_class_data.dart`)
Añadir campos de stats:
- `statsAttack`, `statsDefense`, `statsMagic`, `statsSpeed`, `statsSupport`, `statsSurvival`
  (int 0-100), con `fromMap` leyendo `stats_attack` etc. y defaults.
- Getters de conveniencia si aplica.

### 3. Tabla `hunter_classes` (migración nueva `20260804_hunter_stats.sql`)
```sql
ALTER TABLE public.hunter_classes
  ADD COLUMN IF NOT EXISTS stats_attack int DEFAULT 50,
  ADD COLUMN IF NOT EXISTS stats_defense int DEFAULT 50,
  ADD COLUMN IF NOT EXISTS stats_magic int DEFAULT 50,
  ADD COLUMN IF NOT EXISTS stats_speed int DEFAULT 50,
  ADD COLUMN IF NOT EXISTS stats_support int DEFAULT 50,
  ADD COLUMN IF NOT EXISTS stats_survival int DEFAULT 50;
-- + UPDATE por clase con valores coherentes con el rol
```

### 4. Provider `hunterClassesProvider` — sin cambios de lógica
El `fromMap` leerá las nuevas columnas; si la BD aún no las tiene (migración no aplicada),
los defaults aplican. Fallback estático también se actualizará con stats por clase.

---

## Nuevo widget: Radar de stats de clase

**Patrón reutilizado:** `fl_chart` + `RadarChart` (como `skills_radar_chart.dart`).

Nuevo widget local en el wizard (o reutilizable en `core/widgets/`):
- `ClassStatsRadar` — `RadarChart` de 6 ejes (Ataque, Defensa, Magia, Velocidad, Soporte,
  Supervivencia) con `RadarDataSet` coloreado con el color de la clase (atenuado).
- Recibe `HunterClassData` y devuelve el gráfico dentro de la ficha RPG.
- Altura ~180-200px, ancho completo.

---

## Componentes reutilizados (no duplicar)
- `GlassCard` — ficha RPG y mini-tarjetas.
- `HunterAvatar` — avatar grande y miniaturas.
- `RunicButton` — botón continuar.
- `AppRadius`, `AppTypography`, `AppColors` (nuevos tokens medievales).
- `HunterClassData` / `hunterClassesProvider` — persistencia ya existente (sin tocar).

---

## Persistencia (NO modificar lógica)
- `CharacterCreationData` sigue devolviendo `playerClass` + `avatarIndex`.
- El onboarding persiste `character_class` y `avatar_index` en `user_language_profiles`
  (ya implementado, no se toca).
