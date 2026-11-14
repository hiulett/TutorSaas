import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorsaas/features/auth/presentation/providers/auth_providers.dart';
import 'package:tutorsaas/features/curriculum/data/repositories/curriculum_repository.dart';
import 'package:tutorsaas/features/curriculum/domain/models/curriculum_pack.dart';
import 'package:tutorsaas/features/dashboard/data/models/lesson_catalog.dart';

/// Repositorio del currículo de la sesión.
///
/// Es el único punto que decide si se lee de PostgreSQL o del catálogo Dart
/// según `curriculum_source`; la pantalla no pregunta por el flag (CUR-24).
final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  return buildCurriculumRepository(ref.watch(supabaseClientProvider));
});

/// Lecciones del nivel en el orden del origen activo.
///
/// Con el flag en `dart` devuelve exactamente el catálogo publicado (mismo
/// orden, mismas lecciones), así que conectar la Ruta a este provider no cambia
/// nada hasta que se encienda `db`. Si el pack no sirve, cae al catálogo.
final curriculumLevelLessonsProvider =
    FutureProvider.autoDispose.family<List<LessonData>, String>((ref, levelId) async {
  final repository = ref.watch(curriculumRepositoryProvider);
  final pack = await repository.getLevelPack(levelId);

  final known = catalogLessonsForLevel(levelId);
  final byId = {for (final lesson in known) lesson.id: lesson};
  final mapped = <LessonData>[];
  for (final lesson in pack.lessons) {
    final data = byId[lesson.id];
    if (data != null) mapped.add(data);
  }

  // Un pack con lecciones que la app todavía no sabe renderizar se descarta
  // entero: enseñar 19 de 20 es peor que repetir el catálogo completo.
  if (mapped.isEmpty || mapped.length < pack.lessons.length) {
    return known;
  }
  return mapped;
});
