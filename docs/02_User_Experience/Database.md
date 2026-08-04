# Fase 2 — Database

> Esquema y migraciones de DB relevantes para la Experiencia de Usuario.

## Tablas implicadas

### `public.users`
Perfil público. Columnas usadas: `id`, `email`, `display_name`, `native_language`,
`bio`, `updated_at`.

### `public.user_language_profiles`
Progreso por idioma. `user_id`, `language_id`, `cefr_level_id`, `xp_points`,
`current_streak`. Upsert con `onConflict: 'user_id, language_id'`.

### `public.user_settings`
Preferencias del usuario. **PENDIENTE de columnas de idioma:**

| Columna (deseada) | Tipo | Default | Estado |
|---|---|---|---|
| `ui_language` | VARCHAR(10) | 'es' | ❌ no existe |
| `learning_language` | VARCHAR(10) | 'en' | ❌ no existe |
| `ai_explanations_native` | BOOLEAN | true | ❌ no existe |

Existentes: `correction_style`, `tutor_personality`, `daily_goal_minutes`, `interests`,
`motivation`, etc.

### `public.oracle_questions` (migración `20260730_oracle_questions.sql`)
`id`, `question_text`, `order_index`, `emotion`, `language_code`, `is_active`,
`min/max_cefr_level`. RLS: SELECT para `authenticated`. **Sin consumidor en UI aún.**

### `public.cefr_levels`, `public.languages`
Catálogos; se hacen upsert desde el repo si faltan.

## Migración pendiente (propuesta)

```sql
ALTER TABLE public.user_settings
    ADD COLUMN IF NOT EXISTS ui_language VARCHAR(10) DEFAULT 'es',
    ADD COLUMN IF NOT EXISTS learning_language VARCHAR(10) DEFAULT 'en',
    ADD COLUMN IF NOT EXISTS ai_explanations_native BOOLEAN DEFAULT TRUE;
```

## Notas

- Aplicar migraciones vía SQL Editor/branch si el live rechaza DDL ("read-only transaction").
- RLS: las escrituras de `user_settings` deben permitir al propio usuario (`user_id = auth.uid()`).
