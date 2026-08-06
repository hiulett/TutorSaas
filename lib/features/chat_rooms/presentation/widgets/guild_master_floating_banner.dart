import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/chat_rooms_providers.dart';

/// NPC Maestre de Mesa (Fase 7 · G-F) — control flotante arrastrable.
///
/// Reemplaza el banner estático: el NPC flota sobre el Salón del Gremio (como
/// el monstruo del chat), muestra la imagen del Oráculo y, al expandirse,
/// revela la sugerencia de mesa según el nivel CEFR del aventurero.
class GuildMasterFloatingBanner extends ConsumerStatefulWidget {
  const GuildMasterFloatingBanner({super.key});

  @override
  ConsumerState<GuildMasterFloatingBanner> createState() =>
      _GuildMasterFloatingBannerState();
}

class _GuildMasterFloatingBannerState extends ConsumerState<GuildMasterFloatingBanner>
    with SingleTickerProviderStateMixin {
  Offset _position = const Offset(16, 120);
  bool _isExpanded = false;

  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

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

  void _followSuggestion() {
    final rooms = ref.read(chatRoomsListProvider).value ?? [];
    final keyword = _suggestedRoomKeyword(
      (ref.read(userProgressProvider).value?['level_code'] as String? ?? 'A1'),
    );
    final target = rooms
        .where((r) => (r['title'] as String? ?? '').contains(keyword))
        .toList();
    if (target.isNotEmpty) {
      context.push('/voice-room?roomId=${target.first['id']}');
    } else if (rooms.isNotEmpty) {
      context.push('/voice-room?roomId=${rooms.first['id']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider).value ?? {};
    final cefr = progress['level_code'] as String? ?? 'A1';
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = (_position.dx + details.delta.dx)
                .clamp(10.0, screenSize.width - 230.0);
            final newY = (_position.dy + details.delta.dy)
                .clamp(70.0, screenSize.height - 260.0);
            _position = Offset(newX, newY);
          });
        },
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final floatY = sin(_floatController.value * pi * 2) * 4.0;
            return Transform.translate(
              offset: Offset(0, floatY),
              child: _isExpanded ? _buildExpanded(cefr) : _buildCollapsed(cefr),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCollapsed(String cefr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.monsterPillBg.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.royalGold, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: AppColors.royalGold.withValues(alpha: 0.45),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/avatars/oracle_01.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MAESTRE DE MESA',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.royalGold,
                ),
              ),
              Text(
                'RANGO SSS · Nivel $cefr',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.drag_indicator_rounded,
              color: AppColors.onSurface, size: 14),
        ],
      ),
    );
  }

  Widget _buildExpanded(String cefr) {
    return SizedBox(
      width: 230,
      child: GlassCard(
        borderColor: AppColors.royalGold.withValues(alpha: 0.5),
        showRunicCorners: true,
        runicColor: AppColors.royalGold,
        padding: const EdgeInsets.all(12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/avatars/oracle_01.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAESTRE DE MESA',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.royalGold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'RANGO SSS · Nivel $cefr',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.onSurface, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _suggestForLevel(cefr),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _followSuggestion,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.royalGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
              ),
              child: Text(
                'SIGUE MI SUGERENCIA →',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalGold,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
