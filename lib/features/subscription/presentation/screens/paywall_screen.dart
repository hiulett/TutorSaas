import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../providers/subscription_providers.dart';
import '../../../../l10n/app_localizations.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String _selectedPlan = 'elite';
  bool _isPurchasing = false;

  List<Map<String, dynamic>> _plans = [
    {
      'id': 'apprentice',
      'title': 'ARCANE MANA AMPOULE',
      'price': '\$4.99',
      'billing': '500 Persistent Global Mana',
      'tag': 'INITIATE',
    },
    {
      'id': 'elite',
      'title': 'ELITE HUNTER CORE',
      'price': '\$14.99',
      'billing': '2,000 Mana + 2x XP Multiplier',
      'tag': 'POPULAR',
    },
    {
      'id': 'monarch',
      'title': 'MONARCH ASCENSION PASS',
      'price': '\$19.99/mo',
      'billing': 'Unlimited Mana + VIP Guild Hall Access',
      'tag': 'MAX POWER',
    },
  ];

  final List<String> _features = [
    'Realtime Mana consumption & voice metrics tracker',
    'Unlock the 63 Rank Titles Inventory (from F to SSS Rank)',
    '24/7 access to the Guild Gates in the Grand Discussion Hall',
    'Tactical selector between Voice Mode and Writing Mode',
    'Floor Guardian Boss Arena challenge gates',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDynamicPlans();
  }

  Future<void> _fetchDynamicPlans() async {
    try {
      final fetched = await ref.read(subscriptionRepositoryProvider).getSubscriptionPlans();
      if (mounted && fetched.isNotEmpty) {
        setState(() {
          _plans = fetched;
        });
      }
    } catch (_) {}
  }

  void _handlePurchase() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await ref.read(subscriptionRepositoryProvider).purchasePackage(_selectedPlan);
      
      if (success) {
        ref.read(isPremiumProvider.notifier).setPremium(true);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.paywall_success),
              backgroundColor: AppColors.manaCyan,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paywall_failure('$e'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CyberManhwaBackground(
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runeViolet.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manaCyan.withValues(alpha: 0.1),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface, size: 28),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            await ref.read(subscriptionRepositoryProvider).restorePurchases();
                            if (context.mounted) {
                              final l10n = AppLocalizations.of(context)!;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.paywall_restored)),
                              );
                            }
                          },
                          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                          child: Text(
                            'RESTORE',
                            style: AppTypography.stat(context).copyWith(
                              color: AppColors.runeViolet,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          // Crown icon
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.runeViolet.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.runeViolet.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.runeViolet,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            'UPGRADE TO PREMIUM',
                            textAlign: TextAlign.center,
                            style: AppTypography.headline(context).copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unlock unlimited live sessions and accelerate your Hunter Rank with AI.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMuted(context),
                          ),
                          const SizedBox(height: 32),

                          // Features List
                          ..._features.map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.manaCyan,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: AppTypography.bodyMuted(context).copyWith(
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 32),

                          // Pricing cards
                          ..._plans.map((plan) {
                            final isSelected = _selectedPlan == plan['id'];
                            final hasTag = plan['tag'] != null;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPlan = plan['id'] as String;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Stack(
                                  children: [
                                    GlassCard(
                                      blur: 20,
                                      opacity: isSelected ? 0.12 : 0.04,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.runeViolet
                                            : AppColors.onSurface.withValues(alpha: 0.1),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  plan['title'] as String,
                                                  style: AppTypography.subtitle(context).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  plan['billing'] as String,
                                                  style: AppTypography.bodyMuted(context).copyWith(
                                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            plan['price'] as String,
                                            style: AppTypography.stat(context).copyWith(
                                              color: isSelected ? AppColors.runeViolet : AppColors.onSurface,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasTag)
                                      Positioned(
                                        top: 0,
                                        right: 20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.runeViolet,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: Text(
                                            plan['tag'] as String,
                                            style: AppTypography.tiny(context).copyWith(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 32),

                          // Action purchase button
                          ElevatedButton(
                            onPressed: _isPurchasing ? null : _handlePurchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.runeViolet,
                              foregroundColor: AppColors.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              elevation: 8,
                              shadowColor: AppColors.runeViolet.withValues(alpha: 0.3),
                            ),
                            child: _isPurchasing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.onSurface,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'SUBSCRIBE NOW',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Cancel anytime via App Store / Play Store. Terms and Conditions apply.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMuted(context).copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
