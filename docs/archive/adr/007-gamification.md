# ADR-007: Sistema de Gamificación

## Estado
Aceptado

## Contexto
TutorSaas necesita un sistema de gamificación que:
- Motive la práctica diaria consistente
- Proporcione retroalimentación inmediata sobre progreso
- Cree un sentido de logro y competencia
- Sea coherente con la temática "Abyssal Interface / Isekai Manhwa System HUD"
- Funcione como diferenciador frente a apps tradicionales

## Elementos del Sistema

### XP (Experience Points)
- Acumulados por conversaciones completadas, metas logradas, rachas
- Almacenados en `user_language_profiles.xp_points`
- Determinan el avance visual (rango de cazador)

### Streaks (Rachas)
- `current_streak` — días consecutivos de práctica
- `longest_streak` — récord histórico
- `last_practice_date` — para calcular continuidad
- Visible en DashboardScreen

### Achievements (Logros)
- Catálogo en tabla `achievements` con tipos: `streak`, `conversations`, `vocabulary`
- Condiciones: valor objetivo para desbloquear
- Recompensa: `xp_reward`
- Tabla `user_achievements` para logros obtenidos

### Hunter Ranks (Rangos de Cazador)
- Tab "Hunter Status" en DashboardScreen
- Sistema de rangos (E→D→C→B→A→S) basado en XP
- Leaderboard semanal (actualmente mock)

### Daily Quests (Misiones Diarias)
- Tabla `daily_challenges` con tipo, valor objetivo, progreso
- Asignadas diariamente por usuario
- Recompensa en XP al completar

### Maná (Mana)
- Indicador de uso de sesión en ConversationScreen
- `ManaMeterWidget` muestra maná actual, máximo y usado en sesión
- No es una moneda real del sistema (solo visual/gamificado)

### Metas de Misión (Compass 🧭)
- Modal de misiones en ConversationScreen
- 5 metas por lección evaluadas por keyword matching
- Actualización en tiempo real via `LiveGoalsTrackerBar`

## Decisión
Se implementa un sistema completo de gamificación con XP, streaks, logros, rangos, misiones diarias y metas de misión, integrado con el sistema de diseño "Abyssal Interface".

## Consecuencias
**Positivas:**
- Incrementa retención y engagement mediante refuerzo positivo
- Coherencia temática con la UI de sistema HUD
- Múltiples capas de motivación (diaria, por logro, competitiva)
- Datos estructurados en Supabase permiten análisis de retención

**Negativas:**
- Complejidad adicional en la base de datos (6 tablas)
- Riesgo de fatiga de gamificación si hay demasiados elementos
- Leaderboard requiere datos multi-usuario para ser efectivo
- Mantenimiento continuo de contenido de logros y misiones

## Tablas Relacionadas
- `achievements` — Catálogo de logros
- `user_achievements` — Logros de usuarios
- `daily_challenges` — Misiones diarias
- `user_language_profiles` — XP, streaks
- `user_vocabulary` — Progreso de vocabulario (SRS SM-2)

## Referencias
- Principios de gamificación aplicados de Duolingo y apps de fitness
- Algoritmo SM-2 para Spaced Repetition System
