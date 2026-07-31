import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  // 'initial', 'login', 'register'
  String _viewMode = 'initial';

  // Function to check onboarding status and redirect
  Future<void> _redirectUser(User nextUser) async {
    try {
      final isReg = ref.read(isRegisteringProvider);
      if (isReg) {
        final profile = await Supabase.instance.client
            .from('user_language_profiles')
            .select('id')
            .eq('user_id', nextUser.id)
            .maybeSingle();
        if (!mounted) return;
        if (profile != null) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      } else {
        if (!mounted) return;
        context.go('/home');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // 1. Initial check (if user is already logged in on app startup)
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirectUser(user);
      });
    }

    // 2. Listener check (if authentication state changes during welcome screen session)
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _redirectUser(next);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Neon Glowing Background Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // 2. Safe Area Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top App Bar Header / Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.runeViolet,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DUNGEON OF ENGLISH',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.runeViolet,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentView(theme),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(ThemeData theme) {
    switch (_viewMode) {
      case 'login':
        return Column(
          key: const ValueKey('login'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              opacity: 0.04,
              blur: 25.0,
              borderRadius: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'INICIAR RAIDS',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingresa tus credenciales de Hunter via Google para reanudar tus desafíos lingüísticos.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Login with Google Button
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.runeViolet.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signInWithGoogle();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al iniciar con Google: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.runeViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'G',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('INGRESAR CON GOOGLE'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _viewMode = 'initial';
                });
              },
              child: Text(
                'RETROCEDER',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        );

      case 'register':
        return Column(
          key: const ValueKey('register'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              opacity: 0.04,
              blur: 25.0,
              borderRadius: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CREAR LICENCIA',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Regístrate con tu cuenta para desbloquear el sistema de HUD personal, tu tutor de IA y medir tu progreso en tiempo real.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Register with Google Button
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.runeViolet.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signInWithGoogle();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al registrarse con Google: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.runeViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'G',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('REGISTRARSE CON GOOGLE'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _viewMode = 'initial';
                });
              },
              child: Text(
                'RETROCEDER',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        );

      default:
        return Column(
          key: const ValueKey('initial'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              opacity: 0.04,
              blur: 25.0,
              borderRadius: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SOBREVIVE HABLANDO',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Desciende a los Dungeons de idiomas. Tu tutor de IA está listo para interactuar en tiempo real.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Empezar Button
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.runeViolet.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(isRegisteringProvider.notifier).state = false;
                  setState(() {
                    _viewMode = 'login';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.runeViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  elevation: 0,
                ),
                child: const Text('EMPEZAR RAID'),
              ),
            ),
            const SizedBox(height: 16),
            // Continuar con Google Button
            OutlinedButton(
              onPressed: () {
                ref.read(isRegisteringProvider.notifier).state = true;
                setState(() {
                  _viewMode = 'register';
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.onBackground, width: 1.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'G',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.onBackground,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('REGISTRAR NUEVO HUNTER'),
                ],
              ),
            ),
          ],
        );
    }
  }
}
