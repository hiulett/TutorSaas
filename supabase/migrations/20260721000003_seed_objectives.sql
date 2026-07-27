-- ==========================================================
-- REPOBLAR SCENARIO_OBJECTIVES (tabla vacía por error de seed)
-- ==========================================================

-- Ingles (language_id = 1)
INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Order a drink and a snack with correct size.', ARRAY['espresso', 'croissant', 'decaf', 'oat milk']
FROM scenarios s WHERE s.title = 'Ordering Coffee at Starbucks' AND s.language_id = 1;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Complete check-in process and request wifi password.', ARRAY['reservation', 'room key', 'breakfast', 'elevator']
FROM scenarios s WHERE s.title = 'Checking into a Hotel' AND s.language_id = 1;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Describe a past challenge at work.', ARRAY['skills', 'experience', 'teamwork', 'troubleshooting']
FROM scenarios s WHERE s.title = 'Job Interview for Tech Support' AND s.language_id = 1;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Understand turns and reach destination.', ARRAY['turn left', 'go straight', 'blocks', 'subway station']
FROM scenarios s WHERE s.title = 'Asking for Street Directions' AND s.language_id = 1;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Reach a compromise on launch date and cost.', ARRAY['scope creep', 'milestones', 'bandwidth', 'ROI']
FROM scenarios s WHERE s.title = 'Project Scope & Budget Negotiation' AND s.language_id = 1;

-- Frances (language_id = 2)
INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Commander du pain avec politesse.', ARRAY['baguette', 's\'il vous plaît', 'croissant', 'merci']
FROM scenarios s WHERE s.title = 'Acheter des viennoiseries' AND s.language_id = 2;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Choisir une entrée, plat principal et demander l''addition.', ARRAY['l\'addition', 'plat du jour', 'cuisson', 'saignant']
FROM scenarios s WHERE s.title = 'Au bistrot chic' AND s.language_id = 2;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Présenter un concept publicitaire.', ARRAY['campagne', 'réseaux sociaux', 'cible', 'budget']
FROM scenarios s WHERE s.title = 'Réunion de brainstorming' AND s.language_id = 2;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Négocier la couverture d''assurance.', ARRAY['assurance tous risques', 'permis de conduire', 'caution', 'carburant']
FROM scenarios s WHERE s.title = 'Louer une voiture de sport' AND s.language_id = 2;

-- Aleman (language_id = 3)
INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Ein Bahnticket buchen und die Abfahrtszeit erfahren.', ARRAY['Fahrkarte', 'Gleis', 'Verspätung', 'einfache Fahrt']
FROM scenarios s WHERE s.title = 'Fahrkarten kaufen' AND s.language_id = 3;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Lebensmittel finden und nach dem Preis fragen.', ARRAY['Gemüse', 'Sonderangebot', 'Kasse', 'Einkaufswagen']
FROM scenarios s WHERE s.title = 'Einkaufen bei Aldi' AND s.language_id = 3;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Den Mietvertrag besprechen und die Miete verhandeln.', ARRAY['Warmmiete', 'Kaution', 'Schufa-Auskunft', 'Nebenkosten']
FROM scenarios s WHERE s.title = 'Wohnungsbesichtigung in Berlin' AND s.language_id = 3;

-- Italiano (language_id = 4)
INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Ordinare una coppetta o un cono con gusti specifici.', ARRAY['gelato', 'coppetta', 'gusti', 'panna montata']
FROM scenarios s WHERE s.title = 'Ordinare un Gelato a Roma' AND s.language_id = 4;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Ottenere i biglietti e una mappa del museo.', ARRAY['biglietto', 'ridotto', 'mappa', 'mostra temporanea']
FROM scenarios s WHERE s.title = 'Biglietti per la Galleria degli Uffizi' AND s.language_id = 4;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Raggiungere un compromesso sulle royalty e l''esclusività.', ARRAY['esclusività', 'collezione', 'contratto', 'royalty']
FROM scenarios s WHERE s.title = 'Lancio di una Collezione a Milano' AND s.language_id = 4;
