import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../providers/onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Selected values
  String _selectedLanguageCode = 'en'; // App Default Target Language: English
  String _selectedNativeLanguageCode = 'es'; // Native language
  String _selectedCountryCode = 'MX';
  bool _switchInterfaceToNative = false;
  String _selectedCefrCode = 'A1';
  int _selectedDailyGoal = 15;
  final List<String> _selectedInterests = [];
  String _selectedCorrectionStyle = 'balanced';
  String _selectedCorrectionExplanationLanguage = 'native'; // 'native' vs 'target'
  String _selectedObstacle = '';

  // Paywall & Subscription State
  String _selectedPaywallPlan = 'annual';
  bool _isLoadingPlans = true;
  List<Map<String, dynamic>> _dynamicSubscriptionPlans = [];
  bool _isSaving = false;

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

  final List<Map<String, String>> _countries = [
    {'code': 'MX', 'name': 'México'},
    {'code': 'CO', 'name': 'Colombia'},
    {'code': 'ES', 'name': 'España'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'AR', 'name': 'Argentina'},
    {'code': 'CL', 'name': 'Chile'},
    {'code': 'PE', 'name': 'Perú'},
    {'code': 'BR', 'name': 'Brasil'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'IT', 'name': 'Italy'},
  ];

  final List<Map<String, String>> _targetLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'desc': 'Global communication & professional growth'},
    {'code': 'fr', 'name': 'French', 'native': 'Français', 'desc': 'Culture, gastronomy & international relations'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch', 'desc': 'Engineering, science & European business'},
    {'code': 'it', 'name': 'Italian', 'native': 'Italiano', 'desc': 'Art, design, music & tourism'},
  ];

  final List<Map<String, String>> _levels = [
    {'code': 'A1', 'title': 'Beginner (A1)', 'desc': 'Starting from scratch with basic greetings and phrases.', 'badge': 'A1'},
    {'code': 'A2', 'title': 'Elementary (A2)', 'desc': 'Understand simple sentences, food, shopping & travel.', 'badge': 'A2'},
    {'code': 'B1', 'title': 'Intermediate (B1)', 'desc': 'Hold conversations on familiar topics and work tasks.', 'badge': 'B1'},
    {'code': 'B2', 'title': 'Upper Intermediate (B2)', 'desc': 'Speak fluently about complex topics and debates.', 'badge': 'B2'},
    {'code': 'C1', 'title': 'Advanced (C1)', 'desc': 'Refine professional jargon and academic expression.', 'badge': 'C1'},
    {'code': 'C2', 'title': 'Mastery (C2)', 'desc': 'Near-native fluency across all subjects.', 'badge': 'C2'},
  ];

  final List<Map<String, dynamic>> _goals = [
    {'minutes': 10, 'title': 'Casual', 'desc': '10 min / day. Great for steady daily habit.'},
    {'minutes': 15, 'title': 'Regular', 'desc': '15 min / day. Balanced and steady progress.'},
    {'minutes': 30, 'title': 'Serious', 'desc': '30 min / day. Accelerated language learning.'},
    {'minutes': 45, 'title': 'Intense', 'desc': '45 min / day. Deep immersion and mastery.'},
  ];

  final List<Map<String, dynamic>> _interests = [
    {'code': 'travel', 'name': 'Travel & Tourism', 'icon': Icons.flight},
    {'code': 'business', 'name': 'Career & Business', 'icon': Icons.business_center},
    {'code': 'technology', 'name': 'Technology & AI', 'icon': Icons.computer},
    {'code': 'art', 'name': 'Art & Design', 'icon': Icons.palette},
    {'code': 'sports', 'name': 'Sports & Fitness', 'icon': Icons.sports_soccer},
    {'code': 'music', 'name': 'Music & Movies', 'icon': Icons.music_note},
    {'code': 'science', 'name': 'Science & Innovation', 'icon': Icons.science},
    {'code': 'cooking', 'name': 'Food & Cooking', 'icon': Icons.restaurant},
    {'code': 'history', 'name': 'Culture & History', 'icon': Icons.museum},
  ];

  final List<Map<String, dynamic>> _correctionStyles = [
    {'code': 'strict', 'name': 'Strict', 'desc': 'Correct every grammar detail instantly.', 'icon': Icons.gps_fixed},
    {'code': 'balanced', 'name': 'Balanced', 'desc': 'Correct key mistakes while maintaining natural flow.', 'icon': Icons.balance},
    {'code': 'conversational', 'name': 'Conversational', 'desc': 'Only correct mistakes that prevent understanding.', 'icon': Icons.record_voice_over},
  ];

  final List<Map<String, dynamic>> _obstacles = [
    {'id': 'speaking_fluency', 'icon': Icons.record_voice_over, 'label': 'Speaking Fluency & Confidence'},
    {'id': 'listening', 'icon': Icons.hearing, 'label': 'Listening Comprehension'},
    {'id': 'grammar_structure', 'icon': Icons.edit, 'label': 'Grammar & Sentence Structure'},
    {'id': 'pronunciation', 'icon': Icons.mic, 'label': 'Pronunciation & Accent'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPlansFromDb();
  }

  Future<void> _fetchPlansFromDb() async {
    try {
      final plans = await ref.read(subscriptionRepositoryProvider).getSubscriptionPlans();
      if (mounted) {
        setState(() {
          _dynamicSubscriptionPlans = plans;
          if (plans.isNotEmpty) {
            _selectedPaywallPlan = plans.first['id'] as String? ?? 'annual';
          }
          _isLoadingPlans = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < 7) {
      // Validation Page 4 (Interests) - Quick SnackBar (1.5 seconds)
      if (_currentPage == 4 && _selectedInterests.isEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one interest to continue.'),
            duration: Duration(milliseconds: 1500),
            backgroundColor: AppColors.runeViolet,
          ),
        );
        return;
      }

      // Mandatory Validation Page 6 (Obstacles) - Cannot advance without selection
      if (_currentPage == 6 && _selectedObstacle.isEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your biggest obstacle before continuing.'),
            duration: Duration(milliseconds: 1500),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

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

  Future<void> _completeOnboardingAndPurchase() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider) ?? ref.read(supabaseClientProvider).auth.currentUser;
      final String targetUserId = user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

      await ref.read(onboardingRepositoryProvider).saveOnboardingData(
            userId: targetUserId,
            targetLanguageCode: _selectedLanguageCode,
            nativeLanguageCode: _selectedNativeLanguageCode,
            cefrLevelCode: _selectedCefrCode,
            dailyGoalMinutes: _selectedDailyGoal,
            interests: _selectedInterests,
            motivation: 'career',
            correctionStyle: _selectedCorrectionStyle,
            tutorPersonality: 'friendly',
            primaryObstacle: _selectedObstacle,
            learningStyle: 'auditory_interactive',
          );

      final bool isFreePlan = _selectedPaywallPlan == 'free' || _selectedPaywallPlan.contains('free');

      if (!isFreePlan) {
        // Execute Payment process ONLY for paid plans (Monthly, Annual, Lifetime)
        await ref.read(subscriptionRepositoryProvider).purchasePackage(_selectedPaywallPlan);
        ref.read(isPremiumProvider.notifier).setPremium(true);
      } else {
        // Free Plan: Skip payment process entirely
        ref.read(isPremiumProvider.notifier).setPremium(false);
      }

      if (mounted) {
        context.go('/home');
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
      case 3: return CyberBgMode.onboardingStep3;
      case 4: return CyberBgMode.onboardingStep4;
      case 5: return CyberBgMode.onboardingStep5;
      case 6: return CyberBgMode.onboardingStep6;
      case 7: return CyberBgMode.onboardingStep7;
      default: return CyberBgMode.onboardingStep0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  // Onboarding Header & Progress Indicator (8 pages total)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: _prevPage,
                        )
                      else
                        const SizedBox(width: 48),
                      // Segmented Progress Bar (8 pages)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(8, (index) {
                            final isActive = index <= _currentPage;
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.runeViolet
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_currentPage + 1}/8',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Scrollable Questionnaire Pages (8 Total Steps)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildNativeLanguageAndCountryPage(theme),
                        _buildTargetLanguagePage(theme),
                        _buildLevelPage(theme),
                        _buildGoalPage(theme),
                        _buildInterestsPage(theme),
                        _buildCorrectionStylePage(theme),
                        _buildPlacementObstaclePage(theme),
                        _buildPaywallScreenPage(theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Action Button
                  ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : (_currentPage == 6 && _selectedObstacle.isEmpty)
                            ? null
                            : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_currentPage == 6 && _selectedObstacle.isEmpty)
                          ? Colors.white12
                          : AppColors.runeViolet,
                      foregroundColor: Colors.white,
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
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            _currentPage == 7
                                ? ((_selectedPaywallPlan == 'free' || _selectedPaywallPlan.contains('free'))
                                    ? 'Start Free Practice'
                                    : 'Subscribe & Start Practice')
                                : 'Continue',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // 🟢 Screen 0: Native Language & Country of Origin
  Widget _buildNativeLanguageAndCountryPage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your native language and country?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We will customize your learning journey according to your mother tongue.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Native Language Selector
          Text(
            'Native Language',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
          ),
          const SizedBox(height: 8),
          ..._nativeLanguages.map((lang) {
            final isSelected = _selectedNativeLanguageCode == lang['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNativeLanguageCode = lang['code']!;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.18 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? AppColors.runeViolet : AppColors.outlineVariant, width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            lang['code']!.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.runeViolet : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${lang['native']} (${lang['name']})',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: Colors.white,
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

          const SizedBox(height: 20),
          // Country Selector
          Text(
            'Country of Origin',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                dropdownColor: const Color(0xFF0F172A),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                items: _countries.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['code'],
                    child: Text(c['name']!, style: const TextStyle(color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCountryCode = val;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
          // App Interface Language Preference Switch Card
          GlassCard(
            border: Border.all(color: _switchInterfaceToNative ? AppColors.manaCyan : Colors.white10),
            opacity: _switchInterfaceToNative ? 0.12 : 0.03,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, color: AppColors.manaCyan, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch App Interface Language',
                          style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Change app menus and buttons to ${_selectedNativeLanguageCode.toUpperCase()} instead of English.',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _switchInterfaceToNative,
                    activeThumbColor: AppColors.manaCyan,
                    onChanged: (val) {
                      setState(() {
                        _switchInterfaceToNative = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 🟢 Screen 1: Target Language to Learn (English, French, German, Italian)
  Widget _buildTargetLanguagePage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What language do you want to learn?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the target language you want to practice with your AI voice tutor.',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          ..._targetLanguages.map((lang) {
            final isSelected = _selectedLanguageCode == lang['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLanguageCode = lang['code']!;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.2 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? AppColors.runeViolet : AppColors.outlineVariant, width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            lang['code']!.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.runeViolet : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lang['name']} (${lang['native']})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.runeViolet : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang['desc']!,
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, color: AppColors.runeViolet, size: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🟢 Screen 2: Current CEFR Level
  Widget _buildLevelPage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your current level?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your estimated level. You can adjust this anytime later.',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          ..._levels.map((level) {
            final isSelected = _selectedCefrCode == level['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCefrCode = level['code']!;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.2 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.runeViolet : Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level['badge']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level['title']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.runeViolet : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                level['desc']!,
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, color: AppColors.runeViolet, size: 22),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🟢 Screen 3: Daily Practice Goal
  Widget _buildGoalPage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your daily practice goal?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Consistency is key to speaking fluently.',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          ..._goals.map((goal) {
            final isSelected = _selectedDailyGoal == goal['minutes'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDailyGoal = goal['minutes'] as int;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.2 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_rounded, color: AppColors.manaCyan, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${goal['title']} (${goal['minutes']} min / day)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.runeViolet : Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                goal['desc'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, color: AppColors.runeViolet, size: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🟢 Screen 4: Areas of Interest (Toast duration 1.5s)
  Widget _buildInterestsPage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your areas of interest',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your AI tutor will craft customized scenario dialogues around these topics.',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _interests.map((interest) {
              final isSelected = _selectedInterests.contains(interest['code']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest['code']);
                    } else {
                      _selectedInterests.add(interest['code']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.runeViolet.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.runeViolet : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        interest['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.manaCyan,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          interest['name']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 🟢 Screen 5: Correction Style & Explanation Language
  Widget _buildCorrectionStylePage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like your AI corrections?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tailor how strict the AI tutor is and in which language grammar feedback is explained.',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),

          // Correction Level
          Text(
            'Correction Intensity',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
          ),
          const SizedBox(height: 8),
          ..._correctionStyles.map((style) {
            final isSelected = _selectedCorrectionStyle == style['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCorrectionStyle = style['code']!;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.2 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          style['icon'] as IconData,
                          size: 22,
                          color: isSelected ? Colors.white : AppColors.runeViolet,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style['name']!,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? AppColors.runeViolet : Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(style['desc']!, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
                            ],
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

          const SizedBox(height: 20),
          // NEW Selector: Correction Explanation Language
          Text(
            'Grammar Feedback Language',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCorrectionExplanationLanguage = 'native';
                    });
                  },
                  child: GlassCard(
                    border: Border.all(color: _selectedCorrectionExplanationLanguage == 'native' ? AppColors.manaCyan : Colors.white10),
                    opacity: _selectedCorrectionExplanationLanguage == 'native' ? 0.2 : 0.04,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Icon(Icons.translate_rounded, color: AppColors.manaCyan, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            'Native Language',
                            style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rules in ${_selectedNativeLanguageCode.toUpperCase()}',
                            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCorrectionExplanationLanguage = 'target';
                    });
                  },
                  child: GlassCard(
                    border: Border.all(color: _selectedCorrectionExplanationLanguage == 'target' ? AppColors.runeViolet : Colors.white10),
                    opacity: _selectedCorrectionExplanationLanguage == 'target' ? 0.2 : 0.04,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Icon(Icons.center_focus_strong_rounded, color: AppColors.runeViolet, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            'Target Language',
                            style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '100% in ${_selectedLanguageCode.toUpperCase()}',
                            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🟢 Screen 6: Biggest Obstacle (Mandatory Selection Validation)
  Widget _buildPlacementObstaclePage(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your biggest obstacle when speaking?',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your main challenge so your AI tutor focuses practice sessions on overcoming it.',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),

          ..._obstacles.map((obs) {
            final isSelected = _selectedObstacle == obs['id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedObstacle = obs['id']!;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.2 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          obs['icon'] as IconData,
                          size: 28,
                          color: isSelected ? Colors.white : AppColors.manaCyan,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            obs['label']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.runeViolet : Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_rounded, color: AppColors.runeViolet, size: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 🟢 Screen 7: Dynamic Paywall & Subscription Plans from Supabase DB
  Widget _buildPaywallScreenPage(ThemeData theme) {
    if (_isLoadingPlans) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.runeViolet),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.2),
              ),
              child: const Icon(Icons.stars_rounded, color: AppColors.runeViolet, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Choose your Plan & Start Journey',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Unlock 24/7 AI Voice Tutor & Speech DNA Biometrics',
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          ..._dynamicSubscriptionPlans.map((plan) {
            final String planId = plan['id'] as String? ?? 'annual';
            final isSelected = _selectedPaywallPlan == planId;
            final String title = plan['title'] as String? ?? 'Plan';
            final String price = plan['price'] as String? ?? '\$9.99';
            final String billing = plan['billing'] as String? ?? 'Billed monthly';
            final String? tag = plan['tag'] as String?;
            final int minutesLimit = plan['minutesLimit'] as int? ?? 300;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaywallPlan = planId;
                  });
                },
                child: GlassCard(
                  border: Border.all(color: isSelected ? AppColors.runeViolet : Colors.white10),
                  opacity: isSelected ? 0.2 : 0.04,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tag != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.runeViolet.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.runeViolet),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.runeViolet),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              price,
                              style: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                billing,
                                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer_rounded, color: AppColors.manaCyan, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$minutesLimit min/month AI Audio Practice',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.manaCyan),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
