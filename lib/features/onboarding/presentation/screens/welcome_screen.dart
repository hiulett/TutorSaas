import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  // 'initial', 'login', 'register'
  String _viewMode = 'initial';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                        l10n.app_name.toUpperCase(),
                        style: AppTypography.title(context).copyWith(
                          fontSize: 16,
                          letterSpacing: 2.0,
                          color: AppColors.runeViolet,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentView(theme, l10n),
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

  Widget _buildCurrentView(ThemeData theme, AppLocalizations l10n) {
    switch (_viewMode) {
      case 'login':
        return Column(
          key: const ValueKey('login'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              opacity: AppColors.glassOpacity,
              blur: 25.0,
              borderRadius: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.login,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline(context).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.sign_in_desc,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted(context).copyWith(
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
                    // Login: el router decide (sesión + perfil). Se limpia el
                    // flag de registro para no heredar contexto previo.
                    ref.read(isRegisteringProvider.notifier).state = false;
                    await ref.read(authRepositoryProvider).signInWithGoogle();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.login_google_error)),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.runeViolet,
                  foregroundColor: AppColors.onSurface,
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
                        border: Border.all(color: AppColors.onSurface, width: 1.5),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'G',
                        style: AppTypography.label(context).copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.login_google),
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
                l10n.back,
                style: AppTypography.label(context).copyWith(
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
              opacity: AppColors.glassOpacity,
              blur: 25.0,
              borderRadius: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.register,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline(context).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.create_account_desc,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted(context).copyWith(
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
                    // El registro es explícito: tras autenticar con Google,
                    // el nuevo aventurero va SIEMPRE al onboarding (crear su
                    // identidad), aunque la cuenta ya exista con perfil.
                    ref.read(isRegisteringProvider.notifier).state = true;
                    final user = await ref.read(authRepositoryProvider).signInWithGoogle();
                    if (user != null && mounted) {
                      context.go('/onboarding');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.register_google_error)),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.runeViolet,
                  foregroundColor: AppColors.onSurface,
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
                        border: Border.all(color: AppColors.onSurface, width: 1.5),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'G',
                        style: AppTypography.label(context).copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.register_google),
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
                l10n.back,
                style: AppTypography.label(context).copyWith(
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
              opacity: AppColors.glassOpacity,
              blur: 25.0,
              borderRadius: 4.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.welcome_title,
                    textAlign: TextAlign.center,
                    style: AppTypography.headline(context).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.welcome_desc,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted(context).copyWith(
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
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  elevation: 0,
                ),
                child: Text(l10n.get_started),
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
                side: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.15)),
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
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'G',
                      style: AppTypography.label(context).copyWith(
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.register_new_hunter),
                ],
              ),
            ),
          ],
        );
    }
  }
}
