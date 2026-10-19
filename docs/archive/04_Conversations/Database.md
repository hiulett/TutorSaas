# Fase 4 — Database

> Esquema de datos de Conversaciones.

## Tablas consumidas

### `public.conversations`
Almacena sesiones de conversación por escenario.

### `public.conversation_messages`
Mensajes de la conversación (usuario/IA), evaluados con `isSatisfiedBy`.

### `public.scenarios` (o `lessons`)
Escenarios con objetivos; migraciones `20260721000003_seed_objectives.sql`,
`20260723000002_seed_15_lessons_per_combination.sql`, `clean_all_scenarios.sql`.

### Objetivos
Cada escenario tiene metas conversacionales evaluadas por keyword matching.

## Observaciones

- Verificar el esquema real de `conversations` (migración `20260721000006_fix_conversations_schema.sql`).
- El pipeline no persiste chats libres (efímeros) — solo escenarios.
- No hay tabla dedicada de "tácticas"; el bonus XP es UI/estado local (revisar coherencia
  con economía en Fase 6).
