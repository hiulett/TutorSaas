import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/corrections_repository.dart';
import '../../domain/models/turn_correction.dart';

/// P-29 — Repositorio de correcciones (única puerta a `public.corrections`).
final correctionsRepositoryProvider = Provider<CorrectionsRepository>((ref) {
  return CorrectionsRepository(ref.watch(supabaseClientProvider));
});

/// Correcciones de la sesión en curso, ancladas al texto del mensaje del
/// usuario para pintar el chip bajo la burbuja correcta.
class SessionCorrectionsNotifier
    extends StateNotifier<List<TurnCorrection>> {
  SessionCorrectionsNotifier() : super(const []);

  /// Reemplaza las correcciones del mensaje [messageText] (idempotente: un
  /// reintento de la evaluación no acumula chips duplicados).
  void addForMessage(String messageText, List<TurnCorrection> corrections) {
    if (corrections.isEmpty) return;
    final kept = state
        .where((c) => c.messageText != messageText)
        .toList(growable: false);
    state = List.unmodifiable([
      ...kept,
      ...corrections.map((c) => c.copyWith(messageText: messageText)),
    ]);
  }

  void clear() => state = const [];
}

final sessionCorrectionsProvider =
    StateNotifierProvider<SessionCorrectionsNotifier, List<TurnCorrection>>(
      (ref) => SessionCorrectionsNotifier(),
    );

/// Historial propio de errores para la pantalla «Mis errores».
final myCorrectionsProvider =
    FutureProvider.autoDispose<List<CorrectionRecord>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const [];
      final repository = ref.watch(correctionsRepositoryProvider);
      return repository.loadMyCorrections();
    });
