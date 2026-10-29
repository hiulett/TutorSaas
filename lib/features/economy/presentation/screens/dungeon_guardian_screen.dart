import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';
import '../widgets/mana_item_inventory.dart';
import '../../domain/models/mana_budget.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../vocabulary/presentation/widgets/srs_flashcard_modal.dart';

/// 🏰 GUARDIÁN DE LA MAZMORRA — versión épica.
///
/// Bloquea el acceso a las mazmorras cuando el cazador no tiene maná. Incluye:
/// - Hero cinematográfico con el Guardián y un sello rúnico pulsante.
/// - Anillo de runas giratorio + partículas de energía (respetan reduce-motion).
/// - Contador de maná con barra segmentada y animación.
/// - CTAs de acción (obtener maná, equipar elixir, volver al gremio).
class DungeonGuardianScreen extends ConsumerStatefulWidget {
  const DungeonGuardianScreen({super.key});

  @override
  ConsumerState<DungeonGuardianScreen> createState() =>
      _DungeonGuardianScreenState();
}

class _DungeonGuardianScreenState extends ConsumerState<DungeonGuardianScreen>
    with TickerProviderStateMixin {
  bool _showInventory = false;

  late final AnimationController _pulseController;
  late final AnimationController _ringController;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!_pulseController.isAnimating && !_reduceMotion) {
      _pulseController.repeat(reverse: true);
      _ringController.repeat();
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final manaAsync = ref.watch(manaStateProvider);
    final mana =
        manaAsync.value ??
        const {
          'allowance': 3000,
          'purchased': 0,
          'used': 0,
          'remaining': 3000,
          'expires_at': null,
          'plan': 'Plan Gratuito',
          'is_free': true,
          'daily_limit': 200,
          'daily_used': 0,
          'daily_remaining': 200,
        };

    final bool isFree = mana['is_free'] as bool? ?? true;
    final int allowance = mana['allowance'] as int? ?? 3000;
    final int purchased = mana['purchased'] as int? ?? 0;
    final int remaining = mana['remaining'] as int? ?? 0;
    final int dailyRemaining = mana['daily_remaining'] as int? ?? 0;

    // Qué muestra el contador según el plan (igual que OracleManaBar).
    final int barValue = isFree ? dailyRemaining : remaining;
    final int barMax = isFree
        ? (mana['daily_limit'] as int? ?? 200)
        : allowance + purchased;
    final double progress = barMax > 0
        ? (barValue / barMax).clamp(0.0, 1.0)
        : 0.0;

    // P-26: cuándo se recarga y qué se puede hacer sin maná.
    final budget = ManaBudget.fromState(mana);
    final refill = budget.refillIn(DateTime.now());

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.dashboardGate,
        child: Stack(
          children: [
            // ── Resplandores ambientales (glow de bloqueo) ──
            Positioned(
              top: -140,
              left: -140,
              child: _GlowOrb(
                size: 360,
                color: AppColors.crimsonRed,
                controller: _pulseController,
              ),
            ),
            Positioned(
              bottom: -140,
              right: -140,
              child: _GlowOrb(
                size: 380,
                color: AppColors.runeViolet,
                controller: _pulseController,
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Cabecera ──
                    Row(
                      children: [
                        _RoundIconButton(
                          onTap: () {
                            if (context.canPop()) Navigator.pop(context);
                            context.go('/home');
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.guardian_title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: AppColors.royalGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── HERO cinematográfico ──
                    _buildHero(context, l10n),
                    const SizedBox(height: 22),

                    // ── Grito del Guardián ──
                    Text(
                      l10n.guardian_cry,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.crimsonRed,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: AppColors.crimsonRed.withValues(alpha: 0.6),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.guardian_desc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Contador de maná con barra segmentada ──
                    _buildManaPanel(context, l10n, barValue, barMax, progress),
                    const SizedBox(height: 24),

                    // ── CTA 1: Obtener maná ──
                    RunicButton(
                      label: l10n.guardian_get_mana,
                      icon: Icons.workspace_premium_rounded,
                      onPressed: () => context.push('/paywall'),
                      backgroundColor: AppColors.manaCyan,
                      foregroundColor: AppColors.voidBg,
                    ),
                    const SizedBox(height: 12),

                    // ── CTA 2: Inventario equipable ──
                    _buildInventoryToggle(context, l10n),
                    if (_showInventory) ...[
                      const SizedBox(height: 12),
                      const ManaItemInventory(),
                    ],

                    _buildAlternatives(context, l10n, budget, refill),
                    const SizedBox(height: 14),

                    // ── CTA 3: Volver al gremio ──
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) Navigator.pop(context);
                        context.go('/home');
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(
                        l10n.guardian_go_back,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hero: imagen del Guardián + anillo de runas giratorio + sello pulsante.
  Widget _buildHero(BuildContext context, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 360,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            Image.asset(
              'assets/images/dungeon_guardian.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Center(
                  child: Icon(
                    Icons.no_accounts_rounded,
                    color: AppColors.crimsonRed,
                    size: 80,
                  ),
                ),
              ),
            ),

            // Vineta cinematográfica
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    AppColors.voidBg.withValues(alpha: 0.35),
                    AppColors.voidBg.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),

            // Anillo de runas giratorio (decorativo)
            Positioned(
              right: -30,
              top: 18,
              child: AnimatedBuilder(
                animation: _ringController,
                builder: (context, child) => Transform.rotate(
                  angle: _ringController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: _RuneRingPainter(
                      color: AppColors.manaCyan.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),

            // Sello de bloqueo pulsante (superior)
            Positioned(
              top: 14,
              right: 14,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final glow = _pulseController.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonRed.withValues(
                        alpha: 0.75 + glow * 0.2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.crimsonRed.withValues(
                          alpha: 0.6 + glow * 0.4,
                        ),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.crimsonRed.withValues(
                            alpha: 0.4 + glow * 0.3,
                          ),
                          blurRadius: 18,
                          spreadRadius: glow * 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: AppColors.onSurface,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.guardian_sealed.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Texto en el hero: "SIN ENERGÍA" dramático
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⚠', style: GoogleFonts.jetBrainsMono(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.guardian_sealed.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.crimsonRed,
                        shadows: [
                          Shadow(
                            color: AppColors.crimsonRed.withValues(alpha: 0.7),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Panel de maná con barra segmentada y animación de contador.
  Widget _buildManaPanel(
    BuildContext context,
    AppLocalizations l10n,
    int value,
    int max,
    double progress,
  ) {
    final exhausted = value <= 0;
    final color = exhausted ? AppColors.crimsonRed : AppColors.manaCyan;

    return GlassCard(
      blur: 6,
      opacity: 0.96,
      borderColor: color.withValues(alpha: 0.45),
      showRunicCorners: true,
      runicColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.runeViolet,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.mana_label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '$value / $max',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedBar(value: progress, segments: 20, height: 8, color: color),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                exhausted
                    ? (l10n.guardian_sealed.toUpperCase())
                    : '${l10n.mana_daily_available}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: exhausted ? AppColors.crimsonRed : AppColors.manaCyan,
                ),
              ),
              const Spacer(),
              Text(
                '$value ⚡',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.manaCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryToggle(BuildContext context, AppLocalizations l10n) {
    return GlassCard(
      blur: 4,
      opacity: 0.94,
      border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4)),
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: InkWell(
          onTap: () => setState(() => _showInventory = !_showInventory),
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.runeViolet.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.local_drink_rounded,
                  color: AppColors.runeViolet,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.guardian_equip_item,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.guardian_equip_item_desc,
                      style: const TextStyle(
                        color: AppColors.runeViolet,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _showInventory
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: AppColors.runeViolet,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// P-26: mientras no hay mana, ofrecer alternativas reales.
  Widget _buildAlternatives(
    BuildContext context,
    AppLocalizations l10n,
    ManaBudget budget,
    Duration? refill,
  ) {
    final lowCost = budget.available >= 8;
    final refillText = refill == null
        ? null
        : budget.isFree
        ? l10n.guardian_refill_in(refill.inHours, refill.inMinutes % 60)
        : l10n.guardian_refill_at(
            '${budget.expiresAt?.day.toString().padLeft(2, '0')}/'
            '${budget.expiresAt?.month.toString().padLeft(2, '0')}',
          );

    return GlassCard(
      blur: 6,
      opacity: 0.95,
      borderColor: AppColors.runeViolet.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.guardian_alternative_title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.runeViolet,
            ),
          ),
          if (refillText != null) ...[
            const SizedBox(height: 6),
            Text(
              refillText,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openVocabularyReview(context, l10n),
            icon: const Icon(Icons.style_rounded, size: 18),
            label: Text(l10n.guardian_review_vocab),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 44),
              foregroundColor: AppColors.manaCyan,
              side: BorderSide(
                color: AppColors.manaCyan.withValues(alpha: 0.5),
              ),
            ),
          ),
          if (lowCost) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/conversation'),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: Text(l10n.guardian_low_cost_chat(8)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 44),
                foregroundColor: AppColors.runeViolet,
                side: BorderSide(
                  color: AppColors.runeViolet.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openVocabularyReview(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final due =
        ref.read(dueVocabularyProvider).value ?? const <Map<String, dynamic>>[];
    if (due.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.guardian_no_due_words)));
      return;
    }
    await SrsFlashcardModal.show(context, due.take(10).toList());
    ref.invalidate(dueVocabularyProvider);
  }
}

/// Orbe de resplandor pulsante (decorativo).
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final AnimationController controller;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final v = controller.value;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.18 + v * 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Anillo de runas giratorio (CustomPainter).
class _RuneRingPainter extends CustomPainter {
  final Color color;

  _RuneRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Anillo exterior
    canvas.drawCircle(center, radius, paint);

    // Marcas rúnicas alrededor
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final start = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 2) * math.cos(angle),
        center.dy + (radius + 2) * math.sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // Anillo interior
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.72, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _RuneRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Botón redondo compacto de "volver".
class _RoundIconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _RoundIconButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: AppColors.onSurface.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
