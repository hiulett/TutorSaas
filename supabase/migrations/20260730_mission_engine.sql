-- ============================================================================
-- MISSION ENGINE - Sistema completo de misiones
-- ============================================================================

-- 1. PLANTILLAS DE MISIÓN
CREATE TABLE IF NOT EXISTS mission_templates (
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

-- 2. INSTANCIAS DE MISIÓN POR JUGADOR
CREATE TABLE IF NOT EXISTS mission_instances (
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

-- 3. MISIONES SECRETAS (IA)
CREATE TABLE IF NOT EXISTS secret_missions (
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

-- 4. MISIONES DE EMERGENCIA
CREATE TABLE IF NOT EXISTS emergency_missions (
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

-- 5. EVENTOS GLOBALES
CREATE TABLE IF NOT EXISTS global_events (
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

-- 6. PROGRESO EN EVENTOS
CREATE TABLE IF NOT EXISTS player_event_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES global_events(id) ON DELETE CASCADE,
    current_value INTEGER DEFAULT 0,
    target_value INTEGER NOT NULL,
    is_reward_claimed BOOLEAN DEFAULT false,
    UNIQUE(user_id, event_id)
);

-- 7. MISIONES COLABORATIVAS DEL GREMIO
CREATE TABLE IF NOT EXISTS guild_collaborative_missions (
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

-- 8. HISTORIAL DE RECOMPENSAS
CREATE TABLE IF NOT EXISTS reward_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    source_type VARCHAR(50) NOT NULL,
    source_id VARCHAR(100) NOT NULL,
    xp_earned INTEGER DEFAULT 0,
    gems_earned INTEGER DEFAULT 0,
    item_code VARCHAR(100),
    claimed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. SEED DATA: Plantillas de misión (contexto: conversaciones del mundo real)
INSERT INTO mission_templates (mission_type, title, description, objective_type, target_value, xp_reward, gem_reward, min_cefr_level) VALUES

    -- DIARIAS - Situaciones reales cotidianas
    ('daily', 'Pedir un Café', 'Simula pedir un café en inglés. Usa frases como "I would like..." y "Could I have..."', 'speak_minutes', 3, 50, 5, 'A1'),
    ('daily', 'La Hora del Almuerzo', 'Practica cómo pedir comida en un restaurante. Usa "I\'ll have..." y "Can I get..."', 'speak_minutes', 3, 50, 5, 'A1'),
    ('daily', 'Preguntar Direcciones', 'Practica cómo pedir y dar direcciones en inglés: "Excuse me, where is..."', 'speak_minutes', 3, 55, 5, 'A2'),
    ('daily', 'La Conversación de Ascensor', 'Mantén una conversación breve sobre el clima o el fin de semana', 'speak_minutes', 3, 50, 5, 'A2'),
    ('daily', 'El Correo Electrónico', 'Practica frases para escribir correos: "I am writing to..." y "Looking forward to..."', 'practice_session', 1, 60, 10, 'B1'),
    ('daily', 'La Entrevista Relámpago', 'Responde 3 preguntas típicas de entrevistas de trabajo', 'conversation_turns', 3, 75, 10, 'B1'),
    ('daily', 'La Llamada Telefónica', 'Simula una llamada para reservar una cita o hacer una reserva', 'speak_minutes', 5, 70, 10, 'B2'),
    ('daily', 'El Chart de Negocios', 'Discute un tema de negocios: presupuesto, fechas límite o propuestas', 'speak_minutes', 5, 80, 15, 'B2'),
    ('daily', 'El Debate Rápido', 'Expresa tu opinión sobre un tema actual durante 3 minutos', 'speak_minutes', 3, 65, 10, 'C1'),
    ('daily', 'La Negociación', 'Practica frases de negociación: "What if we..." y "I propose that..."', 'speak_minutes', 5, 90, 15, 'C1'),
    ('daily', 'Mantén tu Racha', 'Completa una conversación de 10 minutos para mantener tu racha diaria', 'speak_minutes', 10, 100, 20, NULL),

    -- SEMANALES - Hitos de conversación real
    ('weekly', 'El Viajero Semanal', 'Practica 5 situaciones de viaje: aeropuerto, hotel, restaurante, transporte, emergencias', 'speak_minutes', 25, 300, 50, NULL),
    ('weekly', 'El Networking Profesional', 'Mantén 3 conversaciones sobre temas profesionales: presentación, proyecto, colaboración', 'sessions', 3, 350, 60, 'B1'),
    ('weekly', 'El Entrevistador', 'Completa una simulación completa de entrevista de trabajo de 15 minutos', 'speak_minutes', 15, 400, 75, 'B2'),
    ('weekly', 'El Ciudadano Global', 'Discute 3 temas de actualidad: tecnología, medio ambiente, cultura', 'conversation_turns', 15, 350, 50, 'C1'),
    ('weekly', 'El Políglota', 'Acumula 20 palabras nuevas y úsalas en contexto', 'vocab_words', 20, 250, 40, NULL),

    -- SECUNDARIAS - Escenarios específicos
    ('secondary', 'Check-in en el Aeropuerto', 'Simula el proceso completo de facturación en un aeropuerto internacional', 'sessions', 1, 120, 15, 'A2'),
    ('secondary', 'La Cena de Negocios', 'Practica cómo socializar durante una cena con colegas internacionales', 'speak_minutes', 8, 150, 20, 'B1'),
    ('secondary', 'Alquilar un Departamento', 'Simula una conversación con un arrendador sobre el alquiler de un departamento', 'speak_minutes', 8, 150, 20, 'B1'),
    ('secondary', 'La Visita al Médico', 'Practica cómo describir síntomas y entender indicaciones médicas en inglés', 'speak_minutes', 5, 130, 15, 'B2'),
    ('secondary', 'La Presentación', 'Prepara y da una presentación corta de 3 minutos sobre un tema que domines', 'speak_minutes', 3, 200, 30, 'B2'),
    ('secondary', 'El Debate Académico', 'Defiende tu punto de vista en un debate estructurado sobre un tema complejo', 'conversation_turns', 10, 250, 40, 'C1'),
    ('secondary', 'La Entrevista de Visa', 'Simula una entrevista para visa de turista o de trabajo en Estados Unidos', 'speak_minutes', 10, 180, 25, 'B1'),
    ('secondary', 'El Servicio al Cliente', 'Practica cómo resolver un problema como cliente: devolución, queja, reembolso', 'speak_minutes', 5, 120, 15, 'A2'),

    -- SECUNDARIAS - Habilidades sociales
    ('secondary', 'El Rompehielos', 'Inicia una conversación con un desconocido usando preguntas abiertas', 'conversation_turns', 5, 80, 10, 'A2'),
    ('secondary', 'El Storyteller', 'Cuenta una anécdota personal de 2 minutos usando pasado simple y continuo', 'speak_minutes', 2, 100, 15, 'B1'),
    ('secondary', 'El Consejero', 'Da consejos sobre un problema usando "should", "ought to" y "if I were you"', 'conversation_turns', 6, 110, 15, 'B1'),
    ('secondary', 'El Pacificador', 'Resuelve un conflicto hipotético usando lenguaje diplomático y negociación', 'speak_minutes', 5, 160, 25, 'B2'),
    ('secondary', 'El Mentor', 'Explica un concepto complejo a alguien con menos nivel que tú', 'speak_minutes', 5, 200, 30, 'C1')
ON CONFLICT DO NOTHING;

-- 10. ÍNDICES
CREATE INDEX IF NOT EXISTS idx_mission_instances_user_status ON mission_instances(user_id, status);
CREATE INDEX IF NOT EXISTS idx_secret_missions_user ON secret_missions(user_id, is_completed);
CREATE INDEX IF NOT EXISTS idx_emergency_missions_active ON emergency_missions(is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_global_events_active ON global_events(is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_reward_history_user ON reward_history(user_id, claimed_at);

-- 11. RLS
ALTER TABLE mission_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE mission_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE secret_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE global_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_event_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_collaborative_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_history ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_missions_authenticated' AND tablename = 'mission_templates') THEN
        CREATE POLICY select_missions_authenticated ON mission_templates FOR SELECT USING (auth.role() = 'authenticated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_own_instances' AND tablename = 'mission_instances') THEN
        CREATE POLICY select_own_instances ON mission_instances FOR SELECT USING (auth.uid() = user_id);
        CREATE POLICY insert_own_instances ON mission_instances FOR INSERT WITH CHECK (auth.uid() = user_id);
        CREATE POLICY update_own_instances ON mission_instances FOR UPDATE USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_own_secret' AND tablename = 'secret_missions') THEN
        CREATE POLICY select_own_secret ON secret_missions FOR SELECT USING (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_emergency' AND tablename = 'emergency_missions') THEN
        CREATE POLICY select_emergency ON emergency_missions FOR SELECT USING (auth.role() = 'authenticated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_events' AND tablename = 'global_events') THEN
        CREATE POLICY select_events ON global_events FOR SELECT USING (auth.role() = 'authenticated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_own_events' AND tablename = 'player_event_progress') THEN
        CREATE POLICY select_own_events ON player_event_progress FOR SELECT USING (auth.uid() = user_id);
        CREATE POLICY insert_own_events ON player_event_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_guild_collab' AND tablename = 'guild_collaborative_missions') THEN
        CREATE POLICY select_guild_collab ON guild_collaborative_missions FOR SELECT USING (auth.role() = 'authenticated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'select_own_rewards' AND tablename = 'reward_history') THEN
        CREATE POLICY select_own_rewards ON reward_history FOR SELECT USING (auth.uid() = user_id);
        CREATE POLICY insert_own_rewards ON reward_history FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
END $$;

-- 12. REALTIME
ALTER PUBLICATION supabase_realtime ADD TABLE mission_instances;
ALTER PUBLICATION supabase_realtime ADD TABLE emergency_missions;
ALTER PUBLICATION supabase_realtime ADD TABLE global_events;
