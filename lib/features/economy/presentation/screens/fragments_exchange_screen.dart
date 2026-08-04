import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../providers/economy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Pantalla de canje de fragmentos (T-505 / ECO-03).
/// La moneda secundaria (fragmentos) se canjea por recompensas:
/// invocaciones al núcleo arcano, gemas, premium 1 día y títulos.
class FragmentsExchangeScreen extends ConsumerStatefulWidget {
  const FragmentsExchangeScreen({super.key});

  @override
  ConsumerState<FragmentsExchangeScreen> createState() => _FragmentsExchangeScreenState();
}

class _FragmentsExchangeScreenState extends ConsumerState<FragmentsExchangeScreen> {
  bool _isRedeeming = false;

  final List<Map<String, dynamic>> _rewards = [
    {
      'id': 'pergamino_practica',
      'name': 'PERGAMINO DE PRÁCTICA',
      'desc': '+5 invocaciones al núcleo arcano del día.',
      'price': 50,
      'success': '¡+5 INVOCACIONES CANJEADAS!',
      'icon': Icons.menu_book_rounded,
      'color': AppColors.manaCyan,
    },
    {
      'id': 'gema_mana',
      'name': 'GEMA DE MANÁ',
      'desc': '+20 gemas a tu reserva de maná.',
      'price': 100,
      'success': '¡+20 GEMAS DE MANÁ!',
      'icon': Icons.diamond_rounded,
      'color': AppColors.runeViolet,
    },
    {
      'id': 'pase_batalla',
      'name': 'PASE DE BATALLA',
      'desc': 'Premium desbloqueado por 1 día.',
      'price': 500,
      'success': 'PREMIUM +1D (SIMULADO)',
      'icon': Icons.card_membership_rounded,
      'color': AppColors.royalGold,
    },
    {
      'id': 'titulo_epico',
      'name': 'TÍTULO ÉPICO',
      'desc': 'Equipa el título Invocador Estelar.',
      'price': 300,
      'success': '¡TÍTULO INVOCADOR ESTELAR EQUIPADO!',
      'icon': Icons.military_tech_rounded,
      'color': AppColors.emeraldGreen,
    },
  ];

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    final type = color == AppColors.successGreen
        ? SystemSnackType.success
        : color == AppColors.crimsonRed
            ? SystemSnackType.error
            : SystemSnackType.info;
    SystemSnack.show(context, message, type: type, duration: const Duration(milliseconds: 1800));
  }

  Future<void> _redeem(Map<String, dynamic> reward) async {
    final itemId = reward['id'] as String;
    final cost = reward['price'] as int;
    setState(() => _isRedeeming = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final repo = ref.read(economyRepositoryProvider);

      final balance = await repo.getFragments(user.id);
      if (balance < cost) {
        _showSnack('FRAGMENTOS INSUFICIENTES ❌', AppColors.crimsonRed);
        return;
      }

      switch (itemId) {
        case 'pergamino_practica':
          await repo.addFragments(user.id, -cost);
          final state = await repo.getDailyState(user.id);
          final currentMax = (state['invocations_max'] as num?)?.toInt() ?? 20;
          final today = DateTime.now().toIso8601String().split('T').first;
          await ref.read(supabaseClientProvider).from('player_daily_state')
              .update({'invocations_max': currentMax + 5})
              .eq('user_id', user.id)
              .eq('date', today);
          ref.invalidate(dailyStateProvider);
          break;
        case 'gema_mana':
          await repo.addFragments(user.id, -cost);
          await repo.addGems(user.id, 20);
          ref.invalidate(gemBalanceProvider);
          break;
        case 'pase_batalla':
          await repo.addFragments(user.id, -cost);
          try {
            await ref.read(supabaseClientProvider).from('user_subscriptions').upsert({
              'user_id': user.id,
              'plan_id': 'premium',
              'status': 'active',
              'updated_at': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            debugPrint('FragmentsExchange: user_subscriptions no disponible → PREMIUM +1D simulado ($e)');
          }
          break;
        case 'titulo_epico':
          await repo.addFragments(user.id, -cost);
          await ref.read(supabaseClientProvider).from('user_language_profiles')
              .update({'equipped_title_code': 'invocador_estelar'})
              .eq('user_id', user.id);
          break;
      }

      ref.invalidate(fragmentBalanceProvider);
      _showSnack(reward['success'] as String, AppColors.successGreen);
    } catch (e) {
      debugPrint('FragmentsExchange: error en canje $itemId → $e');
      _showSnack('ERROR EN EL CANJE ❌', AppColors.crimsonRed);
    } finally {
      if (mounted) setState(() => _isRedeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fragmentsAsync = ref.watch(fragmentBalanceProvider);
    final fragments = fragmentsAsync.value ?? 0;

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.dashboardGate,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          'CANJE DE FRAGMENTOS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.voidBg.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '$fragments',
                            style: GoogleFonts.jetBrainsMono(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'CANJE DE FRAGMENTOS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.manaCyan,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'LOS FRAGMENTOS SON LA MONEDA DE CANJE. ELÍGELOS SABIAMENTE, CAZADOR.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 228,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _rewards.length,
                  itemBuilder: (context, index) {
                    final reward = _rewards[index];
                    final price = reward['price'] as int;
                    final accent = reward['color'] as Color;
                    final canAfford = fragments >= price;

                    return GlassCard(
                      borderColor: canAfford ? accent.withValues(alpha: 0.4) : AppColors.onSurface.withValues(alpha: 0.10),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: accent.withValues(alpha: 0.4)),
                            ),
                            child: Icon(reward['icon'] as IconData, color: accent, size: 20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            reward['name'] as String,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reward['desc'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppColors.runeViolet, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                '$price FRAGMENTOS',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.runeViolet,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (canAfford && !_isRedeeming)
                                  ? () => _redeem(reward)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? accent : AppColors.onSurface.withValues(alpha: 0.12),
                                foregroundColor: canAfford ? AppColors.voidBg : AppColors.onSurface.withValues(alpha: 0.54),
                                minimumSize: const Size(48, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: Text(
                                'CANJEAR',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
