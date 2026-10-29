import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/boss_exam_status.dart';

/// Cliente de la RPC `boss_exam_status` (P-31 / #116).
///
/// El servidor calcula los requisitos con datos reales (nivel, metas
/// superadas, minutos, racha y cooldown). Si la lectura falla, se devuelve
/// `null` y la UI cae al cálculo local heredado: nunca se bloquea al jugador
/// por un error de red.
class BossExamService {
  BossExamService(this._client);

  final SupabaseClient _client;

  static const Duration _timeout = Duration(seconds: 8);

  Future<BossExamStatus?> status({int languageId = 1}) async {
    try {
      final data = await _client
          .rpc('boss_exam_status', params: {'p_language_id': languageId})
          .timeout(_timeout);
      if (data is! Map) {
        debugPrint('boss_exam_status devolvió un tipo inesperado: $data');
        return null;
      }
      final map = Map<String, dynamic>.from(data);
      if (map['error'] != null) {
        debugPrint('boss_exam_status error: ${map['error']}');
        return null;
      }
      return BossExamStatus.fromMap(map);
    } on TimeoutException {
      debugPrint('boss_exam_status timeout tras ${_timeout.inSeconds}s');
      return null;
    } catch (e) {
      debugPrint('boss_exam_status failed: $e');
      return null;
    }
  }
}

final bossExamServiceProvider = Provider<BossExamService>((ref) {
  return BossExamService(Supabase.instance.client);
});

/// Estado del jefe para el usuario actual. `null` = no verificable ahora.
final bossExamStatusProvider = FutureProvider.autoDispose<BossExamStatus?>((
  ref,
) async {
  return ref.watch(bossExamServiceProvider).status();
});
