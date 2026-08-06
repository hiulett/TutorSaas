import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../providers/mission_providers.dart';
import '../../domain/models/mission_models.dart';

/// Guild Quest Board unificado (Fase 7 · G-C + v2).
///
/// Unifica el "Tablón del Gremio" y el "Tablón de Misiones": muestra las
/// misiones activas del jugador (mission_instances) con su progreso real, y el
/// pool del gremio (guild_quest_pool) con misiones aceptables. Cada misión del
/// pool muestra su rango y categoría; NO se pueden aceptar misiones de rango
/// superior al del aventurero.
class GuildQuestBoard extends ConsumerStatefulWidget {
  const GuildQuestBoard({super.key});

  @override
  ConsumerState<GuildQuestBoard> createState() => _GuildQuestBoardState();
}

class _GuildQuestBoardState extends ConsumerState<GuildQuestBoard> {
  String _filter = 'all';
  bool _accepting = false;
  bool _showCompleted = false;

  Future<void> _acceptQuest(GuildQuest quest) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      SystemSnack.show(context, 'Inicia sesión para aceptar misiones.', type: SystemSnackType.warning);
      return;
    }
    final progress = ref.read(userProgressProvider).value ?? {};
    final playerRank = (progress['game_rank'] as String?) ?? 'E';

    // Gate de rango en UI (además del gate en el repo).
    if (!CefrRank.canAcceptRank(playerRank, quest.gameRank)) {
      SystemSnack.show(context, '🔒 RANGO INSUFICIENTE: necesitas rango ${quest.gameRank} para esta misión.', type: SystemSnackType.error);
      return;
    }

    setState(() => _accepting = true);
    try {
      final repo = ref.read(missionRepositoryProvider);
      final instance = await repo.acceptGuildQuest(
        userId: user.id,
        questId: quest.id,
        playerRank: playerRank,
      );
      if (!mounted) return;
      if (instance != null) {
        SystemSnack.show(context, '✅ Misión aceptada: ${quest.title}', type: SystemSnackType.success);
        ref.invalidate(activeMissionsProvider);
        ref.invalidate(guildQuestPoolProvider);
        ref.invalidate(completedGuildQuestsProvider);
      } else {
        SystemSnack.show(context, 'No se pudo aceptar (cuota llena o rango insuficiente).', type: SystemSnackType.error);
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(guildQuestPoolProvider);
    final activeAsync = ref.watch(activeMissionsProvider);
    final progress = ref.watch(userProgressProvider).value ?? {};
    final playerRank = (progress['game_rank'] as String?) ?? 'E';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.campaign_rounded, color: AppColors.royalGold, size: 20),
            const SizedBox(width: 8),
            Text(
              'TABLÓN DEL GREMIO',
              style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface, letterSpacing: 0.8),
            ),
            const Spacer(),
            Text(
              'RANGO: $playerRank',
              style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.royalGold, letterSpacing: 0.5),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Misiones activas del jugador
        Text('TUS MISIONES ACTIVAS', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.manaCyan, letterSpacing: 0.6)),
        const SizedBox(height: 8),
        activeAsync.when(
          loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.manaCyan, strokeWidth: 2))),
          error: (_, __) => const SizedBox.shrink(),
          data: (active) {
            if (active.isEmpty) {
              return GlassCard(
                blur: 4, opacity: 0.94, padding: const EdgeInsets.all(12),
                child: Text('Sin misiones activas. Acepta una del pool de abajo.',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              );
            }
            return Column(
              children: active.take(3).map((m) => _ActiveMissionCard(mission: m, playerRank: playerRank)).toList(),
            );
          },
        ),
        const SizedBox(height: 14),

        // Pool del gremio (aceptable por rango)
        Row(
          children: [
            Text('MISIONES DEL POOL', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.royalGold, letterSpacing: 0.6)),
            const Spacer(),
            // Filtro: ver misiones cumplidas (historial)
            GestureDetector(
              onTap: () => setState(() => _showCompleted = !_showCompleted),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _showCompleted ? AppColors.emeraldGreen.withValues(alpha: 0.15) : AppColors.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _showCompleted ? AppColors.emeraldGreen : AppColors.onSurface.withValues(alpha: 0.15)),
                ),
                child: Text(
                  _showCompleted ? '✓ CUMPLIDAS' : 'CUMPLIDAS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: _showCompleted ? AppColors.emeraldGreen : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Filters
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(label: 'TODAS', value: 'all', current: _filter, onTap: () => setState(() => _filter = 'all')),
              _FilterChip(label: 'DIARIAS', value: 'daily', current: _filter, onTap: () => setState(() => _filter = 'daily')),
              _FilterChip(label: 'SEMANALES', value: 'weekly', current: _filter, onTap: () => setState(() => _filter = 'weekly')),
              _FilterChip(label: 'COLABORATIVAS', value: 'collaborative', current: _filter, onTap: () => setState(() => _filter = 'collaborative')),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (_showCompleted)
          _CompletedQuestsList(playerRank: playerRank)
        else
          questsAsync.when(
          loading: () => const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.royalGold, strokeWidth: 2))),
          error: (_, __) => const SizedBox.shrink(),
          data: (quests) {
            final filtered = _filter == 'all'
                ? quests
                : quests.where((q) => q.questType == _filter).toList();
            // Ordenar: misiones aceptables para el jugador primero, para que
            // el pool no parezca todo bloqueado.
            final sorted = [...filtered]..sort((a, b) {
              final aOk = CefrRank.canAcceptRank(playerRank, a.gameRank);
              final bOk = CefrRank.canAcceptRank(playerRank, b.gameRank);
              if (aOk != bOk) return aOk ? -1 : 1;
              return 0;
            });
            if (sorted.isEmpty) {
              return GlassCard(
                blur: 4, opacity: 0.94, padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('No hay misiones del gremio en esta categoría.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ),
              );
            }
            return Column(
              children: sorted.map((q) => _GuildQuestCard(
                quest: q,
                playerRank: playerRank,
                accepting: _accepting,
                onAccept: () => _acceptQuest(q),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Lista de misiones cumplidas por el jugador (historial, sin botón aceptar).
class _CompletedQuestsList extends ConsumerWidget {
  final String playerRank;
  const _CompletedQuestsList({required this.playerRank});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doneAsync = ref.watch(completedGuildQuestsProvider);
    return doneAsync.when(
      loading: () => const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.emeraldGreen, strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (done) {
        if (done.isEmpty) {
          return GlassCard(
            blur: 4, opacity: 0.94, padding: const EdgeInsets.all(16),
            child: Center(
              child: Text('Aún no has completado misiones del gremio.',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ),
          );
        }
        return Column(
          children: done.map((q) => _CompletedQuestCard(quest: q)).toList(),
        );
      },
    );
  }
}

/// Tarjeta de misión cumplida (historial): sin botón, con badge COMPLETADA.
class _CompletedQuestCard extends StatelessWidget {
  final GuildQuest quest;
  const _CompletedQuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final typeColor = switch (quest.questType) {
      'daily' => AppColors.manaCyan,
      'weekly' => AppColors.royalGold,
      'collaborative' => AppColors.runeViolet,
      _ => AppColors.manaCyan,
    };
    final displayRank = quest.gameRank ?? '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 4, opacity: 0.94,
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.3)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.emeraldGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.4))),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.emeraldGreen, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quest.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${quest.objectiveType.replaceAll('_', ' ').toUpperCase()} · OBJETIVO ${quest.targetValue}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RankChip(rank: displayRank, canAccept: true),
                const SizedBox(width: 4),
                const _StatusPill(icon: Icons.check_circle_rounded, label: 'COMPLETADA', color: AppColors.emeraldGreen),
              ],
            ),
            const SizedBox(height: 8),
            if (quest.category != null && quest.category!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.category_rounded, size: 12, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.category!.toUpperCase()} · ${quest.questType.toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant, letterSpacing: 0.4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isActive ? AppColors.royalGold.withValues(alpha: 0.15) : AppColors.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isActive ? AppColors.royalGold : AppColors.onSurface.withValues(alpha: 0.12)),
            ),
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.royalGold : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Misión activa del jugador con progreso real.
class _ActiveMissionCard extends StatelessWidget {
  final MissionInstance mission;
  final String playerRank;
  const _ActiveMissionCard({required this.mission, required this.playerRank});

  @override
  Widget build(BuildContext context) {
    final statusColor = mission.isCompleted ? AppColors.emeraldGreen : AppColors.manaCyan;
    final displayRank = playerRank.isEmpty ? '-' : playerRank;
    return GestureDetector(
      onTap: () {
        SystemSnack.show(
          context,
          '🗺️ ${mission.title}: ${mission.currentValue}/${mission.targetValue} · RANGO $displayRank',
          type: SystemSnackType.info,
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 4, opacity: 0.94,
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: statusColor.withValues(alpha: 0.4))),
                  child: Icon(mission.isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded, color: statusColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${mission.objectiveType.replaceAll('_', ' ').toUpperCase()} · ${mission.missionType.toUpperCase()}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RankChip(rank: displayRank, canAccept: true),
                if (mission.isCompleted) ...[
                  const SizedBox(width: 4),
                  _StatusPill(icon: Icons.check_circle_rounded, label: 'COMPLETADA', color: AppColors.emeraldGreen),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (mission.gemReward > 0) ...[
                  _GemChip(amount: mission.gemReward),
                  const SizedBox(width: 6),
                ],
                if (mission.xpReward > 0) _XpChip(amount: mission.xpReward),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: SegmentedBar(value: mission.progress, color: statusColor, height: 6)),
                const SizedBox(width: 8),
                Text('${mission.currentValue}/${mission.targetValue}', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Misión del pool, aceptable por rango (onTap).
class _GuildQuestCard extends StatelessWidget {
  final GuildQuest quest;
  final String playerRank;
  final bool accepting;
  final VoidCallback onAccept;

  const _GuildQuestCard({
    required this.quest,
    required this.playerRank,
    required this.accepting,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = switch (quest.questType) {
      'daily' => AppColors.manaCyan,
      'weekly' => AppColors.royalGold,
      'collaborative' => AppColors.runeViolet,
      _ => AppColors.manaCyan,
    };
    final canAccept = CefrRank.canAcceptRank(playerRank, quest.gameRank);
    final displayRank = quest.gameRank ?? '-';
    // Texto OSCURO (voidBg) sobre fondos de color brillante del botón para
    // que "ACEPTAR MISIÓN" se lea bien; rojo para las bloqueadas por rango.
    final btnForeground = canAccept ? AppColors.voidBg : AppColors.crimsonRed;

    // Tarjeta clicable en su totalidad: acepta si el rango lo permite; si no,
    // el propio _acceptQuest muestra el aviso de rango insuficiente.
    return GestureDetector(
      onTap: accepting ? null : onAccept,
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 4, opacity: 0.94,
        border: Border.all(color: canAccept ? typeColor.withValues(alpha: 0.3) : AppColors.crimsonRed.withValues(alpha: 0.3)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor.withValues(alpha: 0.4))),
                  child: Icon(quest.questType == 'collaborative' ? Icons.groups_rounded : Icons.flag_rounded, color: typeColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quest.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${quest.objectiveType.replaceAll('_', ' ').toUpperCase()} · OBJETIVO ${quest.targetValue}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Rango requerido
                _RankChip(rank: displayRank, canAccept: canAccept),
              ],
            ),
            const SizedBox(height: 8),
            // Categoría
            if (quest.category != null && quest.category!.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.category_rounded, size: 12, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.category!.toUpperCase()} · ${quest.questType.toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant, letterSpacing: 0.4),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (quest.gemReward > 0) ...[
                  _GemChip(amount: quest.gemReward),
                  const SizedBox(width: 6),
                ],
                if (quest.xpReward > 0) _XpChip(amount: quest.xpReward),
              ],
            ),
            const SizedBox(height: 10),
            // Botón de aceptar (contraste garantizado en ambos estados).
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: accepting || !canAccept ? null : onAccept,
                icon: accepting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.voidBg))
                    : Icon(Icons.add_task_rounded, size: 16, color: btnForeground),
                label: Text(
                  accepting ? 'ACEPTANDO...' : (canAccept ? 'ACEPTAR MISIÓN' : 'RANGO ${quest.gameRank} REQUERIDO'),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: btnForeground,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAccept ? typeColor : AppColors.onSurface.withValues(alpha: 0.12),
                  disabledBackgroundColor: canAccept ? typeColor : AppColors.onSurface.withValues(alpha: 0.12),
                  foregroundColor: btnForeground,
                  disabledForegroundColor: btnForeground,
                  side: BorderSide(color: canAccept ? Colors.transparent : AppColors.crimsonRed.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Píldora de rango: muestra el rango requerido, rojo si no se puede aceptar.
class _RankChip extends StatelessWidget {
  final String rank;
  final bool canAccept;
  const _RankChip({required this.rank, required this.canAccept});

  @override
  Widget build(BuildContext context) {
    final color = canAccept ? AppColors.royalGold : AppColors.crimsonRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.military_tech_rounded, size: 11, color: color),
          const SizedBox(width: 3),
          Text('RANGO $rank', style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}

/// Píldora de estado: icono + etiqueta con color de estado (radio 4px).
class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.4)),
        ],
      ),
    );
  }
}

/// Chip de recompensa en gemas: diamante + monto.
class _GemChip extends StatelessWidget {
  final int amount;
  const _GemChip({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.manaCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond_rounded, size: 11, color: AppColors.manaCyan),
          const SizedBox(width: 3),
          Text('$amount', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.manaCyan)),
        ],
      ),
    );
  }
}

/// Chip de recompensa en XP: estrellas + monto.
class _XpChip extends StatelessWidget {
  final int amount;
  const _XpChip({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.royalGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 11, color: AppColors.royalGold),
          const SizedBox(width: 3),
          Text('$amount', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.royalGold)),
        ],
      ),
    );
  }
}
