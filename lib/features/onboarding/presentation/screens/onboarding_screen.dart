import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/character_creation_wizard.dart';
import '../../domain/models/cefr_rank.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/hunter_class.dart';
import '../../../../app/navigation_resolver.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Character creation values
  String _characterName = '';
  String _characterClass = 'warrior';
  int _selectedAvatarIndex = 0;

  // Selected values
  String _selectedLanguageCode = 'en'; // App Default Target Language: English
  String _selectedNativeLanguageCode = 'es'; // Native language
  String _selectedCefrCode = 'A1';
  String? _gameRank;
  int _selectedDailyGoal = 15;
  final List<String> _selectedInterests = [];
  String _selectedCorrectionStyle = 'balanced';
  String _selectedCorrectionExplanationLanguage =
      'native'; // 'native' vs 'target'
  String _selectedObstacle = '';

  // Estado
  bool _isSaving = false;
  bool _showHeroWelcome = false;

  // Options lists
  final List<Map<String, String>> _nativeLanguages = [
    {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'pt', 'name': 'Portuguese', 'native': 'Português'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
  ];

  @override
  void initState() {
    super.initState();
    // Issue #54: medir el embudo del onboarding. Sin esto no hay forma de saber
    // en qué paso se pierde el ~23 % que nunca crea perfil.
    _trackOnboarding('onboarding_started', {'step': 0});
    // Primer inicio: si la interfaz sigue al dispositivo, pre-selecciona el
    // idioma nativo según el locale del dispositivo (si está soportado).
    final settings = ref.read(userLanguageProvider);
    final deviceLang = ref.read(deviceLocaleProvider);
    final nativeCodes = _nativeLanguages.map((l) => l['code']).toSet();
    if (settings.followDeviceLanguage && nativeCodes.contains(deviceLang)) {
      _selectedNativeLanguageCode = deviceLang;
    }
    // Detección automática del idioma del dispositivo (primer inicio).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (settings.followDeviceLanguage) {
        SystemSnack.show(
          context,
          AppLocalizations.of(
                context,
              )?.onboarding_device_lang(deviceLang.toUpperCase()) ??
              'Hemos detectado que tu dispositivo utiliza ${deviceLang.toUpperCase()}. '
                  'La aplicación se mostrará en ese idioma.',
          type: SystemSnackType.info,
          duration: const Duration(milliseconds: 3000),
        );
      }
    });
  }

  void _nextPage() {
    final l10n = AppLocalizations.of(context)!;
    // Issue #54: cada paso superado queda registrado con su índice.
    _trackOnboarding('onboarding_step', {'step': _currentPage});
    // Onboarding de 4 pasos: nativo → objetivo → clasificación IA → personaje.
    if (_currentPage == 0 && _selectedNativeLanguageCode.isEmpty) {
      SystemSnack.show(
        context,
        l10n.onb_validate_native,
        type: SystemSnackType.warning,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    if (_currentPage == 1 && _selectedLanguageCode.isEmpty) {
      SystemSnack.show(
        context,
        l10n.onb_validate_target,
        type: SystemSnackType.warning,
        duration: const Duration(milliseconds: 1500),
      );
      return;
    }

    if (_currentPage == 2) {
      _startOracleEvaluation();
      return;
    }

    if (_currentPage < 3) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboardingAndPurchase();
    }
  }

  /// Issue #54: evento del embudo de onboarding (best-effort, no bloquea).
  void _trackOnboarding(String event, [Map<String, Object?>? properties]) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    RetentionAnalytics.instance.track(user.id, event, properties: properties);
  }

  /// P-20: explica que se envia a la IA y que no se envia.
  void _showPrivacyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDeep,
        title: Text(
          l10n?.privacy_title ?? 'PRIVACY',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            l10n?.privacy_body ?? '',
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n?.privacy_accept ?? 'GOT IT',
              style: const TextStyle(color: AppColors.manaCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Lanza la evaluación conversacional del Oráculo y, al volver, avanza al
  /// paso de creación del personaje. Si la evaluación aún no está lista y no
  /// devolvió nivel, se usará el default A1 al guardar.
  Future<void> _startOracleEvaluation() async {
    final result = await context.push<Map<String, dynamic>>(
      '/oracle-test?target=${_selectedLanguageCode}&native=${_selectedNativeLanguageCode}',
    );
    if (!mounted) return;
    setState(() {
      _currentPage = 3;
      if (result != null && result['cefrLevel'] != null) {
        _selectedCefrCode = result['cefrLevel'] as String;
        _gameRank = result['gameRank'] as String? ?? _gameRank;
      }
    });
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Opción manual para hablantes super-básicos: asigna PRE-A1 (rango F) sin
  /// pasar el examen del Oráculo.
  void _skipOracleAsPreA1() {
    setState(() {
      _selectedCefrCode = 'PRE-A1';
      _gameRank = 'F';
      _currentPage = 3;
    });
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboardingAndPurchase() async {
    setState(() => _isSaving = true);
    try {
      final user =
          ref.read(currentUserProvider) ??
          ref.read(supabaseClientProvider).auth.currentUser;

      // Issue #55: sin sesión no se puede guardar el perfil. Antes se usaba un
      // id `guest_<timestamp>` que rompía el upsert y acababa devolviendo al
      // login sin mensaje.
      if (user == null) {
        if (mounted) {
          setState(() => _isSaving = false);
          SystemSnack.show(
            context,
            'SESIÓN NO VÁLIDA: vuelve a iniciar sesión.',
            type: SystemSnackType.error,
          );
        }
        return;
      }

      final String targetUserId = user.id;

      // Si el usuario omitió la evaluación del Oráculo (paso opcional), se
      // parte del rango inicial A1.
      final String cefrCode = _selectedCefrCode.isEmpty
          ? 'A1'
          : _selectedCefrCode;

      await ref
          .read(onboardingRepositoryProvider)
          .saveOnboardingData(
            userId: targetUserId,
            targetLanguageCode: _selectedLanguageCode,
            nativeLanguageCode: _selectedNativeLanguageCode,
            cefrLevelCode: cefrCode,
            dailyGoalMinutes: _selectedDailyGoal,
            interests: _selectedInterests,
            motivation: 'career',
            correctionStyle: _selectedCorrectionStyle,
            tutorPersonality: 'friendly',
            primaryObstacle: _selectedObstacle,
            learningStyle: 'auditory_interactive',
          );

      // El perfil ya existe: marca la caché del Navigation Decision Engine
      // (en memoria + persistida) para que el redirect no vuelva a forzar el
      // onboarding ni consulte la DB.
      await NavigationDecisionEngine.markProfileExists(targetUserId);

      final languageNotifier = ref.read(userLanguageProvider.notifier);
      await languageNotifier.setLearningLanguage(_selectedLanguageCode);
      await languageNotifier.setAiExplanationsInNative(
        _selectedCorrectionExplanationLanguage == 'native',
      );

      if (_characterClass.isNotEmpty) {
        try {
          // #73: `game_rank` y `cefr_level_id` los asigna el servidor; aquí
          // solo se guarda lo que sí es del jugador (clase y avatar).
          await ref
              .read(supabaseClientProvider)
              .from('user_language_profiles')
              .update({
                'character_class': _characterClass,
                'avatar_index': _selectedAvatarIndex,
              })
              .eq('user_id', targetUserId);
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/onboarding/presentation/screens/onboarding_screen.dart:249',
            e,
            stackTrace: st,
          );
        }
      }

      try {
        final accountName =
            (user.userMetadata?['full_name'] as String?) ??
            (user.email?.split('@').first ?? 'Hunter');
        await ref
            .read(dashboardRepositoryProvider)
            .updateUserProfile(
              targetUserId,
              displayName: _characterName.isNotEmpty
                  ? _characterName
                  : accountName,
              nativeLanguage: _selectedNativeLanguageCode,
              bio: '¡Hola! Soy un cazador aventurero.',
            );
        ref.invalidate(userProfileProvider);
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/onboarding/presentation/screens/onboarding_screen.dart:263',
          e,
          stackTrace: st,
        );
      }

      // UX-02: el paywall se mueve post-sesión. El onboarding siempre arranca en plan free.
      ref.read(isPremiumProvider.notifier).setPremium(false);

      try {
        await ref
            .read(userLanguageProvider.notifier)
            .setLearningLanguage(_selectedLanguageCode);
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/onboarding/presentation/screens/onboarding_screen.dart:270',
          e,
          stackTrace: st,
        );
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showHeroWelcome = true;
        });
        _trackOnboarding('onboarding_completed', {
          'cefr': _selectedCefrCode,
          'native': _selectedNativeLanguageCode,
          'target': _selectedLanguageCode,
          'daily_goal': _selectedDailyGoal,
          'interests': _selectedInterests.length,
        });
      }
    } catch (e) {
      debugPrint('Onboarding save failed: $e');
      _trackOnboarding('onboarding_failed', {'error': e.toString()});
      if (mounted) {
        setState(() => _isSaving = false);
        // Issue #55: antes se redirigía a /home en silencio y el router
        // devolvía al login sin explicar nada.
        SystemSnack.show(
          context,
          'NO SE PUDO GUARDAR TU PERFIL. Revisa tu conexión e inténtalo de nuevo.',
          type: SystemSnackType.error,
        );
      }
    }
  }

  CyberBgMode _getOnboardingBgMode() {
    switch (_currentPage) {
      case 0:
        return CyberBgMode.onboardingStep0;
      case 1:
        return CyberBgMode.onboardingStep2;
      case 2:
        return CyberBgMode.onboardingStep7;
      case 3:
        return CyberBgMode.onboardingStep3;
      default:
        return CyberBgMode.onboardingStep0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_showHeroWelcome) {
      return _buildHeroWelcomeScreen(context);
    }

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: _getOnboardingBgMode(),
        child: Stack(
          children: [
            // Background Glow Orbs
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

            // Main Layout
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Onboarding Header & Progress Indicator (5 pasos — UX-01)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.onSurface,
                            ),
                            onPressed: _prevPage,
                          )
                        else
                          const SizedBox(width: 48),
                        // Segmented Progress Bar (5 pasos)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              final isActive = index <= _currentPage;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.runeViolet
                                        : AppColors.onSurface.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${_currentPage + 1}/4',
                          style: AppTypography.stat(
                            context,
                          ).copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Scrollable Questionnaire Pages (4 pasos)
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildNativeLanguagePage(theme),
                          _buildTargetLanguagePage(theme),
                          _buildAiClassificationPage(theme),
                          _buildCharacterCreationPage(theme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottom Action Button (oculto en el paso 4 — el wizard de personaje tiene su propio botón)
                    if (_currentPage != 3)
                      ElevatedButton(
                        onPressed: _isSaving ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.runeViolet,
                          foregroundColor: AppColors.onSurface,
                          // Issue #60: el texto largo desbordaba el ancho del botón.
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.runeViolet.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.onSurface,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _currentPage == 2
                                      ? l10n.onboarding_start_eval
                                      : l10n.btn_continue,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.title(context),
                                ),
                              ),
                      ),
                    if (_currentPage != 3) const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _showPrivacyDialog(context),
                      icon: const Icon(
                        Icons.privacy_tip_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        l10n.onboarding_privacy_link,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
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

  IconData _heroClassIcon(String heroClass) {
    return HunterClass.findById(heroClass).icon;
  }

  Color _heroClassColor(String heroClass) {
    return HunterClass.findById(heroClass).color;
  }

  String _heroClassName(String heroClass, AppLocalizations l10n) {
    return HunterClass.findById(heroClass).getName(l10n);
  }

  /// Formatea una fecha como "dd/MM/yyyy" para la licencia del gremio.
  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }

  /// Pantalla final del onboarding (Fase 2 auditoría): tarjeta del héroe.
  /// Resumen del aventurero (nombre, clase, CEFR y rango del juego) antes de
  /// entrar al reino. El guardado ya se completó en [_completeOnboardingAndPurchase].
  Widget _buildHeroWelcomeScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = _characterName.isNotEmpty ? _characterName : 'Hunter';
    final heroClass = _characterClass.isNotEmpty ? _characterClass : 'warrior';
    final cefrCode = _selectedCefrCode.isEmpty ? 'A1' : _selectedCefrCode;
    final gameRank = _gameRank ?? CefrRank.gameRankFromCefr(cefrCode);
    final classColor = _heroClassColor(heroClass);

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.onboardingStep3,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.royalGold.withValues(alpha: 0.12),
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
                  color: AppColors.runeViolet.withValues(alpha: 0.1),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 24.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(),
                              Text(
                                l10n.welcome_hunter_prefix,
                                textAlign: TextAlign.center,
                                style: AppTypography.headline(context),
                              ),
                              Text(
                                l10n.welcome_hunter_suffix,
                                textAlign: TextAlign.center,
                                style: AppTypography.headline(
                                  context,
                                ).copyWith(color: AppColors.royalGold),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                displayName,
                                textAlign: TextAlign.center,
                                style: AppTypography.subtitle(context).copyWith(
                                  color: AppColors.manaCyan,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Tarjeta de Licencia de Gremio (avatar real + nivel IA + detalles)
                              GlassCard(
                                borderColor: AppColors.royalGold,
                                border: Border.all(
                                  color: AppColors.royalGold.withValues(
                                    alpha: 0.6,
                                  ),
                                  width: 1.5,
                                ),
                                showRunicCorners: true,
                                runicColor: AppColors.royalGold,
                                opacity: AppColors.glassOpacity,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      // Avatar real del aventurero (imagen)
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: classColor,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: classColor.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            HunterClass.findById(
                                              heroClass,
                                            ).avatarAsset,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  color: AppColors
                                                      .surfaceContainerLow,
                                                  child: Icon(
                                                    _heroClassIcon(heroClass),
                                                    color: classColor,
                                                    size: 44,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Nombre del aventurero
                                      Text(
                                        displayName,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.headline(context)
                                            .copyWith(
                                              color: AppColors.onSurface,
                                              fontSize: 22,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Clase + rol
                                      Text(
                                        _heroClassName(heroClass, l10n),
                                        style: AppTypography.subtitle(context)
                                            .copyWith(
                                              color: classColor,
                                              letterSpacing: 1,
                                            ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Nivel IA (CEFR + rango)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildHeroRankPill(
                                            context,
                                            l10n.hero_cefr_label,
                                            cefrCode,
                                          ),
                                          const SizedBox(width: 12),
                                          _buildHeroRankPill(
                                            context,
                                            l10n.rank,
                                            gameRank,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Descripción del rango
                                      Text(
                                        CefrRank.rankDescription(gameRank),
                                        textAlign: TextAlign.center,
                                        style: AppTypography.bodyMuted(context)
                                            .copyWith(
                                              color: AppColors.onSurface
                                                  .withValues(alpha: 0.75),
                                              height: 1.4,
                                            ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Detalles de licencia (clase + fecha)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.royalGold
                                                .withValues(alpha: 0.3),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                        ),
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 14,
                                          runSpacing: 6,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.badge_outlined,
                                                  size: 14,
                                                  color: AppColors.royalGold,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${l10n.hero_class_label}: ${_heroClassName(heroClass, l10n)}',
                                                  style:
                                                      AppTypography.tiny(
                                                        context,
                                                      ).copyWith(
                                                        color: AppColors
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 14,
                                                  color: AppColors.royalGold,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${l10n.hero_member_since}: ${_formatDate(DateTime.now())}',
                                                  style:
                                                      AppTypography.tiny(
                                                        context,
                                                      ).copyWith(
                                                        color: AppColors
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                l10n.adventure_begins,
                                textAlign: TextAlign.center,
                                style: AppTypography.body(context).copyWith(
                                  color: AppColors.onSurface.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              RunicButton(
                                label: l10n.enter_realm,
                                icon: Icons.door_front_door_rounded,
                                backgroundColor: AppColors.royalGold,
                                foregroundColor: AppColors.voidBg,
                                onPressed: () => context.go('/home'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroRankPill(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.royalGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.tiny(
              context,
            ).copyWith(color: AppColors.royalGold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.stat(
              context,
            ).copyWith(color: AppColors.royalGoldLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCreationPage(ThemeData theme) {
    return CharacterCreationWizard(
      onComplete: (data) {
        setState(() {
          _characterName = data.name;
          _characterClass = data.playerClass;
          _selectedAvatarIndex = data.avatarIndex;
        });
        _nextPage();
      },
    );
  }

  // 🟢 Página 0: Idioma del Despertar (idioma nativo + idioma de la interfaz)
  Widget _buildNativeLanguagePage(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboarding_lang, style: AppTypography.headline(context)),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_lang_desc,
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          // Native Language Selector
          Text(
            l10n.onboarding_native_lang,
            style: AppTypography.body(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: AppColors.manaCyan),
          ),
          const SizedBox(height: 8),
          ..._nativeLanguages.map((lang) {
            final isSelected = _selectedNativeLanguageCode == lang['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(minHeight: 48),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNativeLanguageCode = lang['code']!;
                  });
                },
                child: GlassCard(
                  // Issue #56: el GlassCard tiene su propio GestureDetector y
                  // bloquea el tap del padre; el callback debe ir aquí.
                  onTap: () {
                    setState(() {
                      _selectedNativeLanguageCode = lang['code']!;
                    });
                  },
                  border: Border.all(
                    color: isSelected
                        ? AppColors.runeViolet
                        : AppColors.onSurface.withValues(alpha: 0.10),
                  ),
                  opacity: AppColors.glassOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.runeViolet
                                  : AppColors.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            lang['code']!.toUpperCase(),
                            style: AppTypography.label(context).copyWith(
                              color: isSelected
                                  ? AppColors.runeViolet
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${lang['native']} (${lang['name']})',
                            style: AppTypography.body(context).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.runeViolet,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 🟢 Página 1: País de Origen
  Widget _buildTargetLanguagePage(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboarding_target, style: AppTypography.headline(context)),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_target_desc,
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          // Idioma único (EN): DungeonSpeak enseña inglés por defecto.
          // Sin selector de idioma — la app fija 'en' como idioma objetivo.
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(minHeight: 48),
            child: GlassCard(
              border: Border.all(color: AppColors.runeViolet, width: 1.5),
              opacity: AppColors.glassOpacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Text(
                      'EN',
                      style: AppTypography.stat(
                        context,
                      ).copyWith(color: AppColors.runeViolet),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'English (English)',
                        style: AppTypography.body(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.runeViolet,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.runeViolet,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_english_only,
            style: AppTypography.bodyMuted(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 🟢 Página 3: Clasificación del Oráculo (evaluación IA, paso opcional)
  Widget _buildAiClassificationPage(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboarding_oracle_classification,
            style: AppTypography.headline(context),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_oracle_classification_desc,
            style: AppTypography.body(
              context,
            ).copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          // GlassCard destacada con la explicación de la evaluación conversacional
          GlassCard(
            borderColor: AppColors.royalGold,
            border: Border.all(
              color: AppColors.royalGold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            opacity: AppColors.glassOpacity,
            showRunicCorners: true,
            runicColor: AppColors.royalGold,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.royalGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.royalGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.onboarding_voice_evaluation,
                          style: AppTypography.subtitle(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.royalGold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.onboarding_voice_evaluation_desc,
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 12),
          GestureDetector(
            onTap: _skipOracleAsPreA1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.manaCyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.manaCyan.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    color: AppColors.manaCyan,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.onboarding_beginner ??
                        'SOY PRINCIPIANTE ABSOLUTO (PRE-A1)',
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitle(
                      context,
                    ).copyWith(color: AppColors.manaCyan),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)?.onboarding_beginner_desc ??
                        'Aún no sé formar oraciones: solo palabras sueltas y vocabulario mínimo. Empezaré en Fundamentos sin examen.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted(context).copyWith(
                      fontSize: 11,
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            l10n.onboarding_evaluation_optional,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted(
              context,
            ).copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
