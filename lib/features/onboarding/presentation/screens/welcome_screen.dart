import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/navigation_resolver.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Login y registro, rediseñados sobre el HUD de Stitch
/// (`docs/product-audit/stitch/stitch_login.png` / `stitch_register.png`).
///
/// La lógica no cambia respecto a la pantalla anterior: mismas validaciones,
/// mismos providers y mismo destino de navegación. Lo que cambia es la capa
/// visual: barra HUD, tarjeta con esquinas rúnicas, campos etiquetados en
/// JetBrains Mono y medidor de seguridad de la contraseña.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isAuthenticating = false;
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _inlineError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.voidBg,
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _HudGridPainter())),
          _buildGlowOrbs(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHudBar(l10n),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 6),
                          _buildBrand(),
                          const SizedBox(height: 18),
                          _buildHero(l10n),
                          const SizedBox(height: 18),
                          _buildAuthCard(l10n),
                          const SizedBox(height: 16),
                          _buildModeSwitch(l10n),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isAuthenticating) _buildAuthOverlay(context),
        ],
      ),
    );
  }

  // ── Capas decorativas del HUD ─────────────────────────────────────────────

  Widget _buildGlowOrbs() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runeViolet.withValues(alpha: 0.16),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              right: -70,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manaCyan.withValues(alpha: 0.10),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudBar(AppLocalizations l10n) {
    final protocol =
        _isRegisterMode ? l10n.auth_protocol_awakening : l10n.auth_protocol_login;
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.55)),
              color: AppColors.manaCyan.withValues(alpha: 0.06),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.manaCyan,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    protocol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.6,
                      color: AppColors.manaCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.auth_sys_on,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            letterSpacing: 1.4,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.7)),
            color: AppColors.surfaceDeep,
            boxShadow: [
              BoxShadow(
                color: AppColors.manaCyan.withValues(alpha: 0.25),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: AppColors.manaCyan,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'DUNGEON OF ENGLISH',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(AppLocalizations l10n) {
    final title = _isRegisterMode ? l10n.auth_register_title : l10n.login_title;
    final subtitle =
        _isRegisterMode ? l10n.auth_register_subtitle : l10n.login_subtitle;
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 25,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            height: 1.45,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ── Tarjeta de autenticación ──────────────────────────────────────────────

  Widget _buildAuthCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.35)),
        color: AppColors.surfaceDeep.withValues(alpha: 0.72),
      ),
      child: Stack(
        children: [
          const Positioned(top: 0, left: 0, child: _Corner(flipX: false, flipY: false)),
          const Positioned(top: 0, right: 0, child: _Corner(flipX: true, flipY: false)),
          const Positioned(bottom: 0, left: 0, child: _Corner(flipX: false, flipY: true)),
          const Positioned(bottom: 0, right: 0, child: _Corner(flipX: true, flipY: true)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardHeader(l10n),
                const SizedBox(height: 14),
                _hudField(
                  l10n: l10n,
                  label: l10n.auth_label_email,
                  icon: Icons.fingerprint_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: l10n.login_email_hint,
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                _hudField(
                  l10n: l10n,
                  label: l10n.password_label,
                  icon: Icons.lock_outline_rounded,
                  controller: _passwordController,
                  hint: '••••••••',
                  obscure: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onSubmitted: (_) => _onPrimaryAction(l10n),
                ),
                if (_isRegisterMode) ...[
                  const SizedBox(height: 8),
                  _buildStrengthMeter(l10n),
                  const SizedBox(height: 12),
                  _hudField(
                    l10n: l10n,
                    label: l10n.auth_label_confirm,
                    icon: Icons.key_rounded,
                    controller: _confirmController,
                    hint: '••••••••',
                    obscure: _obscureConfirm,
                    onToggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    onSubmitted: (_) => _onPrimaryAction(l10n),
                  ),
                ],
                if (_inlineError != null) ...[
                  const SizedBox(height: 12),
                  _buildInlineError(_inlineError!),
                ],
                const SizedBox(height: 16),
                _buildPrimaryCta(l10n),
                if (!_isRegisterMode) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showPasswordResetDialog(l10n),
                    child: Text(
                      l10n.forgot_password,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.runeViolet,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _buildProtocolDivider(l10n),
                const SizedBox(height: 14),
                _buildGoogleAction(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _isRegisterMode
                ? l10n.auth_gateway_register
                : l10n.auth_gateway_login,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: AppColors.manaCyan,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _isRegisterMode ? l10n.auth_sys_new_recruit : l10n.auth_sys_secure,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            letterSpacing: 1,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _hudField({
    required AppLocalizations l10n,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    bool autocorrect = true,
    TextInputType? keyboardType,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.manaCyan),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          autocorrect: autocorrect,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurface.withValues(alpha: 0.45),
            ),
            filled: true,
            fillColor: AppColors.voidBg.withValues(alpha: 0.6),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    tooltip: l10n.auth_toggle_visibility,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: AppColors.onSurface.withValues(alpha: 0.14),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: AppColors.onSurface.withValues(alpha: 0.14),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.manaCyan),
            ),
          ),
        ),
      ],
    );
  }

  int _passwordStrength() {
    final value = _passwordController.text;
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value) ||
        RegExp(r'[A-Z]').hasMatch(value)) {
      score++;
    }
    return score.clamp(0, 3);
  }

  Widget _buildStrengthMeter(AppLocalizations l10n) {
    final score = _passwordStrength();
    final labels = [
      l10n.auth_strength_weak,
      l10n.auth_strength_medium,
      l10n.auth_strength_strong,
    ];
    const colors = [AppColors.errorRed, AppColors.royalGold, AppColors.emeraldGreen];
    final color = score == 0 ? AppColors.onSurface.withValues(alpha: 0.18) : colors[score - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: index < score ? color : AppColors.onSurface.withValues(alpha: 0.12),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Text(
          '${l10n.auth_security_level}: ${score == 0 ? '—' : labels[score - 1]}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8.5,
            letterSpacing: 1.1,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineError(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.errorRed.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 15, color: AppColors.errorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                height: 1.35,
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCta(AppLocalizations l10n) {
    if (_isAuthenticating) {
      return Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.manaCyan.withValues(alpha: 0.18),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.manaCyan,
          ),
        ),
      );
    }
    final label =
        _isRegisterMode ? l10n.auth_start_trial_cta : l10n.auth_continue_cta;
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: () => _onPrimaryAction(l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.manaCyan,
          foregroundColor: AppColors.voidBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          shadowColor: AppColors.manaCyan.withValues(alpha: 0.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.voidBg,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.voidBg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.onSurface.withValues(alpha: 0.14),
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            l10n.auth_or_protocol,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              letterSpacing: 1.2,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.onSurface.withValues(alpha: 0.14),
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleAction(AppLocalizations l10n) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: _isAuthenticating
            ? null
            : () => _isRegisterMode
                ? _registerWithGoogle(l10n)
                : _signInWithGoogle(l10n),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.onSurface, width: 1.4),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'G',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.auth_continue_google,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitch(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          _isRegisterMode ? l10n.auth_have_account : l10n.auth_new_hunter,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9.5,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: _isAuthenticating
              ? null
              : () => setState(() {
                    _isRegisterMode = !_isRegisterMode;
                    _inlineError = null;
                  }),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.manaCyan,
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            _isRegisterMode ? l10n.auth_go_login : l10n.auth_go_register,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: AppColors.manaCyan,
            ),
          ),
        ),
      ],
    );
  }

  /// Punto único de entrada del CTA: valida la confirmación cuando toca y
  /// delega en la lógica existente.
  void _onPrimaryAction(AppLocalizations l10n) {
    if (_isAuthenticating) return;
    if (_isRegisterMode &&
        _confirmController.text.isNotEmpty &&
        _confirmController.text != _passwordController.text) {
      setState(() => _inlineError = l10n.auth_password_mismatch);
      return;
    }
    setState(() => _inlineError = null);
    _submitEmailAuth(l10n);
  }

  Future<void> _signInWithGoogle(AppLocalizations l10n) async {
    setState(() {
      _isAuthenticating = true;
      _inlineError = null;
    });
    unawaited(_warmUpBackend());
    try {
      ref.read(isRegisteringProvider.notifier).state = false;
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      await _completeLogin(user);
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _inlineError = l10n.login_google_error;
      });
    }
  }

  /// Registro directo con Google (cuenta nueva → onboarding explícito).
  Future<void> _registerWithGoogle(AppLocalizations l10n) async {
    setState(() {
      _isAuthenticating = true;
      _inlineError = null;
    });
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
      // Sin traza era imposible saber si falló Google, Supabase o la red.
      debugPrint('Google sign-up failed: $e');
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _inlineError = l10n.register_google_error;
      });
    }
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
                AppLocalizations.of(context)?.connecting_realm ??
                    'CONECTANDO AL GRAN REINO...',
                style: GoogleFonts.spaceGrotesk(
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

  /// Diálogo de recuperación de contraseña (envía enlace al correo).
  Future<void> _showPasswordResetDialog(AppLocalizations l10n) async {
    final resetController =
        TextEditingController(text: _emailController.text.trim());
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
              style: AppTypography.body(context)
                  .copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: l10n.login_email_hint,
                hintStyle: AppTypography.body(context).copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6)),
                labelText: l10n.email_label,
                labelStyle: AppTypography.label(context)
                    .copyWith(color: AppColors.manaCyan),
                prefixIcon: const Icon(Icons.mail_outline_rounded,
                    color: AppColors.manaCyan, size: 20),
                filled: true,
                fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.12)),
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
            style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant),
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
        final user = await ref
            .read(authRepositoryProvider)
            .signUpWithEmail(email, password);
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
        final user = await ref
            .read(authRepositoryProvider)
            .signInWithEmail(email, password);
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
      debugPrint('Email auth failed: ${e.message} (status ${e.statusCode})');
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      // Issue #55: mensaje accionable cuando el correo no está confirmado.
      final raw = e.message.toLowerCase();
      final notConfirmed =
          raw.contains('not confirmed') || raw.contains('email not confirmed');
      final message = notConfirmed
          ? l10n.login_email_not_confirmed
          : (_isRegisterMode &&
                  (e.message.contains('already registered') ||
                      e.message.contains('registered'))
              ? l10n.email_already_registered
              : (_isRegisterMode
                  ? l10n.register_email_error
                  : l10n.login_email_error));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                _isRegisterMode ? l10n.register_email_error : l10n.login_email_error)),
      );
    }
  }
}

/// Esquina rúnica de la tarjeta: dos trazos de 14 px en L.
class _Corner extends StatelessWidget {
  const _Corner({required this.flipX, required this.flipY});

  final bool flipX;
  final bool flipY;

  @override
  Widget build(BuildContext context) {
    final border = Border(
      top: BorderSide(
        color: AppColors.manaCyan.withValues(alpha: 0.8),
        width: 1.5,
      ),
      left: BorderSide(
        color: AppColors.manaCyan.withValues(alpha: 0.8),
        width: 1.5,
      ),
    );
    return Transform.flip(
      flipX: flipX,
      flipY: flipY,
      child: SizedBox(
        width: 14,
        height: 14,
        child: DecoratedBox(decoration: BoxDecoration(border: border)),
      ),
    );
  }
}

/// Rejilla tenue del fondo, con el mismo aire de HUD que la referencia.
class _HudGridPainter extends CustomPainter {
  const _HudGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.manaCyan.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
