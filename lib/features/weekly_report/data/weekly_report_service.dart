import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/models/weekly_report.dart';

/// P-43 (#128) — cliente de la RPC `get_weekly_report`.
///
/// El cálculo vive en el servidor con datos reales; el cliente solo pide la
/// semana y normaliza la respuesta. Si la llamada falla se devuelve `null` y la
/// UI muestra el error con reintento, nunca un informe inventado.
class WeeklyReportService {
  WeeklyReportService(this._client);

  final SupabaseClient _client;

  static const Duration _timeout = Duration(seconds: 10);

  Future<WeeklyReport?> fetch({int weekOffset = 0, int languageId = 1}) async {
    try {
      final tzOffset = DateTime.now().timeZoneOffset.inMinutes;
      final data = await _client
          .rpc(
            'get_weekly_report',
            params: {
              'p_week_offset': weekOffset,
              'p_tz_offset_minutes': tzOffset,
              'p_language_id': languageId,
            },
          )
          .timeout(_timeout);
      if (data is! Map) {
        debugPrint('get_weekly_report devolvió un tipo inesperado: $data');
        return null;
      }
      return WeeklyReport.fromMap(Map<String, dynamic>.from(data));
    } on TimeoutException {
      debugPrint('get_weekly_report timeout tras ${_timeout.inSeconds}s');
      return null;
    } catch (e) {
      debugPrint('get_weekly_report failed: $e');
      return null;
    }
  }
}

final weeklyReportServiceProvider = Provider<WeeklyReportService>((ref) {
  return WeeklyReportService(ref.watch(supabaseClientProvider));
});

/// Informe de una semana concreta (`0` = semana en curso, `1` = anterior).
/// `null` = no verificable ahora (red o error del servidor).
final weeklyReportProvider = FutureProvider.autoDispose
    .family<WeeklyReport?, int>((ref, weekOffset) {
      return ref
          .watch(weeklyReportServiceProvider)
          .fetch(weekOffset: weekOffset);
    });
