# Auditoría Estratégica del Onboarding — Documento 07

# Cambios de Base de Datos (DB)

> **Proyecto:** TutorSaas / Dungeon of English
> **Base:** hallazgos verificados (docs 01–02, migraciones existentes) — sin modificar código
> **Alcance:** persistencia de la identidad del personaje y la tarjeta de héroe
> **Fase:** F5 del plan (doc 08)

---

## 1. Qué se persiste hoy (verificado)

### 1.1 `saveOnboardingData` — `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart`

| Tabla | Columnas que escribe | Evidencia |
|---|---|---|
| `public.users` | `id, email, display_name, native_language, updated_at` | `onboarding_repository_impl.dart:30-40` |
| `public.languages` | lookup/insert `code, name, native_name, flag_emoji` | `onboarding_repository_impl.dart:43-60` |
| `user_language_profiles` | `user_id, language_id, cefr_level_id, xp_points, current_streak` | `onboarding_repository_impl.dart:98-119` |
| `user_settings` | `user_id, daily_goal_minutes, correction_style, tutor_personality, interests, motivation` | `onboarding_repository_impl.dart:121-136` |
| `user_ai_profiles` | `user_id, pedagogical_summary, learning_style, focus_areas, tutor_prompt_instructions` | `onboarding_repository_impl.dart:138-156` |

**⚠️ El personaje no se persiste aquí.** La identidad (clase/avatar/nombre) se escribe después
en `onboarding_screen.dart:206-215` vía `updateUserProfile`:
- `display_name` ← nombre
- `avatar_url` ← **la clase** (p. ej. `'warrior'`), NO una imagen ni el avatar
- `native_language`, `bio` hardcodeado

`updateUserProfile` en `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart:776-785`
actualiza `display_name / avatar_url / native_language / bio` en `public.users`.

### 1.2 Clasificación IA — `oracle_conversation_screen.dart`

`_persistAiDetails` (`oracle_conversation_screen.dart:363-398`) escribe en
`user_language_profiles`: `game_rank, placement_scores, placement_strengths,
placement_weaknesses, placement_explanation, placement_recommended_focus, placement_assessed_at`
(columnas creadas en `supabase/migrations/20260731_onboarding_revamp.sql`).

### 1.3 Columnas ya disponibles (✓ no requieren migración)

| Dato | Columna | Tabla | Evidencia |
|---|---|---|---|
| País de origen | `country_code` | `public.users` | `onboarding_screen.dart:192-196`; migración `20260730_phase2_country_code.sql` |
| Idioma nativo | `native_language` | `public.users` | `onboarding_repository_impl.dart:35` |
| Idioma objetivo | `language_id` (FK → `languages.code`) | `user_language_profiles` | `onboarding_repository_impl.dart:102-108` |
| Rango de juego | `game_rank` | `user_language_profiles` | `20260731_onboarding_revamp.sql:8-9` |

---

## 2. Gap: qué falta persistir

| Dato | Dónde se genera | Dónde se persiste hoy | Gap |
|---|---|---|---|
| `avatar_index` (0–5) | wizard (`character_creation_wizard.dart:14,34`) | **No se persiste** | 🔴 |
| `character_class` (warrior/mage/…/necromancer) | wizard (`:14,38`) | `users.avatar_url` = clase (semántica abusada) | 🟠 |
| Elemento (fuego/arcano/…) | derivado de clase (doc 06 §2) | No existe | 🟡 |
| Aura (color) | derivado de clase | No existe | 🟡 |
| Nivel inicial (Lv. 1) | constante/derivado de CEFR | No existe (solo `xp_points=0`) | 🟡 |

**Recomendación:** mover la clase y el avatar de `users.avatar_url` a
`user_language_profiles`, que es la tabla por usuario+idioma y donde ya vive `game_rank`
(la identidad del cazador es por perfil de aprendizaje, no por cuenta).

---

## 3. Propuesta de esquema

### 3.1 Decisión de diseño: ¿`hunter_cards` o columnas en `user_language_profiles`?

| Criterio | Tabla `hunter_cards` | Columnas en `user_language_profiles` |
|---|---|---|
| Relación | 1:1 por user+language (con 1 `hunter_card` por perfil) | 1:1 natural (la fila YA existe) |
| Complejidad | Requiere crear tabla + FK + RLS + join en cada lectura | Solo 2–4 `ALTER TABLE` + leer la fila existente |
| Coherencia | La tarjeta es "presentación" del perfil; si se separa hay que sincronizar | Misma fila que `game_rank`, `placement_*` (patrón ya usado) |
| Esfuerzo | Medio-alto (nueva tabla + políticas RLS) | **Bajo** |
| Consistencia con el patrón actual | Rompe el patrón 1-fila-por-perfil | Sigue el patrón de `20260731_onboarding_revamp.sql` |

**Veredicto: columnas en `user_language_profiles`.** El modelo "tarjeta" es una proyección
de lectura (un `SELECT` de la fila), no una entidad propia. Una tabla `hunter_cards` solo
añadiría un join sin beneficio funcional hoy.

### 3.2 Columnas nuevas en `user_language_profiles`

| Columna | Tipo | Default | Descripción |
|---|---|---|---|
| `character_class` | `TEXT` | `'warrior'` | id de clase (`warrior`/`mage`/`assassin`/`knight`/`archer`/`summoner`/`paladin`/`necromancer`) |
| `avatar_index` | `INTEGER` | `0` | índice del avatar de jugador (0–5; 0–7 si se amplía) |
| `character_element` | `TEXT` | `NULL` | elemento (`fire`/`arcane`/`shadow`/`earth`/`wind`/`star`/`light`/`bone`) |
| `character_aura` | `TEXT` | `NULL` | color de aura en formato token (p. ej. `crimsonRed`) o hex `#RRGGBB` |

> `character_element` y `character_aura` son **derivables** de la clase vía catálogo en el
> cliente. Se persisten igual para permitir personalización futura (el jugador podrá cambiar
> aura/elemento sin cambiar de clase) y para que el backend / web admin pueda renderizar la
> carta sin depender del catálogo del cliente.

---

## 4. Migración SQL propuesta (idempotente)

Crear `supabase/migrations/2026XXXX_character_identity.sql` (o aplicar vía SQL Editor /
rama de desarrollo, según AGENTS.md — el proyecto live puede rechazar DDL con
"read-only transaction"):

```sql
-- ============================================================================
-- TutorSaas — Identidad del personaje (F5): clase + avatar + tarjeta de héroe
-- Idempotente. Aplicar vía SQL Editor o rama de desarrollo.
-- ============================================================================

-- 4.1 Clase del cazador (id: warrior/mage/assassin/knight/archer/summoner/paladin/necromancer)
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS character_class TEXT DEFAULT 'warrior';

-- 4.2 Índice del avatar de jugador (0–N)
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS avatar_index INTEGER DEFAULT 0;

-- 4.3 Elemento (fire/arcane/shadow/earth/wind/star/light/bone) — derivable, se persiste
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS character_element TEXT;

-- 4.4 Aura de color (token o hex) — derivable, se persiste
ALTER TABLE public.user_language_profiles
    ADD COLUMN IF NOT EXISTS character_aura TEXT;

-- ============================================================================
-- Retrocompatibilidad: backfill de jugadores existentes
-- (rogue → assassin según el mapeo del doc 06 §2.2)
-- ============================================================================
UPDATE public.user_language_profiles ulp
SET character_class = 'assassin'
WHERE ulp.character_class = 'rogue';

-- 4.5 Sync opcional: los usuarios que tenían avatar_url = clase pasan a character_class.
--     NO borrar avatar_url todavía: se mantiene como fallback para perfiles sin fila de perfil.
UPDATE public.user_language_profiles ulp
SET character_class = u.avatar_url
FROM public.users u
WHERE u.id = ulp.user_id
  AND ulp.character_class = 'warrior'        -- valor por defecto: solo donde no se ha elegido
  AND u.avatar_url IN ('warrior','mage','assassin','rogue','necromancer','priest');

-- ============================================================================
-- Verificación (debe devolver 4 filas)
-- ============================================================================
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_language_profiles'
  AND column_name IN ('character_class','avatar_index','character_element','character_aura')
ORDER BY column_name;

-- ============================================================================
-- RLS: no requiere cambios. Las políticas existentes del perfil (profiles_self /
-- SELECT/INSERT/UPDATE por user_id) cubren automáticamente las columnas nuevas.
-- ============================================================================
```

### 4.1 Consideraciones de seguridad

- **RLS:** las columnas nuevas heredan las políticas existentes de `user_language_profiles`
  (patrón ya validado en `20260731_onboarding_revamp.sql:54`). Verificar tras aplicar con
  `supabase get_advisors` para confirmar que no hay tablas sin RLS.
- **Tipo `TEXT` vs enum/CHECK:** se usa `TEXT` para los ids de clase (ya es el patrón de
  `game_rank`, y los ids pueden evolucionar). Un `CHECK` con los 8 ids es opcional y se
  puede añadir en una fase posterior si el catálogo se vuelve estable.
- **`avatar_index`:** tipo `INTEGER` con default 0 — sin FK (los assets son estáticos, no
  filas). Validar el rango en el cliente.

---

## 5. Cambios en el contrato Dart (referencia de implementación, F5)

| Capa | Cambio propuesto |
|---|---|
| `OnboardingRepository.saveOnboardingData` | añadir params opcionales `characterClass`, `avatarIndex`, `element`, `aura` |
| `onboarding_repository_impl.dart` | escribir `character_class`, `avatar_index`, `character_element`, `character_aura` en el upsert de `user_language_profiles` (`:98-119`) |
| `OnboardingScreen._completeOnboardingAndPurchase` (`:160-238`) | pasar `data.playerClass` y `data.avatarIndex` (hoy solo nombre en `updateUserProfile`) |
| `updateUserProfile` (`dashboard_repository_impl.dart:776-785`) | **dejar de usar** `avatar_url` como clase; guardar imagen real (`player_<i>.webp` o URL) cuando exista |
| `RpgAvatar` (`rpg_avatar.dart:27-28`) | resolver `avatar_index` desde `user_language_profiles` (fallback: clase/icono) |
| Perfil (HUD, `hunter_hud_header.dart:42`) | leer `avatar_url` imagen real en vez de la clase |

---

## 6. Datos ya disponibles (no requiere migración)

| Dato | Columna | Tabla | Estado |
|---|---|---|---|
| `country_code` | `country_code` | `public.users` | ✓ existe (`onboarding_screen.dart:192-196`) |
| `native_language` | `native_language` | `public.users` | ✓ existe (`onboarding_repository_impl.dart:35`) |
| `target_language` | `language_id` → `languages` | `user_language_profiles` | ✓ existe |
| `game_rank` | `game_rank` | `user_language_profiles` | ✓ existe (`20260731_onboarding_revamp.sql`) |

---

## 7. Resumen de decisiones

| # | Decisión | Detalle |
|---|---|---|
| 1 | Tabla `hunter_cards` vs columnas | **Columnas en `user_language_profiles`** (patrón 1-fila-por-perfil, sin join) |
| 2 | Columnas nuevas | `character_class TEXT DEFAULT 'warrior'`, `avatar_index INT DEFAULT 0`, `character_element TEXT`, `character_aura TEXT` |
| 3 | `avatar_url` | Deja de ser "la clase"; pasa a ser la imagen real del avatar |
| 4 | `rogue → assassin` | Backfill idempotente en la migración |
| 5 | RLS | Sin cambios (políticas existentes cubren columnas nuevas); verificar con advisors |
