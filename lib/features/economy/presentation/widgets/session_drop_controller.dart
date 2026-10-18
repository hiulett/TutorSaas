import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final loot = DropLoot.roll(Random());

    // Aplica el XP real del drop (bonus sobre las metas completadas).
    try {
      final repo = ref.read(economyRepositoryProvider);
      await repo.addXp(user.id, loot.xpBonus);
      ref.invalidate(userProgressProvider);
    } catch (_) {}

    if (!mounted) return;
    DropNotification.show(context, loot);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
