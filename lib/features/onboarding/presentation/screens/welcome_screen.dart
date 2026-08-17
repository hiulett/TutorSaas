import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/navigation_resolver.dart';
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
  bool _isAuthenticating = false;

  /// Query mínimo para despertar el pool/instancia de Supabase EN PARALELO con
  /// el flujo de Google: el query de perfil que el redirect ejecuta justo tras
  /// el login deja de pagar el cold start de Postgres. Nunca lanza.
  Future<void> _warmUpBackend() async {
    try {
      await Supabase.instance.client
          .from('user_language_profiles')
          .select('id')
          .limit(1)
          .maybeSingle();
    } catch (_) {/* warm-up best effort */}
  }

  /// Completa el login/registro de forma robusta:
  /// - Si el sign-in devolvió null (cancelado o fallo silencioso), apaga el
  ///   spinner — NUNCA queda bloqueado indefinidamente.
  /// - Si hay sesión, espera (acotada) a que el provider de sesión propague y
  ///   navega explícitamente con la lógica del router (el redirect posterior
  ///   solo confirma el destino, evitando el rebote a Welcome por el race).
  Future<void> _completeLogin(User? user) async {
    if (!mounted) return;
    if (user == null) {
      setState(() => _isAuthenticating = false);
      return;
    }
    // El stream de auth puede propagar la sesión un instante después del
    // sign-in; esperar hasta 5s evita que el redirect lea null y rebote.
    for (var i = 0; i < 50; i++) {
      if (ref.read(currentUserProvider) != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    final devMode = ref.read(devModeProvider);
    final destination = await NavigationDecisionEngine.resolve(
      user: user,
      devMode: devMode,
    );
    if (!mounted) return;
    context.go(navDestinationToPath(destination));
  }

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

                  _buildCurrentView(theme, l10n),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // 3. Overlay de autenticación (spinner post-login)
          if (_isAuthenticating) _buildAuthOverlay(context),
        ],
      ),
    );
  }

  /// Spinner temático mientras se completa el login y el router decide destino.
  Widget _buildAuthOverlay(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.voidBg.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.runeViolet, AppColors.manaCyan],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.manaCyan.withValues(alpha: 0.35),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.voidBg,
                  size: 40,
                ),
              ),
              const SizedBox(height: 26),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.manaCyan,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context)?.connecting_realm ?? 'CONECTANDO AL GRAN REINO...',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView(ThemeData theme, AppLocalizations l10n) {
    return Column(
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
        // Registro directo con Google (cuenta nueva → onboarding explícito).
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
              setState(() => _isAuthenticating = true);
              unawaited(_warmUpBackend());
              try {
                // El registro es explícito: tras autenticar con Google, el
                // nuevo aventurero va SIEMPRE al onboarding (crear identidad).
                ref.read(isRegisteringProvider.notifier).state = true;
                final user = await ref.read(authRepositoryProvider).signInWithGoogle();
                if (!mounted) return;
                if (user == null) {
                  // Cancelado/sin sesión: nunca dejar el spinner infinito.
                  setState(() => _isAuthenticating = false);
                  return;
                }
                context.go('/onboarding');
              } catch (e) {
                if (mounted) {
                  setState(() => _isAuthenticating = false);
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
        // Inicio de sesión con Google (cuenta existente → el router decide).
        OutlinedButton(
          onPressed: () async {
            setState(() => _isAuthenticating = true);
            unawaited(_warmUpBackend());
            try {
              // Login: el router decide (sesión + perfil) sin heredar contexto.
              ref.read(isRegisteringProvider.notifier).state = false;
              final user = await ref.read(authRepositoryProvider).signInWithGoogle();
              await _completeLogin(user);
            } catch (e) {
              if (mounted) {
                setState(() => _isAuthenticating = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.login_google_error)),
                );
              }
            }
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
              Text(l10n.login_google),
            ],
          ),
        ),
      ],
    );
  }
}
