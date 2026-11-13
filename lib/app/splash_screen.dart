import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/segmented_bar.dart';
import '../l10n/app_localizations.dart';
import '../core/telemetry/startup_probe.dart';

/// Splash moderno — Sistema HUD (Isekai/Webtoon).
/// Emblema rúnico pulsante, rejilla de energía, orbes de maná y una barra
/// segmentada que avanza mientras el router decide el destino.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;
  late final Animation<double> _progress;

  /// P-19: la marca se ve un minimo, pero no se espera un tiempo fijo: se
  /// navega cuando el warm-up real termina (con tope de 3 s).
  static const Duration _minSplash = Duration(milliseconds: 500);
  static const Duration _warmupTimeout = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    debugPrint('[Splash] Splash iniciado');
    _controller = AnimationController(
      vsync: this,
      duration: _minSplash,
    )..forward();
    _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    // Calienta la conexión/BD de Supabase durante la animación: en free tier el
    // primer query tras inactividad (p. ej. el perfil del redirect post-login)
    // es lento por el cold start de Postgres. Un query barato aquí lo evita.
    unawaited(_bootstrap());
  }

  /// Query mínimo para despertar el pool/instancia de Supabase. Nunca lanza.
  Future<void> _warmUpBackend() async {
    try {
      await Supabase.instance.client
          .from('user_language_profiles')
          .select('id')
          .limit(1)
          .maybeSingle();
    } catch (_) {/* warm-up best effort */}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final warmupWatch = Stopwatch()..start();
    var timedOut = false;
    final warmUp = _warmUpBackend();
    await Future.wait<void>([
      Future<void>.delayed(_minSplash),
      warmUp.timeout(_warmupTimeout, onTimeout: () {
        timedOut = true;
      }),
    ]);
    warmupWatch.stop();
    StartupProbe.markReady(
      warmupMs: warmupWatch.elapsedMilliseconds,
      timedOut: timedOut,
    );
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          // Orbes de energía
          Positioned(
            top: -120,
            left: -120,
            child: _GlowOrb(
              size: 320,
              color: AppColors.runeViolet.withValues(alpha: 0.28),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -140,
            child: _GlowOrb(
              size: 380,
              color: AppColors.manaCyan.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 140,
            right: -80,
            child: _GlowOrb(
              size: 220,
              color: AppColors.royalGold.withValues(alpha: 0.10),
            ),
          ),

          // Rejilla de energía
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Emblema: puerta de mazmorra trazada (variante B).
                // Sin assets ni degradados: solo trazo, como el resto del HUD.
                ScaleTransition(
                  scale: _pulse,
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: _GatePainter(glow: _controller.value),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Marca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    (AppLocalizations.of(context)?.app_name ?? 'Dungeon of English').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.5,
                      color: AppColors.onSurface,
                      shadows: [
                        Shadow(
                          color: AppColors.manaCyan.withValues(alpha: 0.45),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)?.splash_system_hud ?? 'SISTEMA HUD · DESPERTANDO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                    color: AppColors.manaCyan.withValues(alpha: 0.85),
                  ),
                ),

                const Spacer(),

                // Barra de carga segmentada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, child) => Column(
                      children: [
                        SegmentedBar(
                          value: _progress.value,
                          segments: 14,
                          height: 5,
                          color: AppColors.manaCyan,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)
                                  ?.splash_connecting_realm ??
                              'CONECTANDO AL GRAN REINO',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Variante B: puerta de mazmorra trazada con líneas, sin assets ni degradados.
/// Dos jambas, arco, umbral y un ojo central; el glow late con el controlador.
class _GatePainter extends CustomPainter {
  _GatePainter({required this.glow});

  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final w = size.width;

    final halo = Paint()
      ..color = AppColors.manaCyan.withValues(alpha: 0.14 + 0.18 * glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, w * 0.30, halo);

    final stroke = Paint()
      ..color = AppColors.manaCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final half = w * 0.17;
    final top = center.dy - w * 0.24;
    final bottom = center.dy + w * 0.22;
    final shoulder = top + w * 0.26;

    canvas.drawLine(
      Offset(center.dx - half, bottom),
      Offset(center.dx - half, shoulder),
      stroke,
    );
    canvas.drawLine(
      Offset(center.dx + half, bottom),
      Offset(center.dx + half, shoulder),
      stroke,
    );
    canvas.drawArc(
      Rect.fromLTRB(center.dx - half, top, center.dx + half, top + w * 0.30),
      math.pi,
      math.pi,
      false,
      stroke,
    );
    canvas.drawLine(
      Offset(center.dx - half - w * 0.05, bottom),
      Offset(center.dx + half + w * 0.05, bottom),
      stroke,
    );
    canvas.drawCircle(center, w * 0.030, stroke);
  }

  @override
  bool shouldRepaint(_GatePainter oldDelegate) => oldDelegate.glow != glow;
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.manaCyan.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 34.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
