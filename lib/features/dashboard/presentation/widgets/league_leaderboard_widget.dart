import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../l10n/app_localizations.dart';

class LeagueLeaderboardWidget extends StatelessWidget {
  final String activeLeague;
  final int userRank;
  final int userXp;
  final String userLevelCode;

  /// Datos reales del leaderboard (desde `get_leaderboard`). Si está vacío,
  /// se muestran entradas de demostración (fallback visual).
  final List<Map<String, dynamic>> entries;

  const LeagueLeaderboardWidget({
    super.key,
    this.activeLeague = 'Liga de Nivel',
    required this.userRank,
    required this.userXp,
    this.userLevelCode = 'B1',
    this.entries = const [],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String level = userLevelCode.toUpperCase();
    final String youName = l10n?.league_you ?? 'Tú (Estudiante)';

    final List<Map<String, dynamic>> leaderboard = entries.isNotEmpty
        ? entries.take(5).toList()
        : [
            {'rank': 1, 'name': 'Elena Rostova', 'xp': 3240, 'stars': 15, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Elena', 'isUser': false},
            {'rank': 2, 'name': youName, 'xp': userXp, 'stars': 12, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Profile', 'isUser': true},
            {'rank': 3, 'name': 'Marco Silva', 'xp': 2890, 'stars': 9, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Marco', 'isUser': false},
            {'rank': 4, 'name': 'Sophie Martin', 'xp': 2100, 'stars': 7, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Sophie', 'isUser': false},
            {'rank': 5, 'name': 'Klaus Webber', 'xp': 1850, 'stars': 5, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Klaus', 'isUser': false},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.trophyGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n?.league_ranking(activeLeague) ?? 'Clasificación $activeLeague',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.runeViolet.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.runeViolet.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                l10n?.league_top5(level) ?? 'Top 5 • Nivel $level',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.manaCyan,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        GlassCard(
          blur: 20,
          opacity: AppColors.glassOpacity,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ...leaderboard.map((student) {
                final isUser = student['isUser'] as bool;
                final rank = student['rank'] as int;
                final stars = student['stars'] as int;

                Color rankColor = AppColors.onSurface.withValues(alpha: 0.54);
                if (rank == 1) rankColor = AppColors.trophyGold;
                if (rank == 2) rankColor = AppColors.trophySilver;
                if (rank == 3) rankColor = AppColors.trophyBronze;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.runeViolet.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: isUser
                            ? Border.all(color: AppColors.runeViolet.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: rankColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          RpgAvatar(
                            avatarUrl: student['avatar'] as String?,
                            initials: (student['name'] as String).substring(0, 1),
                            size: 28,
                            hunterClass: rank == 1 ? 'legendary' : (rank == 2 ? 'epic' : 'rare'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              student['name'] as String,
                              style: TextStyle(
                                fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
                                color: isUser
                                    ? AppColors.onSurface
                                    : AppColors.onSurface.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.royalGold, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '$stars',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.royalGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${student['xp']} XP',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              color: AppColors.manaCyan,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (rank == 3) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.manaCyan, thickness: 1)),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '🔝 LÍNEA DE ASCENSO A NIVEL SUPERIOR',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.manaCyan,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.manaCyan, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
