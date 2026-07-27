# Plan de Implementación — Corrección de Inconsistencias

## TutorSaas

---

> **Nota:** Este plan contempla los 6 niveles CEFR completos: **A1, A2, B1, B2, C1, C2**.
> El sistema actual solo soporta hasta C1. Se agregará C2 (Maestría / Casi nativo) en DB, catálogo de lecciones, filtros y UI.

## Convenciones

| Símbolo | Significado |
|---------|-------------|
| 🔴 | Prioridad Crítica (bloqueante) |
| 🟠 | Prioridad Alta |
| 🟡 | Prioridad Media |
| ⚪ | Prioridad Baja / Mejora |

Cada tarea incluye: **Archivo**, **Código actual → Código propuesto**, **Dependencias**, **Verificación**.

---

## FASE 1: Reparación de Base de Datos (Ejecutar primero)

### Tarea DB-1 🟠: Poblar niveles CEFR faltantes (incluyendo C2)

**Archivo:** `supabase/migrations/20260721000001_fix_cefr_levels.sql` (nuevo)

**Problema:** Solo existen A1 y B1. Faltan A2, B2, C1, C2.

**SQL:**
```sql
INSERT INTO public.cefr_levels (code, name, description, order_index)
VALUES
  ('A2', 'Elemental (A2)', 'Nivel CEFR A2', 2),
  ('B2', 'Intermedio Alto (B2)', 'Nivel CEFR B2', 4),
  ('C1', 'Avanzado (C1)', 'Nivel CEFR C1', 5),
  ('C2', 'Maestría (C2)', 'Nivel CEFR C2', 6)
ON CONFLICT (code) DO NOTHING;
```

**Verificación:** `SELECT * FROM cefr_levels;` → 6 filas (A1, A2, B1, B2, C1, C2)

---

### Tarea DB-2 🟠: Eliminar escenarios duplicados

**Archivo:** `supabase/migrations/20260721000002_deduplicate_scenarios.sql` (nuevo)

**Problema:** 30 escenarios (15 × 2). La migración seed se ejecutó dos veces.

**SQL:**
```sql
DELETE FROM public.scenario_objectives
WHERE scenario_id IN (
  SELECT id FROM (
    SELECT id, title, ROW_NUMBER() OVER (
      PARTITION BY title, language_id ORDER BY created_at ASC
    ) AS rn
    FROM public.scenarios
  ) dup
  WHERE dup.rn > 1
);

DELETE FROM public.scenarios
WHERE id IN (
  SELECT id FROM (
    SELECT id, title, language_id, ROW_NUMBER() OVER (
      PARTITION BY title, language_id ORDER BY created_at ASC
    ) AS rn
    FROM public.scenarios
  ) dup
  WHERE dup.rn > 1
);
```

**Verificación:** `SELECT COUNT(*) FROM scenarios;` → 15 filas

---

### Tarea DB-3 🟠: Re-poblar scenario_objectives

**Archivo:** `supabase/migrations/20260721000003_seed_objectives.sql` (nuevo)

**Problema:** `scenario_objectives` está vacía. Los objetivos no se insertaron porque el seed original probablemente falló en el segundo intento.

**SQL**: Extraer los objetivos del seed original migrando a INSERTs directos con subquery por título (para evitar depender de UUIDs).

```sql
-- Ingles (en, language_id=1)
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

-- Frances (fr, language_id=2)
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

-- Aleman (de, language_id=3)
INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Ein Bahnticket buchen und die Abfahrtszeit erfahren.', ARRAY['Fahrkarte', 'Gleis', 'Verspätung', 'einfache Fahrt']
FROM scenarios s WHERE s.title = 'Fahrkarten kaufen' AND s.language_id = 3;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Lebensmittel finden und nach dem Preis fragen.', ARRAY['Gemüse', 'Sonderangebot', 'Kasse', 'Einkaufswagen']
FROM scenarios s WHERE s.title = 'Einkaufen bei Aldi' AND s.language_id = 3;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Den Mietvertrag besprechen und die Miete verhandeln.', ARRAY['Warmmiete', 'Kaution', 'Schufa-Auskunft', 'Nebenkosten']
FROM scenarios s WHERE s.title = 'Wohnungsbesichtigung in Berlin' AND s.language_id = 3;

-- Italiano (it, language_id=4)
INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Ordinare una coppetta o un cono con gusti specifici.', ARRAY['gelato', 'coppetta', 'gusti', 'panna montata']
FROM scenarios s WHERE s.title = 'Ordinare un Gelato a Roma' AND s.language_id = 4;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Ottenere i biglietti e una mappa del museo.', ARRAY['biglietto', 'ridotto', 'mappa', 'mostra temporanea']
FROM scenarios s WHERE s.title = 'Biglietti per la Galleria degli Uffizi' AND s.language_id = 4;

INSERT INTO public.scenario_objectives (scenario_id, objective, vocabulary_focus)
SELECT s.id, 'Raggiungere un compromesso sulle royalty e l''esclusività.', ARRAY['esclusività', 'collezione', 'contratto', 'royalty']
FROM scenarios s WHERE s.title = 'Lancio di una Collezione a Milano' AND s.language_id = 4;
```

**Verificación:** `SELECT COUNT(*) FROM scenario_objectives;` → 15 filas

---

### Tarea DB-4 🟠: Seed de achievements

**Archivo:** `supabase/migrations/20260721000004_seed_achievements.sql` (nuevo)

**Problema:** La migración `20260719000001_seed_achievements.sql` no se ejecutó. Tabla `achievements` vacía.

**SQL:** Copiar el contenido de `20260719000001_seed_achievements.sql` en la nueva migración o ejecutar manualmente la existente.

**Verificación:** `SELECT COUNT(*) FROM achievements;` → > 0 filas

---

### Tarea DB-5 🟠: Verificar RLS policies

**Archivo:** `supabase/migrations/20260721000005_fix_rls_policies.sql` (nuevo)

**Problema:** Los inserts de onboarding pueden estar fallando por RLS.

**SQL:**
```sql
-- Asegurar que usuarios autenticados pueden insertar en user_language_profiles
CREATE POLICY "Users can insert their own language profile"
  ON public.user_language_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Asegurar que usuarios autenticados pueden insertar en user_settings
CREATE POLICY "Users can insert their own settings"
  ON public.user_settings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Asegurar select para usuarios autenticados
CREATE POLICY "Users can read their own language profile"
  ON public.user_language_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can read their own settings"
  ON public.user_settings FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);
```

**Verificación:** Probar onboarding completo en la app y verificar que aparezcan datos en ambas tablas.

---

## FASE 2: Reparación de Código Frontend (Crítico)

### Tarea C-1 🔴: Router — Extraer scenarioId y pasarlo a ConversationScreen

**Archivo:** `lib/app/router.dart`

**Líneas:** 36-39

**Código actual:**
```dart
GoRoute(
  path: '/conversation',
  builder: (context, state) => const ConversationScreen(),
),
```

**Código propuesto:**
```dart
GoRoute(
  path: '/conversation',
  builder: (context, state) {
    final scenarioId = state.uri.queryParameters['scenarioId'];
    final scenarioTitle = state.uri.queryParameters['scenarioTitle'];
    return ConversationScreen(
      scenarioId: scenarioId,
      scenarioTitle: scenarioTitle,
    );
  },
),
```

**Dependencias:** Ninguna

**Verificación:** Al tocar una LessonCard, `widget.scenarioId` debe tener el ID correcto.

---

### Tarea C-2 🔴: LessonCatalog — Manejar null correctamente + agregar nivel C2

**Archivo:** `lib/features/dashboard/data/models/lesson_catalog.dart`

**Líneas:** 563-569

**Código actual (retorna `catalog.first` en null):**
```dart
static LessonData getLessonById(String? id) {
  if (id == null) return catalog.first;
  return catalog.firstWhere(
    (l) => l.id == id,
    orElse: () => catalog.first,
  );
}
```

**Código propuesto:**
```dart
static LessonData? getLessonById(String? id) {
  if (id == null || id.isEmpty) return null;
  return catalog.firstWhere(
    (l) => l.id == id,
    orElse: () => null as LessonData,
  );
}
```

**Además:** Agregar 2 lecciones de nivel C2 al catálogo (`LessonCatalog.catalog`):

```dart
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
    ScenarioGoalItem(id: 'g1', text: 'Utilizar vocabulario académico de alto nivel con precisión', keyword: 'paradigm'),
    ScenarioGoalItem(id: 'g2', text: 'Expresar matices y sutilezas en argumentos complejos', keyword: 'nuance'),
    ScenarioGoalItem(id: 'g3', text: 'Responder a contraargumentos de forma estructurada', keyword: 'counterargument'),
    ScenarioGoalItem(id: 'g4', text: 'Usar referencias culturales e idiomáticas avanzadas', keyword: 'reference'),
    ScenarioGoalItem(id: 'g5', text: 'Sintetizar y concluir con propuestas originales', keyword: 'synthesize'),
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
    ScenarioGoalItem(id: 'g1', text: 'Analizar simbolismo y metáforas complejas', keyword: 'symbolism'),
    ScenarioGoalItem(id: 'g2', text: 'Discutir intención autoral con referencias textuales', keyword: 'authorial'),
    ScenarioGoalItem(id: 'g3', text: 'Comparar corrientes literarias y contextos históricos', keyword: 'literary'),
    ScenarioGoalItem(id: 'g4', text: 'Expresar crítica constructiva con diplomacia', keyword: 'critique'),
    ScenarioGoalItem(id: 'g5', text: 'Construir un argumento interpretativo coherente', keyword: 'interpretation'),
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
```

**Dependencias:** C-1 (para que los llamadores nunca reciban null sin querer)

**Nota:** Todos los consumidores deben manejar null:
- `conversation_screen.dart:101` — `_showScenarioMissionModal`
- `conversation_providers.dart:60` — `initSession`
- `conversation_providers.dart:283` — `_processTranscription`

---

### Tarea C-3 🔴: DashboardCar — Pasar scenarioTitle en la navegación

**Archivo:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Línea:** 540

**Código actual:**
```dart
onTap: () {
  context.push('/conversation?scenarioId=${lesson['id']}');
},
```

**Código propuesto:**
```dart
onTap: () {
  final encodedTitle = Uri.encodeComponent(lesson['title'] as String? ?? '');
  context.push('/conversation?scenarioId=${lesson['id']}&scenarioTitle=$encodedTitle');
},
```

**Dependencias:** C-1 (router debe extraer scenarioTitle también)

---

### Tarea C-4 🔴: ConversationScreen — Manejar null de LessonData

**Archivo:** `lib/features/conversation/presentation/screens/conversation_screen.dart`

**Línea:** 101-102

**Código actual:**
```dart
final lesson = LessonCatalog.getLessonById(widget.scenarioId);
```

**Código propuesto:**
```dart
final lesson = widget.scenarioId != null
    ? LessonCatalog.getLessonById(widget.scenarioId)
    : null;
```

Y en línea 154 (título) y 159 (objetivo), agregar guardas para null:
```dart
Text(
  widget.scenarioTitle ?? lesson?.title ?? 'Práctica de Conversación',
  ...
),
Text(
  'Objetivo: ${lesson?.mainObjective ?? 'Practica tu conversación en inglés'}',
  ...
),
```

Y en líneas 168 y 181 (metas y frases), agregar guardas:
```dart
if (lesson != null) ...[
  ...lesson.goals.asMap().entries.map(...),
]
if (lesson != null) ...[
  ...lesson.usefulPhrases.map(...),
]
```

**Dependencias:** C-2

---

### Tarea C-5 🔴: ConversationNotifier — Manejar session sin scenarioId

**Archivo:** `lib/features/conversation/presentation/providers/conversation_providers.dart`

**Línea:** 60

**Código actual:**
```dart
final lesson = LessonCatalog.getLessonById(scenarioId);
```

**Código propuesto:**
```dart
final lesson = (scenarioId != null && scenarioId.isNotEmpty)
    ? LessonCatalog.getLessonById(scenarioId)
    : null;

state = state.copyWith(
  activeScenarioId: scenarioId,
  activeScenarioName: scenarioTitle ?? lesson?.title ?? 'Práctica de Conversación',
);
```

**Línea:** 283 (en `_processTranscription`):

**Código actual:**
```dart
final lesson = LessonCatalog.getLessonById(state.activeScenarioId);
```

**Código propuesto:**
```dart
final lesson = state.activeScenarioId != null
    ? LessonCatalog.getLessonById(state.activeScenarioId)
    : null;
```

Y en líneas 288-294 (system prompt), agregar valores por defecto cuando `lesson` es null:
```dart
'content':
    'You are an AI Language Tutor. '
    'Converse naturally in English. '
    '${lesson != null ? 'You are roleplaying as ${lesson.assistantRole} in a ${lesson.scenarioContext}. '
    'The user is playing the role of ${lesson.userRole}. Target CEFR Level: ${lesson.level}. '
    'Keep your response appropriate for CEFR level ${lesson.level}' : ''}'
    'Analyze the user message, point out any grammar or vocabulary mistakes adhering to: $correctionInstructions. '
    'Ask a natural follow-up question to continue the conversation.',
```

**Dependencias:** C-2, C-1

---

## FASE 3: Reparación del Motor de Recomendaciones

### Tarea R-1 🟠: Filtrar escenarios por language_id

**Archivo:** `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`

**Líneas:** 62-140

**Código actual (líneas 64-75):**
```dart
final profileResponse = await _supabaseClient
    .from('user_language_profiles')
    .select('language_id, cefr_levels(code)')
    .eq('user_id', userId)
    .maybeSingle();

String levelCode = 'A1';
if (profileResponse != null) {
  final cefrMap = profileResponse['cefr_levels'] as Map<String, dynamic>?;
  levelCode = cefrMap?['code'] as String? ?? 'A1';
}
```

**Código propuesto:**
```dart
final profileResponse = await _supabaseClient
    .from('user_language_profiles')
    .select('language_id, cefr_levels!inner(code)')
    .eq('user_id', userId)
    .maybeSingle();

String levelCode = 'A1';
int? languageId;
if (profileResponse != null) {
  languageId = profileResponse['language_id'] as int?;
  final cefrMap = profileResponse['cefr_levels'] as Map<String, dynamic>?;
  levelCode = cefrMap?['code'] as String? ?? 'A1';
}
```

**Líneas 89-93:**
```dart
final scenariosResponse = await _supabaseClient
    .from('scenarios')
    .select('id, title, description, difficulty_level, category, estimated_minutes')
    .eq('difficulty_level', levelCode);
```

**Código propuesto:**
```dart
var query = _supabaseClient
    .from('scenarios')
    .select('id, title, description, difficulty_level, category, estimated_minutes')
    .eq('difficulty_level', levelCode);

if (languageId != null) {
  query = query.eq('language_id', languageId);
}

final scenariosResponse = await query;
```

---

### Tarea R-2 🟠: Aplicar sort por intereses SIEMPRE

**Archivo:** `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`

**Líneas:** 125-128

**Código actual:**
```dart
if (scenarios.isNotEmpty) {
  return scenarios;
}
return catalogMaps;
```

**Código propuesto:**
```dart
if (scenarios.isNotEmpty) {
  // Sort DB scenarios by interest matching too
  if (userInterests.isNotEmpty) {
    scenarios.sort((a, b) {
      final aCat = (a['category'] as String? ?? '').toLowerCase();
      final bCat = (b['category'] as String? ?? '').toLowerCase();
      final aMatches = userInterests.any((i) => aCat.contains(i.toLowerCase()));
      final bMatches = userInterests.any((i) => bCat.contains(i.toLowerCase()));
      if (aMatches && !bMatches) return -1;
      if (!aMatches && bMatches) return 1;
      return 0;
    });
  }
  return scenarios;
}
return catalogMaps;
```

---

### Tarea R-3 🟠: Filtrar LessonCatalog por idioma también + incluir C2

**Archivo:** `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`

**Líneas:** 97-103 (en `getRecommendedLessons`)

**Código actual (solo hasta C1):**
```dart
final filteredCatalog = LessonCatalog.catalog.where((l) {
  if (levelCode == 'A1') return l.level == 'A1' || l.level == 'A2';
  ...
}).toList();
```

**Código propuesto (con C2 incluido):**
```dart
final targetLangCode = _getLanguageCodeFromId(languageId);
final filteredCatalog = LessonCatalog.catalog.where((l) {
  // Match by target language
  if (targetLangCode != null && l.targetLanguageCode != targetLangCode) return false;
  // Match by level (each level includes the next for progression)
  if (levelCode == 'A1') return l.level == 'A1' || l.level == 'A2';
  if (levelCode == 'A2') return l.level == 'A2' || l.level == 'B1';
  if (levelCode == 'B1') return l.level == 'B1' || l.level == 'B2';
  if (levelCode == 'B2') return l.level == 'B2' || l.level == 'C1';
  if (levelCode == 'C1') return l.level == 'C1' || l.level == 'C2';
  return l.level == 'C2' || l.level == 'C1'; // C2 also gets C1 content
}).toList();
```

Agregar helper al final del archivo:
```dart
String? _getLanguageCodeFromId(int? languageId) {
  switch (languageId) {
    case 1: return 'en';
    case 2: return 'fr';
    case 3: return 'de';
    case 4: return 'it';
    default: return null;
  }
}
```

---

## FASE 4: Correcciones del Dashboard (Fallback y UI)

### Tarea D-1 🟡: Corregir fallback mock con IDs válidos

**Archivo:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Líneas:** 484-515

**Código actual:**
```dart
final lessons = lessonsList.isNotEmpty
    ? lessonsList
    : [
        {'id': 'l1', 'title': 'Ordenar en un Restaurante', ...},
        {'id': 'l2', 'title': 'Entrevista de Trabajo', ...},
        {'id': 'l3', 'title': 'Indicaciones de Viaje', ...},   // ← NO EXISTE
        {'id': 'l4', 'title': 'Discusión Tecnológica', ...},
      ];
```

**Código propuesto:**
```dart
final lessons = lessonsList.isNotEmpty
    ? lessonsList
    : LessonCatalog.catalog.map((l) => {
        'id': l.id,
        'title': l.title,
        'difficulty_level': l.level,
        'category': l.category,
        'progress': 0.0,
      }).toList();
```

Esto garantiza que todos los IDs del fallback existen en el catálogo.

---

### Tarea D-2 🟡: Mejorar MicPulseButton para abrir con lección por defecto

**Archivo:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Línea:** 286-288

**Código actual:**
```dart
MicPulseButton(
  onPressed: () {
    context.push('/conversation');
  },
),
```

**Código propuesto:** Sin cambios funcionales (el botón es para chat libre). Puede quedar como está ya que con la corrección del router C-1, al no pasar scenarioId se abrirá correctamente una conversación genérica.

---

## FASE 5: Correcciones del Modelo de Datos

### Tarea M-1 🟡: Completar UserSettings con interests y motivation

**Archivo:** `lib/features/dashboard/domain/models/user_settings.dart`

**Agregar campos:**
```dart
class UserSettings {
  final String correctionLevel;
  final String correctionStyle;
  final String tutorPersonality;
  final int dailyGoalMinutes;
  final bool notificationsEnabled;
  final String notificationTime;
  final List<String> interests;       // ← NUEVO
  final String motivation;            // ← NUEVO
```

**Actualizar `UserSettings.initial()`:**
```dart
factory UserSettings.initial() {
  return UserSettings(
    correctionLevel: 'short',
    correctionStyle: 'balanced',
    tutorPersonality: 'friendly',
    dailyGoalMinutes: 15,
    notificationsEnabled: false,
    notificationTime: '20:00:00',
    interests: [],                    // ← NUEVO
    motivation: 'general',           // ← NUEVO
  );
}
```

**Actualizar `UserSettings.fromJson()`:**
```dart
factory UserSettings.fromJson(Map<String, dynamic> json) {
  return UserSettings(
    ...
    interests: List<String>.from(json['interests'] ?? []),
    motivation: json['motivation'] as String? ?? 'general',
  );
}
```

**Actualizar `toJson()`:**
```dart
Map<String, dynamic> toJson() {
  return {
    ...
    'interests': interests,
    'motivation': motivation,
  };
}
```

---

### Tarea D-2 🟡: Dashboard — Mostrar nivel C2 correctamente en LessonCard

**Archivo:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Problema:** El mapeo de level a etiqueta solo cubre A1-C1. C2 muestra "Avanzado" en vez de "Maestría".

**Código actual (líneas ~531-535):**
```dart
return LessonCard(
  title: title,
  level: level == 'A1' || level == 'A2'
      ? 'Principiante ($level)'
      : level == 'B1' || level == 'B2'
          ? 'Intermedio ($level)'
          : 'Avanzado ($level)',
```

**Código propuesto:**
```dart
return LessonCard(
  title: title,
  level: _formatLevelLabel(level),
```

Agregar helper:
```dart
String _formatLevelLabel(String level) {
  switch (level) {
    case 'A1': return 'Principiante (A1)';
    case 'A2': return 'Básico (A2)';
    case 'B1': return 'Intermedio (B1)';
    case 'B2': return 'Intermedio Alto (B2)';
    case 'C1': return 'Avanzado (C1)';
    case 'C2': return 'Maestría (C2)';
    default: return level;
  }
}
```

---

### Tarea D-3 🟡: Onboarding — Agregar C2 como opción de nivel

**Archivo:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**Problema:** La lista `_levels` solo tiene A1-C1. Falta C2.

**Código actual:**
```dart
final List<Map<String, String>> _levels = [
  {'code': 'A1', 'title': 'Principiante (A1)', 'desc': '...', 'badge': 'A1'},
  {'code': 'A2', 'title': 'Elemental (A2)', 'desc': '...', 'badge': 'A2'},
  {'code': 'B1', 'title': 'Intermedio (B1)', 'desc': '...', 'badge': 'B1'},
  {'code': 'B2', 'title': 'Intermedio Alto (B2)', 'desc': '...', 'badge': 'B2'},
  {'code': 'C1', 'title': 'Avanzado (C1)', 'desc': '...', 'badge': 'C1'},
];
```

**Código propuesto:**
```dart
final List<Map<String, String>> _levels = [
  {'code': 'A1', 'title': 'Principiante (A1)', 'desc': 'Ideal si estás empezando desde cero.', 'badge': 'A1'},
  {'code': 'A2', 'title': 'Básico (A2)', 'desc': 'Puedes entender frases y expresiones cotidianas.', 'badge': 'A2'},
  {'code': 'B1', 'title': 'Intermedio (B1)', 'desc': 'Puedes mantener conversaciones sobre temas conocidos.', 'badge': 'B1'},
  {'code': 'B2', 'title': 'Intermedio Alto (B2)', 'desc': 'Hablas con fluidez sobre temas complejos.', 'badge': 'B2'},
  {'code': 'C1', 'title': 'Avanzado (C1)', 'desc': 'Deseas perfeccionar fluidez y vocabulario técnico.', 'badge': 'C1'},
  {'code': 'C2', 'title': 'Maestría (C2)', 'desc': 'Buscas dominar el idioma a nivel casi nativo.', 'badge': 'C2'},
];
```

También actualizar el helper `_getCefrName` en `onboarding_repository_impl.dart`:
```dart
String _getCefrName(String code) {
  switch (code) {
    case 'A1': return 'Principiante (A1)';
    case 'A2': return 'Básico (A2)';
    case 'B1': return 'Intermedio (B1)';
    case 'B2': return 'Intermedio Alto (B2)';
    case 'C1': return 'Avanzado (C1)';
    case 'C2': return 'Maestría (C2)';
    default: return 'Principiante (A1)';
  }
}
```

Y `_getCefrOrder`:
```dart
int _getCefrOrder(String code) {
  switch (code) {
    case 'A1': return 1;
    case 'A2': return 2;
    case 'B1': return 3;
    case 'B2': return 4;
    case 'C1': return 5;
    case 'C2': return 6;
    default: return 1;
  }
}
```

---

### Tarea D-4 🟡: ConversationNotifier — Incluir C2 en system prompt

**Archivo:** `lib/features/conversation/presentation/providers/conversation_providers.dart`

**Problema:** La línea del system prompt no menciona C2 en la instrucción de nivel.

**Código actual:**
```dart
'Keep your response appropriate for CEFR level ${lesson.level} '
'(use simple language for A1/A2, intermediate for B1/B2, advanced for C1) '
```

**Código propuesto:**
```dart
'Keep your response appropriate for CEFR level ${lesson.level} '
'(use simple language for A1/A2, intermediate for B1/B2, advanced for C1, '
'native-level fluency and complex discourse for C2) '
```

---

## FASE 6: Correcciones de Internacionalización

### Tarea I-1 🟡: Texto dinámico en onboarding según idioma seleccionado

**Archivo:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**Línea:** 1103

**Código actual:**
```dart
'¿Cuál es tu objetivo de inglés?'
```

**Código propuesto:**
```dart
final selectedLangName = _languages.firstWhere(
  (l) => l['code'] == _selectedLanguageCode,
  orElse: () => _languages.first,
)['name'] ?? 'inglés';
'¿Cuál es tu objetivo de $selectedLangName?'
```

---

### Tarea I-2 🟡: Verificar que todos los textos de onboarding se adapten al idioma

**Archivo:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

Revisar que en ningún otro lugar del onboarding (pasos 8-10) haya referencias hardcodeadas a "inglés". Buscar patrones como `'inglés'`, `'English'` en strings de UI.

---

### Tarea I-3 🟡: Onboarding — Agregar C2 en _buildStudyPlan y _buildPlacementResultPage

**Archivo:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**Problema:** `_buildStudyPlan` solo tiene planes para A1-B2. Y `_buildPlacementResultPage` solo muestra niveles hasta B2.

**Código actual (`_buildStudyPlan`):**
```dart
List<String> _buildStudyPlan(String level) {
  const plans = {
    'A1': [...],
    'A2': [...],
    'B1': [...],
    'B2': [...],
  };
  return plans[level] ?? plans['B1']!;
}
```

**Código propuesto (agregar C1 y C2):**
```dart
List<String> _buildStudyPlan(String level) {
  const plans = {
    'A1': [
      'Empezaremos con vocabulario básico del día a día.',
      'Conversaciones simples de presentación y saludos.',
      '10 minutos diarios de práctica de voz guiada.',
    ],
    'A2': [
      'Frases útiles para situaciones cotidianas.',
      'Práctica de preguntas y respuestas cortas.',
      'Gramática básica: presente simple y continuo.',
    ],
    'B1': [
      'Conversaciones sobre trabajo, viajes y rutinas.',
      'Pasado simple y perfecto en contexto real.',
      'Vocabulario temático: negocios y tecnología.',
    ],
    'B2': [
      'Debates y opiniones en inglés fluido.',
      'Vocabulario avanzado y expresiones idiomáticas.',
      'Presentaciones y comunicación profesional.',
    ],
    'C1': [
      'Argumentación compleja y matices lingüísticos.',
      'Lenguaje técnico y especializado por industria.',
      'Análisis crítico de textos y discursos.',
    ],
    'C2': [
      'Dominio casi nativo con expresiones idiomáticas avanzadas.',
      'Discurso académico y persuasivo de alto nivel.',
      'Perfeccionamiento de fonética y entonación nativa.',
    ],
  };
  return plans[level] ?? plans['B1']!;
}
```

**Código actual (`_buildPlacementResultPage`):**
```dart
finalLevel == 'A1' ? 'Principiante (A1)' :
finalLevel == 'A2' ? 'Elemental (A2)' :
finalLevel == 'B1' ? 'Intermedio (B1)' : 'Intermedio Alto (B2)',
```

**Código propuesto:**
```dart
finalLevel == 'A1' ? 'Principiante (A1)' :
finalLevel == 'A2' ? 'Básico (A2)' :
finalLevel == 'B1' ? 'Intermedio (B1)' :
finalLevel == 'B2' ? 'Intermedio Alto (B2)' :
finalLevel == 'C1' ? 'Avanzado (C1)' : 'Maestría (C2)',
```

---

## FASE 7: Corrección de Nivel de Corrección

### Tarea L-1 🟡: Separar cases de correction level

**Archivo:** `lib/features/conversation/presentation/providers/conversation_providers.dart`

**Líneas:** 271-281

**Código actual:**
```dart
case 'important_only':
  correctionInstructions =
      'Only correct mistakes that prevent understanding...';
  break;
case 'short':
case 'moderate':
default:
  correctionInstructions =
      'Provide the correction and a brief explanation...';
```

**Código propuesto:**
```dart
case 'important_only':
  correctionInstructions =
      'Only correct mistakes that prevent understanding or represent severe grammar errors. '
      'Keep corrections minimal and very brief.';
  break;
case 'short':
  correctionInstructions =
      'Provide a very brief correction (1 line max) and then continue the conversation naturally.';
  break;
case 'moderate':
  correctionInstructions =
      'Provide the correction and a brief explanation of 1 to 2 lines, then continue the conversation.';
  break;
case 'detailed':
  correctionInstructions =
      'Provide detailed corrections including grammar rule explanations, vocabulary suggestions, '
      'and alternative phrasing. Then continue the conversation.';
  break;
default:
  correctionInstructions =
      'Provide the correction and a brief explanation of 1 to 2 lines, then continue the conversation.';
```

---

## FASE 8: Limpieza de Código y Pruebas

### Tarea T-1 ⚪: Agregar tests unitarios para LessonCatalog

**Archivo:** `test/lesson_catalog_test.dart` (nuevo)

```dart
void main() {
  test('getLessonById returns null for null input', () {
    expect(LessonCatalog.getLessonById(null), isNull);
  });
  test('getLessonById returns null for non-existent id', () {
    expect(LessonCatalog.getLessonById('non_existent'), isNull);
  });
  test('getLessonById returns correct lesson for valid id', () {
    final lesson = LessonCatalog.getLessonById('l1');
    expect(lesson, isNotNull);
    expect(lesson!.id, 'l1');
  });
}
```

---

### Tarea T-2 ⚪: Agregar tests para DashboardRepository

**Archivo:** `test/dashboard_repository_test.dart` (nuevo)

Probar que `getRecommendedLessons` filtra correctamente por `language_id` usando mocks de Supabase.

---

## RESUMEN DE DEPENDENCIAS

```
FASE 1 (DB)
  DB-1: Poblar CEFR levels (sin dependencias)
  DB-2: Deducar escenarios (sin dependencias)
  DB-3: Re-poblar objectives (depende de DB-2)
  DB-4: Seed achievements (sin dependencias)
  DB-5: RLS policies (sin dependencias)

FASE 2 (Código crítico)
  C-1: Router (sin dependencias) ← PRIORIDAD MÁXIMA
  C-2: LessonCatalog null safety (depende de C-1)
  C-3: Dashboard pasar title (depende de C-1)
  C-4: ConversationScreen manejar null (depende de C-2)
  C-5: ConversationNotifier manejar null (depende de C-2)

FASE 3 (Recomendaciones)
  R-1: Filtro language_id (depende de DB datos en user_language_profiles)
  R-2: Sort siempre (depende de R-1)
  R-3: Filtrar catálogo por idioma (depende de R-1)

FASE 4 (Dashboard)
  D-1: IDs de fallback válidos (depende de C-3)
  D-2: Mostrar C2 en LessonCard (independiente)
  D-3: Agregar C2 en onboarding (independiente)
  D-4: Incluir C2 en system prompt (depende de C-2)

FASE 5 (Modelos)
  M-1: UserSettings completo (independiente)

FASE 6 (i18n)
  I-1: Texto onboarding dinámico (independiente)
  I-2: Revisar hardcodes (independiente)
  I-3: Agregar C2 en study plan y resultado (independiente)

FASE 7 (Corrección)
  L-1: Separar levels (independiente)

FASE 8 (Tests)
  T-1: Tests unitarios (depende de C-2)
  T-2: Tests repository (depende de R-1)
```

---

## ORDEN DE EJECUCIÓN RECOMENDADO

```
Día 1 (Base de datos):
  DB-1 → DB-2 → DB-3 → DB-4 → DB-5

Día 1-2 (Código crítico):
  C-1 → C-2 → C-3 → C-4 → C-5

Día 2 (Motor de recomendaciones):
  R-1 → R-2 → R-3

Día 2-3 (Dashboard y UI + niveles C2):
  D-1 → D-2 → D-3 → D-4 → M-1 → I-1 → I-2 → I-3

Día 3 (Afinación):
  L-1 → T-1 → T-2
```

---

## VERIFICACIÓN FINAL

Después de implementar todo, ejecutar la siguiente checklist:

1. Onboarding completo → verificar `user_language_profiles` y `user_settings` poblados
2. Dashboard carga solo lecciones del idioma seleccionado
3. Tap en LessonCard → chat abre con título, contexto, metas y frases correctos
4. Brújula (Compass) → Guía de Misión con datos de la lección correcta
5. Chat envía system prompt con el rol y nivel adecuados
6. Sin IDs `l3` inválidos en ningún flujo
7. Menos de 30 escenarios en DB (15 únicos)
8. `scenario_objectives` poblada (15 filas)
9. CEFR levels completos: 6 niveles (A1, A2, B1, B2, C1, C2)
10. Navaja nivel "Maestría (C2)" visible en onboarding y dashboard
11. `achievements` poblada
