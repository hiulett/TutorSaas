import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../../features/dashboard/data/models/hunter_catalog.dart';

class DraggableMonsterWidget extends StatefulWidget {
  final DungeonMonsterItem monster;
  final bool isSpeaking;
  final double progress; // Value from 0.0 to 1.0 (deals damage to boss HP)
  final Function(bool isExpanded)? onExpandChanged;

  const DraggableMonsterWidget({
    super.key,
    required this.monster,
    this.isSpeaking = false,
    this.progress = 0.0,
    this.onExpandChanged,
  });

  @override
  State<DraggableMonsterWidget> createState() => _DraggableMonsterWidgetState();
}

class _DraggableMonsterWidgetState extends State<DraggableMonsterWidget>
    with TickerProviderStateMixin {
  Offset _position = const Offset(20, 110);
  bool _isExpanded = false;

  late AnimationController _floatController;
  late AnimationController _breatheController;
  late AnimationController _speakingWaveController;
  late AnimationController _runeRotateController;

  @override
  void initState() {
    super.initState();

    // 1. Continuous Floating Sine Wave Motion (Up & Down Bounce)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 2. Breathing Life Cycle Pulse (Scale 1.0 to 1.07)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 3. Audio Wave Pulsing when speaking
    _speakingWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // 4. Rotating Magic Pentagram Circle
    _runeRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _breatheController.dispose();
    _speakingWaveController.dispose();
    _runeRotateController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (widget.onExpandChanged != null) {
      widget.onExpandChanged!(_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_isExpanded) {
      // Expanded State: Fullscreen Dynamic Live Animated Monster Overlay behind chat
      return Positioned.fill(
        child: GestureDetector(
          onTap: _toggleExpand,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _floatController,
              _breatheController,
              _speakingWaveController,
              _runeRotateController,
            ]),
            builder: (context, child) {
              final floatOffsetY = sin(_floatController.value * pi * 2) * 12.0;
              final breatheScale = 0.96 + (_breatheController.value * 0.08);
              final speakingExtra = widget.isSpeaking
                  ? (_speakingWaveController.value * 0.12)
                  : 0.0;
              final finalScale = breatheScale + speakingExtra;

              return Container(
                color: AppColors.voidBg.withValues(alpha: 0.80),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating Magic Pentagram behind Monster
                    Transform.rotate(
                      angle: _runeRotateController.value * 2 * pi,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.monster.isBoss
                                ? AppColors.crimsonRed.withValues(alpha: 0.4)
                                : AppColors.runeViolet.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.monster.isBoss
                                  ? AppColors.crimsonRed.withValues(alpha: 0.3)
                                  : AppColors.runeViolet.withValues(alpha: 0.3),
                              blurRadius: 90,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live Animated Floating Monster Avatar
                    Transform.translate(
                      offset: Offset(0, floatOffsetY),
                      child: Transform.scale(
                        scale: finalScale,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    widget.monster.isBoss ? AppColors.crimsonRed : AppColors.runeViolet,
                                    AppColors.manaCyan,
                                    widget.monster.isBoss ? AppColors.royalGold : AppColors.manaCyan,
                                    widget.monster.isBoss ? AppColors.crimsonRed : AppColors.runeViolet,
                                  ],
                                  transform: GradientRotation(_runeRotateController.value * 2 * pi),
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 95,
                                backgroundColor: AppColors.monsterAvatarBg,
                                child: CircleAvatar(
                                  radius: 90,
                                  backgroundImage: NetworkImage(widget.monster.avatarUrl),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.voidBg.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                          color: widget.monster.isBoss ? AppColors.crimsonRed : AppColors.manaCyan,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.monster.isBoss ? '🔥 JEFE GUARDIÁN' : '👾 MONSTRUO INSTRUCTOR',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: widget.monster.isBoss ? AppColors.crimsonRed : AppColors.manaCyan,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.monster.name,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Boss HP Bar
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'HP',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.crimsonRed,
                                            ),
                                          ),
                                          Text(
                                            '${((1.0 - widget.progress) * 100).round().clamp(0, 100)}%',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSurface.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 8,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          color: AppColors.onSurface.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.3)),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: (1.0 - widget.progress).clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [AppColors.crimsonRed, AppColors.royalGold],
                                              ),
                                              borderRadius: BorderRadius.circular(AppRadius.sm),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.onSurface.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Text(
                                widget.isSpeaking ? '🎙️ Hablando en vivo...' : '↕️ Toca para colapsar a vista flotante',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    // Collapsed State: Floating Draggable Animated Pill (With Continuous Bounce)
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = (_position.dx + details.delta.dx)
                .clamp(10.0, screenSize.width - 160.0);
            final newY = (_position.dy + details.delta.dy)
                .clamp(60.0, screenSize.height - 190.0);
            _position = Offset(newX, newY);
          });
        },
        onTap: _toggleExpand,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _floatController,
            _breatheController,
            _speakingWaveController,
          ]),
          builder: (context, child) {
            final floatOffsetY = sin(_floatController.value * pi * 2) * 5.0;
            final breatheScale = 0.97 + (_breatheController.value * 0.06);
            final glow = widget.isSpeaking
                ? (8.0 + _speakingWaveController.value * 12.0)
                : (3.0 + _breatheController.value * 3.0);

            return Transform.translate(
              offset: Offset(0, floatOffsetY),
              child: Transform.scale(
                scale: breatheScale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.monsterPillBg.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: widget.monster.isBoss
                          ? AppColors.crimsonRed
                          : (widget.isSpeaking ? AppColors.manaCyan : AppColors.runeViolet),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.monster.isBoss
                            ? AppColors.crimsonRed.withValues(alpha: 0.5)
                            : (widget.isSpeaking
                                ? AppColors.manaCyan.withValues(alpha: 0.6)
                                : AppColors.runeViolet.withValues(alpha: 0.4)),
                        blurRadius: glow * 1.5,
                        spreadRadius: glow / 3,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isSpeaking ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.24),
                            width: 1.2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundImage: NetworkImage(widget.monster.avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.monster.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            widget.isSpeaking ? '🗣️ Enseñando...' : '👾 En Vivo (Toca)',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: widget.isSpeaking ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.drag_indicator_rounded, color: AppColors.onSurface.withValues(alpha: 0.38), size: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
