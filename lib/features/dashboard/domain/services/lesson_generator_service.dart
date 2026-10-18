import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Router pedagógico: detecta el skill más débil del radar y decide si
/// reutiliza una lección existente o genera una nueva (sub misión) vía la
/// edge function `lesson-generator` (que debita 100 maná server-side).
///
/// Regla de negocio:
///  - Tras una lección, se lee el skill radar (5 dimensiones).
///  - Se identifica el skill con menor score.
///  - Si existe un escenario con ese `skill_focus` y nivel → se reutiliza.
///  - Si no → se llama a `lesson-generator` (genera + debita 100 maná).
class LessonGeneratorService {
  const LessonGeneratorService._();

  /// Identifica el skill más débil del radar (score más bajo).
  /// Devuelve el código (`fluency`/`vocab`/`phonetics`/`grammar`/`goals`).
  static String weakestSkill(Map<String, double> radar) {
    if (radar.isEmpty) return 'grammar'; // default conservador
    final entries = radar.entries.where((e) => e.key.isNotEmpty).toList();
    if (entries.isEmpty) return 'grammar';
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries.first.key;
  }

  /// Busca una lección existente en `scenarios` con el skill + nivel indicados.
  /// Si existe, la reutiliza (sin costo de generación).
  static Future<Map<String, dynamic>?> findExisting({
    required String skillFocus,
    required String level,
    String? parentId,
  }) async {
    try {
      final client = Supabase.instance.client;
      dynamic query = client
          .from('scenarios')
          .select('*')
          .eq('skill_focus', skillFocus)
          .eq('difficulty_level', level)
          .eq('is_active', true)
          .order('created_at', ascending: true)
          .limit(1);
      if (parentId != null) query = query.eq('parent_id', parentId);
      final data = await query.maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Genera (o reutiliza) una lección de refuerzo para el skill débil.
  /// Devuelve el escenario resultante, o null si la generación falló.
  static Future<Map<String, dynamic>?> ensureLessonForWeakness({
    required String skillFocus,
    required String level,
    String? weakness,
    String? parentId,
  }) async {
    // 1. Intentar reutilizar una existente (biblioteca compartida).
    final existing = await findExisting(
      skillFocus: skillFocus,
      level: level,
      parentId: parentId,
    );
    if (existing != null) return existing;

    // 2. Generar vía edge function (debita 100 maná server-side).
    try {
      final client = Supabase.instance.client;
      final res = await client.functions.invoke('lesson-generator', body: {
        'skill_focus': skillFocus,
        'level': level,
        'weakness': weakness ?? skillFocus,
        if (parentId != null) 'parent_id': parentId,
      });
      final data = res.data as Map?;
      if (data != null && data['success'] == true) {
        return data['scenario'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('lesson-generator invoke error: $e');
      return null;
    }
  }
}
