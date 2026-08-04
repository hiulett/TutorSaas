import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/data/models/hunter_catalog.dart';
import '../providers/chat_rooms_providers.dart';

/// NPC Maestre de Mesa (Fase 7 · G-F).
/// Da la bienvenida al Gran Salón y sugiere una mesa según el nivel CEFR
/// del jugador. Reutiliza HunterCatalog.oracle como NPC del gremio.
class GuildMasterNpcBanner extends ConsumerWidget {
  const GuildMasterNpcBanner({super.key});

  String _suggestForLevel(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'A1':
      case 'A2':
        return 'Recomiendo la Taberna del Aprendiz: es la mesa perfecta para cazadores novatos.';
      case 'B1':
      case 'B2':
        return 'La Mesa Redonda de Tácticas te espera: debates y fluidez intermedia.';
      case 'C1':
      case 'C2':
        return 'El Consejo Supremo de Altos Cazadores es tu lugar: elocuencia de nivel maestro.';
      default:
        return 'Elige una mesa y comienza tu raid de conversación.';
    }
  }

  String _suggestedRoomKeyword(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'A1':
      case 'A2':
        return 'Aprendiz';
      case 'B1':
      case 'B2':
        return 'Tácticas';
      case 'C1':
      case 'C2':
        return 'Consejo';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider).value ?? {};
    final cefr = progress['level_code'] as String? ?? 'A1';
    final roomsAsync = ref.watch(chatRoomsListProvider);
    final suggestion = _suggestForLevel(cefr);
    final keyword = _suggestedRoomKeyword(cefr);
    final oracle = HunterCatalog.oracle;

    return GlassCard(
      borderColor: AppColors.royalGold.withValues(alpha: 0.5),
      showRunicCorners: true,
      runicColor: AppColors.royalGold,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.royalGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
            ),
            child: Text('🔮', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAESTRE DE MESA · RANGO ${oracle.level}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.royalGold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.7), height: 1.4),
                ),
                if (keyword.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      final rooms = roomsAsync.value ?? [];
                      final target = rooms.where((r) => (r['title'] as String? ?? '').contains(keyword)).toList();
                      if (target.isNotEmpty) {
                        context.push('/voice-room?roomId=${target.first['id']}');
                      } else if (rooms.isNotEmpty) {
                        context.push('/voice-room?roomId=${rooms.first['id']}');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.royalGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'SIGUE MI SUGERENCIA →',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
