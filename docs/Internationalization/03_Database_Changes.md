# Cambios de Base de Datos para Internacionalización

> Documento técnico. Complementa `docs/Internationalization/01_Current_Audit.md` y `02_Architecture.md`.
> No modifica código ni aplica DDL: contiene la **migración propuesta** y el **mapeo verificado** de campos.

---

## 1. Estado verificado de la base de datos

### 1.1 Tabla `public.user_settings`

Definición original en `supabase/migrations/20260717000000_init.sql` (líneas 18-28):

| Columna | Tipo | Default | Notas |
|---|---|---|---|
| `id` | UUID | `gen_random_uuid()` | PK |
| `user_id` | UUID | — | FK → `users(id)` ON DELETE CASCADE · `UNIQUE(user_id)` |
| `correction_style` | VARCHAR(20) | `'balanced'` | — |
| `tutor_personality` | VARCHAR(50) | `'friendly'` | — |
| `tutor_voice_id` | VARCHAR(100) | NULL | — |
| `daily_goal_minutes` | INTEGER | `15` | — |
| `notifications_enabled` | BOOLEAN | `TRUE` | — |
| `notification_time` | TIME | `'09:00'` | — |

Columnas de idioma añadidas por la migración `20260730_SQL_EDITOR_pendientes.sql` (PARTE A, líneas 23-30):

| Columna | Tipo | Default | Comentario |
|---|---|---|---|
| `ui_language` | VARCHAR(10) | `'es'` | Idioma de la interfaz (UI) de la app |
| `learning_language` | VARCHAR(10) | `'en'` | Idioma que se está aprendiendo (target) |
| `ai_explanations_native` | BOOLEAN | `TRUE` | Explicaciones de la IA en idioma nativo |

### 1.2 Tabla `public.users`

`native_language` **ya existe** desde `20260717000000_init.sql` (línea 10):

| Columna | Tipo | Default | Notas |
|---|---|---|---|
| `native_language` | VARCHAR(10) | `'es'` | `NOT NULL` |

> ⚠️ Dato clave: `native_language` vive en `users`, **no** en `user_settings`. El mapping del modelo (sección 3) debe reflejarlo.

### 1.3 Brecha detectada

- **No existe** `follow_device_language` en ninguna tabla (confirmado en `01_Current_Audit.md`, brecha G2).
- La política RLS actual es `user_settings_self` (`auth.uid() = user_id`), que ya cubre SELECT e INSERT — suficiente para la sincronización descendente (brecha G3).

---

## 2. Migración propuesta (idempotente)

Nueva migración sugerida: `supabase/migrations/20260802_add_follow_device_language.sql`.

```sql
-- ============================================================================
-- TutorSaas — Internacionalización: follow_device_language
-- Añade el flag de "seguir idioma del dispositivo" a user_settings.
-- Idempotente: puede ejecutarse varias veces sin error.
-- ============================================================================

-- 2.1. user_settings.follow_device_language
ALTER TABLE public.user_settings
    ADD COLUMN IF NOT EXISTS follow_device_language BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN public.user_settings.follow_device_language
    IS 'Si TRUE, la UI sigue al idioma del dispositivo en cada arranque, ignorando ui_language guardado.';

-- 2.2. Verificación defensiva de native_language en users (ya existe; idempotente por si un entorno lo pierde)
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS native_language VARCHAR(10) NOT NULL DEFAULT 'es';

COMMENT ON COLUMN public.users.native_language
    IS 'Idioma nativo del usuario (código ISO 639-1, p.ej. es/en/pt).';

-- 2.3. Índice de respaldo (ya garantizado por UNIQUE(user_id); se mantiene por claridad, no duplicar)
--       No se crea índice adicional: UNIQUE(user_id) ya cubre el fetch por user_id.
```

### Notas de aplicación

- **La DB live rechaza DDL** vía cliente ("read-only transaction"): aplicar **desde el SQL Editor** del dashboard, igual que la PARTE A de `20260730_SQL_EDITOR_pendientes.sql`. Proyecto: `sipiumfdpvnszthykyog`.
- No es necesario tocar RLS: la política `user_settings_self` (`FOR ALL` / `user_settings_self` consolidada) ya permite el `select` por `user_id = auth.uid()` que necesita la sincronización descendente.

---

## 3. Mapeo verificado de los 4 campos del prompt

| Campo conceptual | Tabla.Columna | Tipo | Estado | Origen |
|---|---|---|---|---|
| `interface_language` | `user_settings.ui_language` | VARCHAR(10) | ✅ existe | migración 20260730 (PARTE A) |
| `native_language` | `users.native_language` | VARCHAR(10) | ✅ existe | `20260717000000_init.sql:10` |
| `learning_language` | `user_settings.learning_language` | VARCHAR(10) | ✅ existe | migración 20260730 (PARTE A) |
| `follow_device_language` | `user_settings.follow_device_language` | BOOLEAN | ❌ **nuevo** | esta migración |

### Correspondencia con el modelo Dart

| Modelo (`UserLanguageSettings`) | Columna DB | SharedPreferences |
|---|---|---|
| `uiLanguage` | `user_settings.ui_language` | `ui_language` |
| `learningLanguage` | `user_settings.learning_language` | `learning_language` |
| `aiExplanationsInNative` | `user_settings.ai_explanations_native` | `ai_explanations_native` |
| `followDeviceLanguage` *(nuevo)* | `user_settings.follow_device_language` | `follow_device_language` |

> `native_language` (idioma del usuario, no de la UI) se gestiona por separado en `users.native_language` y se edita en `profile_edit_screen.dart` / onboarding; **no entra en `user_settings`** para no duplicar la fuente de verdad. Ver `onboarding_repository_impl.dart:35` y `dashboard_repository_impl.dart:683,780`.

---

## 4. Querys de verificación

Después de aplicar la migración:

```sql
-- 4.1. Columnas de idioma en user_settings (deben aparecer los 3 + follow_device_language)
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_settings'
  AND column_name IN ('ui_language','learning_language','ai_explanations_native','follow_device_language')
ORDER BY ordinal_position;

-- 4.2. native_language en users
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'users'
  AND column_name = 'native_language';

-- 4.3. Política RLS vigente (debe permitir SELECT/INSERT con auth.uid() = user_id)
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_settings';
```

Resultado esperado de 4.1:

| column_name | data_type | column_default |
|---|---|---|
| `ui_language` | character varying(10) | `'es'::character varying` |
| `learning_language` | character varying(10) | `'en'::character varying` |
| `ai_explanations_native` | boolean | `true` |
| `follow_device_language` | boolean | `true` |

---

## 5. Consideraciones de consistencia

1. **Default `TRUE` para `follow_device_language`**: alineado con la arquitectura objetivo (detección automática en el primer inicio, sección 1 de `02_Architecture.md`).
2. **`NOT NULL` + default**: evita filas con NULL que romperían la lectura en Dart (`prefs.getBool` no acepta NULL para el nuevo flag sin manejo).
3. **No sobrescribir `ui_language`** cuando el flag está activo: la detección es en memoria para la sesión (regla 3.3 de `02_Architecture.md`).
4. **Upsert sin conflicto**: `UNIQUE(user_id)` hace que el `upsert` de `UserLanguageNotifier._persistToSupabase` sea seguro; tras añadir el flag, el upsert debe incluir los 4 campos (ver `05_Flutter_Implementation.md`, sección 5).
5. **Idiomas del catálogo** (`languages`): la tabla `languages` soporta `en/fr/de/it` como idiomas de aprendizaje; el selector de UI se limita a `es/en/pt` (los que tienen ARB). La migración no toca `languages`.
