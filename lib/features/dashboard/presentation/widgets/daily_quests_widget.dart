import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class DailyQuestsWidget extends StatefulWidget {
  final int streakDays;
  final Function(int xpEarned) onClaimReward;

  const DailyQuestsWidget({
    super.key,
    required this.streakDays,
    required this.onClaimReward,
  });

  @override
  State<DailyQuestsWidget> createState() => _DailyQuestsWidgetState();
}

class _DailyQuestsWidgetState extends State<DailyQuestsWidget> {
  final List<Map<String, dynamic>> _quests = [
    {
      'id': 'quest_1',
      'title': 'Habla 10 minutos de voz',
      'description': 'Completa una sesión conversacional fluida',
      'icon': '🎙️',
      'current': 7,
      'target': 10,
      'xp': 50,
      'isClaimed': false,
    },
    {
      'id': 'quest_2',
      'title': 'Aprende 5 palabras nuevas',
      'description': 'Acumula vocabulario en tus llamadas',
      'icon': '📚',
      'current': 5,
      'target': 5,
      'xp': 75,
      'isClaimed': false,
    },
    {
      'id': 'quest_3',
      'title': 'Logra >85% en Pronunciación',
      'description': 'Supera una prueba de huella de voz',
      'icon': '🎯',
      'current': 1,
      'target': 1,
      'xp': 100,
      'isClaimed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.manaCyan,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Misiones Diarias',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.streakDays} Días',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._quests.map((quest) {
          final isCompleted = (quest['current'] as int) >= (quest['target'] as int);
          final isClaimed = quest['isClaimed'] as bool;
          final progressRatio = ((quest['current'] as int) / (quest['target'] as int)).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GlassCard(
              blur: 20,
              opacity: 0.05,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(quest['icon'] as String, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quest['description'] as String,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressRatio,
                            minHeight: 4,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted ? const Color(0xFF10B981) : AppColors.runeViolet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isClaimed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
                    )
                  else if (isCompleted)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          quest['isClaimed'] = true;
                        });
                        widget.onClaimReward(quest['xp'] as int);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        '+${quest['xp']} XP',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Text(
                      '${quest['current']}/${quest['target']}',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
