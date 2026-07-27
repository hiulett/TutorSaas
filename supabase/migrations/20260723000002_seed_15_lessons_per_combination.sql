-- =============================================================================
-- MIGRACIÓN DE SEEDING COMPLETO: 15 LECCIONES PARA CADA COMBINACIÓN POSIBLE DE ONBOARDING
-- 4 Idiomas ('en', 'fr', 'de', 'it') x 6 Niveles (A1-C2) x 9 Categorías x 15 Lecciones
-- TOTAL = EXACTAMENTE 3,240 LECCIONES PRECARGADAS EN LA BASE DE DATOS (`public.scenarios`)
-- =============================================================================

DO $$
DECLARE
    lang_rec RECORD;
    lvl TEXT;
    cat TEXT;
    i INT;
    v_title TEXT;
    v_desc TEXT;
    v_context TEXT;
    v_mins INT;
    v_goals JSONB;
    v_phrases JSONB;
    v_init_msg TEXT;
    v_asst_role TEXT;
BEGIN
    -- Arreglo de los 6 Niveles CEFR del Onboarding
    FOREACH lvl IN ARRAY ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
    LOOP
        -- Arreglo de las 9 Categorías de Interés del Onboarding
        FOREACH cat IN ARRAY ARRAY['travel', 'business', 'technology', 'art', 'sports', 'music', 'science', 'cooking', 'history']
        LOOP
            -- Recorrer los 4 Idiomas Objetivos
            FOR lang_rec IN 
                SELECT id, code FROM public.languages WHERE code IN ('en', 'fr', 'de', 'it')
            LOOP
                -- Generar exactamente 15 lecciones precargadas para esta combinación específica
                FOR i IN 1..15 LOOP
                    
                    -- Asignación de tiempo según nivel
                    v_mins := CASE 
                        WHEN lvl = 'A1' THEN 10
                        WHEN lvl IN ('A2', 'B1') THEN 15
                        WHEN lvl IN ('B2', 'C1') THEN 30
                        ELSE 45
                    END;

                    -- Título y roles dinámicos por lección y categoría
                    v_title := lvl || ' - ' || INITCAP(cat) || ' Lección ' || i || ': Práctica de ' || INITCAP(cat);
                    v_desc := 'Lección precargada ' || i || '/15 de nivel ' || lvl || ' en la categoría ' || cat || ' para idioma ' || lang_rec.code || '.';
                    v_context := 'Tutor de IA interactuando en nivel ' || lvl || ' para la lección de ' || cat || ' (Lección ' || i || '). Idioma objetivo: ' || lang_rec.code || '. Adapta las correcciones e interacción al nivel del estudiante.';
                    v_asst_role := 'Tutor IA de ' || INITCAP(cat);
                    v_init_msg := '¡Hola! Bienvenido a tu lección ' || i || ' de nivel ' || lvl || ' sobre ' || INITCAP(cat) || '. ¿Listo para practicar hoy?';

                    -- Arreglo JSONB de Metas de Escenario (3 metas por lección)
                    v_goals := jsonb_build_array(
                        'Completar la conversación ' || i || ' sobre ' || cat,
                        'Demostrar uso de vocabulario nivel ' || lvl,
                        'Alcanzar los objetivos de fluidez en ' || lang_rec.code
                    );

                    -- Arreglo JSONB de Frases Útiles (3 frases por lección)
                    v_phrases := jsonb_build_array(
                        'Frase clave de apoyo 1 para ' || cat,
                        'Expresión recomendada nivel ' || lvl,
                        '¡Gracias por la lección y retroalimentación!'
                    );

                    -- Inserción directa en la tabla public.scenarios
                    INSERT INTO public.scenarios (
                        language_id,
                        title,
                        description,
                        context,
                        difficulty_level,
                        category,
                        estimated_minutes,
                        main_objective,
                        assistant_role,
                        user_role,
                        initial_assistant_message,
                        goals,
                        useful_phrases,
                        is_active
                    ) VALUES (
                        lang_rec.id,
                        v_title,
                        v_desc,
                        v_context,
                        lvl,
                        cat,
                        v_mins,
                        'Dominar la conversación ' || i || ' de ' || cat || ' en nivel ' || lvl,
                        v_asst_role,
                        'Estudiante',
                        v_init_msg,
                        v_goals,
                        v_phrases,
                        TRUE
                    );

                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END $$;
