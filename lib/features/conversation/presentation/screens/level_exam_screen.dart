import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../dashboard/data/models/hunter_catalog.dart';
import '../../../../l10n/app_localizations.dart';

class LevelExamScreen extends StatefulWidget {
  final String levelCode; // A1, A2, B1, B2, C1, C2

  const LevelExamScreen({
    super.key,
    this.levelCode = 'A1',
  });

  @override
  State<LevelExamScreen> createState() => _LevelExamScreenState();
}

class _LevelExamScreenState extends State<LevelExamScreen> {
  late Timer _examTimer;
  int _secondsRemaining = 180; // 3 min default for A1
  bool _isSpeaking = true;
  bool _isExamFinished = false;
  int _examScore = 85;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _getExamDurationSeconds(widget.levelCode);
    _startExamTimer();
  }

  int _getExamDurationSeconds(String level) {
    switch (level.toUpperCase()) {
      case 'A1': return 180; // 3 min
      case 'A2': return 240; // 4 min
      case 'B1': return 300; // 5 min
      case 'B2': return 360; // 6 min
      case 'C1': return 420; // 7 min
      case 'C2': return 480; // 8 min
      default: return 180;
    }
  }

  void _startExamTimer() {
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _finishExam();
      } else {
        setState(() {
          _secondsRemaining--;
          _isSpeaking = timer.tick % 4 < 2;
        });
      }
    });
  }

  void _finishExam() {
    setState(() {
      _isExamFinished = true;
    });
  }

  String _bossNameForLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
      case 'A2':
        return 'GOBLIN DE LA GRAMÁTICA';
      case 'B1':
      case 'B2':
        return 'ESPECTRO DE LA SINTAXIS';
      case 'C1':
      case 'C2':
        return 'DRAGÓN DEL ABISMO LÉXICO';
      default:
        return 'GOBLIN DE LA GRAMÁTICA';
    }
  }

  IconData _bossIconForLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
      case 'A2':
        return Icons.pest_control_rounded;
      case 'B1':
      case 'B2':
        return Icons.dark_mode_rounded;
      case 'C1':
      case 'C2':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.pest_control_rounded;
    }
  }

  Color _bossAccentForLevel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
      case 'A2':
        return AppColors.emeraldGreen;
      case 'B1':
      case 'B2':
        return AppColors.manaCyan;
      case 'C1':
      case 'C2':
        return AppColors.royalGold;
      default:
        return AppColors.emeraldGreen;
    }
  }

  Widget _buildBossHeader(String level) {
    final accent = _bossAccentForLevel(level);
    final health = (_examScore / 100).clamp(0.0, 1.0).toDouble();

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      borderColor: accent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accent, width: 1.5),
            ),
            child: Icon(_bossIconForLevel(level), color: accent, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _bossNameForLevel(level),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      level,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accent.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'GUARDIÁN DEL REINO DEL VERBO — RANGO CEFR',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    color: AppColors.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedBar(
                  value: health,
                  segments: 10,
                  color: accent,
                  height: 8,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HP',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    Text(
                      '$_examScore%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _examTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.levelCode.toUpperCase();
    final boss = HunterCatalog.floorBosses.firstWhere(
      (b) => b.level.toUpperCase() == level,
      orElse: () => HunterCatalog.floorBosses.first,
    );

    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.arenaVoid,
      body: CyberManhwaBackground(
        isBossArena: true,
        child: Stack(
          children: [
            // Background Boss Avatar Video Feed
            Positioned.fill(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.crimsonRed.withValues(alpha: 0.25),
                          AppColors.arenaVoid,
                        ],
                        radius: 1.2,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.crimsonRed.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.crimsonRed, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.crimsonRed.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(boss.avatarUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.voidBg.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.crimsonRed),
                        ),
                        child: Column(
                          children: [
                            Text(
                              boss.name.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.crimsonRed,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              boss.description,
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Header Overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.crimsonRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.crimsonRed),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.gpp_bad_rounded, color: AppColors.crimsonRed, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'FLOOR GUARDIAN RAID: $level',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.runeViolet.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.manaCyan),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, color: AppColors.manaCyan, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                timeStr,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.manaCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Boss Header: narrative boss for the target CEFR range
                    _buildBossHeader(level),
                  ],
                ),
              ),
            ),

            // Student Picture-in-Picture Floating Video
            Positioned(
              right: 20,
              bottom: 120,
              child: Container(
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.manaCyan, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.voidBg.withValues(alpha: 0.54), blurRadius: 10),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.person_rounded, color: AppColors.onSurface.withValues(alpha: 0.38), size: 40),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Text(
                          'YOU (HUNTER)',
                          style: TextStyle(fontSize: 9, color: AppColors.onSurface, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Control Actions
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.exam_mute, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
                        foregroundColor: AppColors.onSurface,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _finishExam,
                      icon: const Icon(Icons.call_end_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.exam_conclude, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.crimsonRed,
                        foregroundColor: AppColors.onSurface,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Exam Results Overlay Modal if Finished
            if (_isExamFinished)
              Container(
                color: AppColors.voidBg.withValues(alpha: 0.87),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _examScore >= 80 ? 'RAID CLEAR: STAGE CONQUERED!' : 'RAID FAILED: TARGET SURVIVED',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _examScore >= 80 ? AppColors.triumphGold : AppColors.crimsonRed,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Fluency Score: $_examScore%',
                          style: GoogleFonts.jetBrainsMono(fontSize: 16, color: AppColors.onSurface, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (_examScore >= 80)
                          Text(
                            'Congratulations Hunter! You have defeated ${boss.name} and opened the gate to the next floor.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.7)),
                          )
                        else
                          Text(
                            'You must review the red-marked vocabulary & speech segments to re-attempt the gate.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.crimsonRed),
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.runeViolet,
                            foregroundColor: AppColors.onSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                          ),
                          child: Text(AppLocalizations.of(context)!.exam_return, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                        ),
                      ],
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
