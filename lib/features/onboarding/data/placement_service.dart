import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/placement_outcome.dart';

/// Error de evaluación del Oráculo con un mensaje accionable.
///
/// [quota] distingue el 402 (sin maná) del resto de fallos, para que la UI
/// ofrezca recargar en vez de "reintenta".
class PlacementException implements Exception {
  const PlacementException(this.message, {this.quota = false});

  final String message;
  final bool quota;

  @override
  String toString() => message;
}

/// Cliente de la Edge Function `evaluate-placement` (#73).
///
/// El servidor recibe la transcripción y devuelve el nivel ya validado y
/// persistido. El cliente no calcula ni escribe el CEFR.
class PlacementService {
  PlacementService(this._client);

  final SupabaseClient _client;

  static const Duration _timeout = Duration(seconds: 45);

  Future<PlacementOutcome> evaluate({
    required List<String> answers,
    String? declaredCefr,
    String? declaredRank,
    int languageId = 1,
    String mode = 'placement',
    bool forced = false,
  }) async {
    try {
      final response = await _client.functions
          .invoke(
            'evaluate-placement',
            body: {
              'answers': answers,
              'language_id': languageId,
              'mode': mode,
              'forced': forced,
              if (declaredCefr != null && declaredCefr.isNotEmpty)
                'declared_cefr': declaredCefr,
              if (declaredRank != null && declaredRank.isNotEmpty)
                'declared_rank': declaredRank,
            },
          )
          .timeout(_timeout);

      final data = response.data;
      if (data is! Map) {
        throw const PlacementException(
          'El Oráculo no devolvió un resultado válido. Reintenta la evaluación.',
        );
      }

      final outcome = PlacementOutcome.fromMap(Map<String, dynamic>.from(data));
      if (outcome.cefrLevel.isEmpty) {
        throw const PlacementException(
          'El Oráculo no devolvió un nivel válido. Reintenta la evaluación.',
        );
      }
      return outcome;
    } on FunctionException catch (e) {
      debugPrint('evaluate-placement failed (${e.status}): ${e.details}');
      throw PlacementException(_messageFor(e), quota: e.status == 402);
    } on TimeoutException {
      throw const PlacementException(
        'El Oráculo tardó demasiado en evaluar. Reintenta en unos segundos.',
      );
    }
  }

  String _messageFor(FunctionException error) {
    switch (error.status) {
      case 402:
        return 'Te quedaste sin maná para la evaluación. Recarga o espera la '
            'renovación de tu plan.';
      case 401:
      case 403:
        return 'Tu sesión expiró. Vuelve a iniciar sesión para continuar.';
      case 400:
        final details = error.details;
        if (details is Map && details['error'] == 'insufficient_evidence') {
          final min = details['min_answers'] ?? 5;
          return 'El Oráculo necesita al menos $min respuestas para juzgar el '
              'examen. Este intento no cuenta.';
        }
        return 'No se recibieron respuestas suficientes para evaluar. '
            'Responde al menos una pregunta del Oráculo.';
      case 429:
        final next = _nextAttemptLabel(error.details);
        if (next != null) {
          return 'El jefe no acepta otro reto hasta $next. '
              'Practica mientras tanto y vuelve.';
        }
        return 'El jefe no acepta otro reto todavía. Reintenta más tarde.';
      default:
        return 'El Oráculo no pudo evaluar tu examen. Reintenta en unos '
            'segundos.';
    }
  }

  /// Fecha del próximo intento que manda el servidor (cooldown del jefe).
  String? _nextAttemptLabel(Object? details) {
    if (details is! Map) return null;
    final raw = details['next_attempt_at'];
    if (raw is! String) return null;
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return null;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)} ${two(date.hour)}:${two(date.minute)}';
  }
}

final placementServiceProvider = Provider<PlacementService>((ref) {
  return PlacementService(Supabase.instance.client);
});
