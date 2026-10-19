# 05 — Impacto en Base de Datos — Simplificación del Onboarding

> Proyecto: TutorSaas · Fecha: 2026-08-02
> Estado: documentación de cambios ya realizados (verificados contra código, sin modificar código)
> Archivo clave: `lib/features/onboarding/presentation/screens/onboarding_screen.dart` → `_completeOnboardingAndPurchase()`

---

## 1. Resumen

La simplificación no cambia el schema de la base de datos: **no se requiere ninguna migración**, todos los campos que el onboarding persiste ya existían. El único cambio es **qué se escribe en la persistencia**: ya no se fuerza el idioma de la interfaz (`ui_language`) al idioma nativo al completar el onboarding.

## 2. Qué se ELIMINA de la persistencia

| Dato | Antes | Después |
|---|---|---|
| `setUiLanguage(nativo)` | Se forzaba el idioma de la interfaz al idioma nativo del usuario al completar el onboarding | **Eliminado.** La interfaz sigue al dispositivo (`follow_device_language = true`); el usuario lo cambia desde Configuración |

Motivo: el onboarding deja de imponer el idioma de la UI. La preferencia de idioma de la interfaz se maneja ahora por el dispositivo por defecto y es configurable únicamente en Settings (ver `settings_screen.dart:1341`).

Evidencia en `onboarding_screen.dart:163-238`: el bloque `_completeOnboardingAndPurchase()` ya **no contiene** ninguna llamada a `setUiLanguage(...)`. Se mantiene `setLearningLanguage(...)` (líneas 188 y 223).

## 3. Qué se MANTIENE en la persistencia

El guardado final (`_completeOnboardingAndPurchase`, onboarding_screen.dart:163-238) conserva:

| # | Dato | Destino (tabla.columna) | Evidencia |
|---|---|---|---|
| 1 | Idioma nativo | `users.native_language` (vía `updateUserProfile` con `nativeLanguage`) | onboarding_screen.dart:209-215 |
| 2 | Idioma de aprendizaje (target) | `user_language_profiles` / `user_settings.learning_language` (vía `setLearningLanguage`) | onboarding_screen.dart:188, 223 |
| 3 | País de origen | `users.country_code` | onboarding_screen.dart:193-195 |
| 4 | Rango del juego | `user_language_profiles.game_rank` | onboarding_screen.dart:201 |
| 5 | Clase del personaje | `user_language_profiles.character_class` (default `'warrior'`) | onboarding_screen.dart:202 |
| 6 | Índice de avatar | `user_language_profiles.avatar_index` | onboarding_screen.dart:203 |
| 7 | Perfil (displayName/avatarUrl) | `users.display_name`, `users.avatar_url` (vía `updateUserProfile`) | onboarding_screen.dart:209-215 |
| 8 | Explicaciones IA en nativo | `user_settings.ai_explanations_native` (vía `setAiExplanationsInNative`) | onboarding_screen.dart:189-190 |
| 9 | CEFR / rango Oráculo | `user_language_profiles.cefr_level_id` / `game_rank` (resultado de `/oracle-test`) | onboarding_screen.dart:171-185 |

Además, los datos de la evaluación del Oráculo ya se persisten desde `OracleConversationScreen` en `user_language_profiles` (columnas `placement_*`), sin cambios en esta simplificación.

## 4. Columnas finales por tabla

### `users`
`id`, `email`, `display_name`, `avatar_url`, `native_language`, `country_code`, `created_at`, `updated_at`, `last_active_at`, `is_active`, `timezone`

### `user_settings`
`id`, `user_id`, `correction_style`, `tutor_personality`, `tutor_voice_id`, `daily_goal_minutes`, `notifications_enabled`, `notification_time`, `ui_language`, `learning_language`, `ai_explanations_native`, `follow_device_language`

### `user_language_profiles`
`id`, `user_id`, `language_id`, `cefr_level_id`, `xp_points`, `current_streak`, `longest_streak`, `last_practice_date`, `total_minutes`, `created_at`, `game_rank`, `placement_scores`, `placement_strengths`, `placement_weaknesses`, `placement_explanation`, `placement_recommended_focus`, `placement_assessed_at`, `character_class`, `avatar_index`

## 5. Schema: sin migraciones necesarias

| Campo | Migración origen |
|---|---|
| `users.native_language` | `20260717000000_init.sql` / `20260731_i18n_follow_device.sql` |
| `users.country_code` | `20260730_phase2_country_code.sql` |
| `user_settings.ui_language`, `learning_language` | `20260730_SQL_EDITOR_pendientes.sql` |
| `user_settings.ai_explanations_native`, `follow_device_language` | `20260731_i18n_follow_device.sql` |
| `user_language_profiles.game_rank`, `placement_*` | `20260731_onboarding_revamp.sql` |
| `user_language_profiles.character_class`, `avatar_index` | `20260731_onboarding_character.sql` |

**Conclusión:** todos los campos ya existen; el cambio es 100% de lógica de cliente. No se elimina ni agrega columna alguna.
