import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/economy_providers.dart';

class NucleoArcanoLimitScreen extends ConsumerWidget {
  final int invocationsUsed;
  final int invocationsMax;

  const NucleoArcanoLimitScreen({
    super.key,
    required this.invocationsUsed,
    required this.invocationsMax,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gemsAsync = ref.watch(gemBalanceProvider);
    final gems = gemsAsync.value ?? 0;
    final canBuyGems = gems >= 50;

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
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'El Oráculo ha respondido $invocationsUsed veces hoy.\nNecesita recargarse con la luz del amanecer.\n\nVuelve mañana cuando el sol del nuevo día\nalimente los Cristales de Maná.\n\nLos Cazadores de Élite pueden invocar\nal Oráculo sin límites.',
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
                            '$invocationsUsed / $invocationsMax Invocaciones',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Option 1: Recargar con gemas
                    GlassCard(
                      blur: 4, opacity: 0.94,
                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: canBuyGems
                            ? () async {
                                final repo = ref.read(economyRepositoryProvider);
                                final user = ref.read(currentUserProvider);
                                if (user == null) return;
                                final spent = await repo.spendGems(user.id, 50);
                                if (spent) {
                                  // Refill invocations
                                  final today = DateTime.now().toIso8601String().split('T').first;
                                  await repo.getDailyState(user.id); // refresh state
                                  ref.invalidate(dailyStateProvider);
                                  ref.invalidate(gemBalanceProvider);
                                  if (context.mounted) Navigator.pop(context);
                                }
                              }
                            : null,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.manaCyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.diamond_rounded, color: AppColors.manaCyan, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recargar con Cristales de Maná', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text('50 💎 = +5 invocaciones al Oráculo', style: TextStyle(color: canBuyGems ? AppColors.emeraldGreen : AppColors.onSurfaceVariant, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(canBuyGems ? Icons.arrow_forward_ios_rounded : Icons.lock_rounded, color: canBuyGems ? AppColors.manaCyan : Colors.white24, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Option 2: Premium
                    GlassCard(
                      blur: 4, opacity: 0.94,
                      border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () {
                          context.push('/paywall');
                        },
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
                                  Text('Invocaciones Ilimitadas', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text('Conviértete en Cazador de Élite desde \$1.99/mes', style: TextStyle(color: AppColors.royalGold, fontSize: 12)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.royalGold, size: 16),
                          ],
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
