import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';

/// Pantalla SIN MANÁ (FASE B/C).
///
/// El Maná es la única moneda de consumo de IA y solo se adquiere con dinero
/// (plan + porciones/gemas). Al agotarse, el jugador puede comprar más o
/// esperar la renovación del ciclo. No existe recarga con gemas gratuitas.
class NucleoArcanoLimitScreen extends ConsumerStatefulWidget {
  const NucleoArcanoLimitScreen({super.key});

  @override
  ConsumerState<NucleoArcanoLimitScreen> createState() => _NucleoArcanoLimitScreenState();
}

class _NucleoArcanoLimitScreenState extends ConsumerState<NucleoArcanoLimitScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final manaAsync = ref.watch(manaStateProvider);
    final mana = manaAsync.value ?? const {
      'allowance': 1800,
      'purchased': 0,
      'used': 0,
      'remaining': 1800,
      'expires_at': null,
      'plan': 'Plan Gratuito',
    };
    final int remaining = mana['remaining'] as int? ?? 0;
    final int allowance = mana['allowance'] as int? ?? 1800;
    final int purchased = mana['purchased'] as int? ?? 0;
    final DateTime? expiresAt = mana['expires_at'] is String
        ? DateTime.tryParse(mana['expires_at'] as String)
        : null;

    return Scaffold(
      body: CyberManhwaBackground(
        child: Stack(
          children: [
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
                      child: const Icon(Icons.bolt_rounded, color: AppColors.runeViolet, size: 48),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      l10n.no_mana,
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
                      l10n.mana_exhausted_desc(
                        expiresAt != null ? l10n.mana_renews_on(_formatDate(expiresAt)) : '',
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GlassCard(
                      blur: 4, opacity: 0.94,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded, color: AppColors.runeViolet, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.mana_balance(remaining, allowance + purchased),
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

                    // CTA 1: Obtener maná (planes / porciones)
                    GlassCard(
                      blur: 4, opacity: 0.94,
                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: InkWell(
                          onTap: () => context.push('/paywall'),
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.manaCyan.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.workspace_premium_rounded, color: AppColors.manaCyan, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.nucleo_premium,
                                      style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.more_mana_monthly,
                                      style: const TextStyle(color: AppColors.manaCyan, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.manaCyan, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // CTA 2: Esperar renovación
                    TextButton(
                      onPressed: () {
                        if (context.canPop()) Navigator.pop(context);
                        context.go('/home');
                      },
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      child: Text(
                        l10n.wait_plan_renewal,
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

  String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}
