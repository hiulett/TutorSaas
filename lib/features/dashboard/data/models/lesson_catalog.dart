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
    // NIVEL A1 — A1 — Principiante (20 lecciones)
    // =========================================================================

    // A1-01
    LessonData(
      id: 'a1_ordering_coffee_at_a_cafe',
      title: 'Ordering Coffee at a Cafe',
      description: 'Practice ordering coffee and pastries using polite expressions.',
      level: 'A1',
      category: 'travel',
      interest: 'travel',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Order a coffee drink and snack with size preferences.',
      scenarioContext: 'You are a friendly barista at a local cafe. Interact with a beginner (A1) student learning target language code. Keep vocabulary simple and encourage basic politeness.',
      assistantRole: 'Barista',
      userRole: 'Customer',
      initialAssistantMessage: 'Hello! Welcome to Metro Cafe. What can I get started for you today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Order a coffee drink', keywords: ['order', 'coffee', 'drink'], examplePhrase: 'Order a coffee drink'),
        ScenarioGoalItem(id: 'g2', text: 'Specify milk or sugar preferences', keywords: ['specify', 'milk', 'sugar', 'preferences'], examplePhrase: 'Specify milk or sugar preferences'),
        ScenarioGoalItem(id: 'g3', text: 'Order a pastry', keywords: ['order', 'pastry'], examplePhrase: 'Order a pastry'),
        ScenarioGoalItem(id: 'g4', text: 'Ask for total price', keywords: ['ask', 'total', 'price'], examplePhrase: 'Ask for total price'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I would like a coffee, please.', translation: 'I would like a coffee, please.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Can I have oat milk?', translation: 'Can I have oat milk?'),
        UsefulPhraseItem(id: 'p3', phrase: 'How much is that?', translation: 'How much is that?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you!', translation: 'Thank you!'),
      ],
    ),

    // A1-02
    LessonData(
      id: 'a1_checking_into_a_hotel',
      title: 'Checking into a Hotel',
      description: 'Check into your hotel room and request basic amenities.',
      level: 'A1',
      category: 'travel',
      interest: 'travel',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Complete check-in process and ask about Wi-Fi and breakfast.',
      scenarioContext: 'You are a helpful hotel receptionist welcoming a guest. Keep sentences simple and slow for A1 level.',
      assistantRole: 'Hotel Receptionist',
      userRole: 'Hotel Guest',
      initialAssistantMessage: 'Good afternoon! Welcome to Grand View Hotel. Do you have a reservation with us?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Provide your name for reservation', keywords: ['provide', 'name', 'reservation'], examplePhrase: 'Provide your name for reservation'),
        ScenarioGoalItem(id: 'g2', text: 'Confirm room type', keywords: ['confirm', 'room', 'type'], examplePhrase: 'Confirm room type'),
        ScenarioGoalItem(id: 'g3', text: 'Ask for Wi-Fi password', keywords: ['ask', 'password'], examplePhrase: 'Ask for Wi-Fi password'),
        ScenarioGoalItem(id: 'g4', text: 'Inquire about breakfast hours', keywords: ['inquire', 'breakfast', 'hours'], examplePhrase: 'Inquire about breakfast hours'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have a reservation under my name.', translation: 'I have a reservation under my name.'),
        UsefulPhraseItem(id: 'p2', phrase: 'What time is breakfast?', translation: 'What time is breakfast?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Is Wi-Fi included?', translation: 'Is Wi-Fi included?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Where is the elevator?', translation: 'Where is the elevator?'),
      ],
    ),

    // A1-03
    LessonData(
      id: 'a1_asking_for_street_directions',
      title: 'Asking for Street Directions',
      description: 'Find your way around town by asking pedestrians for directions.',
      level: 'A1',
      category: 'travel',
      interest: 'travel',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Ask for directions and understand simple turn instructions.',
      scenarioContext: 'You are a friendly local walking on the street. Help a lost tourist reach Central Park with simple directional words.',
      assistantRole: 'Local Resident',
      userRole: 'Tourist',
      initialAssistantMessage: 'Excuse me! You look a bit lost. Can I help you find something in the city?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask how to reach Central Park', keywords: ['ask', 'how', 'reach', 'central', 'park'], examplePhrase: 'Ask how to reach Central Park'),
        ScenarioGoalItem(id: 'g2', text: 'Understand turn left/right', keywords: ['understand', 'turn', 'left', 'right'], examplePhrase: 'Understand turn left/right'),
        ScenarioGoalItem(id: 'g3', text: 'Ask if it is near on foot', keywords: ['ask', 'near', 'foot'], examplePhrase: 'Ask if it is near on foot'),
        ScenarioGoalItem(id: 'g4', text: 'Say thank you', keywords: ['say', 'thank'], examplePhrase: 'Say thank you'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Excuse me, where is Central Park?', translation: 'Excuse me, where is Central Park?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Is it far from here?', translation: 'Is it far from here?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Should I turn left or right?', translation: 'Should I turn left or right?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you so much!', translation: 'Thank you so much!'),
      ],
    ),

    // A1-04
    LessonData(
      id: 'a1_grocery_shopping_basics',
      title: 'Grocery Shopping Basics',
      description: 'Buy fresh fruits, vegetables, and daily staples at the market.',
      level: 'A1',
      category: 'cooking',
      interest: 'cooking',
      difficulty: 1,
      iconKey: 'restaurant',
      mainObjective: 'Ask for food locations, prices, and pay at checkout.',
      scenarioContext: 'You work at a fresh grocery market. Assist the customer in finding items and checking out.',
      assistantRole: 'Grocery Clerk',
      userRole: 'Shopper',
      initialAssistantMessage: 'Hello! Welcome to Fresh Market. Let me know if you need help finding anything.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask where milk and apples are', keywords: ['ask', 'where', 'milk', 'apples'], examplePhrase: 'Ask where milk and apples are'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire price per kilo', keywords: ['inquire', 'price', 'per', 'kilo'], examplePhrase: 'Inquire price per kilo'),
        ScenarioGoalItem(id: 'g3', text: 'Request a shopping bag', keywords: ['request', 'shopping', 'bag'], examplePhrase: 'Request a shopping bag'),
        ScenarioGoalItem(id: 'g4', text: 'Pay at register', keywords: ['pay', 'register'], examplePhrase: 'Pay at register'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Where can I find the milk?', translation: 'Where can I find the milk?'),
        UsefulPhraseItem(id: 'p2', phrase: 'How much are the apples?', translation: 'How much are the apples?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Can I get a bag?', translation: 'Can I get a bag?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Here is my card.', translation: 'Here is my card.'),
      ],
    ),

    // A1-05
    LessonData(
      id: 'a1_taking_a_city_taxi',
      title: 'Taking a City Taxi',
      description: 'Tell the taxi driver your destination and discuss the fare.',
      level: 'A1',
      category: 'travel',
      interest: 'travel',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Communicate destination address and pay fare.',
      scenarioContext: 'You are a polite taxi driver picking up a passenger. Ask where they are going and give simple fare estimates.',
      assistantRole: 'Taxi Driver',
      userRole: 'Passenger',
      initialAssistantMessage: 'Hi there! Jump in. Where are we heading today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State destination address', keywords: ['state', 'destination', 'address'], examplePhrase: 'State destination address'),
        ScenarioGoalItem(id: 'g2', text: 'Ask estimated arrival time', keywords: ['ask', 'estimated', 'arrival', 'time'], examplePhrase: 'Ask estimated arrival time'),
        ScenarioGoalItem(id: 'g3', text: 'Ask how much the ride costs', keywords: ['ask', 'how', 'much', 'ride', 'costs'], examplePhrase: 'Ask how much the ride costs'),
        ScenarioGoalItem(id: 'g4', text: 'Pay driver and tip', keywords: ['pay', 'driver', 'tip'], examplePhrase: 'Pay driver and tip'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Please take me to the airport.', translation: 'Please take me to the airport.'),
        UsefulPhraseItem(id: 'p2', phrase: 'How long will it take?', translation: 'How long will it take?'),
        UsefulPhraseItem(id: 'p3', phrase: 'How much is the fare?', translation: 'How much is the fare?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Keep the change.', translation: 'Keep the change.'),
      ],
    ),

    // A1-06
    LessonData(
      id: 'a1_introducing_yourself_to_a_neighbor',
      title: 'Introducing Yourself to a Neighbor',
      description: 'Meet your new neighbor and exchange basic background info.',
      level: 'A1',
      category: 'daily',
      interest: 'daily',
      difficulty: 1,
      iconKey: 'school',
      mainObjective: 'Introduce yourself, origin country, and profession.',
      scenarioContext: 'You are a welcoming neighbor meeting someone who just moved in next door.',
      assistantRole: 'Neighbor',
      userRole: 'New Resident',
      initialAssistantMessage: 'Hi! I noticed you just moved in next door. I am Alex!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State your name and origin', keywords: ['state', 'name', 'origin'], examplePhrase: 'State your name and origin'),
        ScenarioGoalItem(id: 'g2', text: 'Mention your profession', keywords: ['mention', 'profession'], examplePhrase: 'Mention your profession'),
        ScenarioGoalItem(id: 'g3', text: 'Ask how long neighbor lived here', keywords: ['ask', 'how', 'long', 'neighbor', 'lived', 'here'], examplePhrase: 'Ask how long neighbor lived here'),
        ScenarioGoalItem(id: 'g4', text: 'Friendly closing', keywords: ['friendly', 'closing'], examplePhrase: 'Friendly closing'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Nice to meet you, I am...', translation: 'Nice to meet you, I am...'),
        UsefulPhraseItem(id: 'p2', phrase: 'I recently moved from...', translation: 'I recently moved from...'),
        UsefulPhraseItem(id: 'p3', phrase: 'I work as an engineer.', translation: 'I work as an engineer.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Have a great day!', translation: 'Have a great day!'),
      ],
    ),

    // A1-07
    LessonData(
      id: 'a1_ordering_pizza_for_pickup',
      title: 'Ordering Pizza for Pickup',
      description: 'Call a local pizzeria to order a customized pizza.',
      level: 'A1',
      category: 'cooking',
      interest: 'cooking',
      difficulty: 1,
      iconKey: 'restaurant',
      mainObjective: 'Select pizza size, crust, toppings, and pickup time.',
      scenarioContext: 'You take phone orders at Mario Pizzeria. Help customer pick size, crust, and toppings.',
      assistantRole: 'Pizzeria Cashier',
      userRole: 'Caller',
      initialAssistantMessage: 'Thanks for calling Mario Pizza! Is this order for pickup or delivery?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Choose pickup or delivery', keywords: ['choose', 'pickup', 'delivery'], examplePhrase: 'Choose pickup or delivery'),
        ScenarioGoalItem(id: 'g2', text: 'Select pizza size', keywords: ['select', 'pizza', 'size'], examplePhrase: 'Select pizza size'),
        ScenarioGoalItem(id: 'g3', text: 'Pick 2 toppings', keywords: ['pick', 'toppings'], examplePhrase: 'Pick 2 toppings'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm pickup time', keywords: ['confirm', 'pickup', 'time'], examplePhrase: 'Confirm pickup time'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I would like a large pizza.', translation: 'I would like a large pizza.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Thin crust, please.', translation: 'Thin crust, please.'),
        UsefulPhraseItem(id: 'p3', phrase: 'How long will pickup take?', translation: 'How long will pickup take?'),
        UsefulPhraseItem(id: 'p4', phrase: 'My phone number is...', translation: 'My phone number is...'),
      ],
    ),

    // A1-08
    LessonData(
      id: 'a1_buying_clothes_at_a_shop',
      title: 'Buying Clothes at a Shop',
      description: 'Try on clothes and ask for different sizes or colors.',
      level: 'A1',
      category: 'daily',
      interest: 'daily',
      difficulty: 1,
      iconKey: 'school',
      mainObjective: 'Ask for clothing size, fitting room, and price.',
      scenarioContext: 'You are a retail assistant at a clothing store helping a customer find their size.',
      assistantRole: 'Store Assistant',
      userRole: 'Shopper',
      initialAssistantMessage: 'Welcome! Looking for anything specific in our autumn collection today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask for shirt in Medium size', keywords: ['ask', 'shirt', 'medium', 'size'], examplePhrase: 'Ask for shirt in Medium size'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire about alternative colors', keywords: ['inquire', 'alternative', 'colors'], examplePhrase: 'Inquire about alternative colors'),
        ScenarioGoalItem(id: 'g3', text: 'Ask where fitting room is', keywords: ['ask', 'where', 'fitting', 'room'], examplePhrase: 'Ask where fitting room is'),
        ScenarioGoalItem(id: 'g4', text: 'Decide to purchase', keywords: ['decide', 'purchase'], examplePhrase: 'Decide to purchase'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Do you have this in Medium?', translation: 'Do you have this in Medium?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Does this come in blue?', translation: 'Does this come in blue?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Where are fitting rooms?', translation: 'Where are fitting rooms?'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will take this one.', translation: 'I will take this one.'),
      ],
    ),

    // A1-09
    LessonData(
      id: 'a1_talking_about_daily_routine',
      title: 'Talking About Daily Routine',
      description: 'Describe your typical daily schedule and simple habits.',
      level: 'A1',
      category: 'daily',
      interest: 'daily',
      difficulty: 1,
      iconKey: 'school',
      mainObjective: 'Share wake up time, meals, work transit, and bedtime.',
      scenarioContext: 'You are a friendly language tutor asking the student about their daily schedule.',
      assistantRole: 'Tutor',
      userRole: 'Student',
      initialAssistantMessage: 'Tell me about your typical day! What time do you usually wake up?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Mention wake up time', keywords: ['mention', 'wake', 'time'], examplePhrase: 'Mention wake up time'),
        ScenarioGoalItem(id: 'g2', text: 'Describe breakfast routine', keywords: ['describe', 'breakfast', 'routine'], examplePhrase: 'Describe breakfast routine'),
        ScenarioGoalItem(id: 'g3', text: 'Explain transit to work', keywords: ['explain', 'transit', 'work'], examplePhrase: 'Explain transit to work'),
        ScenarioGoalItem(id: 'g4', text: 'State sleep time', keywords: ['state', 'sleep', 'time'], examplePhrase: 'State sleep time'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I wake up at 7 AM.', translation: 'I wake up at 7 AM.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I drink coffee and eat toast.', translation: 'I drink coffee and eat toast.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I go to work by bus.', translation: 'I go to work by bus.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I go to bed at 10 PM.', translation: 'I go to bed at 10 PM.'),
      ],
    ),

    // A1-10
    LessonData(
      id: 'a1_discussing_weather_and_time',
      title: 'Discussing Weather and Time',
      description: 'Make casual small talk about current weather and times.',
      level: 'A1',
      category: 'science',
      interest: 'science',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Describe weather temperature and ask for current time.',
      scenarioContext: 'You are a coworker making casual elevator talk about today weather and schedules.',
      assistantRole: 'Colleague',
      userRole: 'Coworker',
      initialAssistantMessage: 'Good morning! Looks pretty cloudy and cold outside today, doesn me it?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Comment on weather', keywords: ['comment', 'weather'], examplePhrase: 'Comment on weather'),
        ScenarioGoalItem(id: 'g2', text: 'State temperature feeling', keywords: ['state', 'temperature', 'feeling'], examplePhrase: 'State temperature feeling'),
        ScenarioGoalItem(id: 'g3', text: 'Ask for current time', keywords: ['ask', 'current', 'time'], examplePhrase: 'Ask for current time'),
        ScenarioGoalItem(id: 'g4', text: 'Plan outdoor activity', keywords: ['plan', 'outdoor', 'activity'], examplePhrase: 'Plan outdoor activity'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'It is very warm today.', translation: 'It is very warm today.'),
        UsefulPhraseItem(id: 'p2', phrase: 'What time is it right now?', translation: 'What time is it right now?'),
        UsefulPhraseItem(id: 'p3', phrase: 'It looks like rain.', translation: 'It looks like rain.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us meet at 3 PM.', translation: 'Let us meet at 3 PM.'),
      ],
    ),

    // A1-11
    LessonData(
      id: 'a1_doctor_clinic_reception_check_in',
      title: 'Doctor Clinic Reception Check-In',
      description: 'Check in for a scheduled medical consultation.',
      level: 'A1',
      category: 'daily',
      interest: 'daily',
      difficulty: 1,
      iconKey: 'school',
      mainObjective: 'Provide name, appointment time, and ID card.',
      scenarioContext: 'You are a clinic receptionist checking in patients and verifying personal ID.',
      assistantRole: 'Medical Receptionist',
      userRole: 'Patient',
      initialAssistantMessage: 'Hello, welcome to City Health Clinic. How can I help you today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State appointment name and time', keywords: ['state', 'appointment', 'name', 'time'], examplePhrase: 'State appointment name and time'),
        ScenarioGoalItem(id: 'g2', text: 'Provide ID card', keywords: ['provide', 'card'], examplePhrase: 'Provide ID card'),
        ScenarioGoalItem(id: 'g3', text: 'Take seat in waiting area', keywords: ['take', 'seat', 'waiting', 'area'], examplePhrase: 'Take seat in waiting area'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm doctor name', keywords: ['confirm', 'doctor', 'name'], examplePhrase: 'Confirm doctor name'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have an appointment with Dr. Smith.', translation: 'I have an appointment with Dr. Smith.'),
        UsefulPhraseItem(id: 'p2', phrase: 'My name is John Doe.', translation: 'My name is John Doe.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Here is my ID card.', translation: 'Here is my ID card.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will wait here.', translation: 'I will wait here.'),
      ],
    ),

    // A1-12
    LessonData(
      id: 'a1_visiting_a_pet_shop',
      title: 'Visiting a Pet Shop',
      description: 'Ask about pets, food, and animal supplies.',
      level: 'A1',
      category: 'sports',
      interest: 'sports',
      difficulty: 1,
      iconKey: 'people',
      mainObjective: 'Inquire about pet food recommendations and prices.',
      scenarioContext: 'You run a pet shop. Help customer choose puppy food and toys.',
      assistantRole: 'Pet Shop Owner',
      userRole: 'Customer',
      initialAssistantMessage: 'Hello! Looking for pet food or thinking of adopting a pet today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State what pet you own', keywords: ['state', 'what', 'pet', 'own'], examplePhrase: 'State what pet you own'),
        ScenarioGoalItem(id: 'g2', text: 'Ask for food recommendation', keywords: ['ask', 'food', 'recommendation'], examplePhrase: 'Ask for food recommendation'),
        ScenarioGoalItem(id: 'g3', text: 'Inquire about toy prices', keywords: ['inquire', 'toy', 'prices'], examplePhrase: 'Inquire about toy prices'),
        ScenarioGoalItem(id: 'g4', text: 'Purchase item', keywords: ['purchase', 'item'], examplePhrase: 'Purchase item'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have a small puppy.', translation: 'I have a small puppy.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Which food is best?', translation: 'Which food is best?'),
        UsefulPhraseItem(id: 'p3', phrase: 'How much is this toy?', translation: 'How much is this toy?'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will take this bag.', translation: 'I will take this bag.'),
      ],
    ),

    // A1-13
    LessonData(
      id: 'a1_talking_about_hobbies',
      title: 'Talking About Hobbies',
      description: 'Share your favorite leisure activities and weekend fun.',
      level: 'A1',
      category: 'art',
      interest: 'art',
      difficulty: 1,
      iconKey: 'devices',
      mainObjective: 'List 2-3 hobbies and state frequency.',
      scenarioContext: 'You are chatting with a friend about free time activities and weekend hobbies.',
      assistantRole: 'Friend',
      userRole: 'Friend',
      initialAssistantMessage: 'Hey! What do you like to do on weekends when you have free time?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Mention main hobbies', keywords: ['mention', 'main', 'hobbies'], examplePhrase: 'Mention main hobbies'),
        ScenarioGoalItem(id: 'g2', text: 'State frequency', keywords: ['state', 'frequency'], examplePhrase: 'State frequency'),
        ScenarioGoalItem(id: 'g3', text: 'Ask about their hobbies', keywords: ['ask', 'their', 'hobbies'], examplePhrase: 'Ask about their hobbies'),
        ScenarioGoalItem(id: 'g4', text: 'Invite for shared activity', keywords: ['invite', 'shared', 'activity'], examplePhrase: 'Invite for shared activity'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I like reading and soccer.', translation: 'I like reading and soccer.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I play music on weekends.', translation: 'I play music on weekends.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Do you enjoy cooking?', translation: 'Do you enjoy cooking?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us play together!', translation: 'Let us play together!'),
      ],
    ),

    // A1-14
    LessonData(
      id: 'a1_birthday_party_wish_gift',
      title: 'Birthday Party Wish & Gift',
      description: 'Congratulate a friend on their birthday and hand over a present.',
      level: 'A1',
      category: 'music',
      interest: 'music',
      difficulty: 1,
      iconKey: 'devices',
      mainObjective: 'Express birthday wishes and ask about party plans.',
      scenarioContext: 'You are celebrating your birthday with friends at a small gathering.',
      assistantRole: 'Birthday Host',
      userRole: 'Friend',
      initialAssistantMessage: 'Hey! Thanks for coming to my birthday celebration today!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Wish Happy Birthday', keywords: ['wish', 'happy', 'birthday'], examplePhrase: 'Wish Happy Birthday'),
        ScenarioGoalItem(id: 'g2', text: 'Hand over gift', keywords: ['hand', 'over', 'gift'], examplePhrase: 'Hand over gift'),
        ScenarioGoalItem(id: 'g3', text: 'Ask about party plans', keywords: ['ask', 'party', 'plans'], examplePhrase: 'Ask about party plans'),
        ScenarioGoalItem(id: 'g4', text: 'Enjoy cake', keywords: ['enjoy', 'cake'], examplePhrase: 'Enjoy cake'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Happy Birthday to you!', translation: 'Happy Birthday to you!'),
        UsefulPhraseItem(id: 'p2', phrase: 'I brought a small gift.', translation: 'I brought a small gift.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Are you having a party?', translation: 'Are you having a party?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Enjoy your special day!', translation: 'Enjoy your special day!'),
      ],
    ),

    // A1-15
    LessonData(
      id: 'a1_buying_bus_tickets',
      title: 'Buying Bus Tickets',
      description: 'Purchase city or interstate bus tickets at terminal.',
      level: 'A1',
      category: 'travel',
      interest: 'travel',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Specify destination, ticket type (one-way), and pay.',
      scenarioContext: 'You work at the bus ticket counter. Assist traveler with destinations and fare.',
      assistantRole: 'Ticket Clerk',
      userRole: 'Traveler',
      initialAssistantMessage: 'Next in line please! Where are you traveling to today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Specify destination city', keywords: ['specify', 'destination', 'city'], examplePhrase: 'Specify destination city'),
        ScenarioGoalItem(id: 'g2', text: 'Choose single or return ticket', keywords: ['choose', 'single', 'return', 'ticket'], examplePhrase: 'Choose single or return ticket'),
        ScenarioGoalItem(id: 'g3', text: 'Select departure time', keywords: ['select', 'departure', 'time'], examplePhrase: 'Select departure time'),
        ScenarioGoalItem(id: 'g4', text: 'Pay for ticket', keywords: ['pay', 'ticket'], examplePhrase: 'Pay for ticket'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'One ticket to Boston, please.', translation: 'One ticket to Boston, please.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Is it a direct bus?', translation: 'Is it a direct bus?'),
        UsefulPhraseItem(id: 'p3', phrase: 'One-way ticket, please.', translation: 'One-way ticket, please.'),
        UsefulPhraseItem(id: 'p4', phrase: 'What gate departs?', translation: 'What gate departs?'),
      ],
    ),

    // A1-16
    LessonData(
      id: 'a1_renting_a_city_bike',
      title: 'Renting a City Bike',
      description: 'Rent a bicycle for a day at a rental shop.',
      level: 'A1',
      category: 'sports',
      interest: 'sports',
      difficulty: 1,
      iconKey: 'people',
      mainObjective: 'Inquire about hourly rates, helmet rental, and deposit.',
      scenarioContext: 'You rent out bicycles to city tourists. Explain rates and helmet safety.',
      assistantRole: 'Bike Shop Staff',
      userRole: 'Tourist',
      initialAssistantMessage: 'Hello! Ready to explore the city on two wheels today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask hourly rental rate', keywords: ['ask', 'hourly', 'rental', 'rate'], examplePhrase: 'Ask hourly rental rate'),
        ScenarioGoalItem(id: 'g2', text: 'Request helmet and lock', keywords: ['request', 'helmet', 'lock'], examplePhrase: 'Request helmet and lock'),
        ScenarioGoalItem(id: 'g3', text: 'Confirm return time', keywords: ['confirm', 'return', 'time'], examplePhrase: 'Confirm return time'),
        ScenarioGoalItem(id: 'g4', text: 'Pay deposit', keywords: ['pay', 'deposit'], examplePhrase: 'Pay deposit'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'How much per hour?', translation: 'How much per hour?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Does it include a helmet?', translation: 'Does it include a helmet?'),
        UsefulPhraseItem(id: 'p3', phrase: 'What time do you close?', translation: 'What time do you close?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Here is my deposit.', translation: 'Here is my deposit.'),
      ],
    ),

    // A1-17
    LessonData(
      id: 'a1_asking_for_pharmacy_help',
      title: 'Asking for Pharmacy Help',
      description: 'Describe mild symptoms to a pharmacist for over-the-counter medicine.',
      level: 'A1',
      category: 'science',
      interest: 'science',
      difficulty: 1,
      iconKey: 'explore',
      mainObjective: 'Explain symptom (headache) and ask dosage instructions.',
      scenarioContext: 'You are a pharmacist advising a customer with a mild headache or cough.',
      assistantRole: 'Pharmacist',
      userRole: 'Customer',
      initialAssistantMessage: 'Good afternoon! How can I assist you at the pharmacy today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe symptom clearly', keywords: ['describe', 'symptom', 'clearly'], examplePhrase: 'Describe symptom clearly'),
        ScenarioGoalItem(id: 'g2', text: 'Ask how to take medicine', keywords: ['ask', 'how', 'take', 'medicine'], examplePhrase: 'Ask how to take medicine'),
        ScenarioGoalItem(id: 'g3', text: 'Ask about side effects', keywords: ['ask', 'side', 'effects'], examplePhrase: 'Ask about side effects'),
        ScenarioGoalItem(id: 'g4', text: 'Purchase medication', keywords: ['purchase', 'medication'], examplePhrase: 'Purchase medication'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have a bad headache.', translation: 'I have a bad headache.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Do you have pain medicine?', translation: 'Do you have pain medicine?'),
        UsefulPhraseItem(id: 'p3', phrase: 'How many times a day?', translation: 'How many times a day?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you so much.', translation: 'Thank you so much.'),
      ],
    ),

    // A1-18
    LessonData(
      id: 'a1_smartphone_basics_setup',
      title: 'Smartphone Basics Setup',
      description: 'Ask a store associate how to connect your phone to Wi-Fi.',
      level: 'A1',
      category: 'technology',
      interest: 'technology',
      difficulty: 1,
      iconKey: 'devices',
      mainObjective: 'Ask for Wi-Fi connection steps and app installation.',
      scenarioContext: 'You work at a mobile phone store helping a customer configure simple phone settings.',
      assistantRole: 'Tech Associate',
      userRole: 'Customer',
      initialAssistantMessage: 'Hello! Need help setting up your new smartphone today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask how to connect to Wi-Fi', keywords: ['ask', 'how', 'connect'], examplePhrase: 'Ask how to connect to Wi-Fi'),
        ScenarioGoalItem(id: 'g2', text: 'Ask where app store is', keywords: ['ask', 'where', 'app', 'store'], examplePhrase: 'Ask where app store is'),
        ScenarioGoalItem(id: 'g3', text: 'Inquire about battery life', keywords: ['inquire', 'battery', 'life'], examplePhrase: 'Inquire about battery life'),
        ScenarioGoalItem(id: 'g4', text: 'Thank associate', keywords: ['thank', 'associate'], examplePhrase: 'Thank associate'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'How do I connect Wi-Fi?', translation: 'How do I connect Wi-Fi?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Where is the camera app?', translation: 'Where is the camera app?'),
        UsefulPhraseItem(id: 'p3', phrase: 'How do I turn it off?', translation: 'How do I turn it off?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you for helping.', translation: 'Thank you for helping.'),
      ],
    ),

    // A1-19
    LessonData(
      id: 'a1_showing_family_photo_album',
      title: 'Showing Family Photo Album',
      description: 'Describe family members shown in a photo album.',
      level: 'A1',
      category: 'history',
      interest: 'history',
      difficulty: 1,
      iconKey: 'school',
      mainObjective: 'Name family relationships (father, mother, brother) and ages.',
      scenarioContext: 'You are looking at a friend family album and asking who each person is.',
      assistantRole: 'Friend',
      userRole: 'Friend',
      initialAssistantMessage: 'Oh, is that a picture of your family? Who is this standing here?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Identify family member', keywords: ['identify', 'family', 'member'], examplePhrase: 'Identify family member'),
        ScenarioGoalItem(id: 'g2', text: 'State their profession/age', keywords: ['state', 'their', 'profession', 'age'], examplePhrase: 'State their profession/age'),
        ScenarioGoalItem(id: 'g3', text: 'Describe family pet', keywords: ['describe', 'family', 'pet'], examplePhrase: 'Describe family pet'),
        ScenarioGoalItem(id: 'g4', text: 'Ask about friend family', keywords: ['ask', 'friend', 'family'], examplePhrase: 'Ask about friend family'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'This is my brother.', translation: 'This is my brother.'),
        UsefulPhraseItem(id: 'p2', phrase: 'She works as a teacher.', translation: 'She works as a teacher.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We are four in my family.', translation: 'We are four in my family.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Do you have siblings?', translation: 'Do you have siblings?'),
      ],
    ),

    // A1-20
    LessonData(
      id: 'a1_ordering_bakery_breakfast',
      title: 'Ordering Bakery Breakfast',
      description: 'Buy fresh bread, croissants, and juice for breakfast.',
      level: 'A1',
      category: 'cooking',
      interest: 'cooking',
      difficulty: 1,
      iconKey: 'restaurant',
      mainObjective: 'Request bakery items, quantity, and pay.',
      scenarioContext: 'You are a baker selling fresh morning pastries and orange juice.',
      assistantRole: 'Baker',
      userRole: 'Customer',
      initialAssistantMessage: 'Good morning! Everything is fresh out of the oven. What would you like?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Order 2 croissants', keywords: ['order', 'croissants'], examplePhrase: 'Order 2 croissants'),
        ScenarioGoalItem(id: 'g2', text: 'Ask for fresh orange juice', keywords: ['ask', 'fresh', 'orange', 'juice'], examplePhrase: 'Ask for fresh orange juice'),
        ScenarioGoalItem(id: 'g3', text: 'Confirm bread freshness', keywords: ['confirm', 'bread', 'freshness'], examplePhrase: 'Confirm bread freshness'),
        ScenarioGoalItem(id: 'g4', text: 'Pay total', keywords: ['pay', 'total'], examplePhrase: 'Pay total'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Two croissants, please.', translation: 'Two croissants, please.'),
        UsefulPhraseItem(id: 'p2', phrase: 'A glass of orange juice.', translation: 'A glass of orange juice.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Is the bread fresh?', translation: 'Is the bread fresh?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Keep the change!', translation: 'Keep the change!'),
      ],
    ),


    // =========================================================================
    // NIVEL A2 — A2 — Elemental (20 lecciones)
    // =========================================================================

    // A2-01
    LessonData(
      id: 'a2_handling_restaurant_order_issue',
      title: 'Handling Restaurant Order Issue',
      description: 'Respectfully address an incorrect meal order with waiter.',
      level: 'A2',
      category: 'cooking',
      interest: 'cooking',
      difficulty: 2,
      iconKey: 'restaurant',
      mainObjective: 'Explain incorrect dish item and request replacement.',
      scenarioContext: 'You are a waiter at a casual restaurant. Address a diner who received the wrong steak temperature.',
      assistantRole: 'Waiter',
      userRole: 'Diner',
      initialAssistantMessage: 'Excuse me, is everything tasting alright with your steak and salad?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Politely mention wrong order', keywords: ['politely', 'mention', 'wrong', 'order'], examplePhrase: 'Politely mention wrong order'),
        ScenarioGoalItem(id: 'g2', text: 'Explain requested temperature', keywords: ['explain', 'requested', 'temperature'], examplePhrase: 'Explain requested temperature'),
        ScenarioGoalItem(id: 'g3', text: 'Request replacement dish', keywords: ['request', 'replacement', 'dish'], examplePhrase: 'Request replacement dish'),
        ScenarioGoalItem(id: 'g4', text: 'Thank waiter', keywords: ['thank', 'waiter'], examplePhrase: 'Thank waiter'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Excuse me, I ordered medium-rare.', translation: 'Excuse me, I ordered medium-rare.'),
        UsefulPhraseItem(id: 'p2', phrase: 'This dish is cold.', translation: 'This dish is cold.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Could you replace this?', translation: 'Could you replace this?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you for fixing it.', translation: 'Thank you for fixing it.'),
      ],
    ),

    // A2-02
    LessonData(
      id: 'a2_returning_a_purchased_clothing_item',
      title: 'Returning a Purchased Clothing Item',
      description: 'Return or exchange a defective clothing item at a store.',
      level: 'A2',
      category: 'business',
      interest: 'business',
      difficulty: 2,
      iconKey: 'work',
      mainObjective: 'State reason for return, show receipt, request refund.',
      scenarioContext: 'You work at customer service desk. Help customer return a defective sweater with receipt.',
      assistantRole: 'Customer Service Clerk',
      userRole: 'Customer',
      initialAssistantMessage: 'Hello! Welcome to Customer Service. How can I assist you today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Present receipt and item', keywords: ['present', 'receipt', 'item'], examplePhrase: 'Present receipt and item'),
        ScenarioGoalItem(id: 'g2', text: 'Explain defect reason', keywords: ['explain', 'defect', 'reason'], examplePhrase: 'Explain defect reason'),
        ScenarioGoalItem(id: 'g3', text: 'Choose refund or credit', keywords: ['choose', 'refund', 'credit'], examplePhrase: 'Choose refund or credit'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm transaction', keywords: ['confirm', 'transaction'], examplePhrase: 'Confirm transaction'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I would like to return this.', translation: 'I would like to return this.'),
        UsefulPhraseItem(id: 'p2', phrase: 'It has a small tear.', translation: 'It has a small tear.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Here is my receipt.', translation: 'Here is my receipt.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Can I get store credit?', translation: 'Can I get store credit?'),
      ],
    ),

    // A2-03
    LessonData(
      id: 'a2_booking_a_guided_city_tour',
      title: 'Booking a Guided City Tour',
      description: 'Inquire about city sightseeing schedules, prices, and spots.',
      level: 'A2',
      category: 'travel',
      interest: 'travel',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Compare tour packages, departure times, and book tickets.',
      scenarioContext: 'You sell tour tickets for City Sightseeing. Explain bus vs walking tour packages.',
      assistantRole: 'Tour Agent',
      userRole: 'Tourist',
      initialAssistantMessage: 'Welcome to City Sightseeing! Are you interested in our historic walking tour or bus tour?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask walking vs bus tour', keywords: ['ask', 'walking', 'bus', 'tour'], examplePhrase: 'Ask walking vs bus tour'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire tour duration', keywords: ['inquire', 'tour', 'duration'], examplePhrase: 'Inquire tour duration'),
        ScenarioGoalItem(id: 'g3', text: 'Ask if audio guide included', keywords: ['ask', 'audio', 'guide', 'included'], examplePhrase: 'Ask if audio guide included'),
        ScenarioGoalItem(id: 'g4', text: 'Book 2 tickets', keywords: ['book', 'tickets'], examplePhrase: 'Book 2 tickets'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'What time does bus tour start?', translation: 'What time does bus tour start?'),
        UsefulPhraseItem(id: 'p2', phrase: 'How long is walking tour?', translation: 'How long is walking tour?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Are museum tickets included?', translation: 'Are museum tickets included?'),
        UsefulPhraseItem(id: 'p4', phrase: 'I would like two tickets.', translation: 'I would like two tickets.'),
      ],
    ),

    // A2-04
    LessonData(
      id: 'a2_asking_advice_for_a_mild_cold',
      title: 'Asking Advice for a Mild Cold',
      description: 'Seek advice from a friend on traditional remedies for cold.',
      level: 'A2',
      category: 'science',
      interest: 'science',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Describe cold symptoms and evaluate recommended remedies.',
      scenarioContext: 'You are a caring friend giving herbal tea remedies advice for a mild sore throat.',
      assistantRole: 'Friend',
      userRole: 'Sick Friend',
      initialAssistantMessage: 'Oh no! You sound terrible today. Are you feeling under the weather?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe cold symptoms', keywords: ['describe', 'cold', 'symptoms'], examplePhrase: 'Describe cold symptoms'),
        ScenarioGoalItem(id: 'g2', text: 'Ask herbal tea recommendations', keywords: ['ask', 'herbal', 'tea', 'recommendations'], examplePhrase: 'Ask herbal tea recommendations'),
        ScenarioGoalItem(id: 'g3', text: 'Thank friend for advice', keywords: ['thank', 'friend', 'advice'], examplePhrase: 'Thank friend for advice'),
        ScenarioGoalItem(id: 'g4', text: 'Plan rest', keywords: ['plan', 'rest'], examplePhrase: 'Plan rest'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I have a sore throat.', translation: 'I have a sore throat.'),
        UsefulPhraseItem(id: 'p2', phrase: 'What tea do you recommend?', translation: 'What tea do you recommend?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Should I rest today?', translation: 'Should I rest today?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thanks for checking on me!', translation: 'Thanks for checking on me!'),
      ],
    ),

    // A2-05
    LessonData(
      id: 'a2_handling_train_delays_at_station',
      title: 'Handling Train Delays at Station',
      description: 'Inquire about delayed train schedules and alternative routes.',
      level: 'A2',
      category: 'travel',
      interest: 'travel',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Ask delay cause, revised departure platform, and connection.',
      scenarioContext: 'You are a train station agent assisting passengers affected by a 45-minute delay.',
      assistantRole: 'Station Agent',
      userRole: 'Passenger',
      initialAssistantMessage: 'Attention passengers: Train 402 is delayed by 45 minutes due to maintenance.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask cause of train delay', keywords: ['ask', 'cause', 'train', 'delay'], examplePhrase: 'Ask cause of train delay'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire if connection missed', keywords: ['inquire', 'connection', 'missed'], examplePhrase: 'Inquire if connection missed'),
        ScenarioGoalItem(id: 'g3', text: 'Ask platform number', keywords: ['ask', 'platform', 'number'], examplePhrase: 'Ask platform number'),
        ScenarioGoalItem(id: 'g4', text: 'Request ticket change', keywords: ['request', 'ticket', 'change'], examplePhrase: 'Request ticket change'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Why is the train delayed?', translation: 'Why is the train delayed?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Will I miss my connection?', translation: 'Will I miss my connection?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Which platform does it leave?', translation: 'Which platform does it leave?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Can I switch trains?', translation: 'Can I switch trains?'),
      ],
    ),

    // A2-06
    LessonData(
      id: 'a2_opening_a_bank_checking_account',
      title: 'Opening a Bank Checking Account',
      description: 'Set up a basic checking account with a bank teller.',
      level: 'A2',
      category: 'business',
      interest: 'business',
      difficulty: 2,
      iconKey: 'work',
      mainObjective: 'Provide documentation, select account type, ask about fees.',
      scenarioContext: 'You are a bank teller guiding a customer through opening a checking account.',
      assistantRole: 'Bank Teller',
      userRole: 'Customer',
      initialAssistantMessage: 'Good day! Welcome to First National Bank. How can I help you open an account?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Request checking account', keywords: ['request', 'checking', 'account'], examplePhrase: 'Request checking account'),
        ScenarioGoalItem(id: 'g2', text: 'Provide passport/address proof', keywords: ['provide', 'passport', 'address', 'proof'], examplePhrase: 'Provide passport/address proof'),
        ScenarioGoalItem(id: 'g3', text: 'Ask monthly maintenance fees', keywords: ['ask', 'monthly', 'maintenance', 'fees'], examplePhrase: 'Ask monthly maintenance fees'),
        ScenarioGoalItem(id: 'g4', text: 'Request debit card', keywords: ['request', 'debit', 'card'], examplePhrase: 'Request debit card'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I want to open a checking account.', translation: 'I want to open a checking account.'),
        UsefulPhraseItem(id: 'p2', phrase: 'What documents do you need?', translation: 'What documents do you need?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Are there monthly fees?', translation: 'Are there monthly fees?'),
        UsefulPhraseItem(id: 'p4', phrase: 'When will card arrive?', translation: 'When will card arrive?'),
      ],
    ),

    // A2-07
    LessonData(
      id: 'a2_signing_up_for_gym_membership',
      title: 'Signing Up for Gym Membership',
      description: 'Inquire about monthly plans, equipment, and personal trainer.',
      level: 'A2',
      category: 'sports',
      interest: 'sports',
      difficulty: 2,
      iconKey: 'people',
      mainObjective: 'Compare membership tiers, gym hours, and trial pass.',
      scenarioContext: 'You are a gym representative showing membership plans and facilities to a guest.',
      assistantRole: 'Gym Sales Agent',
      userRole: 'Prospective Member',
      initialAssistantMessage: 'Hey there! Ready to smash your fitness goals with us at PowerGym?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask monthly vs annual fee', keywords: ['ask', 'monthly', 'annual', 'fee'], examplePhrase: 'Ask monthly vs annual fee'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire pool/sauna access', keywords: ['inquire', 'pool', 'sauna', 'access'], examplePhrase: 'Inquire pool/sauna access'),
        ScenarioGoalItem(id: 'g3', text: 'Ask for free trial pass', keywords: ['ask', 'free', 'trial', 'pass'], examplePhrase: 'Ask for free trial pass'),
        ScenarioGoalItem(id: 'g4', text: 'Complete sign up', keywords: ['complete', 'sign'], examplePhrase: 'Complete sign up'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'How much is monthly fee?', translation: 'How much is monthly fee?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Is personal training included?', translation: 'Is personal training included?'),
        UsefulPhraseItem(id: 'p3', phrase: 'What are opening hours?', translation: 'What are opening hours?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Can I try free pass today?', translation: 'Can I try free pass today?'),
      ],
    ),

    // A2-08
    LessonData(
      id: 'a2_renting_a_compact_car',
      title: 'Renting a Compact Car',
      description: 'Rent a vehicle at an airport rental counter.',
      level: 'A2',
      category: 'travel',
      interest: 'travel',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Select car class, add full insurance, check fuel policy.',
      scenarioContext: 'You are a car rental agent processing driver license and insurance selection.',
      assistantRole: 'Rental Car Agent',
      userRole: 'Driver',
      initialAssistantMessage: 'Welcome to DriveFast Rental! Do you have a reservation confirmation code?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Present driver license', keywords: ['present', 'driver', 'license'], examplePhrase: 'Present driver license'),
        ScenarioGoalItem(id: 'g2', text: 'Select compact vehicle', keywords: ['select', 'compact', 'vehicle'], examplePhrase: 'Select compact vehicle'),
        ScenarioGoalItem(id: 'g3', text: 'Choose full insurance option', keywords: ['choose', 'full', 'insurance', 'option'], examplePhrase: 'Choose full insurance option'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm return fuel policy', keywords: ['confirm', 'return', 'fuel', 'policy'], examplePhrase: 'Confirm return fuel policy'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Here is my license.', translation: 'Here is my license.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I want full insurance coverage.', translation: 'I want full insurance coverage.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Is gas tank full?', translation: 'Is gas tank full?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Where do I pick up keys?', translation: 'Where do I pick up keys?'),
      ],
    ),

    // A2-09
    LessonData(
      id: 'a2_doctor_consultation_for_sprained_ankle',
      title: 'Doctor Consultation for Sprained Ankle',
      description: 'Describe a minor physical injury to a physician.',
      level: 'A2',
      category: 'science',
      interest: 'science',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Explain how injury occurred, pain level, and ask about X-ray.',
      scenarioContext: 'You are a physician examining a patient who twisted their ankle playing sports.',
      assistantRole: 'Physician',
      userRole: 'Patient',
      initialAssistantMessage: 'Hello! Come on in. What seems to be bothering your ankle today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Explain how injury happened', keywords: ['explain', 'how', 'injury', 'happened'], examplePhrase: 'Explain how injury happened'),
        ScenarioGoalItem(id: 'g2', text: 'Rate pain scale 1-10', keywords: ['rate', 'pain', 'scale'], examplePhrase: 'Rate pain scale 1-10'),
        ScenarioGoalItem(id: 'g3', text: 'Ask if X-ray needed', keywords: ['ask', 'ray', 'needed'], examplePhrase: 'Ask if X-ray needed'),
        ScenarioGoalItem(id: 'g4', text: 'Understand doctor rest advice', keywords: ['understand', 'doctor', 'rest', 'advice'], examplePhrase: 'Understand doctor rest advice'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I twisted my ankle playing tennis.', translation: 'I twisted my ankle playing tennis.'),
        UsefulPhraseItem(id: 'p2', phrase: 'It hurts when I walk.', translation: 'It hurts when I walk.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Do I need an X-ray?', translation: 'Do I need an X-ray?'),
        UsefulPhraseItem(id: 'p4', phrase: 'How many days should I rest?', translation: 'How many days should I rest?'),
      ],
    ),

    // A2-10
    LessonData(
      id: 'a2_setting_roommate_house_rules',
      title: 'Setting Roommate House Rules',
      description: 'Discuss cleaning schedules, quiet hours, and shared bills.',
      level: 'A2',
      category: 'daily',
      interest: 'daily',
      difficulty: 2,
      iconKey: 'school',
      mainObjective: 'Propose fair division of household chores and quiet hours.',
      scenarioContext: 'You are a roommate discussing cleaning rotation and quiet hours for a new flat.',
      assistantRole: 'Roommate',
      userRole: 'Roommate',
      initialAssistantMessage: 'Hey! Now that we moved in together, let us agree on some basic ground rules.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Propose cleaning rotation', keywords: ['propose', 'cleaning', 'rotation'], examplePhrase: 'Propose cleaning rotation'),
        ScenarioGoalItem(id: 'g2', text: 'Agree quiet hours for sleep', keywords: ['agree', 'quiet', 'hours', 'sleep'], examplePhrase: 'Agree quiet hours for sleep'),
        ScenarioGoalItem(id: 'g3', text: 'Discuss utility bills split', keywords: ['discuss', 'utility', 'bills', 'split'], examplePhrase: 'Discuss utility bills split'),
        ScenarioGoalItem(id: 'g4', text: 'Establish guest policy', keywords: ['establish', 'guest', 'policy'], examplePhrase: 'Establish guest policy'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Let us alternate cleaning kitchen.', translation: 'Let us alternate cleaning kitchen.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Quiet hours after 10 PM sound good?', translation: 'Quiet hours after 10 PM sound good?'),
        UsefulPhraseItem(id: 'p3', phrase: 'We can split utility bills 50/50.', translation: 'We can split utility bills 50/50.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Sounds fair to me!', translation: 'Sounds fair to me!'),
      ],
    ),

    // A2-11
    LessonData(
      id: 'a2_describing_your_job_responsibilities',
      title: 'Describing Your Job Responsibilities',
      description: 'Explain your role, daily tasks, and tools to a new colleague.',
      level: 'A2',
      category: 'business',
      interest: 'business',
      difficulty: 2,
      iconKey: 'work',
      mainObjective: 'List main responsibilities, software used, and goals.',
      scenarioContext: 'You are a new employee asking a colleague about their job duties and daily tools.',
      assistantRole: 'New Colleague',
      userRole: 'Employee',
      initialAssistantMessage: 'Hi! I just joined the marketing department. Could you tell me what you do here?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State job title', keywords: ['state', 'job', 'title'], examplePhrase: 'State job title'),
        ScenarioGoalItem(id: 'g2', text: 'Describe daily responsibilities', keywords: ['describe', 'daily', 'responsibilities'], examplePhrase: 'Describe daily responsibilities'),
        ScenarioGoalItem(id: 'g3', text: 'Mention software tools used', keywords: ['mention', 'software', 'tools', 'used'], examplePhrase: 'Mention software tools used'),
        ScenarioGoalItem(id: 'g4', text: 'Offer help onboarding', keywords: ['offer', 'help', 'onboarding'], examplePhrase: 'Offer help onboarding'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I am a digital marketing specialist.', translation: 'I am a digital marketing specialist.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I manage social media campaigns.', translation: 'I manage social media campaigns.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I use Analytics and Figma.', translation: 'I use Analytics and Figma.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let me know if you need help!', translation: 'Let me know if you need help!'),
      ],
    ),

    // A2-12
    LessonData(
      id: 'a2_shopping_for_a_birthday_gift',
      title: 'Shopping for a Birthday Gift',
      description: 'Ask store staff for recommendations for a friend gift.',
      level: 'A2',
      category: 'art',
      interest: 'art',
      difficulty: 2,
      iconKey: 'devices',
      mainObjective: 'Specify friend interests, budget limit, and gift wrapping.',
      scenarioContext: 'You work at a gift shop recommending items based on budget and hobbies.',
      assistantRole: 'Gift Specialist',
      userRole: 'Shopper',
      initialAssistantMessage: 'Hello! Looking for a special gift for a birthday or anniversary today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State recipient interests', keywords: ['state', 'recipient', 'interests'], examplePhrase: 'State recipient interests'),
        ScenarioGoalItem(id: 'g2', text: 'Set budget limit', keywords: ['set', 'budget', 'limit'], examplePhrase: 'Set budget limit'),
        ScenarioGoalItem(id: 'g3', text: 'Ask item recommendations', keywords: ['ask', 'item', 'recommendations'], examplePhrase: 'Ask item recommendations'),
        ScenarioGoalItem(id: 'g4', text: 'Request gift wrap', keywords: ['request', 'gift', 'wrap'], examplePhrase: 'Request gift wrap'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I am looking for a gift for my sister.', translation: 'I am looking for a gift for my sister.'),
        UsefulPhraseItem(id: 'p2', phrase: 'She loves photography.', translation: 'She loves photography.'),
        UsefulPhraseItem(id: 'p3', phrase: 'My budget is around \$50.', translation: 'My budget is around \$50.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Could you gift-wrap it?', translation: 'Could you gift-wrap it?'),
      ],
    ),

    // A2-13
    LessonData(
      id: 'a2_explaining_a_simple_recipe',
      title: 'Explaining a Simple Recipe',
      description: 'Explain steps to prepare a simple regional dish to a friend.',
      level: 'A2',
      category: 'cooking',
      interest: 'cooking',
      difficulty: 2,
      iconKey: 'restaurant',
      mainObjective: 'List main ingredients, cooking tools, and step order.',
      scenarioContext: 'You are a friend asking for step-by-step cooking instructions for pasta sauce.',
      assistantRole: 'Friend',
      userRole: 'Home Cook',
      initialAssistantMessage: 'Mmm! This pasta dish smells amazing! How do you prepare it?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'List main ingredients', keywords: ['list', 'main', 'ingredients'], examplePhrase: 'List main ingredients'),
        ScenarioGoalItem(id: 'g2', text: 'Explain preparation steps', keywords: ['explain', 'preparation', 'steps'], examplePhrase: 'Explain preparation steps'),
        ScenarioGoalItem(id: 'g3', text: 'Mention cooking time/heat', keywords: ['mention', 'cooking', 'time', 'heat'], examplePhrase: 'Mention cooking time/heat'),
        ScenarioGoalItem(id: 'g4', text: 'Offer flavor tips', keywords: ['offer', 'flavor', 'tips'], examplePhrase: 'Offer flavor tips'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'First, chop garlic and onions.', translation: 'First, chop garlic and onions.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Boil pasta in salted water.', translation: 'Boil pasta in salted water.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Simmer sauce for 15 minutes.', translation: 'Simmer sauce for 15 minutes.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Top with fresh parmesan cheese!', translation: 'Top with fresh parmesan cheese!'),
      ],
    ),

    // A2-14
    LessonData(
      id: 'a2_planning_a_weekend_trip',
      title: 'Planning a Weekend Trip',
      description: 'Discuss weekend getaway destinations, transport, and lodging.',
      level: 'A2',
      category: 'travel',
      interest: 'travel',
      difficulty: 2,
      iconKey: 'explore',
      mainObjective: 'Propose location ideas, compare train vs car, agree on lodging.',
      scenarioContext: 'You are planning a weekend mountain road trip with a travel partner.',
      assistantRole: 'Travel Partner',
      userRole: 'Traveler',
      initialAssistantMessage: 'Hey! Next weekend is a long weekend. Want to take a short trip somewhere?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Suggest destination ideas', keywords: ['suggest', 'destination', 'ideas'], examplePhrase: 'Suggest destination ideas'),
        ScenarioGoalItem(id: 'g2', text: 'Compare train vs car rental', keywords: ['compare', 'train', 'car', 'rental'], examplePhrase: 'Compare train vs car rental'),
        ScenarioGoalItem(id: 'g3', text: 'Propose budget hotel/cabin', keywords: ['propose', 'budget', 'hotel', 'cabin'], examplePhrase: 'Propose budget hotel/cabin'),
        ScenarioGoalItem(id: 'g4', text: 'Set departure time', keywords: ['set', 'departure', 'time'], examplePhrase: 'Set departure time'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'How about driving to the lake?', translation: 'How about driving to the lake?'),
        UsefulPhraseItem(id: 'p2', phrase: 'The train takes only two hours.', translation: 'The train takes only two hours.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We can book a cozy cabin.', translation: 'We can book a cozy cabin.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us leave Friday evening!', translation: 'Let us leave Friday evening!'),
      ],
    ),

    // A2-15
    LessonData(
      id: 'a2_historic_neighborhood_tour',
      title: 'Historic Neighborhood Tour',
      description: 'Explore a historic district with a local resident guide.',
      level: 'A2',
      category: 'history',
      interest: 'history',
      difficulty: 2,
      iconKey: 'school',
      mainObjective: 'Ask about historic significance, local dining, and safety.',
      scenarioContext: 'You are a local tour guide showing visitors around 19th-century architecture.',
      assistantRole: 'Local Guide',
      userRole: 'Visitor',
      initialAssistantMessage: 'Welcome to Old Town Plaza! This cathedral was constructed back in 1850.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask historic significance', keywords: ['ask', 'historic', 'significance'], examplePhrase: 'Ask historic significance'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire best local restaurants', keywords: ['inquire', 'best', 'local', 'restaurants'], examplePhrase: 'Inquire best local restaurants'),
        ScenarioGoalItem(id: 'g3', text: 'Ask where to take photos', keywords: ['ask', 'where', 'take', 'photos'], examplePhrase: 'Ask where to take photos'),
        ScenarioGoalItem(id: 'g4', text: 'Thank guide', keywords: ['thank', 'guide'], examplePhrase: 'Thank guide'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'How old is this cathedral?', translation: 'How old is this cathedral?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Where do locals eat around here?', translation: 'Where do locals eat around here?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Is it safe to walk at night?', translation: 'Is it safe to walk at night?'),
        UsefulPhraseItem(id: 'p4', phrase: 'This architecture is beautiful.', translation: 'This architecture is beautiful.'),
      ],
    ),

    // A2-16
    LessonData(
      id: 'a2_reporting_a_lost_wallet',
      title: 'Reporting a Lost Wallet',
      description: 'Report a lost wallet at transit lost-and-found office.',
      level: 'A2',
      category: 'daily',
      interest: 'daily',
      difficulty: 2,
      iconKey: 'school',
      mainObjective: 'Describe item appearance, contents, location, and phone.',
      scenarioContext: 'You work at transit lost property office taking detailed loss reports.',
      assistantRole: 'Lost Property Officer',
      userRole: 'Citizen',
      initialAssistantMessage: 'Lost Property Office. Please describe the item you misplaced on transit.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe wallet color/material', keywords: ['describe', 'wallet', 'color', 'material'], examplePhrase: 'Describe wallet color/material'),
        ScenarioGoalItem(id: 'g2', text: 'List contents (ID, cash)', keywords: ['list', 'contents', 'cash'], examplePhrase: 'List contents (ID, cash)'),
        ScenarioGoalItem(id: 'g3', text: 'State last known location', keywords: ['state', 'last', 'known', 'location'], examplePhrase: 'State last known location'),
        ScenarioGoalItem(id: 'g4', text: 'Leave contact phone', keywords: ['leave', 'contact', 'phone'], examplePhrase: 'Leave contact phone'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I lost a black leather wallet.', translation: 'I lost a black leather wallet.'),
        UsefulPhraseItem(id: 'p2', phrase: 'It contains my ID and two cards.', translation: 'It contains my ID and two cards.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I left it on bus route 14.', translation: 'I left it on bus route 14.'),
        UsefulPhraseItem(id: 'p4', phrase: 'My phone number is...', translation: 'My phone number is...'),
      ],
    ),

    // A2-17
    LessonData(
      id: 'a2_hairdresser_appointment_styling',
      title: 'Hairdresser Appointment Styling',
      description: 'Communicate hair styling preferences at a hair salon.',
      level: 'A2',
      category: 'art',
      interest: 'art',
      difficulty: 2,
      iconKey: 'devices',
      mainObjective: 'Explain haircut style, length to trim, and shampoo wash.',
      scenarioContext: 'You are a hair stylist asking how much length to trim for a customer.',
      assistantRole: 'Hair Stylist',
      userRole: 'Client',
      initialAssistantMessage: 'Welcome! Take a seat in the chair. How are we styling your hair today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Specify length to trim', keywords: ['specify', 'length', 'trim'], examplePhrase: 'Specify length to trim'),
        ScenarioGoalItem(id: 'g2', text: 'Describe requested haircut style', keywords: ['describe', 'requested', 'haircut', 'style'], examplePhrase: 'Describe requested haircut style'),
        ScenarioGoalItem(id: 'g3', text: 'Decide on shampoo wash', keywords: ['decide', 'shampoo', 'wash'], examplePhrase: 'Decide on shampoo wash'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm satisfaction', keywords: ['confirm', 'satisfaction'], examplePhrase: 'Confirm satisfaction'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Just a trim on sides, please.', translation: 'Just a trim on sides, please.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Keep the top a bit longer.', translation: 'Keep the top a bit longer.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Not too short on back.', translation: 'Not too short on back.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Looks great, thank you!', translation: 'Looks great, thank you!'),
      ],
    ),

    // A2-18
    LessonData(
      id: 'a2_inquiring_about_music_festival',
      title: 'Inquiring About Music Festival',
      description: 'Ask for details about an upcoming summer music festival.',
      level: 'A2',
      category: 'music',
      interest: 'music',
      difficulty: 2,
      iconKey: 'devices',
      mainObjective: 'Inquire about band lineup, ticket prices, and parking.',
      scenarioContext: 'You staff the info booth for Summer Fest answering lineup and ticket questions.',
      assistantRole: 'Festival Info Staff',
      userRole: 'Attendee',
      initialAssistantMessage: 'Hi there! Excited for Summer Music Fest happening this weekend?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Ask who main headliners are', keywords: ['ask', 'who', 'main', 'headliners'], examplePhrase: 'Ask who main headliners are'),
        ScenarioGoalItem(id: 'g2', text: 'Check day pass ticket price', keywords: ['check', 'day', 'pass', 'ticket', 'price'], examplePhrase: 'Check day pass ticket price'),
        ScenarioGoalItem(id: 'g3', text: 'Ask food stalls available', keywords: ['ask', 'food', 'stalls', 'available'], examplePhrase: 'Ask food stalls available'),
        ScenarioGoalItem(id: 'g4', text: 'Inquire parking location', keywords: ['inquire', 'parking', 'location'], examplePhrase: 'Inquire parking location'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Which bands play Saturday?', translation: 'Which bands play Saturday?'),
        UsefulPhraseItem(id: 'p2', phrase: 'How much is a day pass?', translation: 'How much is a day pass?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Are outside drinks allowed?', translation: 'Are outside drinks allowed?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Where can I park my car?', translation: 'Where can I park my car?'),
      ],
    ),

    // A2-19
    LessonData(
      id: 'a2_getting_a_public_library_card',
      title: 'Getting a Public Library Card',
      description: 'Register for a public library card and borrow books.',
      level: 'A2',
      category: 'history',
      interest: 'history',
      difficulty: 2,
      iconKey: 'school',
      mainObjective: 'Provide address proof, fill form, ask borrowing limits.',
      scenarioContext: 'You are a librarian helping a new resident sign up for a library card.',
      assistantRole: 'Librarian',
      userRole: 'Patron',
      initialAssistantMessage: 'Hello! Welcome to Public Library. Would you like to register for a library card?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Fill out registration form', keywords: ['fill', 'out', 'registration', 'form'], examplePhrase: 'Fill out registration form'),
        ScenarioGoalItem(id: 'g2', text: 'Show proof of address', keywords: ['show', 'proof', 'address'], examplePhrase: 'Show proof of address'),
        ScenarioGoalItem(id: 'g3', text: 'Ask maximum borrowing limit', keywords: ['ask', 'maximum', 'borrowing', 'limit'], examplePhrase: 'Ask maximum borrowing limit'),
        ScenarioGoalItem(id: 'g4', text: 'Inquire about e-books', keywords: ['inquire', 'books'], examplePhrase: 'Inquire about e-books'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I would like a library card.', translation: 'I would like a library card.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Here is my utility bill proof.', translation: 'Here is my utility bill proof.'),
        UsefulPhraseItem(id: 'p3', phrase: 'How many books can I borrow?', translation: 'How many books can I borrow?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Is e-book access free?', translation: 'Is e-book access free?'),
      ],
    ),

    // A2-20
    LessonData(
      id: 'a2_ordering_food_delivery_by_phone',
      title: 'Ordering Food Delivery by Phone',
      description: 'Place a phone order for takeaway delivery to apartment.',
      level: 'A2',
      category: 'cooking',
      interest: 'cooking',
      difficulty: 2,
      iconKey: 'restaurant',
      mainObjective: 'Specify food items, spice level, address, and cash payment.',
      scenarioContext: 'You take delivery phone orders for a Thai food restaurant.',
      assistantRole: 'Delivery Dispatcher',
      userRole: 'Customer',
      initialAssistantMessage: 'Hello! Thanks for calling Spicy Thai Delivery. What can I get for you?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State food items and spice level', keywords: ['state', 'food', 'items', 'spice', 'level'], examplePhrase: 'State food items and spice level'),
        ScenarioGoalItem(id: 'g2', text: 'Provide complete delivery address', keywords: ['provide', 'complete', 'delivery', 'address'], examplePhrase: 'Provide complete delivery address'),
        ScenarioGoalItem(id: 'g3', text: 'Ask delivery time estimate', keywords: ['ask', 'delivery', 'time', 'estimate'], examplePhrase: 'Ask delivery time estimate'),
        ScenarioGoalItem(id: 'g4', text: 'Choose payment method', keywords: ['choose', 'payment', 'method'], examplePhrase: 'Choose payment method'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I would like Pad Thai chicken.', translation: 'I would like Pad Thai chicken.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Medium spicy, please.', translation: 'Medium spicy, please.'),
        UsefulPhraseItem(id: 'p3', phrase: 'My address is 45 Main St Apt 3B.', translation: 'My address is 45 Main St Apt 3B.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Will pay cash on delivery.', translation: 'Will pay cash on delivery.'),
      ],
    ),


    // =========================================================================
    // NIVEL B1 — B1 — Intermedio (20 lecciones)
    // =========================================================================

    // B1-01
    LessonData(
      id: 'b1_job_interview_strengths_weaknesses',
      title: 'Job Interview: Strengths & Weaknesses',
      description: 'Answer classic job interview questions about professional skills.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Describe key strengths, managed weakness, and past work example.',
      scenarioContext: 'You are a hiring manager interviewing a candidate. Ask about core strengths, weaknesses, and past achievements.',
      assistantRole: 'Hiring Manager',
      userRole: 'Job Candidate',
      initialAssistantMessage: 'Welcome to your interview today. To start off, tell me about your greatest professional strength.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Highlight core professional strength', keywords: ['highlight', 'core', 'professional', 'strength'], examplePhrase: 'Highlight core professional strength'),
        ScenarioGoalItem(id: 'g2', text: 'Explain weakness with improvement step', keywords: ['explain', 'weakness', 'improvement', 'step'], examplePhrase: 'Explain weakness with improvement step'),
        ScenarioGoalItem(id: 'g3', text: 'Provide past work accomplishment', keywords: ['provide', 'past', 'work', 'accomplishment'], examplePhrase: 'Provide past work accomplishment'),
        ScenarioGoalItem(id: 'g4', text: 'Express enthusiasm for role', keywords: ['express', 'enthusiasm', 'role'], examplePhrase: 'Express enthusiasm for role'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'One of my main strengths is problem solving.', translation: 'One of my main strengths is problem solving.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I used to struggle with delegation, but now...', translation: 'I used to struggle with delegation, but now...'),
        UsefulPhraseItem(id: 'p3', phrase: 'In my last role, I successfully led...', translation: 'In my last role, I successfully led...'),
        UsefulPhraseItem(id: 'p4', phrase: 'I am excited about this opportunity.', translation: 'I am excited about this opportunity.'),
      ],
    ),

    // B1-02
    LessonData(
      id: 'b1_describing_past_work_challenges',
      title: 'Describing Past Work Challenges',
      description: 'Narrate a difficult work situation and how you resolved it.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Use STAR structure to describe project delay and resolution.',
      scenarioContext: 'You are an interviewer asking candidate to use STAR method (Situation, Task, Action, Result) for past challenge.',
      assistantRole: 'Interviewer',
      userRole: 'Candidate',
      initialAssistantMessage: 'Can you describe a specific time when a project did not go according to original plan?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe initial problem situation', keywords: ['describe', 'initial', 'problem', 'situation'], examplePhrase: 'Describe initial problem situation'),
        ScenarioGoalItem(id: 'g2', text: 'Explain action plan implemented', keywords: ['explain', 'action', 'plan', 'implemented'], examplePhrase: 'Explain action plan implemented'),
        ScenarioGoalItem(id: 'g3', text: 'Highlight team collaboration', keywords: ['highlight', 'team', 'collaboration'], examplePhrase: 'Highlight team collaboration'),
        ScenarioGoalItem(id: 'g4', text: 'Share positive outcome metrics', keywords: ['share', 'positive', 'outcome', 'metrics'], examplePhrase: 'Share positive outcome metrics'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We faced a tight deadline when...', translation: 'We faced a tight deadline when...'),
        UsefulPhraseItem(id: 'p2', phrase: 'I organized emergency stand-up meetings.', translation: 'I organized emergency stand-up meetings.'),
        UsefulPhraseItem(id: 'p3', phrase: 'As a result, we delivered on time.', translation: 'As a result, we delivered on time.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I learned the value of clear communication.', translation: 'I learned the value of clear communication.'),
      ],
    ),

    // B1-03
    LessonData(
      id: 'b1_apartment_viewing_with_landlord',
      title: 'Apartment Viewing with Landlord',
      description: 'Inspect a rental apartment and discuss lease terms.',
      level: 'B1',
      category: 'daily',
      interest: 'daily',
      difficulty: 3,
      iconKey: 'school',
      mainObjective: 'Evaluate apartment condition, ask about utilities, deposit, and date.',
      scenarioContext: 'You are a landlord showing a 2-bedroom flat and discussing rent, deposit, and utility terms.',
      assistantRole: 'Landlord',
      userRole: 'Prospective Tenant',
      initialAssistantMessage: 'Welcome! This is the two-bedroom apartment. Feel free to look around the rooms!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Inspect appliances and lighting', keywords: ['inspect', 'appliances', 'lighting'], examplePhrase: 'Inspect appliances and lighting'),
        ScenarioGoalItem(id: 'g2', text: 'Ask if utilities included in rent', keywords: ['ask', 'utilities', 'included', 'rent'], examplePhrase: 'Ask if utilities included in rent'),
        ScenarioGoalItem(id: 'g3', text: 'Discuss security deposit amount', keywords: ['discuss', 'security', 'deposit', 'amount'], examplePhrase: 'Discuss security deposit amount'),
        ScenarioGoalItem(id: 'g4', text: 'Negotiate lease start date', keywords: ['negotiate', 'lease', 'start', 'date'], examplePhrase: 'Negotiate lease start date'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Are utilities included in rent?', translation: 'Are utilities included in rent?'),
        UsefulPhraseItem(id: 'p2', phrase: 'How much is security deposit?', translation: 'How much is security deposit?'),
        UsefulPhraseItem(id: 'p3', phrase: 'When is earliest move-in date?', translation: 'When is earliest move-in date?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Is parking space included?', translation: 'Is parking space included?'),
      ],
    ),

    // B1-04
    LessonData(
      id: 'b1_troubleshooting_software_bug_with_it',
      title: 'Troubleshooting Software Bug with IT',
      description: 'Describe a computer software glitch to IT support technician.',
      level: 'B1',
      category: 'technology',
      interest: 'technology',
      difficulty: 3,
      iconKey: 'devices',
      mainObjective: 'Explain error message, steps leading to crash, and OS version.',
      scenarioContext: 'You are an IT helpdesk specialist guiding user through error logs and app restart steps.',
      assistantRole: 'IT Support Specialist',
      userRole: 'User',
      initialAssistantMessage: 'IT Help Desk. What technical software issue are you experiencing on your computer today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe error message text', keywords: ['describe', 'error', 'message', 'text'], examplePhrase: 'Describe error message text'),
        ScenarioGoalItem(id: 'g2', text: 'Explain action causing crash', keywords: ['explain', 'action', 'causing', 'crash'], examplePhrase: 'Explain action causing crash'),
        ScenarioGoalItem(id: 'g3', text: 'Confirm OS version', keywords: ['confirm', 'version'], examplePhrase: 'Confirm OS version'),
        ScenarioGoalItem(id: 'g4', text: 'Follow IT technician steps', keywords: ['follow', 'technician', 'steps'], examplePhrase: 'Follow IT technician steps'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'My app crashes when I click export.', translation: 'My app crashes when I click export.'),
        UsefulPhraseItem(id: 'p2', phrase: 'The error code shows 500.', translation: 'The error code shows 500.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I tried restarting the computer already.', translation: 'I tried restarting the computer already.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Should I reinstall the app?', translation: 'Should I reinstall the app?'),
      ],
    ),

    // B1-05
    LessonData(
      id: 'b1_customer_service_refund_negotiation',
      title: 'Customer Service Refund Negotiation',
      description: 'Resolve a product dispute with online retail manager.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Explain damaged item, cite return policy, demand full refund.',
      scenarioContext: 'You are a retail customer service manager handling a damaged product complaint.',
      assistantRole: 'Support Manager',
      userRole: 'Customer',
      initialAssistantMessage: 'Thank you for contacting customer support. How can I resolve your order issue today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Explain damaged item condition', keywords: ['explain', 'damaged', 'item', 'condition'], examplePhrase: 'Explain damaged item condition'),
        ScenarioGoalItem(id: 'g2', text: 'Reference order number and policy', keywords: ['reference', 'order', 'number', 'policy'], examplePhrase: 'Reference order number and policy'),
        ScenarioGoalItem(id: 'g3', text: 'Reject replacement if damaged', keywords: ['reject', 'replacement', 'damaged'], examplePhrase: 'Reject replacement if damaged'),
        ScenarioGoalItem(id: 'g4', text: 'Insist on full refund', keywords: ['insist', 'full', 'refund'], examplePhrase: 'Insist on full refund'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'The item arrived completely damaged.', translation: 'The item arrived completely damaged.'),
        UsefulPhraseItem(id: 'p2', phrase: 'My order number is 98765.', translation: 'My order number is 98765.'),
        UsefulPhraseItem(id: 'p3', phrase: 'According to policy, I am eligible for refund.', translation: 'According to policy, I am eligible for refund.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I expect full refund to my card.', translation: 'I expect full refund to my card.'),
      ],
    ),

    // B1-06
    LessonData(
      id: 'b1_discussing_favorite_movies_themes',
      title: 'Discussing Favorite Movies & Themes',
      description: 'Critique a film plot, actor performances, and themes.',
      level: 'B1',
      category: 'music',
      interest: 'music',
      difficulty: 3,
      iconKey: 'devices',
      mainObjective: 'Express opinions on acting, plot twists, and recommendations.',
      scenarioContext: 'You are a movie enthusiast discussing latest cinema releases and directing styles.',
      assistantRole: 'Film Buff',
      userRole: 'Movie Fan',
      initialAssistantMessage: 'Did you watch that new sci-fi movie everyone has been talking about recently?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Share overall movie impression', keywords: ['share', 'overall', 'movie', 'impression'], examplePhrase: 'Share overall movie impression'),
        ScenarioGoalItem(id: 'g2', text: 'Discuss lead actor performance', keywords: ['discuss', 'lead', 'actor', 'performance'], examplePhrase: 'Discuss lead actor performance'),
        ScenarioGoalItem(id: 'g3', text: 'Analyze plot twists message', keywords: ['analyze', 'plot', 'twists', 'message'], examplePhrase: 'Analyze plot twists message'),
        ScenarioGoalItem(id: 'g4', text: 'Recommend film to friend', keywords: ['recommend', 'film', 'friend'], examplePhrase: 'Recommend film to friend'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Visual effects were incredible.', translation: 'Visual effects were incredible.'),
        UsefulPhraseItem(id: 'p2', phrase: 'The plot twist surprised me.', translation: 'The plot twist surprised me.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Pacing felt a bit slow.', translation: 'Pacing felt a bit slow.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I highly recommend watching it.', translation: 'I highly recommend watching it.'),
      ],
    ),

    // B1-07
    LessonData(
      id: 'b1_planning_a_group_trip_budget',
      title: 'Planning a Group Trip Budget',
      description: 'Coordinate travel logistics and budget allocation with friends.',
      level: 'B1',
      category: 'travel',
      interest: 'travel',
      difficulty: 3,
      iconKey: 'explore',
      mainObjective: 'Balance accommodation costs, food expenses, and transport.',
      scenarioContext: 'You are organizing a summer group vacation with a budget of \$500 per person.',
      assistantRole: 'Trip Organizer',
      userRole: 'Group Member',
      initialAssistantMessage: 'Let us finalize our summer vacation budget! We have about \$500 budget per person.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Propose budget allocation hotel/food', keywords: ['propose', 'budget', 'allocation', 'hotel', 'food'], examplePhrase: 'Propose budget allocation hotel/food'),
        ScenarioGoalItem(id: 'g2', text: 'Suggest cost-saving travel hacks', keywords: ['suggest', 'cost', 'saving', 'travel', 'hacks'], examplePhrase: 'Suggest cost-saving travel hacks'),
        ScenarioGoalItem(id: 'g3', text: 'Agree on group activities', keywords: ['agree', 'group', 'activities'], examplePhrase: 'Agree on group activities'),
        ScenarioGoalItem(id: 'g4', text: 'Set up shared expense app', keywords: ['set', 'shared', 'expense', 'app'], examplePhrase: 'Set up shared expense app'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We should prioritize central lodging.', translation: 'We should prioritize central lodging.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Cooking breakfast saves money.', translation: 'Cooking breakfast saves money.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Let us split transit costs evenly.', translation: 'Let us split transit costs evenly.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will track expenses in app.', translation: 'I will track expenses in app.'),
      ],
    ),

    // B1-08
    LessonData(
      id: 'b1_weekly_office_status_update_meeting',
      title: 'Weekly Office Status Update Meeting',
      description: 'Give a concise progress update on your active project tasks.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Summarize completed tasks, blockers, and next priorities.',
      scenarioContext: 'You are a project manager hosting weekly team stand-up for project status updates.',
      assistantRole: 'Project Manager',
      userRole: 'Team Member',
      initialAssistantMessage: 'Alright team, let us go around the table. What did you accomplish this week?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Report completed weekly tasks', keywords: ['report', 'completed', 'weekly', 'tasks'], examplePhrase: 'Report completed weekly tasks'),
        ScenarioGoalItem(id: 'g2', text: 'Mention current blockers/dependencies', keywords: ['mention', 'current', 'blockers', 'dependencies'], examplePhrase: 'Mention current blockers/dependencies'),
        ScenarioGoalItem(id: 'g3', text: 'Outline top priority next week', keywords: ['outline', 'top', 'priority', 'next', 'week'], examplePhrase: 'Outline top priority next week'),
        ScenarioGoalItem(id: 'g4', text: 'Ask colleague input', keywords: ['ask', 'colleague', 'input'], examplePhrase: 'Ask colleague input'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'This week I completed database migration.', translation: 'This week I completed database migration.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I am blocked by design approval.', translation: 'I am blocked by design approval.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Next week I focus on testing.', translation: 'Next week I focus on testing.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Can we sync after this call?', translation: 'Can we sync after this call?'),
      ],
    ),

    // B1-09
    LessonData(
      id: 'b1_resolving_missing_package_shipping_issue',
      title: 'Resolving Missing Package Shipping Issue',
      description: 'Track a missing delivery package and arrange redelivery.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Provide tracking code, verify address, demand status update.',
      scenarioContext: 'You are a logistics agent checking tracking numbers and delivery driver status.',
      assistantRole: 'Logistics Agent',
      userRole: 'Customer',
      initialAssistantMessage: 'Express Shipping support. How can I check your delivery package status today?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Provide tracking number', keywords: ['provide', 'tracking', 'number'], examplePhrase: 'Provide tracking number'),
        ScenarioGoalItem(id: 'g2', text: 'Explain missing package date', keywords: ['explain', 'missing', 'package', 'date'], examplePhrase: 'Explain missing package date'),
        ScenarioGoalItem(id: 'g3', text: 'Verify address instructions', keywords: ['verify', 'address', 'instructions'], examplePhrase: 'Verify address instructions'),
        ScenarioGoalItem(id: 'g4', text: 'Request priority redelivery', keywords: ['request', 'priority', 'redelivery'], examplePhrase: 'Request priority redelivery'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Tracking says delivered, but not received.', translation: 'Tracking says delivered, but not received.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Here is my tracking code.', translation: 'Here is my tracking code.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Can you contact driver directly?', translation: 'Can you contact driver directly?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Please arrange redelivery tomorrow.', translation: 'Please arrange redelivery tomorrow.'),
      ],
    ),

    // B1-10
    LessonData(
      id: 'b1_setting_fitness_health_targets',
      title: 'Setting Fitness & Health Targets',
      description: 'Discuss health habits and realistic targets with a trainer.',
      level: 'B1',
      category: 'sports',
      interest: 'sports',
      difficulty: 3,
      iconKey: 'people',
      mainObjective: 'Define measurable targets (endurance, weight) and diet habits.',
      scenarioContext: 'You are a wellness coach evaluating client fitness goals, diet, and tracking.',
      assistantRole: 'Wellness Coach',
      userRole: 'Client',
      initialAssistantMessage: 'Welcome to your wellness evaluation! What health goals do you want to achieve?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State primary health goal', keywords: ['state', 'primary', 'health', 'goal'], examplePhrase: 'State primary health goal'),
        ScenarioGoalItem(id: 'g2', text: 'Discuss current diet/exercise', keywords: ['discuss', 'current', 'diet', 'exercise'], examplePhrase: 'Discuss current diet/exercise'),
        ScenarioGoalItem(id: 'g3', text: 'Set 3-month target', keywords: ['set', 'month', 'target'], examplePhrase: 'Set 3-month target'),
        ScenarioGoalItem(id: 'g4', text: 'Agree weekly check-ins', keywords: ['agree', 'weekly', 'check', 'ins'], examplePhrase: 'Agree weekly check-ins'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I want to run a 10k race in three months.', translation: 'I want to run a 10k race in three months.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I currently exercise twice a week.', translation: 'I currently exercise twice a week.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I need help planning balanced meals.', translation: 'I need help planning balanced meals.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us track progress weekly.', translation: 'Let us track progress weekly.'),
      ],
    ),

    // B1-11
    LessonData(
      id: 'b1_volunteering_for_community_park_cleanup',
      title: 'Volunteering for Community Park Cleanup',
      description: 'Inquire about volunteer roles for local environmental cleanup.',
      level: 'B1',
      category: 'science',
      interest: 'science',
      difficulty: 3,
      iconKey: 'explore',
      mainObjective: 'Express interest, discuss weekend availability, and tasks.',
      scenarioContext: 'You are volunteer coordinator signing up citizens for eco-cleanup projects.',
      assistantRole: 'Volunteer Coordinator',
      userRole: 'Volunteer',
      initialAssistantMessage: 'Thank you for reaching out to EcoClean Community! Ready to make a difference?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State volunteer motivation', keywords: ['state', 'volunteer', 'motivation'], examplePhrase: 'State volunteer motivation'),
        ScenarioGoalItem(id: 'g2', text: 'Specify weekend hours available', keywords: ['specify', 'weekend', 'hours', 'available'], examplePhrase: 'Specify weekend hours available'),
        ScenarioGoalItem(id: 'g3', text: 'Select planting/cleanup activity', keywords: ['select', 'planting', 'cleanup', 'activity'], examplePhrase: 'Select planting/cleanup activity'),
        ScenarioGoalItem(id: 'g4', text: 'Ask what equipment to bring', keywords: ['ask', 'what', 'equipment', 'bring'], examplePhrase: 'Ask what equipment to bring'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I want to improve local parks.', translation: 'I want to improve local parks.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I am free on Saturday mornings.', translation: 'I am free on Saturday mornings.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I prefer outdoor planting activities.', translation: 'I prefer outdoor planting activities.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Do I need to bring my own gloves?', translation: 'Do I need to bring my own gloves?'),
      ],
    ),

    // B1-12
    LessonData(
      id: 'b1_organizing_a_surprise_birthday_party',
      title: 'Organizing a Surprise Birthday Party',
      description: 'Plan secret party details (venue, cake, guest list) with co-organizer.',
      level: 'B1',
      category: 'music',
      interest: 'music',
      difficulty: 3,
      iconKey: 'devices',
      mainObjective: 'Delegate food, music, secret arrival time, and guest list.',
      scenarioContext: 'You are co-organizing a surprise 30th birthday party for a mutual friend.',
      assistantRole: 'Co-Planner',
      userRole: 'Party Organizer',
      initialAssistantMessage: 'Shh! Let us plan Sarah surprise 30th birthday party without her knowing!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Suggest secret venue', keywords: ['suggest', 'secret', 'venue'], examplePhrase: 'Suggest secret venue'),
        ScenarioGoalItem(id: 'g2', text: 'Assign cake and music tasks', keywords: ['assign', 'cake', 'music', 'tasks'], examplePhrase: 'Assign cake and music tasks'),
        ScenarioGoalItem(id: 'g3', text: 'Create secret group chat', keywords: ['create', 'secret', 'group', 'chat'], examplePhrase: 'Create secret group chat'),
        ScenarioGoalItem(id: 'g4', text: 'Establish guest arrival timeline', keywords: ['establish', 'guest', 'arrival', 'timeline'], examplePhrase: 'Establish guest arrival timeline'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We must keep this secret.', translation: 'We must keep this secret.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I will handle birthday cake and drinks.', translation: 'I will handle birthday cake and drinks.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Everyone must arrive 30 min early.', translation: 'Everyone must arrive 30 min early.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will create a hidden event page.', translation: 'I will create a hidden event page.'),
      ],
    ),

    // B1-13
    LessonData(
      id: 'b1_discussing_long_term_career_ambitions',
      title: 'Discussing Long-Term Career Ambitions',
      description: 'Discuss career growth, promotion goals, and skill gaps with mentor.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Share 5-year vision, identify skill gaps, seek advice.',
      scenarioContext: 'You are a senior career mentor helping a junior professional map out 5-year goals.',
      assistantRole: 'Career Mentor',
      userRole: 'Mentee',
      initialAssistantMessage: 'Where do you see yourself professionally in the next three to five years?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Share 5-year career vision', keywords: ['share', 'year', 'career', 'vision'], examplePhrase: 'Share 5-year career vision'),
        ScenarioGoalItem(id: 'g2', text: 'Identify skills needed', keywords: ['identify', 'skills', 'needed'], examplePhrase: 'Identify skills needed'),
        ScenarioGoalItem(id: 'g3', text: 'Ask mentor for actionable advice', keywords: ['ask', 'mentor', 'actionable', 'advice'], examplePhrase: 'Ask mentor for actionable advice'),
        ScenarioGoalItem(id: 'g4', text: 'Plan next steps', keywords: ['plan', 'next', 'steps'], examplePhrase: 'Plan next steps'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I aim to transition into management.', translation: 'I aim to transition into management.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I need to improve public speaking.', translation: 'I need to improve public speaking.'),
        UsefulPhraseItem(id: 'p3', phrase: 'What certifications do you recommend?', translation: 'What certifications do you recommend?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you for valuable guidance.', translation: 'Thank you for valuable guidance.'),
      ],
    ),

    // B1-14
    LessonData(
      id: 'b1_resolving_workplace_miscommunication',
      title: 'Resolving Workplace Miscommunication',
      description: 'Clarify miscommunication over task ownership with colleague.',
      level: 'B1',
      category: 'business',
      interest: 'business',
      difficulty: 3,
      iconKey: 'work',
      mainObjective: 'Politely explain perspective, listen actively, set task split.',
      scenarioContext: 'You are a colleague resolving a misunderstanding about presentation deck ownership.',
      assistantRole: 'Colleague',
      userRole: 'Team Member',
      initialAssistantMessage: 'Hey, I felt there was some confusion about who was presenting slides today.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Acknowledge communication gap', keywords: ['acknowledge', 'communication', 'gap'], examplePhrase: 'Acknowledge communication gap'),
        ScenarioGoalItem(id: 'g2', text: 'Explain initial understanding', keywords: ['explain', 'initial', 'understanding'], examplePhrase: 'Explain initial understanding'),
        ScenarioGoalItem(id: 'g3', text: 'Propose clear task division', keywords: ['propose', 'clear', 'task', 'division'], examplePhrase: 'Propose clear task division'),
        ScenarioGoalItem(id: 'g4', text: 'Agree future sync protocol', keywords: ['agree', 'future', 'sync', 'protocol'], examplePhrase: 'Agree future sync protocol'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I apologize for the misunderstanding.', translation: 'I apologize for the misunderstanding.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I thought you wanted me to cover section two.', translation: 'I thought you wanted me to cover section two.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Let us clearly divide presentation topics.', translation: 'Let us clearly divide presentation topics.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We should confirm in writing next time.', translation: 'We should confirm in writing next time.'),
      ],
    ),

    // B1-15
    LessonData(
      id: 'b1_adopting_sustainable_daily_habits',
      title: 'Adopting Sustainable Daily Habits',
      description: 'Debate practical ways to reduce plastic waste and energy footprint.',
      level: 'B1',
      category: 'science',
      interest: 'science',
      difficulty: 3,
      iconKey: 'explore',
      mainObjective: 'Discuss eco-friendly habits (reusable bags, transit) and challenges.',
      scenarioContext: 'You are an eco-activist discussing daily recycling and energy saving habits.',
      assistantRole: 'Eco Activist',
      userRole: 'Citizen',
      initialAssistantMessage: 'What daily changes have you made recently to live more sustainably?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Mention reusable bags and bottles', keywords: ['mention', 'reusable', 'bags', 'bottles'], examplePhrase: 'Mention reusable bags and bottles'),
        ScenarioGoalItem(id: 'g2', text: 'Discuss reducing energy consumption', keywords: ['discuss', 'reducing', 'energy', 'consumption'], examplePhrase: 'Discuss reducing energy consumption'),
        ScenarioGoalItem(id: 'g3', text: 'Debate recycling challenges', keywords: ['debate', 'recycling', 'challenges'], examplePhrase: 'Debate recycling challenges'),
        ScenarioGoalItem(id: 'g4', text: 'Encourage community habits', keywords: ['encourage', 'community', 'habits'], examplePhrase: 'Encourage community habits'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I started bringing reusable cloth bags.', translation: 'I started bringing reusable cloth bags.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I switched to public transit.', translation: 'I switched to public transit.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Recycling rules can be confusing.', translation: 'Recycling rules can be confusing.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Every small habit makes a difference.', translation: 'Every small habit makes a difference.'),
      ],
    ),

    // B1-16
    LessonData(
      id: 'b1_designing_remote_work_home_office',
      title: 'Designing Remote Work Home Office',
      description: 'Discuss ergonomic furniture, internet reliability, and work boundaries.',
      level: 'B1',
      category: 'technology',
      interest: 'technology',
      difficulty: 3,
      iconKey: 'devices',
      mainObjective: 'Evaluate dual monitors, ergonomic chair, internet, and work hours.',
      scenarioContext: 'You are a remote work advisor evaluating home office ergonomics and routines.',
      assistantRole: 'Remote Advisor',
      userRole: 'Remote Employee',
      initialAssistantMessage: 'Working from home can be great if your setup is right! How is your office setup?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe desk and monitor setup', keywords: ['describe', 'desk', 'monitor', 'setup'], examplePhrase: 'Describe desk and monitor setup'),
        ScenarioGoalItem(id: 'g2', text: 'Discuss ergonomic chair posture', keywords: ['discuss', 'ergonomic', 'chair', 'posture'], examplePhrase: 'Discuss ergonomic chair posture'),
        ScenarioGoalItem(id: 'g3', text: 'Mention internet speed needs', keywords: ['mention', 'internet', 'speed', 'needs'], examplePhrase: 'Mention internet speed needs'),
        ScenarioGoalItem(id: 'g4', text: 'Set work hour boundaries', keywords: ['set', 'work', 'hour', 'boundaries'], examplePhrase: 'Set work hour boundaries'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I bought dual monitors recently.', translation: 'I bought dual monitors recently.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I need better ergonomic office chair.', translation: 'I need better ergonomic office chair.'),
        UsefulPhraseItem(id: 'p3', phrase: 'High-speed internet is essential.', translation: 'High-speed internet is essential.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I log off strictly at 6 PM.', translation: 'I log off strictly at 6 PM.'),
      ],
    ),

    // B1-17
    LessonData(
      id: 'b1_selecting_university_elective_courses',
      title: 'Selecting University Elective Courses',
      description: 'Discuss university course choices with an academic advisor.',
      level: 'B1',
      category: 'history',
      interest: 'history',
      difficulty: 3,
      iconKey: 'school',
      mainObjective: 'Compare history vs literature courses, exams, and credit count.',
      scenarioContext: 'You are an academic advisor reviewing course credits and syllabi with a student.',
      assistantRole: 'Academic Advisor',
      userRole: 'University Student',
      initialAssistantMessage: 'Hello! Let us review your elective choices for the upcoming semester.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Express interest in history vs literature', keywords: ['express', 'interest', 'history', 'literature'], examplePhrase: 'Express interest in history vs literature'),
        ScenarioGoalItem(id: 'g2', text: 'Ask about exam vs essay grade', keywords: ['ask', 'exam', 'essay', 'grade'], examplePhrase: 'Ask about exam vs essay grade'),
        ScenarioGoalItem(id: 'g3', text: 'Check prerequisite requirements', keywords: ['check', 'prerequisite', 'requirements'], examplePhrase: 'Check prerequisite requirements'),
        ScenarioGoalItem(id: 'g4', text: 'Finalize course registration', keywords: ['finalize', 'course', 'registration'], examplePhrase: 'Finalize course registration'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I am considering World History 201.', translation: 'I am considering World History 201.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Is grade based on essays or exams?', translation: 'Is grade based on essays or exams?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Does this course satisfy credit count?', translation: 'Does this course satisfy credit count?'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will enroll in this course.', translation: 'I will enroll in this course.'),
      ],
    ),

    // B1-18
    LessonData(
      id: 'b1_bargaining_price_at_flea_market',
      title: 'Bargaining Price at Flea Market',
      description: 'Negotiate price for antique souvenirs with street vendor.',
      level: 'B1',
      category: 'travel',
      interest: 'travel',
      difficulty: 3,
      iconKey: 'explore',
      mainObjective: 'Politely offer lower counter-price, point out wear, reach deal.',
      scenarioContext: 'You are a flea market antique vendor negotiating prices with a savvy tourist.',
      assistantRole: 'Market Vendor',
      userRole: 'Buyer',
      initialAssistantMessage: 'Step right up! Authentic hand-crafted vintage clock. Only \$80 today!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Politely question original price', keywords: ['politely', 'question', 'original', 'price'], examplePhrase: 'Politely question original price'),
        ScenarioGoalItem(id: 'g2', text: 'Offer lower counter-price', keywords: ['offer', 'lower', 'counter', 'price'], examplePhrase: 'Offer lower counter-price'),
        ScenarioGoalItem(id: 'g3', text: 'Highlight minor scratch wear', keywords: ['highlight', 'minor', 'scratch', 'wear'], examplePhrase: 'Highlight minor scratch wear'),
        ScenarioGoalItem(id: 'g4', text: 'Agree fair final price', keywords: ['agree', 'fair', 'final', 'price'], examplePhrase: 'Agree fair final price'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'That is a bit above my budget.', translation: 'That is a bit above my budget.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Would you accept \$50 for this clock?', translation: 'Would you accept \$50 for this clock?'),
        UsefulPhraseItem(id: 'p3', phrase: 'It has a tiny scratch on the side.', translation: 'It has a tiny scratch on the side.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us deal at \$60, cash.', translation: 'Let us deal at \$60, cash.'),
      ],
    ),

    // B1-19
    LessonData(
      id: 'b1_handling_flight_schedule_changes',
      title: 'Handling Flight Schedule Changes',
      description: 'Rebook a missed connecting flight at airline customer desk.',
      level: 'B1',
      category: 'travel',
      interest: 'travel',
      difficulty: 3,
      iconKey: 'explore',
      mainObjective: 'Explain missed connection, ask next flight, request meal voucher.',
      scenarioContext: 'You are an airline agent rebooking passengers affected by flight delay.',
      assistantRole: 'Airline Agent',
      userRole: 'Passenger',
      initialAssistantMessage: 'I am sorry your incoming flight arrived late. Let me help rebook your seat.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Explain missed connection cause', keywords: ['explain', 'missed', 'connection', 'cause'], examplePhrase: 'Explain missed connection cause'),
        ScenarioGoalItem(id: 'g2', text: 'Request seat on next flight', keywords: ['request', 'seat', 'next', 'flight'], examplePhrase: 'Request seat on next flight'),
        ScenarioGoalItem(id: 'g3', text: 'Inquire about meal vouchers', keywords: ['inquire', 'meal', 'vouchers'], examplePhrase: 'Inquire about meal vouchers'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm baggage transfer', keywords: ['confirm', 'baggage', 'transfer'], examplePhrase: 'Confirm baggage transfer'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'My incoming flight was delayed.', translation: 'My incoming flight was delayed.'),
        UsefulPhraseItem(id: 'p2', phrase: 'What is next available flight?', translation: 'What is next available flight?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Am I eligible for meal voucher?', translation: 'Am I eligible for meal voucher?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Will luggage transfer automatically?', translation: 'Will luggage transfer automatically?'),
      ],
    ),

    // B1-20
    LessonData(
      id: 'b1_comparing_cultural_traditions_holidays',
      title: 'Comparing Cultural Traditions & Holidays',
      description: 'Discuss holiday traditions, food customs, and celebrations.',
      level: 'B1',
      category: 'history',
      interest: 'history',
      difficulty: 3,
      iconKey: 'school',
      mainObjective: 'Describe holiday meals, family gatherings, contrast customs.',
      scenarioContext: 'You are an international exchange student sharing holiday customs and food.',
      assistantRole: 'International Peer',
      userRole: 'Student',
      initialAssistantMessage: 'In my country, New Year is celebrated with family dinners. How about yours?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Describe holiday traditional foods', keywords: ['describe', 'holiday', 'traditional', 'foods'], examplePhrase: 'Describe holiday traditional foods'),
        ScenarioGoalItem(id: 'g2', text: 'Explain family gathering customs', keywords: ['explain', 'family', 'gathering', 'customs'], examplePhrase: 'Explain family gathering customs'),
        ScenarioGoalItem(id: 'g3', text: 'Compare gift-giving traditions', keywords: ['compare', 'gift', 'giving', 'traditions'], examplePhrase: 'Compare gift-giving traditions'),
        ScenarioGoalItem(id: 'g4', text: 'Express appreciation for diversity', keywords: ['express', 'appreciation', 'diversity'], examplePhrase: 'Express appreciation for diversity'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We prepare a big family feast on New Year Eve.', translation: 'We prepare a big family feast on New Year Eve.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Firework displays light up the city.', translation: 'Firework displays light up the city.'),
        UsefulPhraseItem(id: 'p3', phrase: 'It is fascinating how cultures celebrate differently.', translation: 'It is fascinating how cultures celebrate differently.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I would love to experience your tradition!', translation: 'I would love to experience your tradition!'),
      ],
    ),


    // =========================================================================
    // NIVEL B2 — B2 — Intermedio Alto (20 lecciones)
    // =========================================================================

    // B2-01
    LessonData(
      id: 'b2_senior_tech_developer_architecture_interview',
      title: 'Senior Tech Developer Architecture Interview',
      description: 'Demonstrate technical expertise, microservices, and system design.',
      level: 'B2',
      category: 'technology',
      interest: 'technology',
      difficulty: 4,
      iconKey: 'devices',
      mainObjective: 'Explain Redis caching, SQL vs NoSQL, and scaling trade-offs.',
      scenarioContext: 'You are a Lead Tech Architect evaluating senior developer candidate on microservices API scaling.',
      assistantRole: 'Lead Architect',
      userRole: 'Senior Developer Candidate',
      initialAssistantMessage: 'Welcome! To start off, how do you handle scaling a high-traffic microservices API?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Explain microservice Redis caching', keywords: ['explain', 'microservice', 'redis', 'caching'], examplePhrase: 'Explain microservice Redis caching'),
        ScenarioGoalItem(id: 'g2', text: 'Discuss trade-offs SQL vs NoSQL', keywords: ['discuss', 'trade', 'offs', 'sql', 'nosql'], examplePhrase: 'Discuss trade-offs SQL vs NoSQL'),
        ScenarioGoalItem(id: 'g3', text: 'Describe incident debugging process', keywords: ['describe', 'incident', 'debugging', 'process'], examplePhrase: 'Describe incident debugging process'),
        ScenarioGoalItem(id: 'g4', text: 'Demonstrate engineering leadership', keywords: ['demonstrate', 'engineering', 'leadership'], examplePhrase: 'Demonstrate engineering leadership'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I recommend implementing Redis caching.', translation: 'I recommend implementing Redis caching.'),
        UsefulPhraseItem(id: 'p2', phrase: 'We prioritized horizontal scaling for traffic.', translation: 'We prioritized horizontal scaling for traffic.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Monolith vs microservices depends on domain.', translation: 'Monolith vs microservices depends on domain.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I emphasize automated CI/CD testing.', translation: 'I emphasize automated CI/CD testing.'),
      ],
    ),

    // B2-02
    LessonData(
      id: 'b2_pitching_a_new_product_feature',
      title: 'Pitching a New Product Feature',
      description: 'Present a compelling product roadmap proposal to stakeholders.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Highlight user pain point, ROI metrics, timeline, and objection.',
      scenarioContext: 'You are Product Director listening to product manager feature pitch for AI onboarding.',
      assistantRole: 'Product Director',
      userRole: 'Product Manager',
      initialAssistantMessage: 'You have 5 minutes to pitch your proposed AI feature to the board. Go ahead!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State core user pain point', keywords: ['state', 'core', 'user', 'pain', 'point'], examplePhrase: 'State core user pain point'),
        ScenarioGoalItem(id: 'g2', text: 'Present AI feature prototype solution', keywords: ['present', 'feature', 'prototype', 'solution'], examplePhrase: 'Present AI feature prototype solution'),
        ScenarioGoalItem(id: 'g3', text: 'Show projected user retention metrics', keywords: ['show', 'projected', 'user', 'retention', 'metrics'], examplePhrase: 'Show projected user retention metrics'),
        ScenarioGoalItem(id: 'g4', text: 'Answer stakeholder objections', keywords: ['answer', 'stakeholder', 'objections'], examplePhrase: 'Answer stakeholder objections'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Data shows 40% user drop-off at onboarding.', translation: 'Data shows 40% user drop-off at onboarding.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Introducing AI guide increases conversion.', translation: 'Introducing AI guide increases conversion.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Initial development takes 6 weeks.', translation: 'Initial development takes 6 weeks.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Expected ROI is 25% revenue boost.', translation: 'Expected ROI is 25% revenue boost.'),
      ],
    ),

    // B2-03
    LessonData(
      id: 'b2_debating_remote_vs_hybrid_work_policies',
      title: 'Debating Remote vs Hybrid Work Policies',
      description: 'Participate in corporate debate on office attendance rules.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Present remote pros, counter culture arguments, propose 2-day hybrid.',
      scenarioContext: 'You are Operations Director arguing for 4-day office mandate vs flexible remote work.',
      assistantRole: 'Operations Director',
      userRole: 'HR Manager',
      initialAssistantMessage: 'Our executive team wants to mandate 4 days in the office. What is your stance?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Present remote pros for talent retention', keywords: ['present', 'remote', 'pros', 'talent', 'retention'], examplePhrase: 'Present remote pros for talent retention'),
        ScenarioGoalItem(id: 'g2', text: 'Counter with culture in-person benefits', keywords: ['counter', 'culture', 'person', 'benefits'], examplePhrase: 'Counter with culture in-person benefits'),
        ScenarioGoalItem(id: 'g3', text: 'Propose compromised 2-day hybrid model', keywords: ['propose', 'compromised', 'day', 'hybrid', 'model'], examplePhrase: 'Propose compromised 2-day hybrid model'),
        ScenarioGoalItem(id: 'g4', text: 'Suggest measuring output over hours', keywords: ['suggest', 'measuring', 'output', 'over', 'hours'], examplePhrase: 'Suggest measuring output over hours'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Mandating 4 days risks losing key talent.', translation: 'Mandating 4 days risks losing key talent.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Studies prove remote workers maintain high productivity.', translation: 'Studies prove remote workers maintain high productivity.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Flexible hybrid offers best of both worlds.', translation: 'Flexible hybrid offers best of both worlds.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We should evaluate performance on deliverables.', translation: 'We should evaluate performance on deliverables.'),
      ],
    ),

    // B2-04
    LessonData(
      id: 'b2_salary_equity_package_negotiation',
      title: 'Salary & Equity Package Negotiation',
      description: 'Negotiate executive compensation, bonuses, and stock options.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Benchmark market rates, articulate value, secure written offer.',
      scenarioContext: 'You are VP of Talent offering executive role and negotiating base salary and equity.',
      assistantRole: 'VP of Talent',
      userRole: 'Senior Executive Candidate',
      initialAssistantMessage: 'We are excited to offer you the Director position at \$130,000 base salary.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Thank VP while benchmarking market value', keywords: ['thank', 'while', 'benchmarking', 'market', 'value'], examplePhrase: 'Thank VP while benchmarking market value'),
        ScenarioGoalItem(id: 'g2', text: 'Request higher base or stock options', keywords: ['request', 'higher', 'base', 'stock', 'options'], examplePhrase: 'Request higher base or stock options'),
        ScenarioGoalItem(id: 'g3', text: 'Inquire performance bonus criteria', keywords: ['inquire', 'performance', 'bonus', 'criteria'], examplePhrase: 'Inquire performance bonus criteria'),
        ScenarioGoalItem(id: 'g4', text: 'Secure agreed final terms in writing', keywords: ['secure', 'agreed', 'final', 'terms', 'writing'], examplePhrase: 'Secure agreed final terms in writing'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Thank you for the offer.', translation: 'Thank you for the offer.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Based on industry benchmarks, I seek \$145,000.', translation: 'Based on industry benchmarks, I seek \$145,000.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Can we structure a performance bonus trigger?', translation: 'Can we structure a performance bonus trigger?'),
        UsefulPhraseItem(id: 'p4', phrase: 'I look forward to the revised letter.', translation: 'I look forward to the revised letter.'),
      ],
    ),

    // B2-05
    LessonData(
      id: 'b2_expressing_nuanced_opinions_in_debates',
      title: 'Expressing Nuanced Opinions in Debates',
      description: 'Articulate balanced perspectives on complex social issues.',
      level: 'B2',
      category: 'history',
      interest: 'history',
      difficulty: 4,
      iconKey: 'school',
      mainObjective: 'State initial stance, acknowledge counter-arguments, propose compromise.',
      scenarioContext: 'You host a debate club evaluating whether public transit should be 100% free.',
      assistantRole: 'Debate Host',
      userRole: 'Participant',
      initialAssistantMessage: 'Today topic: Should public transit be completely free for all citizens in major cities?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'State initial nuanced position', keywords: ['state', 'initial', 'nuanced', 'position'], examplePhrase: 'State initial nuanced position'),
        ScenarioGoalItem(id: 'g2', text: 'Acknowledge economic funding arguments', keywords: ['acknowledge', 'economic', 'funding', 'arguments'], examplePhrase: 'Acknowledge economic funding arguments'),
        ScenarioGoalItem(id: 'g3', text: 'Highlight environmental/equality benefits', keywords: ['highlight', 'environmental', 'equality', 'benefits'], examplePhrase: 'Highlight environmental/equality benefits'),
        ScenarioGoalItem(id: 'g4', text: 'Conclude pragmatic funding solution', keywords: ['conclude', 'pragmatic', 'funding', 'solution'], examplePhrase: 'Conclude pragmatic funding solution'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'While free transit reduces emissions, funding requires tax changes.', translation: 'While free transit reduces emissions, funding requires tax changes.'),
        UsefulPhraseItem(id: 'p2', phrase: 'On one hand, it improves accessibility.', translation: 'On one hand, it improves accessibility.'),
        UsefulPhraseItem(id: 'p3', phrase: 'On the other hand, service quality matters.', translation: 'On the other hand, service quality matters.'),
        UsefulPhraseItem(id: 'p4', phrase: 'A subsidized tier system is most realistic.', translation: 'A subsidized tier system is most realistic.'),
      ],
    ),

    // B2-06
    LessonData(
      id: 'b2_modern_art_gallery_exhibition_critique',
      title: 'Modern Art Gallery Exhibition Critique',
      description: 'Analyze conceptual art pieces with a gallery curator.',
      level: 'B2',
      category: 'art',
      interest: 'art',
      difficulty: 4,
      iconKey: 'devices',
      mainObjective: 'Interpret symbolism of materials, lighting, and give verdict.',
      scenarioContext: 'You are a gallery curator discussing modern abstract steel installations.',
      assistantRole: 'Gallery Curator',
      userRole: 'Art Critic',
      initialAssistantMessage: 'What are your thoughts on this abstract installation crafted from recycled steel?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Interpret symbolic meaning of materials', keywords: ['interpret', 'symbolic', 'meaning', 'materials'], examplePhrase: 'Interpret symbolic meaning of materials'),
        ScenarioGoalItem(id: 'g2', text: 'Critique spatial arrangement and lighting', keywords: ['critique', 'spatial', 'arrangement', 'lighting'], examplePhrase: 'Critique spatial arrangement and lighting'),
        ScenarioGoalItem(id: 'g3', text: 'Contrast with traditional sculpture', keywords: ['contrast', 'traditional', 'sculpture'], examplePhrase: 'Contrast with traditional sculpture'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate overall artistic verdict', keywords: ['formulate', 'overall', 'artistic', 'verdict'], examplePhrase: 'Formulate overall artistic verdict'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Raw steel creates contrast with organic textures.', translation: 'Raw steel creates contrast with organic textures.'),
        UsefulPhraseItem(id: 'p2', phrase: 'It evokes industrial isolation.', translation: 'It evokes industrial isolation.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Lighting emphasizes shadows dramatically.', translation: 'Lighting emphasizes shadows dramatically.'),
        UsefulPhraseItem(id: 'p4', phrase: 'It challenges conventional definitions of form.', translation: 'It challenges conventional definitions of form.'),
      ],
    ),

    // B2-07
    LessonData(
      id: 'b2_managing_a_disappointed_key_client',
      title: 'Managing a Disappointed Key Client',
      description: 'De-escalate a major client crisis after a server outage.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Apologize sincerely, explain root cause, offer service credit.',
      scenarioContext: 'You are an enterprise client furious about a 2-hour software outage.',
      assistantRole: 'Enterprise Client',
      userRole: 'Account Director',
      initialAssistantMessage: 'Your system outage yesterday cost our company thousands of dollars! Explain yourself!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Acknowledge severity and express apology', keywords: ['acknowledge', 'severity', 'express', 'apology'], examplePhrase: 'Acknowledge severity and express apology'),
        ScenarioGoalItem(id: 'g2', text: 'Provide clear technical root cause', keywords: ['provide', 'clear', 'technical', 'root', 'cause'], examplePhrase: 'Provide clear technical root cause'),
        ScenarioGoalItem(id: 'g3', text: 'Detail immediate prevention measures', keywords: ['detail', 'immediate', 'prevention', 'measures'], examplePhrase: 'Detail immediate prevention measures'),
        ScenarioGoalItem(id: 'g4', text: 'Offer credit compensation for trust', keywords: ['offer', 'credit', 'compensation', 'trust'], examplePhrase: 'Offer credit compensation for trust'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I completely understand your frustration.', translation: 'I completely understand your frustration.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Downtime was caused by server hardware failure.', translation: 'Downtime was caused by server hardware failure.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We deployed redundant backups to prevent recurrence.', translation: 'We deployed redundant backups to prevent recurrence.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We are issuing a full service credit this month.', translation: 'We are issuing a full service credit this month.'),
      ],
    ),

    // B2-08
    LessonData(
      id: 'b2_requesting_a_project_deadline_extension',
      title: 'Requesting a Project Deadline Extension',
      description: 'Negotiate additional project timeline with demanding client.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Explain technical complexity, security risks, propose phased launch.',
      scenarioContext: 'You are a client sponsor expecting release delivery this Friday.',
      assistantRole: 'Client Sponsor',
      userRole: 'Project Lead',
      initialAssistantMessage: 'We expect the full software release this Friday as originally agreed in scope.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Explain unforeseen technical complexity', keywords: ['explain', 'unforeseen', 'technical', 'complexity'], examplePhrase: 'Explain unforeseen technical complexity'),
        ScenarioGoalItem(id: 'g2', text: 'Warn about risk to security if rushed', keywords: ['warn', 'risk', 'security', 'rushed'], examplePhrase: 'Warn about risk to security if rushed'),
        ScenarioGoalItem(id: 'g3', text: 'Propose phased delivery model', keywords: ['propose', 'phased', 'delivery', 'model'], examplePhrase: 'Propose phased delivery model'),
        ScenarioGoalItem(id: 'g4', text: 'Commit to firm milestone date', keywords: ['commit', 'firm', 'milestone', 'date'], examplePhrase: 'Commit to firm milestone date'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'To guarantee security, we need two extra weeks.', translation: 'To guarantee security, we need two extra weeks.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Rushing launch could compromise data integrity.', translation: 'Rushing launch could compromise data integrity.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We can release core features Friday and secondary later.', translation: 'We can release core features Friday and secondary later.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This ensures a flawless user experience.', translation: 'This ensures a flawless user experience.'),
      ],
    ),

    // B2-09
    LessonData(
      id: 'b2_debating_environmental_energy_policies',
      title: 'Debating Environmental Energy Policies',
      description: 'Discuss renewable energy transition strategies and economic impacts.',
      level: 'B2',
      category: 'science',
      interest: 'science',
      difficulty: 4,
      iconKey: 'explore',
      mainObjective: 'Analyze carbon tax models, grid stability, and corporate incentives.',
      scenarioContext: 'You are an environmental economist debating carbon tax vs green innovation subsidies.',
      assistantRole: 'Environmental Economist',
      userRole: 'Policy Researcher',
      initialAssistantMessage: 'Is a global carbon tax the most effective policy mechanism against climate change?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Evaluate economic impact carbon pricing', keywords: ['evaluate', 'economic', 'impact', 'carbon', 'pricing'], examplePhrase: 'Evaluate economic impact carbon pricing'),
        ScenarioGoalItem(id: 'g2', text: 'Discuss renewable grid transition challenges', keywords: ['discuss', 'renewable', 'grid', 'transition', 'challenges'], examplePhrase: 'Discuss renewable grid transition challenges'),
        ScenarioGoalItem(id: 'g3', text: 'Address opposition heavy industries', keywords: ['address', 'opposition', 'heavy', 'industries'], examplePhrase: 'Address opposition heavy industries'),
        ScenarioGoalItem(id: 'g4', text: 'Propose green innovation subsidies', keywords: ['propose', 'green', 'innovation', 'subsidies'], examplePhrase: 'Propose green innovation subsidies'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Carbon pricing creates financial incentive for clean energy.', translation: 'Carbon pricing creates financial incentive for clean energy.'),
        UsefulPhraseItem(id: 'p2', phrase: 'We must prevent energy price spikes for consumers.', translation: 'We must prevent energy price spikes for consumers.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Battery storage infrastructure is critical.', translation: 'Battery storage infrastructure is critical.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Subsidizing green tech yields economic benefits.', translation: 'Subsidizing green tech yields economic benefits.'),
      ],
    ),

    // B2-10
    LessonData(
      id: 'b2_pitching_a_startup_idea_to_vc_investors',
      title: 'Pitching a Startup Idea to VC Investors',
      description: 'Deliver a 3-minute pitch deck presentation to venture capitalists.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Articulate market size, traction metrics, SaaS model, funding ask.',
      scenarioContext: 'You are a venture capitalist evaluating EdTech SaaS traction and funding request.',
      assistantRole: 'Venture Capitalist',
      userRole: 'Startup Founder',
      initialAssistantMessage: 'You have 3 minutes to pitch your AI EdTech platform. Pitch away!',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Define market opportunity size', keywords: ['define', 'market', 'opportunity', 'size'], examplePhrase: 'Define market opportunity size'),
        ScenarioGoalItem(id: 'g2', text: 'Demonstrate current user growth metrics', keywords: ['demonstrate', 'current', 'user', 'growth', 'metrics'], examplePhrase: 'Demonstrate current user growth metrics'),
        ScenarioGoalItem(id: 'g3', text: 'Explain SaaS subscription model', keywords: ['explain', 'saas', 'subscription', 'model'], examplePhrase: 'Explain SaaS subscription model'),
        ScenarioGoalItem(id: 'g4', text: 'State explicit investment capital request', keywords: ['state', 'explicit', 'investment', 'capital', 'request'], examplePhrase: 'State explicit investment capital request'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'The language market is a \$60B global opportunity.', translation: 'The language market is a \$60B global opportunity.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Our AI voice tutor achieves 3x higher engagement.', translation: 'Our AI voice tutor achieves 3x higher engagement.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We operate a scalable Freemium B2C model.', translation: 'We operate a scalable Freemium B2C model.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We are raising \$1.5M to scale engineering.', translation: 'We are raising \$1.5M to scale engineering.'),
      ],
    ),

    // B2-11
    LessonData(
      id: 'b2_navigating_complex_government_bureaucracy',
      title: 'Navigating Complex Government Bureaucracy',
      description: 'Resolve visa or residency permit documentation roadblocks.',
      level: 'B2',
      category: 'history',
      interest: 'history',
      difficulty: 4,
      iconKey: 'school',
      mainObjective: 'Inquire exact missing documents, ask extension permit, resubmit.',
      scenarioContext: 'You are an immigration officer rejecting visa application due to translation certs.',
      assistantRole: 'Immigration Officer',
      userRole: 'Applicant',
      initialAssistantMessage: 'Your visa application is missing certified translations of tax records.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Request clarification on missing documents', keywords: ['request', 'clarification', 'missing', 'documents'], examplePhrase: 'Request clarification on missing documents'),
        ScenarioGoalItem(id: 'g2', text: 'Explain previous submission attempt', keywords: ['explain', 'previous', 'submission', 'attempt'], examplePhrase: 'Explain previous submission attempt'),
        ScenarioGoalItem(id: 'g3', text: 'Ask temporary extension permit', keywords: ['ask', 'temporary', 'extension', 'permit'], examplePhrase: 'Ask temporary extension permit'),
        ScenarioGoalItem(id: 'g4', text: 'Confirm fast-track resubmission', keywords: ['confirm', 'fast', 'track', 'resubmission'], examplePhrase: 'Confirm fast-track resubmission'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Which tax records require certified translation?', translation: 'Which tax records require certified translation?'),
        UsefulPhraseItem(id: 'p2', phrase: 'Can I submit digital copies online today?', translation: 'Can I submit digital copies online today?'),
        UsefulPhraseItem(id: 'p3', phrase: 'Is temporary processing extension possible?', translation: 'Is temporary processing extension possible?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you for clarifying exact steps.', translation: 'Thank you for clarifying exact steps.'),
      ],
    ),

    // B2-12
    LessonData(
      id: 'b2_discussing_ethics_in_artificial_intelligence',
      title: 'Discussing Ethics in Artificial Intelligence',
      description: 'Debate AI training bias, data privacy, and job automation.',
      level: 'B2',
      category: 'technology',
      interest: 'technology',
      difficulty: 4,
      iconKey: 'devices',
      mainObjective: 'Analyze training bias, corporate responsibility, and human oversight.',
      scenarioContext: 'You are an AI ethics researcher discussing algorithmic audit frameworks.',
      assistantRole: 'AI Ethics Researcher',
      userRole: 'Software Engineer',
      initialAssistantMessage: 'As AI models become autonomous, who should be held accountable for system errors?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Discuss training data bias in ML', keywords: ['discuss', 'training', 'data', 'bias'], examplePhrase: 'Discuss training data bias in ML'),
        ScenarioGoalItem(id: 'g2', text: 'Debate corporate responsibility vs developer', keywords: ['debate', 'corporate', 'responsibility', 'developer'], examplePhrase: 'Debate corporate responsibility vs developer'),
        ScenarioGoalItem(id: 'g3', text: 'Propose regulatory audit frameworks', keywords: ['propose', 'regulatory', 'audit', 'frameworks'], examplePhrase: 'Propose regulatory audit frameworks'),
        ScenarioGoalItem(id: 'g4', text: 'Emphasize human-in-loop oversight', keywords: ['emphasize', 'human', 'loop', 'oversight'], examplePhrase: 'Emphasize human-in-loop oversight'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'AI models reflect biases present in training data.', translation: 'AI models reflect biases present in training data.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Developers must implement transparent audit algorithms.', translation: 'Developers must implement transparent audit algorithms.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Regulatory frameworks should require safety testing.', translation: 'Regulatory frameworks should require safety testing.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Maintaining human oversight is vital.', translation: 'Maintaining human oversight is vital.'),
      ],
    ),

    // B2-13
    LessonData(
      id: 'b2_handling_team_conflict_as_a_manager',
      title: 'Handling Team Conflict as a Manager',
      description: 'Mediate an interpersonal dispute between two lead engineers.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Listen neutrally, reframe around shared goals, set code standards.',
      scenarioContext: 'You are an engineering manager listening to team conflict over code reviews.',
      assistantRole: 'Engineering Manager',
      userRole: 'Conflicting Engineer',
      initialAssistantMessage: 'Thanks for meeting privately. Things have been tense between you and Alex lately.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Listen to engineer perspective without bias', keywords: ['listen', 'engineer', 'perspective', 'without', 'bias'], examplePhrase: 'Listen to engineer perspective without bias'),
        ScenarioGoalItem(id: 'g2', text: 'Reframe conflict around shared goals', keywords: ['reframe', 'conflict', 'around', 'shared', 'goals'], examplePhrase: 'Reframe conflict around shared goals'),
        ScenarioGoalItem(id: 'g3', text: 'Establish objective coding guidelines', keywords: ['establish', 'objective', 'coding', 'guidelines'], examplePhrase: 'Establish objective coding guidelines'),
        ScenarioGoalItem(id: 'g4', text: 'Set follow-up check-in date', keywords: ['set', 'follow', 'check', 'date'], examplePhrase: 'Set follow-up check-in date'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I want to understand your perspective on code reviews.', translation: 'I want to understand your perspective on code reviews.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Both contributions are essential to team.', translation: 'Both contributions are essential to team.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Let us agree on objective coding guidelines.', translation: 'Let us agree on objective coding guidelines.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We will review progress in two weeks.', translation: 'We will review progress in two weeks.'),
      ],
    ),

    // B2-14
    LessonData(
      id: 'b2_handling_an_emergency_situation_abroad',
      title: 'Handling an Emergency Situation Abroad',
      description: 'Manage a stolen passport and emergency medical situation in foreign city.',
      level: 'B2',
      category: 'travel',
      interest: 'travel',
      difficulty: 4,
      iconKey: 'explore',
      mainObjective: 'Contact embassy, report theft, request emergency travel certificate.',
      scenarioContext: 'You are consular agent assisting citizen with stolen passport and travel cert.',
      assistantRole: 'Consular Agent',
      userRole: 'Stranded Traveler',
      initialAssistantMessage: 'Emergency Consular Services. Please state your urgency and location.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Report stolen passport and cards', keywords: ['report', 'stolen', 'passport', 'cards'], examplePhrase: 'Report stolen passport and cards'),
        ScenarioGoalItem(id: 'g2', text: 'Request emergency travel certificate', keywords: ['request', 'emergency', 'travel', 'certificate'], examplePhrase: 'Request emergency travel certificate'),
        ScenarioGoalItem(id: 'g3', text: 'Confirm proof of citizenship', keywords: ['confirm', 'proof', 'citizenship'], examplePhrase: 'Confirm proof of citizenship'),
        ScenarioGoalItem(id: 'g4', text: 'Coordinate emergency money transfer', keywords: ['coordinate', 'emergency', 'money', 'transfer'], examplePhrase: 'Coordinate emergency money transfer'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'My passport and wallet were stolen at station.', translation: 'My passport and wallet were stolen at station.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I need emergency travel document for tomorrow.', translation: 'I need emergency travel document for tomorrow.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I have digital copies of ID stored online.', translation: 'I have digital copies of ID stored online.'),
        UsefulPhraseItem(id: 'p4', phrase: 'What is fastest replacement procedure?', translation: 'What is fastest replacement procedure?'),
      ],
    ),

    // B2-15
    LessonData(
      id: 'b2_commercial_real_estate_investment_pitch',
      title: 'Commercial Real Estate Investment Pitch',
      description: 'Negotiate commercial office lease or property acquisition terms.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Analyze cap rate, tenant lease terms, ask tenant improvement money.',
      scenarioContext: 'You are a real estate broker presenting downtown commercial property return.',
      assistantRole: 'Real Estate Broker',
      userRole: 'Corporate Investor',
      initialAssistantMessage: 'This downtown commercial building yields a projected 8% annual return.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze cap rate and tenant lease terms', keywords: ['analyze', 'cap', 'rate', 'tenant', 'lease', 'terms'], examplePhrase: 'Analyze cap rate and tenant lease terms'),
        ScenarioGoalItem(id: 'g2', text: 'Inquire building maintenance history', keywords: ['inquire', 'building', 'maintenance', 'history'], examplePhrase: 'Inquire building maintenance history'),
        ScenarioGoalItem(id: 'g3', text: 'Negotiate tenant improvement allowance', keywords: ['negotiate', 'tenant', 'improvement', 'allowance'], examplePhrase: 'Negotiate tenant improvement allowance'),
        ScenarioGoalItem(id: 'g4', text: 'Propose counter-offer price', keywords: ['propose', 'counter', 'offer', 'price'], examplePhrase: 'Propose counter-offer price'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'What is current building occupancy rate?', translation: 'What is current building occupancy rate?'),
        UsefulPhraseItem(id: 'p2', phrase: 'We need \$50,000 tenant improvement allowance.', translation: 'We need \$50,000 tenant improvement allowance.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Requested price per square foot is above market.', translation: 'Requested price per square foot is above market.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We are prepared to submit letter of intent.', translation: 'We are prepared to submit letter of intent.'),
      ],
    ),

    // B2-16
    LessonData(
      id: 'b2_public_speaking_keynote_preparation',
      title: 'Public Speaking Keynote Preparation',
      description: 'Rehearse a conference keynote speech with communications coach.',
      level: 'B2',
      category: 'art',
      interest: 'art',
      difficulty: 4,
      iconKey: 'devices',
      mainObjective: 'Deliver memorable hook, control vocal pacing, integrate feedback.',
      scenarioContext: 'You are a speech coach evaluating opening story hook and vocal pacing.',
      assistantRole: 'Speech Coach',
      userRole: 'Keynote Speaker',
      initialAssistantMessage: 'Let us practice your keynote opening! Give me your first two minutes.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deliver memorable story opening hook', keywords: ['deliver', 'memorable', 'story', 'opening', 'hook'], examplePhrase: 'Deliver memorable story opening hook'),
        ScenarioGoalItem(id: 'g2', text: 'Control vocal pacing and strategic pauses', keywords: ['control', 'vocal', 'pacing', 'strategic', 'pauses'], examplePhrase: 'Control vocal pacing and strategic pauses'),
        ScenarioGoalItem(id: 'g3', text: 'Engage audience with questions', keywords: ['engage', 'audience', 'questions'], examplePhrase: 'Engage audience with questions'),
        ScenarioGoalItem(id: 'g4', text: 'Incorporate coach feedback', keywords: ['incorporate', 'coach', 'feedback'], examplePhrase: 'Incorporate coach feedback'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Imagine a world where language barriers vanish.', translation: 'Imagine a world where language barriers vanish.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I will slow down pace during key statistics.', translation: 'I will slow down pace during key statistics.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Does this slide transition feel natural?', translation: 'Does this slide transition feel natural?'),
        UsefulPhraseItem(id: 'p4', phrase: 'Thank you for constructive feedback.', translation: 'Thank you for constructive feedback.'),
      ],
    ),

    // B2-17
    LessonData(
      id: 'b2_corporate_crisis_mitigation_strategy',
      title: 'Corporate Crisis Mitigation Strategy',
      description: 'Formulate emergency response plan following data leak.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Outline containment, draft public PR statement, notify regulators.',
      scenarioContext: 'You are Chief Risk Officer drafting public PR statement after security incident.',
      assistantRole: 'Chief Risk Officer',
      userRole: 'Communications Lead',
      initialAssistantMessage: 'We just discovered a database breach affecting 50,000 customer records. What is our plan?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Outline technical containment steps', keywords: ['outline', 'technical', 'containment', 'steps'], examplePhrase: 'Outline technical containment steps'),
        ScenarioGoalItem(id: 'g2', text: 'Draft transparent public statement to users', keywords: ['draft', 'transparent', 'public', 'statement', 'users'], examplePhrase: 'Draft transparent public statement to users'),
        ScenarioGoalItem(id: 'g3', text: 'Notify data protection regulatory authorities', keywords: ['notify', 'data', 'protection', 'regulatory', 'authorities'], examplePhrase: 'Notify data protection regulatory authorities'),
        ScenarioGoalItem(id: 'g4', text: 'Set up dedicated support hotline', keywords: ['set', 'dedicated', 'support', 'hotline'], examplePhrase: 'Set up dedicated support hotline'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Top priority is securing compromised server immediately.', translation: 'Top priority is securing compromised server immediately.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Transparency is critical; notify users in 24 hrs.', translation: 'Transparency is critical; notify users in 24 hrs.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We will offer free credit monitoring.', translation: 'We will offer free credit monitoring.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us prepare official press release now.', translation: 'Let us prepare official press release now.'),
      ],
    ),

    // B2-18
    LessonData(
      id: 'b2_analyzing_media_bias_news_credibility',
      title: 'Analyzing Media Bias & News Credibility',
      description: 'Critique news articles for sensationalism, bias, and source verification.',
      level: 'B2',
      category: 'history',
      interest: 'history',
      difficulty: 4,
      iconKey: 'school',
      mainObjective: 'Identify biased language, evaluate sources, synthesize objective facts.',
      scenarioContext: 'You are a journalism professor analyzing sensationalist headlines and unverified sources.',
      assistantRole: 'Journalism Professor',
      userRole: 'Media Analyst',
      initialAssistantMessage: 'Look at these two articles reporting on the same political event. Notice the tone difference?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Identify biased language and sensational terms', keywords: ['identify', 'biased', 'language', 'sensational', 'terms'], examplePhrase: 'Identify biased language and sensational terms'),
        ScenarioGoalItem(id: 'g2', text: 'Evaluate reliability of cited sources', keywords: ['evaluate', 'reliability', 'cited', 'sources'], examplePhrase: 'Evaluate reliability of cited sources'),
        ScenarioGoalItem(id: 'g3', text: 'Discuss social media algorithm impact', keywords: ['discuss', 'social', 'media', 'algorithm', 'impact'], examplePhrase: 'Discuss social media algorithm impact'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate objective summary of facts', keywords: ['formulate', 'objective', 'summary', 'facts'], examplePhrase: 'Formulate objective summary of facts'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Article A uses emotionally loaded words.', translation: 'Article A uses emotionally loaded words.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Article B relies on unverified sources.', translation: 'Article B relies on unverified sources.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Outlets tailor coverage to subscriber demographics.', translation: 'Outlets tailor coverage to subscriber demographics.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Cross-referencing facts is essential.', translation: 'Cross-referencing facts is essential.'),
      ],
    ),

    // B2-19
    LessonData(
      id: 'b2_strategic_career_pivot_discussion',
      title: 'Strategic Career Pivot Discussion',
      description: 'Discuss changing career paths from traditional industry to tech startup.',
      level: 'B2',
      category: 'business',
      interest: 'business',
      difficulty: 4,
      iconKey: 'work',
      mainObjective: 'Highlight transferable skills, address skill gaps, plan portfolio.',
      scenarioContext: 'You are a career advisor guiding financial analyst into product management.',
      assistantRole: 'Career Advisor',
      userRole: 'Professional',
      initialAssistantMessage: 'Transitioning from finance into product management is ambitious! Let us plan it.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Highlight transferable analytical skills', keywords: ['highlight', 'transferable', 'analytical', 'skills'], examplePhrase: 'Highlight transferable analytical skills'),
        ScenarioGoalItem(id: 'g2', text: 'Identify critical skill gaps (UX, tech stack)', keywords: ['identify', 'critical', 'skill', 'gaps', 'tech', 'stack'], examplePhrase: 'Identify critical skill gaps (UX, tech stack)'),
        ScenarioGoalItem(id: 'g3', text: 'Plan bootcamp or project portfolio', keywords: ['plan', 'bootcamp', 'project', 'portfolio'], examplePhrase: 'Plan bootcamp or project portfolio'),
        ScenarioGoalItem(id: 'g4', text: 'Develop targeted networking approach', keywords: ['develop', 'targeted', 'networking', 'approach'], examplePhrase: 'Develop targeted networking approach'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Financial analysis translates well to product data.', translation: 'Financial analysis translates well to product data.'),
        UsefulPhraseItem(id: 'p2', phrase: 'I am completing product management certification.', translation: 'I am completing product management certification.'),
        UsefulPhraseItem(id: 'p3', phrase: 'I am building a portfolio of case studies.', translation: 'I am building a portfolio of case studies.'),
        UsefulPhraseItem(id: 'p4', phrase: 'How can I leverage my network for referrals?', translation: 'How can I leverage my network for referrals?'),
      ],
    ),

    // B2-20
    LessonData(
      id: 'b2_sports_performance_data_analytics',
      title: 'Sports Performance Data Analytics',
      description: 'Analyze athlete biomechanics and recovery data with sports scientist.',
      level: 'B2',
      category: 'sports',
      interest: 'sports',
      difficulty: 4,
      iconKey: 'people',
      mainObjective: 'Evaluate athlete workload metrics, prevent fatigue, optimize training.',
      scenarioContext: 'You are a sports scientist analyzing GPS tracking and heart rate variability data.',
      assistantRole: 'Sports Scientist',
      userRole: 'Head Coach',
      initialAssistantMessage: 'Our GPS tracking shows mid-fielders ran 12 kilometers yesterday with high fatigue indicators.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze heart rate variability metrics', keywords: ['analyze', 'heart', 'rate', 'variability', 'metrics'], examplePhrase: 'Analyze heart rate variability metrics'),
        ScenarioGoalItem(id: 'g2', text: 'Adjust training intensity workload', keywords: ['adjust', 'training', 'intensity', 'workload'], examplePhrase: 'Adjust training intensity workload'),
        ScenarioGoalItem(id: 'g3', text: 'Implement recovery cold-water protocols', keywords: ['implement', 'recovery', 'cold', 'water', 'protocols'], examplePhrase: 'Implement recovery cold-water protocols'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate match day lineup strategy', keywords: ['formulate', 'match', 'day', 'lineup', 'strategy'], examplePhrase: 'Formulate match day lineup strategy'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'High fatigue indicators suggest risk of muscle strain.', translation: 'High fatigue indicators suggest risk of muscle strain.'),
        UsefulPhraseItem(id: 'p2', phrase: 'We should reduce tactical session intensity today.', translation: 'We should reduce tactical session intensity today.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Cryotherapy acceleration aids recovery.', translation: 'Cryotherapy acceleration aids recovery.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We will rotation key players on Saturday.', translation: 'We will rotation key players on Saturday.'),
      ],
    ),


    // =========================================================================
    // NIVEL C1 — C1 — Avanzado (20 lecciones)
    // =========================================================================

    // C1-01
    LessonData(
      id: 'c1_contract_scope_royalty_negotiation',
      title: 'Contract Scope & Royalty Negotiation',
      description: 'Negotiate complex legal clauses, liability caps, and royalty percentages.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Propose liability cap equal to 12 months fee, IP transfer, royalty scale.',
      scenarioContext: 'You are Corporate General Counsel debating liability caps and IP ownership clauses.',
      assistantRole: 'General Counsel',
      userRole: 'Contract Negotiator',
      initialAssistantMessage: 'We cannot accept unlimited liability in section 4.2 of the software agreement.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Propose liability cap equal to 12 months fee', keywords: ['propose', 'liability', 'cap', 'equal', 'months', 'fee'], examplePhrase: 'Propose liability cap equal to 12 months fee'),
        ScenarioGoalItem(id: 'g2', text: 'Negotiate IP ownership transfer clauses', keywords: ['negotiate', 'ownership', 'transfer', 'clauses'], examplePhrase: 'Negotiate IP ownership transfer clauses'),
        ScenarioGoalItem(id: 'g3', text: 'Refine royalty percentage scale', keywords: ['refine', 'royalty', 'percentage', 'scale'], examplePhrase: 'Refine royalty percentage scale'),
        ScenarioGoalItem(id: 'g4', text: 'Finalize binding arbitration venue', keywords: ['finalize', 'binding', 'arbitration', 'venue'], examplePhrase: 'Finalize binding arbitration venue'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We propose capping liability at annual contract value.', translation: 'We propose capping liability at annual contract value.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Intellectual property remains our sole asset.', translation: 'Intellectual property remains our sole asset.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Royalty rates should tier based on volume.', translation: 'Royalty rates should tier based on volume.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Let us draft revised mutual indemnification language.', translation: 'Let us draft revised mutual indemnification language.'),
      ],
    ),

    // C1-02
    LessonData(
      id: 'c1_academic_debate_on_macroeconomic_policy',
      title: 'Academic Debate on Macroeconomic Policy',
      description: 'Debate fiscal policy, inflation control, and central bank interest rates.',
      level: 'C1',
      category: 'history',
      interest: 'history',
      difficulty: 5,
      iconKey: 'school',
      mainObjective: 'Deconstruct inflation triggers, evaluate rate hikes, cite historical stagflation.',
      scenarioContext: 'You are a macroeconomist analyzing quantitative easing vs rate hikes.',
      assistantRole: 'Macroeconomist',
      userRole: 'Policy Researcher',
      initialAssistantMessage: 'Should central banks prioritize aggressive inflation suppression over job growth?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct inflation triggers and supply factors', keywords: ['deconstruct', 'inflation', 'triggers', 'supply', 'factors'], examplePhrase: 'Deconstruct inflation triggers and supply factors'),
        ScenarioGoalItem(id: 'g2', text: 'Evaluate economic tradeoffs rate hikes', keywords: ['evaluate', 'economic', 'tradeoffs', 'rate', 'hikes'], examplePhrase: 'Evaluate economic tradeoffs rate hikes'),
        ScenarioGoalItem(id: 'g3', text: 'Cite historical stagflation precedents', keywords: ['cite', 'historical', 'stagflation', 'precedents'], examplePhrase: 'Cite historical stagflation precedents'),
        ScenarioGoalItem(id: 'g4', text: 'Synthesize balanced fiscal policy proposal', keywords: ['synthesize', 'balanced', 'fiscal', 'policy', 'proposal'], examplePhrase: 'Synthesize balanced fiscal policy proposal'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Aggressive rate increases risk recessionary spiral.', translation: 'Aggressive rate increases risk recessionary spiral.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Supply constraints require targeted fiscal intervention.', translation: 'Supply constraints require targeted fiscal intervention.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Historical precedent from 1970s illustrates costs.', translation: 'Historical precedent from 1970s illustrates costs.'),
        UsefulPhraseItem(id: 'p4', phrase: 'A dual-mandate approach is necessary.', translation: 'A dual-mandate approach is necessary.'),
      ],
    ),

    // C1-03
    LessonData(
      id: 'c1_executive_board_strategy_review',
      title: 'Executive Board Strategy Review',
      description: 'Defend annual strategic roadmap and capital allocation before board.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Present demographic growth, mitigate currency volatility, 3-year EBITDA.',
      scenarioContext: 'You are Board Chairman questioning CEO on \$10M expansion into emerging markets.',
      assistantRole: 'Board Chairman',
      userRole: 'Chief Executive Officer',
      initialAssistantMessage: 'CEO, explain why we should allocate \$10M into emerging Latin American markets.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Present demographic growth and market gap data', keywords: ['present', 'demographic', 'growth', 'market', 'gap', 'data'], examplePhrase: 'Present demographic growth and market gap data'),
        ScenarioGoalItem(id: 'g2', text: 'Address political and currency volatility risks', keywords: ['address', 'political', 'currency', 'volatility', 'risks'], examplePhrase: 'Address political and currency volatility risks'),
        ScenarioGoalItem(id: 'g3', text: 'Outline 3-year EBITDA profitability projection', keywords: ['outline', 'year', 'ebitda', 'profitability', 'projection'], examplePhrase: 'Outline 3-year EBITDA profitability projection'),
        ScenarioGoalItem(id: 'g4', text: 'Secure unanimous board approval', keywords: ['secure', 'unanimous', 'board', 'approval'], examplePhrase: 'Secure unanimous board approval'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Latin America represents our fastest growing user base.', translation: 'Latin America represents our fastest growing user base.'),
        UsefulPhraseItem(id: 'p2', phrase: 'We mitigated currency risk via local partnerships.', translation: 'We mitigated currency risk via local partnerships.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Financial modeling projects breakeven in 18 months.', translation: 'Financial modeling projects breakeven in 18 months.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I welcome board vote to approve expansion.', translation: 'I welcome board vote to approve expansion.'),
      ],
    ),

    // C1-04
    LessonData(
      id: 'c1_philosophical_ethics_ai_consciousness',
      title: 'Philosophical Ethics & AI Consciousness',
      description: 'Debate moral personhood, utilitarian ethics, and artificial sentience.',
      level: 'C1',
      category: 'history',
      interest: 'history',
      difficulty: 5,
      iconKey: 'school',
      mainObjective: 'Differentiate simulation vs phenomenology, apply Kantian/Utilitarian frameworks.',
      scenarioContext: 'You are an Ethics Professor evaluating functional simulation vs subjective qualia.',
      assistantRole: 'Ethics Professor',
      userRole: 'Philosopher',
      initialAssistantMessage: 'If an AI system simulates pain convincingly, does it possess moral status?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Differentiate simulation from subjective qualia', keywords: ['differentiate', 'simulation', 'subjective', 'qualia'], examplePhrase: 'Differentiate simulation from subjective qualia'),
        ScenarioGoalItem(id: 'g2', text: 'Apply Kantian vs Utilitarian framework to synthetic minds', keywords: ['apply', 'kantian', 'utilitarian', 'framework', 'synthetic', 'minds'], examplePhrase: 'Apply Kantian vs Utilitarian framework to synthetic minds'),
        ScenarioGoalItem(id: 'g3', text: 'Examine Turing test limits for moral agency', keywords: ['examine', 'turing', 'test', 'limits', 'moral', 'agency'], examplePhrase: 'Examine Turing test limits for moral agency'),
        ScenarioGoalItem(id: 'g4', text: 'Propose ethical safeguards for superintelligence', keywords: ['propose', 'ethical', 'safeguards', 'superintelligence'], examplePhrase: 'Propose ethical safeguards for superintelligence'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Simulated behavior does not imply subjective qualia.', translation: 'Simulated behavior does not imply subjective qualia.'),
        UsefulPhraseItem(id: 'p2', phrase: 'From utilitarian lens, causing distress is immoral.', translation: 'From utilitarian lens, causing distress is immoral.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Distinguish moral agency from moral patienthood.', translation: 'Distinguish moral agency from moral patienthood.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Ethical frameworks must adapt to synthetic cognition.', translation: 'Ethical frameworks must adapt to synthetic cognition.'),
      ],
    ),

    // C1-05
    LessonData(
      id: 'c1_literary_analysis_of_post_war_fiction',
      title: 'Literary Analysis of Post-War Fiction',
      description: 'Deconstruct narrative structure, existentialism, and motif symbolism.',
      level: 'C1',
      category: 'art',
      interest: 'art',
      difficulty: 5,
      iconKey: 'devices',
      mainObjective: 'Analyze linguistic symbolism, unreliable narrator, post-war existentialism.',
      scenarioContext: 'You are a Literature Professor analyzing unreliable narrators in post-war novels.',
      assistantRole: 'Literature Professor',
      userRole: 'Literary Scholar',
      initialAssistantMessage: 'How does the author utilize the motif of light to reflect existential dread?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze subtle linguistic symbolism and imagery', keywords: ['analyze', 'subtle', 'linguistic', 'symbolism', 'imagery'], examplePhrase: 'Analyze subtle linguistic symbolism and imagery'),
        ScenarioGoalItem(id: 'g2', text: 'Deconstruct unreliable narrator perspective', keywords: ['deconstruct', 'unreliable', 'narrator', 'perspective'], examplePhrase: 'Deconstruct unreliable narrator perspective'),
        ScenarioGoalItem(id: 'g3', text: 'Contextualize text within post-war existentialism', keywords: ['contextualize', 'text', 'within', 'post', 'war', 'existentialism'], examplePhrase: 'Contextualize text within post-war existentialism'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate original literary thesis', keywords: ['formulate', 'original', 'literary', 'thesis'], examplePhrase: 'Formulate original literary thesis'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'The motif of light paradoxically exposes barrenness.', translation: 'The motif of light paradoxically exposes barrenness.'),
        UsefulPhraseItem(id: 'p2', phrase: 'The unreliable narrative voice subverts expectation.', translation: 'The unreliable narrative voice subverts expectation.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Text reflects post-war disillusionment with authority.', translation: 'Text reflects post-war disillusionment with authority.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This choice reinforces the existential crisis.', translation: 'This choice reinforces the existential crisis.'),
      ],
    ),

    // C1-06
    LessonData(
      id: 'c1_cross_border_mergers_acquisitions_strategy',
      title: 'Cross-Border Mergers & Acquisitions Strategy',
      description: 'Analyze valuation, due diligence, and cultural integration in M&A.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Assess EBITDA multiples, antitrust regulatory clearance, cultural integration.',
      scenarioContext: 'You are M&A Managing Director evaluating a \$500M European competitor acquisition.',
      assistantRole: 'M&A Managing Director',
      userRole: 'Investment Banker',
      initialAssistantMessage: 'We are evaluating a \$500M acquisition of a European competitor. Thoughts on valuation?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Assess EBITDA acquisition multiple accuracy', keywords: ['assess', 'ebitda', 'acquisition', 'multiple', 'accuracy'], examplePhrase: 'Assess EBITDA acquisition multiple accuracy'),
        ScenarioGoalItem(id: 'g2', text: 'Identify antitrust regulatory compliance hurdles', keywords: ['identify', 'antitrust', 'regulatory', 'compliance', 'hurdles'], examplePhrase: 'Identify antitrust regulatory compliance hurdles'),
        ScenarioGoalItem(id: 'g3', text: 'Outline post-merger cultural integration plan', keywords: ['outline', 'post', 'merger', 'cultural', 'integration', 'plan'], examplePhrase: 'Outline post-merger cultural integration plan'),
        ScenarioGoalItem(id: 'g4', text: 'Deliver strategic recommendation', keywords: ['deliver', 'strategic', 'recommendation'], examplePhrase: 'Deliver strategic recommendation'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'The 12x EBITDA multiple is justified by synergies.', translation: 'The 12x EBITDA multiple is justified by synergies.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Antitrust scrutiny in Germany may require divestment.', translation: 'Antitrust scrutiny in Germany may require divestment.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Cultural integration between US and EU teams is critical.', translation: 'Cultural integration between US and EU teams is critical.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I recommend proceeding to definitive agreement.', translation: 'I recommend proceeding to definitive agreement.'),
      ],
    ),

    // C1-07
    LessonData(
      id: 'c1_geopolitical_energy_security_strategy',
      title: 'Geopolitical Energy Security Strategy',
      description: 'Analyze international energy independence, grid resilience, and risk.',
      level: 'C1',
      category: 'science',
      interest: 'science',
      difficulty: 5,
      iconKey: 'explore',
      mainObjective: 'Analyze energy dependency, nuclear baseline, rare earth minerals.',
      scenarioContext: 'You are Energy Security Analyst evaluating LNG supply chains and nuclear power.',
      assistantRole: 'Energy Security Analyst',
      userRole: 'Diplomatic Advisor',
      initialAssistantMessage: 'How can European nations maintain grid stability while phasing out fossil fuels?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze energy import dependency vulnerabilities', keywords: ['analyze', 'energy', 'import', 'dependency', 'vulnerabilities'], examplePhrase: 'Analyze energy import dependency vulnerabilities'),
        ScenarioGoalItem(id: 'g2', text: 'Assess nuclear energy as baseline transition source', keywords: ['assess', 'nuclear', 'energy', 'baseline', 'transition', 'source'], examplePhrase: 'Assess nuclear energy as baseline transition source'),
        ScenarioGoalItem(id: 'g3', text: 'Evaluate supply chain security rare earth minerals', keywords: ['evaluate', 'supply', 'chain', 'security', 'rare', 'earth'], examplePhrase: 'Evaluate supply chain security rare earth minerals'),
        ScenarioGoalItem(id: 'g4', text: 'Propose resilient multi-lateral energy treaty', keywords: ['propose', 'resilient', 'multi', 'lateral', 'energy', 'treaty'], examplePhrase: 'Propose resilient multi-lateral energy treaty'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Diversifying energy import routes is paramount.', translation: 'Diversifying energy import routes is paramount.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Nuclear power provides essential baseload power.', translation: 'Nuclear power provides essential baseload power.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Critical mineral supply chains represent new bottleneck.', translation: 'Critical mineral supply chains represent new bottleneck.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Regional energy interconnections enhance grid resilience.', translation: 'Regional energy interconnections enhance grid resilience.'),
      ],
    ),

    // C1-08
    LessonData(
      id: 'c1_intellectual_property_litigation_settlement',
      title: 'Intellectual Property Litigation Settlement',
      description: 'Negotiate patent infringement settlement and cross-licensing terms.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Evaluate invalidity defense counter-claims, lost profit calculations, cross-license.',
      scenarioContext: 'You are Lead IP Counsel evaluating a \$2M settlement offer for patent infringement.',
      assistantRole: 'IP Litigation Counsel',
      userRole: 'Lead Patent Attorney',
      initialAssistantMessage: 'The opposing counsel offered a \$2M settlement for patent infringement. Do we take it?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Evaluate strength of invalidity defense counter-claim', keywords: ['evaluate', 'strength', 'invalidity', 'defense', 'counter', 'claim'], examplePhrase: 'Evaluate strength of invalidity defense counter-claim'),
        ScenarioGoalItem(id: 'g2', text: 'Calculate lost profits vs reasonable royalty damages', keywords: ['calculate', 'lost', 'profits', 'reasonable', 'royalty', 'damages'], examplePhrase: 'Calculate lost profits vs reasonable royalty damages'),
        ScenarioGoalItem(id: 'g3', text: 'Draft mutual cross-licensing agreement terms', keywords: ['draft', 'mutual', 'cross', 'licensing', 'agreement', 'terms'], examplePhrase: 'Draft mutual cross-licensing agreement terms'),
        ScenarioGoalItem(id: 'g4', text: 'Finalize global settlement terms', keywords: ['finalize', 'global', 'settlement', 'terms'], examplePhrase: 'Finalize global settlement terms'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Offered settlement fails to compensate lost market share.', translation: 'Offered settlement fails to compensate lost market share.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Our invalidity arguments against patent are strong.', translation: 'Our invalidity arguments against patent are strong.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Propose mutual cross-licensing with \$5M lump sum.', translation: 'Propose mutual cross-licensing with \$5M lump sum.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This protects our core product line permanently.', translation: 'This protects our core product line permanently.'),
      ],
    ),

    // C1-09
    LessonData(
      id: 'c1_complex_medical_case_consultation',
      title: 'Complex Medical Case Consultation',
      description: 'Analyze multi-system autoimmune disorder diagnostics with medical board.',
      level: 'C1',
      category: 'science',
      interest: 'science',
      difficulty: 5,
      iconKey: 'explore',
      mainObjective: 'Analyze laboratory biomarker panels, rule out infections, biological therapy.',
      scenarioContext: 'You are Chief of Medicine evaluating systemic vasculitis and renal lab panels.',
      assistantRole: 'Chief of Medicine',
      userRole: 'Specialist Physician',
      initialAssistantMessage: 'The patient presents with systemic vasculitis, renal failure, and persistent fever.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze complex laboratory biomarker panels', keywords: ['analyze', 'complex', 'laboratory', 'biomarker', 'panels'], examplePhrase: 'Analyze complex laboratory biomarker panels'),
        ScenarioGoalItem(id: 'g2', text: 'Rule out atypical infectious etiologies', keywords: ['rule', 'out', 'atypical', 'infectious', 'etiologies'], examplePhrase: 'Rule out atypical infectious etiologies'),
        ScenarioGoalItem(id: 'g3', text: 'Formulate targeted biological therapy plan', keywords: ['formulate', 'targeted', 'biological', 'therapy', 'plan'], examplePhrase: 'Formulate targeted biological therapy plan'),
        ScenarioGoalItem(id: 'g4', text: 'Discuss prognosis and monitoring protocol', keywords: ['discuss', 'prognosis', 'monitoring', 'protocol'], examplePhrase: 'Discuss prognosis and monitoring protocol'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Elevated ANCA titers point toward vasculitis.', translation: 'Elevated ANCA titers point toward vasculitis.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Rule out fungal infection before high-dose steroids.', translation: 'Rule out fungal infection before high-dose steroids.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Start pulse cyclophosphamide with biologics.', translation: 'Start pulse cyclophosphamide with biologics.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Close monitoring of renal function is essential.', translation: 'Close monitoring of renal function is essential.'),
      ],
    ),

    // C1-10
    LessonData(
      id: 'c1_distributed_cloud_systems_architecture_review',
      title: 'Distributed Cloud Systems Architecture Review',
      description: 'Defend global high-availability, eventual consistency, and fault tolerance.',
      level: 'C1',
      category: 'technology',
      interest: 'technology',
      difficulty: 5,
      iconKey: 'devices',
      mainObjective: 'Deconstruct CAP theorem trade-offs, Raft consensus, 200ms failover.',
      scenarioContext: 'You are Principal Systems Architect evaluating CAP theorem trade-offs and raft consensus.',
      assistantRole: 'Principal Systems Architect',
      userRole: 'Infrastructure Engineer',
      initialAssistantMessage: 'Explain how your system maintains low latency while guaranteeing consistency across 3 continents.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct CAP theorem trade-offs in distributed stores', keywords: ['deconstruct', 'cap', 'theorem', 'trade', 'offs', 'distributed'], examplePhrase: 'Deconstruct CAP theorem trade-offs in distributed stores'),
        ScenarioGoalItem(id: 'g2', text: 'Explain Raft/Paxos consensus implementation', keywords: ['explain', 'raft', 'paxos', 'consensus', 'implementation'], examplePhrase: 'Explain Raft/Paxos consensus implementation'),
        ScenarioGoalItem(id: 'g3', text: 'Analyze disaster recovery multi-region failover', keywords: ['analyze', 'disaster', 'recovery', 'multi', 'region', 'failover'], examplePhrase: 'Analyze disaster recovery multi-region failover'),
        ScenarioGoalItem(id: 'g4', text: 'Defend architectural design decisions', keywords: ['defend', 'architectural', 'design', 'decisions'], examplePhrase: 'Defend architectural design decisions'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We sacrificed strict consistency for availability via CRDTs.', translation: 'We sacrificed strict consistency for availability via CRDTs.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Edge caching with regional leaders minimizes latency.', translation: 'Edge caching with regional leaders minimizes latency.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Automated failover completes in under 200ms.', translation: 'Automated failover completes in under 200ms.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Architecture handles 100k requests/sec gracefully.', translation: 'Architecture handles 100k requests/sec gracefully.'),
      ],
    ),

    // C1-11
    LessonData(
      id: 'c1_international_diplomatic_protocol_crisis',
      title: 'International Diplomatic Protocol & Crisis',
      description: 'Manage a delicate diplomatic incident between two sovereign nations.',
      level: 'C1',
      category: 'history',
      interest: 'history',
      difficulty: 5,
      iconKey: 'school',
      mainObjective: 'Draft diplomatic note, maintain back-channel comms, multilateral UN pressure.',
      scenarioContext: 'You are Foreign Affairs Minister drafting formal note of protest over territorial waters.',
      assistantRole: 'Foreign Minister',
      userRole: 'Senior Diplomat',
      initialAssistantMessage: 'A foreign naval vessel entered restricted territorial waters. How do we respond?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Draft formal diplomatic note of protest', keywords: ['draft', 'formal', 'diplomatic', 'note', 'protest'], examplePhrase: 'Draft formal diplomatic note of protest'),
        ScenarioGoalItem(id: 'g2', text: 'Maintain open channels to avoid escalation', keywords: ['maintain', 'open', 'channels', 'avoid', 'escalation'], examplePhrase: 'Maintain open channels to avoid escalation'),
        ScenarioGoalItem(id: 'g3', text: 'Coordinate multilateral pressure via UN Security Council', keywords: ['coordinate', 'multilateral', 'pressure', 'via', 'security', 'council'], examplePhrase: 'Coordinate multilateral pressure via UN Security Council'),
        ScenarioGoalItem(id: 'g4', text: 'Achieve peaceful diplomatic resolution', keywords: ['achieve', 'peaceful', 'diplomatic', 'resolution'], examplePhrase: 'Achieve peaceful diplomatic resolution'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We must issue formal note expressing grave concern.', translation: 'We must issue formal note expressing grave concern.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Back-channel comms prevent public escalation.', translation: 'Back-channel comms prevent public escalation.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Request emergency briefing at security council.', translation: 'Request emergency briefing at security council.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Priority is sovereign integrity via diplomacy.', translation: 'Priority is sovereign integrity via diplomacy.'),
      ],
    ),

    // C1-12
    LessonData(
      id: 'c1_crisis_public_relations_press_conference',
      title: 'Crisis Public Relations Press Conference',
      description: 'Face aggressive journalists during live corporate scandal press conference.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Deliver calm factual statement, refuse speculation, emphasize safety.',
      scenarioContext: 'You are an investigative reporter grilling spokesperson on executive stock sales before recall.',
      assistantRole: 'Investigative Reporter',
      userRole: 'Corporate Spokesperson',
      initialAssistantMessage: 'Is it true that executives sold shares days before the product safety recall?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deliver calm transparent statement of facts', keywords: ['deliver', 'calm', 'transparent', 'statement', 'facts'], examplePhrase: 'Deliver calm transparent statement of facts'),
        ScenarioGoalItem(id: 'g2', text: 'Refuse to speculate on legal investigations', keywords: ['refuse', 'speculate', 'legal', 'investigations'], examplePhrase: 'Refuse to speculate on legal investigations'),
        ScenarioGoalItem(id: 'g3', text: 'Reiterate company commitment to safety', keywords: ['reiterate', 'company', 'commitment', 'safety'], examplePhrase: 'Reiterate company commitment to safety'),
        ScenarioGoalItem(id: 'g4', text: 'Control high-pressure interview environment', keywords: ['control', 'high', 'pressure', 'interview', 'environment'], examplePhrase: 'Control high-pressure interview environment'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Executive share transactions followed 10b5-1 trading plans.', translation: 'Executive share transactions followed 10b5-1 trading plans.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Primary concern is ensuring complete customer safety.', translation: 'Primary concern is ensuring complete customer safety.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We cooperate fully with independent auditors.', translation: 'We cooperate fully with independent auditors.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I have time for two more questions from floor.', translation: 'I have time for two more questions from floor.'),
      ],
    ),

    // C1-13
    LessonData(
      id: 'c1_venture_capital_due_diligence_defense',
      title: 'Venture Capital Due Diligence Defense',
      description: 'Defend startup unit economics, CAC, LTV, and churn before VC partners.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Deconstruct CAC increase, highlight 4:1 LTV:CAC, net revenue retention.',
      scenarioContext: 'You are VC General Partner questioning 30% CAC increase in enterprise segment.',
      assistantRole: 'VC General Partner',
      userRole: 'Founder CEO',
      initialAssistantMessage: 'Your customer acquisition cost rose 30% last quarter. How is that sustainable?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct CAC increase due to enterprise channel investment', keywords: ['deconstruct', 'cac', 'increase', 'due', 'enterprise', 'channel'], examplePhrase: 'Deconstruct CAC increase due to enterprise channel investment'),
        ScenarioGoalItem(id: 'g2', text: 'Highlight 4:1 LTV to CAC ratio', keywords: ['highlight', 'ltv', 'cac', 'ratio'], examplePhrase: 'Highlight 4:1 LTV to CAC ratio'),
        ScenarioGoalItem(id: 'g3', text: 'Demonstrate negative net revenue churn', keywords: ['demonstrate', 'negative', 'net', 'revenue', 'churn'], examplePhrase: 'Demonstrate negative net revenue churn'),
        ScenarioGoalItem(id: 'g4', text: 'Secure follow-on funding commitment', keywords: ['secure', 'follow', 'funding', 'commitment'], examplePhrase: 'Secure follow-on funding commitment'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'CAC rise reflects investment in high-converting enterprise channels.', translation: 'CAC rise reflects investment in high-converting enterprise channels.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Net revenue retention stands at 135%.', translation: 'Net revenue retention stands at 135%.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Enterprise customers show 5x higher lifetime value.', translation: 'Enterprise customers show 5x higher lifetime value.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Unit economic profile positions us for rapid scale.', translation: 'Unit economic profile positions us for rapid scale.'),
      ],
    ),

    // C1-14
    LessonData(
      id: 'c1_global_climate_policy_accord_negotiations',
      title: 'Global Climate Policy Accord Negotiations',
      description: 'Negotiate carbon reduction targets between developed/developing nations.',
      level: 'C1',
      category: 'science',
      interest: 'science',
      difficulty: 5,
      iconKey: 'explore',
      mainObjective: 'Acknowledge historical responsibility, tech transfer fund, tiered deadlines.',
      scenarioContext: 'You are climate delegate from developing nation demanding tech transfer fund.',
      assistantRole: 'Developing Nation Delegate',
      userRole: 'Developed Nation Delegate',
      initialAssistantMessage: 'Developing economies cannot sacrifice industrial growth without financial compensation.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Acknowledge historical carbon responsibility', keywords: ['acknowledge', 'historical', 'carbon', 'responsibility'], examplePhrase: 'Acknowledge historical carbon responsibility'),
        ScenarioGoalItem(id: 'g2', text: 'Propose green tech transfer funding mechanism', keywords: ['propose', 'green', 'tech', 'transfer', 'funding', 'mechanism'], examplePhrase: 'Propose green tech transfer funding mechanism'),
        ScenarioGoalItem(id: 'g3', text: 'Set realistic tiered carbon reduction deadlines', keywords: ['set', 'realistic', 'tiered', 'carbon', 'reduction', 'deadlines'], examplePhrase: 'Set realistic tiered carbon reduction deadlines'),
        ScenarioGoalItem(id: 'g4', text: 'Finalize binding global treaty consensus', keywords: ['finalize', 'binding', 'global', 'treaty', 'consensus'], examplePhrase: 'Finalize binding global treaty consensus'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Historical emitters must lead funding contributions.', translation: 'Historical emitters must lead funding contributions.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Green technology transfer fund accelerates transition.', translation: 'Green technology transfer fund accelerates transition.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Tiered compliance schedules account for capabilities.', translation: 'Tiered compliance schedules account for capabilities.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This compromise aligns action with ecological urgency.', translation: 'This compromise aligns action with ecological urgency.'),
      ],
    ),

    // C1-15
    LessonData(
      id: 'c1_enterprise_cloud_security_audit_review',
      title: 'Enterprise Cloud Security Audit Review',
      description: 'Review zero-trust network architecture and IAM privilege escalation risks.',
      level: 'C1',
      category: 'technology',
      interest: 'technology',
      difficulty: 5,
      iconKey: 'devices',
      mainObjective: 'Analyze root cause IAM misconfigurations, zero-trust, short-lived tokens.',
      scenarioContext: 'You are Chief Information Security Officer reviewing penetration audit findings.',
      assistantRole: 'CISO',
      userRole: 'Lead Security Auditor',
      initialAssistantMessage: 'Our audit uncovered potential IAM privilege escalation paths in production.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze root cause IAM policy misconfigurations', keywords: ['analyze', 'root', 'cause', 'iam', 'policy', 'misconfigurations'], examplePhrase: 'Analyze root cause IAM policy misconfigurations'),
        ScenarioGoalItem(id: 'g2', text: 'Enforce strict zero-trust least privilege', keywords: ['enforce', 'strict', 'zero', 'trust', 'least', 'privilege'], examplePhrase: 'Enforce strict zero-trust least privilege'),
        ScenarioGoalItem(id: 'g3', text: 'Mandate automated short-lived token rotation', keywords: ['mandate', 'automated', 'short', 'lived', 'token', 'rotation'], examplePhrase: 'Mandate automated short-lived token rotation'),
        ScenarioGoalItem(id: 'g4', text: 'Approve security remediation timeline', keywords: ['approve', 'security', 'remediation', 'timeline'], examplePhrase: 'Approve security remediation timeline'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We are revoking overly permissive IAM wildcard policies.', translation: 'We are revoking overly permissive IAM wildcard policies.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Zero-trust ensures micro-segmentation across clusters.', translation: 'Zero-trust ensures micro-segmentation across clusters.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Automated short-lived credentials eliminate risks.', translation: 'Automated short-lived credentials eliminate risks.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Full remediation and re-testing concludes in 48 hours.', translation: 'Full remediation and re-testing concludes in 48 hours.'),
      ],
    ),

    // C1-16
    LessonData(
      id: 'c1_corporate_governance_ethics_investigation',
      title: 'Corporate Governance & Ethics Investigation',
      description: 'Lead an internal investigation into financial accounting irregularities.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Examine forensic audit evidence, breach of GAAP, recommend suspension.',
      scenarioContext: 'You are Internal Audit Director investigating whistleblower revenue recognition claims.',
      assistantRole: 'Internal Audit Director',
      userRole: 'Special Counsel',
      initialAssistantMessage: 'We reviewed the revenue recognition entries flagged by the internal whistleblower.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Examine forensic audit evidence objectively', keywords: ['examine', 'forensic', 'audit', 'evidence', 'objectively'], examplePhrase: 'Examine forensic audit evidence objectively'),
        ScenarioGoalItem(id: 'g2', text: 'Identify breaches of accounting principles (GAAP)', keywords: ['identify', 'breaches', 'accounting', 'principles', 'gaap'], examplePhrase: 'Identify breaches of accounting principles (GAAP)'),
        ScenarioGoalItem(id: 'g3', text: 'Recommend executive disciplinary/legal measures', keywords: ['recommend', 'executive', 'disciplinary', 'legal', 'measures'], examplePhrase: 'Recommend executive disciplinary/legal measures'),
        ScenarioGoalItem(id: 'g4', text: 'Report findings to board audit committee', keywords: ['report', 'findings', 'board', 'audit', 'committee'], examplePhrase: 'Report findings to board audit committee'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Forensic auditing confirms premature revenue recognition in Q3.', translation: 'Forensic auditing confirms premature revenue recognition in Q3.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Practice violates ethics guidelines and GAAP standards.', translation: 'Practice violates ethics guidelines and GAAP standards.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We recommend earnings restatement and executive suspension.', translation: 'We recommend earnings restatement and executive suspension.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Full report will be presented to board tomorrow.', translation: 'Full report will be presented to board tomorrow.'),
      ],
    ),

    // C1-17
    LessonData(
      id: 'c1_higher_education_structural_reform_debate',
      title: 'Higher Education Structural Reform Debate',
      description: 'Debate university tenure, research funding allocation, and digital models.',
      level: 'C1',
      category: 'history',
      interest: 'history',
      difficulty: 5,
      iconKey: 'school',
      mainObjective: 'Defend academic freedom, address tuition constraints, propose hybrid track.',
      scenarioContext: 'You are Faculty Senate Chair defending tenure against clinical teaching tracks.',
      assistantRole: 'Faculty Senate Chair',
      userRole: 'University President',
      initialAssistantMessage: 'Should our university phase out traditional tenure in favor of clinical teaching tracks?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Defend academic freedom and tenure protections', keywords: ['defend', 'academic', 'freedom', 'tenure', 'protections'], examplePhrase: 'Defend academic freedom and tenure protections'),
        ScenarioGoalItem(id: 'g2', text: 'Acknowledge tuition cost constraints', keywords: ['acknowledge', 'tuition', 'cost', 'constraints'], examplePhrase: 'Acknowledge tuition cost constraints'),
        ScenarioGoalItem(id: 'g3', text: 'Propose hybrid faculty appointment structure', keywords: ['propose', 'hybrid', 'faculty', 'appointment', 'structure'], examplePhrase: 'Propose hybrid faculty appointment structure'),
        ScenarioGoalItem(id: 'g4', text: 'Balance research excellence with teaching quality', keywords: ['balance', 'research', 'excellence', 'teaching', 'quality'], examplePhrase: 'Balance research excellence with teaching quality'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Tenure is essential for protecting unconstrained research.', translation: 'Tenure is essential for protecting unconstrained research.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Rising tuition costs demand administrative flexibility.', translation: 'Rising tuition costs demand administrative flexibility.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Dual track honoring research and teaching is optimal.', translation: 'Dual track honoring research and teaching is optimal.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Preserving educational rigor remains our mission.', translation: 'Preserving educational rigor remains our mission.'),
      ],
    ),

    // C1-18
    LessonData(
      id: 'c1_scientific_peer_review_defense',
      title: 'Scientific Peer Review Defense',
      description: 'Defend novel genomic sequencing methodology against reviewer critiques.',
      level: 'C1',
      category: 'science',
      interest: 'science',
      difficulty: 5,
      iconKey: 'explore',
      mainObjective: 'Rebut reviewer critique, Monte Carlo simulations, statistical power >0.95.',
      scenarioContext: 'You are a journal editor reviewing author responses to statistical confidence intervals.',
      assistantRole: 'Journal Editor',
      userRole: 'Principal Investigator',
      initialAssistantMessage: 'Reviewer 2 questions your statistical confidence intervals in section 3.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Rebut reviewer critique with supplementary data', keywords: ['rebut', 'reviewer', 'critique', 'supplementary', 'data'], examplePhrase: 'Rebut reviewer critique with supplementary data'),
        ScenarioGoalItem(id: 'g2', text: 'Demonstrate control group methodologies', keywords: ['demonstrate', 'control', 'group', 'methodologies'], examplePhrase: 'Demonstrate control group methodologies'),
        ScenarioGoalItem(id: 'g3', text: 'Validate statistical power and p-value robustness', keywords: ['validate', 'statistical', 'power', 'value', 'robustness'], examplePhrase: 'Validate statistical power and p-value robustness'),
        ScenarioGoalItem(id: 'g4', text: 'Secure paper publication acceptance', keywords: ['secure', 'paper', 'publication', 'acceptance'], examplePhrase: 'Secure paper publication acceptance'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We conducted Monte Carlo simulations for confidence intervals.', translation: 'We conducted Monte Carlo simulations for confidence intervals.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Control group selection accounted for confounding variables.', translation: 'Control group selection accounted for confounding variables.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Statistical power exceeds 0.95, proving reproducibility.', translation: 'Statistical power exceeds 0.95, proving reproducibility.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We updated manuscript addressing all observations.', translation: 'We updated manuscript addressing all observations.'),
      ],
    ),

    // C1-19
    LessonData(
      id: 'c1_global_franchise_expansion_strategy',
      title: 'Global Franchise Expansion Strategy',
      description: 'Negotiate master franchise agreement terms for South American rollout.',
      level: 'C1',
      category: 'business',
      interest: 'business',
      difficulty: 5,
      iconKey: 'work',
      mainObjective: 'Define store rollout schedule, supply chain standards, 4% royalty rate.',
      scenarioContext: 'You are Global Brand Director awarding master franchise rights for 30 locations.',
      assistantRole: 'Global Brand Director',
      userRole: 'Master Franchisee',
      initialAssistantMessage: 'We are ready to award master franchise rights for South America. Let us discuss terms.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Define territory exclusivity and rollout schedule', keywords: ['define', 'territory', 'exclusivity', 'rollout', 'schedule'], examplePhrase: 'Define territory exclusivity and rollout schedule'),
        ScenarioGoalItem(id: 'g2', text: 'Establish supply chain sourcing quality benchmarks', keywords: ['establish', 'supply', 'chain', 'sourcing', 'quality', 'benchmarks'], examplePhrase: 'Establish supply chain sourcing quality benchmarks'),
        ScenarioGoalItem(id: 'g3', text: 'Negotiate franchise fee and royalty percentage', keywords: ['negotiate', 'franchise', 'fee', 'royalty', 'percentage'], examplePhrase: 'Negotiate franchise fee and royalty percentage'),
        ScenarioGoalItem(id: 'g4', text: 'Finalize binding multi-unit agreement', keywords: ['finalize', 'binding', 'multi', 'unit', 'agreement'], examplePhrase: 'Finalize binding multi-unit agreement'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We commit to opening 30 locations over 5 years.', translation: 'We commit to opening 30 locations over 5 years.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Local sourcing must meet global quality assurance.', translation: 'Local sourcing must meet global quality assurance.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We propose 4% ongoing royalty rate with co-op marketing.', translation: 'We propose 4% ongoing royalty rate with co-op marketing.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This agreement unlocks massive regional growth.', translation: 'This agreement unlocks massive regional growth.'),
      ],
    ),

    // C1-20
    LessonData(
      id: 'c1_bioethics_of_human_gene_editing',
      title: 'Bioethics of Human Gene Editing',
      description: 'Debate regulatory policy on germline CRISPR gene editing technologies.',
      level: 'C1',
      category: 'science',
      interest: 'science',
      difficulty: 5,
      iconKey: 'explore',
      mainObjective: 'Evaluate therapeutic potential, address germline consent, propose global body.',
      scenarioContext: 'You are a bioethicist evaluating therapeutic benefits vs eugenic risks of CRISPR.',
      assistantRole: 'Bioethicist',
      userRole: 'Genetic Researcher',
      initialAssistantMessage: 'Should germline editing be banned globally or restricted to fatal genetic diseases?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Evaluate clinical therapeutic potential monogenic disease', keywords: ['evaluate', 'clinical', 'therapeutic', 'potential', 'monogenic', 'disease'], examplePhrase: 'Evaluate clinical therapeutic potential monogenic disease'),
        ScenarioGoalItem(id: 'g2', text: 'Address slippery slope risks toward enhancement', keywords: ['address', 'slippery', 'slope', 'risks', 'toward', 'enhancement'], examplePhrase: 'Address slippery slope risks toward enhancement'),
        ScenarioGoalItem(id: 'g3', text: 'Propose international oversight bodies/moratoriums', keywords: ['propose', 'international', 'oversight', 'bodies', 'moratoriums'], examplePhrase: 'Propose international oversight bodies/moratoriums'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate balanced bioethical regulatory framework', keywords: ['formulate', 'balanced', 'bioethical', 'regulatory', 'framework'], examplePhrase: 'Formulate balanced bioethical regulatory framework'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'CRISPR offers cures for hereditary diseases like sickle cell.', translation: 'CRISPR offers cures for hereditary diseases like sickle cell.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Germline alterations permanently affect future generations.', translation: 'Germline alterations permanently affect future generations.'),
        UsefulPhraseItem(id: 'p3', phrase: 'An international regulatory body must oversee trial protocols.', translation: 'An international regulatory body must oversee trial protocols.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We must distinguish therapy from non-essential enhancement.', translation: 'We must distinguish therapy from non-essential enhancement.'),
      ],
    ),


    // =========================================================================
    // NIVEL C2 — C2 — Maestría (20 lecciones)
    // =========================================================================

    // C2-01
    LessonData(
      id: 'c2_diplomatic_summit_on_multilateral_treaties',
      title: 'Diplomatic Summit on Multilateral Treaties',
      description: 'Engage in high-level diplomacy to negotiate international sovereignty accords.',
      level: 'C2',
      category: 'history',
      interest: 'history',
      difficulty: 6,
      iconKey: 'school',
      mainObjective: 'Employ diplomatic tact, strategic ambiguity, draft binding compromise.',
      scenarioContext: 'You are Chief Diplomat resolving demilitarized management zones in multilateral treaty.',
      assistantRole: 'Chief Diplomat',
      userRole: 'Ambassador Plenipotentiary',
      initialAssistantMessage: 'Your Excellency, we must resolve the remaining sovereignty disputes in clause 12.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Employ sophisticated diplomatic tact and ambiguity', keywords: ['employ', 'sophisticated', 'diplomatic', 'tact', 'ambiguity'], examplePhrase: 'Employ sophisticated diplomatic tact and ambiguity'),
        ScenarioGoalItem(id: 'g2', text: 'Harmonize conflicting national security imperatives', keywords: ['harmonize', 'conflicting', 'national', 'security', 'imperatives'], examplePhrase: 'Harmonize conflicting national security imperatives'),
        ScenarioGoalItem(id: 'g3', text: 'Draft binding treaty compromise language', keywords: ['draft', 'binding', 'treaty', 'compromise', 'language'], examplePhrase: 'Draft binding treaty compromise language'),
        ScenarioGoalItem(id: 'g4', text: 'Secure multilateral consensus for signing', keywords: ['secure', 'multilateral', 'consensus', 'signing'], examplePhrase: 'Secure multilateral consensus for signing'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We acknowledge profound sensitivity around territorial claims.', translation: 'We acknowledge profound sensitivity around territorial claims.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Joint demilitarized management zone honors both nations.', translation: 'Joint demilitarized management zone honors both nations.'),
        UsefulPhraseItem(id: 'p3', phrase: 'This wording preserves sovereignty while sharing resources.', translation: 'This wording preserves sovereignty while sharing resources.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I am prepared to recommend full ratification.', translation: 'I am prepared to recommend full ratification.'),
      ],
    ),

    // C2-02
    LessonData(
      id: 'c2_supreme_court_constitutional_argument',
      title: 'Supreme Court Constitutional Argument',
      description: 'Deliver oral arguments before Highest Judicial Bench on constitutional law.',
      level: 'C2',
      category: 'history',
      interest: 'history',
      difficulty: 6,
      iconKey: 'school',
      mainObjective: 'Deconstruct jurisprudence precedents, originalist vs living constitution.',
      scenarioContext: 'You are Supreme Court Justice questioning counsel on 14th Amendment stare decisis.',
      assistantRole: 'Supreme Court Justice',
      userRole: 'Constitutional Attorney',
      initialAssistantMessage: 'Counselor, how does your interpretation of the 14th Amendment square with precedent?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct historical jurisprudence and stare decisis', keywords: ['deconstruct', 'historical', 'jurisprudence', 'stare', 'decisis'], examplePhrase: 'Deconstruct historical jurisprudence and stare decisis'),
        ScenarioGoalItem(id: 'g2', text: 'Articulate originalist vs living constitution', keywords: ['articulate', 'originalist', 'living', 'constitution'], examplePhrase: 'Articulate originalist vs living constitution'),
        ScenarioGoalItem(id: 'g3', text: 'Dismantle opposing counsel legal reasoning', keywords: ['dismantle', 'opposing', 'counsel', 'legal', 'reasoning'], examplePhrase: 'Dismantle opposing counsel legal reasoning'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate decisive constitutional thesis', keywords: ['formulate', 'decisive', 'constitutional', 'thesis'], examplePhrase: 'Formulate decisive constitutional thesis'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Stare decisis is a principle of policy, not inexorable.', translation: 'Stare decisis is a principle of policy, not inexorable.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Framers drafted expansive language for changing structures.', translation: 'Framers drafted expansive language for changing structures.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Overruling precedent corrects misreading of due process.', translation: 'Overruling precedent corrects misreading of due process.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We urge the Court to uphold fundamental rights.', translation: 'We urge the Court to uphold fundamental rights.'),
      ],
    ),

    // C2-03
    LessonData(
      id: 'c2_epistemology_theoretical_consciousness',
      title: 'Epistemology & Theoretical Consciousness',
      description: 'Debate the hard problem of consciousness, qualia, and panpsychism.',
      level: 'C2',
      category: 'science',
      interest: 'science',
      difficulty: 6,
      iconKey: 'explore',
      mainObjective: 'Deconstruct physicalist reductionism, Integrated Information Theory, qualia.',
      scenarioContext: 'You are Cognitive Neuroscientist analyzing reductionist physicalism vs qualia gap.',
      assistantRole: 'Cognitive Neuroscientist',
      userRole: 'Theoretical Philosopher',
      initialAssistantMessage: 'Can physical computation ever account for the subjective feeling of redness?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct explanatory gap in physicalist reductionism', keywords: ['deconstruct', 'explanatory', 'gap', 'physicalist', 'reductionism'], examplePhrase: 'Deconstruct explanatory gap in physicalist reductionism'),
        ScenarioGoalItem(id: 'g2', text: 'Critique panpsychism and integrated information theory', keywords: ['critique', 'panpsychism', 'integrated', 'information', 'theory'], examplePhrase: 'Critique panpsychism and integrated information theory'),
        ScenarioGoalItem(id: 'g3', text: 'Analyze neurobiological correlates of experience', keywords: ['analyze', 'neurobiological', 'correlates', 'experience'], examplePhrase: 'Analyze neurobiological correlates of experience'),
        ScenarioGoalItem(id: 'g4', text: 'Synthesize advanced metaphysical position', keywords: ['synthesize', 'advanced', 'metaphysical', 'position'], examplePhrase: 'Synthesize advanced metaphysical position'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Physicalist reductionism struggles with explanatory gap.', translation: 'Physicalist reductionism struggles with explanatory gap.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Integrated Information Theory offers mathematical metrics.', translation: 'Integrated Information Theory offers mathematical metrics.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Whether consciousness is emergent remains scientific frontier.', translation: 'Whether consciousness is emergent remains scientific frontier.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Subjective experience requires shift in physical ontology.', translation: 'Subjective experience requires shift in physical ontology.'),
      ],
    ),

    // C2-04
    LessonData(
      id: 'c2_peer_review_defense_of_quantum_physics_research',
      title: 'Peer Review Defense of Quantum Physics Research',
      description: 'Defend quantum entanglement experiment data against elite peer critique.',
      level: 'C2',
      category: 'science',
      interest: 'science',
      difficulty: 6,
      iconKey: 'explore',
      mainObjective: 'Deconstruct noise algorithms, validate Bell inequality >7-sigma, 10 millikelvin.',
      scenarioContext: 'You are Renowned Quantum Physicist questioning macroscopic entanglement decoherence noise.',
      assistantRole: 'Renowned Physicist',
      userRole: 'Lead Researcher',
      initialAssistantMessage: 'Professor, your claim of macroscopic entanglement appears vulnerable to thermal noise.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct quantum noise filtration algorithms', keywords: ['deconstruct', 'quantum', 'noise', 'filtration', 'algorithms'], examplePhrase: 'Deconstruct quantum noise filtration algorithms'),
        ScenarioGoalItem(id: 'g2', text: 'Validate Bell inequality violation metrics >7-sigma', keywords: ['validate', 'bell', 'inequality', 'violation', 'metrics', 'sigma'], examplePhrase: 'Validate Bell inequality violation metrics >7-sigma'),
        ScenarioGoalItem(id: 'g3', text: 'Demonstrate cryogenic experimental controls', keywords: ['demonstrate', 'cryogenic', 'experimental', 'controls'], examplePhrase: 'Demonstrate cryogenic experimental controls'),
        ScenarioGoalItem(id: 'g4', text: 'Achieve unanimous peer recognition', keywords: ['achieve', 'unanimous', 'peer', 'recognition'], examplePhrase: 'Achieve unanimous peer recognition'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Our setup suppressed decoherence using topological qudits.', translation: 'Our setup suppressed decoherence using topological qudits.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Violation of Bell inequality exceeded 7 standard deviations.', translation: 'Violation of Bell inequality exceeded 7 standard deviations.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Thermal noise was mitigated by cooling to 10 millikelvin.', translation: 'Thermal noise was mitigated by cooling to 10 millikelvin.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Data conclusively demonstrates macroscopic coherence.', translation: 'Data conclusively demonstrates macroscopic coherence.'),
      ],
    ),

    // C2-05
    LessonData(
      id: 'c2_post_modernist_literary_deconstruction',
      title: 'Post-Modernist Literary Deconstruction',
      description: 'Analyze metanarratives, intertextuality, and semiotics in post-modern text.',
      level: 'C2',
      category: 'art',
      interest: 'art',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Analyze semiotic signifiers, Derrida/Foucault linguistic theories, narrative truth.',
      scenarioContext: 'You are Semiotics Professor analyzing self-reflexive footnotes and linguistic fluidity.',
      assistantRole: 'Semiotics Professor',
      userRole: 'Literary Critic',
      initialAssistantMessage: 'Examine how the text deconstructs its own narrative authority through self-reflexive footnotes.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze semiotic signifiers and intertextuality', keywords: ['analyze', 'semiotic', 'signifiers', 'intertextuality'], examplePhrase: 'Analyze semiotic signifiers and intertextuality'),
        ScenarioGoalItem(id: 'g2', text: 'Deconstruct illusion of objective narrative truth', keywords: ['deconstruct', 'illusion', 'objective', 'narrative', 'truth'], examplePhrase: 'Deconstruct illusion of objective narrative truth'),
        ScenarioGoalItem(id: 'g3', text: 'Examine post-structuralist linguistic theories', keywords: ['examine', 'post', 'structuralist', 'linguistic', 'theories'], examplePhrase: 'Examine post-structuralist linguistic theories'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate groundbreaking literary critique', keywords: ['formulate', 'groundbreaking', 'literary', 'critique'], examplePhrase: 'Formulate groundbreaking literary critique'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Footnotes undermine central narrative ontological primacy.', translation: 'Footnotes undermine central narrative ontological primacy.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Signifiers continuously defer fixed meaning.', translation: 'Signifiers continuously defer fixed meaning.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Text parodies claim to authority, celebrating instability.', translation: 'Text parodies claim to authority, celebrating instability.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This maneuver challenges nature of literary consumption.', translation: 'This maneuver challenges nature of literary consumption.'),
      ],
    ),

    // C2-06
    LessonData(
      id: 'c2_central_bank_monetary_policy_summit',
      title: 'Central Bank Monetary Policy Summit',
      description: 'Formulate global central bank strategy against stagflation and currency risks.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Analyze stagflation dynamics, quantitative tightening, sovereign debt risks.',
      scenarioContext: 'You are Central Bank Governor evaluating 8% inflation alongside contracting GDP.',
      assistantRole: 'Central Bank Governor',
      userRole: 'Chief Monetary Strategist',
      initialAssistantMessage: 'Colleagues, we face persistent 8% inflation alongside contracting GDP. What is our mandate?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze macroeconomic stagflation dynamics', keywords: ['analyze', 'macroeconomic', 'stagflation', 'dynamics'], examplePhrase: 'Analyze macroeconomic stagflation dynamics'),
        ScenarioGoalItem(id: 'g2', text: 'Evaluate quantitative tightening vs bank instability', keywords: ['evaluate', 'quantitative', 'tightening', 'bank', 'instability'], examplePhrase: 'Evaluate quantitative tightening vs bank instability'),
        ScenarioGoalItem(id: 'g3', text: 'Formulate calibrated monetary policy directive', keywords: ['formulate', 'calibrated', 'monetary', 'policy', 'directive'], examplePhrase: 'Formulate calibrated monetary policy directive'),
        ScenarioGoalItem(id: 'g4', text: 'Communicate forward guidance to markets', keywords: ['communicate', 'forward', 'guidance', 'markets'], examplePhrase: 'Communicate forward guidance to markets'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Targeted quantitative tightening anchors inflation expectations.', translation: 'Targeted quantitative tightening anchors inflation expectations.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Rapid rate hikes threaten sovereign debt sustainability.', translation: 'Rapid rate hikes threaten sovereign debt sustainability.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Macroprudential tools insulate banking system during tightening.', translation: 'Macroprudential tools insulate banking system during tightening.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Forward guidance emphasizes data-dependent agility.', translation: 'Forward guidance emphasizes data-dependent agility.'),
      ],
    ),

    // C2-07
    LessonData(
      id: 'c2_cyber_warfare_sovereign_state_threat_analysis',
      title: 'Cyber Warfare & Sovereign State Threat Analysis',
      description: 'Coordinate national defense against state-sponsored SCADA power grid attack.',
      level: 'C2',
      category: 'technology',
      interest: 'technology',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Deconstruct APT vectors, air-gap industrial control systems, diplomatic sanctions.',
      scenarioContext: 'You are National Security Advisor briefing head of state on APT zero-day payload.',
      assistantRole: 'National Security Advisor',
      userRole: 'Cyber Intelligence Director',
      initialAssistantMessage: 'A state actor just deployed an advanced zero-day payload into our power grid. Options?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct advanced persistent threat (APT) vectors', keywords: ['deconstruct', 'advanced', 'persistent', 'threat', 'apt', 'vectors'], examplePhrase: 'Deconstruct advanced persistent threat (APT) vectors'),
        ScenarioGoalItem(id: 'g2', text: 'Isolate compromised industrial control systems (ICS)', keywords: ['isolate', 'compromised', 'industrial', 'control', 'systems', 'ics'], examplePhrase: 'Isolate compromised industrial control systems (ICS)'),
        ScenarioGoalItem(id: 'g3', text: 'Formulate calibrated cyber counter-strike strategy', keywords: ['formulate', 'calibrated', 'cyber', 'counter', 'strike', 'strategy'], examplePhrase: 'Formulate calibrated cyber counter-strike strategy'),
        ScenarioGoalItem(id: 'g4', text: 'Brief head of state on security stance', keywords: ['brief', 'head', 'state', 'security', 'stance'], examplePhrase: 'Brief head of state on security stance'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Malware exploits unknown vulnerability in SCADA firmware.', translation: 'Malware exploits unknown vulnerability in SCADA firmware.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Air-gapping substations contained lateral movement.', translation: 'Air-gapping substations contained lateral movement.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Attribution points to APT29 based on code signatures.', translation: 'Attribution points to APT29 based on code signatures.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We recommend cyber neutralization and targeted sanctions.', translation: 'We recommend cyber neutralization and targeted sanctions.'),
      ],
    ),

    // C2-08
    LessonData(
      id: 'c2_high_stakes_international_trade_arbitration',
      title: 'High-Stakes International Trade Arbitration',
      description: 'Represent a sovereign nation in ICSID investment treaty dispute.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Cite ICSID jurisprudence, police power defense, refute cash flow claims.',
      scenarioContext: 'You are Arbitral Tribunal President hearing indirect expropriation arguments.',
      assistantRole: 'Tribunal President',
      userRole: 'Lead International Counsel',
      initialAssistantMessage: 'Counsel, prove that your state regulation did not constitute indirect expropriation.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Cite international investment arbitration precedents', keywords: ['cite', 'international', 'investment', 'arbitration', 'precedents'], examplePhrase: 'Cite international investment arbitration precedents'),
        ScenarioGoalItem(id: 'g2', text: 'Demonstrate legitimate exercise of police powers', keywords: ['demonstrate', 'legitimate', 'exercise', 'police', 'powers'], examplePhrase: 'Demonstrate legitimate exercise of police powers'),
        ScenarioGoalItem(id: 'g3', text: 'Refute claimant discounted cash flow calculations', keywords: ['refute', 'claimant', 'discounted', 'cash', 'flow', 'calculations'], examplePhrase: 'Refute claimant discounted cash flow calculations'),
        ScenarioGoalItem(id: 'g4', text: 'Secure favorable arbitral award', keywords: ['secure', 'favorable', 'arbitral', 'award'], examplePhrase: 'Secure favorable arbitral award'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Regulation constitutes non-compensable police power for health.', translation: 'Regulation constitutes non-compensable police power for health.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Indirect expropriation requires permanent economic loss.', translation: 'Indirect expropriation requires permanent economic loss.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Claimant projected damages rely on speculative assumptions.', translation: 'Claimant projected damages rely on speculative assumptions.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We request Tribunal to dismiss all claims with prejudice.', translation: 'We request Tribunal to dismiss all claims with prejudice.'),
      ],
    ),

    // C2-09
    LessonData(
      id: 'c2_complex_corporate_restructuring_solvency',
      title: 'Complex Corporate Restructuring & Solvency',
      description: 'Engineer financial restructuring for distressed conglomerate with \$5B debt.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Structure debt-for-equity swap, Chapter 11 cramdown, preserve \$300M interest.',
      scenarioContext: 'You are Restructuring Trustee negotiating senior bondholder debt-for-equity swap.',
      assistantRole: 'Restructuring Trustee',
      userRole: 'Chief Restructuring Officer',
      initialAssistantMessage: 'Senior bondholders refuse a 30% haircut on debt principal. How do we prevent liquidation?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Structure debt-for-equity swap framework', keywords: ['structure', 'debt', 'equity', 'swap', 'framework'], examplePhrase: 'Structure debt-for-equity swap framework'),
        ScenarioGoalItem(id: 'g2', text: 'Negotiate cramdown terms under Chapter 11 insolvency', keywords: ['negotiate', 'cramdown', 'terms', 'under', 'chapter', 'insolvency'], examplePhrase: 'Negotiate cramdown terms under Chapter 11 insolvency'),
        ScenarioGoalItem(id: 'g3', text: 'Preserve operational cash flow and vendor trust', keywords: ['preserve', 'operational', 'cash', 'flow', 'vendor', 'trust'], examplePhrase: 'Preserve operational cash flow and vendor trust'),
        ScenarioGoalItem(id: 'g4', text: 'Achieve consensus among creditor classes', keywords: ['achieve', 'consensus', 'among', 'creditor', 'classes'], examplePhrase: 'Achieve consensus among creditor classes'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'We propose converting 40% senior debt into preferred equity.', translation: 'We propose converting 40% senior debt into preferred equity.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Restructuring reduces annual interest expense by \$300M.', translation: 'Restructuring reduces annual interest expense by \$300M.'),
        UsefulPhraseItem(id: 'p3', phrase: 'If unsecured creditors reject, we utilize cramdown.', translation: 'If unsecured creditors reject, we utilize cramdown.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Reorganization preserves 15,000 jobs and optimizes recovery.', translation: 'Reorganization preserves 15,000 jobs and optimizes recovery.'),
      ],
    ),

    // C2-10
    LessonData(
      id: 'c2_fine_art_authentication_provenance_debate',
      title: 'Fine Art Authentication & Provenance Debate',
      description: 'Debate authenticity of uncatalogued Renaissance master painting.',
      level: 'C2',
      category: 'art',
      interest: 'art',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Analyze XRF spectroscopy, pentimenti underdrawing, unbroken provenance.',
      scenarioContext: 'You are Museum Director analyzing X-ray fluorescence and 1638 Medici archives.',
      assistantRole: 'Museum Director',
      userRole: 'Art Historian & Forensic Expert',
      initialAssistantMessage: 'Is this canvas truly an uncatalogued work by Caravaggio or a master forgery?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze X-ray fluorescence and lead white isotope ratios', keywords: ['analyze', 'ray', 'fluorescence', 'lead', 'white', 'isotope'], examplePhrase: 'Analyze X-ray fluorescence and lead white isotope ratios'),
        ScenarioGoalItem(id: 'g2', text: 'Evaluate chiaroscuro brushwork against masterworks', keywords: ['evaluate', 'chiaroscuro', 'brushwork', 'against', 'masterworks'], examplePhrase: 'Evaluate chiaroscuro brushwork against masterworks'),
        ScenarioGoalItem(id: 'g3', text: 'Trace historical provenance documents through archives', keywords: ['trace', 'historical', 'provenance', 'documents', 'through', 'archives'], examplePhrase: 'Trace historical provenance documents through archives'),
        ScenarioGoalItem(id: 'g4', text: 'Deliver definitive scholarly attribution', keywords: ['deliver', 'definitive', 'scholarly', 'attribution'], examplePhrase: 'Deliver definitive scholarly attribution'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Spectroscopic analysis confirms 1600s Roman lapis lazuli.', translation: 'Spectroscopic analysis confirms 1600s Roman lapis lazuli.'),
        UsefulPhraseItem(id: 'p2', phrase: 'X-radiography reveals pentimenti underdrawing style.', translation: 'X-radiography reveals pentimenti underdrawing style.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Unbroken provenance corroborated by 1638 Medici records.', translation: 'Unbroken provenance corroborated by 1638 Medici records.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I unequivocally attribute this work to Caravaggio.', translation: 'I unequivocally attribute this work to Caravaggio.'),
      ],
    ),

    // C2-11
    LessonData(
      id: 'c2_ethnomusicology_archaeoacoustic_research',
      title: 'Ethnomusicology & Archaeoacoustic Research',
      description: 'Deconstruct ancient musical tuning systems and stone temple acoustics.',
      level: 'C2',
      category: 'music',
      interest: 'music',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Analyze Helmholtz resonance, non-Western microtonal intonation, psychoacoustics.',
      scenarioContext: 'You are Acoustics Researcher measuring 110 Hz Helmholtz resonance in stone chambers.',
      assistantRole: 'Acoustics Researcher',
      userRole: 'Ethnomusicologist',
      initialAssistantMessage: 'How did the resonant frequencies of Neolithic stone chambers influence ritual chanting?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze acoustic Helmholtz resonance data from sites', keywords: ['analyze', 'acoustic', 'helmholtz', 'resonance', 'data', 'sites'], examplePhrase: 'Analyze acoustic Helmholtz resonance data from sites'),
        ScenarioGoalItem(id: 'g2', text: 'Deconstruct non-Western microtonal scale structures', keywords: ['deconstruct', 'non', 'western', 'microtonal', 'scale', 'structures'], examplePhrase: 'Deconstruct non-Western microtonal scale structures'),
        ScenarioGoalItem(id: 'g3', text: 'Examine psychoacoustic effects low-frequency waves', keywords: ['examine', 'psychoacoustic', 'effects', 'low', 'frequency', 'waves'], examplePhrase: 'Examine psychoacoustic effects low-frequency waves'),
        ScenarioGoalItem(id: 'g4', text: 'Synthesize interdisciplinary research paper', keywords: ['synthesize', 'interdisciplinary', 'research', 'paper'], examplePhrase: 'Synthesize interdisciplinary research paper'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Chamber 110 Hz resonance amplifies male vocal fundamentals.', translation: 'Chamber 110 Hz resonance amplifies male vocal fundamentals.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Standing wave patterns induce trance psychoacoustic states.', translation: 'Standing wave patterns induce trance psychoacoustic states.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Tuning system relies on 13-limit just intonation.', translation: 'Tuning system relies on 13-limit just intonation.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Soundscapes were intentionally engineered into architecture.', translation: 'Soundscapes were intentionally engineered into architecture.'),
      ],
    ),

    // C2-12
    LessonData(
      id: 'c2_astro_physics_dark_energy_cosmological_models',
      title: 'Astro-Physics & Dark Energy Cosmological Models',
      description: 'Debate cosmological constant theories and Hubble tension measurements.',
      level: 'C2',
      category: 'science',
      interest: 'science',
      difficulty: 6,
      iconKey: 'explore',
      mainObjective: 'Deconstruct 5-sigma Hubble tension, time-varying dark energy, Lambda-CDM.',
      scenarioContext: 'You are Theoretical Astrophysicist analyzing James Webb and Planck satellite data.',
      assistantRole: 'Theoretical Astrophysicist',
      userRole: 'Cosmologist',
      initialAssistantMessage: 'Does the persistent Hubble tension indicate new physics beyond the Lambda-CDM model?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct measurements from JWST and Planck data', keywords: ['deconstruct', 'measurements', 'jwst', 'planck', 'data'], examplePhrase: 'Deconstruct measurements from JWST and Planck data'),
        ScenarioGoalItem(id: 'g2', text: 'Analyze dark energy equation of state variations', keywords: ['analyze', 'dark', 'energy', 'equation', 'state', 'variations'], examplePhrase: 'Analyze dark energy equation of state variations'),
        ScenarioGoalItem(id: 'g3', text: 'Critique MOND vs Cold Dark Matter assumptions', keywords: ['critique', 'mond', 'cold', 'dark', 'matter', 'assumptions'], examplePhrase: 'Critique MOND vs Cold Dark Matter assumptions'),
        ScenarioGoalItem(id: 'g4', text: 'Formulate novel cosmological hypothesis', keywords: ['formulate', 'novel', 'cosmological', 'hypothesis'], examplePhrase: 'Formulate novel cosmological hypothesis'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: '5-sigma discrepancy between Hubble measurements is real.', translation: '5-sigma discrepancy between Hubble measurements is real.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Tension suggests time-varying dark energy component.', translation: 'Tension suggests time-varying dark energy component.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Modifying gravity at galactic scales fails CMB spectra.', translation: 'Modifying gravity at galactic scales fails CMB spectra.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We are on verge of paradigm shift in precision cosmology.', translation: 'We are on verge of paradigm shift in precision cosmology.'),
      ],
    ),

    // C2-13
    LessonData(
      id: 'c2_international_human_rights_digital_charter',
      title: 'International Human Rights Digital Charter',
      description: 'Draft novel global legal frameworks protecting cognitive liberty from neural harvesting.',
      level: 'C2',
      category: 'history',
      interest: 'history',
      difficulty: 6,
      iconKey: 'school',
      mainObjective: 'Define cognitive liberty, prohibit unauthorized neural decoding, UN adoption.',
      scenarioContext: 'You are UN High Commissioner drafting universal declaration amendments for neural data.',
      assistantRole: 'UN High Commissioner',
      userRole: 'Human Rights Scholar',
      initialAssistantMessage: 'How should international law protect citizens against non-consensual neural data harvesting?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Formulate legal definitions cognitive liberty/privacy', keywords: ['formulate', 'legal', 'definitions', 'cognitive', 'liberty', 'privacy'], examplePhrase: 'Formulate legal definitions cognitive liberty/privacy'),
        ScenarioGoalItem(id: 'g2', text: 'Draft binding international treaty protocol amendments', keywords: ['draft', 'binding', 'international', 'treaty', 'protocol', 'amendments'], examplePhrase: 'Draft binding international treaty protocol amendments'),
        ScenarioGoalItem(id: 'g3', text: 'Address jurisdiction enforcement across networks', keywords: ['address', 'jurisdiction', 'enforcement', 'across', 'networks'], examplePhrase: 'Address jurisdiction enforcement across networks'),
        ScenarioGoalItem(id: 'g4', text: 'Secure international diplomatic adoption', keywords: ['secure', 'international', 'diplomatic', 'adoption'], examplePhrase: 'Secure international diplomatic adoption'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Freedom of thought must prohibit unauthorized neural decoding.', translation: 'Freedom of thought must prohibit unauthorized neural decoding.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Neural data requires absolute bodily integrity protection.', translation: 'Neural data requires absolute bodily integrity protection.'),
        UsefulPhraseItem(id: 'p3', phrase: 'State surveillance using predictive algorithms violates dignity.', translation: 'State surveillance using predictive algorithms violates dignity.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We present this draft protocol as imperative update.', translation: 'We present this draft protocol as imperative update.'),
      ],
    ),

    // C2-14
    LessonData(
      id: 'c2_neuro_linguistic_bci_speech_synthesis',
      title: 'Neuro-Linguistic BCI Speech Synthesis',
      description: 'Deconstruct neural decoding of speech using invasive brain-computer interfaces.',
      level: 'C2',
      category: 'technology',
      interest: 'technology',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Deconstruct ECoG signal processing, transformer phoneme decoding, <50ms latency.',
      scenarioContext: 'You are Neurosurgeon evaluating ECoG signal processing and 90 WPM synthesis.',
      assistantRole: 'Neurosurgeon',
      userRole: 'Computational Neuroscientist',
      initialAssistantMessage: 'How does your BCI model translate motor cortex neural spikes into fluent speech audio?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct high-density ECoG signal processing', keywords: ['deconstruct', 'high', 'density', 'ecog', 'signal', 'processing'], examplePhrase: 'Deconstruct high-density ECoG signal processing'),
        ScenarioGoalItem(id: 'g2', text: 'Explain transformer neural decoding phoneme trajectories', keywords: ['explain', 'transformer', 'neural', 'decoding', 'phoneme', 'trajectories'], examplePhrase: 'Explain transformer neural decoding phoneme trajectories'),
        ScenarioGoalItem(id: 'g3', text: 'Analyze closed-loop latency optimization <50ms', keywords: ['analyze', 'closed', 'loop', 'latency', 'optimization', '50ms'], examplePhrase: 'Analyze closed-loop latency optimization <50ms'),
        ScenarioGoalItem(id: 'g4', text: 'Demonstrate clinical speech restoration breakthrough', keywords: ['demonstrate', 'clinical', 'speech', 'restoration', 'breakthrough'], examplePhrase: 'Demonstrate clinical speech restoration breakthrough'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'High-density ECoG records local field potentials from cortex.', translation: 'High-density ECoG records local field potentials from cortex.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Deep transformer maps neural firing to articulatory features.', translation: 'Deep transformer maps neural firing to articulatory features.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Synthesis achieves 5,000-word vocabulary at 90 WPM.', translation: 'Synthesis achieves 5,000-word vocabulary at 90 WPM.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This restores natural speech to locked-in patients.', translation: 'This restores natural speech to locked-in patients.'),
      ],
    ),

    // C2-15
    LessonData(
      id: 'c2_arbitral_award_international_enforcement',
      title: 'Arbitral Award International Enforcement',
      description: 'Enforce a \$1B international arbitration award under New York Convention.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Analyze New York Convention Article V, commercial exception, maritime arrest.',
      scenarioContext: 'You are Enforcement Attorney tracing state-owned commercial oil tanker assets.',
      assistantRole: 'Enforcement Attorney',
      userRole: 'Sovereignty Counsel',
      initialAssistantMessage: 'The respondent state claims sovereign immunity against asset seizure of state oil tankers.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze New York Convention Article V exceptions', keywords: ['analyze', 'new', 'york', 'convention', 'article', 'exceptions'], examplePhrase: 'Analyze New York Convention Article V exceptions'),
        ScenarioGoalItem(id: 'g2', text: 'Deconstruct commercial exceptions to sovereign immunity', keywords: ['deconstruct', 'commercial', 'exceptions', 'sovereign', 'immunity'], examplePhrase: 'Deconstruct commercial exceptions to sovereign immunity'),
        ScenarioGoalItem(id: 'g3', text: 'Track hidden offshore state asset structures', keywords: ['track', 'hidden', 'offshore', 'state', 'asset', 'structures'], examplePhrase: 'Track hidden offshore state asset structures'),
        ScenarioGoalItem(id: 'g4', text: 'Secure court orders for asset attachment', keywords: ['secure', 'court', 'orders', 'asset', 'attachment'], examplePhrase: 'Secure court orders for asset attachment'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Sovereign immunity does not shield commercial operations.', translation: 'Sovereign immunity does not shield commercial operations.'),
        UsefulPhraseItem(id: 'p2', phrase: 'State enterprise assets are subject to execution exceptions.', translation: 'State enterprise assets are subject to execution exceptions.'),
        UsefulPhraseItem(id: 'p3', phrase: 'We identified target vessels docked in friendly ports.', translation: 'We identified target vessels docked in friendly ports.'),
        UsefulPhraseItem(id: 'p4', phrase: 'We request ex parte order for maritime arrest.', translation: 'We request ex parte order for maritime arrest.'),
      ],
    ),

    // C2-16
    LessonData(
      id: 'c2_executive_crisis_address_to_global_stakeholders',
      title: 'Executive Crisis Address to Global Stakeholders',
      description: 'Address shareholders and media during a catastrophic \$4B corporate failure.',
      level: 'C2',
      category: 'business',
      interest: 'business',
      difficulty: 6,
      iconKey: 'work',
      mainObjective: 'Deliver radical transparency, asset recovery protocols, law enforcement coop.',
      scenarioContext: 'You are Financial Times journalist grilling CEO on missing client funds.',
      assistantRole: 'FT Journalist',
      userRole: 'Global Chief Executive',
      initialAssistantMessage: 'Your firm lost \$4B in client funds overnight. Why should you not be criminally prosecuted?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deliver uncompromising accountability and radical transparency', keywords: ['deliver', 'uncompromising', 'accountability', 'radical', 'transparency'], examplePhrase: 'Deliver uncompromising accountability and radical transparency'),
        ScenarioGoalItem(id: 'g2', text: 'Detail immediate liquidation and asset recovery protocols', keywords: ['detail', 'immediate', 'liquidation', 'asset', 'recovery', 'protocols'], examplePhrase: 'Detail immediate liquidation and asset recovery protocols'),
        ScenarioGoalItem(id: 'g3', text: 'Cooperate unconditionally with regulatory authorities', keywords: ['cooperate', 'unconditionally', 'regulatory', 'authorities'], examplePhrase: 'Cooperate unconditionally with regulatory authorities'),
        ScenarioGoalItem(id: 'g4', text: 'Outline path to complete victim restitution', keywords: ['outline', 'path', 'complete', 'victim', 'restitution'], examplePhrase: 'Outline path to complete victim restitution'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'I am here today to accept complete accountability.', translation: 'I am here today to accept complete accountability.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Immediate mandate is securing assets for victim restitution.', translation: 'Immediate mandate is securing assets for victim restitution.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Providing independent forensic auditors unhindered access.', translation: 'Providing independent forensic auditors unhindered access.'),
        UsefulPhraseItem(id: 'p4', phrase: 'I will not step down until every possible dollar is returned.', translation: 'I will not step down until every possible dollar is returned.'),
      ],
    ),

    // C2-17
    LessonData(
      id: 'c2_advanced_zk_stark_distributed_consensus',
      title: 'Advanced ZK-STARK Distributed Consensus',
      description: 'Analyze zero-knowledge rollups, SNARKs, and BFT consensus without setup.',
      level: 'C2',
      category: 'technology',
      interest: 'technology',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Deconstruct FRI mathematics, polylogarithmic verification, 33% BFT partition.',
      scenarioContext: 'You are Cryptography Professor analyzing FRI polynomial commitments and liveness.',
      assistantRole: 'Cryptography Professor',
      userRole: 'Protocol Architect',
      initialAssistantMessage: 'How does your protocol guarantee validity without trusted setup ceremonies?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct FRI mathematics and polynomial commitments', keywords: ['deconstruct', 'fri', 'mathematics', 'polynomial', 'commitments'], examplePhrase: 'Deconstruct FRI mathematics and polynomial commitments'),
        ScenarioGoalItem(id: 'g2', text: 'Analyze zero-knowledge succinctness verification complexity', keywords: ['analyze', 'zero', 'knowledge', 'succinctness', 'verification', 'complexity'], examplePhrase: 'Analyze zero-knowledge succinctness verification complexity'),
        ScenarioGoalItem(id: 'g3', text: 'Validate BFT liveness under 33% adversarial partition', keywords: ['validate', 'bft', 'liveness', 'under', 'adversarial', 'partition'], examplePhrase: 'Validate BFT liveness under 33% adversarial partition'),
        ScenarioGoalItem(id: 'g4', text: 'Prove cryptographic security bounds', keywords: ['prove', 'cryptographic', 'security', 'bounds'], examplePhrase: 'Prove cryptographic security bounds'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'zk-STARKs eliminate trusted setup ceremonies via hashes.', translation: 'zk-STARKs eliminate trusted setup ceremonies via hashes.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Verification complexity remains polylogarithmic.', translation: 'Verification complexity remains polylogarithmic.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Liveness guaranteed under partial synchrony with 33% malicious.', translation: 'Liveness guaranteed under partial synchrony with 33% malicious.'),
        UsefulPhraseItem(id: 'p4', phrase: 'This achieves unprecedented cryptographic security and throughput.', translation: 'This achieves unprecedented cryptographic security and throughput.'),
      ],
    ),

    // C2-18
    LessonData(
      id: 'c2_geo_engineering_ethics_solar_radiation_managemen',
      title: 'Geo-Engineering Ethics & Solar Radiation Management',
      description: 'Debate global deployment of stratospheric aerosol injection to halt warming.',
      level: 'C2',
      category: 'science',
      interest: 'science',
      difficulty: 6,
      iconKey: 'explore',
      mainObjective: 'Evaluate thermal equilibrium vs monsoon disruption, termination shock, UN treaty.',
      scenarioContext: 'You are Geo-Engineering Scientist debating termination shock risks and UN governance.',
      assistantRole: 'Geo-Engineering Scientist',
      userRole: 'Global Risk Ethicist',
      initialAssistantMessage: 'If one nation unilaterally sprays sulfur dioxide into the stratosphere, how do we respond?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Evaluate thermal equilibrium vs hydrological disruption', keywords: ['evaluate', 'thermal', 'equilibrium', 'hydrological', 'disruption'], examplePhrase: 'Evaluate thermal equilibrium vs hydrological disruption'),
        ScenarioGoalItem(id: 'g2', text: 'Analyze catastrophic termination shock scenario risks', keywords: ['analyze', 'catastrophic', 'termination', 'shock', 'scenario', 'risks'], examplePhrase: 'Analyze catastrophic termination shock scenario risks'),
        ScenarioGoalItem(id: 'g3', text: 'Propose mandatory multilateral governance treaty', keywords: ['propose', 'mandatory', 'multilateral', 'governance', 'treaty'], examplePhrase: 'Propose mandatory multilateral governance treaty'),
        ScenarioGoalItem(id: 'g4', text: 'Synthesize global emergency protocol', keywords: ['synthesize', 'global', 'emergency', 'protocol'], examplePhrase: 'Synthesize global emergency protocol'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Aerosol injection lowers temperature but alters monsoons.', translation: 'Aerosol injection lowers temperature but alters monsoons.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Unilateral deployment poses grave geopolitical risks.', translation: 'Unilateral deployment poses grave geopolitical risks.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Termination shock causes rapid warming if interrupted.', translation: 'Termination shock causes rapid warming if interrupted.'),
        UsefulPhraseItem(id: 'p4', phrase: 'A binding UN moratorium must govern atmospheric intervention.', translation: 'A binding UN moratorium must govern atmospheric intervention.'),
      ],
    ),

    // C2-19
    LessonData(
      id: 'c2_post_quantum_cryptographic_standard_migration',
      title: 'Post-Quantum Cryptographic Standard Migration',
      description: 'Formulate national strategy for migrating critical infrastructure to lattice crypto.',
      level: 'C2',
      category: 'technology',
      interest: 'technology',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Deconstruct Shor algorithm threat, CRYSTALS-Kyber/Dilithium, hybrid rollout.',
      scenarioContext: 'You are National Cyber Director planning migration against Shor algorithm threat.',
      assistantRole: 'National Cyber Director',
      userRole: 'Post-Quantum Cryptographer',
      initialAssistantMessage: 'When quantum computers reach 10,000 qubits, RSA-4096 breaks. How fast can we migrate?',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Deconstruct Shor algorithm threat to public key infrastructure', keywords: ['deconstruct', 'shor', 'algorithm', 'threat', 'public', 'key'], examplePhrase: 'Deconstruct Shor algorithm threat to public key infrastructure'),
        ScenarioGoalItem(id: 'g2', text: 'Evaluate NIST-selected lattice algorithms (Kyber/Dilithium)', keywords: ['evaluate', 'nist', 'selected', 'lattice', 'algorithms', 'kyber'], examplePhrase: 'Evaluate NIST-selected lattice algorithms (Kyber/Dilithium)'),
        ScenarioGoalItem(id: 'g3', text: 'Plan hybrid classical-quantum migration roadmap', keywords: ['plan', 'hybrid', 'classical', 'quantum', 'migration', 'roadmap'], examplePhrase: 'Plan hybrid classical-quantum migration roadmap'),
        ScenarioGoalItem(id: 'g4', text: 'Secure national critical infrastructure', keywords: ['secure', 'national', 'critical', 'infrastructure'], examplePhrase: 'Secure national critical infrastructure'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Shor algorithm renders RSA and ECC obsolete upon supremacy.', translation: 'Shor algorithm renders RSA and ECC obsolete upon supremacy.'),
        UsefulPhraseItem(id: 'p2', phrase: 'Deploying CRYSTALS-Kyber for encryption and Dilithium for signature.', translation: 'Deploying CRYSTALS-Kyber for encryption and Dilithium for signature.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Hybrid dual-signature protocol ensures backward compatibility.', translation: 'Hybrid dual-signature protocol ensures backward compatibility.'),
        UsefulPhraseItem(id: 'p4', phrase: 'All critical systems achieve post-quantum resilience by 2028.', translation: 'All critical systems achieve post-quantum resilience by 2028.'),
      ],
    ),

    // C2-20
    LessonData(
      id: 'c2_structural_analysis_of_late_beethoven_quartets',
      title: 'Structural Analysis of Late Beethoven Quartets',
      description: 'Deconstruct counterpoint, thematic transformation, and form in Opus 133.',
      level: 'C2',
      category: 'music',
      interest: 'music',
      difficulty: 6,
      iconKey: 'devices',
      mainObjective: 'Analyze thematic metric transformation, contrapuntal inversion, chromatic dissonance.',
      scenarioContext: 'You are Musicology Chair deconstructing double fugue structure in Grosse Fuge.',
      assistantRole: 'Musicology Chair',
      userRole: 'Composer & Theorist',
      initialAssistantMessage: 'Deconstruct the double fugue structure in Beethoven Grosse Fuge, Opus 133.',
      goals: [
        ScenarioGoalItem(id: 'g1', text: 'Analyze thematic metric transformation and inversion', keywords: ['analyze', 'thematic', 'metric', 'transformation', 'inversion'], examplePhrase: 'Analyze thematic metric transformation and inversion'),
        ScenarioGoalItem(id: 'g2', text: 'Deconstruct chromatic dissonance and harmonic resolution', keywords: ['deconstruct', 'chromatic', 'dissonance', 'harmonic', 'resolution'], examplePhrase: 'Deconstruct chromatic dissonance and harmonic resolution'),
        ScenarioGoalItem(id: 'g3', text: 'Examine historical reception and influence on avant-garde', keywords: ['examine', 'historical', 'reception', 'influence', 'avant', 'garde'], examplePhrase: 'Examine historical reception and influence on avant-garde'),
        ScenarioGoalItem(id: 'g4', text: 'Deliver definitive musical theory analysis', keywords: ['deliver', 'definitive', 'musical', 'theory', 'analysis'], examplePhrase: 'Deliver definitive musical theory analysis'),
      ],
      usefulPhrases: [
        UsefulPhraseItem(id: 'p1', phrase: 'Grosse Fuge subverts traditional sonata-fugue boundaries.', translation: 'Grosse Fuge subverts traditional sonata-fugue boundaries.'),
        UsefulPhraseItem(id: 'p2', phrase: 'The opening presents principal motif in four rhythmic transformations.', translation: 'The opening presents principal motif in four rhythmic transformations.'),
        UsefulPhraseItem(id: 'p3', phrase: 'Dissonance is treated as structural pillar.', translation: 'Dissonance is treated as structural pillar.'),
        UsefulPhraseItem(id: 'p4', phrase: 'Beethoven anticipated 20th-century serialism by over a century.', translation: 'Beethoven anticipated 20th-century serialism by over a century.'),
      ],
    ),

  ];

  static final Map<String, LessonData> dynamicCatalogCache = {};

  /// Genera un mensaje de apertura del tutor acorde al nivel CEFR de la misión.
  ///
  /// Se usa cuando la misión no trae un `initial_assistant_message` propio
  /// (o viene genérico/vacío desde la BD), garantizando que la conversación
  /// arranque con una dificultad coherente con el nivel: simple para A1/A2,
  /// intermedia para B1/B2, avanzada para C1 y discurso nativo para C2.
  static String levelAppropriateOpening(String level, String title) {
    final lvl = level.trim().toUpperCase().split('-').first;
    switch (lvl) {
      case 'A1':
        return 'Hi! I am your tutor. Welcome to "$title". Today we will talk in simple English. My name is Alex. What is your name?';
      case 'A2':
        return 'Hello! Welcome to "$title". Let us have a short conversation. Last time we talked about simple things. Now, tell me about your day.';
      case 'B1':
        return 'Hey! Welcome to "$title". I am glad you are here. I would like to know what you think about this topic. Could you share your opinion with me?';
      case 'B2':
        return 'Hello, and welcome to "$title". Let us explore this topic in some depth. I am curious about your perspective. What factors do you think matter most here?';
      case 'C1':
        return 'Good to see you. In this session on "$title" we will engage with nuanced arguments and abstract concepts. To begin, how would you frame the core issue at stake?';
      case 'C2':
        return 'Welcome. Today we will tackle "$title" at a sophisticated level, examining subtle distinctions and counterarguments. How would you characterize the fundamental tension we face?';
      default:
        return 'Hello! Welcome to the $title session. How would you like to start?';
    }
  }

  /// Resuelve el mensaje de apertura: usa el de la BD solo si es un mensaje
  /// propio (no vacío ni el genérico por defecto); si no, genera uno acorde
  /// al nivel CEFR de la misión.
  static String _resolveInitialMessage({
    Object? dbMessage,
    required String level,
    required String title,
  }) {
    final message = dbMessage?.toString().trim() ?? '';
    final generic = 'Hello! Welcome to the $title session.';
    if (message.isEmpty || message == generic) {
      return levelAppropriateOpening(level, title);
    }
    return message;
  }

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
        initialAssistantMessage: _resolveInitialMessage(
          dbMessage: data['initial_assistant_message'],
          level: level,
          title: title,
        ),
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
      initialAssistantMessage: levelAppropriateOpening('B1', displayTitle),
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

