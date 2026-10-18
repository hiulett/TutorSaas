import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/presence_repository.dart';

class PresenceRepositoryImpl implements PresenceRepository {
  PresenceRepositoryImpl(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  Future<void> reportPresence(String section) async {
    try {
      await _supabaseClient.rpc('report_presence', params: {
        'p_section': section,
      });
    } catch (e) {
      // No bloqueante: la presencia nunca debe romper la navegación.
      debugPrint('report_presence falló (no bloqueante): $e');
    }
  }
}
