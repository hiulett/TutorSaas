# Base de Datos — Esquema Supabase

## Convenciones

- **Naming:** `snake_case` para tablas, columnas e índices
- **Timestamps:** `TIMESTAMPTZ` con `DEFAULT NOW()`
- **IDs:** `UUID` con `gen_random_uuid()` excepto tablas de referencia (SERIAL)
- **Relaciones:** Foreign keys explícitas con `ON DELETE CASCADE/SET NULL/RESTRICT`
- **RLS:** Row Level Security activo en todas las tablas públicas

## Tablas

### `users`
Sincronizada automáticamente desde `auth.users` via trigger `handle_new_user()`.

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | `gen_random_uuid()` | FK = `auth.users.id` |
| `email` | VARCHAR(255) | — | UNIQUE, NOT NULL |
| `display_name` | VARCHAR(100) | — | Público, editable |
| `avatar_url` | TEXT | — | URL de foto de perfil |
| `native_language` | VARCHAR(10) | `'es'` | Idioma nativo |
| `created_at` | TIMESTAMPTZ | `NOW()` | — |
| `updated_at` | TIMESTAMPTZ | `NOW()` | — |
| `last_active_at` | TIMESTAMPTZ | — | Última actividad |
| `is_active` | BOOLEAN | `TRUE` | Soft-delete |
| `timezone` | VARCHAR(50) | `'UTC'` | Zona horaria |

### `user_settings`
1:1 con users. Creada automáticamente por `handle_new_user()`.

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | `gen_random_uuid()` | — |
| `user_id` | UUID FK | — | `REFERENCES users(id) ON DELETE CASCADE`, UNIQUE |
| `correction_style` | VARCHAR(20) | `'balanced'` | `gentle`, `balanced`, `strict` |
| `tutor_personality` | VARCHAR(50) | `'friendly'` | Personalidad del tutor IA |
| `tutor_voice_id` | VARCHAR(100) | — | Voz TTS preferida |
| `daily_goal_minutes` | INTEGER | `15` | Meta diaria en minutos |
| `notifications_enabled` | BOOLEAN | `TRUE` | Notificaciones push |
| `notification_time` | TIME | `'09:00'` | Hora de notificación |

### `languages`
Catálogo de idiomas disponibles.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | SERIAL PK | — |
| `code` | VARCHAR(10) UNIQUE | `'en'`, `'es'`, `'fr'`, `'de'`, `'it'` |
| `name` | VARCHAR(100) | Nombre en inglés |
| `native_name` | VARCHAR(100) | Nombre en idioma nativo |
| `flag_emoji` | VARCHAR(10) | Emoji de bandera |
| `is_active` | BOOLEAN DEFAULT TRUE | — |

### `cefr_levels`
Niveles del Marco Común Europeo de Referencia.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | SERIAL PK | — |
| `code` | VARCHAR(5) UNIQUE | `'A1'`, `'A2'`, `'B1'`, `'B2'`, `'C1'`, `'C2'` |
| `name` | VARCHAR(50) | Nombre descriptivo |
| `description` | TEXT | Descripción del nivel |
| `order_index` | INTEGER | 1-6 para ordenamiento |

### `user_language_profiles`
Perfiles de idioma por usuario (1 usuario puede tener múltiples perfiles).

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | `gen_random_uuid()` | — |
| `user_id` | UUID FK | — | `REFERENCES users(id) ON DELETE CASCADE` |
| `language_id` | INTEGER FK | — | `REFERENCES languages(id) ON DELETE RESTRICT` |
| `cefr_level_id` | INTEGER FK | — | `REFERENCES cefr_levels(id) ON DELETE RESTRICT` |
| `xp_points` | INTEGER | `0` | Experiencia acumulada |
| `current_streak` | INTEGER | `0` | Racha actual en días |
| `longest_streak` | INTEGER | `0` | Máxima racha histórica |
| `last_practice_date` | DATE | — | Última práctica |
| `total_minutes` | INTEGER | `0` | Minutos totales |
| `created_at` | TIMESTAMPTZ | `NOW()` | — |
| UNIQUE | `(user_id, language_id)` | | |

### `scenarios`
Lecciones/escenarios disponibles (15 por idioma).

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | `gen_random_uuid()` | — |
| `language_id` | INTEGER FK | — | `REFERENCES languages(id) ON DELETE CASCADE` |
| `title` | VARCHAR(200) | — | NOT NULL |
| `description` | TEXT | — | Descripción |
| `context` | TEXT | — | System prompt completo del escenario |
| `difficulty_level` | VARCHAR(5) | — | A1-C2 |
| `category` | VARCHAR(100) | — | `business`, `travel`, `daily`, `tech`, `social` |
| `estimated_minutes` | INTEGER | `10` | Duración estimada |
| `is_active` | BOOLEAN | `TRUE` | Soft-delete |
| `created_at` | TIMESTAMPTZ | `NOW()` | — |

### `scenario_objectives`
Objetivos específicos de cada escenario (~3-5 por escenario).

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | SERIAL PK | — |
| `scenario_id` | UUID FK | `REFERENCES scenarios(id) ON DELETE CASCADE` |
| `objective` | TEXT NOT NULL | Descripción del objetivo |
| `vocabulary_focus` | TEXT[] | Array de vocabulario clave |

### `conversations`
Sesiones conversacionales.

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | `gen_random_uuid()` | — |
| `user_id` | UUID FK | — | `REFERENCES users(id) ON DELETE CASCADE` |
| `language_id` | INTEGER FK | — | `REFERENCES languages(id) ON DELETE RESTRICT` |
| `scenario_id` | UUID FK | — | `REFERENCES scenarios(id) ON DELETE SET NULL` |
| `started_at` | TIMESTAMPTZ | `NOW()` | — |
| `ended_at` | TIMESTAMPTZ | — | — |
| `duration_seconds` | INTEGER | — | Duración en segundos |
| `fluency_score` | DECIMAL(5,2) | — | 0-100 |
| `pronunciation_score` | DECIMAL(5,2) | — | 0-100 |
| `grammar_score` | DECIMAL(5,2) | — | 0-100 |
| `vocabulary_score` | DECIMAL(5,2) | — | 0-100 |
| `overall_score` | DECIMAL(5,2) | — | 0-100 |
| `xp_earned` | INTEGER | `0` | XP de la sesión |
| `status` | VARCHAR(20) | `'active'` | `active`, `completed`, `abandoned` |

### `messages`
Mensajes individuales dentro de conversaciones.

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | `gen_random_uuid()` | — |
| `conversation_id` | UUID FK | — | `REFERENCES conversations(id) ON DELETE CASCADE` |
| `role` | VARCHAR(20) | — | `'user'`, `'assistant'` |
| `content_text` | TEXT NOT NULL | — | Contenido del mensaje |
| `audio_url` | TEXT | — | URL del audio (S3/Blob) |
| `audio_duration_ms` | INTEGER | — | Duración del audio |
| `tokens_used` | INTEGER | — | Tokens consumidos |
| `created_at` | TIMESTAMPTZ | `NOW()` | — |
| `sequence_number` | INTEGER NOT NULL | — | Orden en la conversación |

### `corrections`
Correcciones gramaticales asociadas a mensajes.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | UUID PK | — |
| `message_id` | UUID FK | `REFERENCES messages(id) ON DELETE CASCADE` |
| `original_text` | TEXT NOT NULL | Texto original del usuario |
| `corrected_text` | TEXT NOT NULL | Texto corregido |
| `explanation` | TEXT | Explicación de la corrección |
| `error_type` | VARCHAR(50) | `grammar`, `vocabulary`, `pronunciation` |
| `severity` | VARCHAR(20) | `minor`, `major`, `critical` |

### `pronunciation_assessments`
Evaluaciones de pronunciación por fonema.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | UUID PK | — |
| `message_id` | UUID FK | — |
| `user_id` | UUID FK | `REFERENCES users(id) ON DELETE CASCADE` |
| `target_text` | TEXT NOT NULL | Texto objetivo |
| `overall_score` | DECIMAL(5,2) | Puntaje general |
| `accuracy_score` | DECIMAL(5,2) | Precisión fonética |
| `fluency_score` | DECIMAL(5,2) | Fluidez |
| `completeness_score` | DECIMAL(5,2) | Completez |
| `prosody_score` | DECIMAL(5,2) | Prosodia |
| `phoneme_details` | JSONB | Detalle por fonema |

### `vocabulary_items`
Catálogo de vocabulario.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | UUID PK | — |
| `language_id` | INTEGER FK | `REFERENCES languages(id) ON DELETE CASCADE` |
| `word` | VARCHAR(200) NOT NULL | Palabra |
| `translation` | VARCHAR(200) | Traducción |
| `native_language` | VARCHAR(10) DEFAULT `'es'` | Idioma de traducción |
| `pronunciation_ipa` | VARCHAR(200) | IPA |
| `audio_url` | TEXT | URL de audio |
| `part_of_speech` | VARCHAR(50) | Categoría gramatical |
| `difficulty_level` | VARCHAR(5) | Nivel CEFR |
| `example_sentence` | TEXT | Oración de ejemplo |
| UNIQUE | `(language_id, word)` | |

### `user_vocabulary`
Vocabulario aprendido por usuario con algoritmo SM-2.

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | — | |
| `user_id` | UUID FK | — | `REFERENCES users(id) ON DELETE CASCADE` |
| `vocabulary_id` | UUID FK | — | `REFERENCES vocabulary_items(id) ON DELETE CASCADE` |
| `times_seen` | INTEGER | `1` | Veces visto |
| `times_correct` | INTEGER | `0` | Veces correcto |
| `ease_factor` | DECIMAL(4,2) | `2.5` | Factor de facilidad SM-2 |
| `interval_days` | INTEGER | `1` | Intervalo de repaso |
| `next_review_at` | TIMESTAMPTZ | — | Próximo repaso |
| `last_seen_at` | TIMESTAMPTZ | `NOW()` | Última vez |
| UNIQUE | `(user_id, vocabulary_id)` | | |

### `daily_stats`
Estadísticas diarias por usuario e idioma.

| Columna | Tipo | Default | Notas |
|---------|------|---------|-------|
| `id` | UUID PK | — | |
| `user_id` | UUID FK | — | |
| `language_id` | INTEGER FK | — | |
| `date` | DATE NOT NULL | — | |
| `minutes_practiced` | INTEGER | `0` | Minutos |
| `conversations_count` | INTEGER | `0` | Conversaciones |
| `words_learned` | INTEGER | `0` | Palabras nuevas |
| `xp_earned` | INTEGER | `0` | XP del día |
| `avg_fluency_score` | DECIMAL(5,2) | — | Fluidez promedio |
| UNIQUE | `(user_id, language_id, date)` | | |

### `weekly_stats`
Resumen semanal.

| Columna | Tipo | Default |
|---------|------|---------|
| `id` | UUID PK | — |
| `user_id` | UUID FK | — |
| `language_id` | INTEGER FK | — |
| `week_start` | DATE NOT NULL | — |
| `total_minutes` | INTEGER | `0` |
| `total_xp` | INTEGER | `0` |
| `conversations` | INTEGER | `0` |
| `avg_score` | DECIMAL(5,2) | — |
| UNIQUE | `(user_id, language_id, week_start)` | |

### `achievements`
Catálogo de logros.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | SERIAL PK | — |
| `code` | VARCHAR(100) UNIQUE NOT NULL | Código del logro |
| `title` | VARCHAR(200) NOT NULL | Título |
| `description` | TEXT | Descripción |
| `icon_url` | TEXT | Icono |
| `xp_reward` | INTEGER DEFAULT 0 | XP de recompensa |
| `condition_type` | VARCHAR(50) | `streak`, `conversations`, `vocabulary` |
| `condition_value` | INTEGER | Valor para desbloquear |

### `user_achievements`
Logros obtenidos por usuario.

| Columna | Tipo |
|---------|------|
| `id` | UUID PK |
| `user_id` | UUID FK |
| `achievement_id` | INTEGER FK |
| `earned_at` | TIMESTAMPTZ DEFAULT NOW() |
| UNIQUE | `(user_id, achievement_id)` |

### `daily_challenges`
Desafíos diarios por usuario.

| Columna | Tipo | Default |
|---------|------|---------|
| `id` | UUID PK | — |
| `user_id` | UUID FK | — |
| `language_id` | INTEGER FK | — |
| `date` | DATE NOT NULL | — |
| `challenge_type` | VARCHAR(50) | — |
| `target_value` | INTEGER | — |
| `current_value` | INTEGER | `0` |
| `is_completed` | BOOLEAN | `FALSE` |
| `xp_reward` | INTEGER | — |
| UNIQUE | `(user_id, language_id, date)` | |

### `subscription_plans`
Planes de suscripción disponibles.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | SERIAL PK | — |
| `name` | VARCHAR(100) NOT NULL | Nombre del plan |
| `code` | VARCHAR(50) UNIQUE NOT NULL | Código interno |
| `price_usd` | DECIMAL(10,2) | Precio en USD |
| `interval` | VARCHAR(20) | `monthly`, `yearly`, `lifetime` |
| `features` | JSONB | Características del plan |
| `is_active` | BOOLEAN DEFAULT TRUE | |

### `user_subscriptions`
Suscripciones activas de usuarios.

| Columna | Tipo | Notas |
|---------|------|-------|
| `id` | UUID PK | — |
| `user_id` | UUID FK UNIQUE | `REFERENCES users(id) ON DELETE CASCADE` |
| `plan_id` | INTEGER FK | `REFERENCES subscription_plans(id) ON DELETE RESTRICT` |
| `status` | VARCHAR(20) NOT NULL | `active`, `cancelled`, `expired` |
| `started_at` | TIMESTAMPTZ DEFAULT NOW() | — |
| `expires_at` | TIMESTAMPTZ | — |
| `cancelled_at` | TIMESTAMPTZ | — |
| `revenuecat_subscriber_id` | VARCHAR(255) | ID RevenueCat |
| `store` | VARCHAR(20) | `app_store`, `play_store`, `web` |

### `payments`
Registro de pagos.

| Columna | Tipo |
|---------|------|
| `id` | UUID PK |
| `user_id` | UUID FK |
| `subscription_id` | UUID FK |
| `amount_usd` | DECIMAL(10,2) |
| `currency` | VARCHAR(10) DEFAULT 'USD' |
| `status` | VARCHAR(20) |
| `payment_method` | VARCHAR(50) |
| `stripe_payment_id` | VARCHAR(255) |
| `created_at` | TIMESTAMPTZ DEFAULT NOW() |

### `ai_usage_logs`
Registro de uso de APIs de IA.

| Columna | Tipo | Default |
|---------|------|---------|
| `id` | UUID PK | — |
| `user_id` | UUID FK | — |
| `conversation_id` | UUID FK | — |
| `model` | VARCHAR(100) | — |
| `input_tokens` | INTEGER | — |
| `output_tokens` | INTEGER | — |
| `cost_usd` | DECIMAL(10,6) | — |
| `latency_ms` | INTEGER | — |
| `created_at` | TIMESTAMPTZ | `NOW()` |

## Índices

```sql
idx_conversations_user_id ON conversations(user_id)
idx_conversations_started_at ON conversations(started_at)
idx_messages_conversation_id ON messages(conversation_id)
idx_messages_created_at ON messages(created_at)
idx_daily_stats_user_date ON daily_stats(user_id, date)
idx_user_vocabulary_next_review ON user_vocabulary(user_id, next_review_at)
idx_ai_usage_user_date ON ai_usage_logs(user_id, created_at)
```

## Trigger: `handle_new_user()`

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name, avatar_url)
  VALUES (new.id, new.email,
    new.raw_user_meta_data->>'display_name',
    new.raw_user_meta_data->>'avatar_url');
  INSERT INTO public.user_settings (user_id) VALUES (new.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## Políticas RLS

Las políticas RLS garantizan que los usuarios solo puedan acceder a sus propios datos:

- **users**: SELECT/UPDATE own row
- **user_settings**: SELECT/UPDATE own row
- **user_language_profiles**: SELECT/INSERT/UPDATE own rows
- **conversations**: SELECT/INSERT/UPDATE own conversations
- **messages**: SELECT/INSERT on own conversation messages
- **scenarios**: SELECT for all authenticated users (catálogo público)
- **daily_stats**: SELECT/INSERT/UPDATE own stats

## Relaciones (Diagrama)

```
auth.users
  → handle_new_user() trigger
    → public.users
      → user_settings (1:1)
      → user_language_profiles (1:N)
        → languages (FK)
        → cefr_levels (FK)
      → conversations (1:N)
        → messages (1:N)
          → corrections (1:N)
          → pronunciation_assessments (1:N)
        → scenarios (FK, nullable)
      → daily_stats (1:N)
      → weekly_stats (1:N)
      → user_vocabulary (N:N)
        → vocabulary_items (FK)
      → user_achievements (N:N)
        → achievements (FK)
      → daily_challenges (1:N)
      → user_subscriptions (1:1)
        → subscription_plans (FK)
      → payments (1:N)
      → ai_usage_logs (1:N)

scenarios
  → scenario_objectives (1:N)
```

---

## Estado actual (Fases 2-11, 2026-07-30)

### Tablas a�adidas/verificadas
| Tabla | Uso | Estado |
|---|---|---|
| mission_templates/instances | Motor de misiones | ? 8 tablas + 29 plantillas |
| secret_missions, emergency_missions | Misiones IA/emergencia | ? |
| global_events, player_event_progress | Eventos | ? |
| guild_collaborative_missions, guild_quest_pool | Gremio | ? |
| eward_history | Recompensas | ? |
| player_inventory, cosmetic_catalog | Items (11 tipos + key/book/mission_modifier) | ? |
| guild_battle_pass, player_daily_state, player_streaks, player_pergaminos | Econom�a | ? |

### Columnas clave a�adidas
- user_settings: ui_language, learning_language, i_explanations_native.
- users: country_code.
- user_language_profiles: ragments, 	otal_gold, player_class, guild_role, equipped_title_code.
- player_inventory: item_effect, item_meta, source.
- mission_instances: eward_multiplier, pplied_modifier_code.
- chat_rooms: oom_type, moderator_type, ssigned_moderator_id.

### RPCs (verificados)
dd_xp, dd_gems, spend_gems, dd_fragments, increment_pergaminos_max, otate_daily_missions, check_ai_audio_quota, 	rack_ai_audio_time.

### Seguridad pendiente (QA)
- system_ai_settings RLS ? service_role (script 20260730_phase11_security_fixes.sql).
- ocabulary_items INSERT WITH CHECK (true) ? restringido.
- Revocar EXECUTE de funciones internas a anon/authenticated.
