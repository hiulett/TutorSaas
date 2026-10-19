# Configuración de Supabase — TutorSaas

## Proyecto

| Propiedad | Valor |
|-----------|-------|
| **URL del Proyecto** | `https://sipiumfdpvnszthykyog.supabase.co` |
| **ID del Proyecto** | `sipiumfdpvnszthykyog` |
| **Región** | US (predeterminada) |
| **Plan** | Free (escalable a Pro) |

## Configuración de API Keys

Las claves se inyectan mediante `--dart-define` en tiempo de compilación:

```bash
flutter run --dart-define=SUPABASE_URL=https://sipiumfdpvnszthykyog.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...
```

Definidas en `lib/core/constants/api_constants.dart`:

```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://sipiumfdpvnszthykyog.supabase.co',
);
static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIs...',
);
```

Para builds de producción, usar archivo de configuración:
```bash
flutter build apk --dart-define-from-file=config.json
```

## Tablas en el Schema `public`

| Tabla | Propósito |
|-------|-----------|
| `users` | Perfiles de usuario sincronizados con auth.users |
| `user_settings` | Preferencias de usuario (1:1) |
| `languages` | Catálogo de idiomas |
| `cefr_levels` | Niveles CEFR (A1-C2) |
| `user_language_profiles` | Perfiles de idioma por usuario |
| `scenarios` | Lecciones/escenarios |
| `scenario_objectives` | Objetivos de cada escenario |
| `conversations` | Sesiones conversacionales |
| `messages` | Mensajes de conversaciones |
| `corrections` | Correcciones gramaticales |
| `pronunciation_assessments` | Evaluaciones de pronunciación |
| `vocabulary_items` | Catálogo de vocabulario |
| `user_vocabulary` | Vocabulario aprendido (SM-2) |
| `daily_stats` | Estadísticas diarias |
| `weekly_stats` | Estadísticas semanales |
| `achievements` | Catálogo de logros |
| `user_achievements` | Logros de usuarios |
| `daily_challenges` | Desafíos diarios |
| `subscription_plans` | Planes de suscripción |
| `user_subscriptions` | Suscripciones activas |
| `payments` | Registro de pagos |
| `ai_usage_logs` | Registro de uso de IA |
| `rate_limiting` | Control de límites de uso |

## Realtime

Realtime habilitado para las siguientes tablas:
- `chat_rooms` — para salas de voz grupales
- `messages` — para actualizaciones en vivo durante conversaciones

Configuración desde `supabase/migrations/20260719000002_create_chat_rooms.sql`.

## Storage

Buckets disponibles:

| Bucket | Visibilidad | Uso |
|--------|-------------|-----|
| `avatars` | Público | Fotos de perfil de usuario |
| `lesson-assets` | Público | Assets de lecciones (imágenes, audios) |

## Autenticación

### Providers Habilitados

| Provider | Estado |
|----------|--------|
| **Email/Password** | Activo |
| **Google OAuth** | Activo (configurado en Supabase Console) |

### Configuración de Google OAuth

1. Web client ID configurado en Google Cloud Console
2. Redirect URLs configuradas en Supabase Auth settings
3. `google_sign_in` package en Flutter maneja el flujo OAuth

### Trigger de Sincronización

El trigger `on_auth_user_created → handle_new_user()` sincroniza automáticamente:
1. Crea registro en `public.users` con datos de `auth.users.raw_user_meta_data`
2. Crea registro en `public.user_settings` con valores por defecto

## Migraciones

Todas las migraciones en `supabase/migrations/`:

| Migración | Propósito |
|-----------|-----------|
| `20260717000000_init.sql` | Schema inicial completo |
| `20260717000001_seed_lessons.sql` | Seed de lecciones iniciales |
| `20260717000002_rate_limiting.sql` | Tabla de rate limiting |
| `20260718000000_sync_existing.sql` | Sincronización de datos existentes |
| `20260719000000_add_onboarding_fields.sql` | Campos de onboarding |
| `20260719000001_seed_achievements.sql` | Seed de logros |
| `20260719000002_create_chat_rooms.sql` | Salas de chat + Realtime |
| `20260720000000_add_correction_level.sql` | Nivel de corrección |
| `20260721000001_fix_cefr_levels.sql` | Corrección niveles CEFR |
| `20260721000002_deduplicate_scenarios.sql` | Deduplicación de escenarios |
| `20260721000003_seed_objectives.sql` | Seed de objetivos |
| `20260721000004_seed_achievements.sql` | Seed de logros v2 |
| `20260721000005_fix_rls_policies.sql` | Corrección de RLS |
| `20260721000006_fix_conversations_schema.sql` | Corrección schema conversaciones |
| `20260721000007_fix_rls_conversations.sql` | Corrección RLS conversaciones |
| `20260723000000-20260723000002` | Seeds masivos de lecciones |
| `seed_*.sql` | Seeds por nivel e idioma (A1-C2, en/fr/de/it) |

## RLS (Row Level Security)

Todas las tablas tienen RLS habilitado. Políticas principales:

- `users`: SELECT/UPDATE where `id = auth.uid()`
- `user_settings`: SELECT/UPDATE where `user_id = auth.uid()`
- `user_language_profiles`: SELECT/INSERT/UPDATE where `user_id = auth.uid()`
- `conversations`: SELECT/INSERT/UPDATE where `user_id = auth.uid()`
- `messages`: SELECT/INSERT on conversations where user is owner
- `scenarios`: SELECT for all authenticated users
- `scenario_objectives`: SELECT for all authenticated users

## CLI y MCP

El proyecto usa Supabase CLI y MCP para gestión de base de datos. Comandos útiles:

```bash
supabase start          # Iniciar stack local
supabase db push        # Aplicar migraciones
supabase gen types      # Generar tipos TypeScript/Dart
```
