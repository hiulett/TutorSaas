# Mission Engine — Dungeon of English

> **Documento:** Julio 2026  
> **Propósito:** Sistema de misiones inteligente, dinámico, persistente e infinito  

---

## Arquitectura General

```
                    ┌─────────────────────────────┐
                    │     MISSION ENGINE            │
                    │                               │
                    │  ┌───────────────────────┐   │
                    │  │  Mission Generator     │   │
                    │  │  (IA + Plantillas)     │   │
                    │  └───────────────────────┘   │
                    │            │                 │
                    │            ▼                 │
                    │  ┌───────────────────────┐   │
                    │  │  Mission Scheduler     │   │
                    │  │  (Tiempo, Eventos)     │   │
                    │  └───────────────────────┘   │
                    │            │                 │
                    │            ▼                 │
                    │  ┌───────────────────────┐   │
                    │  │  Mission Validator     │   │
                    │  │  (Reglas de negocio)   │   │
                    │  └───────────────────────┘   │
                    │            │                 │
                    │            ▼                 │
                    │  ┌───────────────────────┐   │
                    │  │  Reward Dispatcher     │   │
                    │  │  (XP, Items, Gemas)   │   │
                    │  └───────────────────────┘   │
                    └─────────────────────────────┘
```

## Tipos de Misiones (19 Categorías)

| # | Tipo | Generación | IA | Persistencia |
|---|------|-----------|-----|-------------|
| 1 | 📜 Recomendadas (historia CEFR) | Plantilla + orden secuencial | ❌ No | Tabla scenarios |
| 2 | 📋 Secundarias | Plantillas por nivel | ❌ No | mission_templates |
| 3 | 🔮 Secretas | IA según errores/falencias | ✅ Sí | hidden_quests |
| 4 | 🏰 Del Gremio | Pool rotativo | ❌ No | guild_quest_pool |
| 5 | ⚡ Emergencia | IA + tiempo límite | ✅ Sí | emergency_missions |
| 6 | ⏳ Temporales | Plantilla + duración | ❌ No | mission_instances |
| 7 | 📅 Diarias | Pool diario rotativo | ❌ No | guild_quest_pool |
| 8 | 📆 Semanales | Pool semanal rotativo | ❌ No | guild_quest_pool |
| 9 | 📅 Mensuales | Pool mensual rotativo | ❌ No | guild_quest_pool |
| 10 | 🍂 Estacionales | Evento + fecha | ❌ No | mission_templates |
| 11 | 🌍 Globales | Evento + todos los usuarios | ✅ Sí | global_events |
| 12 | 👥 Colaborativas | Meta colectiva del gremio | ❌ No | guild_quest_pool |
| 13 | 🤝 Cooperativas | 2+ jugadores | ✅ Sí | coop_missions |
| 14 | ⚔️ Competitivas | Ranking entre jugadores | ❌ No | leaderboard |
| 15 | 🎟️ Battle Pass | Temporada + niveles | ❌ No | guild_battle_pass |
| 16 | 🏆 Colección | Logros + hitos | ❌ No | achievements |
| 17 | 🗺️ Exploración | Descubrir nuevo contenido | ❌ No | scenarios |
| 18 | 📖 Narrativas | Lore + historia | ✅ Sí | narrative_chapters |
| 19 | 👑 Legendarias | Hitos+rango + combo especial | ✅ Sí | legendary_missions |

---

## Modelo de Datos (SQL)

```sql
-- Plantillas de misión (contenido predefinido, sin IA)
CREATE TABLE mission_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_type VARCHAR(50) NOT NULL,
    target_value INTEGER NOT NULL DEFAULT 1,
    xp_reward INTEGER DEFAULT 50,
    gem_reward INTEGER DEFAULT 0,
    item_reward VARCHAR(100),
    min_cefr_level VARCHAR(5),
    max_cefr_level VARCHAR(5),
    prerequisites JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    cooldown_hours INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Instancia de misión para un jugador
CREATE TABLE mission_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    template_id UUID REFERENCES mission_templates(id),
    mission_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_type VARCHAR(50) NOT NULL,
    target_value INTEGER NOT NULL,
    current_value INTEGER DEFAULT 0,
    xp_reward INTEGER DEFAULT 50,
    gem_reward INTEGER DEFAULT 0,
    item_reward VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','completed','failed','expired','cancelled')),
    is_reward_claimed BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    UNIQUE(user_id, template_id, mission_type)
);

-- Misiones secretas generadas por IA
CREATE TABLE secret_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trigger_data JSONB NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_type VARCHAR(50) NOT NULL DEFAULT 'practice_session',
    target_value INTEGER DEFAULT 1,
    xp_reward INTEGER DEFAULT 100,
    gem_reward INTEGER DEFAULT 10,
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Misiones de emergencia (eventos temporales globales)
CREATE TABLE emergency_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    objective_type VARCHAR(50) NOT NULL,
    target_value INTEGER NOT NULL,
    xp_reward INTEGER DEFAULT 200,
    gem_reward INTEGER DEFAULT 50,
    item_reward VARCHAR(100),
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '1 hour',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Eventos globales
CREATE TABLE global_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    reward_data JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Progreso del jugador en eventos globales
CREATE TABLE player_event_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES global_events(id) ON DELETE CASCADE,
    current_value INTEGER DEFAULT 0,
    target_value INTEGER NOT NULL,
    is_reward_claimed BOOLEAN DEFAULT false,
    UNIQUE(user_id, event_id)
);

-- Misiones colaborativas del gremio
CREATE TABLE guild_collaborative_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    objective_type VARCHAR(50) NOT NULL,
    target_value INTEGER NOT NULL,
    current_value INTEGER DEFAULT 0,
    xp_reward INTEGER DEFAULT 500,
    gem_reward INTEGER DEFAULT 100,
    item_reward VARCHAR(100),
    starts_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',
    is_reward_claimed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recompensas reclamadas (historial)
CREATE TABLE reward_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    source_type VARCHAR(50) NOT NULL,
    source_id VARCHAR(100) NOT NULL,
    xp_earned INTEGER DEFAULT 0,
    gems_earned INTEGER DEFAULT 0,
    item_code VARCHAR(100),
    claimed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para rendimiento
CREATE INDEX idx_mission_instances_user_status ON mission_instances(user_id, status);
CREATE INDEX idx_secret_missions_user ON secret_missions(user_id, is_completed);
CREATE INDEX idx_emergency_missions_active ON emergency_missions(is_active, expires_at);
CREATE INDEX idx_global_events_active ON global_events(is_active, expires_at);
CREATE INDEX idx_reward_history_user ON reward_history(user_id, claimed_at);
```

---

## Reglas de Negocio

| Regla | Descripción |
|---|---|
| **Max misiones activas** | Un jugador puede tener máximo 10 misiones activas simultáneas (sin contar daily/weekly) |
| **Rotación diaria** | Las misiones diarias se refrescan cada 24h |
| **Expiración** | Las misiones expiradas pasan a estado `expired` y no pueden reclamarse |
| **Prioridad** | Emergency > Secret > Daily > Weekly > Secondary > Story |
| **Cooldown** | Mismas misiones no pueden repetirse hasta después del cooldown |
| **Prerrequisitos** | Ciertas misiones requieren completar otras antes |
| **Encadenamiento** | Misiones pueden activar otras al completarse |
| **Reemplazo** | Si un jugador tiene 10 misiones activas, no recibe nuevas hasta completar algunas |
| **Batch generación** | Misiones diarias se generan en batch nocturno (sin IA en vivo) |
| **IA solo para secretas** | Solo las misiones secretas y de emergencia usan IA en vivo |

---

## Integración con IA

### Prompt para Generación de Misiones Secretas

```
Generate a hidden quest for an English learner.

USER PROFILE:
- CEFR Level: {cefr_level}
- Native Language: {native_language}
- Learning Language: {learning_language}
- Recent errors: {recent_errors}
- Time since last practice: {days_inactive} days
- Interests: {interests}
- Strengths: {strengths}
- Weaknesses: {weaknesses}

RULES:
1. The quest must feel like an RPG adventure, never like an exercise.
2. It must address one of the user's weaknesses or errors naturally.
3. Include a short narrative (2-3 sentences).
4. Include a clear objective.
5. Suggest XP and gem rewards.
6. Keep the language at {cefr_level} level.

Output format (JSON):
{
  "title": "string",
  "description": "string (narrative)",
  "objective_type": "practice_session|vocab_words|grammar_focus|pronunciation|conversation_turns",
  "target_value": "integer (1-10)",
  "xp_reward": "integer (50-500)",
  "gem_reward": "integer (0-50)"
}
```

### Cuándo NO usar IA

| Situación | Alternativa |
|---|---|
| Misiones diarias | Pool predefinido rotativo |
| Misiones de historia | Contenido pre-seedado |
| Misiones del gremio | Pool + condiciones |
| Misiones semanales | Pool predefinido |
| Misiones de colección | Logros estáticos |
| Battle Pass | Niveles predefinidos |

**Ahorro estimado: ~80% de las misiones no requieren IA**
