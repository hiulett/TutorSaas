import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../../../l10n/app_localizations.dart';
import '../../data/country_catalog.dart';
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
  String _selectedCountryCode = 'MX';
  String _selectedCefrCode = 'A1';
  String? _gameRank;
  int _selectedDailyGoal = 15;
  final List<String> _selectedInterests = [];
  String _selectedCorrectionStyle = 'balanced';
  String _selectedCorrectionExplanationLanguage = 'native'; // 'native' vs 'target'
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

  final List<Map<String, String>> _targetLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'desc': 'Global communication & professional growth'},
    {'code': 'fr', 'name': 'French', 'native': 'Français', 'desc': 'Culture, gastronomy & international relations'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch', 'desc': 'Engineering, science & European business'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano', 'desc': 'Art, design, music & tourism'},
  ];

  @override
  void initState() {
    super.initState();
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
          AppLocalizations.of(context)?.onboarding_device_lang(deviceLang.toUpperCase()) ??
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
    // Onboarding de 5 pasos (T04-T06): nativo → país → objetivo → clasificación IA → personaje.
    if (_currentPage == 0 && _selectedNativeLanguageCode.isEmpty) {
      SystemSnack.show(context, l10n.onb_validate_native,
          type: SystemSnackType.warning,
          duration: const Duration(milliseconds: 1500));
      return;
    }

    if (_currentPage == 2 && _selectedLanguageCode.isEmpty) {
      SystemSnack.show(context, l10n.onb_validate_target,
          type: SystemSnackType.warning,
          duration: const Duration(milliseconds: 1500));
      return;
    }

    if (_currentPage == 3) {
      _startOracleEvaluation();
      return;
    }

    if (_currentPage < 4) {
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
      _currentPage = 4;
      if (result != null && result['cefrLevel'] != null) {
        _selectedCefrCode = result['cefrLevel'] as String;
        _gameRank = result['gameRank'] as String? ?? _gameRank;
      }
    });
    _pageController.animateToPage(
      4,
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
      _currentPage = 4;
    });
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboardingAndPurchase() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider) ?? ref.read(supabaseClientProvider).auth.currentUser;
      final String targetUserId = user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

      // Si el usuario omitió la evaluación del Oráculo (paso opcional), se
      // parte del rango inicial A1.
      final String cefrCode = _selectedCefrCode.isEmpty ? 'A1' : _selectedCefrCode;

      await ref.read(onboardingRepositoryProvider).saveOnboardingData(
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
          _selectedCorrectionExplanationLanguage == 'native');

      try {
        await ref.read(supabaseClientProvider).from('users').update({
          'country_code': _selectedCountryCode,
        }).eq('id', targetUserId);
      } catch (_) {}

      if (_gameRank != null || _characterClass.isNotEmpty) {
        try {
          await ref.read(supabaseClientProvider).from('user_language_profiles').update({
            if (_gameRank != null) 'game_rank': _gameRank,
            'character_class': _characterClass.isNotEmpty ? _characterClass : 'warrior',
            'avatar_index': _selectedAvatarIndex,
          }).eq('user_id', targetUserId);
        } catch (_) {}
      }

      try {
        final accountName = (user?.userMetadata?['full_name'] as String?) ??
            (user?.email?.split('@').first ?? 'Hunter');
        await ref.read(dashboardRepositoryProvider).updateUserProfile(
          targetUserId,
          displayName: _characterName.isNotEmpty ? _characterName : accountName,
          avatarUrl: _characterClass,
          nativeLanguage: _selectedNativeLanguageCode,
          bio: '[Stats|STR:5|INT:5|DEX:5|LUK:5] ¡Hola! Soy un cazador aventurero.',
        );
        ref.invalidate(userProfileProvider);
      } catch (_) {}

      // UX-02: el paywall se mueve post-sesión. El onboarding siempre arranca en plan free.
      ref.read(isPremiumProvider.notifier).setPremium(false);

      try {
        await ref.read(userLanguageProvider.notifier).setLearningLanguage(_selectedLanguageCode);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showHeroWelcome = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.go('/home');
      }
    }
  }

  CyberBgMode _getOnboardingBgMode() {
    switch (_currentPage) {
      case 0: return CyberBgMode.onboardingStep0;
      case 1: return CyberBgMode.onboardingStep1;
      case 2: return CyberBgMode.onboardingStep2;
      case 3: return CyberBgMode.onboardingStep7;
      case 4: return CyberBgMode.onboardingStep3;
      default: return CyberBgMode.onboardingStep0;
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Onboarding Header & Progress Indicator (5 pasos — UX-01)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                          onPressed: _prevPage,
                        )
                      else
                        const SizedBox(width: 48),
                      // Segmented Progress Bar (5 pasos)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final isActive = index <= _currentPage;
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.runeViolet
                                      : AppColors.onSurface.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_currentPage + 1}/5',
                        style: AppTypography.stat(context).copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Scrollable Questionnaire Pages (5 pasos — UX-01)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildNativeLanguagePage(theme),
                        _buildCountryPage(theme),
                        _buildTargetLanguagePage(theme),
                        _buildAiClassificationPage(theme),
                        _buildCharacterCreationPage(theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Action Button (oculto en el paso 4 — el wizard de personaje tiene su propio botón)
                  if (_currentPage != 4)
                    ElevatedButton(
                      onPressed: _isSaving ? null : _nextPage,
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
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: AppColors.onSurface, strokeWidth: 2.5),
                            )
                          : Text(
                              _currentPage == 3 ? l10n.onboarding_start_eval : l10n.btn_continue,
                              style: AppTypography.title(context),
                            ),
                    ),
                  if (_currentPage != 4) const SizedBox(height: 12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
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
                                style: AppTypography.headline(context).copyWith(
                                  color: AppColors.royalGold,
                                ),
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
                                border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.6), width: 1.5),
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
                                          border: Border.all(color: classColor, width: 2),
                                          boxShadow: [BoxShadow(color: classColor.withValues(alpha: 0.4), blurRadius: 16)],
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            HunterClass.findById(heroClass).avatarAsset,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: AppColors.surfaceContainerLow,
                                              child: Icon(_heroClassIcon(heroClass), color: classColor, size: 44),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Nombre del aventurero
                                      Text(
                                        displayName,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.headline(context).copyWith(
                                          color: AppColors.onSurface,
                                          fontSize: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Clase + rol
                                      Text(
                                        _heroClassName(heroClass, l10n),
                                        style: AppTypography.subtitle(context).copyWith(
                                          color: classColor,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Nivel IA (CEFR + rango)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildHeroRankPill(context, l10n.hero_cefr_label, cefrCode),
                                          const SizedBox(width: 12),
                                          _buildHeroRankPill(context, l10n.rank, gameRank),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Descripción del rango
                                      Text(
                                        CefrRank.rankDescription(gameRank),
                                        textAlign: TextAlign.center,
                                        style: AppTypography.bodyMuted(context).copyWith(
                                          color: AppColors.onSurface.withValues(alpha: 0.75),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      // Detalles de licencia (clase + fecha)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.3)),
                                          borderRadius: BorderRadius.circular(AppRadius.sm),
                                        ),
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 14,
                                          runSpacing: 6,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.badge_outlined, size: 14, color: AppColors.royalGold),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${l10n.hero_class_label}: ${_heroClassName(heroClass, l10n)}',
                                                  style: AppTypography.tiny(context).copyWith(color: AppColors.onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.royalGold),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${l10n.hero_member_since}: ${_formatDate(DateTime.now())}',
                                                  style: AppTypography.tiny(context).copyWith(color: AppColors.onSurfaceVariant),
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
                                  color: AppColors.onSurface.withValues(alpha: 0.8),
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
            style: AppTypography.tiny(context).copyWith(color: AppColors.royalGold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.stat(context).copyWith(
              color: AppColors.royalGoldLight,
              fontSize: 16,
            ),
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
          Text(
            l10n.onboarding_lang,
            style: AppTypography.headline(context),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_lang_desc,
            style: AppTypography.body(context).copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Native Language Selector
          Text(
            l10n.onboarding_native_lang,
            style: AppTypography.body(context).copyWith(fontWeight: FontWeight.bold, color: AppColors.manaCyan),
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
                  border: Border.all(color: isSelected ? AppColors.runeViolet : AppColors.onSurface.withValues(alpha: 0.10)),
                  opacity: AppColors.glassOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? AppColors.runeViolet : AppColors.outlineVariant, width: 1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            lang['code']!.toUpperCase(),
                            style: AppTypography.label(context).copyWith(
                              color: isSelected ? AppColors.runeViolet : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${lang['native']} (${lang['name']})',
                            style: AppTypography.body(context).copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, color: AppColors.runeViolet, size: 20),
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
  Widget _buildCountryPage(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboarding_country_title,
            style: AppTypography.headline(context),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_country_desc,
            style: AppTypography.body(context).copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Dropdown con buscador sobre el catálogo completo de países
          Builder(
            builder: (context) {
              final currentSelected = CountryCatalog.countries
                  .firstWhere((c) => c.code == _selectedCountryCode, orElse: () => CountryCatalog.countries.first);
              return GestureDetector(
                onTap: () => _openCountryDropdown(context, locale),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentSelected.getName(locale),
                          style: AppTypography.body(context).copyWith(color: AppColors.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.manaCyan, size: 28),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _openCountryDropdown(BuildContext context, String locale) async {
    final selected = await showModalBottomSheet<CountryCatalogItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (sheetContext) => _CountryDropdownSheet(
        locale: locale,
        currentCode: _selectedCountryCode,
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedCountryCode = selected.code;
      });
    }
  }

  // 🟢 Página 2: Idioma a Aprender
  Widget _buildTargetLanguagePage(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboarding_target,
            style: AppTypography.headline(context),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_target_desc,
            style: AppTypography.body(context).copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          ..._targetLanguages.map((lang) {
            final isSelected = _selectedLanguageCode == lang['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(minHeight: 48),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguageCode = lang['code']!;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : AppColors.onSurface.withValues(alpha: 0.10)),
                  opacity: AppColors.glassOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          lang['code']!.toUpperCase(),
                          style: AppTypography.stat(context).copyWith(
                            color: isSelected ? AppColors.runeViolet : AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${lang['name']} (${lang['native']})',
                            style: AppTypography.body(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.runeViolet : AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, color: AppColors.runeViolet, size: 20),
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
            style: AppTypography.body(context).copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // GlassCard destacada con la explicación de la evaluación conversacional
          GlassCard(
            borderColor: AppColors.royalGold,
            border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.6), width: 1.5),
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
                        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.royalGold, size: 24),
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
                border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.eco_rounded, color: AppColors.manaCyan, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.onboarding_beginner ?? 'SOY PRINCIPIANTE ABSOLUTO (PRE-A1)',
                    textAlign: TextAlign.center,
                    style: AppTypography.subtitle(context).copyWith(
                      color: AppColors.manaCyan,
                    ),
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
            style: AppTypography.bodyMuted(context).copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CountryDropdownSheet extends StatefulWidget {
  final String locale;
  final String currentCode;

  const _CountryDropdownSheet({required this.locale, required this.currentCode});

  @override
  State<_CountryDropdownSheet> createState() => _CountryDropdownSheetState();
}

class _CountryDropdownSheetState extends State<_CountryDropdownSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCatalogItem> _results = CountryCatalog.countries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.toLowerCase();
    setState(() {
      _results = q.isEmpty
          ? CountryCatalog.countries
          : CountryCatalog.countries.where((c) {
              final name = c.getName(widget.locale).toLowerCase();
              return name.contains(q) || c.code.toLowerCase().contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  style: AppTypography.body(context).copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                    hintText: l10n.onboarding_country_search_hint,
                    hintStyle: AppTypography.body(context).copyWith(color: AppColors.onSurface.withValues(alpha: 0.3)),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(color: AppColors.manaCyan),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Country list
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text(
                          l10n.onboarding_country_no_results,
                          style: AppTypography.bodyMuted(context),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final isSelected = item.code == widget.currentCode;
                          return ListTile(
                            dense: true,
                            leading: Text(
                              item.code,
                              style: AppTypography.label(context).copyWith(
                                color: isSelected ? AppColors.manaCyan : AppColors.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              item.getName(widget.locale),
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.manaCyan, size: 20)
                                : null,
                            onTap: () => Navigator.of(context).pop(item),
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
