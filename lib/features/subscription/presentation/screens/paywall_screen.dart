import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../providers/subscription_providers.dart';

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
      'title': '🔮 Frasco de Maná Arcano',
      'price': '\$4.99',
      'billing': '500 Maná Global Persistente',
      'tag': 'INICIACIÓN',
    },
    {
      'id': 'elite',
      'title': '⚡ Esfera del Cazador de Élite',
      'price': '\$14.99',
      'billing': '2,000 Maná + 2x Multiplicador XP',
      'tag': 'POPULAR',
    },
    {
      'id': 'monarch',
      'title': '👑 Pase del Monarca Absoluto',
      'price': '\$19.99/mes',
      'billing': 'Maná Ilimitado + Acceso VIP Gremial',
      'tag': 'MÁXIMO PODER',
    },
  ];

  final List<String> _features = [
    '🔮 Consumo de Maná en vivo con métricas de oratoria',
    '📜 Desbloqueo del Inventario de 63 Títulos de Rango (F a SSS)',
    '🍻 Acceso a las 4 Mesas de Discusión del Gran Hall del Gremio 24/7',
    '🎙️ Alternador táctico entre Modo Voz y Modo Escritura',
    '🐉 Desafío de Pruebas del Guardián del Piso con Jefes de Mazmorra',
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Gracias por tu suscripción! Ya eres usuario Premium.'),
              backgroundColor: AppColors.tertiaryTeal,
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al realizar compra: $e')),
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
    final theme = Theme.of(context);

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
                color: AppColors.primaryPurple.withValues(alpha: 0.12),
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
                color: AppColors.secondaryBlue.withValues(alpha: 0.1),
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
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Suscripciones restauradas con éxito.')),
                            );
                          }
                        },
                        child: Text(
                          'RESTAURAR',
                          style: GoogleFonts.spaceMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurpleDim,
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
                              shape: BoxShape.circle,
                              color: AppColors.primaryPurple.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppColors.primaryPurple.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.primaryPurpleDim,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'Pasa a Premium',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Desbloquea conversaciones ilimitadas 24/7 y acelera tu aprendizaje con la IA.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Features List
                        ..._features.map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.tertiaryTeal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
                                          ? AppColors.primaryPurple
                                          : Colors.white.withValues(alpha: 0.1),
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
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                plan['billing'] as String,
                                                style: TextStyle(
                                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          plan['price'] as String,
                                          style: TextStyle(
                                            color: isSelected ? AppColors.primaryPurpleDim : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
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
                                          color: AppColors.primaryPurple,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          plan['tag'] as String,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
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
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primaryPurple.withValues(alpha: 0.3),
                          ),
                          child: _isPurchasing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  'Suscribirse Ahora',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Puedes cancelar en cualquier momento desde tu cuenta de App Store o Play Store. Se aplican Términos y Condiciones.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
