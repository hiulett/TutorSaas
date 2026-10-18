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
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isAuthenticating = false;
  bool _isRegisterMode = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 16),

                  Expanded(
                    child: _buildCurrentView(theme, l10n),
                  ),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título limpio de bienvenida (sin SYSTEM MESSAGE)
          Text(
            l10n.login_title,
            textAlign: TextAlign.center,
            style: AppTypography.headline(context).copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.login_subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted(context).copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          _buildEmailForm(theme, l10n),
          const SizedBox(height: 20),
          // Separador
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.onSurface.withValues(alpha: 0.15))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.continue_google,
                  style: AppTypography.tiny(context).copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.onSurface.withValues(alpha: 0.15))),
            ],
          ),
          const SizedBox(height: 20),
          _buildGoogleRegisterButton(),
          const SizedBox(height: 12),
          _buildGoogleButton(l10n.login_google),
        ],
      ),
    );
  }

  /// Registro directo con Google (cuenta nueva → onboarding explícito).
  Widget _buildGoogleRegisterButton() {
    return DecoratedBox(
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
            ref.read(isRegisteringProvider.notifier).state = true;
            final user = await ref.read(authRepositoryProvider).signInWithGoogle();
            if (!mounted) return;
            if (user == null) {
              setState(() => _isAuthenticating = false);
              return;
            }
            context.go('/onboarding');
          } catch (e) {
            if (mounted) {
              setState(() => _isAuthenticating = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)?.register_google_error ?? 'Error')),
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
        child: _googleRow(AppLocalizations.of(context)?.register_google ?? 'REGISTER WITH GOOGLE'),
      ),
    );
  }

  Widget _buildGoogleButton(String label) {
    return OutlinedButton(
      onPressed: () async {
        setState(() => _isAuthenticating = true);
        unawaited(_warmUpBackend());
        try {
          ref.read(isRegisteringProvider.notifier).state = false;
          final user = await ref.read(authRepositoryProvider).signInWithGoogle();
          await _completeLogin(user);
        } catch (e) {
          if (mounted) {
            setState(() => _isAuthenticating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.login_google_error ?? 'Error')),
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
      child: _googleRow(label),
    );
  }

  Widget _googleRow(String label) {
    return Row(
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
        Flexible(
          child: Text(
            label,
            style: AppTypography.label(context).copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título del modo actual (INICIAR SESIÓN / CREAR CUENTA)
        Text(
          _isRegisterMode ? l10n.register : l10n.login,
          textAlign: TextAlign.center,
          style: AppTypography.subtitle(context).copyWith(
            color: AppColors.manaCyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: AppTypography.body(context).copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: l10n.login_email_hint,
            hintStyle: AppTypography.body(context).copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
            labelText: l10n.email_label,
            labelStyle: AppTypography.label(context).copyWith(color: AppColors.manaCyan),
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.manaCyan, size: 20),
            filled: true,
            fillColor: AppColors.onSurface.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.manaCyan),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: AppTypography.body(context).copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: AppTypography.body(context).copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
            labelText: l10n.password_label,
            labelStyle: AppTypography.label(context).copyWith(color: AppColors.manaCyan),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.manaCyan, size: 20),
            filled: true,
            fillColor: AppColors.onSurface.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.manaCyan),
            ),
          ),
          onSubmitted: (_) => _submitEmailAuth(l10n),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isAuthenticating ? null : () => _submitEmailAuth(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.runeViolet,
            foregroundColor: AppColors.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            elevation: 8,
            shadowColor: AppColors.runeViolet.withValues(alpha: 0.3),
          ),
          child: _isAuthenticating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: AppColors.onSurface, strokeWidth: 2.5),
                )
              : Text(
                  _isRegisterMode ? l10n.register_email : l10n.login_email,
                  style: AppTypography.title(context),
                ),
        ),
        if (!_isRegisterMode) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showPasswordResetDialog(l10n),
            child: Text(
              l10n.forgot_password,
              textAlign: TextAlign.center,
              style: AppTypography.label(context).copyWith(
                color: AppColors.manaCyan,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Cambio de modo discreto
        GestureDetector(
          onTap: () => setState(() => _isRegisterMode = !_isRegisterMode),
          child: Text(
            _isRegisterMode ? l10n.login_prompt : l10n.register_prompt,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted(context).copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Diálogo de recuperación de contraseña (envía enlace al correo).
  Future<void> _showPasswordResetDialog(AppLocalizations l10n) async {
    final resetController = TextEditingController(text: _emailController.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    final show = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: AppColors.manaCyan.withValues(alpha: 0.3)),
        ),
        title: Text(
          l10n.reset_password_title,
          style: AppTypography.headline(context).copyWith(
            fontSize: 18,
            color: AppColors.manaCyan,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.reset_password_desc,
              style: AppTypography.bodyMuted(context),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              style: AppTypography.body(context).copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: l10n.login_email_hint,
                hintStyle: AppTypography.body(context).copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
                labelText: l10n.email_label,
                labelStyle: AppTypography.label(context).copyWith(color: AppColors.manaCyan),
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.manaCyan, size: 20),
                filled: true,
                fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.manaCyan),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
            child: Text(l10n.back),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.runeViolet,
              foregroundColor: AppColors.onSurface,
            ),
            child: Text(l10n.reset_password_send),
          ),
        ],
      ),
    );
    resetController.dispose();
    if (show != true) return;

    final email = resetController.text.trim();
    if (email.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reset_password_email_empty)),
      );
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.email_invalid)),
      );
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reset_password_sent)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reset_password_error)),
      );
    }
  }

  /// Valida y ejecuta el login/registro con correo y contraseña.
  Future<void> _submitEmailAuth(AppLocalizations l10n) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.email_required)),
      );
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.email_invalid)),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.password_required)),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.password_short)),
      );
      return;
    }

    setState(() => _isAuthenticating = true);
    try {
      if (_isRegisterMode) {
        final user = await ref.read(authRepositoryProvider).signUpWithEmail(email, password);
        if (!mounted) return;

        if (user == null) {
          setState(() => _isAuthenticating = false);
          return;
        }

        // Issue #55: con la confirmación de email activa, `signUp` crea el
        // usuario pero NO crea sesión. Navegar al onboarding en ese estado
        // dejaba la cuenta sin perfil y devolvía al login.
        final hasSession =
            ref.read(supabaseClientProvider).auth.currentSession != null;
        if (!hasSession) {
          setState(() => _isAuthenticating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.register_confirm_email),
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: l10n.resend_confirmation,
                onPressed: () => ref
                    .read(authRepositoryProvider)
                    .resendConfirmationEmail(email),
              ),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.register_success)),
        );
        context.go('/onboarding');
      } else {
        final user = await ref.read(authRepositoryProvider).signInWithEmail(email, password);
        if (!mounted) return;
        if (user == null) {
          setState(() => _isAuthenticating = false);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.login_success)),
        );
        await _completeLogin(user);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      // Issue #55: mensaje accionable cuando el correo no está confirmado.
      final raw = e.message.toLowerCase();
      final notConfirmed =
          raw.contains('not confirmed') || raw.contains('email not confirmed');
      final message = notConfirmed
          ? l10n.login_email_not_confirmed
          : (_isRegisterMode && (e.message.contains('already registered') || e.message.contains('registered'))
              ? l10n.email_already_registered
              : (_isRegisterMode ? l10n.register_email_error : l10n.login_email_error));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isRegisterMode ? l10n.register_email_error : l10n.login_email_error)),
      );
    }
  }
}
