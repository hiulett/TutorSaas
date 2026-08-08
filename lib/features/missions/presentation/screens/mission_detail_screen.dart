import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/floating_reward.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../../domain/models/mission_models.dart';
import '../providers/mission_providers.dart';
import '../widgets/mission_parchment.dart';

/// Detalle de una misión del gremio. Se abre como pantalla nueva (no dialog).
/// Muestra el pergamino grande + descripción + recompensas + botones
/// ACEPTAR / RECHAZAR. Toda la info proviene de la BD (GuildQuest por id).
class MissionDetailScreen extends ConsumerStatefulWidget {
  final String questId;
  const MissionDetailScreen({super.key, required this.questId});

  @override
  ConsumerState<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  bool _accepting = false;
  bool _claiming = false;

  @override
  void initState() {
    super.initState();
    // Sembrar el id de la misión en el provider de detalle.
    Future.microtask(() {
      ref.read(guildQuestIdProvider.notifier).state = widget.questId;
    });
  }

  Future<void> _acceptQuest(GuildQuest quest) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      SystemSnack.show(context, 'Inicia sesión para aceptar misiones.', type: SystemSnackType.warning);
      return;
    }
    final progress = ref.read(userProgressProvider).value ?? {};
    final playerRank = (progress['game_rank'] as String?) ?? 'E';

    if (!CefrRank.canAcceptRank(playerRank, quest.gameRank)) {
      SystemSnack.show(context, '🔒 RANGO INSUFICIENTE: necesitas rango ${quest.gameRank}.', type: SystemSnackType.error);
      return;
    }

    // Confirmación para misiones de rango alto (S/SS/SSS).
    if (_isHighRank(quest.gameRank)) {
      final confirmed = await _confirmHighRank(quest);
      if (!confirmed || !mounted) return;
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
        ref.invalidate(activeMissionsProvider);
        ref.invalidate(guildQuestPoolProvider);
        ref.invalidate(fullGuildQuestPoolProvider);
        ref.invalidate(completedGuildQuestsProvider);
        // Feedback háptico de confirmación.
        HapticFeedback.mediumImpact();
        SystemSnack.show(context, '✅ Misión aceptada: ${quest.title}', type: SystemSnackType.success);
        // Navegar al chat de voz (flujo: Aceptar → Chat de Voz).
        if (context.mounted) {
          context.go('/voice-room');
        }
      } else {
        SystemSnack.show(context, 'No se pudo aceptar (cuota llena o rango insuficiente).', type: SystemSnackType.error);
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  bool _isHighRank(String? rank) {
    const high = ['S', 'SS', 'SSS'];
    return high.contains(rank?.trim().toUpperCase());
  }

  Future<bool> _confirmHighRank(GuildQuest quest) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.medievalStone,
        title: Text(
          'MISIÓN DE ALTO RANGO',
          style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.medievalAgedGoldLight),
        ),
        content: Text(
          '¿Seguro que deseas emprender "${quest.title}" (rango ${quest.gameRank})? Es una misión de élite del gremio.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.85), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ACEPTAR', style: TextStyle(color: AppColors.royalGold, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Cobra la recompensa de una misión ya completada (XP + oro + historial).
  Future<void> _claimRewardFor(MissionInstance instance) async {
    setState(() => _claiming = true);
    try {
      final ok = await ref.read(missionRepositoryProvider).claimReward(instance.id, instance.userId);
      if (!mounted) return;
      if (ok) {
        ref.invalidate(completedMissionsProvider);
        ref.invalidate(recentRewardsProvider);
        ref.invalidate(userProgressProvider);
        HapticFeedback.lightImpact();
        FloatingReward.show(
          context,
          '+${instance.xpReward} XP  ·  +${instance.gemReward} 💎',
          icon: Icons.card_giftcard_rounded,
          color: AppColors.royalGold,
        );
      } else {
        SystemSnack.show(context, 'No se pudo cobrar la recompensa.', type: SystemSnackType.error);
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  String _npcFor(String? category) {
    switch (category) {
      case 'collaborative':
        return 'Maestre de Mesa · GreMio';
      case 'vocabulary':
        return 'Bibliotecaria del Gremio';
      case 'writing':
        return 'Escriba Real';
      case 'argumentation':
        return 'Cónsul del Debate';
      default:
        return 'Maestre de Mesa';
    }
  }

  String _difficultyLabel(String? rank) {
    return rank == null ? 'Desconocida' : 'Rango $rank';
  }

  String _estimatedTime(String? type) {
    switch (type) {
      case 'daily':
        return '~10-15 min';
      case 'weekly':
        return '~45-60 min';
      case 'collaborative':
        return '~30 min';
      default:
        return '~20 min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final questAsync = ref.watch(guildQuestByIdProvider);
    final progress = ref.watch(userProgressProvider).value ?? {};
    final playerRank = (progress['game_rank'] as String?) ?? 'E';
    // Instancia completada sin reclamar (para el botón COBRAR) y activa.
    final completedAsync = ref.watch(completedMissionsProvider);
    final activeAsync = ref.watch(activeMissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.guildTable,
        child: SafeArea(
          child: questAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.medievalAgedGold, strokeWidth: 2)),
            error: (_, __) => const Center(child: Text('No se pudo cargar la misión.')),
            data: (quest) {
              if (quest == null) {
                return const Center(child: Text('Misión no encontrada.'));
              }
              final rarity = QuestRarity.fromRank(quest.gameRank, rarity: quest.rarity);
              final canAccept = CefrRank.canAcceptRank(playerRank, quest.gameRank);

              // Misión completada sin reclamar por este jugador (para COBRAR).
              MissionInstance? completedInstance;
              for (final m in completedAsync.value ?? const <MissionInstance>[]) {
                if (m.questId == quest.id && !m.isRewardClaimed) {
                  completedInstance = m;
                  break;
                }
              }
              // Misión activa (en progreso) por este jugador.
              MissionInstance? activeInstance;
              for (final m in activeAsync.value ?? const <MissionInstance>[]) {
                if (m.questId == quest.id) {
                  activeInstance = m;
                  break;
                }
              }
              final hasCompleted = completedInstance != null;
              final hasActive = activeInstance != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'DETALLE DE MISIÓN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Pergamino grande ──────────────────────────────
                          Center(
                            child: Container(
                              width: 220,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: rarity.color.withValues(alpha: 0.5), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: rarity.color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 2),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset('assets/images/avatars/Mision.png', fit: BoxFit.cover),
                                    Container(color: AppColors.voidBg.withValues(alpha: 0.35)),
                                    Center(
                                      child: Text(
                                        quest.title,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.medievalText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Título + rareza ───────────────────────────────
                          Text(
                            quest.title,
                            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${rarity.label} · ${quest.questType.toUpperCase()}',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: rarity.color, letterSpacing: 0.8),
                          ),

                          const SizedBox(height: 12),

                          // ── Descripción / historia ────────────────────────
                          _section('DESCRIPCIÓN', quest.description),
                          const SizedBox(height: 12),

                          // ── NPC que asigna ────────────────────────────────
                          Row(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/avatars/oracle_01.png',
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 34,
                                    height: 34,
                                    color: AppColors.medievalDarkWood,
                                    child: const Icon(Icons.person_rounded, color: AppColors.medievalAgedGold, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('NPC', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.medievalAgedGoldLight, letterSpacing: 0.8)),
                                    const SizedBox(height: 2),
                                    Text(_npcFor(quest.category), style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.85))),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Stats en fila ─────────────────────────────────
                          Row(
                            children: [
                              _statCard(Icons.military_tech_rounded, 'NIVEL', _difficultyLabel(quest.gameRank)),
                              const SizedBox(width: 8),
                              _statCard(Icons.auto_awesome_rounded, 'XP', '${quest.xpReward}'),
                              const SizedBox(width: 8),
                              _statCard(Icons.diamond_rounded, 'ORO', '${quest.gemReward}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _statCard(Icons.schedule_rounded, 'TIEMPO', _estimatedTime(quest.questType)),
                              const SizedBox(width: 8),
                              _statCard(Icons.speed_rounded, 'OBJETIVO', '${quest.targetValue}'),
                              const SizedBox(width: 8),
                              _statCard(Icons.flag_rounded, 'CEFR', quest.gameRank ?? '-'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Objetivos ─────────────────────────────────────
                          _section('OBJETIVOS', 'Completa ${quest.targetValue} de ${quest.objectiveType.replaceAll('_', ' ')}.'),
                          const SizedBox(height: 16),

                          // ── Botones ───────────────────────────────────────
                          if (hasCompleted) ...[
                            // Misión completada → botón COBRAR recompensa.
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _claiming ? null : () => _claimRewardFor(completedInstance!),
                                icon: _claiming
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.voidBg))
                                    : const Icon(Icons.card_giftcard_rounded, size: 18, color: AppColors.voidBg),
                                label: Text(
                                  _claiming ? 'COBRANDO...' : 'COBRAR RECOMPENSA',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.voidBg, letterSpacing: 0.6),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.royalGold,
                                  disabledBackgroundColor: AppColors.royalGold,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                            ),
                          ] else if (hasActive) ...[
                            // Misión activa → no se puede volver a aceptar.
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => context.go('/voice-room'),
                                icon: const Icon(Icons.mic_rounded, size: 16, color: AppColors.voidBg),
                                label: Text(
                                  'EN PROGRESO · IR AL CHAT',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.voidBg, letterSpacing: 0.6),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.manaCyan,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => context.pop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.onSurfaceVariant,
                                      side: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.2)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Text('RECHAZAR', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _accepting || !canAccept ? null : () => _acceptQuest(quest),
                                    icon: _accepting
                                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.voidBg))
                                        : const Icon(Icons.add_task_rounded, size: 16, color: AppColors.voidBg),
                                    label: Text(
                                      canAccept ? 'ACEPTAR MISIÓN' : 'RANGO ${quest.gameRank} REQUERIDO',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: canAccept ? AppColors.voidBg : AppColors.crimsonRed),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canAccept ? AppColors.medievalAgedGoldLight : AppColors.onSurface.withValues(alpha: 0.12),
                                      disabledBackgroundColor: AppColors.onSurface.withValues(alpha: 0.12),
                                      disabledForegroundColor: AppColors.crimsonRed,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.medievalAgedGoldLight, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.85), height: 1.4)),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.medievalAgedGoldLight),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value, textAlign: TextAlign.center, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}
