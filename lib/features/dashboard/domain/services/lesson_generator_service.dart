import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/lesson_catalog.dart';
import '../models/remedial_lesson.dart';

/// Router pedagógico: convierte la evidencia real del alumno (errores
/// recurrentes P-29 + objetivos fallados) en una lección de refuerzo jugable.
///
/// La decisión de qué reforzar vive en [buildRemedialPlan]; el edge function
/// `lesson-generator` valida nivel/skill, reutiliza si ya existe, cobra el maná
/// server-side y solo inserta el escenario como borrador privado si genera
/// contenido con metas. Esta clase solo aporta la E/S.
class LessonGeneratorService {
  const LessonGeneratorService._();

  /// Skill más débil del radar, ignorando los ejes sin `skill_focus` aceptado.
  static String weakestSkill(Map<String, double> radar) =>
      weakestSkillFromRadar(radar);

  /// Genera (o reutiliza) la lección de refuerzo del plan.
  ///
  /// Nunca devuelve `null`: cualquier fallo se traduce a un
  /// [RemedialLessonResult] con un estado que la UI puede explicar.
  static Future<RemedialLessonResult> ensureRemedialLesson({
    required RemedialPlan plan,
    required String level,
    String? parentId,
  }) async {
    try {
      final client = Supabase.instance.client;
      final res = await client.functions.invoke(
        'lesson-generator',
        body: {
          'skill_focus': plan.skillFocus,
          'level': level.toUpperCase(),
          'weakness': plan.weakness,
          'failed_goals': plan.failedGoals,
          if (parentId != null) 'parent_id': parentId,
        },
      );

      final raw = res.data;
      final data = raw is Map ? Map<String, dynamic>.from(raw) : null;
      final result = RemedialLessonResult.fromResponse(data);

      // El escenario generado se inyecta al catálogo para que la sesión pueda
      // lanzarse sin depender de una recarga del dashboard.
      final scenario = data?['scenario'];
      if (result.isPlayable && scenario is Map) {
        LessonCatalog.updateCatalogFromMap(Map<String, dynamic>.from(scenario));
      }
      return result;
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map ? details['error']?.toString() : null;
      debugPrint(
        'lesson-generator ${e.status}: ${code ?? e.reasonPhrase ?? 'sin detalle'}',
      );
      return RemedialLessonResult.fromFailure(status: e.status, code: code);
    } catch (e) {
      debugPrint('lesson-generator invoke error: $e');
      return RemedialLessonResult.fromFailure(code: e.toString());
    }
  }
}
