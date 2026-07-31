import 'package:flutter/foundation.dart';

class ScenarioGoalItem {
  final String id;
  final String text;
  final List<String> keywords;
  final String examplePhrase;
  final bool isCompleted;

  ScenarioGoalItem({
    required this.id,
    required this.text,
    required this.keywords,
    this.examplePhrase = '',
    this.isCompleted = false,
  });

  ScenarioGoalItem copyWith({bool? isCompleted}) {
    return ScenarioGoalItem(
      id: id,
      text: text,
      keywords: keywords,
      examplePhrase: examplePhrase,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool isSatisfiedBy(String userText) {
    final lower = userText.toLowerCase();
    return keywords.any((k) => lower.contains(k.toLowerCase()));
  }
}

class UsefulPhraseItem {
  final String id;
  final String phrase;
  final String translation;
  final bool isUsed;

  UsefulPhraseItem({
    required this.id,
    required this.phrase,
    required this.translation,
    this.isUsed = false,
  });

  UsefulPhraseItem copyWith({bool? isUsed}) {
    return UsefulPhraseItem(
      id: id,
      phrase: phrase,
      translation: translation,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}

class LessonData {
  final String id;
  final String targetLanguageCode;
  final String title;
  final String description;
  final String level;
  final String category;
  final String interest;
  final int difficulty;
  final String iconKey;
  final String mainObjective;
  final String scenarioContext;
  final String assistantRole;
  final String userRole;
  final String initialAssistantMessage;
  final List<ScenarioGoalItem> goals;
  final List<UsefulPhraseItem> usefulPhrases;

  LessonData({
    required this.id,
    this.targetLanguageCode = 'en',
    required this.title,
    required this.description,
    required this.level,
    required this.category,
    required this.interest,
    required this.difficulty,
    required this.iconKey,
    required this.mainObjective,
    required this.scenarioContext,
    required this.assistantRole,
    required this.userRole,
    required this.initialAssistantMessage,
    required this.goals,
    required this.usefulPhrases,
  });
}

class LessonCatalog {
  static final List<LessonData> catalog = [
    // =========================================================================
    // NIVEL A1 — Principiante
    // =========================================================================

    LessonData(
      id: 'a1_greetings',
      title: 'Saludos y Presentaciones',
      description: 'Aprende a saludar, decir tu nombre, de dónde eres y despedirte.',
      level: 'A1',
      category: 'social',
      interest: 'social',
      difficulty: 1,
      iconKey: 'handshake',
      mainObjective: 'Presentarte con educación y entablar una conversación inicial básica.',
      scenarioContext: 'Social meeting',
      assistantRole: 'New acquaintance (Alex)',
      userRole: 'Student',
      initialAssistantMessage: "Hi! I'm Alex. What's your name?",
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Saludar y decir tu nombre', keywords: ['name', 'my name is', 'i am'], examplePhrase: 'My name is...'),
        ScenarioGoalItem(id: 'g2', text: 'Preguntar el nombre del otro', keywords: ['what', 'what\'s your name', 'your name'], examplePhrase: "What's your name?"),
        ScenarioGoalItem(id: 'g3', text: 'Decir de dónde eres', keywords: ['from', 'i am from', 'i\'m from'], examplePhrase: "I'm from..."),
        ScenarioGoalItem(id: 'g4', text: 'Preguntar how are you', keywords: ['how', 'how are you', 'how\'s it going'], examplePhrase: 'How are you?'),
        ScenarioGoalItem(id: 'g5', text: 'Despedirte correctamente', keywords: ['goodbye', 'bye', 'see you', 'later'], examplePhrase: 'Goodbye! See you later!'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Nice to meet you', translation: 'Mucho gusto'),
        UsefulPhraseItem(id: 'p2', phrase: 'My name is...', translation: 'Me llamo...'),
        UsefulPhraseItem(id: 'p3', phrase: 'Where are you from?', translation: '¿De dónde eres?'),
        UsefulPhraseItem(id: 'p4', phrase: "I'm from...", translation: 'Soy de...'),
        UsefulPhraseItem(id: 'p5', phrase: 'How are you?', translation: '¿Cómo estás?'),
        UsefulPhraseItem(id: 'p6', phrase: "I'm fine, thanks", translation: 'Estoy bien, gracias'),
        UsefulPhraseItem(id: 'p7', phrase: 'See you later', translation: 'Nos vemos luego'),
        UsefulPhraseItem(id: 'p8', phrase: 'Goodbye', translation: 'Adiós'),
        UsefulPhraseItem(id: 'p9', phrase: 'What do you do?', translation: '¿A qué te dedicas?'),
        UsefulPhraseItem(id: 'p10', phrase: "I'm a student", translation: 'Soy estudiante'),
      ],
    ),

    LessonData(
      id: 'a1_family',
      title: 'Mi Familia',
      description: 'Habla de los miembros de tu familia, sus edades y descripciones físicas.',
      level: 'A1',
      category: 'social',
      interest: 'social',
      difficulty: 1,
      iconKey: 'people',
      mainObjective: 'Describir a tu grupo familiar y hacer preguntas sobre la familia de otros.',
      scenarioContext: 'Casual conversation',
      assistantRole: 'Friend',
      userRole: 'Friend',
      initialAssistantMessage: 'Tell me about your family. Do you have brothers or sisters?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Nombrar 3 miembros de tu familia', keywords: ['brother', 'sister', 'mother', 'father', 'parent'], examplePhrase: 'I have two brothers'),
        ScenarioGoalItem(id: 'g2', text: 'Decir sus edades', keywords: ['years', 'year', 'old', 'age'], examplePhrase: 'My sister is 10 years old'),
        ScenarioGoalItem(id: 'g3', text: 'Describir a una persona físicamente', keywords: ['tall', 'hair', 'eyes', 'short'], examplePhrase: 'He is tall with brown hair'),
        ScenarioGoalItem(id: 'g4', text: 'Usar posesivos (my, his, her)', keywords: ['my', 'his', 'her', 'their'], examplePhrase: 'My mother and her sister'),
        ScenarioGoalItem(id: 'g5', text: 'Preguntar sobre la familia del otro', keywords: ['family', 'your family', 'do you have'], examplePhrase: 'Do you have a big family?'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'This is my mother', translation: 'Esta es mi madre'),
        UsefulPhraseItem(id: 'p2', phrase: 'I have two brothers', translation: 'Tengo dos hermanos'),
        UsefulPhraseItem(id: 'p3', phrase: 'He is tall', translation: 'Él es alto'),
        UsefulPhraseItem(id: 'p4', phrase: 'She is younger than me', translation: 'Ella es menor que yo'),
        UsefulPhraseItem(id: 'p5', phrase: 'My parents live in...', translation: 'Mis padres viven en...'),
        UsefulPhraseItem(id: 'p6', phrase: 'Do you have siblings?', translation: '¿Tienes hermanos?'),
        UsefulPhraseItem(id: 'p7', phrase: "I'm an only child", translation: 'Soy hijo único'),
        UsefulPhraseItem(id: 'p8', phrase: 'My grandmother is 70', translation: 'Mi abuela tiene 70 años'),
        UsefulPhraseItem(id: 'p9', phrase: 'We are a big family', translation: 'Somos una familia grande'),
        UsefulPhraseItem(id: 'p10', phrase: 'He works as a doctor', translation: 'Él trabaja como doctor'),
      ],
    ),

    LessonData(
      id: 'a1_numbers_time',
      title: 'Números y la Hora',
      description: 'Aprende a pedir y decir la hora, horarios de despertar y coordinar citas.',
      level: 'A1',
      category: 'daily_life',
      interest: 'daily_life',
      difficulty: 1,
      iconKey: 'schedule',
      mainObjective: 'Manejar expresiones de tiempo, horas del día y agenda personal.',
      scenarioContext: 'Daily planning',
      assistantRole: 'Friend / Colleague',
      userRole: 'Friend',
      initialAssistantMessage: 'What time do you usually wake up?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Decir la hora actual', keywords: ['oclock', "o'clock", 'clock', 'half past'], examplePhrase: "It's three o'clock"),
        ScenarioGoalItem(id: 'g2', text: 'Preguntar la hora', keywords: ['time', 'what time', 'when'], examplePhrase: 'What time is it?'),
        ScenarioGoalItem(id: 'g3', text: 'Contar números en contexto', keywords: ['three', 'seven', 'five', 'one', 'two', 'four'], examplePhrase: 'I wake up at seven'),
        ScenarioGoalItem(id: 'g4', text: 'Decir tu hora de despertar o dormir', keywords: ['wake', 'wake up', 'get up', 'sleep', 'go to bed'], examplePhrase: 'I wake up at 7 AM'),
        ScenarioGoalItem(id: 'g5', text: 'Programar una cita usando hora', keywords: ['meet', 'appointment', 'free', 'tomorrow'], examplePhrase: "Let's meet at noon"),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'What time is it?', translation: '¿Qué hora es?'),
        UsefulPhraseItem(id: 'p2', phrase: "It's three o'clock", translation: 'Son las tres'),
        UsefulPhraseItem(id: 'p3', phrase: 'I wake up at seven', translation: 'Me despierto a las siete'),
        UsefulPhraseItem(id: 'p4', phrase: 'Can we meet at noon?', translation: '¿Podemos vernos al mediodía?'),
        UsefulPhraseItem(id: 'p5', phrase: "It's half past five", translation: 'Son las cinco y media'),
        UsefulPhraseItem(id: 'p6', phrase: 'I have an appointment at...', translation: 'Tengo una cita a las...'),
        UsefulPhraseItem(id: 'p7', phrase: 'Early / Late', translation: 'Temprano / Tarde'),
        UsefulPhraseItem(id: 'p8', phrase: 'How many...?', translation: '¿Cuántos...?'),
        UsefulPhraseItem(id: 'p9', phrase: "I'm free tomorrow", translation: 'Estoy libre mañana'),
        UsefulPhraseItem(id: 'p10', phrase: "Let's meet at 9 AM", translation: 'Veámonos a las 9 AM'),
      ],
    ),

    LessonData(
      id: 'a1_food_order',
      title: 'Pedir Comida en un Café',
      description: 'Ordena bebidas y snacks en una cafetería, consulta precios y paga.',
      level: 'A1',
      category: 'food',
      interest: 'food',
      difficulty: 1,
      iconKey: 'coffee',
      mainObjective: 'Ordenar alimentos y bebidas básicas en un establecimiento.',
      scenarioContext: 'Coffee shop counter',
      assistantRole: 'Barista',
      userRole: 'Customer',
      initialAssistantMessage: 'Welcome! What would you like to order today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Pedir una bebida y comida', keywords: ['coffee', 'tea', 'i would like', "i'd like", 'can i have'], examplePhrase: "I'd like a coffee, please"),
        ScenarioGoalItem(id: 'g2', text: 'Preguntar el precio', keywords: ['much', 'how much', 'cost', 'price'], examplePhrase: 'How much is it?'),
        ScenarioGoalItem(id: 'g3', text: 'Pedir la cuenta', keywords: ['check', 'bill', 'pay'], examplePhrase: 'Can I get the check, please?'),
        ScenarioGoalItem(id: 'g4', text: 'Mencionar una alergia o preferencia', keywords: ['allergic', 'without', 'no', 'prefer'], examplePhrase: "I'm allergic to nuts"),
        ScenarioGoalItem(id: 'g5', text: 'Agradecer y pagar', keywords: ['thanks', 'thank you', 'thank'], examplePhrase: 'Thank you!'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: "I'd like a coffee, please", translation: 'Quisiera un café, por favor'),
        UsefulPhraseItem(id: 'p2', phrase: 'Can I have the menu?', translation: '¿Me da el menú?'),
        UsefulPhraseItem(id: 'p3', phrase: 'How much is it?', translation: '¿Cuánto cuesta?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Can I get the check, please?', translation: '¿Me trae la cuenta, por favor?'),
        UsefulPhraseItem(id: 'p5', phrase: "I'm allergic to...", translation: 'Soy alérgico a...'),
        UsefulPhraseItem(id: 'p6', phrase: 'Is this spicy?', translation: '¿Esto es picante?'),
        UsefulPhraseItem(id: 'p7', phrase: 'To go or to stay?', translation: '¿Para llevar o para aquí?'),
        UsefulPhraseItem(id: 'p8', phrase: 'Anything else?', translation: '¿Algo más?'),
        UsefulPhraseItem(id: 'p9', phrase: "That's all, thanks", translation: 'Eso es todo, gracias'),
        UsefulPhraseItem(id: 'p10', phrase: 'Do you accept cards?', translation: '¿Aceptan tarjetas?'),
      ],
    ),

    LessonData(
      id: 'a1_airport_checkin',
      title: 'Check-in en el Aeropuerto',
      description: 'Presenta tu pasaporte, registra maletas y ubica la puerta de embarque.',
      level: 'A1',
      category: 'travel',
      interest: 'travel',
      difficulty: 1,
      iconKey: 'flight',
      mainObjective: 'Facturar equipaje y obtener el pase de abordar en la aerolínea.',
      scenarioContext: 'Airport check-in counter',
      assistantRole: 'Airline Counter Agent',
      userRole: 'Passenger',
      initialAssistantMessage: 'Good morning! May I see your passport and ticket, please?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Entregar documentos y responder preguntas', keywords: ['passport', 'ticket', 'here is', 'here\'s'], examplePhrase: "Here's my passport"),
        ScenarioGoalItem(id: 'g2', text: 'Decir cuántas maletas llevas', keywords: ['bag', 'suitcase', 'luggage', 'carry'], examplePhrase: 'I have one suitcase'),
        ScenarioGoalItem(id: 'g3', text: 'Pedir asiento de ventana o pasillo', keywords: ['seat', 'window', 'aisle'], examplePhrase: 'Window seat, please'),
        ScenarioGoalItem(id: 'g4', text: 'Preguntar la puerta de embarque', keywords: ['gate', 'boarding', 'which gate'], examplePhrase: 'Which gate is it?'),
        ScenarioGoalItem(id: 'g5', text: 'Confirmar la hora del vuelo', keywords: ['flight', 'depart', 'leave', 'on time'], examplePhrase: 'What time does the flight leave?'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: "Here's my passport", translation: 'Aquí está mi pasaporte'),
        UsefulPhraseItem(id: 'p2', phrase: 'I have one suitcase', translation: 'Tengo una maleta'),
        UsefulPhraseItem(id: 'p3', phrase: 'Window seat, please', translation: 'Asiento de ventana, por favor'),
        UsefulPhraseItem(id: 'p4', phrase: 'What time does the flight leave?', translation: '¿A qué hora sale el vuelo?'),
        UsefulPhraseItem(id: 'p5', phrase: 'Which gate is it?', translation: '¿Cuál es la puerta?'),
        UsefulPhraseItem(id: 'p6', phrase: 'Is the flight on time?', translation: '¿El vuelo está a tiempo?'),
        UsefulPhraseItem(id: 'p7', phrase: 'I have a connecting flight', translation: 'Tengo un vuelo de conexión'),
        UsefulPhraseItem(id: 'p8', phrase: 'How much luggage can I bring?', translation: '¿Cuánto equipaje puedo llevar?'),
        UsefulPhraseItem(id: 'p9', phrase: 'Boarding starts at...', translation: 'El embarque empieza a las...'),
        UsefulPhraseItem(id: 'p10', phrase: 'Thank you, have a nice flight', translation: 'Gracias, buen vuelo'),
      ],
    ),

    // =========================================================================
    // NIVEL A2 — Elemental
    // =========================================================================

    LessonData(
      id: 'l1', // ordering_food_a2
      title: 'Ordering Food in a Restaurant',
      description: 'Interact with the waiter to ask for recommendations, order meals, and split the bill.',
      level: 'A2',
      category: 'food',
      interest: 'food',
      difficulty: 2,
      iconKey: 'restaurant',
      mainObjective: 'Order a full lunch/dinner with customized preferences and handle payment.',
      scenarioContext: 'Restaurant table',
      assistantRole: 'Waiter / Server',
      userRole: 'Restaurant Customer',
      initialAssistantMessage: "Hi, welcome! Have you decided what you'd like to order?",
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Pedir una recomendación al mesero', keywords: ['recommend', 'suggestion', 'popular', 'good'], examplePhrase: 'What do you recommend?'),
        ScenarioGoalItem(id: 'g2', text: 'Ordenar entrada, plato fuerte y bebida', keywords: ['order', 'i will have', "i'll have", 'i would like'], examplePhrase: "I'll have the grilled chicken"),
        ScenarioGoalItem(id: 'g3', text: 'Pedir modificaciones (sin cebolla, etc.)', keywords: ['without', 'no', 'instead of', 'extra'], examplePhrase: 'Could I get that without onions?'),
        ScenarioGoalItem(id: 'g4', text: 'Expresar tu satisfacción con la comida', keywords: ['delicious', 'amazing', 'great', 'wonderful', 'good'], examplePhrase: 'The food was delicious'),
        ScenarioGoalItem(id: 'g5', text: 'Pedir la cuenta y dividirla', keywords: ['bill', 'check', 'split', 'separate'], examplePhrase: 'Could we split the bill?'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'What do you recommend?', translation: '¿Qué recomienda?'),
        UsefulPhraseItem(id: 'p2', phrase: "I'll have the grilled chicken", translation: 'Voy a pedir el pollo a la parrilla'),
        UsefulPhraseItem(id: 'p3', phrase: 'Could I get that without onions?', translation: '¿Podría ser sin cebolla?'),
        UsefulPhraseItem(id: 'p4', phrase: "This isn't what I ordered", translation: 'Esto no es lo que pedí'),
        UsefulPhraseItem(id: 'p5', phrase: 'Could we split the bill?', translation: '¿Podemos dividir la cuenta?'),
        UsefulPhraseItem(id: 'p6', phrase: 'Is this dish spicy?', translation: '¿Este plato es picante?'),
        UsefulPhraseItem(id: 'p7', phrase: 'Can I have some water, please?', translation: '¿Me trae agua, por favor?'),
        UsefulPhraseItem(id: 'p8', phrase: 'The food was delicious', translation: 'La comida estuvo deliciosa'),
        UsefulPhraseItem(id: 'p9', phrase: 'Could we get the check?', translation: '¿Nos trae la cuenta?'),
        UsefulPhraseItem(id: 'p10', phrase: "We'd like a table for two", translation: 'Quisiéramos una mesa para dos'),
      ],
    ),

    LessonData(
      id: 'a2_hotel', // hotel_checkin_a2
      title: 'Hotel Check-In',
      description: 'Confirm your reservation, ask about amenities like Wi-Fi and breakfast, and request key.',
      level: 'A2',
      category: 'travel',
      interest: 'travel',
      difficulty: 2,
      iconKey: 'hotel',
      mainObjective: 'Check in smoothly and inquire about hotel policies and facilities.',
      scenarioContext: 'Hotel front desk',
      assistantRole: 'Hotel Receptionist',
      userRole: 'Hotel Guest',
      initialAssistantMessage: 'Welcome to our hotel! Do you have a reservation?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Confirmar tu reserva a tu nombre', keywords: ['reservation', 'booking', 'i have a', 'under my name'], examplePhrase: 'I have a reservation under my name'),
        ScenarioGoalItem(id: 'g2', text: 'Pedir tipo de habitación o vista', keywords: ['room', 'view', 'double', 'single', 'suite'], examplePhrase: 'Do you have a room with a sea view?'),
        ScenarioGoalItem(id: 'g3', text: 'Preguntar por servicios (wifi, desayuno)', keywords: ['wifi', 'breakfast', 'included', 'free', 'gym'], examplePhrase: 'Is breakfast included?'),
        ScenarioGoalItem(id: 'g4', text: 'Preguntar hora de check-out', keywords: ['checkout', 'check-out', 'check out', 'late'], examplePhrase: 'What time is check-out?'),
        ScenarioGoalItem(id: 'g5', text: 'Pedir ayuda con el equipaje', keywords: ['bags', 'luggage', 'help', 'carry'], examplePhrase: 'Could someone help with my bags?'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have a reservation under my name', translation: 'Tengo una reserva a mi nombre'),
        UsefulPhraseItem(id: 'p2', phrase: 'Do you have a room with a sea view?', translation: '¿Tienen una habitación con vista al mar?'),
        UsefulPhraseItem(id: 'p3', phrase: 'What time is check-out?', translation: '¿A qué hora es el check-out?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Is breakfast included?', translation: '¿El desayuno está incluido?'),
        UsefulPhraseItem(id: 'p5', phrase: 'Could someone help with my bags?', translation: '¿Alguien puede ayudarme con las maletas?'),
        UsefulPhraseItem(id: 'p6', phrase: 'Is there free wifi?', translation: '¿Hay wifi gratis?'),
        UsefulPhraseItem(id: 'p7', phrase: 'Can I get a late check-out?', translation: '¿Puedo hacer check-out tarde?'),
        UsefulPhraseItem(id: 'p8', phrase: 'Is there a gym in the hotel?', translation: '¿Hay gimnasio en el hotel?'),
        UsefulPhraseItem(id: 'p9', phrase: "I'd like to extend my stay", translation: 'Me gustaría extender mi estadía'),
        UsefulPhraseItem(id: 'p10', phrase: "What's the wifi password?", translation: '¿Cuál es la contraseña del wifi?'),
      ],
    ),

    LessonData(
      id: 'a2_past_experiences',
      title: 'Contar Experiencias Pasadas',
      description: 'Narra un viaje o evento del pasado usando verbos en pasado simple.',
      level: 'A2',
      category: 'social',
      interest: 'social',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Compartir vivencias pasadas y emociones sobre tus vacaciones.',
      scenarioContext: 'Coffee shop conversation',
      assistantRole: 'Friend',
      userRole: 'Friend',
      initialAssistantMessage: 'So, tell me about your last vacation. Where did you go?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Narrar un viaje o evento pasado', keywords: ['went', 'traveled', 'visited', 'vacation', 'trip'], examplePhrase: 'I went to Colombia last year'),
        ScenarioGoalItem(id: 'g2', text: 'Usar verbos en pasado simple', keywords: ['visited', 'stayed', 'saw', 'ate', 'had', 'was'], examplePhrase: 'I visited my grandparents'),
        ScenarioGoalItem(id: 'g3', text: 'Describir cómo te sentiste', keywords: ['felt', 'was', 'happy', 'excited', 'tired', 'amazing'], examplePhrase: 'I felt really happy'),
        ScenarioGoalItem(id: 'g4', text: 'Mencionar algo que salió mal', keywords: ['missed', 'wrong', 'problem', 'delay', 'lost'], examplePhrase: 'We missed our flight'),
        ScenarioGoalItem(id: 'g5', text: 'Recomendar el lugar', keywords: ['recommend', 'suggest', 'should go', 'must visit'], examplePhrase: 'I would definitely recommend it'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I went to Colombia last year', translation: 'Fui a Colombia el año pasado'),
        UsefulPhraseItem(id: 'p2', phrase: 'I visited my grandparents', translation: 'Visité a mis abuelos'),
        UsefulPhraseItem(id: 'p3', phrase: 'It was an amazing experience', translation: 'Fue una experiencia increíble'),
        UsefulPhraseItem(id: 'p4', phrase: 'We missed our flight', translation: 'Perdimos nuestro vuelo'),
        UsefulPhraseItem(id: 'p5', phrase: 'I felt really tired', translation: 'Me sentí muy cansado'),
        UsefulPhraseItem(id: 'p6', phrase: 'I would definitely recommend it', translation: 'Definitivamente lo recomendaría'),
        UsefulPhraseItem(id: 'p7', phrase: 'We stayed for a week', translation: 'Nos quedamos una semana'),
        UsefulPhraseItem(id: 'p8', phrase: 'I learned a lot', translation: 'Aprendí mucho'),
        UsefulPhraseItem(id: 'p9', phrase: 'Something went wrong with...', translation: 'Algo salió mal con...'),
        UsefulPhraseItem(id: 'p10', phrase: "It didn't go as planned", translation: 'No salió como lo planeamos'),
      ],
    ),

    // =========================================================================
    // NIVEL B1 — Intermedio
    // =========================================================================

    LessonData(
      id: 'b1_tech',
      title: 'Artificial Intelligence and Workplace Impact',
      description: 'Discuss automation, AI tools, and remote work trends with your colleague.',
      level: 'B1',
      category: 'technology',
      interest: 'technology',
      difficulty: 3,
      iconKey: 'devices',
      mainObjective: 'Express arguments clearly regarding tech tools and productivity.',
      scenarioContext: 'Tech office discussion',
      assistantRole: 'Senior Tech Lead',
      userRole: 'Software Developer',
      initialAssistantMessage: 'Hey! We are evaluating new AI tools for our engineering team. What is your perspective on automating daily tasks?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Dar tu opinión sobre las herramientas de IA', keywords: ['opinion', 'think', 'believe', 'view'], examplePhrase: 'In my opinion, AI helps productivity'),
        ScenarioGoalItem(id: 'g2', text: 'Mencionar ventajas o desventajas del trabajo remoto', keywords: ['remote', 'flexibility', 'home', 'office', 'hybrid'], examplePhrase: 'Remote work improves flexibility'),
        ScenarioGoalItem(id: 'g3', text: 'Discutir sobre productividad y código', keywords: ['productivity', 'code', 'automation', 'efficiency'], examplePhrase: 'AI tools increase productivity'),
        ScenarioGoalItem(id: 'g4', text: 'Preguntar la postura de tu interlocutor', keywords: ['think', 'what about', 'your perspective', 'you think'], examplePhrase: 'What do you think about automation?'),
        ScenarioGoalItem(id: 'g5', text: 'Resumir tu conclusión final', keywords: ['conclusion', 'in summary', 'overall', 'final'], examplePhrase: 'In conclusion, technology empowers developers'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'In my opinion, AI accelerates daily tasks', translation: 'En mi opinión, la IA acelera tareas diarias'),
        UsefulPhraseItem(id: 'p2', phrase: 'On the other hand, remote work improves flexibility', translation: 'Por otro lado, el trabajo remoto mejora la flexibilidad'),
        UsefulPhraseItem(id: 'p3', phrase: 'What do you think about automation?', translation: '¿Qué opinas sobre la automatización?'),
        UsefulPhraseItem(id: 'p4', phrase: 'AI tools increase productivity', translation: 'Las herramientas de IA aumentan la productividad'),
        UsefulPhraseItem(id: 'p5', phrase: 'However, data security is crucial', translation: 'Sin embargo, la seguridad de datos es crucial'),
        UsefulPhraseItem(id: 'p6', phrase: 'I agree with your point', translation: 'Estoy de acuerdo con tu punto'),
        UsefulPhraseItem(id: 'p7', phrase: 'We need to consider human oversight', translation: 'Necesitamos considerar la supervisión humana'),
        UsefulPhraseItem(id: 'p8', phrase: 'That makes a lot of sense', translation: 'Eso tiene mucho sentido'),
        UsefulPhraseItem(id: 'p9', phrase: 'What are the main drawbacks?', translation: '¿Cuáles son las desventajas principales?'),
        UsefulPhraseItem(id: 'p10', phrase: 'In conclusion, technology empowers developers', translation: 'En conclusión, la tecnología empodera desarrolladores'),
      ],
    ),

    LessonData(
      id: 'b1_job_interview',
      title: 'Entrevista de Trabajo Inicial',
      description: 'Presenta tu experiencia laboral, fortalezas y por qué deseas la vacante.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Comunicar tus antecedentes y responder preguntas de selección.',
      scenarioContext: 'Job interview room',
      assistantRole: 'HR Recruiter',
      userRole: 'Candidate',
      initialAssistantMessage: "Thanks for coming in. So, tell me a bit about yourself.",
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Presentar tu experiencia profesional', keywords: ['experience', 'background', 'worked', 'years'], examplePhrase: 'I have three years of experience'),
        ScenarioGoalItem(id: 'g2', text: 'Explicar por qué quieres el puesto', keywords: ['role', 'position', 'interested', 'opportunity'], examplePhrase: "I'm really interested in this role"),
        ScenarioGoalItem(id: 'g3', text: 'Describir una fortaleza principal', keywords: ['strength', 'good at', 'skilled', 'strong'], examplePhrase: 'One of my strengths is problem-solving'),
        ScenarioGoalItem(id: 'g4', text: 'Mencionar una habilidad a mejorar', keywords: ['improving', 'learning', 'develop', 'growth'], examplePhrase: "I'm working on improving my leadership skills"),
        ScenarioGoalItem(id: 'g5', text: 'Hacer una pregunta al entrevistador', keywords: ['team', 'culture', 'tell me about', 'typical day'], examplePhrase: 'Could you tell me more about the team?'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have three years of experience in...', translation: 'Tengo tres años de experiencia en...'),
        UsefulPhraseItem(id: 'p2', phrase: "I'm really interested in this role because...", translation: 'Me interesa mucho este puesto porque...'),
        UsefulPhraseItem(id: 'p3', phrase: 'One of my strengths is...', translation: 'Una de mis fortalezas es...'),
        UsefulPhraseItem(id: 'p4', phrase: "I'm working on improving...", translation: 'Estoy trabajando en mejorar...'),
        UsefulPhraseItem(id: 'p5', phrase: 'If I faced that situation, I would...', translation: 'Si enfrentara esa situación, yo...'),
        UsefulPhraseItem(id: 'p6', phrase: 'Could you tell me more about the team?', translation: '¿Podría contarme más sobre el equipo?'),
        UsefulPhraseItem(id: 'p7', phrase: "I've led several projects", translation: 'He liderado varios proyectos'),
        UsefulPhraseItem(id: 'p8', phrase: 'What does a typical day look like?', translation: '¿Cómo es un día típico?'),
        UsefulPhraseItem(id: 'p9', phrase: "I'm a fast learner", translation: 'Aprendo rápido'),
        UsefulPhraseItem(id: 'p10', phrase: 'Thank you for the opportunity', translation: 'Gracias por la oportunidad'),
      ],
    ),

    // =========================================================================
    // NIVEL B2 — Intermedio Alto
    // =========================================================================

    LessonData(
      id: 'l2', // entrevista_b2
      title: 'Tech Job Interview at a Startup',
      description: 'Answer key recruiter questions regarding career history, technical strengths, and problem solving.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Demonstrate fluency and leadership when explaining complex career accomplishments.',
      scenarioContext: 'Job interview',
      assistantRole: 'HR Hiring Manager',
      userRole: 'Job Applicant',
      initialAssistantMessage: 'Welcome to your interview! To start, could you please introduce yourself and walk me through your recent background?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describir tu trayectoria en la industria tech', keywords: ['experience', 'background', 'led', 'managed', 'previous'], examplePhrase: 'In my previous role, I led key projects'),
        ScenarioGoalItem(id: 'g2', text: 'Explicar tu fortaleza en resolución de problemas', keywords: ['strength', 'problem-solving', 'solve', 'challenge'], examplePhrase: 'One of my greatest strengths is problem-solving'),
        ScenarioGoalItem(id: 'g3', text: 'Describir un reto técnico difícil resuelto', keywords: ['problem', 'challenge', 'difficult', 'issue', 'solved'], examplePhrase: 'I solved a complex scaling issue'),
        ScenarioGoalItem(id: 'g4', text: 'Preguntar sobre la cultura de ingeniería', keywords: ['culture', 'team', 'engineering', 'environment'], examplePhrase: 'Could you tell me about the team culture?'),
        ScenarioGoalItem(id: 'g5', text: 'Agradecer y consultar por los siguientes pasos', keywords: ['next', 'steps', 'timeline', 'thank'], examplePhrase: 'What are the next steps?'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'In my previous role, I led key projects', translation: 'En mi rol anterior, lideré proyectos clave'),
        UsefulPhraseItem(id: 'p2', phrase: 'One of my greatest strengths is problem-solving', translation: 'Una de mis fortalezas es la resolución de problemas'),
        UsefulPhraseItem(id: 'p3', phrase: 'Could you tell me more about the team culture?', translation: '¿Podría contarme más sobre la cultura del equipo?'),
        UsefulPhraseItem(id: 'p4', phrase: 'I am passionate about building scalable software', translation: 'Me apasiona crear software escalable'),
        UsefulPhraseItem(id: 'p5', phrase: 'I handled cross-functional collaboration effectively', translation: 'Manejé la colaboración multifuncional con eficacia'),
        UsefulPhraseItem(id: 'p6', phrase: 'When faced with tight deadlines, I prioritize tasks', translation: 'Al enfrentar plazos ajustados, priorizo tareas'),
        UsefulPhraseItem(id: 'p7', phrase: 'I am eager to contribute to your growth', translation: 'Estoy entusiasmado por contribuir a su crecimiento'),
        UsefulPhraseItem(id: 'p8', phrase: 'What are the upcoming goals for this team?', translation: '¿Cuáles son las metas próximas de este equipo?'),
        UsefulPhraseItem(id: 'p9', phrase: 'What is the timeline for the next steps?', translation: '¿Cuál es el cronograma para los siguientes pasos?'),
        UsefulPhraseItem(id: 'p10', phrase: 'Thank you for your time today', translation: 'Gracias por su tiempo hoy'),
      ],
    ),

    LessonData(
      id: 'b2_business_meeting',
      title: 'Reunión de Negocios y Resultados Q3',
      description: 'Presenta métricas de desempeño, defiende propuestas y responde objeciones.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Dirigir una sección de la junta ejecutiva argumentando decisiones comerciales.',
      scenarioContext: 'Executive boardroom',
      assistantRole: 'CEO / Partner',
      userRole: 'Department Head',
      initialAssistantMessage: "Alright, let's get started. Can you walk us through the Q3 numbers?",
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Presentar los números y resultados', keywords: ['numbers', 'revenue', 'growth', 'results', 'increased'], examplePhrase: 'Revenue increased by 15%'),
        ScenarioGoalItem(id: 'g2', text: 'Responder preguntas de seguimiento', keywords: ['question', 'good question', 'great question', 'follow-up'], examplePhrase: "That's a great question"),
        ScenarioGoalItem(id: 'g3', text: 'Proponer un siguiente paso o inversión', keywords: ['propose', 'suggest', 'recommend', 'investment', 'next step'], examplePhrase: "I'd like to propose that we..."),
        ScenarioGoalItem(id: 'g4', text: 'Manejar una objeción con educación', keywords: ['however', 'understand', 'point', 'perspective', 'but'], examplePhrase: "I see your point, however..."),
        ScenarioGoalItem(id: 'g5', text: 'Resumir acuerdos y próximos pasos', keywords: ['summary', 'summarize', 'next steps', 'wrap up'], examplePhrase: 'To summarize, our next steps are...'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Let me walk you through the numbers', translation: 'Déjenme explicarles los números'),
        UsefulPhraseItem(id: 'p2', phrase: 'As you can see, revenue increased by...', translation: 'Como pueden ver, los ingresos aumentaron en...'),
        UsefulPhraseItem(id: 'p3', phrase: "That's a great question — here's my take", translation: 'Esa es una gran pregunta, esta es mi opinión'),
        UsefulPhraseItem(id: 'p4', phrase: "I'd like to propose that we...", translation: 'Me gustaría proponer que...'),
        UsefulPhraseItem(id: 'p5', phrase: "I see where you're coming from, however...", translation: 'Entiendo su punto, sin embargo...'),
        UsefulPhraseItem(id: 'p6', phrase: "Let's take that offline", translation: 'Hablemos de eso después, aparte'),
        UsefulPhraseItem(id: 'p7', phrase: 'To summarize, our next steps are...', translation: 'Para resumir, nuestros próximos pasos son...'),
        UsefulPhraseItem(id: 'p8', phrase: "Who's taking ownership of this?", translation: '¿Quién se hará responsable de esto?'),
        UsefulPhraseItem(id: 'p9', phrase: "Let's circle back next week", translation: 'Retomemos esto la próxima semana'),
        UsefulPhraseItem(id: 'p10', phrase: 'Thanks everyone for your time', translation: 'Gracias a todos por su tiempo'),
      ],
    ),

    // =========================================================================
    // NIVEL C1 — Avanzado
    // =========================================================================

    LessonData(
      id: 'l4', // tech_c1
      title: 'Debate de Ética en IA y Automatización Global',
      description: 'Sostén una conversación sofisticada sobre gobernanza de datos y regulación tecnológica.',
      level: 'C1',
      category: 'technology',
      interest: 'technology',
      difficulty: 5,
      iconKey: 'devices',
      mainObjective: 'Articular opiniones técnicas de alto nivel con retórica avanzada.',
      scenarioContext: 'Global tech conference panel',
      assistantRole: 'Ethics Committee Chair',
      userRole: 'AI Researcher',
      initialAssistantMessage: 'Welcome panelist. As AI models scale rapidly, how should we balance innovation with strict regulatory frameworks?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Definir el impacto ético de modelos generativos', keywords: ['ethics', 'ethical', 'privacy', 'responsible', 'bias'], examplePhrase: 'Data privacy is an ethical priority'),
        ScenarioGoalItem(id: 'g2', text: 'Rebatir una postura con evidencia conceptual', keywords: ['however', 'challenge', 'counter', 'although', 'nevertheless'], examplePhrase: 'I would challenge that assumption'),
        ScenarioGoalItem(id: 'g3', text: 'Proponer marcos de autorregulación', keywords: ['framework', 'regulation', 'governance', 'policy', 'standard'], examplePhrase: 'We need a regulatory framework'),
        ScenarioGoalItem(id: 'g4', text: 'Discutir implicaciones económicas a largo plazo', keywords: ['economic', 'long-term', 'implications', 'impact', 'global'], examplePhrase: 'The long-term economic implications are profound'),
        ScenarioGoalItem(id: 'g5', text: 'Concluir con un llamado a la colaboración global', keywords: ['collaboration', 'global', 'together', 'benchmark', 'cooperation'], examplePhrase: 'Global collaboration is essential'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'From an ethical standpoint, data privacy is paramount', translation: 'Desde un punto de vista ético, la privacidad es primordial'),
        UsefulPhraseItem(id: 'p2', phrase: 'Notwithstanding the benefits, regulatory frameworks are necessary', translation: 'A pesar de los beneficios, se requieren marcos regulatorios'),
        UsefulPhraseItem(id: 'p3', phrase: 'This raises fundamental questions regarding accountability', translation: 'Esto plantea preguntas fundamentales sobre responsabilidad'),
        UsefulPhraseItem(id: 'p4', phrase: 'It is a double-edged sword that requires oversight', translation: 'Es un arma de doble filo que requiere supervisión'),
        UsefulPhraseItem(id: 'p5', phrase: 'We must avoid hasty generalizations', translation: 'Debemos evitar generalizaciones apresuradas'),
        UsefulPhraseItem(id: 'p6', phrase: 'The long-term implications are profound', translation: 'Las implicaciones a largo plazo son profundas'),
        UsefulPhraseItem(id: 'p7', phrase: 'I would challenge that assumption', translation: 'Yo desafiaría esa suposición'),
        UsefulPhraseItem(id: 'p8', phrase: 'In essence, transparency builds public trust', translation: 'En esencia, la transparencia construye confianza pública'),
        UsefulPhraseItem(id: 'p9', phrase: 'We ought to establish global benchmarks', translation: 'Deberíamos establecer puntos de referencia globales'),
        UsefulPhraseItem(id: 'p10', phrase: 'To sum up, governance should match technological speed', translation: 'Para resumir, la gobernanza debe igualar la velocidad tecnológica'),
      ],
    ),

    // =========================================================================
    // NIVEL C2 — Maestría / Casi nativo
    // =========================================================================

    LessonData(
      id: 'c2_academic_debate',
      title: 'Academic Roundtable: Geopolitical Analysis',
      description: 'Engage in a sophisticated panel discussion analyzing geopolitical trends with precise academic language.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Articulate complex geopolitical concepts with native-like fluency and nuanced argumentation.',
      scenarioContext: 'University academic roundtable',
      assistantRole: 'Professor / Panel Moderator',
      userRole: 'Guest Academic Researcher',
      initialAssistantMessage: 'Welcome, colleagues. Today we examine the shifting paradigms in global trade policy. Dr. Mendoza, would you care to share your latest findings on supply chain resilience?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Utilizar vocabulario académico de alto nivel con precisión', keywords: ['paradigm', 'perspective', 'framework', 'fundamental'], examplePhrase: 'This represents a paradigm shift'),
        ScenarioGoalItem(id: 'g2', text: 'Expresar matices y sutilezas en argumentos complejos', keywords: ['nuance', 'subtle', 'complex', 'underlying', 'implies'], examplePhrase: 'The data suggests a more nuanced interpretation'),
        ScenarioGoalItem(id: 'g3', text: 'Responder a contraargumentos de forma estructurada', keywords: ['counterargument', 'however', 'while', 'nevertheless', 'juxtaposition'], examplePhrase: 'I would counter that argument by...'),
        ScenarioGoalItem(id: 'g4', text: 'Usar referencias culturales e idiomáticas avanzadas', keywords: ['reference', 'context', 'parallel', 'reminiscent'], examplePhrase: 'This is reminiscent of...'),
        ScenarioGoalItem(id: 'g5', text: 'Sintetizar y concluir con propuestas originales', keywords: ['synthesize', 'conclude', 'in sum', 'evidence suggests', 'venture'], examplePhrase: 'In sum, the evidence points toward...'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'From a macroeconomic perspective...', translation: 'Desde una perspectiva macroeconómica...'),
        UsefulPhraseItem(id: 'p2', phrase: 'The underlying assumption warrants closer scrutiny', translation: 'La suposición subyacente merece un examen más detenido'),
        UsefulPhraseItem(id: 'p3', phrase: 'This begs the question of whether...', translation: 'Esto plantea la cuestión de si...'),
        UsefulPhraseItem(id: 'p4', phrase: 'Notwithstanding the aforementioned limitations...', translation: 'No obstante las limitaciones mencionadas...'),
        UsefulPhraseItem(id: 'p5', phrase: 'The data suggests a more nuanced interpretation', translation: 'Los datos sugieren una interpretación más matizada'),
        UsefulPhraseItem(id: 'p6', phrase: 'By the same token, we must consider...', translation: 'Del mismo modo, debemos considerar...'),
        UsefulPhraseItem(id: 'p7', phrase: 'To posit that... would be an oversimplification', translation: 'Sostener que... sería una simplificación excesiva'),
        UsefulPhraseItem(id: 'p8', phrase: 'This juxtaposition highlights a fundamental tension', translation: 'Esta yuxtaposición resalta una tensión fundamental'),
        UsefulPhraseItem(id: 'p9', phrase: 'In sum, the evidence points toward...', translation: 'En suma, la evidencia apunta hacia...'),
        UsefulPhraseItem(id: 'p10', phrase: 'I would venture to suggest that...', translation: 'Me atrevería a sugerir que...'),
      ],
    ),

    LessonData(
      id: 'c2_literary_critique',
      title: 'Literary Critique & Discourse',
      description: 'Analyze and critique a contemporary novel, exploring themes, symbolism, and authorial intent at a native level.',
      level: 'C2',
      category: 'social',
      interest: 'art',
      difficulty: 6,
      iconKey: 'handshake',
      mainObjective: 'Demonstrate mastery of abstract literary analysis and cultural discourse.',
      scenarioContext: 'Literary salon / Book club',
      assistantRole: 'Literary Critic / Fellow Reader',
      userRole: 'Literature Enthusiast',
      initialAssistantMessage: 'I found the author\'s use of maritime imagery throughout the second act quite compelling. How do you interpret the recurring motif of the lighthouse?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analizar simbolismo y metáforas complejas', keywords: ['symbolism', 'metaphor', 'imagery', 'motif', 'allegory'], examplePhrase: 'The maritime imagery symbolizes freedom'),
        ScenarioGoalItem(id: 'g2', text: 'Discutir intención autoral con referencias textuales', keywords: ['authorial', 'author', 'narrative', 'subtext', 'device'], examplePhrase: 'The author deftly employs irony'),
        ScenarioGoalItem(id: 'g3', text: 'Comparar corrientes literarias y contextos históricos', keywords: ['literary', 'movement', 'era', 'postmodern', 'romantic'], examplePhrase: 'This passage reflects the modernist movement'),
        ScenarioGoalItem(id: 'g4', text: 'Expresar crítica constructiva con diplomacia', keywords: ['critique', 'criticism', 'however', 'while', 'although'], examplePhrase: 'While I take your point, I would counter that...'),
        ScenarioGoalItem(id: 'g5', text: 'Construir un argumento interpretativo coherente', keywords: ['interpretation', 'reading', 'argue', 'meaning', 'thematic'], examplePhrase: 'One could argue the subtext reveals...'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'The narrative arc is reminiscent of...', translation: 'El arco narrativo recuerda a...'),
        UsefulPhraseItem(id: 'p2', phrase: 'One could argue that the subtext reveals...', translation: 'Se podría argumentar que el subtexto revela...'),
        UsefulPhraseItem(id: 'p3', phrase: 'The author deftly employs... as a device to...', translation: 'El autor emplea hábilmente... como recurso para...'),
        UsefulPhraseItem(id: 'p4', phrase: 'This passage invites a post-structuralist reading', translation: 'Este pasaje invita a una lectura post-estructuralista'),
        UsefulPhraseItem(id: 'p5', phrase: 'The dichotomy between X and Y serves to...', translation: 'La dicotomía entre X e Y sirve para...'),
        UsefulPhraseItem(id: 'p6', phrase: 'While I take your point, I would counter that...', translation: 'Si bien acepto tu punto, yo contraargumentaría que...'),
        UsefulPhraseItem(id: 'p7', phrase: 'This is emblematic of a broader thematic concern', translation: 'Esto es emblemático de una preocupación temática más amplia'),
        UsefulPhraseItem(id: 'p8', phrase: 'The denouement feels somewhat contrived', translation: 'El desenlace parece un tanto forzado'),
        UsefulPhraseItem(id: 'p9', phrase: 'On a meta-textual level, the narrative subverts...', translation: 'A nivel meta-textual, la narrativa subvierte...'),
        UsefulPhraseItem(id: 'p10', phrase: 'To conclude, the work stands as a testament to...', translation: 'Para concluir, la obra es un testimonio de...'),
      ],
    ),

    LessonData(
      id: 'c2_corporate_crisis',
      title: 'Boardroom Crisis Negotiation',
      description: 'Negotiate a severe corporate crisis involving a hostile takeover and public relations fallout at a mastery level.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Handle high-stakes boardroom arguments, diffuse tensions, and present a bulletproof strategic plan.',
      scenarioContext: 'Emergency board of directors meeting',
      assistantRole: 'Hostile Shareholder / Board Chairman',
      userRole: 'Chief Executive Officer (CEO)',
      initialAssistantMessage: 'Let\'s cut to the chase. Stock prices are in freefall, and the public is demanding accountability. Why should this board not vote to replace you immediately?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Justificar decisiones con vocabulario estratégico de alto nivel', keywords: ['mitigate', 'diversification', 'fiduciary', 'stakeholders'], examplePhrase: 'We must mitigate these risks immediately'),
        ScenarioGoalItem(id: 'g2', text: 'Negociar concesiones y acuerdos bilaterales', keywords: ['compromise', 'concession', 'mutual', 'alignment'], examplePhrase: 'I propose a compromise that aligns with our goals'),
        ScenarioGoalItem(id: 'g3', text: 'Desviar críticas y reencuadrar la narrativa corporativa', keywords: ['reframe', 'narrative', 'opportunity', 'long-term'], examplePhrase: 'Let us reframe this challenge as an opportunity'),
        ScenarioGoalItem(id: 'g4', text: 'Usar retórica formal y diplomática para calmar tensiones', keywords: ['diplomatic', 'assure', 'collaborative', 'stability'], examplePhrase: 'I assure you we are taking decisive action'),
        ScenarioGoalItem(id: 'g5', text: 'Sintetizar un plan de acción a corto y largo plazo', keywords: ['roadmap', 'milestones', 'objectives', 'execution'], examplePhrase: 'Our immediate roadmap focuses on stability'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'To mitigate any further damage to our brand reputation...', translation: 'Para mitigar cualquier daño adicional a la reputación de nuestra marca...'),
        UsefulPhraseItem(id: 'p2', phrase: 'Our fiduciary duty to our stakeholders dictates that...', translation: 'Nuestro deber fiduciario hacia nuestros grupos de interés dicta que...'),
        UsefulPhraseItem(id: 'p3', phrase: 'Allow me to reframe the narrative surrounding this incident...', translation: 'Permítanme reencuadrar la narrativa que rodea a este incidente...'),
        UsefulPhraseItem(id: 'p4', phrase: 'I propose a collaborative roadmap with clear milestones...', translation: 'Propongo una hoja de ruta colaborativa con hitos claros...'),
        UsefulPhraseItem(id: 'p5', phrase: 'This is not a setback, but rather a catalyst for...', translation: 'Esto no es un contratiempo, sino más bien un catalizador para...'),
        UsefulPhraseItem(id: 'p6', phrase: 'I assure the board we are taking decisive action...', translation: 'Aseguro a la junta que estamos tomando medidas decisivas...'),
        UsefulPhraseItem(id: 'p7', phrase: 'A hostile takeover would severely jeopardize our stability...', translation: 'Una adquisición hostil pondría en grave peligro nuestra estabilidad...'),
        UsefulPhraseItem(id: 'p8', phrase: 'We must seek a mutually beneficial compromise...', translation: 'Debemos buscar un compromiso mutuamente beneficioso...'),
        UsefulPhraseItem(id: 'p9', phrase: 'This strategy aligns perfectly with our long-term vision...', translation: 'Esta estrategia se alinea perfectamente con nuestra visión a largo plazo...'),
        UsefulPhraseItem(id: 'p10', phrase: 'I welcome your input on these remedial measures...', translation: 'Agradezco sus comentarios sobre estas medidas correctivas...'),
      ],
    ),

    LessonData(
      id: 'c2_philosophical_discourse',
      title: 'Ethical Frontiers: AI & Transhumanism',
      description: 'Engage in a profound philosophical debate on technological ethics and human consciousness.',
      level: 'C2',
      category: 'social',
      interest: 'philosophy',
      difficulty: 6,
      iconKey: 'psychology',
      mainObjective: 'Explore and critique abstract theories on post-humanism and ethical boundaries of intelligence.',
      scenarioContext: 'Philosophical symposium',
      assistantRole: 'Bioethicist / Academic Chair',
      userRole: 'Philosopher of Mind',
      initialAssistantMessage: 'As cybernetic enhancements become indistinguishable from biological functions, we must ask: does transhumanism preserve humanity, or does it render the concept of human rights obsolete?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analizar implicaciones éticas y filosóficas profundas', keywords: ['ethics', 'moral', 'imperative', 'philosophical', 'dilemma'], examplePhrase: 'This poses a significant ethical dilemma'),
        ScenarioGoalItem(id: 'g2', text: 'Discutir teorías abstractas sobre la conciencia', keywords: ['consciousness', 'sentience', 'cognitive', 'existential'], examplePhrase: 'We must define the boundary of sentience'),
        ScenarioGoalItem(id: 'g3', text: 'Argumentar sobre dilemas existenciales futuros', keywords: ['existential', 'post-human', 'transhumanism', 'obsolete'], examplePhrase: 'This could render human labor obsolete'),
        ScenarioGoalItem(id: 'g4', text: 'Desafiar premisas lógicas de forma estructurada', keywords: ['premise', 'fallacy', 'validity', 'inconsistency'], examplePhrase: 'That premise relies on a logical fallacy'),
        ScenarioGoalItem(id: 'g5', text: 'Sintetizar una postura ética unificada', keywords: ['harmonize', 'ethical framework', 'synthesis', 'human dignity'], examplePhrase: 'We need to synthesize an ethical framework'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'This poses a profound existential dilemma...', translation: 'Esto plantea un dilema existencial profundo...'),
        UsefulPhraseItem(id: 'p2', phrase: 'We must critically examine the ethical boundaries of...', translation: 'Debemos examinar críticamente los límites éticos de...'),
        UsefulPhraseItem(id: 'p3', phrase: 'That premise relies on what I perceive as a logical fallacy...', translation: 'Esa premisa se basa en lo que percibo como una falacia lógica...'),
        UsefulPhraseItem(id: 'p4', phrase: 'If we are to preserve fundamental human dignity...', translation: 'Si queremos preservar la dignidad humana fundamental...'),
        UsefulPhraseItem(id: 'p5', phrase: 'The distinction between biological and synthetic sentience...', translation: 'La distinción entre la sintiencia biológica y sintética...'),
        UsefulPhraseItem(id: 'p6', phrase: 'I would posit that consciousness is not substrate-dependent...', translation: 'Sostendría que la conciencia no depende del sustrato...'),
        UsefulPhraseItem(id: 'p7', phrase: 'This debate is reminiscent of classical Cartesian dualism...', translation: 'Este debate recuerda al dualismo cartesiano clásico...'),
        UsefulPhraseItem(id: 'p8', phrase: 'Such an outcome would render the social contract obsolete...', translation: 'Tal resultado dejaría obsoleto el contrato social...'),
        UsefulPhraseItem(id: 'p9', phrase: 'We must synthesize a robust, proactive regulatory framework...', translation: 'Debemos sintetizar un marco regulatorio robusto y proactivo...'),
        UsefulPhraseItem(id: 'p10', phrase: 'By positing this, we inadvertently invite...', translation: 'Al plantear esto, invitamos inadvertidamente a...'),
      ],
    ),
  ];

  static final Map<String, LessonData> dynamicCatalogCache = {};

  static void updateCatalogFromMap(Map<String, dynamic> data) {
    try {
      final id = data['id']?.toString();
      if (id == null || id.isEmpty) return;

      final title = data['title'] as String? ?? 'Escenario';
      final description = data['description'] as String? ?? '';
      final level = data['difficulty_level'] as String? ?? 'A1';
      final category = data['category'] as String? ?? 'general';

      List<ScenarioGoalItem> goals = [];
      if (data['goals'] != null) {
        final rawGoals = data['goals'];
        if (rawGoals is List) {
          goals = rawGoals.asMap().entries.map<ScenarioGoalItem>((entry) {
            final idx = entry.key + 1;
            final g = entry.value;
            if (g is Map) {
              final text = g['text']?.toString() ?? '';
              final keyword = g['keyword']?.toString() ?? text.split(' ').last;
              final keywords = g['keywords'] is List
                  ? (g['keywords'] as List).map((k) => k.toString()).toList()
                  : [keyword];
              final example = g['examplePhrase']?.toString() ?? text;
              return ScenarioGoalItem(
                id: (g['id'] != null && g['id'].toString().isNotEmpty) ? g['id'].toString() : 'g$idx',
                text: text,
                keywords: keywords,
                examplePhrase: example,
              );
            }
            return ScenarioGoalItem(
              id: 'g$idx',
              text: g.toString(),
              keywords: [g.toString().split(' ').last],
              examplePhrase: g.toString(),
            );
          }).toList();
        }
      }

      List<UsefulPhraseItem> usefulPhrases = [];
      if (data['useful_phrases'] != null) {
        final rawPhrases = data['useful_phrases'];
        if (rawPhrases is List) {
          final int langId = (data['language_id'] as num?)?.toInt() ?? 1;
          usefulPhrases = rawPhrases.asMap().entries.map<UsefulPhraseItem>((entry) {
            final idx = entry.key + 1;
            final p = entry.value;
            if (p is Map) {
              final orig = p['phrase']?.toString() ?? '';
              final translatedPhrase = translateUsefulPhrase(orig, category, langId);
              return UsefulPhraseItem(
                id: (p['id'] != null && p['id'].toString().isNotEmpty) ? p['id'].toString() : 'p$idx',
                phrase: translatedPhrase,
                translation: p['translation']?.toString() ?? '',
              );
            }
            final translated = translateUsefulPhrase(p.toString(), category, langId);
            return UsefulPhraseItem(id: 'p$idx', phrase: translated, translation: '');
          }).toList();
        }
      }

      final lessonObj = LessonData(
        id: id,
        title: title,
        description: description,
        level: level,
        category: category,
        interest: category,
        difficulty: 1,
        iconKey: 'chat',
        mainObjective: data['main_objective'] as String? ?? (description.isNotEmpty ? description : 'Practica tu conversación en "$title".'),
        scenarioContext: title,
        assistantRole: data['assistant_role'] as String? ?? 'Tutor de Idiomas AI',
        userRole: data['user_role'] as String? ?? 'Estudiante',
        initialAssistantMessage: data['initial_assistant_message'] as String? ?? 'Hello! Welcome to the $title session.',
        goals: goals.isNotEmpty ? goals : [
          ScenarioGoalItem(id: 'g1', text: 'Saludar e iniciar la interacción', keywords: ['hello', 'hi'], examplePhrase: 'Hello!'),
          ScenarioGoalItem(id: 'g2', text: 'Responder al tutor', keywords: ['yes', 'sure'], examplePhrase: 'Yes'),
          ScenarioGoalItem(id: 'g3', text: 'Expresar ideas principales', keywords: ['think', 'like'], examplePhrase: 'I think that'),
          ScenarioGoalItem(id: 'g4', text: 'Hacer una pregunta', keywords: ['what', 'how'], examplePhrase: 'What do you mean?'),
          ScenarioGoalItem(id: 'g5', text: 'Despedirte o concluir', keywords: ['bye', 'goodbye'], examplePhrase: 'Goodbye!'),
        ],
        usefulPhrases: usefulPhrases.isNotEmpty ? usefulPhrases : [
          UsefulPhraseItem(id: 'p1', phrase: 'Could you repeat that, please?', translation: '¿Podrías repetir eso, por favor?'),
          UsefulPhraseItem(id: 'p2', phrase: 'In my opinion...', translation: 'En mi opinión...'),
        ],
      );

      dynamicCatalogCache[id] = lessonObj;
      if (title.isNotEmpty) {
        dynamicCatalogCache[title.trim().toLowerCase()] = lessonObj;
      }
    } catch (e) {
      debugPrint('Error updating dynamic catalog cache: $e');
    }
  }

  static String translateUsefulPhrase(String key, String category, int languageId) {
    final cleanKey = key.trim().toLowerCase();

    // English (languageId = 1)
    if (languageId == 1) {
      if (cleanKey.contains('travel')) {
        if (cleanKey.contains('vocab_1')) return 'I would like to book a room';
        if (cleanKey.contains('vocab_2')) return 'Where is the train station?';
        if (cleanKey.contains('vocab_3')) return 'How much does this cost?';
        if (cleanKey.contains('vocab_4')) return 'Can I have a map, please?';
        if (cleanKey.contains('vocab_5')) return 'I need to check in';
        if (cleanKey.contains('expresion_6')) return 'Here is my passport';
        if (cleanKey.contains('expresion_7')) return 'Is breakfast included?';
        if (cleanKey.contains('expresion_8')) return 'At what time is check-out?';
        if (cleanKey.contains('expresion_9')) return 'Where can I get a taxi?';
        if (cleanKey.contains('expresion_10')) return 'Enjoy your trip!';
        if (cleanKey.contains('termino_11')) return 'Excuse me, where is the airport?';
        if (cleanKey.contains('termino_12')) return 'I have a flight delay';
        if (cleanKey.contains('termino_13')) return 'Where is the gate?';
        if (cleanKey.contains('termino_14')) return 'Can you help me with my bags?';
        if (cleanKey.contains('termino_15')) return 'I would like to rent a bike';
        if (cleanKey.contains('clave_16')) return 'I am looking for the museum';
        if (cleanKey.contains('clave_17')) return 'Could you help me, please?';
        if (cleanKey.contains('clave_18')) return 'I lost my wallet';
        if (cleanKey.contains('clave_19')) return 'Which platform is it?';
        if (cleanKey.contains('clave_20')) return 'Thank you for your help';
      }

      if (cleanKey.contains('business') || cleanKey.contains('work')) {
        if (cleanKey.contains('vocab_1')) return 'Let\'s schedule a meeting';
        if (cleanKey.contains('vocab_2')) return 'What is the project deadline?';
        if (cleanKey.contains('vocab_3')) return 'Here is the marketing plan';
        if (cleanKey.contains('vocab_4')) return 'We need to increase sales';
        if (cleanKey.contains('vocab_5')) return 'Can you review this report?';
        if (cleanKey.contains('expresion_6')) return 'Let\'s discuss the budget';
        if (cleanKey.contains('expresion_7')) return 'I agree with your proposal';
        if (cleanKey.contains('expresion_8')) return 'We should focus on team synergy';
        if (cleanKey.contains('expresion_9')) return 'What is our target audience?';
        if (cleanKey.contains('expresion_10')) return 'Thank you for the update';
        if (cleanKey.contains('termino_11')) return 'Let\'s align on the goals';
        if (cleanKey.contains('termino_12')) return 'I will send you the details';
        if (cleanKey.contains('termino_13')) return 'Let\'s start the presentation';
        if (cleanKey.contains('termino_14')) return 'We have a status call';
        if (cleanKey.contains('termino_15')) return 'Great working with you';
        if (cleanKey.contains('clave_16')) return 'Let\'s keep in touch';
        if (cleanKey.contains('clave_17')) return 'I will follow up on this';
        if (cleanKey.contains('clave_18')) return 'Let\'s brainstorm ideas';
        if (cleanKey.contains('clave_19')) return 'What is the next step?';
        if (cleanKey.contains('clave_20')) return 'Excellent progress';
      }
      
      // English general fallbacks
      if (cleanKey.contains('vocab_1')) return 'Could you help me?';
      if (cleanKey.contains('vocab_2')) return 'Where can I find it?';
      if (cleanKey.contains('vocab_3')) return 'How much is it?';
      if (cleanKey.contains('vocab_4')) return 'I would like this';
      if (cleanKey.contains('vocab_5')) return 'Thank you very much';
      if (cleanKey.contains('expresion_6')) return 'Could you repeat that?';
      if (cleanKey.contains('expresion_7')) return 'I don\'t understand';
      if (cleanKey.contains('expresion_8')) return 'What does this mean?';
      if (cleanKey.contains('expresion_9')) return 'Please speak slowly';
      if (cleanKey.contains('expresion_10')) return 'Have a nice day';
    }

    // French (languageId = 2)
    if (languageId == 2) {
      if (cleanKey.contains('travel')) {
        if (cleanKey.contains('vocab_1')) return 'Je voudrais réserver une chambre';
        if (cleanKey.contains('vocab_2')) return 'Où est la gare?';
        if (cleanKey.contains('vocab_3')) return 'Combien ça coûte?';
        if (cleanKey.contains('vocab_4')) return 'Un plan, s\'il vous plaît';
        if (cleanKey.contains('vocab_5')) return 'Je dois m\'enregistrer';
        if (cleanKey.contains('expresion_6')) return 'Voici mon passeport';
        if (cleanKey.contains('expresion_7')) return 'Le petit déjeuner est inclus?';
        if (cleanKey.contains('expresion_8')) return 'À quelle heure est le départ?';
        if (cleanKey.contains('expresion_9')) return 'Où trouver un taxi?';
        if (cleanKey.contains('expresion_10')) return 'Bon voyage!';
        if (cleanKey.contains('termino_11')) return 'Où est l\'aéroport?';
        if (cleanKey.contains('termino_12')) return 'Mon vol est retardé';
        if (cleanKey.contains('termino_13')) return 'Où est la porte d\'embarquement?';
        if (cleanKey.contains('termino_14')) return 'Aidez-moi avec mes bagages';
        if (cleanKey.contains('termino_15')) return 'Je veux louer un vélo';
        if (cleanKey.contains('clave_16')) return 'Je cherche le musée';
        if (cleanKey.contains('clave_17')) return 'Aidez-moi, s\'il vous plaît';
        if (cleanKey.contains('clave_18')) return 'J\'ai perdu mon portefeuille';
        if (cleanKey.contains('clave_19')) return 'Quel quai est-ce?';
        if (cleanKey.contains('clave_20')) return 'Merci pour votre aide';
      }

      if (cleanKey.contains('business') || cleanKey.contains('work')) {
        if (cleanKey.contains('vocab_1')) return 'Organisons une réunion';
        if (cleanKey.contains('vocab_2')) return 'Quelle est la date limite?';
        if (cleanKey.contains('vocab_3')) return 'Voici le plan marketing';
        if (cleanKey.contains('vocab_4')) return 'Il faut augmenter les ventes';
        if (cleanKey.contains('vocab_5')) return 'Pouvez-vous revoir ce rapport?';
        if (cleanKey.contains('expresion_6')) return 'Parlons du budget';
        if (cleanKey.contains('expresion_7')) return 'Je suis d\'accord avec vous';
        if (cleanKey.contains('expresion_8')) return 'Créons une synergie d\'équipe';
        if (cleanKey.contains('expresion_9')) return 'Quel est notre public cible?';
        if (cleanKey.contains('expresion_10')) return 'Merci pour la mise à jour';
      }
      
      // French general fallbacks
      if (cleanKey.contains('vocab_1')) return 'Pouvez-vous m\'aider?';
      if (cleanKey.contains('vocab_2')) return 'Où puis-je le trouver?';
      if (cleanKey.contains('vocab_3')) return 'C\'est combien?';
      if (cleanKey.contains('vocab_4')) return 'Je voudrais ceci';
      if (cleanKey.contains('vocab_5')) return 'Merci beaucoup';
      if (cleanKey.contains('expresion_6')) return 'Pouvez-vous répéter?';
      if (cleanKey.contains('expresion_7')) return 'Je ne comprends pas';
      if (cleanKey.contains('expresion_8')) return 'Qu\'est-ce que ça veut dire?';
      if (cleanKey.contains('expresion_9')) return 'Parlez lentement, s\'il vous plaît';
      if (cleanKey.contains('expresion_10')) return 'Bonne journée';
    }

    // German (languageId = 3)
    if (languageId == 3) {
      if (cleanKey.contains('travel')) {
        if (cleanKey.contains('vocab_1')) return 'Ich möchte ein Zimmer buchen';
        if (cleanKey.contains('vocab_2')) return 'Wo ist der Bahnhof?';
        if (cleanKey.contains('vocab_3')) return 'Wie viel kostet das?';
        if (cleanKey.contains('vocab_4')) return 'Eine Karte, bitte';
        if (cleanKey.contains('vocab_5')) return 'Ich muss einchecken';
        if (cleanKey.contains('expresion_6')) return 'Hier ist mein Reisepass';
        if (cleanKey.contains('expresion_7')) return 'Ist das Frühstück inklusive?';
        if (cleanKey.contains('expresion_8')) return 'Wann ist der Check-out?';
        if (cleanKey.contains('expresion_9')) return 'Wo finde ich ein Taxi?';
        if (cleanKey.contains('expresion_10')) return 'Gute Reise!';
        if (cleanKey.contains('termino_11')) return 'Wo ist der Flughafen?';
        if (cleanKey.contains('termino_12')) return 'Mein Flug ist verspätet';
        if (cleanKey.contains('termino_13')) return 'Wo ist das Gate?';
        if (cleanKey.contains('termino_14')) return 'Helfen Sie mir mit dem Gepäck';
        if (cleanKey.contains('termino_15')) return 'Ich möchte ein Fahrrad leihen';
        if (cleanKey.contains('clave_16')) return 'Ich suche das Museum';
        if (cleanKey.contains('clave_17')) return 'Helfen Sie mir, bitte';
        if (cleanKey.contains('clave_18')) return 'Ich habe meine Brieftasche verloren';
        if (cleanKey.contains('clave_19')) return 'Welches Gleis ist es?';
        if (cleanKey.contains('clave_20')) return 'Danke für Ihre Hilfe';
      }

      if (cleanKey.contains('business') || cleanKey.contains('work')) {
        if (cleanKey.contains('vocab_1')) return 'Planen wir ein Meeting';
        if (cleanKey.contains('vocab_2')) return 'Wann ist die Frist?';
        if (cleanKey.contains('vocab_3')) return 'Hier ist der Marketingplan';
        if (cleanKey.contains('vocab_4')) return 'Wir müssen den Umsatz steigern';
        if (cleanKey.contains('vocab_5')) return 'Können Sie den Bericht prüfen?';
        if (cleanKey.contains('expresion_6')) return 'Besprechen wir das Budget';
        if (cleanKey.contains('expresion_7')) return 'Ich stimme Ihrem Vorschlag zu';
        if (cleanKey.contains('expresion_8')) return 'Fokus auf Teamsynergie';
        if (cleanKey.contains('expresion_9')) return 'Wer ist unsere Zielgruppe?';
        if (cleanKey.contains('expresion_10')) return 'Danke für das Update';
      }
      
      // German general fallbacks
      if (cleanKey.contains('vocab_1')) return 'Können Sie mir helfen?';
      if (cleanKey.contains('vocab_2')) return 'Wo finde ich das?';
      if (cleanKey.contains('vocab_3')) return 'Wie viel kostet es?';
      if (cleanKey.contains('vocab_4')) return 'Ich möchte das bitte';
      if (cleanKey.contains('vocab_5')) return 'Vielen Dank';
      if (cleanKey.contains('expresion_6')) return 'Können Sie das wiederholen?';
      if (cleanKey.contains('expresion_7')) return 'Ich verstehe nicht';
      if (cleanKey.contains('expresion_8')) return 'Was bedeutet das?';
      if (cleanKey.contains('expresion_9')) return 'Sprechen Sie bitte langsam';
      if (cleanKey.contains('expresion_10')) return 'Schönen Tag noch';
    }

    // Italian (languageId = 4)
    if (languageId == 4) {
      if (cleanKey.contains('travel')) {
        if (cleanKey.contains('vocab_1')) return 'Vorrei prenotare una camera';
        if (cleanKey.contains('vocab_2')) return 'Dov\'è la stazione ferroviaria?';
        if (cleanKey.contains('vocab_3')) return 'Quanto costa questo?';
        if (cleanKey.contains('vocab_4')) return 'Una mappa, per favore';
        if (cleanKey.contains('vocab_5')) return 'Devo fare il check-in';
        if (cleanKey.contains('expresion_6')) return 'Ecco il mio passaporto';
        if (cleanKey.contains('expresion_7')) return 'La colazione è inclusa?';
        if (cleanKey.contains('expresion_8')) return 'A che ora è il check-out?';
        if (cleanKey.contains('expresion_9')) return 'Dove posso prendere un taxi?';
        if (cleanKey.contains('expresion_10')) return 'Buon viaggio!';
        if (cleanKey.contains('termino_11')) return 'Dov\'è l\'aeroporto?';
        if (cleanKey.contains('termino_12')) return 'Il mio volo è in ritardo';
        if (cleanKey.contains('termino_13')) return 'Dov\'è il gate?';
        if (cleanKey.contains('termino_14')) return 'Può aiutarmi con i bagagli?';
        if (cleanKey.contains('termino_15')) return 'Vorrei noleggiare una bici';
        if (cleanKey.contains('clave_16')) return 'Sto cercando il museo';
        if (cleanKey.contains('clave_17')) return 'Mi aiuti, per favore';
        if (cleanKey.contains('clave_18')) return 'Ho perso il mio portafoglio';
        if (cleanKey.contains('clave_19')) return 'Quale binario è?';
        if (cleanKey.contains('clave_20')) return 'Grazie per il tuo aiuto';
      }

      if (cleanKey.contains('business') || cleanKey.contains('work')) {
        if (cleanKey.contains('vocab_1')) return 'Pianifichiamo una riunione';
        if (cleanKey.contains('vocab_2')) return 'Qual è la scadenza?';
        if (cleanKey.contains('vocab_3')) return 'Ecco il piano di marketing';
        if (cleanKey.contains('vocab_4')) return 'Dobbiamo aumentare le vendite';
        if (cleanKey.contains('vocab_5')) return 'Puoi rivedere questo rapporto?';
        if (cleanKey.contains('expresion_6')) return 'Discutiamo del budget';
        if (cleanKey.contains('expresion_7')) return 'Sono d\'accordo con la proposta';
        if (cleanKey.contains('expresion_8')) return 'Focalizziamoci sulla sinergia del team';
        if (cleanKey.contains('expresion_9')) return 'Qual è il nostro target?';
        if (cleanKey.contains('expresion_10')) return 'Grazie per l\'aggiornamento';
      }
      
      // Italian general fallbacks
      if (cleanKey.contains('vocab_1')) return 'Può aiutarmi?';
      if (cleanKey.contains('vocab_2')) return 'Dove posso trovarlo?';
      if (cleanKey.contains('vocab_3')) return 'Quanto costa?';
      if (cleanKey.contains('vocab_4')) return 'Vorrei questo';
      if (cleanKey.contains('vocab_5')) return 'Grazie mille';
      if (cleanKey.contains('expresion_6')) return 'Può ripetere?';
      if (cleanKey.contains('expresion_7')) return 'Non capisco';
      if (cleanKey.contains('expresion_8')) return 'Cosa significa?';
      if (cleanKey.contains('expresion_9')) return 'Parli lentamente, per favore';
      if (cleanKey.contains('expresion_10')) return 'Buona giornata';
    }

    if (!key.contains('_')) {
      return key;
    }
    return 'How do you say that in English?';
  }

  static LessonData? getLessonById(String? id, {String? title}) {
    final cleanId = id?.trim();
    final cleanTitle = title?.trim().toLowerCase();

    // 0. Check dynamic cache (from Supabase DB updates)
    if (cleanId != null && dynamicCatalogCache.containsKey(cleanId)) {
      return dynamicCatalogCache[cleanId];
    }
    if (cleanTitle != null && dynamicCatalogCache.containsKey(cleanTitle)) {
      return dynamicCatalogCache[cleanTitle];
    }

    // 1. Exact ID match
    if (cleanId != null && cleanId.isNotEmpty) {
      for (final l in catalog) {
        if (l.id == cleanId) return l;
      }
    }

    // 2. Exact or partial Title match
    if (cleanTitle != null && cleanTitle.isNotEmpty) {
      for (final l in catalog) {
        final lTitle = l.title.toLowerCase();
        if (lTitle == cleanTitle || lTitle.contains(cleanTitle) || cleanTitle.contains(lTitle)) {
          return l;
        }
      }
    }

    // 3. Substring match on ID
    if (cleanId != null && cleanId.isNotEmpty) {
      for (final l in catalog) {
        if (cleanId.contains(l.id) || l.id.contains(cleanId)) {
          return l;
        }
      }
    }

    // If neither id nor title provided, return catalog.first as a safe fallback
    if ((cleanId == null || cleanId.isEmpty) && (cleanTitle == null || cleanTitle.isEmpty)) {
      return catalog.first;
    }

    // 4. Dynamic LessonData fallback for custom/database scenarios so objective, goals and phrases always display
    final displayTitle = title ?? 'Práctica de Conversación';
    return LessonData(
      id: cleanId ?? 'custom_lesson',
      title: displayTitle,
      description: 'Práctica interactiva de conversación guiada.',
      level: 'A1-C2',
      category: 'general',
      interest: 'general',
      difficulty: 1,
      iconKey: 'chat',
      mainObjective: 'Practica tu fluidez, vocabulario y expresiones clave en el escenario "$displayTitle".',
      scenarioContext: displayTitle,
      assistantRole: 'Tutor de Idiomas AI',
      userRole: 'Estudiante',
      initialAssistantMessage: 'Hello! Welcome to the $displayTitle session. How would you like to start?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Saludar e iniciar la interacción', keywords: ['hello', 'hi', 'hey', 'good morning'], examplePhrase: 'Hello! How are you?'),
        ScenarioGoalItem(id: 'g2', text: 'Responder a las preguntas del tutor', keywords: ['yes', 'sure', 'okay', 'of course', 'i think'], examplePhrase: 'Yes, I think so'),
        ScenarioGoalItem(id: 'g3', text: 'Expresar tus ideas o preferencias', keywords: ['think', 'like', 'prefer', 'believe', 'opinion'], examplePhrase: 'I think that is interesting'),
        ScenarioGoalItem(id: 'g4', text: 'Hacer una pregunta sobre el tema', keywords: ['what', 'how', 'why', 'could you', 'can you'], examplePhrase: 'What do you mean by that?'),
        ScenarioGoalItem(id: 'g5', text: 'Concluir la conversación o despedirte', keywords: ['bye', 'goodbye', 'see you', 'thanks', 'that\'s all'], examplePhrase: 'Goodbye! See you later!'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Could you repeat that, please?', translation: '¿Podrías repetir eso, por favor?'),
        UsefulPhraseItem(id: 'p2', phrase: 'What do you mean by...?', translation: '¿Qué quieres decir con...?'),
        UsefulPhraseItem(id: 'p3', phrase: 'In my opinion...', translation: 'En mi opinión...'),
        UsefulPhraseItem(id: 'p4', phrase: 'Could you give me an example?', translation: '¿Podrías darme un ejemplo?'),
        UsefulPhraseItem(id: 'p5', phrase: 'That sounds interesting', translation: 'Eso suena interesante'),
        UsefulPhraseItem(id: 'p6', phrase: 'How do you say... in English?', translation: '¿Cómo se dice... en inglés?'),
        UsefulPhraseItem(id: 'p7', phrase: 'Thank you for your help', translation: 'Gracias por tu ayuda'),
      ],
    );
  }
}
