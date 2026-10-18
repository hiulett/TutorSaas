-- Re-siembra las mesas por defecto del gremio.
-- El bug de leave_table las borró todas al quedar vacías (ya corregido).
-- Moderador técnico: la cuenta del administrador (solo como FK; el juego usa
-- moderator_type='ai' para moderación automática).
DO $$
DECLARE
    v_admin uuid;
BEGIN
    SELECT id INTO v_admin FROM public.users ORDER BY created_at LIMIT 1;
    IF v_admin IS NULL THEN
        RAISE EXCEPTION 'No hay usuarios en public.users para asignar moderator_id';
    END IF;

    INSERT INTO public.chat_rooms
        (title, category, moderator_id, moderator_type, room_type, description,
         has_ai_moderator, max_speakers, max_seats, max_standing, mana_cost_per_min,
         is_active)
    VALUES
        ('Sala General',        'general',    v_admin, 'ai', 'discussion', 'Habla libremente de lo que quieras en inglés.', true, 6, 8, 8, 0, true),
        ('Viajeros del Mundo',  'travel',     v_admin, 'ai', 'discussion', 'Comparte experiencias y aprende vocabulario de viajes.', true, 6, 8, 8, 0, true),
        ('Entrevistas y Trabajo','business',  v_admin, 'ai', 'discussion', 'Practica entrevistas y vocabulario profesional.', true, 6, 8, 8, 0, true),
        ('Tech & Gamers',       'technology', v_admin, 'ai', 'discussion', 'Tecnología, videojuegos y cultura digital en inglés.', true, 6, 8, 8, 0, true),
        ('Arte y Creatividad',  'art',        v_admin, 'ai', 'discussion', 'Describe arte, música y comparte tu creatividad.', true, 6, 8, 8, 0, true),
        ('Cocina Internacional','cooking',    v_admin, 'ai', 'discussion', 'Recetas y gastronomía en inglés.', true, 6, 8, 8, 0, true)
    ON CONFLICT DO NOTHING;
END $$;
