import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../dashboard/data/models/hunter_catalog.dart';

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
      backgroundColor: const Color(0xFF04060C),
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
                        Colors.redAccent.withValues(alpha: 0.25),
                        const Color(0xFF04060C),
                      ],
                      radius: 1.2,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 110,
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.4),
                      child: CircleAvatar(
                        radius: 102,
                        backgroundImage: NetworkImage(boss.avatarUrl),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Column(
                        children: [
                          Text(
                            boss.name,
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            boss.description,
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          'PRUEBA DEL GUARDIÁN DEL PISO $level',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tertiaryTeal),
                    ),
                    child: Text(
                      '⏱️ $timeStr',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiaryTeal,
                      ),
                    ),
                  ),
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
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tertiaryTeal, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.person_rounded, color: Colors.white38, size: 40),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Text(
                        'Tú (Cazador)',
                        style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
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
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'mic_mute',
                    backgroundColor: Colors.white24,
                    onPressed: () {},
                    child: const Icon(Icons.mic_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton.large(
                    heroTag: 'end_exam',
                    backgroundColor: Colors.redAccent,
                    onPressed: _finishExam,
                    child: const Icon(Icons.call_end_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Exam Results Overlay Modal if Finished
          if (_isExamFinished)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: GlassCard(
                  blur: 20,
                  opacity: 0.1,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _examScore >= 80 ? '🎉 ¡PRUEBA DE PISO SUPERADA!' : '🚨 PRUEBA INCOMPLETA',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _examScore >= 80 ? const Color(0xFFFFD700) : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Puntaje Obtenido: $_examScore%',
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_examScore >= 80)
                        Text(
                          '¡Felicidades Cazador! Has derrotado al ${boss.name} y abierto el portal al Piso siguiente.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        )
                      else
                        const Text(
                          'Debes repasar las lecciones marcadas en rojo para reintentar la prueba.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.redAccent),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Volver al Santuario', style: TextStyle(fontWeight: FontWeight.bold)),
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
