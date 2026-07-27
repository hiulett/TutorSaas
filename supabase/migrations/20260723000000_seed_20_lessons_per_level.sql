-- =============================================================================
-- MIGRACIÓN DE SEEDING: 120 LECCIONES ADAPTATIVAS (20 POR NIVEL CEFR: A1, A2, B1, B2, C1, C2)
-- Mapeadas automáticamente para los 4 idiomas objetivos: 'en', 'fr', 'de', 'it' (Total = 480 registros)
-- Basadas en los parámetros de Onboarding: Nivel, Intereses, Metas de Tiempo, Roles y Estilos de Corrección
-- =============================================================================

DO $$
DECLARE
    lang_rec RECORD;
BEGIN
    -- Recorrer los 4 idiomas objetivos de la plataforma
    FOR lang_rec IN 
        SELECT id, code FROM public.languages WHERE code IN ('en', 'fr', 'de', 'it')
    LOOP

        -- ==========================================
        -- NIVEL A1: PRINCIPIANTE (20 LECCIONES)
        -- ==========================================

        -- A1-01
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Ordering Coffee at a Cafe', 'Practice ordering coffee and pastries using polite expressions.', 
        'You are a friendly barista at a local cafe. Interact with a beginner (A1) student learning target language code ' || lang_rec.code || '. Keep vocabulary simple and encourage basic politeness.',
        'A1', 'travel', 10, 'Order a coffee drink and snack with size preferences.', 'Barista', 'Customer',
        'Hello! Welcome to Metro Cafe. What can I get started for you today?',
        '["Order a coffee drink", "Specify milk or sugar preferences", "Order a pastry", "Ask for total price"]'::jsonb,
        '["I would like a coffee, please.", "Can I have oat milk?", "How much is that?", "Thank you!"]'::jsonb, TRUE);

        -- A1-02
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Checking into a Hotel', 'Check into your hotel room and request basic amenities.', 
        'You are a helpful hotel receptionist welcoming a guest. Keep sentences simple and slow for A1 level.',
        'A1', 'travel', 15, 'Complete check-in process and ask about Wi-Fi and breakfast.', 'Hotel Receptionist', 'Hotel Guest',
        'Good afternoon! Welcome to Grand View Hotel. Do you have a reservation with us?',
        '["Provide your name for reservation", "Confirm room type", "Ask for Wi-Fi password", "Inquire about breakfast hours"]'::jsonb,
        '["I have a reservation under my name.", "What time is breakfast?", "Is Wi-Fi included?", "Where is the elevator?"]'::jsonb, TRUE);

        -- A1-03
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Asking for Street Directions', 'Find your way around town by asking pedestrians for directions.', 
        'You are a friendly local walking on the street. Help a lost tourist reach Central Park with simple directional words.',
        'A1', 'travel', 10, 'Ask for directions and understand simple turn instructions.', 'Local Resident', 'Tourist',
        'Excuse me! You look a bit lost. Can I help you find something in the city?',
        '["Ask how to reach Central Park", "Understand turn left/right", "Ask if it is near on foot", "Say thank you"]'::jsonb,
        '["Excuse me, where is Central Park?", "Is it far from here?", "Should I turn left or right?", "Thank you so much!"]'::jsonb, TRUE);

        -- A1-04
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Grocery Shopping Basics', 'Buy fresh fruits, vegetables, and daily staples at the market.', 
        'You work at a fresh grocery market. Assist the customer in finding items and checking out.',
        'A1', 'cooking', 15, 'Ask for food locations, prices, and pay at checkout.', 'Grocery Clerk', 'Shopper',
        'Hello! Welcome to Fresh Market. Let me know if you need help finding anything.',
        '["Ask where milk and apples are", "Inquire price per kilo", "Request a shopping bag", "Pay at register"]'::jsonb,
        '["Where can I find the milk?", "How much are the apples?", "Can I get a bag?", "Here is my card."]'::jsonb, TRUE);

        -- A1-05
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Taking a City Taxi', 'Tell the taxi driver your destination and discuss the fare.', 
        'You are a polite taxi driver picking up a passenger. Ask where they are going and give simple fare estimates.',
        'A1', 'travel', 10, 'Communicate destination address and pay fare.', 'Taxi Driver', 'Passenger',
        'Hi there! Jump in. Where are we heading today?',
        '["State destination address", "Ask estimated arrival time", "Ask how much the ride costs", "Pay driver and tip"]'::jsonb,
        '["Please take me to the airport.", "How long will it take?", "How much is the fare?", "Keep the change."]'::jsonb, TRUE);

        -- A1-06
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Introducing Yourself to a Neighbor', 'Meet your new neighbor and exchange basic background info.', 
        'You are a welcoming neighbor meeting someone who just moved in next door.',
        'A1', 'daily', 10, 'Introduce yourself, origin country, and profession.', 'Neighbor', 'New Resident',
        'Hi! I noticed you just moved in next door. I am Alex!',
        '["State your name and origin", "Mention your profession", "Ask how long neighbor lived here", "Friendly closing"]'::jsonb,
        '["Nice to meet you, I am...", "I recently moved from...", "I work as an engineer.", "Have a great day!"]'::jsonb, TRUE);

        -- A1-07
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Ordering Pizza for Pickup', 'Call a local pizzeria to order a customized pizza.', 
        'You take phone orders at Mario Pizzeria. Help customer pick size, crust, and toppings.',
        'A1', 'cooking', 15, 'Select pizza size, crust, toppings, and pickup time.', 'Pizzeria Cashier', 'Caller',
        'Thanks for calling Mario Pizza! Is this order for pickup or delivery?',
        '["Choose pickup or delivery", "Select pizza size", "Pick 2 toppings", "Confirm pickup time"]'::jsonb,
        '["I would like a large pizza.", "Thin crust, please.", "How long will pickup take?", "My phone number is..."]'::jsonb, TRUE);

        -- A1-08
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Buying Clothes at a Shop', 'Try on clothes and ask for different sizes or colors.', 
        'You are a retail assistant at a clothing store helping a customer find their size.',
        'A1', 'daily', 15, 'Ask for clothing size, fitting room, and price.', 'Store Assistant', 'Shopper',
        'Welcome! Looking for anything specific in our autumn collection today?',
        '["Ask for shirt in Medium size", "Inquire about alternative colors", "Ask where fitting room is", "Decide to purchase"]'::jsonb,
        '["Do you have this in Medium?", "Does this come in blue?", "Where are fitting rooms?", "I will take this one."]'::jsonb, TRUE);

        -- A1-09
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Talking About Daily Routine', 'Describe your typical daily schedule and simple habits.', 
        'You are a friendly language tutor asking the student about their daily schedule.',
        'A1', 'daily', 10, 'Share wake up time, meals, work transit, and bedtime.', 'Tutor', 'Student',
        'Tell me about your typical day! What time do you usually wake up?',
        '["Mention wake up time", "Describe breakfast routine", "Explain transit to work", "State sleep time"]'::jsonb,
        '["I wake up at 7 AM.", "I drink coffee and eat toast.", "I go to work by bus.", "I go to bed at 10 PM."]'::jsonb, TRUE);

        -- A1-10
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Discussing Weather and Time', 'Make casual small talk about current weather and times.', 
        'You are a coworker making casual elevator talk about today weather and schedules.',
        'A1', 'science', 10, 'Describe weather temperature and ask for current time.', 'Colleague', 'Coworker',
        'Good morning! Looks pretty cloudy and cold outside today, doesn me it?',
        '["Comment on weather", "State temperature feeling", "Ask for current time", "Plan outdoor activity"]'::jsonb,
        '["It is very warm today.", "What time is it right now?", "It looks like rain.", "Let us meet at 3 PM."]'::jsonb, TRUE);

        -- A1-11
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Doctor Clinic Reception Check-In', 'Check in for a scheduled medical consultation.', 
        'You are a clinic receptionist checking in patients and verifying personal ID.',
        'A1', 'daily', 15, 'Provide name, appointment time, and ID card.', 'Medical Receptionist', 'Patient',
        'Hello, welcome to City Health Clinic. How can I help you today?',
        '["State appointment name and time", "Provide ID card", "Take seat in waiting area", "Confirm doctor name"]'::jsonb,
        '["I have an appointment with Dr. Smith.", "My name is John Doe.", "Here is my ID card.", "I will wait here."]'::jsonb, TRUE);

        -- A1-12
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Visiting a Pet Shop', 'Ask about pets, food, and animal supplies.', 
        'You run a pet shop. Help customer choose puppy food and toys.',
        'A1', 'sports', 10, 'Inquire about pet food recommendations and prices.', 'Pet Shop Owner', 'Customer',
        'Hello! Looking for pet food or thinking of adopting a pet today?',
        '["State what pet you own", "Ask for food recommendation", "Inquire about toy prices", "Purchase item"]'::jsonb,
        '["I have a small puppy.", "Which food is best?", "How much is this toy?", "I will take this bag."]'::jsonb, TRUE);

        -- A1-13
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Talking About Hobbies', 'Share your favorite leisure activities and weekend fun.', 
        'You are chatting with a friend about free time activities and weekend hobbies.',
        'A1', 'art', 15, 'List 2-3 hobbies and state frequency.', 'Friend', 'Friend',
        'Hey! What do you like to do on weekends when you have free time?',
        '["Mention main hobbies", "State frequency", "Ask about their hobbies", "Invite for shared activity"]'::jsonb,
        '["I like reading and soccer.", "I play music on weekends.", "Do you enjoy cooking?", "Let us play together!"]'::jsonb, TRUE);

        -- A1-14
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Birthday Party Wish & Gift', 'Congratulate a friend on their birthday and hand over a present.', 
        'You are celebrating your birthday with friends at a small gathering.',
        'A1', 'music', 15, 'Express birthday wishes and ask about party plans.', 'Birthday Host', 'Friend',
        'Hey! Thanks for coming to my birthday celebration today!',
        '["Wish Happy Birthday", "Hand over gift", "Ask about party plans", "Enjoy cake"]'::jsonb,
        '["Happy Birthday to you!", "I brought a small gift.", "Are you having a party?", "Enjoy your special day!"]'::jsonb, TRUE);

        -- A1-15
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Buying Bus Tickets', 'Purchase city or interstate bus tickets at terminal.', 
        'You work at the bus ticket counter. Assist traveler with destinations and fare.',
        'A1', 'travel', 10, 'Specify destination, ticket type (one-way), and pay.', 'Ticket Clerk', 'Traveler',
        'Next in line please! Where are you traveling to today?',
        '["Specify destination city", "Choose single or return ticket", "Select departure time", "Pay for ticket"]'::jsonb,
        '["One ticket to Boston, please.", "Is it a direct bus?", "One-way ticket, please.", "What gate departs?"]'::jsonb, TRUE);

        -- A1-16
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Renting a City Bike', 'Rent a bicycle for a day at a rental shop.', 
        'You rent out bicycles to city tourists. Explain rates and helmet safety.',
        'A1', 'sports', 15, 'Inquire about hourly rates, helmet rental, and deposit.', 'Bike Shop Staff', 'Tourist',
        'Hello! Ready to explore the city on two wheels today?',
        '["Ask hourly rental rate", "Request helmet and lock", "Confirm return time", "Pay deposit"]'::jsonb,
        '["How much per hour?", "Does it include a helmet?", "What time do you close?", "Here is my deposit."]'::jsonb, TRUE);

        -- A1-17
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Asking for Pharmacy Help', 'Describe mild symptoms to a pharmacist for over-the-counter medicine.', 
        'You are a pharmacist advising a customer with a mild headache or cough.',
        'A1', 'science', 10, 'Explain symptom (headache) and ask dosage instructions.', 'Pharmacist', 'Customer',
        'Good afternoon! How can I assist you at the pharmacy today?',
        '["Describe symptom clearly", "Ask how to take medicine", "Ask about side effects", "Purchase medication"]'::jsonb,
        '["I have a bad headache.", "Do you have pain medicine?", "How many times a day?", "Thank you so much."]'::jsonb, TRUE);

        -- A1-18
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Smartphone Basics Setup', 'Ask a store associate how to connect your phone to Wi-Fi.', 
        'You work at a mobile phone store helping a customer configure simple phone settings.',
        'A1', 'technology', 15, 'Ask for Wi-Fi connection steps and app installation.', 'Tech Associate', 'Customer',
        'Hello! Need help setting up your new smartphone today?',
        '["Ask how to connect to Wi-Fi", "Ask where app store is", "Inquire about battery life", "Thank associate"]'::jsonb,
        '["How do I connect Wi-Fi?", "Where is the camera app?", "How do I turn it off?", "Thank you for helping."]'::jsonb, TRUE);

        -- A1-19
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Showing Family Photo Album', 'Describe family members shown in a photo album.', 
        'You are looking at a friend family album and asking who each person is.',
        'A1', 'history', 15, 'Name family relationships (father, mother, brother) and ages.', 'Friend', 'Friend',
        'Oh, is that a picture of your family? Who is this standing here?',
        '["Identify family member", "State their profession/age", "Describe family pet", "Ask about friend family"]'::jsonb,
        '["This is my brother.", "She works as a teacher.", "We are four in my family.", "Do you have siblings?"]'::jsonb, TRUE);

        -- A1-20
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Ordering Bakery Breakfast', 'Buy fresh bread, croissants, and juice for breakfast.', 
        'You are a baker selling fresh morning pastries and orange juice.',
        'A1', 'cooking', 10, 'Request bakery items, quantity, and pay.', 'Baker', 'Customer',
        'Good morning! Everything is fresh out of the oven. What would you like?',
        '["Order 2 croissants", "Ask for fresh orange juice", "Confirm bread freshness", "Pay total"]'::jsonb,
        '["Two croissants, please.", "A glass of orange juice.", "Is the bread fresh?", "Keep the change!"]'::jsonb, TRUE);


        -- ==========================================
        -- NIVEL A2: ELEMENTAL (20 LECCIONES)
        -- ==========================================

        -- A2-01
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Handling Restaurant Order Issue', 'Respectfully address an incorrect meal order with waiter.', 
        'You are a waiter at a casual restaurant. Address a diner who received the wrong steak temperature.',
        'A2', 'cooking', 15, 'Explain incorrect dish item and request replacement.', 'Waiter', 'Diner',
        'Excuse me, is everything tasting alright with your steak and salad?',
        '["Politely mention wrong order", "Explain requested temperature", "Request replacement dish", "Thank waiter"]'::jsonb,
        '["Excuse me, I ordered medium-rare.", "This dish is cold.", "Could you replace this?", "Thank you for fixing it."]'::jsonb, TRUE);

        -- A2-02
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Returning a Purchased Clothing Item', 'Return or exchange a defective clothing item at a store.', 
        'You work at customer service desk. Help customer return a defective sweater with receipt.',
        'A2', 'business', 15, 'State reason for return, show receipt, request refund.', 'Customer Service Clerk', 'Customer',
        'Hello! Welcome to Customer Service. How can I assist you today?',
        '["Present receipt and item", "Explain defect reason", "Choose refund or credit", "Confirm transaction"]'::jsonb,
        '["I would like to return this.", "It has a small tear.", "Here is my receipt.", "Can I get store credit?"]'::jsonb, TRUE);

        -- A2-03
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Booking a Guided City Tour', 'Inquire about city sightseeing schedules, prices, and spots.', 
        'You sell tour tickets for City Sightseeing. Explain bus vs walking tour packages.',
        'A2', 'travel', 15, 'Compare tour packages, departure times, and book tickets.', 'Tour Agent', 'Tourist',
        'Welcome to City Sightseeing! Are you interested in our historic walking tour or bus tour?',
        '["Ask walking vs bus tour", "Inquire tour duration", "Ask if audio guide included", "Book 2 tickets"]'::jsonb,
        '["What time does bus tour start?", "How long is walking tour?", "Are museum tickets included?", "I would like two tickets."]'::jsonb, TRUE);

        -- A2-04
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Asking Advice for a Mild Cold', 'Seek advice from a friend on traditional remedies for cold.', 
        'You are a caring friend giving herbal tea remedies advice for a mild sore throat.',
        'A2', 'science', 10, 'Describe cold symptoms and evaluate recommended remedies.', 'Friend', 'Sick Friend',
        'Oh no! You sound terrible today. Are you feeling under the weather?',
        '["Describe cold symptoms", "Ask herbal tea recommendations", "Thank friend for advice", "Plan rest"]'::jsonb,
        '["I have a sore throat.", "What tea do you recommend?", "Should I rest today?", "Thanks for checking on me!"]'::jsonb, TRUE);

        -- A2-05
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Handling Train Delays at Station', 'Inquire about delayed train schedules and alternative routes.', 
        'You are a train station agent assisting passengers affected by a 45-minute delay.',
        'A2', 'travel', 15, 'Ask delay cause, revised departure platform, and connection.', 'Station Agent', 'Passenger',
        'Attention passengers: Train 402 is delayed by 45 minutes due to maintenance.',
        '["Ask cause of train delay", "Inquire if connection missed", "Ask platform number", "Request ticket change"]'::jsonb,
        '["Why is the train delayed?", "Will I miss my connection?", "Which platform does it leave?", "Can I switch trains?"]'::jsonb, TRUE);

        -- A2-06
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Opening a Bank Checking Account', 'Set up a basic checking account with a bank teller.', 
        'You are a bank teller guiding a customer through opening a checking account.',
        'A2', 'business', 30, 'Provide documentation, select account type, ask about fees.', 'Bank Teller', 'Customer',
        'Good day! Welcome to First National Bank. How can I help you open an account?',
        '["Request checking account", "Provide passport/address proof", "Ask monthly maintenance fees", "Request debit card"]'::jsonb,
        '["I want to open a checking account.", "What documents do you need?", "Are there monthly fees?", "When will card arrive?"]'::jsonb, TRUE);

        -- A2-07
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Signing Up for Gym Membership', 'Inquire about monthly plans, equipment, and personal trainer.', 
        'You are a gym representative showing membership plans and facilities to a guest.',
        'A2', 'sports', 15, 'Compare membership tiers, gym hours, and trial pass.', 'Gym Sales Agent', 'Prospective Member',
        'Hey there! Ready to smash your fitness goals with us at PowerGym?',
        '["Ask monthly vs annual fee", "Inquire pool/sauna access", "Ask for free trial pass", "Complete sign up"]'::jsonb,
        '["How much is monthly fee?", "Is personal training included?", "What are opening hours?", "Can I try free pass today?"]'::jsonb, TRUE);

        -- A2-08
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Renting a Compact Car', 'Rent a vehicle at an airport rental counter.', 
        'You are a car rental agent processing driver license and insurance selection.',
        'A2', 'travel', 15, 'Select car class, add full insurance, check fuel policy.', 'Rental Car Agent', 'Driver',
        'Welcome to DriveFast Rental! Do you have a reservation confirmation code?',
        '["Present driver license", "Select compact vehicle", "Choose full insurance option", "Confirm return fuel policy"]'::jsonb,
        '["Here is my license.", "I want full insurance coverage.", "Is gas tank full?", "Where do I pick up keys?"]'::jsonb, TRUE);

        -- A2-09
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Doctor Consultation for Sprained Ankle', 'Describe a minor physical injury to a physician.', 
        'You are a physician examining a patient who twisted their ankle playing sports.',
        'A2', 'science', 15, 'Explain how injury occurred, pain level, and ask about X-ray.', 'Physician', 'Patient',
        'Hello! Come on in. What seems to be bothering your ankle today?',
        '["Explain how injury happened", "Rate pain scale 1-10", "Ask if X-ray needed", "Understand doctor rest advice"]'::jsonb,
        '["I twisted my ankle playing tennis.", "It hurts when I walk.", "Do I need an X-ray?", "How many days should I rest?"]'::jsonb, TRUE);

        -- A2-10
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Setting Roommate House Rules', 'Discuss cleaning schedules, quiet hours, and shared bills.', 
        'You are a roommate discussing cleaning rotation and quiet hours for a new flat.',
        'A2', 'daily', 15, 'Propose fair division of household chores and quiet hours.', 'Roommate', 'Roommate',
        'Hey! Now that we moved in together, let us agree on some basic ground rules.',
        '["Propose cleaning rotation", "Agree quiet hours for sleep", "Discuss utility bills split", "Establish guest policy"]'::jsonb,
        '["Let us alternate cleaning kitchen.", "Quiet hours after 10 PM sound good?", "We can split utility bills 50/50.", "Sounds fair to me!"]'::jsonb, TRUE);

        -- A2-11
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Describing Your Job Responsibilities', 'Explain your role, daily tasks, and tools to a new colleague.', 
        'You are a new employee asking a colleague about their job duties and daily tools.',
        'A2', 'business', 15, 'List main responsibilities, software used, and goals.', 'New Colleague', 'Employee',
        'Hi! I just joined the marketing department. Could you tell me what you do here?',
        '["State job title", "Describe daily responsibilities", "Mention software tools used", "Offer help onboarding"]'::jsonb,
        '["I am a digital marketing specialist.", "I manage social media campaigns.", "I use Analytics and Figma.", "Let me know if you need help!"]'::jsonb, TRUE);

        -- A2-12
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Shopping for a Birthday Gift', 'Ask store staff for recommendations for a friend gift.', 
        'You work at a gift shop recommending items based on budget and hobbies.',
        'A2', 'art', 15, 'Specify friend interests, budget limit, and gift wrapping.', 'Gift Specialist', 'Shopper',
        'Hello! Looking for a special gift for a birthday or anniversary today?',
        '["State recipient interests", "Set budget limit", "Ask item recommendations", "Request gift wrap"]'::jsonb,
        '["I am looking for a gift for my sister.", "She loves photography.", "My budget is around $50.", "Could you gift-wrap it?"]'::jsonb, TRUE);

        -- A2-13
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Explaining a Simple Recipe', 'Explain steps to prepare a simple regional dish to a friend.', 
        'You are a friend asking for step-by-step cooking instructions for pasta sauce.',
        'A2', 'cooking', 15, 'List main ingredients, cooking tools, and step order.', 'Friend', 'Home Cook',
        'Mmm! This pasta dish smells amazing! How do you prepare it?',
        '["List main ingredients", "Explain preparation steps", "Mention cooking time/heat", "Offer flavor tips"]'::jsonb,
        '["First, chop garlic and onions.", "Boil pasta in salted water.", "Simmer sauce for 15 minutes.", "Top with fresh parmesan cheese!"]'::jsonb, TRUE);

        -- A2-14
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Planning a Weekend Trip', 'Discuss weekend getaway destinations, transport, and lodging.', 
        'You are planning a weekend mountain road trip with a travel partner.',
        'A2', 'travel', 15, 'Propose location ideas, compare train vs car, agree on lodging.', 'Travel Partner', 'Traveler',
        'Hey! Next weekend is a long weekend. Want to take a short trip somewhere?',
        '["Suggest destination ideas", "Compare train vs car rental", "Propose budget hotel/cabin", "Set departure time"]'::jsonb,
        '["How about driving to the lake?", "The train takes only two hours.", "We can book a cozy cabin.", "Let us leave Friday evening!"]'::jsonb, TRUE);

        -- A2-15
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Historic Neighborhood Tour', 'Explore a historic district with a local resident guide.', 
        'You are a local tour guide showing visitors around 19th-century architecture.',
        'A2', 'history', 30, 'Ask about historic significance, local dining, and safety.', 'Local Guide', 'Visitor',
        'Welcome to Old Town Plaza! This cathedral was constructed back in 1850.',
        '["Ask historic significance", "Inquire best local restaurants", "Ask where to take photos", "Thank guide"]'::jsonb,
        '["How old is this cathedral?", "Where do locals eat around here?", "Is it safe to walk at night?", "This architecture is beautiful."]'::jsonb, TRUE);

        -- A2-16
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Reporting a Lost Wallet', 'Report a lost wallet at transit lost-and-found office.', 
        'You work at transit lost property office taking detailed loss reports.',
        'A2', 'daily', 15, 'Describe item appearance, contents, location, and phone.', 'Lost Property Officer', 'Citizen',
        'Lost Property Office. Please describe the item you misplaced on transit.',
        '["Describe wallet color/material", "List contents (ID, cash)", "State last known location", "Leave contact phone"]'::jsonb,
        '["I lost a black leather wallet.", "It contains my ID and two cards.", "I left it on bus route 14.", "My phone number is..."]'::jsonb, TRUE);

        -- A2-17
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Hairdresser Appointment Styling', 'Communicate hair styling preferences at a hair salon.', 
        'You are a hair stylist asking how much length to trim for a customer.',
        'A2', 'art', 15, 'Explain haircut style, length to trim, and shampoo wash.', 'Hair Stylist', 'Client',
        'Welcome! Take a seat in the chair. How are we styling your hair today?',
        '["Specify length to trim", "Describe requested haircut style", "Decide on shampoo wash", "Confirm satisfaction"]'::jsonb,
        '["Just a trim on sides, please.", "Keep the top a bit longer.", "Not too short on back.", "Looks great, thank you!"]'::jsonb, TRUE);

        -- A2-18
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Inquiring About Music Festival', 'Ask for details about an upcoming summer music festival.', 
        'You staff the info booth for Summer Fest answering lineup and ticket questions.',
        'A2', 'music', 15, 'Inquire about band lineup, ticket prices, and parking.', 'Festival Info Staff', 'Attendee',
        'Hi there! Excited for Summer Music Fest happening this weekend?',
        '["Ask who main headliners are", "Check day pass ticket price", "Ask food stalls available", "Inquire parking location"]'::jsonb,
        '["Which bands play Saturday?", "How much is a day pass?", "Are outside drinks allowed?", "Where can I park my car?"]'::jsonb, TRUE);

        -- A2-19
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Getting a Public Library Card', 'Register for a public library card and borrow books.', 
        'You are a librarian helping a new resident sign up for a library card.',
        'A2', 'history', 10, 'Provide address proof, fill form, ask borrowing limits.', 'Librarian', 'Patron',
        'Hello! Welcome to Public Library. Would you like to register for a library card?',
        '["Fill out registration form", "Show proof of address", "Ask maximum borrowing limit", "Inquire about e-books"]'::jsonb,
        '["I would like a library card.", "Here is my utility bill proof.", "How many books can I borrow?", "Is e-book access free?"]'::jsonb, TRUE);

        -- A2-20
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Ordering Food Delivery by Phone', 'Place a phone order for takeaway delivery to apartment.', 
        'You take delivery phone orders for a Thai food restaurant.',
        'A2', 'cooking', 10, 'Specify food items, spice level, address, and cash payment.', 'Delivery Dispatcher', 'Customer',
        'Hello! Thanks for calling Spicy Thai Delivery. What can I get for you?',
        '["State food items and spice level", "Provide complete delivery address", "Ask delivery time estimate", "Choose payment method"]'::jsonb,
        '["I would like Pad Thai chicken.", "Medium spicy, please.", "My address is 45 Main St Apt 3B.", "Will pay cash on delivery."]'::jsonb, TRUE);


        -- ==========================================
        -- NIVEL B1: INTERMEDIO (20 LECCIONES)
        -- ==========================================

        -- B1-01
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Job Interview: Strengths & Weaknesses', 'Answer classic job interview questions about professional skills.', 
        'You are a hiring manager interviewing a candidate. Ask about core strengths, weaknesses, and past achievements.',
        'B1', 'business', 30, 'Describe key strengths, managed weakness, and past work example.', 'Hiring Manager', 'Job Candidate',
        'Welcome to your interview today. To start off, tell me about your greatest professional strength.',
        '["Highlight core professional strength", "Explain weakness with improvement step", "Provide past work accomplishment", "Express enthusiasm for role"]'::jsonb,
        '["One of my main strengths is problem solving.", "I used to struggle with delegation, but now...", "In my last role, I successfully led...", "I am excited about this opportunity."]'::jsonb, TRUE);

        -- B1-02
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Describing Past Work Challenges', 'Narrate a difficult work situation and how you resolved it.', 
        'You are an interviewer asking candidate to use STAR method (Situation, Task, Action, Result) for past challenge.',
        'B1', 'business', 30, 'Use STAR structure to describe project delay and resolution.', 'Interviewer', 'Candidate',
        'Can you describe a specific time when a project did not go according to original plan?',
        '["Describe initial problem situation", "Explain action plan implemented", "Highlight team collaboration", "Share positive outcome metrics"]'::jsonb,
        '["We faced a tight deadline when...", "I organized emergency stand-up meetings.", "As a result, we delivered on time.", "I learned the value of clear communication."]'::jsonb, TRUE);

        -- B1-03
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Apartment Viewing with Landlord', 'Inspect a rental apartment and discuss lease terms.', 
        'You are a landlord showing a 2-bedroom flat and discussing rent, deposit, and utility terms.',
        'B1', 'daily', 30, 'Evaluate apartment condition, ask about utilities, deposit, and date.', 'Landlord', 'Prospective Tenant',
        'Welcome! This is the two-bedroom apartment. Feel free to look around the rooms!',
        '["Inspect appliances and lighting", "Ask if utilities included in rent", "Discuss security deposit amount", "Negotiate lease start date"]'::jsonb,
        '["Are utilities included in rent?", "How much is security deposit?", "When is earliest move-in date?", "Is parking space included?"]'::jsonb, TRUE);

        -- B1-04
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Troubleshooting Software Bug with IT', 'Describe a computer software glitch to IT support technician.', 
        'You are an IT helpdesk specialist guiding user through error logs and app restart steps.',
        'B1', 'technology', 15, 'Explain error message, steps leading to crash, and OS version.', 'IT Support Specialist', 'User',
        'IT Help Desk. What technical software issue are you experiencing on your computer today?',
        '["Describe error message text", "Explain action causing crash", "Confirm OS version", "Follow IT technician steps"]'::jsonb,
        '["My app crashes when I click export.", "The error code shows 500.", "I tried restarting the computer already.", "Should I reinstall the app?"]'::jsonb, TRUE);

        -- B1-05
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Customer Service Refund Negotiation', 'Resolve a product dispute with online retail manager.', 
        'You are a retail customer service manager handling a damaged product complaint.',
        'B1', 'business', 15, 'Explain damaged item, cite return policy, demand full refund.', 'Support Manager', 'Customer',
        'Thank you for contacting customer support. How can I resolve your order issue today?',
        '["Explain damaged item condition", "Reference order number and policy", "Reject replacement if damaged", "Insist on full refund"]'::jsonb,
        '["The item arrived completely damaged.", "My order number is 98765.", "According to policy, I am eligible for refund.", "I expect full refund to my card."]'::jsonb, TRUE);

        -- B1-06
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Discussing Favorite Movies & Themes', 'Critique a film plot, actor performances, and themes.', 
        'You are a movie enthusiast discussing latest cinema releases and directing styles.',
        'B1', 'music', 15, 'Express opinions on acting, plot twists, and recommendations.', 'Film Buff', 'Movie Fan',
        'Did you watch that new sci-fi movie everyone has been talking about recently?',
        '["Share overall movie impression", "Discuss lead actor performance", "Analyze plot twists message", "Recommend film to friend"]'::jsonb,
        '["Visual effects were incredible.", "The plot twist surprised me.", "Pacing felt a bit slow.", "I highly recommend watching it."]'::jsonb, TRUE);

        -- B1-07
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Planning a Group Trip Budget', 'Coordinate travel logistics and budget allocation with friends.', 
        'You are organizing a summer group vacation with a budget of $500 per person.',
        'B1', 'travel', 30, 'Balance accommodation costs, food expenses, and transport.', 'Trip Organizer', 'Group Member',
        'Let us finalize our summer vacation budget! We have about $500 budget per person.',
        '["Propose budget allocation hotel/food", "Suggest cost-saving travel hacks", "Agree on group activities", "Set up shared expense app"]'::jsonb,
        '["We should prioritize central lodging.", "Cooking breakfast saves money.", "Let us split transit costs evenly.", "I will track expenses in app."]'::jsonb, TRUE);

        -- B1-08
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Weekly Office Status Update Meeting', 'Give a concise progress update on your active project tasks.', 
        'You are a project manager hosting weekly team stand-up for project status updates.',
        'B1', 'business', 15, 'Summarize completed tasks, blockers, and next priorities.', 'Project Manager', 'Team Member',
        'Alright team, let us go around the table. What did you accomplish this week?',
        '["Report completed weekly tasks", "Mention current blockers/dependencies", "Outline top priority next week", "Ask colleague input"]'::jsonb,
        '["This week I completed database migration.", "I am blocked by design approval.", "Next week I focus on testing.", "Can we sync after this call?"]'::jsonb, TRUE);

        -- B1-09
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Resolving Missing Package Shipping Issue', 'Track a missing delivery package and arrange redelivery.', 
        'You are a logistics agent checking tracking numbers and delivery driver status.',
        'B1', 'business', 15, 'Provide tracking code, verify address, demand status update.', 'Logistics Agent', 'Customer',
        'Express Shipping support. How can I check your delivery package status today?',
        '["Provide tracking number", "Explain missing package date", "Verify address instructions", "Request priority redelivery"]'::jsonb,
        '["Tracking says delivered, but not received.", "Here is my tracking code.", "Can you contact driver directly?", "Please arrange redelivery tomorrow."]'::jsonb, TRUE);

        -- B1-10
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Setting Fitness & Health Targets', 'Discuss health habits and realistic targets with a trainer.', 
        'You are a wellness coach evaluating client fitness goals, diet, and tracking.',
        'B1', 'sports', 30, 'Define measurable targets (endurance, weight) and diet habits.', 'Wellness Coach', 'Client',
        'Welcome to your wellness evaluation! What health goals do you want to achieve?',
        '["State primary health goal", "Discuss current diet/exercise", "Set 3-month target", "Agree weekly check-ins"]'::jsonb,
        '["I want to run a 10k race in three months.", "I currently exercise twice a week.", "I need help planning balanced meals.", "Let us track progress weekly."]'::jsonb, TRUE);

        -- B1-11
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Volunteering for Community Park Cleanup', 'Inquire about volunteer roles for local environmental cleanup.', 
        'You are volunteer coordinator signing up citizens for eco-cleanup projects.',
        'B1', 'science', 30, 'Express interest, discuss weekend availability, and tasks.', 'Volunteer Coordinator', 'Volunteer',
        'Thank you for reaching out to EcoClean Community! Ready to make a difference?',
        '["State volunteer motivation", "Specify weekend hours available", "Select planting/cleanup activity", "Ask what equipment to bring"]'::jsonb,
        '["I want to improve local parks.", "I am free on Saturday mornings.", "I prefer outdoor planting activities.", "Do I need to bring my own gloves?"]'::jsonb, TRUE);

        -- B1-12
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Organizing a Surprise Birthday Party', 'Plan secret party details (venue, cake, guest list) with co-organizer.', 
        'You are co-organizing a surprise 30th birthday party for a mutual friend.',
        'B1', 'music', 15, 'Delegate food, music, secret arrival time, and guest list.', 'Co-Planner', 'Party Organizer',
        'Shh! Let us plan Sarah surprise 30th birthday party without her knowing!',
        '["Suggest secret venue", "Assign cake and music tasks", "Create secret group chat", "Establish guest arrival timeline"]'::jsonb,
        '["We must keep this secret.", "I will handle birthday cake and drinks.", "Everyone must arrive 30 min early.", "I will create a hidden event page."]'::jsonb, TRUE);

        -- B1-13
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Discussing Long-Term Career Ambitions', 'Discuss career growth, promotion goals, and skill gaps with mentor.', 
        'You are a senior career mentor helping a junior professional map out 5-year goals.',
        'B1', 'business', 30, 'Share 5-year vision, identify skill gaps, seek advice.', 'Career Mentor', 'Mentee',
        'Where do you see yourself professionally in the next three to five years?',
        '["Share 5-year career vision", "Identify skills needed", "Ask mentor for actionable advice", "Plan next steps"]'::jsonb,
        '["I aim to transition into management.", "I need to improve public speaking.", "What certifications do you recommend?", "Thank you for valuable guidance."]'::jsonb, TRUE);

        -- B1-14
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Resolving Workplace Miscommunication', 'Clarify miscommunication over task ownership with colleague.', 
        'You are a colleague resolving a misunderstanding about presentation deck ownership.',
        'B1', 'business', 30, 'Politely explain perspective, listen actively, set task split.', 'Colleague', 'Team Member',
        'Hey, I felt there was some confusion about who was presenting slides today.',
        '["Acknowledge communication gap", "Explain initial understanding", "Propose clear task division", "Agree future sync protocol"]'::jsonb,
        '["I apologize for the misunderstanding.", "I thought you wanted me to cover section two.", "Let us clearly divide presentation topics.", "We should confirm in writing next time."]'::jsonb, TRUE);

        -- B1-15
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Adopting Sustainable Daily Habits', 'Debate practical ways to reduce plastic waste and energy footprint.', 
        'You are an eco-activist discussing daily recycling and energy saving habits.',
        'B1', 'science', 15, 'Discuss eco-friendly habits (reusable bags, transit) and challenges.', 'Eco Activist', 'Citizen',
        'What daily changes have you made recently to live more sustainably?',
        '["Mention reusable bags and bottles", "Discuss reducing energy consumption", "Debate recycling challenges", "Encourage community habits"]'::jsonb,
        '["I started bringing reusable cloth bags.", "I switched to public transit.", "Recycling rules can be confusing.", "Every small habit makes a difference."]'::jsonb, TRUE);

        -- B1-16
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Designing Remote Work Home Office', 'Discuss ergonomic furniture, internet reliability, and work boundaries.', 
        'You are a remote work advisor evaluating home office ergonomics and routines.',
        'B1', 'technology', 30, 'Evaluate dual monitors, ergonomic chair, internet, and work hours.', 'Remote Advisor', 'Remote Employee',
        'Working from home can be great if your setup is right! How is your office setup?',
        '["Describe desk and monitor setup", "Discuss ergonomic chair posture", "Mention internet speed needs", "Set work hour boundaries"]'::jsonb,
        '["I bought dual monitors recently.", "I need better ergonomic office chair.", "High-speed internet is essential.", "I log off strictly at 6 PM."]'::jsonb, TRUE);

        -- B1-17
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Selecting University Elective Courses', 'Discuss university course choices with an academic advisor.', 
        'You are an academic advisor reviewing course credits and syllabi with a student.',
        'B1', 'history', 30, 'Compare history vs literature courses, exams, and credit count.', 'Academic Advisor', 'University Student',
        'Hello! Let us review your elective choices for the upcoming semester.',
        '["Express interest in history vs literature", "Ask about exam vs essay grade", "Check prerequisite requirements", "Finalize course registration"]'::jsonb,
        '["I am considering World History 201.", "Is grade based on essays or exams?", "Does this course satisfy credit count?", "I will enroll in this course."]'::jsonb, TRUE);

        -- B1-18
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Bargaining Price at Flea Market', 'Negotiate price for antique souvenirs with street vendor.', 
        'You are a flea market antique vendor negotiating prices with a savvy tourist.',
        'B1', 'travel', 15, 'Politely offer lower counter-price, point out wear, reach deal.', 'Market Vendor', 'Buyer',
        'Step right up! Authentic hand-crafted vintage clock. Only $80 today!',
        '["Politely question original price", "Offer lower counter-price", "Highlight minor scratch wear", "Agree fair final price"]'::jsonb,
        '["That is a bit above my budget.", "Would you accept $50 for this clock?", "It has a tiny scratch on the side.", "Let us deal at $60, cash."]'::jsonb, TRUE);

        -- B1-19
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Handling Flight Schedule Changes', 'Rebook a missed connecting flight at airline customer desk.', 
        'You are an airline agent rebooking passengers affected by flight delay.',
        'B1', 'travel', 15, 'Explain missed connection, ask next flight, request meal voucher.', 'Airline Agent', 'Passenger',
        'I am sorry your incoming flight arrived late. Let me help rebook your seat.',
        '["Explain missed connection cause", "Request seat on next flight", "Inquire about meal vouchers", "Confirm baggage transfer"]'::jsonb,
        '["My incoming flight was delayed.", "What is next available flight?", "Am I eligible for meal voucher?", "Will luggage transfer automatically?"]'::jsonb, TRUE);

        -- B1-20
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Comparing Cultural Traditions & Holidays', 'Discuss holiday traditions, food customs, and celebrations.', 
        'You are an international exchange student sharing holiday customs and food.',
        'B1', 'history', 30, 'Describe holiday meals, family gatherings, contrast customs.', 'International Peer', 'Student',
        'In my country, New Year is celebrated with family dinners. How about yours?',
        '["Describe holiday traditional foods", "Explain family gathering customs", "Compare gift-giving traditions", "Express appreciation for diversity"]'::jsonb,
        '["We prepare a big family feast on New Year Eve.", "Firework displays light up the city.", "It is fascinating how cultures celebrate differently.", "I would love to experience your tradition!"]'::jsonb, TRUE);


        -- ==========================================
        -- NIVEL B2: INTERMEDIO ALTO (20 LECCIONES)
        -- ==========================================

        -- B2-01
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Senior Tech Developer Architecture Interview', 'Demonstrate technical expertise, microservices, and system design.', 
        'You are a Lead Tech Architect evaluating senior developer candidate on microservices API scaling.',
        'B2', 'technology', 30, 'Explain Redis caching, SQL vs NoSQL, and scaling trade-offs.', 'Lead Architect', 'Senior Developer Candidate',
        'Welcome! To start off, how do you handle scaling a high-traffic microservices API?',
        '["Explain microservice Redis caching", "Discuss trade-offs SQL vs NoSQL", "Describe incident debugging process", "Demonstrate engineering leadership"]'::jsonb,
        '["I recommend implementing Redis caching.", "We prioritized horizontal scaling for traffic.", "Monolith vs microservices depends on domain.", "I emphasize automated CI/CD testing."]'::jsonb, TRUE);

        -- B2-02
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Pitching a New Product Feature', 'Present a compelling product roadmap proposal to stakeholders.', 
        'You are Product Director listening to product manager feature pitch for AI onboarding.',
        'B2', 'business', 30, 'Highlight user pain point, ROI metrics, timeline, and objection.', 'Product Director', 'Product Manager',
        'You have 5 minutes to pitch your proposed AI feature to the board. Go ahead!',
        '["State core user pain point", "Present AI feature prototype solution", "Show projected user retention metrics", "Answer stakeholder objections"]'::jsonb,
        '["Data shows 40% user drop-off at onboarding.", "Introducing AI guide increases conversion.", "Initial development takes 6 weeks.", "Expected ROI is 25% revenue boost."]'::jsonb, TRUE);

        -- B2-03
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Debating Remote vs Hybrid Work Policies', 'Participate in corporate debate on office attendance rules.', 
        'You are Operations Director arguing for 4-day office mandate vs flexible remote work.',
        'B2', 'business', 30, 'Present remote pros, counter culture arguments, propose 2-day hybrid.', 'Operations Director', 'HR Manager',
        'Our executive team wants to mandate 4 days in the office. What is your stance?',
        '["Present remote pros for talent retention", "Counter with culture in-person benefits", "Propose compromised 2-day hybrid model", "Suggest measuring output over hours"]'::jsonb,
        '["Mandating 4 days risks losing key talent.", "Studies prove remote workers maintain high productivity.", "Flexible hybrid offers best of both worlds.", "We should evaluate performance on deliverables."]'::jsonb, TRUE);

        -- B2-04
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Salary & Equity Package Negotiation', 'Negotiate executive compensation, bonuses, and stock options.', 
        'You are VP of Talent offering executive role and negotiating base salary and equity.',
        'B2', 'business', 30, 'Benchmark market rates, articulate value, secure written offer.', 'VP of Talent', 'Senior Executive Candidate',
        'We are excited to offer you the Director position at $130,000 base salary.',
        '["Thank VP while benchmarking market value", "Request higher base or stock options", "Inquire performance bonus criteria", "Secure agreed final terms in writing"]'::jsonb,
        '["Thank you for the offer.", "Based on industry benchmarks, I seek $145,000.", "Can we structure a performance bonus trigger?", "I look forward to the revised letter."]'::jsonb, TRUE);

        -- B2-05
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Expressing Nuanced Opinions in Debates', 'Articulate balanced perspectives on complex social issues.', 
        'You host a debate club evaluating whether public transit should be 100% free.',
        'B2', 'history', 30, 'State initial stance, acknowledge counter-arguments, propose compromise.', 'Debate Host', 'Participant',
        'Today topic: Should public transit be completely free for all citizens in major cities?',
        '["State initial nuanced position", "Acknowledge economic funding arguments", "Highlight environmental/equality benefits", "Conclude pragmatic funding solution"]'::jsonb,
        '["While free transit reduces emissions, funding requires tax changes.", "On one hand, it improves accessibility.", "On the other hand, service quality matters.", "A subsidized tier system is most realistic."]'::jsonb, TRUE);

        -- B2-06
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Modern Art Gallery Exhibition Critique', 'Analyze conceptual art pieces with a gallery curator.', 
        'You are a gallery curator discussing modern abstract steel installations.',
        'B2', 'art', 30, 'Interpret symbolism of materials, lighting, and give verdict.', 'Gallery Curator', 'Art Critic',
        'What are your thoughts on this abstract installation crafted from recycled steel?',
        '["Interpret symbolic meaning of materials", "Critique spatial arrangement and lighting", "Contrast with traditional sculpture", "Formulate overall artistic verdict"]'::jsonb,
        '["Raw steel creates contrast with organic textures.", "It evokes industrial isolation.", "Lighting emphasizes shadows dramatically.", "It challenges conventional definitions of form."]'::jsonb, TRUE);

        -- B2-07
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Managing a Disappointed Key Client', 'De-escalate a major client crisis after a server outage.', 
        'You are an enterprise client furious about a 2-hour software outage.',
        'B2', 'business', 30, 'Apologize sincerely, explain root cause, offer service credit.', 'Enterprise Client', 'Account Director',
        'Your system outage yesterday cost our company thousands of dollars! Explain yourself!',
        '["Acknowledge severity and express apology", "Provide clear technical root cause", "Detail immediate prevention measures", "Offer credit compensation for trust"]'::jsonb,
        '["I completely understand your frustration.", "Downtime was caused by server hardware failure.", "We deployed redundant backups to prevent recurrence.", "We are issuing a full service credit this month."]'::jsonb, TRUE);

        -- B2-08
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Requesting a Project Deadline Extension', 'Negotiate additional project timeline with demanding client.', 
        'You are a client sponsor expecting release delivery this Friday.',
        'B2', 'business', 30, 'Explain technical complexity, security risks, propose phased launch.', 'Client Sponsor', 'Project Lead',
        'We expect the full software release this Friday as originally agreed in scope.',
        '["Explain unforeseen technical complexity", "Warn about risk to security if rushed", "Propose phased delivery model", "Commit to firm milestone date"]'::jsonb,
        '["To guarantee security, we need two extra weeks.", "Rushing launch could compromise data integrity.", "We can release core features Friday and secondary later.", "This ensures a flawless user experience."]'::jsonb, TRUE);

        -- B2-09
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Debating Environmental Energy Policies', 'Discuss renewable energy transition strategies and economic impacts.', 
        'You are an environmental economist debating carbon tax vs green innovation subsidies.',
        'B2', 'science', 45, 'Analyze carbon tax models, grid stability, and corporate incentives.', 'Environmental Economist', 'Policy Researcher',
        'Is a global carbon tax the most effective policy mechanism against climate change?',
        '["Evaluate economic impact carbon pricing", "Discuss renewable grid transition challenges", "Address opposition heavy industries", "Propose green innovation subsidies"]'::jsonb,
        '["Carbon pricing creates financial incentive for clean energy.", "We must prevent energy price spikes for consumers.", "Battery storage infrastructure is critical.", "Subsidizing green tech yields economic benefits."]'::jsonb, TRUE);

        -- B2-10
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Pitching a Startup Idea to VC Investors', 'Deliver a 3-minute pitch deck presentation to venture capitalists.', 
        'You are a venture capitalist evaluating EdTech SaaS traction and funding request.',
        'B2', 'business', 30, 'Articulate market size, traction metrics, SaaS model, funding ask.', 'Venture Capitalist', 'Startup Founder',
        'You have 3 minutes to pitch your AI EdTech platform. Pitch away!',
        '["Define market opportunity size", "Demonstrate current user growth metrics", "Explain SaaS subscription model", "State explicit investment capital request"]'::jsonb,
        '["The language market is a $60B global opportunity.", "Our AI voice tutor achieves 3x higher engagement.", "We operate a scalable Freemium B2C model.", "We are raising $1.5M to scale engineering."]'::jsonb, TRUE);

        -- B2-11
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Navigating Complex Government Bureaucracy', 'Resolve visa or residency permit documentation roadblocks.', 
        'You are an immigration officer rejecting visa application due to translation certs.',
        'B2', 'history', 30, 'Inquire exact missing documents, ask extension permit, resubmit.', 'Immigration Officer', 'Applicant',
        'Your visa application is missing certified translations of tax records.',
        '["Request clarification on missing documents", "Explain previous submission attempt", "Ask temporary extension permit", "Confirm fast-track resubmission"]'::jsonb,
        '["Which tax records require certified translation?", "Can I submit digital copies online today?", "Is temporary processing extension possible?", "Thank you for clarifying exact steps."]'::jsonb, TRUE);

        -- B2-12
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Discussing Ethics in Artificial Intelligence', 'Debate AI training bias, data privacy, and job automation.', 
        'You are an AI ethics researcher discussing algorithmic audit frameworks.',
        'B2', 'technology', 45, 'Analyze training bias, corporate responsibility, and human oversight.', 'AI Ethics Researcher', 'Software Engineer',
        'As AI models become autonomous, who should be held accountable for system errors?',
        '["Discuss training data bias in ML", "Debate corporate responsibility vs developer", "Propose regulatory audit frameworks", "Emphasize human-in-loop oversight"]'::jsonb,
        '["AI models reflect biases present in training data.", "Developers must implement transparent audit algorithms.", "Regulatory frameworks should require safety testing.", "Maintaining human oversight is vital."]'::jsonb, TRUE);

        -- B2-13
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Handling Team Conflict as a Manager', 'Mediate an interpersonal dispute between two lead engineers.', 
        'You are an engineering manager listening to team conflict over code reviews.',
        'B2', 'business', 30, 'Listen neutrally, reframe around shared goals, set code standards.', 'Engineering Manager', 'Conflicting Engineer',
        'Thanks for meeting privately. Things have been tense between you and Alex lately.',
        '["Listen to engineer perspective without bias", "Reframe conflict around shared goals", "Establish objective coding guidelines", "Set follow-up check-in date"]'::jsonb,
        '["I want to understand your perspective on code reviews.", "Both contributions are essential to team.", "Let us agree on objective coding guidelines.", "We will review progress in two weeks."]'::jsonb, TRUE);

        -- B2-14
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Handling an Emergency Situation Abroad', 'Manage a stolen passport and emergency medical situation in foreign city.', 
        'You are consular agent assisting citizen with stolen passport and travel cert.',
        'B2', 'travel', 30, 'Contact embassy, report theft, request emergency travel certificate.', 'Consular Agent', 'Stranded Traveler',
        'Emergency Consular Services. Please state your urgency and location.',
        '["Report stolen passport and cards", "Request emergency travel certificate", "Confirm proof of citizenship", "Coordinate emergency money transfer"]'::jsonb,
        '["My passport and wallet were stolen at station.", "I need emergency travel document for tomorrow.", "I have digital copies of ID stored online.", "What is fastest replacement procedure?"]'::jsonb, TRUE);

        -- B2-15
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Commercial Real Estate Investment Pitch', 'Negotiate commercial office lease or property acquisition terms.', 
        'You are a real estate broker presenting downtown commercial property return.',
        'B2', 'business', 45, 'Analyze cap rate, tenant lease terms, ask tenant improvement money.', 'Real Estate Broker', 'Corporate Investor',
        'This downtown commercial building yields a projected 8% annual return.',
        '["Analyze cap rate and tenant lease terms", "Inquire building maintenance history", "Negotiate tenant improvement allowance", "Propose counter-offer price"]'::jsonb,
        '["What is current building occupancy rate?", "We need $50,000 tenant improvement allowance.", "Requested price per square foot is above market.", "We are prepared to submit letter of intent."]'::jsonb, TRUE);

        -- B2-16
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Public Speaking Keynote Preparation', 'Rehearse a conference keynote speech with communications coach.', 
        'You are a speech coach evaluating opening story hook and vocal pacing.',
        'B2', 'art', 30, 'Deliver memorable hook, control vocal pacing, integrate feedback.', 'Speech Coach', 'Keynote Speaker',
        'Let us practice your keynote opening! Give me your first two minutes.',
        '["Deliver memorable story opening hook", "Control vocal pacing and strategic pauses", "Engage audience with questions", "Incorporate coach feedback"]'::jsonb,
        '["Imagine a world where language barriers vanish.", "I will slow down pace during key statistics.", "Does this slide transition feel natural?", "Thank you for constructive feedback."]'::jsonb, TRUE);

        -- B2-17
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Corporate Crisis Mitigation Strategy', 'Formulate emergency response plan following data leak.', 
        'You are Chief Risk Officer drafting public PR statement after security incident.',
        'B2', 'business', 45, 'Outline containment, draft public PR statement, notify regulators.', 'Chief Risk Officer', 'Communications Lead',
        'We just discovered a database breach affecting 50,000 customer records. What is our plan?',
        '["Outline technical containment steps", "Draft transparent public statement to users", "Notify data protection regulatory authorities", "Set up dedicated support hotline"]'::jsonb,
        '["Top priority is securing compromised server immediately.", "Transparency is critical; notify users in 24 hrs.", "We will offer free credit monitoring.", "Let us prepare official press release now."]'::jsonb, TRUE);

        -- B2-18
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Analyzing Media Bias & News Credibility', 'Critique news articles for sensationalism, bias, and source verification.', 
        'You are a journalism professor analyzing sensationalist headlines and unverified sources.',
        'B2', 'history', 30, 'Identify biased language, evaluate sources, synthesize objective facts.', 'Journalism Professor', 'Media Analyst',
        'Look at these two articles reporting on the same political event. Notice the tone difference?',
        '["Identify biased language and sensational terms", "Evaluate reliability of cited sources", "Discuss social media algorithm impact", "Formulate objective summary of facts"]'::jsonb,
        '["Article A uses emotionally loaded words.", "Article B relies on unverified sources.", "Outlets tailor coverage to subscriber demographics.", "Cross-referencing facts is essential."]'::jsonb, TRUE);

        -- B2-19
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Strategic Career Pivot Discussion', 'Discuss changing career paths from traditional industry to tech startup.', 
        'You are a career advisor guiding financial analyst into product management.',
        'B2', 'business', 30, 'Highlight transferable skills, address skill gaps, plan portfolio.', 'Career Advisor', 'Professional',
        'Transitioning from finance into product management is ambitious! Let us plan it.',
        '["Highlight transferable analytical skills", "Identify critical skill gaps (UX, tech stack)", "Plan bootcamp or project portfolio", "Develop targeted networking approach"]'::jsonb,
        '["Financial analysis translates well to product data.", "I am completing product management certification.", "I am building a portfolio of case studies.", "How can I leverage my network for referrals?"]'::jsonb, TRUE);

        -- B2-20
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Sports Performance Data Analytics', 'Analyze athlete biomechanics and recovery data with sports scientist.', 
        'You are a sports scientist analyzing GPS tracking and heart rate variability data.',
        'B2', 'sports', 30, 'Evaluate athlete workload metrics, prevent fatigue, optimize training.', 'Sports Scientist', 'Head Coach',
        'Our GPS tracking shows mid-fielders ran 12 kilometers yesterday with high fatigue indicators.',
        '["Analyze heart rate variability metrics", "Adjust training intensity workload", "Implement recovery cold-water protocols", "Formulate match day lineup strategy"]'::jsonb,
        '["High fatigue indicators suggest risk of muscle strain.", "We should reduce tactical session intensity today.", "Cryotherapy acceleration aids recovery.", "We will rotation key players on Saturday."]'::jsonb, TRUE);


        -- ==========================================
        -- NIVEL C1: AVANZADO (20 LECCIONES)
        -- ==========================================

        -- C1-01
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Contract Scope & Royalty Negotiation', 'Negotiate complex legal clauses, liability caps, and royalty percentages.', 
        'You are Corporate General Counsel debating liability caps and IP ownership clauses.',
        'C1', 'business', 45, 'Propose liability cap equal to 12 months fee, IP transfer, royalty scale.', 'General Counsel', 'Contract Negotiator',
        'We cannot accept unlimited liability in section 4.2 of the software agreement.',
        '["Propose liability cap equal to 12 months fee", "Negotiate IP ownership transfer clauses", "Refine royalty percentage scale", "Finalize binding arbitration venue"]'::jsonb,
        '["We propose capping liability at annual contract value.", "Intellectual property remains our sole asset.", "Royalty rates should tier based on volume.", "Let us draft revised mutual indemnification language."]'::jsonb, TRUE);

        -- C1-02
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Academic Debate on Macroeconomic Policy', 'Debate fiscal policy, inflation control, and central bank interest rates.', 
        'You are a macroeconomist analyzing quantitative easing vs rate hikes.',
        'C1', 'history', 45, 'Deconstruct inflation triggers, evaluate rate hikes, cite historical stagflation.', 'Macroeconomist', 'Policy Researcher',
        'Should central banks prioritize aggressive inflation suppression over job growth?',
        '["Deconstruct inflation triggers and supply factors", "Evaluate economic tradeoffs rate hikes", "Cite historical stagflation precedents", "Synthesize balanced fiscal policy proposal"]'::jsonb,
        '["Aggressive rate increases risk recessionary spiral.", "Supply constraints require targeted fiscal intervention.", "Historical precedent from 1970s illustrates costs.", "A dual-mandate approach is necessary."]'::jsonb, TRUE);

        -- C1-03
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Executive Board Strategy Review', 'Defend annual strategic roadmap and capital allocation before board.', 
        'You are Board Chairman questioning CEO on $10M expansion into emerging markets.',
        'C1', 'business', 45, 'Present demographic growth, mitigate currency volatility, 3-year EBITDA.', 'Board Chairman', 'Chief Executive Officer',
        'CEO, explain why we should allocate $10M into emerging Latin American markets.',
        '["Present demographic growth and market gap data", "Address political and currency volatility risks", "Outline 3-year EBITDA profitability projection", "Secure unanimous board approval"]'::jsonb,
        '["Latin America represents our fastest growing user base.", "We mitigated currency risk via local partnerships.", "Financial modeling projects breakeven in 18 months.", "I welcome board vote to approve expansion."]'::jsonb, TRUE);

        -- C1-04
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Philosophical Ethics & AI Consciousness', 'Debate moral personhood, utilitarian ethics, and artificial sentience.', 
        'You are an Ethics Professor evaluating functional simulation vs subjective qualia.',
        'C1', 'history', 45, 'Differentiate simulation vs phenomenology, apply Kantian/Utilitarian frameworks.', 'Ethics Professor', 'Philosopher',
        'If an AI system simulates pain convincingly, does it possess moral status?',
        '["Differentiate simulation from subjective qualia", "Apply Kantian vs Utilitarian framework to synthetic minds", "Examine Turing test limits for moral agency", "Propose ethical safeguards for superintelligence"]'::jsonb,
        '["Simulated behavior does not imply subjective qualia.", "From utilitarian lens, causing distress is immoral.", "Distinguish moral agency from moral patienthood.", "Ethical frameworks must adapt to synthetic cognition."]'::jsonb, TRUE);

        -- C1-05
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Literary Analysis of Post-War Fiction', 'Deconstruct narrative structure, existentialism, and motif symbolism.', 
        'You are a Literature Professor analyzing unreliable narrators in post-war novels.',
        'C1', 'art', 30, 'Analyze linguistic symbolism, unreliable narrator, post-war existentialism.', 'Literature Professor', 'Literary Scholar',
        'How does the author utilize the motif of light to reflect existential dread?',
        '["Analyze subtle linguistic symbolism and imagery", "Deconstruct unreliable narrator perspective", "Contextualize text within post-war existentialism", "Formulate original literary thesis"]'::jsonb,
        '["The motif of light paradoxically exposes barrenness.", "The unreliable narrative voice subverts expectation.", "Text reflects post-war disillusionment with authority.", "This choice reinforces the existential crisis."]'::jsonb, TRUE);

        -- C1-06
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Cross-Border Mergers & Acquisitions Strategy', 'Analyze valuation, due diligence, and cultural integration in M&A.', 
        'You are M&A Managing Director evaluating a $500M European competitor acquisition.',
        'C1', 'business', 45, 'Assess EBITDA multiples, antitrust regulatory clearance, cultural integration.', 'M&A Managing Director', 'Investment Banker',
        'We are evaluating a $500M acquisition of a European competitor. Thoughts on valuation?',
        '["Assess EBITDA acquisition multiple accuracy", "Identify antitrust regulatory compliance hurdles", "Outline post-merger cultural integration plan", "Deliver strategic recommendation"]'::jsonb,
        '["The 12x EBITDA multiple is justified by synergies.", "Antitrust scrutiny in Germany may require divestment.", "Cultural integration between US and EU teams is critical.", "I recommend proceeding to definitive agreement."]'::jsonb, TRUE);

        -- C1-07
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Geopolitical Energy Security Strategy', 'Analyze international energy independence, grid resilience, and risk.', 
        'You are Energy Security Analyst evaluating LNG supply chains and nuclear power.',
        'C1', 'science', 45, 'Analyze energy dependency, nuclear baseline, rare earth minerals.', 'Energy Security Analyst', 'Diplomatic Advisor',
        'How can European nations maintain grid stability while phasing out fossil fuels?',
        '["Analyze energy import dependency vulnerabilities", "Assess nuclear energy as baseline transition source", "Evaluate supply chain security rare earth minerals", "Propose resilient multi-lateral energy treaty"]'::jsonb,
        '["Diversifying energy import routes is paramount.", "Nuclear power provides essential baseload power.", "Critical mineral supply chains represent new bottleneck.", "Regional energy interconnections enhance grid resilience."]'::jsonb, TRUE);

        -- C1-08
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Intellectual Property Litigation Settlement', 'Negotiate patent infringement settlement and cross-licensing terms.', 
        'You are Lead IP Counsel evaluating a $2M settlement offer for patent infringement.',
        'C1', 'business', 45, 'Evaluate invalidity defense counter-claims, lost profit calculations, cross-license.', 'IP Litigation Counsel', 'Lead Patent Attorney',
        'The opposing counsel offered a $2M settlement for patent infringement. Do we take it?',
        '["Evaluate strength of invalidity defense counter-claim", "Calculate lost profits vs reasonable royalty damages", "Draft mutual cross-licensing agreement terms", "Finalize global settlement terms"]'::jsonb,
        '["Offered settlement fails to compensate lost market share.", "Our invalidity arguments against patent are strong.", "Propose mutual cross-licensing with $5M lump sum.", "This protects our core product line permanently."]'::jsonb, TRUE);

        -- C1-09
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Complex Medical Case Consultation', 'Analyze multi-system autoimmune disorder diagnostics with medical board.', 
        'You are Chief of Medicine evaluating systemic vasculitis and renal lab panels.',
        'C1', 'science', 45, 'Analyze laboratory biomarker panels, rule out infections, biological therapy.', 'Chief of Medicine', 'Specialist Physician',
        'The patient presents with systemic vasculitis, renal failure, and persistent fever.',
        '["Analyze complex laboratory biomarker panels", "Rule out atypical infectious etiologies", "Formulate targeted biological therapy plan", "Discuss prognosis and monitoring protocol"]'::jsonb,
        '["Elevated ANCA titers point toward vasculitis.", "Rule out fungal infection before high-dose steroids.", "Start pulse cyclophosphamide with biologics.", "Close monitoring of renal function is essential."]'::jsonb, TRUE);

        -- C1-10
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Distributed Cloud Systems Architecture Review', 'Defend global high-availability, eventual consistency, and fault tolerance.', 
        'You are Principal Systems Architect evaluating CAP theorem trade-offs and raft consensus.',
        'C1', 'technology', 45, 'Deconstruct CAP theorem trade-offs, Raft consensus, 200ms failover.', 'Principal Systems Architect', 'Infrastructure Engineer',
        'Explain how your system maintains low latency while guaranteeing consistency across 3 continents.',
        '["Deconstruct CAP theorem trade-offs in distributed stores", "Explain Raft/Paxos consensus implementation", "Analyze disaster recovery multi-region failover", "Defend architectural design decisions"]'::jsonb,
        '["We sacrificed strict consistency for availability via CRDTs.", "Edge caching with regional leaders minimizes latency.", "Automated failover completes in under 200ms.", "Architecture handles 100k requests/sec gracefully."]'::jsonb, TRUE);

        -- C1-11
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'International Diplomatic Protocol & Crisis', 'Manage a delicate diplomatic incident between two sovereign nations.', 
        'You are Foreign Affairs Minister drafting formal note of protest over territorial waters.',
        'C1', 'history', 45, 'Draft diplomatic note, maintain back-channel comms, multilateral UN pressure.', 'Foreign Minister', 'Senior Diplomat',
        'A foreign naval vessel entered restricted territorial waters. How do we respond?',
        '["Draft formal diplomatic note of protest", "Maintain open channels to avoid escalation", "Coordinate multilateral pressure via UN Security Council", "Achieve peaceful diplomatic resolution"]'::jsonb,
        '["We must issue formal note expressing grave concern.", "Back-channel comms prevent public escalation.", "Request emergency briefing at security council.", "Priority is sovereign integrity via diplomacy."]'::jsonb, TRUE);

        -- C1-12
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Crisis Public Relations Press Conference', 'Face aggressive journalists during live corporate scandal press conference.', 
        'You are an investigative reporter grilling spokesperson on executive stock sales before recall.',
        'C1', 'business', 45, 'Deliver calm factual statement, refuse speculation, emphasize safety.', 'Investigative Reporter', 'Corporate Spokesperson',
        'Is it true that executives sold shares days before the product safety recall?',
        '["Deliver calm transparent statement of facts", "Refuse to speculate on legal investigations", "Reiterate company commitment to safety", "Control high-pressure interview environment"]'::jsonb,
        '["Executive share transactions followed 10b5-1 trading plans.", "Primary concern is ensuring complete customer safety.", "We cooperate fully with independent auditors.", "I have time for two more questions from floor."]'::jsonb, TRUE);

        -- C1-13
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Venture Capital Due Diligence Defense', 'Defend startup unit economics, CAC, LTV, and churn before VC partners.', 
        'You are VC General Partner questioning 30% CAC increase in enterprise segment.',
        'C1', 'business', 45, 'Deconstruct CAC increase, highlight 4:1 LTV:CAC, net revenue retention.', 'VC General Partner', 'Founder CEO',
        'Your customer acquisition cost rose 30% last quarter. How is that sustainable?',
        '["Deconstruct CAC increase due to enterprise channel investment", "Highlight 4:1 LTV to CAC ratio", "Demonstrate negative net revenue churn", "Secure follow-on funding commitment"]'::jsonb,
        '["CAC rise reflects investment in high-converting enterprise channels.", "Net revenue retention stands at 135%.", "Enterprise customers show 5x higher lifetime value.", "Unit economic profile positions us for rapid scale."]'::jsonb, TRUE);

        -- C1-14
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Global Climate Policy Accord Negotiations', 'Negotiate carbon reduction targets between developed/developing nations.', 
        'You are climate delegate from developing nation demanding tech transfer fund.',
        'C1', 'science', 45, 'Acknowledge historical responsibility, tech transfer fund, tiered deadlines.', 'Developing Nation Delegate', 'Developed Nation Delegate',
        'Developing economies cannot sacrifice industrial growth without financial compensation.',
        '["Acknowledge historical carbon responsibility", "Propose green tech transfer funding mechanism", "Set realistic tiered carbon reduction deadlines", "Finalize binding global treaty consensus"]'::jsonb,
        '["Historical emitters must lead funding contributions.", "Green technology transfer fund accelerates transition.", "Tiered compliance schedules account for capabilities.", "This compromise aligns action with ecological urgency."]'::jsonb, TRUE);

        -- C1-15
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Enterprise Cloud Security Audit Review', 'Review zero-trust network architecture and IAM privilege escalation risks.', 
        'You are Chief Information Security Officer reviewing penetration audit findings.',
        'C1', 'technology', 45, 'Analyze root cause IAM misconfigurations, zero-trust, short-lived tokens.', 'CISO', 'Lead Security Auditor',
        'Our audit uncovered potential IAM privilege escalation paths in production.',
        '["Analyze root cause IAM policy misconfigurations", "Enforce strict zero-trust least privilege", "Mandate automated short-lived token rotation", "Approve security remediation timeline"]'::jsonb,
        '["We are revoking overly permissive IAM wildcard policies.", "Zero-trust ensures micro-segmentation across clusters.", "Automated short-lived credentials eliminate risks.", "Full remediation and re-testing concludes in 48 hours."]'::jsonb, TRUE);

        -- C1-16
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Corporate Governance & Ethics Investigation', 'Lead an internal investigation into financial accounting irregularities.', 
        'You are Internal Audit Director investigating whistleblower revenue recognition claims.',
        'C1', 'business', 45, 'Examine forensic audit evidence, breach of GAAP, recommend suspension.', 'Internal Audit Director', 'Special Counsel',
        'We reviewed the revenue recognition entries flagged by the internal whistleblower.',
        '["Examine forensic audit evidence objectively", "Identify breaches of accounting principles (GAAP)", "Recommend executive disciplinary/legal measures", "Report findings to board audit committee"]'::jsonb,
        '["Forensic auditing confirms premature revenue recognition in Q3.", "Practice violates ethics guidelines and GAAP standards.", "We recommend earnings restatement and executive suspension.", "Full report will be presented to board tomorrow."]'::jsonb, TRUE);

        -- C1-17
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Higher Education Structural Reform Debate', 'Debate university tenure, research funding allocation, and digital models.', 
        'You are Faculty Senate Chair defending tenure against clinical teaching tracks.',
        'C1', 'history', 45, 'Defend academic freedom, address tuition constraints, propose hybrid track.', 'Faculty Senate Chair', 'University President',
        'Should our university phase out traditional tenure in favor of clinical teaching tracks?',
        '["Defend academic freedom and tenure protections", "Acknowledge tuition cost constraints", "Propose hybrid faculty appointment structure", "Balance research excellence with teaching quality"]'::jsonb,
        '["Tenure is essential for protecting unconstrained research.", "Rising tuition costs demand administrative flexibility.", "Dual track honoring research and teaching is optimal.", "Preserving educational rigor remains our mission."]'::jsonb, TRUE);

        -- C1-18
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Scientific Peer Review Defense', 'Defend novel genomic sequencing methodology against reviewer critiques.', 
        'You are a journal editor reviewing author responses to statistical confidence intervals.',
        'C1', 'science', 45, 'Rebut reviewer critique, Monte Carlo simulations, statistical power >0.95.', 'Journal Editor', 'Principal Investigator',
        'Reviewer 2 questions your statistical confidence intervals in section 3.',
        '["Rebut reviewer critique with supplementary data", "Demonstrate control group methodologies", "Validate statistical power and p-value robustness", "Secure paper publication acceptance"]'::jsonb,
        '["We conducted Monte Carlo simulations for confidence intervals.", "Control group selection accounted for confounding variables.", "Statistical power exceeds 0.95, proving reproducibility.", "We updated manuscript addressing all observations."]'::jsonb, TRUE);

        -- C1-19
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Global Franchise Expansion Strategy', 'Negotiate master franchise agreement terms for South American rollout.', 
        'You are Global Brand Director awarding master franchise rights for 30 locations.',
        'C1', 'business', 45, 'Define store rollout schedule, supply chain standards, 4% royalty rate.', 'Global Brand Director', 'Master Franchisee',
        'We are ready to award master franchise rights for South America. Let us discuss terms.',
        '["Define territory exclusivity and rollout schedule", "Establish supply chain sourcing quality benchmarks", "Negotiate franchise fee and royalty percentage", "Finalize binding multi-unit agreement"]'::jsonb,
        '["We commit to opening 30 locations over 5 years.", "Local sourcing must meet global quality assurance.", "We propose 4% ongoing royalty rate with co-op marketing.", "This agreement unlocks massive regional growth."]'::jsonb, TRUE);

        -- C1-20
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Bioethics of Human Gene Editing', 'Debate regulatory policy on germline CRISPR gene editing technologies.', 
        'You are a bioethicist evaluating therapeutic benefits vs eugenic risks of CRISPR.',
        'C1', 'science', 45, 'Evaluate therapeutic potential, address germline consent, propose global body.', 'Bioethicist', 'Genetic Researcher',
        'Should germline editing be banned globally or restricted to fatal genetic diseases?',
        '["Evaluate clinical therapeutic potential monogenic disease", "Address slippery slope risks toward enhancement", "Propose international oversight bodies/moratoriums", "Formulate balanced bioethical regulatory framework"]'::jsonb,
        '["CRISPR offers cures for hereditary diseases like sickle cell.", "Germline alterations permanently affect future generations.", "An international regulatory body must oversee trial protocols.", "We must distinguish therapy from non-essential enhancement."]'::jsonb, TRUE);


        -- ==========================================
        -- NIVEL C2: MAESTRÍA (20 LECCIONES)
        -- ==========================================

        -- C2-01
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Diplomatic Summit on Multilateral Treaties', 'Engage in high-level diplomacy to negotiate international sovereignty accords.', 
        'You are Chief Diplomat resolving demilitarized management zones in multilateral treaty.',
        'C2', 'history', 45, 'Employ diplomatic tact, strategic ambiguity, draft binding compromise.', 'Chief Diplomat', 'Ambassador Plenipotentiary',
        'Your Excellency, we must resolve the remaining sovereignty disputes in clause 12.',
        '["Employ sophisticated diplomatic tact and ambiguity", "Harmonize conflicting national security imperatives", "Draft binding treaty compromise language", "Secure multilateral consensus for signing"]'::jsonb,
        '["We acknowledge profound sensitivity around territorial claims.", "Joint demilitarized management zone honors both nations.", "This wording preserves sovereignty while sharing resources.", "I am prepared to recommend full ratification."]'::jsonb, TRUE);

        -- C2-02
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Supreme Court Constitutional Argument', 'Deliver oral arguments before Highest Judicial Bench on constitutional law.', 
        'You are Supreme Court Justice questioning counsel on 14th Amendment stare decisis.',
        'C2', 'history', 45, 'Deconstruct jurisprudence precedents, originalist vs living constitution.', 'Supreme Court Justice', 'Constitutional Attorney',
        'Counselor, how does your interpretation of the 14th Amendment square with precedent?',
        '["Deconstruct historical jurisprudence and stare decisis", "Articulate originalist vs living constitution", "Dismantle opposing counsel legal reasoning", "Formulate decisive constitutional thesis"]'::jsonb,
        '["Stare decisis is a principle of policy, not inexorable.", "Framers drafted expansive language for changing structures.", "Overruling precedent corrects misreading of due process.", "We urge the Court to uphold fundamental rights."]'::jsonb, TRUE);

        -- C2-03
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Epistemology & Theoretical Consciousness', 'Debate the hard problem of consciousness, qualia, and panpsychism.', 
        'You are Cognitive Neuroscientist analyzing reductionist physicalism vs qualia gap.',
        'C2', 'science', 45, 'Deconstruct physicalist reductionism, Integrated Information Theory, qualia.', 'Cognitive Neuroscientist', 'Theoretical Philosopher',
        'Can physical computation ever account for the subjective feeling of redness?',
        '["Deconstruct explanatory gap in physicalist reductionism", "Critique panpsychism and integrated information theory", "Analyze neurobiological correlates of experience", "Synthesize advanced metaphysical position"]'::jsonb,
        '["Physicalist reductionism struggles with explanatory gap.", "Integrated Information Theory offers mathematical metrics.", "Whether consciousness is emergent remains scientific frontier.", "Subjective experience requires shift in physical ontology."]'::jsonb, TRUE);

        -- C2-04
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Peer Review Defense of Quantum Physics Research', 'Defend quantum entanglement experiment data against elite peer critique.', 
        'You are Renowned Quantum Physicist questioning macroscopic entanglement decoherence noise.',
        'C2', 'science', 45, 'Deconstruct noise algorithms, validate Bell inequality >7-sigma, 10 millikelvin.', 'Renowned Physicist', 'Lead Researcher',
        'Professor, your claim of macroscopic entanglement appears vulnerable to thermal noise.',
        '["Deconstruct quantum noise filtration algorithms", "Validate Bell inequality violation metrics >7-sigma", "Demonstrate cryogenic experimental controls", "Achieve unanimous peer recognition"]'::jsonb,
        '["Our setup suppressed decoherence using topological qudits.", "Violation of Bell inequality exceeded 7 standard deviations.", "Thermal noise was mitigated by cooling to 10 millikelvin.", "Data conclusively demonstrates macroscopic coherence."]'::jsonb, TRUE);

        -- C2-05
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Post-Modernist Literary Deconstruction', 'Analyze metanarratives, intertextuality, and semiotics in post-modern text.', 
        'You are Semiotics Professor analyzing self-reflexive footnotes and linguistic fluidity.',
        'C2', 'art', 45, 'Analyze semiotic signifiers, Derrida/Foucault linguistic theories, narrative truth.', 'Semiotics Professor', 'Literary Critic',
        'Examine how the text deconstructs its own narrative authority through self-reflexive footnotes.',
        '["Analyze semiotic signifiers and intertextuality", "Deconstruct illusion of objective narrative truth", "Examine post-structuralist linguistic theories", "Formulate groundbreaking literary critique"]'::jsonb,
        '["Footnotes undermine central narrative ontological primacy.", "Signifiers continuously defer fixed meaning.", "Text parodies claim to authority, celebrating instability.", "This maneuver challenges nature of literary consumption."]'::jsonb, TRUE);

        -- C2-06
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Central Bank Monetary Policy Summit', 'Formulate global central bank strategy against stagflation and currency risks.', 
        'You are Central Bank Governor evaluating 8% inflation alongside contracting GDP.',
        'C2', 'business', 45, 'Analyze stagflation dynamics, quantitative tightening, sovereign debt risks.', 'Central Bank Governor', 'Chief Monetary Strategist',
        'Colleagues, we face persistent 8% inflation alongside contracting GDP. What is our mandate?',
        '["Analyze macroeconomic stagflation dynamics", "Evaluate quantitative tightening vs bank instability", "Formulate calibrated monetary policy directive", "Communicate forward guidance to markets"]'::jsonb,
        '["Targeted quantitative tightening anchors inflation expectations.", "Rapid rate hikes threaten sovereign debt sustainability.", "Macroprudential tools insulate banking system during tightening.", "Forward guidance emphasizes data-dependent agility."]'::jsonb, TRUE);

        -- C2-07
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Cyber Warfare & Sovereign State Threat Analysis', 'Coordinate national defense against state-sponsored SCADA power grid attack.', 
        'You are National Security Advisor briefing head of state on APT zero-day payload.',
        'C2', 'technology', 45, 'Deconstruct APT vectors, air-gap industrial control systems, diplomatic sanctions.', 'National Security Advisor', 'Cyber Intelligence Director',
        'A state actor just deployed an advanced zero-day payload into our power grid. Options?',
        '["Deconstruct advanced persistent threat (APT) vectors", "Isolate compromised industrial control systems (ICS)", "Formulate calibrated cyber counter-strike strategy", "Brief head of state on security stance"]'::jsonb,
        '["Malware exploits unknown vulnerability in SCADA firmware.", "Air-gapping substations contained lateral movement.", "Attribution points to APT29 based on code signatures.", "We recommend cyber neutralization and targeted sanctions."]'::jsonb, TRUE);

        -- C2-08
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'High-Stakes International Trade Arbitration', 'Represent a sovereign nation in ICSID investment treaty dispute.', 
        'You are Arbitral Tribunal President hearing indirect expropriation arguments.',
        'C2', 'business', 45, 'Cite ICSID jurisprudence, police power defense, refute cash flow claims.', 'Tribunal President', 'Lead International Counsel',
        'Counsel, prove that your state regulation did not constitute indirect expropriation.',
        '["Cite international investment arbitration precedents", "Demonstrate legitimate exercise of police powers", "Refute claimant discounted cash flow calculations", "Secure favorable arbitral award"]'::jsonb,
        '["Regulation constitutes non-compensable police power for health.", "Indirect expropriation requires permanent economic loss.", "Claimant projected damages rely on speculative assumptions.", "We request Tribunal to dismiss all claims with prejudice."]'::jsonb, TRUE);

        -- C2-09
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Complex Corporate Restructuring & Solvency', 'Engineer financial restructuring for distressed conglomerate with $5B debt.', 
        'You are Restructuring Trustee negotiating senior bondholder debt-for-equity swap.',
        'C2', 'business', 45, 'Structure debt-for-equity swap, Chapter 11 cramdown, preserve $300M interest.', 'Restructuring Trustee', 'Chief Restructuring Officer',
        'Senior bondholders refuse a 30% haircut on debt principal. How do we prevent liquidation?',
        '["Structure debt-for-equity swap framework", "Negotiate cramdown terms under Chapter 11 insolvency", "Preserve operational cash flow and vendor trust", "Achieve consensus among creditor classes"]'::jsonb,
        '["We propose converting 40% senior debt into preferred equity.", "Restructuring reduces annual interest expense by $300M.", "If unsecured creditors reject, we utilize cramdown.", "Reorganization preserves 15,000 jobs and optimizes recovery."]'::jsonb, TRUE);

        -- C2-10
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Fine Art Authentication & Provenance Debate', 'Debate authenticity of uncatalogued Renaissance master painting.', 
        'You are Museum Director analyzing X-ray fluorescence and 1638 Medici archives.',
        'C2', 'art', 45, 'Analyze XRF spectroscopy, pentimenti underdrawing, unbroken provenance.', 'Museum Director', 'Art Historian & Forensic Expert',
        'Is this canvas truly an uncatalogued work by Caravaggio or a master forgery?',
        '["Analyze X-ray fluorescence and lead white isotope ratios", "Evaluate chiaroscuro brushwork against masterworks", "Trace historical provenance documents through archives", "Deliver definitive scholarly attribution"]'::jsonb,
        '["Spectroscopic analysis confirms 1600s Roman lapis lazuli.", "X-radiography reveals pentimenti underdrawing style.", "Unbroken provenance corroborated by 1638 Medici records.", "I unequivocally attribute this work to Caravaggio."]'::jsonb, TRUE);

        -- C2-11
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Ethnomusicology & Archaeoacoustic Research', 'Deconstruct ancient musical tuning systems and stone temple acoustics.', 
        'You are Acoustics Researcher measuring 110 Hz Helmholtz resonance in stone chambers.',
        'C2', 'music', 45, 'Analyze Helmholtz resonance, non-Western microtonal intonation, psychoacoustics.', 'Acoustics Researcher', 'Ethnomusicologist',
        'How did the resonant frequencies of Neolithic stone chambers influence ritual chanting?',
        '["Analyze acoustic Helmholtz resonance data from sites", "Deconstruct non-Western microtonal scale structures", "Examine psychoacoustic effects low-frequency waves", "Synthesize interdisciplinary research paper"]'::jsonb,
        '["Chamber 110 Hz resonance amplifies male vocal fundamentals.", "Standing wave patterns induce trance psychoacoustic states.", "Tuning system relies on 13-limit just intonation.", "Soundscapes were intentionally engineered into architecture."]'::jsonb, TRUE);

        -- C2-12
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Astro-Physics & Dark Energy Cosmological Models', 'Debate cosmological constant theories and Hubble tension measurements.', 
        'You are Theoretical Astrophysicist analyzing James Webb and Planck satellite data.',
        'C2', 'science', 45, 'Deconstruct 5-sigma Hubble tension, time-varying dark energy, Lambda-CDM.', 'Theoretical Astrophysicist', 'Cosmologist',
        'Does the persistent Hubble tension indicate new physics beyond the Lambda-CDM model?',
        '["Deconstruct measurements from JWST and Planck data", "Analyze dark energy equation of state variations", "Critique MOND vs Cold Dark Matter assumptions", "Formulate novel cosmological hypothesis"]'::jsonb,
        '["5-sigma discrepancy between Hubble measurements is real.", "Tension suggests time-varying dark energy component.", "Modifying gravity at galactic scales fails CMB spectra.", "We are on verge of paradigm shift in precision cosmology."]'::jsonb, TRUE);

        -- C2-13
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'International Human Rights Digital Charter', 'Draft novel global legal frameworks protecting cognitive liberty from neural harvesting.', 
        'You are UN High Commissioner drafting universal declaration amendments for neural data.',
        'C2', 'history', 45, 'Define cognitive liberty, prohibit unauthorized neural decoding, UN adoption.', 'UN High Commissioner', 'Human Rights Scholar',
        'How should international law protect citizens against non-consensual neural data harvesting?',
        '["Formulate legal definitions cognitive liberty/privacy", "Draft binding international treaty protocol amendments", "Address jurisdiction enforcement across networks", "Secure international diplomatic adoption"]'::jsonb,
        '["Freedom of thought must prohibit unauthorized neural decoding.", "Neural data requires absolute bodily integrity protection.", "State surveillance using predictive algorithms violates dignity.", "We present this draft protocol as imperative update."]'::jsonb, TRUE);

        -- C2-14
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Neuro-Linguistic BCI Speech Synthesis', 'Deconstruct neural decoding of speech using invasive brain-computer interfaces.', 
        'You are Neurosurgeon evaluating ECoG signal processing and 90 WPM synthesis.',
        'C2', 'technology', 45, 'Deconstruct ECoG signal processing, transformer phoneme decoding, <50ms latency.', 'Neurosurgeon', 'Computational Neuroscientist',
        'How does your BCI model translate motor cortex neural spikes into fluent speech audio?',
        '["Deconstruct high-density ECoG signal processing", "Explain transformer neural decoding phoneme trajectories", "Analyze closed-loop latency optimization <50ms", "Demonstrate clinical speech restoration breakthrough"]'::jsonb,
        '["High-density ECoG records local field potentials from cortex.", "Deep transformer maps neural firing to articulatory features.", "Synthesis achieves 5,000-word vocabulary at 90 WPM.", "This restores natural speech to locked-in patients."]'::jsonb, TRUE);

        -- C2-15
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Arbitral Award International Enforcement', 'Enforce a $1B international arbitration award under New York Convention.', 
        'You are Enforcement Attorney tracing state-owned commercial oil tanker assets.',
        'C2', 'business', 45, 'Analyze New York Convention Article V, commercial exception, maritime arrest.', 'Enforcement Attorney', 'Sovereignty Counsel',
        'The respondent state claims sovereign immunity against asset seizure of state oil tankers.',
        '["Analyze New York Convention Article V exceptions", "Deconstruct commercial exceptions to sovereign immunity", "Track hidden offshore state asset structures", "Secure court orders for asset attachment"]'::jsonb,
        '["Sovereign immunity does not shield commercial operations.", "State enterprise assets are subject to execution exceptions.", "We identified target vessels docked in friendly ports.", "We request ex parte order for maritime arrest."]'::jsonb, TRUE);

        -- C2-16
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Executive Crisis Address to Global Stakeholders', 'Address shareholders and media during a catastrophic $4B corporate failure.', 
        'You are Financial Times journalist grilling CEO on missing client funds.',
        'C2', 'business', 45, 'Deliver radical transparency, asset recovery protocols, law enforcement coop.', 'FT Journalist', 'Global Chief Executive',
        'Your firm lost $4B in client funds overnight. Why should you not be criminally prosecuted?',
        '["Deliver uncompromising accountability and radical transparency", "Detail immediate liquidation and asset recovery protocols", "Cooperate unconditionally with regulatory authorities", "Outline path to complete victim restitution"]'::jsonb,
        '["I am here today to accept complete accountability.", "Immediate mandate is securing assets for victim restitution.", "Providing independent forensic auditors unhindered access.", "I will not step down until every possible dollar is returned."]'::jsonb, TRUE);

        -- C2-17
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Advanced ZK-STARK Distributed Consensus', 'Analyze zero-knowledge rollups, SNARKs, and BFT consensus without setup.', 
        'You are Cryptography Professor analyzing FRI polynomial commitments and liveness.',
        'C2', 'technology', 45, 'Deconstruct FRI mathematics, polylogarithmic verification, 33% BFT partition.', 'Cryptography Professor', 'Protocol Architect',
        'How does your protocol guarantee validity without trusted setup ceremonies?',
        '["Deconstruct FRI mathematics and polynomial commitments", "Analyze zero-knowledge succinctness verification complexity", "Validate BFT liveness under 33% adversarial partition", "Prove cryptographic security bounds"]'::jsonb,
        '["zk-STARKs eliminate trusted setup ceremonies via hashes.", "Verification complexity remains polylogarithmic.", "Liveness guaranteed under partial synchrony with 33% malicious.", "This achieves unprecedented cryptographic security and throughput."]'::jsonb, TRUE);

        -- C2-18
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Geo-Engineering Ethics & Solar Radiation Management', 'Debate global deployment of stratospheric aerosol injection to halt warming.', 
        'You are Geo-Engineering Scientist debating termination shock risks and UN governance.',
        'C2', 'science', 45, 'Evaluate thermal equilibrium vs monsoon disruption, termination shock, UN treaty.', 'Geo-Engineering Scientist', 'Global Risk Ethicist',
        'If one nation unilaterally sprays sulfur dioxide into the stratosphere, how do we respond?',
        '["Evaluate thermal equilibrium vs hydrological disruption", "Analyze catastrophic termination shock scenario risks", "Propose mandatory multilateral governance treaty", "Synthesize global emergency protocol"]'::jsonb,
        '["Aerosol injection lowers temperature but alters monsoons.", "Unilateral deployment poses grave geopolitical risks.", "Termination shock causes rapid warming if interrupted.", "A binding UN moratorium must govern atmospheric intervention."]'::jsonb, TRUE);

        -- C2-19
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Post-Quantum Cryptographic Standard Migration', 'Formulate national strategy for migrating critical infrastructure to lattice crypto.', 
        'You are National Cyber Director planning migration against Shor algorithm threat.',
        'C2', 'technology', 45, 'Deconstruct Shor algorithm threat, CRYSTALS-Kyber/Dilithium, hybrid rollout.', 'National Cyber Director', 'Post-Quantum Cryptographer',
        'When quantum computers reach 10,000 qubits, RSA-4096 breaks. How fast can we migrate?',
        '["Deconstruct Shor algorithm threat to public key infrastructure", "Evaluate NIST-selected lattice algorithms (Kyber/Dilithium)", "Plan hybrid classical-quantum migration roadmap", "Secure national critical infrastructure"]'::jsonb,
        '["Shor algorithm renders RSA and ECC obsolete upon supremacy.", "Deploying CRYSTALS-Kyber for encryption and Dilithium for signature.", "Hybrid dual-signature protocol ensures backward compatibility.", "All critical systems achieve post-quantum resilience by 2028."]'::jsonb, TRUE);

        -- C2-20
        INSERT INTO public.scenarios (language_id, title, description, context, difficulty_level, category, estimated_minutes, main_objective, assistant_role, user_role, initial_assistant_message, goals, useful_phrases, is_active)
        VALUES (lang_rec.id, 'Structural Analysis of Late Beethoven Quartets', 'Deconstruct counterpoint, thematic transformation, and form in Opus 133.', 
        'You are Musicology Chair deconstructing double fugue structure in Grosse Fuge.',
        'C2', 'music', 45, 'Analyze thematic metric transformation, contrapuntal inversion, chromatic dissonance.', 'Musicology Chair', 'Composer & Theorist',
        'Deconstruct the double fugue structure in Beethoven Grosse Fuge, Opus 133.',
        '["Analyze thematic metric transformation and inversion", "Deconstruct chromatic dissonance and harmonic resolution", "Examine historical reception and influence on avant-garde", "Deliver definitive musical theory analysis"]'::jsonb,
        '["Grosse Fuge subverts traditional sonata-fugue boundaries.", "The opening presents principal motif in four rhythmic transformations.", "Dissonance is treated as structural pillar.", "Beethoven anticipated 20th-century serialism by over a century."]'::jsonb, TRUE);

    END LOOP;
END $$;
