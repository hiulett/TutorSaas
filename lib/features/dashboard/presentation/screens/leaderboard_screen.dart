import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Ranking semanal de cazadores: top 20 por XP vía RPC segura `get_leaderboard`
/// (SECURITY DEFINER) que solo expone user_id + xp_points, sin abrir la tabla.
final weeklyLeaderboardProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase.rpc('get_leaderboard', params: {'p_limit': 20});
    return List<Map<String, dynamic>>.from(res as List);
  } catch (e, s) {
    debugPrint('LeaderboardScreen: error al cargar el ranking ($e)\n$s');
    return [];
  }
});

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(weeklyLeaderboardProvider);
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.guildHall,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              Expanded(
                child: leaderboardAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.manaCyan),
                  ),
                  error: (error, stackTrace) => _buildEmptyState(),
                  data: (entries) {
                    if (entries.isEmpty) return _buildEmptyState();
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) => _buildRankEntry(
                        index,
                        entries[index],
                        currentUserId,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            tooltip: 'Volver',
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RANKING DE CAZADORES',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalGold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Temporada semanal',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: AppColors.royalGold.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'AÚN NO HAY CAZADORES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankEntry(
    int index,
    Map<String, dynamic> entry,
    String? currentUserId,
  ) {
    final rank = index + 1;
    final isCurrentUser =
        currentUserId != null && entry['user_id'] == currentUserId;
    final hunterTag = _shortenHunterId(entry['user_id'] as String? ?? '');
    final xp = (entry['xp_points'] as num?)?.toInt() ?? 0;

    if (rank <= 3) {
      final accentColor = isCurrentUser
          ? AppColors.runeViolet
          : (rank == 1
              ? AppColors.royalGold
              : rank == 2
                  ? AppColors.manaCyan
                  : AppColors.emeraldGreen);
      final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
      return GlassCard(
        borderColor: accentColor,
        borderRadius: 4,
        showRunicCorners: rank == 1,
        runicColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: _buildRowContent(
          rank: rank,
          hunterTag: hunterTag,
          xp: xp,
          accentColor: accentColor,
          isCurrentUser: isCurrentUser,
          medal: medal,
        ),
      );
    }

    final row = _buildRowContent(
      rank: rank,
      hunterTag: hunterTag,
      xp: xp,
      accentColor: AppColors.manaCyan,
      isCurrentUser: isCurrentUser,
    );
    if (isCurrentUser) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.runeViolet.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.runeViolet),
          borderRadius: BorderRadius.circular(4),
        ),
        child: row,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.onSurface.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: row,
    );
  }

  Widget _buildRowContent({
    required int rank,
    required String hunterTag,
    required int xp,
    required Color accentColor,
    required bool isCurrentUser,
    String? medal,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            medal ?? '$rank',
            textAlign: TextAlign.center,
            style: medal != null
                ? const TextStyle(fontSize: 20)
                : GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            hunterTag,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
              color: isCurrentUser ? AppColors.runeVioletText : AppColors.onSurface,
            ),
          ),
        ),
        if (isCurrentUser) ...[
          const SizedBox(width: 6),
          Text(
            'TÚ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.runeViolet,
            ),
          ),
        ],
        const SizedBox(width: 8),
        Text(
          '$xp XP',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  String _shortenHunterId(String userId) {
    if (userId.isEmpty) return '???';
    return userId.length <= 8 ? userId.toUpperCase() : userId.substring(0, 8).toUpperCase();
  }
}
