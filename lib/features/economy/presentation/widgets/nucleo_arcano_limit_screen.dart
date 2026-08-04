import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';

class NucleoArcanoLimitScreen extends ConsumerStatefulWidget {
  final int invocationsUsed;
  final int invocationsMax;

  const NucleoArcanoLimitScreen({
    super.key,
    required this.invocationsUsed,
    required this.invocationsMax,
  });

  @override
  ConsumerState<NucleoArcanoLimitScreen> createState() => _NucleoArcanoLimitScreenState();
}

class _NucleoArcanoLimitScreenState extends ConsumerState<NucleoArcanoLimitScreen> {
  static const int _rechargeCostGems = 40;

  bool _isPurchasing = false;

  Future<void> _rechargeInvocations() async {
    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final gems = ref.read(gemBalanceProvider).value ?? 0;
      if (gems < _rechargeCostGems) {
        _showSnackBar(
          'MANÁ (GEMAS) INSUFICIENTE: FALTAN ${_rechargeCostGems - gems} 💎',
          SystemSnackType.error,
        );
        return;
      }

      final success = await ref
          .read(economyRepositoryProvider)
          .purchaseItem(user.id, 'consumible_invocacion5');

      if (!mounted) return;

      if (success) {
        ref.invalidate(dailyStateProvider);
        ref.invalidate(gemBalanceProvider);
        ref.invalidate(canInvokeProvider);
        _showSnackBar(
          '¡NÚCLEO ARCANO RECARGADO! +5 INVOCACIONES ⚡',
          SystemSnackType.success,
        );
        if (context.canPop()) {
          Navigator.pop(context);
        } else {
          context.go('/home');
        }
      } else {
        _showSnackBar(
          'MANÁ (GEMAS) INSUFICIENTE: NO SE PUDO COMPLETAR LA RECARGA ❌',
          SystemSnackType.error,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('ERROR AL RECARGAR EL NÚCLEO, INTENTA DE NUEVO ❌',
            SystemSnackType.error);
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  void _showSnackBar(String message, SystemSnackType type) {
    SystemSnack.show(context, message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gemsAsync = ref.watch(gemBalanceProvider);
    final gems = gemsAsync.value ?? 0;
    final canBuyRecharge = gems >= _rechargeCostGems;

    return Scaffold(
      body: CyberManhwaBackground(
        child: Stack(
          children: [
            // Glow orb
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runeViolet.withValues(alpha: 0.15),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated rune icon
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.runeViolet.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 48),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'EL NÚCLEO ARCANO\nESTÁ AGOTÁNDOSE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'El Oráculo ha respondido ${widget.invocationsUsed} veces hoy.\nNecesita recargarse con la luz del amanecer.\n\nVuelve mañana cuando el sol del nuevo día\nalimente los Cristales de Maná.\n\nLos Cazadores de Élite pueden invocar\nal Oráculo sin límites.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Invocation meter
                    GlassCard(
                      blur: 4, opacity: 0.94,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded, color: AppColors.runeViolet, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.invocationsUsed} / ${widget.invocationsMax} Invocaciones',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // CTA 1: Recargar +5 con gemas
                    GlassCard(
                      blur: 4, opacity: 0.94,
                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: InkWell(
                        onTap: _isPurchasing ? null : _rechargeInvocations,
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.manaCyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _isPurchasing
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(color: AppColors.manaCyan, strokeWidth: 2.5),
                                    )
                                  : const Icon(Icons.diamond_rounded, color: AppColors.manaCyan, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.nucleo_recharge, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                  const SizedBox(height: 2),
                                  Text('$_rechargeCostGems 💎 = +5 invocaciones al Oráculo', style: TextStyle(color: canBuyRecharge ? AppColors.emeraldGreen : AppColors.crimsonRed, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(canBuyRecharge ? Icons.arrow_forward_ios_rounded : Icons.lock_rounded, color: canBuyRecharge ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.24), size: 16),
                          ],
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CTA 2: Ir premium
                    GlassCard(
                      blur: 4, opacity: 0.94,
                      border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: InkWell(
                        onTap: () {
                          context.push('/paywall');
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.royalGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.royalGold, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.nucleo_premium, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                  const SizedBox(height: 2),
                                  Text(l10n.nucleo_unlimited, style: TextStyle(color: AppColors.royalGold, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.royalGold, size: 16),
                          ],
                        ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Option 3: Wait
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) Navigator.pop(context);
                        context.go('/home');
                      },
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      child: Text(
                        'Descansar hasta mañana — El Núcleo se recargará',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
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
}
