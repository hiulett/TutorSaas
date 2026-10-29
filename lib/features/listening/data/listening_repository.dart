import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/error_tracker.dart';
import '../domain/models/listening_exercise.dart';

/// Error con mensaje accionable para la pantalla de comprensión auditiva.
class ListeningException implements Exception {
  const ListeningException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Acceso a `public.listening_exercises`, `public.listening_attempts` y a la
/// RPC `submit_listening_attempt` (P-30 / #115).
///
/// El cliente nunca escribe el progreso: solo envía `{questionId: optionId}` y
/// el servidor corrige, guarda el intento y avanza misiones.
class ListeningRepository {
  ListeningRepository(this._client);

  final SupabaseClient _client;

  static const Duration _readTimeout = Duration(seconds: 10);
  static const Duration _submitTimeout = Duration(seconds: 20);

  static const String _exerciseColumns =
      'id, slug, level, title, context, lines, questions, sort_order';

  Future<List<ListeningExercise>> loadExercises({required String level}) async {
    final normalized = level.trim().toUpperCase();
    if (normalized.isEmpty) return const [];
    try {
      final data = await _client
          .from('listening_exercises')
          .select(_exerciseColumns)
          .eq('level', normalized)
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .timeout(_readTimeout);
      return _parseExercises(data);
    } on TimeoutException {
      debugPrint(
        'listening_exercises timeout ($normalized) tras '
        '${_readTimeout.inSeconds}s',
      );
      throw const ListeningException(
        'La conexión tardó demasiado al cargar los ejercicios de escucha. '
        'Revisa tu red e inténtalo otra vez.',
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/listening/data/listening_repository.dart:loadExercises',
        e,
        stackTrace: st,
      );
      debugPrint('listening_exercises error ($normalized): $e');
      throw ListeningException(
        'No pudimos cargar los ejercicios de escucha: $e',
      );
    }
  }

  Future<ListeningExercise?> loadBySlug(String slug) async {
    if (slug.trim().isEmpty) return null;
    try {
      final data = await _client
          .from('listening_exercises')
          .select(_exerciseColumns)
          .eq('slug', slug.trim())
          .eq('is_active', true)
          .maybeSingle()
          .timeout(_readTimeout);
      if (data == null) return null;
      final exercise = ListeningExercise.fromMap(data);
      return exercise.isPlayable ? exercise : null;
    } on TimeoutException {
      debugPrint('listening_exercises.slug timeout ($slug)');
      throw const ListeningException(
        'La conexión tardó demasiado al abrir el ejercicio. Inténtalo otra vez.',
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/listening/data/listening_repository.dart:loadBySlug',
        e,
        stackTrace: st,
      );
      debugPrint('listening_exercises.slug error ($slug): $e');
      throw ListeningException('No pudimos abrir el ejercicio: $e');
    }
  }

  Future<ListeningProgress> loadProgress() async {
    try {
      final data = await _client
          .from('listening_attempts')
          .select('exercise_id, score, total, passed')
          .order('created_at', ascending: false)
          .limit(200)
          .timeout(_readTimeout);
      return ListeningProgress.fromAttempts(_asRows(data));
    } catch (e, st) {
      // El progreso es información de apoyo: sin él se juega igual, pero se
      // deja registro del fallo (no hay catch vacío).
      ErrorTracker.logSilent(
        'lib/features/listening/data/listening_repository.dart:loadProgress',
        e,
        stackTrace: st,
      );
      debugPrint('listening_attempts error: $e');
      return const ListeningProgress();
    }
  }

  Future<ListeningAttemptResult> submit({
    required String exerciseId,
    required Map<String, String> answers,
    required int minutes,
    int tzOffsetMinutes = 0,
  }) async {
    try {
      final data = await _client
          .rpc(
            'submit_listening_attempt',
            params: {
              'p_exercise_id': exerciseId,
              'p_answers': answers,
              'p_minutes': minutes,
              'p_tz_offset_minutes': tzOffsetMinutes,
            },
          )
          .timeout(_submitTimeout);
      return ListeningAttemptResult.fromMap(data);
    } on TimeoutException {
      debugPrint(
        'submit_listening_attempt timeout tras '
        '${_submitTimeout.inSeconds}s',
      );
      throw const ListeningException(
        'El servidor no respondió al corregir. Tus respuestas siguen aquí: '
        'pulsa "Reintentar enviar".',
      );
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/listening/data/listening_repository.dart:submit',
        e,
        stackTrace: st,
      );
      debugPrint('submit_listening_attempt error: $e');
      throw ListeningException(
        'No pudimos guardar el resultado: $e. Revisa tu conexión y reintenta.',
      );
    }
  }

  List<ListeningExercise> _parseExercises(Object? data) {
    return _asRows(data)
        .map(ListeningExercise.fromMap)
        .where((exercise) => exercise.isPlayable)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _asRows(Object? data) {
    if (data is! List) {
      debugPrint('Se esperaba una lista y llegó ${data.runtimeType}');
      return const [];
    }
    return data
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
