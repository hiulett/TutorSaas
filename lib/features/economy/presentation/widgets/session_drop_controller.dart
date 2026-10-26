import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/models/drop_loot.dart';
import '../providers/economy_providers.dart';
import '../widgets/drop_notification.dart';

/// Dispara el DROP SORPRESA de fin de sesión una sola vez.
///
/// Se monta al abrir el resumen: lanza el loot (pesos por rareza), aplica el
/// XP real vía RPC `add_xp` y muestra la notificación épica en overlay.
class SessionDropController extends ConsumerStatefulWidget {
  final int completedGoals;

  const SessionDropController({super.key, required this.completedGoals});

  @override
  ConsumerState<SessionDropController> createState() => _SessionDropControllerState();
}

class _SessionDropControllerState extends ConsumerState<SessionDropController> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRoll());
  }

  Future<void> _maybeRoll() async {
    if (_done) return;
    _done = true;
    if (widget.completedGoals <= 0) return;

    // El drop vive en servidor: idempotente por session_id. Sin sesion
    // registrada no hay drop (evita farmear reabriendo el resumen).
    final session = ref.read(sessionResultProvider);
    final sessionId = session?['session_id'] as String?;
    if (sessionId == null || sessionId.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final repo = ref.read(economyRepositoryProvider);
    final res = await repo.claimSessionDrop(
      sessionId: sessionId,
      completedGoals: widget.completedGoals,
    );
    if (res['ok'] != true) return;

    if (res['already_claimed'] != true) {
      ref.invalidate(userProgressProvider);
      ref.invalidate(goldBalanceProvider);
    }

    if (!mounted) return;
    DropNotification.show(context, DropLoot.fromServer(res));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
