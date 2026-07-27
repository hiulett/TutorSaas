import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CyberBgMode {
  dynamicLevel,
  onboardingStep0,
  onboardingStep1,
  onboardingStep2,
  onboardingStep3,
  onboardingStep4,
  onboardingStep5,
  onboardingStep6,
  onboardingStep7,
  dashboardGate,
  guildHall,
  guildTable,
  hunterStatus,
}

class CyberManhwaBackground extends StatefulWidget {
  final Widget child;
  final bool isBossArena;
  final String levelCode; // A1, A2, B1, B2, C1, C2
  final CyberBgMode bgMode;

  const CyberManhwaBackground({
    super.key,
    required this.child,
    this.isBossArena = false,
    this.levelCode = 'A1',
    this.bgMode = CyberBgMode.dynamicLevel,
  });

  @override
  State<CyberManhwaBackground> createState() => _CyberManhwaBackgroundState();
}

class _CyberManhwaBackgroundState extends State<CyberManhwaBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _cameraZoomController;
  final List<ManaParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _cameraZoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _initParticles();
  }

  void _initParticles() {
    final Color baseColor = _getPrimaryThemeColor();
    for (int i = 0; i < 35; i++) {
      _particles.add(
        ManaParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 3.5 + 1.2,
          speed: _random.nextDouble() * 0.15 + 0.05,
          color: i % 3 == 0
              ? baseColor.withValues(alpha: _random.nextDouble() * 0.7 + 0.3)
              : (i % 2 == 0
                  ? AppColors.tertiaryTeal.withValues(alpha: _random.nextDouble() * 0.6 + 0.2)
                  : AppColors.primaryPurple.withValues(alpha: _random.nextDouble() * 0.6 + 0.2)),
        ),
      );
    }
  }

  Color _getPrimaryThemeColor() {
    if (widget.isBossArena) return Colors.redAccent;
    switch (widget.bgMode) {
      case CyberBgMode.dashboardGate:
      case CyberBgMode.hunterStatus:
        return AppColors.tertiaryTeal;
      case CyberBgMode.guildHall:
      case CyberBgMode.guildTable:
        return Colors.amberAccent;
      case CyberBgMode.onboardingStep7:
        return const Color(0xFFFFD700);
      default:
        switch (widget.levelCode.toUpperCase()) {
          case 'A1': return const Color(0xFF10B981);
          case 'A2': return const Color(0xFFF59E0B);
          case 'B1': return const Color(0xFF06B6D4);
          case 'B2': return const Color(0xFF8B5CF6);
          case 'C1': return const Color(0xFFEC4899);
          case 'C2': return const Color(0xFFFF4500);
          default: return AppColors.primaryPurple;
        }
    }
  }

  String _getFloorAssetPath() {
    switch (widget.bgMode) {
      case CyberBgMode.onboardingStep0:
        return 'assets/images/onboarding_interview_bg.jpg';
      case CyberBgMode.onboardingStep1:
        return 'assets/images/dungeon_forest_a1_bg.jpg';
      case CyberBgMode.onboardingStep2:
        return 'assets/images/dungeon_ruins_a2_bg.jpg';
      case CyberBgMode.onboardingStep3:
        return 'assets/images/dungeon_wind_b1_bg.jpg';
      case CyberBgMode.onboardingStep4:
        return 'assets/images/cyber_manhwa_portal_bg.jpg';
      case CyberBgMode.onboardingStep5:
        return 'assets/images/dungeon_boss_arena_bg.jpg';
      case CyberBgMode.onboardingStep6:
        return 'assets/images/dungeon_ruins_a2_bg.jpg';
      case CyberBgMode.onboardingStep7:
        return 'assets/images/onboarding_license_delivery_bg.jpg';
      case CyberBgMode.dashboardGate:
        return 'assets/images/dashboard_dungeon_gate_bg.jpg';
      case CyberBgMode.guildHall:
        return 'assets/images/guild_hall_adventurers_bg.jpg';
      case CyberBgMode.guildTable:
        return 'assets/images/guild_table_adventurers_bg.jpg';
      case CyberBgMode.hunterStatus:
        return 'assets/images/hunter_status_matrix_bg.jpg';
      case CyberBgMode.dynamicLevel:
        if (widget.isBossArena) return 'assets/images/dungeon_boss_arena_bg.jpg';
        switch (widget.levelCode.toUpperCase()) {
          case 'A1': return 'assets/images/dungeon_forest_a1_bg.jpg';
          case 'A2': return 'assets/images/dungeon_ruins_a2_bg.jpg';
          case 'B1': return 'assets/images/dungeon_wind_b1_bg.jpg';
          case 'B2': return 'assets/images/cyber_manhwa_portal_bg.jpg';
          case 'C1':
          case 'C2': return 'assets/images/dungeon_boss_arena_bg.jpg';
          default: return 'assets/images/cyber_manhwa_portal_bg.jpg';
        }
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _cameraZoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getFloorAssetPath();
    final themeColor = _getPrimaryThemeColor();

    return Stack(
      children: [
        // 1. Dark Base Void
        Positioned.fill(
          child: Container(
            color: const Color(0xFF04060C),
          ),
        ),

        // 2. Dynamic Animated Floor Image Overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _cameraZoomController,
            builder: (context, child) {
              final scale = 1.0 + sin(_cameraZoomController.value * pi) * 0.05;
              return Transform.scale(
                scale: scale,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            themeColor.withValues(alpha: 0.35),
                            const Color(0xFF04060C),
                          ],
                          radius: 1.3,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // 3. Dark Vignette & Cyber Scanline Grid Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF04060C).withValues(alpha: 0.82),
                  const Color(0xFF04060C).withValues(alpha: 0.65),
                  const Color(0xFF04060C).withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
        ),

        // 4. Animated Rotating Magic Circle & Glowing Rune Array
        Positioned.fill(
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _pulseController]),
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedMagicCirclePainter(
                  rotationProgress: _rotationController.value,
                  pulseProgress: _pulseController.value,
                  color: themeColor,
                ),
              );
            },
          ),
        ),

        // 5. Floating Animated Mana Particle Field
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ManaParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                ),
              );
            },
          ),
        ),

        // 6. Child Screen Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

class ManaParticle {
  double x;
  double y;
  double radius;
  double speed;
  Color color;

  ManaParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });
}

class ManaParticlePainter extends CustomPainter {
  final List<ManaParticle> particles;
  final double progress;

  ManaParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = (particle.y - progress * particle.speed) % 1.0;
      final position = Offset(particle.x * size.width, currentY * size.height);
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ManaParticlePainter oldDelegate) => true;
}

class AnimatedMagicCirclePainter extends CustomPainter {
  final double rotationProgress;
  final double pulseProgress;
  final Color color;

  AnimatedMagicCirclePainter({
    required this.rotationProgress,
    required this.pulseProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final radius = min(size.width, size.height) * 0.38;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.15 + pulseProgress * 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Outer Glowing Ring
    canvas.drawCircle(center, radius, paint);

    // Inner Concentric Ring
    paint.strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.75, paint);
    canvas.drawCircle(center, radius * 0.50, paint);

    // Rotating Star Pentagram
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationProgress * 2 * pi);

    final path = Path();
    const points = 6;
    final angle = (2 * pi) / points;

    for (int i = 0; i < points; i++) {
      final x1 = radius * 0.75 * cos(i * angle);
      final y1 = radius * 0.75 * sin(i * angle);
      final x2 = radius * 0.75 * cos((i + 2) * angle);
      final y2 = radius * 0.75 * sin((i + 2) * angle);

      if (i == 0) {
        path.moveTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();

    paint.color = color.withValues(alpha: 0.12 + pulseProgress * 0.08);
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimatedMagicCirclePainter oldDelegate) => true;
}
