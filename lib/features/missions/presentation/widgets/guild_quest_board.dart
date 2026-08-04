import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../providers/mission_providers.dart';
import '../../domain/models/mission_models.dart';

/// Guild Quest Board (Fase 7 · G-C).
/// Muestra las misiones del gremio (guild_quest_pool) con filtros por tipo
/// y recompensas. Consume `guildQuestPoolProvider` + `guildMissionsProvider`.
class GuildQuestBoard extends ConsumerStatefulWidget {
  const GuildQuestBoard({super.key});

  @override
  ConsumerState<GuildQuestBoard> createState() => _GuildQuestBoardState();
}

class _GuildQuestBoardState extends ConsumerState<GuildQuestBoard> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(guildQuestPoolProvider);
    final collabAsync = ref.watch(guildMissionsProvider);

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
          ],
        ),
        const SizedBox(height: 10),

        // Filters
        SizedBox(
          height: 48,
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
        const SizedBox(height: 12),

        // Quests
        questsAsync.when(
          loading: () => const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.royalGold, strokeWidth: 2))),
          error: (_, __) => const SizedBox.shrink(),
          data: (quests) {
            // Las misiones del pool no tienen progreso/estado propio: se muestran como "disponibles".
            final filtered = _filter == 'all'
                ? quests
                : quests.where((q) => q.questType == _filter).toList();
            final sorted = _sortByRank(filtered, (_) => _questAvailable.rank);

            if (sorted.isEmpty && _filter == 'collaborative') {
              // Mostrar colaborativas desde GuildMission (repo T-400)
              return collabAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (collabs) {
                  if (collabs.isEmpty) return _empty();
                  final sortedCollabs = _sortByRank(collabs, (c) => _missionStatus(c).rank);
                  return Column(
                    children: sortedCollabs.map((c) => _GuildCollabCard(mission: c)).toList(),
                  );
                },
              );
            }

            if (sorted.isEmpty) return _empty();

            return Column(
              children: sorted.take(4).map((q) => _GuildQuestCard(quest: q)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _empty() {
    return GlassCard(
      blur: 4, opacity: 0.94,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No hay misiones del gremio en esta categoría.',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
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

class _GuildQuestCard extends StatelessWidget {
  final GuildQuest quest;
  const _GuildQuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final typeColor = switch (quest.questType) {
      'daily' => AppColors.manaCyan,
      'weekly' => AppColors.royalGold,
      'collaborative' => AppColors.runeViolet,
      _ => AppColors.manaCyan,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 4, opacity: 0.94,
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
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
                _StatusPill(icon: _questAvailable.icon, label: _questAvailable.label, color: _questAvailable.color),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (quest.gemReward > 0) ...[
                  _GemChip(amount: quest.gemReward),
                  const SizedBox(width: 6),
                ],
                if (quest.xpReward > 0) ...[
                  _XpChip(amount: quest.xpReward),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: SegmentedBar(value: 0, color: AppColors.manaCyan, height: 6)),
                const SizedBox(width: 8),
                Text('0/${quest.targetValue}', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuildCollabCard extends StatelessWidget {
  final GuildMission mission;
  const _GuildCollabCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final status = _missionStatus(mission);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 4, opacity: 0.94,
        border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.3)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.runeViolet.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4))),
                  child: const Icon(Icons.groups_rounded, color: AppColors.runeViolet, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${mission.objectiveType.replaceAll('_', ' ').toUpperCase()} · ${mission.currentValue}/${mission.targetValue}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(icon: status.icon, label: status.label, color: status.color),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (mission.gemReward > 0) ...[
                  _GemChip(amount: mission.gemReward),
                  const SizedBox(width: 6),
                ],
                if (mission.xpReward > 0) ...[
                  _XpChip(amount: mission.xpReward),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: SegmentedBar(value: mission.progress, color: status.color, height: 6)),
                const SizedBox(width: 8),
                Text('${mission.currentValue}/${mission.targetValue}', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado visual de una misión del gremio (icono + etiqueta + color + orden).
typedef _QuestStatus = ({IconData icon, Color color, String label, int rank});

const _questAvailable = (icon: Icons.radio_button_unchecked, color: AppColors.manaCyan, label: 'DISPONIBLE', rank: 1);

/// Deriva el estado de una `GuildMission`: en progreso → disponible → completada → expirada.
_QuestStatus _missionStatus(GuildMission m) {
  if (m.isExpired) {
    return (icon: Icons.hourglass_disabled_rounded, color: AppColors.crimsonRed, label: 'EXPIRADA', rank: 3);
  }
  if (m.isCompleted) {
    return (icon: Icons.check_circle_rounded, color: AppColors.emeraldGreen, label: 'COMPLETADA', rank: 2);
  }
  if (m.currentValue > 0) {
    return (icon: Icons.timelapse_rounded, color: AppColors.royalGold, label: 'EN PROGRESO', rank: 0);
  }
  return _questAvailable;
}

/// Ordena por estado (en progreso → disponible → completada → expirada),
/// preservando el orden original dentro del mismo estado.
List<T> _sortByRank<T>(List<T> items, int Function(T) rankOf) {
  final indexed = <(int, T)>[];
  for (var i = 0; i < items.length; i++) {
    indexed.add((i, items[i]));
  }
  indexed.sort((a, b) {
    final byRank = rankOf(a.$2).compareTo(rankOf(b.$2));
    return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
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
