# ADR-008: Diseño Integral del Schema de Supabase

## Estado
Aceptado

## Contexto
TutorSaas requiere un schema de base de datos que soporte:
- Autenticación y perfiles de usuario
- Múltiples idiomas y niveles CEFR
- Conversaciones con mensajes y correcciones
- Catálogo de escenarios con objetivos
- Gamificación (XP, streaks, logros, desafíos)
- Vocabulario con algoritmo SM-2
- Suscripciones y pagos
- Estadísticas diarias y semanales
- Registro de uso de APIs de IA

## Principios de Diseño

1. **UUID como PKs** — para escalabilidad y seguridad (evita enumeración)
2. **RLS obligatorio** — toda tabla pública tiene Row Level Security
3. **Cascada controlada** — `ON DELETE CASCADE` para datos dependientes, `RESTRICT` para datos de referencia
4. **Timestamps consistentes** — `TIMESTAMPTZ` con `DEFAULT NOW()`
5. **Índices críticos** — para queries frecuentes (user_id, fechas, next_review)
6. **Trigger de sincronización** — `handle_new_user()` para mantener `auth.users` y `public.users` sincronizados

## Módulos del Schema

### Módulo de Usuarios
- `users` — Perfiles (sincronizado con auth.users)
- `user_settings` — Preferencias 1:1

### Módulo de Idiomas y Niveles
- `languages` — Catálogo de idiomas (en, es, fr, de, it)
- `cefr_levels` — Niveles A1-C2 con orden
- `user_language_profiles` — Perfil de idioma por usuario

### Módulo de Escenarios
- `scenarios` — Lecciones con context, difficulty, category
- `scenario_objectives` — Objetivos con vocabulario focus

### Módulo de Conversaciones
- `conversations` — Sesiones con scores y XP
- `messages` — Mensajes con contenido y metadata de audio
- `corrections` — Correcciones gramaticales

### Módulo de Pronunciación
- `pronunciation_assessments` — Evaluaciones fonémicas detalladas

### Módulo de Vocabulario
- `vocabulary_items` — Catálogo de palabras
- `user_vocabulary` — Progreso SM-2 por usuario

### Módulo de Estadísticas
- `daily_stats` — Resumen diario
- `weekly_stats` — Resumen semanal

### Módulo de Gamificación
- `achievements` — Catálogo de logros
- `user_achievements` — Logros obtenidos
- `daily_challenges` — Desafíos diarios

### Módulo de Suscripciones
- `subscription_plans` — Planes disponibles
- `user_subscriptions` — Suscripciones activas
- `payments` — Historial de pagos

### Módulo de IA
- `ai_usage_logs` — Registro de tokens, costos y latencia

### Módulo de Control
- `rate_limiting` — Límites de uso por usuario

## Relaciones Clave

```
users 1:1 user_settings
users 1:N user_language_profiles
users 1:N conversations
conversations 1:N messages 1:N corrections
conversations N:1 scenarios 1:N scenario_objectives
users N:N vocabulary_items via user_vocabulary (SM-2)
users N:N achievements via user_achievements
```

## Decisión
Schema completo de 22 tablas en PostgreSQL gestionado por Supabase, con migraciones versionadas en `supabase/migrations/`.

## Consecuencias
**Positivas:**
- Cobertura completa de todos los dominios del negocio
- Relaciones explícitas con foreign keys
- RLS permite seguridad granular por usuario
- Migraciones versionadas permiten evolución controlada
- Índices optimizados para queries frecuentes

**Negativas:**
- 22 tablas requieren mantenimiento continuo
- Algunas tablas (pronunciation_assessments, payments) sin flujo de llenado implementado
- Schema complejo puede ser difícil de modificar
- Migraciones múltiples requieren coordinación

## Referencias
- [Supabase Database Design](https://supabase.com/docs/guides/database)
- Migraciones en `supabase/migrations/`
