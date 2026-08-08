import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../../domain/models/mission_models.dart';
import '../providers/mission_providers.dart';
import '../widgets/mission_board_skeleton.dart';
import '../widgets/mission_parchment.dart';

/// Tablón de Misiones del Gremio (pantalla independiente).
///
/// Cuadrícula adaptativa de pergaminos (reutiliza `Mision.png`). Incluye:
/// - orden inteligente (recomendadas → disponibles → bloqueadas),
/// - mini-barra de progreso en misiones activas,
/// - filtros por tipo y por rareza,
/// - historial de misiones cumplidas (toggle CUMPLIDAS).
class GuildMissionBoardScreen extends ConsumerStatefulWidget {
  const GuildMissionBoardScreen({super.key});

  @override
  ConsumerState<GuildMissionBoardScreen> createState() => _GuildMissionBoardScreenState();
}

class _GuildMissionBoardScreenState extends ConsumerState<GuildMissionBoardScreen> {
  static const int _pageSize = 6;
  String _filter = 'all';
  String _rarityFilter = 'all';
  bool _showCompleted = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _visibleCount = _pageSize;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetPagination() {
    setState(() => _visibleCount = _pageSize);
  }

  List<GuildQuest> _applyFilters(List<GuildQuest> quests) {
    var result = _filter == 'all'
        ? quests
        : quests.where((q) => q.questType == _filter).toList();
    if (_rarityFilter != 'all') {
      result = result.where((q) => QuestRarity.fromRank(q.gameRank, rarity: q.rarity).name == _rarityFilter).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((it) => it.title.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  /// Orden inteligente: recomendadas primero, luego disponibles/aceptables,
  /// y bloqueadas al final (función pura testable).
  List<GuildQuest> _sortSmart(List<GuildQuest> quests, String playerRank, String recommendedRank) {
    return sortQuestSmart(quests: quests, playerRank: playerRank, recommendedRank: recommendedRank);
  }

  @override
  Widget build(BuildContext context) {
    final questsAsync = ref.watch(fullGuildQuestPoolProvider);
    final completedAsync = ref.watch(completedGuildQuestsProvider);
    final activeAsync = ref.watch(activeMissionsProvider);
    final progress = ref.watch(userProgressProvider).value ?? {};
    final playerRank = (progress['game_rank'] as String?) ?? 'E';
    final recommendedRank = CefrRank.gameRankFromCefr((progress['level_code'] as String?) ?? 'A1');

    // Map questId -> mission activa (para progreso + estado "en progreso").
    final activeByQuestId = <String, MissionInstance>{};
    for (final m in activeAsync.value ?? const <MissionInstance>[]) {
      if (m.questId != null) activeByQuestId[m.questId!] = m;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.guildTable,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TABLÓN DE MISIONES',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'AVENTURERO · RANGO $playerRank',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              letterSpacing: 1.0,
                              color: AppColors.medievalAgedGoldLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Toggle CUMPLIDAS (historial) ───────────────────────
                    GestureDetector(
                      onTap: () => setState(() => _showCompleted = !_showCompleted),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showCompleted
                              ? AppColors.royalGold.withValues(alpha: 0.18)
                              : AppColors.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _showCompleted ? AppColors.royalGold : AppColors.onSurface.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          _showCompleted ? '✓ CUMPLIDAS' : 'CUMPLIDAS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: _showCompleted ? AppColors.royalGold : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Filtros ───────────────────────────────────────────────────
              if (!_showCompleted) ...[
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _chip('TODAS', 'all', _filter, (v) { _filter = v; _resetPagination(); }),
                      _chip('DIARIAS', 'daily', _filter, (v) { _filter = v; _resetPagination(); }),
                      _chip('SEMANALES', 'weekly', _filter, (v) { _filter = v; _resetPagination(); }),
                      _chip('COLABORATIVAS', 'collaborative', _filter, (v) { _filter = v; _resetPagination(); }),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Filtro por rareza
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _chip('RARO: TODAS', 'all', _rarityFilter, (v) { _rarityFilter = v; _resetPagination(); }),
                      for (final r in QuestRarity.values)
                        _chip(
                          r.label,
                          r.name,
                          _rarityFilter,
                          (v) { _rarityFilter = v; _resetPagination(); },
                        ),
                    ],
                  ),
                ),
                // ── Búsqueda por texto ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) { _searchQuery = v; _resetPagination(); },
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar misión por nombre...',
                      hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ── Contenido ────────────────────────────────────────────────
              Expanded(
                child: _showCompleted
                    ? _buildCompletedGrid(completedAsync, playerRank)
                    : _buildQuestGrid(questsAsync, activeByQuestId, playerRank, recommendedRank),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestGrid(
    AsyncValue<List<GuildQuest>> questsAsync,
    Map<String, MissionInstance> activeByQuestId,
    String playerRank,
    String recommendedRank,
  ) {
    return questsAsync.when(
      loading: () => const MissionBoardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (quests) {
        final filtered = _applyFilters(quests);
        final sorted = _sortSmart(filtered, playerRank, recommendedRank);
        if (sorted.isEmpty) {
          return Center(
            child: Text(
              'No hay misiones del gremio con estos filtros.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          );
        }
        // Número razonable de pergaminos visibles (paginación incremental).
        final visible = sorted.take(_visibleCount).toList();
        final hasMore = sorted.length > _visibleCount;
        return Column(
          children: [
            Expanded(
              child: _buildGrid(visible, playerRank, recommendedRank, activeByQuestId),
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _visibleCount += _pageSize),
                    icon: const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.medievalAgedGoldLight),
                    label: Text(
                      'VER MÁS MISIONES (${sorted.length - _visibleCount} restantes)',
                      style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.medievalAgedGoldLight, letterSpacing: 0.6),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.medievalAgedGold.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCompletedGrid(
    AsyncValue<List<GuildQuest>> completedAsync,
    String playerRank,
  ) {
    return completedAsync.when(
      loading: () => const MissionBoardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (completed) {
        if (completed.isEmpty) {
          return Center(
            child: Text(
              'Aún no has completado misiones del gremio.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          );
        }
        // Historial: todas marcadas como completadas.
        final recommendedRank = CefrRank.gameRankFromCefr((ref.read(userProgressProvider).value?['level_code'] as String?) ?? 'A1');
        return _buildGrid(completed, playerRank, recommendedRank, const {}, forceCompleted: true);
      },
    );
  }

  Widget _buildGrid(
    List<GuildQuest> quests,
    String playerRank,
    String recommendedRank,
    Map<String, MissionInstance> activeByQuestId, {
    bool forceCompleted = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width >= 1000 ? 4 : width >= 650 ? 3 : 2;
        final itemWidth = (width - (cols + 1) * 10) / cols;
        final itemHeight = itemWidth * 1.0;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemCount: quests.length,
          itemBuilder: (context, index) {
            final quest = quests[index];
            final active = activeByQuestId[quest.id];
            final status = forceCompleted
                ? QuestStatus.completed
                : questStatusFor(
                    quest: quest,
                    playerRank: playerRank,
                    isCompleted: false,
                    isActive: active != null,
                    isRecommended: quest.gameRank == recommendedRank,
                  );
            final progress = active != null ? active.progress : null;
            final progressLabel = active != null ? '${active.currentValue}/${active.targetValue}' : null;
            return MissionParchment(
              quest: quest,
              playerRank: playerRank,
              status: status,
              isRecommended: !forceCompleted && status == QuestStatus.recommended,
              isNew: !forceCompleted && status == QuestStatus.available && index < 3,
              progress: progress,
              progressLabel: progressLabel,
              index: index,
              onTap: () => context.push(
                '/guild-quest-detail?questId=${quest.id}',
              ),
            );
          },
        );
      },
    );
  }

  Widget _chip(String label, String value, String current, ValueChanged<String> onTap) {
    final isActive = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? AppColors.medievalAgedGold.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isActive ? AppColors.medievalAgedGold : AppColors.onSurface.withValues(alpha: 0.12)),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.medievalAgedGoldLight : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
