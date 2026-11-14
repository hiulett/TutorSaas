import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

/// Paquete de un nivel tal como lo sirve `get_curriculum_pack` (CUR-07).
///
/// Los modelos toleran campos ausentes: el contenido es dinámico y un campo
/// nuevo en la base no debe romper una app ya publicada.
class CurriculumPack {
  const CurriculumPack({
    required this.level,
    required this.contentVersion,
    required this.units,
    required this.source,
  });

  final CurriculumLevel level;
  final int contentVersion;
  final List<CurriculumUnit> units;

  /// `db` si vino de PostgreSQL, `dart` si es el catálogo empaquetado.
  final String source;

  List<CurriculumLesson> get lessons =>
      units.expand((unit) => unit.lessons).toList(growable: false);

  CurriculumLesson? lessonById(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  factory CurriculumPack.fromJson(Map<String, dynamic> json) {
    final levelJson = (json['level'] as Map?)?.cast<String, dynamic>() ?? const {};
    final unitsJson = (json['units'] as List?) ?? const [];
    return CurriculumPack(
      level: CurriculumLevel.fromJson(levelJson),
      contentVersion: (json['content_version'] as num?)?.toInt() ?? 0,
      units: unitsJson
          .whereType<Map>()
          .map((unit) => CurriculumUnit.fromJson(unit.cast<String, dynamic>()))
          .toList(growable: false),
      source: 'db',
    );
  }
}

class CurriculumLevel {
  const CurriculumLevel({
    required this.id,
    required this.cefr,
    required this.name,
    required this.orderIndex,
  });

  final String id;
  final String cefr;
  final String name;
  final int orderIndex;

  factory CurriculumLevel.fromJson(Map<String, dynamic> json) => CurriculumLevel(
        id: json['id'] as String? ?? '',
        cefr: json['cefr'] as String? ?? '',
        name: json['name'] as String? ?? '',
        orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      );
}

class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.slug,
    required this.title,
    required this.orderIndex,
    required this.lessons,
  });

  final String id;
  final String slug;
  final String title;
  final int orderIndex;
  final List<CurriculumLesson> lessons;

  factory CurriculumUnit.fromJson(Map<String, dynamic> json) {
    final lessonsJson = (json['lessons'] as List?) ?? const [];
    return CurriculumUnit(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      lessons: lessonsJson
          .whereType<Map>()
          .map((lesson) => CurriculumLesson.fromJson(lesson.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

class CurriculumLesson {
  const CurriculumLesson({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.orderIndex,
    required this.version,
    required this.objectives,
    required this.phrases,
    required this.activities,
    this.mainObjective,
    this.scenarioContext,
    this.assistantRole,
    this.userRole,
    this.initialMessage,
  });

  final String id;
  final String title;
  final String category;
  final int? difficulty;
  final int orderIndex;
  final int version;
  final List<CurriculumObjective> objectives;
  final List<CurriculumPhrase> phrases;
  final List<CurriculumActivity> activities;
  final String? mainObjective;
  final String? scenarioContext;
  final String? assistantRole;
  final String? userRole;
  final String? initialMessage;

  factory CurriculumLesson.fromJson(Map<String, dynamic> json) {
    final objectivesJson = (json['objectives'] as List?) ?? const [];
    final phrasesJson = (json['phrases'] as List?) ?? const [];
    final activitiesJson = (json['activities'] as List?) ?? const [];
    return CurriculumLesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'daily',
      difficulty: (json['difficulty'] as num?)?.toInt(),
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      mainObjective: json['main_objective'] as String?,
      scenarioContext: json['scenario_context'] as String?,
      assistantRole: json['assistant_role'] as String?,
      userRole: json['user_role'] as String?,
      initialMessage: json['initial_message'] as String?,
      objectives: objectivesJson
          .whereType<Map>()
          .map((item) => CurriculumObjective.fromJson(item.cast<String, dynamic>()))
          .toList(growable: false),
      phrases: phrasesJson
          .whereType<Map>()
          .map((item) => CurriculumPhrase.fromJson(item.cast<String, dynamic>()))
          .toList(growable: false),
      activities: activitiesJson
          .whereType<Map>()
          .map((item) => CurriculumActivity.fromJson(item.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

class CurriculumObjective {
  const CurriculumObjective({
    required this.code,
    required this.description,
    required this.competency,
    required this.orderIndex,
    this.keywords = const [],
    this.examplePhrase,
  });

  final String code;
  final String description;
  final String competency;
  final int orderIndex;
  final List<String> keywords;
  final String? examplePhrase;

  factory CurriculumObjective.fromJson(Map<String, dynamic> json) {
    final evidence = (json['evidence_examples'] as Map?)?.cast<String, dynamic>();
    final keywordsJson = (evidence?['keywords'] as List?) ?? const [];
    return CurriculumObjective(
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      competency: json['competency'] as String? ?? 'communication',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      keywords: keywordsJson.map((item) => item.toString()).toList(growable: false),
      examplePhrase: evidence?['example_phrase'] as String?,
    );
  }
}

class CurriculumPhrase {
  const CurriculumPhrase({
    required this.orderIndex,
    required this.phrase,
    required this.translation,
    required this.translationStatus,
  });

  final int orderIndex;
  final String phrase;
  final String translation;
  final String translationStatus;

  bool get isTranslated => translationStatus != 'identical';
  bool get isPending => translationStatus == 'pending';

  factory CurriculumPhrase.fromJson(Map<String, dynamic> json) => CurriculumPhrase(
        orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
        phrase: json['phrase'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
        translationStatus: json['translation_status'] as String? ?? 'pending',
      );
}

class CurriculumActivity {
  const CurriculumActivity({
    required this.activityType,
    required this.orderIndex,
    required this.payload,
    this.instructions,
    this.scoring,
    this.feedbackGood,
    this.feedbackBad,
  });

  final String activityType;
  final int orderIndex;
  final Map<String, dynamic> payload;
  final String? instructions;
  final Map<String, dynamic>? scoring;
  final String? feedbackGood;
  final String? feedbackBad;

  factory CurriculumActivity.fromJson(Map<String, dynamic> json) => CurriculumActivity(
        activityType: json['activity_type'] as String? ?? '',
        orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
        payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
        instructions: json['instructions'] as String?,
        scoring: (json['scoring'] as Map?)?.cast<String, dynamic>(),
        feedbackGood: json['feedback_good'] as String?,
        feedbackBad: json['feedback_bad'] as String?,
      );
}

/// Adapta el catálogo empaquetado al mismo modelo, para el modo `dart`.
CurriculumPack curriculumPackFromDart(String levelId) {
  final level = _levelFromCatalogId(levelId);
  final lessons = LessonCatalog.catalog
      .where((lesson) => lesson.level.toLowerCase() == level.cefr.toLowerCase())
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));

  final units = <CurriculumUnit>[];
  for (var index = 0; index < lessons.length; index += 5) {
    final slice = lessons.skip(index).take(5).toList();
    final unitNumber = index ~/ 5 + 1;
    units.add(CurriculumUnit(
      id: '',
      slug: '${level.id}-u$unitNumber',
      title: '${level.cefr} · Unidad $unitNumber',
      orderIndex: unitNumber,
      lessons: slice.map(_lessonFromDart).toList(growable: false),
    ));
  }

  return CurriculumPack(
    level: level,
    contentVersion: 0,
    units: units,
    source: 'dart',
  );
}

CurriculumLevel _levelFromCatalogId(String levelId) {
  const levels = <String, ({String cefr, String name, int order})>{
    'pre_a1': (cefr: 'PRE-A1', name: 'Despertar', order: 1),
    'a1': (cefr: 'A1', name: 'Aprendiz', order: 2),
    'a2': (cefr: 'A2', name: 'Iniciado', order: 3),
    'b1': (cefr: 'B1', name: 'Cazador', order: 4),
    'b2': (cefr: 'B2', name: 'Veterano', order: 5),
    'c1': (cefr: 'C1', name: 'Maestro', order: 6),
    'c2': (cefr: 'C2', name: 'Leyenda', order: 7),
  };
  final entry = levels[levelId] ?? (cefr: levelId, name: levelId, order: 0);
  return CurriculumLevel(
    id: levelId,
    cefr: entry.cefr,
    name: entry.name,
    orderIndex: entry.order,
  );
}

CurriculumLesson _lessonFromDart(LessonData lesson) => CurriculumLesson(
      id: lesson.id,
      title: lesson.title,
      category: lesson.category,
      difficulty: lesson.difficulty,
      orderIndex: 0,
      version: 0,
      mainObjective: lesson.mainObjective,
      scenarioContext: lesson.scenarioContext,
      assistantRole: lesson.assistantRole,
      userRole: lesson.userRole,
      initialMessage: lesson.initialAssistantMessage,
      objectives: [
        for (var index = 0; index < lesson.goals.length; index++)
          CurriculumObjective(
            code: lesson.goals[index].id,
            description: lesson.goals[index].text,
            competency: 'communication',
            orderIndex: index + 1,
            keywords: lesson.goals[index].keywords,
            examplePhrase: lesson.goals[index].examplePhrase,
          ),
      ],
      phrases: [
        for (var index = 0; index < lesson.usefulPhrases.length; index++)
          CurriculumPhrase(
            orderIndex: index + 1,
            phrase: lesson.usefulPhrases[index].phrase,
            translation: lesson.usefulPhrases[index].translation,
            translationStatus: lesson.usefulPhrases[index].phrase ==
                    lesson.usefulPhrases[index].translation
                ? 'identical'
                : 'ok',
          ),
      ],
      activities: const [],
    );
