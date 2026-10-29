import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/listening_repository.dart';
import '../../data/listening_tts.dart';
import '../../domain/models/listening_exercise.dart';

/// P-30 (#115) — puerta única a las tablas y la RPC de comprensión auditiva.
final listeningRepositoryProvider = Provider<ListeningRepository>((ref) {
  return ListeningRepository(ref.watch(supabaseClientProvider));
});

/// Reproductor TTS del ejercicio. Se sustituye por un doble en los tests de
/// widget: `flutter_tts` no tiene implementación en el entorno de pruebas.
final listeningAudioProvider = Provider<ListeningAudio>((ref) {
  return ListeningTts();
});

/// Ejercicios activos del nivel (A1, A2, B1...).
final listeningExercisesProvider = FutureProvider.autoDispose
    .family<List<ListeningExercise>, String>((ref, level) async {
      return ref.watch(listeningRepositoryProvider).loadExercises(level: level);
    });

/// Mejor marca por ejercicio del usuario actual.
final listeningProgressProvider = FutureProvider.autoDispose<ListeningProgress>(
  (ref) async {
    return ref.watch(listeningRepositoryProvider).loadProgress();
  },
);
