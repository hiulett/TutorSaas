-- ==========================================================
-- SEEDING 15 ESCENARIOS Y LECCIONES DE APRENDIZAJE DE IDIOMAS
-- ==========================================================

DO $$
DECLARE
    lang_en_id INTEGER;
    lang_fr_id INTEGER;
    lang_de_id INTEGER;
    lang_it_id INTEGER;
    
    scen_id UUID;
BEGIN
    -- 1. Obtener IDs de idiomas mapeados en la base de datos
    SELECT id INTO lang_en_id FROM public.languages WHERE code = 'en';
    IF lang_en_id IS NULL THEN
        INSERT INTO public.languages (code, name, native_name, flag_emoji)
        VALUES ('en', 'Inglés', 'English', '🇺🇸') RETURNING id INTO lang_en_id;
    END IF;

    SELECT id INTO lang_fr_id FROM public.languages WHERE code = 'fr';
    IF lang_fr_id IS NULL THEN
        INSERT INTO public.languages (code, name, native_name, flag_emoji)
        VALUES ('fr', 'Francés', 'Français', '🇫🇷') RETURNING id INTO lang_fr_id;
    END IF;

    SELECT id INTO lang_de_id FROM public.languages WHERE code = 'de';
    IF lang_de_id IS NULL THEN
        INSERT INTO public.languages (code, name, native_name, flag_emoji)
        VALUES ('de', 'Alemán', 'Deutsch', '🇩🇪') RETURNING id INTO lang_de_id;
    END IF;

    SELECT id INTO lang_it_id FROM public.languages WHERE code = 'it';
    IF lang_it_id IS NULL THEN
        INSERT INTO public.languages (code, name, native_name, flag_emoji)
        VALUES ('it', 'Italiano', 'Italiano', '🇮🇹') RETURNING id INTO lang_it_id;
    END IF;

    -- ==========================================
    -- ESCENARIOS EN INGLÉS (🇺🇸)
    -- ==========================================

    -- Escenario 1: Cafetería (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_en_id,
        'Ordering Coffee at Starbucks',
        'Practice ordering a coffee and a pastry at a local cafe. Focus on simple politeness.',
        'You are a friendly barista at a busy NYC coffee shop. The user wants to buy coffee. Keep sentences simple and prompt them to specify size and milk options.',
        'A1',
        'travel',
        10
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Order a drink and a snack with correct size.', ARRAY['espresso', 'croissant', 'decaf', 'oat milk']);

    -- Escenario 2: Registro en Hotel (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_en_id,
        'Checking into a Hotel',
        'Check into a cozy hotel. Provide details of your reservation and room preferences.',
        'You are a professional hotel receptionist in London. Welcome the guest, ask for their ID, reservation name, and check them into Room 204. Keep it slow.',
        'A1',
        'travel',
        12
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Complete check-in process and request wifi password.', ARRAY['reservation', 'room key', 'breakfast', 'elevator']);

    -- Escenario 3: Entrevista de Trabajo (B1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_en_id,
        'Job Interview for Tech Support',
        'A classic job interview. Discuss your background, work experience, and strengths.',
        'You are an HR Manager interviewing a candidate. Ask questions about their experience solving tech issues and how they handle stressful customer calls.',
        'B1',
        'business',
        15
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Describe a past challenge at work.', ARRAY['skills', 'experience', 'teamwork', 'troubleshooting']);

    -- Escenario 4: Preguntar Direcciones (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_en_id,
        'Asking for Street Directions',
        'You are lost in New York. Ask a pedestrian how to reach Central Park.',
        'You are a helpful local pedestrian. Give simple, clear directions using words like left, right, block, and straight ahead.',
        'A1',
        'travel',
        8
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Understand turns and reach destination.', ARRAY['turn left', 'go straight', 'blocks', 'subway station']);

    -- Escenario 5: Negociación de Proyecto (C1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_en_id,
        'Project Scope & Budget Negotiation',
        'Negotiate budget limits and delivery timeline constraints with an demanding client.',
        'You are a strict client who wants a complex mobile app delivered in 3 weeks. The user is the project manager negotiating for more time or a higher fee.',
        'C1',
        'business',
        20
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Reach a compromise on launch date and cost.', ARRAY['scope creep', 'milestones', 'bandwidth', 'ROI']);


    -- ==========================================
    -- ESCENARIOS EN FRANCÉS (🇫🇷)
    -- ==========================================

    -- Escenario 6: Panadería (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_fr_id,
        'Acheter des viennoiseries',
        'Achetez une baguette et des croissants dans une boulangerie traditionnelle à Paris.',
        'Vous êtes le boulanger d''une boulangerie parisienne. Soyez poli et proposez d''autres articles comme des pains au chocolat.',
        'A1',
        'travel',
        8
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Commander du pain avec politesse.', ARRAY['baguette', 's''il vous plaît', 'croissant', 'merci']);

    -- Escenario 7: En el Restaurante (B1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_fr_id,
        'Au bistrot chic',
        'Commandez un repas complet de cuisine française et discutez des plats recommandés par le serveur.',
        'Vous êtes un serveur passionné dans un restaurant français classique. Expliquez les plats du jour et répondez aux questions sur le vin.',
        'B1',
        'travel',
        15
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Choisir une entrée, plat principal et demander l''addition.', ARRAY['l''addition', 'plat du jour', 'cuisson', 'saignant']);

    -- Escenario 8: Reunión de Trabajo (B1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_fr_id,
        'Réunion de brainstorming',
        'Partagez vos idées créatives pour une campagne marketing internationale.',
        'Vous êtes le directeur marketing d''une marque de cosmétiques. Animez la réunion de remue-méninges et encouragez le candidat à détailler ses idées.',
        'B1',
        'business',
        15
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Présenter un concept publicitaire.', ARRAY['campagne', 'réseaux sociaux', 'cible', 'budget']);

    -- Escenario 9: Alquiler de Coche (B1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_fr_id,
        'Louer une voiture de sport',
        'Louez un véhicule pour votre voyage sur la Côte d''Azur. Comparez les assurances.',
        'Vous êtes agent d''accueil chez Rent-A-Car Nice. Proposez des options d''assurance et décrivez les modèles de voitures disponibles.',
        'B1',
        'travel',
        12
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Négocier la couverture d''assurance.', ARRAY['assurance tous risques', 'permis de conduire', 'caution', 'carburant']);


    -- ==========================================
    -- ESCENARIOS EN ALEMÁN (🇩🇪)
    -- ==========================================

    -- Escenario 10: Comprar Billetes de Tren (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_de_id,
        'Fahrkarten kaufen',
        'Kaufen Sie eine Zugfahrkarte am Bahnhof München. Fragen Sie nach Verspätungen.',
        'Sie arbeiten am Schalter der Deutschen Bahn in München. Helfen Sie dem Kunden, ein Ticket nach Berlin zu buchen.',
        'A1',
        'travel',
        10
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Ein Bahnticket buchen und die Abfahrtszeit erfahren.', ARRAY['Fahrkarte', 'Gleis', 'Verspätung', 'einfache Fahrt']);

    -- Escenario 11: Compras en el Supermercado (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_de_id,
        'Einkaufen bei Aldi',
        'Suchen Sie nach Zutaten für ein deutsches Rezept und fragen Sie den Verkäufer um Hilfe.',
        'Sie sind ein freundlicher Mitarbeiter im Supermarkt. Beantworten Sie Fragen zum Standort von Milchprodukten und Backwaren.',
        'A1',
        'daily',
        10
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Lebensmittel finden und nach dem Preis fragen.', ARRAY['Gemüse', 'Sonderangebot', 'Kasse', 'Einkaufswagen']);

    -- Escenario 12: Alquiler de Piso (B1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_de_id,
        'Wohnungsbesichtigung in Berlin',
        'Besprechen Sie die Details eines Mietvertrags für eine Wohnung in Berlin-Mitte.',
        'Sie sind der strenge Vermieter einer Wohnung in Berlin. Fragen Sie den Bewerber nach seinem Gehalt, Haustieren und der Kaution.',
        'B1',
        'daily',
        15
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Den Mietvertrag besprechen und die Miete verhandeln.', ARRAY['Warmmiete', 'Kaution', 'Schufa-Auskunft', 'Nebenkosten']);


    -- ==========================================
    -- ESCENARIOS EN ITALIANO (🇮🇹)
    -- ==========================================

    -- Escenario 13: Comprar Gelato (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_it_id,
        'Ordinare un Gelato a Roma',
        'Ordina un gelato in una gelateria artigianale vicino alla Fontana di Trevi.',
        'Sei un gelataio gioviale a Roma. Consiglia gusti tipici come pistacchio siciliano e nocciola al cliente.',
        'A1',
        'travel',
        8
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Ordinare una coppetta o un cono con gusti specifici.', ARRAY['gelato', 'coppetta', 'gusti', 'panna montata']);

    -- Escenario 14: Visita al Museo (A1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_it_id,
        'Biglietti per la Galleria degli Uffizi',
        'Compra i biglietti per visitare un museo d''arte a Firenze. Chiedi sconti per studenti.',
        'Sei un addetto alla biglietteria del museo a Firenze. Spiega gli orari e i prezzi del biglietto.',
        'A1',
        'travel',
        10
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Ottenere i biglietti e una mappa del museo.', ARRAY['biglietto', 'ridotto', 'mappa', 'mostra temporanea']);

    -- Escenario 15: Discusión de Negocios de Moda (C1)
    INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes)
    VALUES (
        lang_it_id,
        'Lancio di una Collezione a Milano',
        'Negozia la distribuzione esclusiva di abiti da sposa con un partner milanese.',
        'Sei un distributore di moda di lusso a Milano. Esigi termini contrattuali rigorosi prima di firmare l''accordo.',
        'C1',
        'business',
        20
    ) RETURNING id INTO scen_id;

    INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
    VALUES (scen_id, 'Raggiungere un compromesso sulle royalty e l''esclusività.', ARRAY['esclusività', 'collezione', 'contratto', 'royalty']);

END $$;
