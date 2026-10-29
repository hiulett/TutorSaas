import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/turn_correction.dart';

/// Error de lectura con mensaje accionable (la UI lo muestra tal cual).
class CorrectionsException implements Exception {
  const CorrectionsException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Persistencia y lectura de `public.corrections` (P-29).
///
/// La escritura es best-effort: un fallo de registro nunca bloquea el turno.
/// La lectura sí propaga un [CorrectionsException] para que la pantalla
/// «Mis errores» pueda explicar qué pasó y ofrecer reintento.
class CorrectionsRepository {
  CorrectionsRepository(this._client);

  final SupabaseClient _client;

  /// Inserta las correcciones de un turno sin duplicar.
  ///
  /// La unicidad la garantiza el índice
  /// `corrections_turn_dedupe_idx (user_id, turn_ref, error_type, original_text)`;
  /// `ignoreDuplicates` evita que un reintento del mismo turno duplique filas.
  Future<void> saveCorrections({
    required String userId,
    required String turnRef,
    required List<TurnCorrection> corrections,
    String? conversationId,
    String? messageId,
  }) async {
    if (userId.isEmpty || corrections.isEmpty) return;

    final rows = corrections
        .map(
          (correction) => {
            'user_id': userId,
            'conversation_id': _asUuid(conversationId),
            'message_id': _asUuid(messageId),
            'turn_ref': turnRef,
            'original_text': correction.original,
            'corrected_text': correction.corrected,
            'error_type': correction.type.wireName,
            'explanation': correction.explanation.isEmpty
                ? null
                : correction.explanation,
          },
        )
        .toList();

    try {
      await _client
          .from('corrections')
          .upsert(
            rows,
            onConflict: 'user_id,turn_ref,error_type,original_text',
            ignoreDuplicates: true,
          );
      debugPrint('corrections: ${rows.length} guardadas (turn_ref=$turnRef)');
    } catch (e) {
      debugPrint('Error guardando correcciones (turn_ref=$turnRef): $e');
    }
  }

  /// Historial propio, más reciente primero. RLS filtra por `auth.uid()`.
  Future<List<CorrectionRecord>> loadMyCorrections({int limit = 300}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const CorrectionsException(
        'Inicia sesión para ver tus errores guardados.',
      );
    }
    try {
      final rows = await _client
          .from('corrections')
          .select(
            'error_type, original_text, corrected_text, explanation, created_at',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final records = <CorrectionRecord>[];
      for (final row in rows as List) {
        final record = _toRecord(row);
        if (record != null) records.add(record);
      }
      return records;
    } catch (e) {
      debugPrint('Error cargando correcciones propias: $e');
      throw const CorrectionsException(
        'No pudimos cargar tus errores. Revisa tu conexión y reintenta.',
      );
    }
  }

  /// Vista agregada `user_recurring_errors` (ya agrupada en servidor).
  ///
  /// Se usa para el prompt del tutor y para las misiones de refuerzo; si falla
  /// no se interrumpe nada (devuelve lista vacía).
  Future<List<CorrectionGroup>> loadRecurringErrors({
    int limit = 5,
    int minOccurrences = recurringErrorThreshold,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return const [];
    try {
      final rows = await _client
          .from('user_recurring_errors')
          .select(
            'error_type, last_original, last_corrected, last_explanation, occurrences, last_seen_at',
          )
          .eq('user_id', userId)
          .gte('occurrences', minOccurrences)
          .order('occurrences', ascending: false)
          .limit(limit);

      final groups = <CorrectionGroup>[];
      for (final row in rows as List) {
        final type = CorrectionType.fromWire(row['error_type']);
        final corrected = (row['last_corrected'] as String?)?.trim() ?? '';
        if (type == null || corrected.isEmpty) continue;
        groups.add(
          CorrectionGroup(
            type: type,
            original: (row['last_original'] as String?)?.trim() ?? '',
            corrected: corrected,
            occurrences: (row['occurrences'] as num?)?.toInt() ?? 1,
            explanation: (row['last_explanation'] as String?)?.trim() ?? '',
            lastSeenAt: DateTime.tryParse(row['last_seen_at'] as String? ?? ''),
          ),
        );
      }
      return groups;
    } catch (e) {
      debugPrint('Error cargando errores recurrentes: $e');
      return const [];
    }
  }

  CorrectionRecord? _toRecord(Map<String, dynamic> row) {
    final type = CorrectionType.fromWire(row['error_type']);
    final original = (row['original_text'] as String?)?.trim() ?? '';
    final corrected = (row['corrected_text'] as String?)?.trim() ?? '';
    if (type == null || original.isEmpty || corrected.isEmpty) return null;
    return CorrectionRecord(
      type: type,
      original: original,
      corrected: corrected,
      explanation: (row['explanation'] as String?)?.trim() ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
    );
  }

  /// Un id local (`local_...`) o vacío no es un UUID: se envía `null`.
  String? _asUuid(String? value) {
    if (value == null || value.isEmpty) return null;
    final isUuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
    return isUuid ? value : null;
  }
}
