import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class LeagueLeaderboardWidget extends StatelessWidget {
  final String activeLeague;
  final int userRank;
  final int userXp;
  final String userLevelCode;

  const LeagueLeaderboardWidget({
    super.key,
    this.activeLeague = 'Liga de Nivel',
    required this.userRank,
    required this.userXp,
    this.userLevelCode = 'B1',
  });

  @override
  Widget build(BuildContext context) {
    final String level = userLevelCode.toUpperCase();

    final List<Map<String, dynamic>> leaderboard = [
      {'rank': 1, 'name': 'Elena Rostova', 'xp': 3240, 'stars': 15, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Elena', 'isUser': false},
      {'rank': 2, 'name': 'Tú (Estudiante)', 'xp': userXp, 'stars': 12, 'avatar': 'https://api.dicebear.com/7.x/bottts-neutral/png?seed=Profile', 'isUser': true},
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
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Clasificación $activeLeague',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Top 5 • Nivel $level',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        GlassCard(
          blur: 20,
          opacity: 0.05,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              ...leaderboard.map((student) {
                final isUser = student['isUser'] as bool;
                final rank = student['rank'] as int;
                final stars = student['stars'] as int;

                Color rankColor = Colors.white54;
                if (rank == 1) rankColor = const Color(0xFFFFD700);
                if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                if (rank == 3) rankColor = const Color(0xFFCD7F32);

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primaryPurple.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isUser
                            ? Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5))
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
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(student['avatar'] as String),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              student['name'] as String,
                              style: TextStyle(
                                fontWeight: isUser ? FontWeight.bold : FontWeight.w500,
                                color: isUser ? Colors.white : Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '$stars',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${student['xp']} XP',
                            style: GoogleFonts.hankenGrotesk(
                              fontWeight: FontWeight.bold,
                              color: AppColors.tertiaryTeal,
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
                          const Expanded(child: Divider(color: AppColors.tertiaryTeal, thickness: 1)),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '🔝 LÍNEA DE ASCENSO A NIVEL SUPERIOR',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tertiaryTeal,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.tertiaryTeal, thickness: 1)),
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
