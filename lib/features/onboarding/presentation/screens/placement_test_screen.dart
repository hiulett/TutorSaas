import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/placement_providers.dart';

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1 — Goal
  String _selectedGoal = '';

  // Step 2 — Obstacle
  String _selectedObstacle = '';

  // Step 3 — Quick comprehension quiz
  final Map<int, String> _quizAnswers = {};

  // Step 4 — Result
  bool _isSaving = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Data ───────────────────────────────────────────────────────────────────

  final List<Map<String, dynamic>> _goals = [
    {'id': 'professional', 'icon': Icons.business_center, 'label': 'WORK & CAREER'},
    {'id': 'academic', 'icon': Icons.school, 'label': 'ACADEMICS & EXAMS'},
    {'id': 'social_travel', 'icon': Icons.flight, 'label': 'TRAVEL & SOCIAL'},
    {'id': 'personal', 'icon': Icons.emoji_events, 'label': 'PERSONAL GROWTH'},
  ];

  final List<Map<String, dynamic>> _obstacles = [
    {'id': 'speaking_fluency', 'icon': Icons.record_voice_over, 'label': 'SPEAKING FLUENCY'},
    {'id': 'listening', 'icon': Icons.hearing, 'label': 'UNDERSTANDING SPEECH'},
    {'id': 'grammar_structure', 'icon': Icons.edit, 'label': 'GRAMMAR STRUCTURE'},
    {'id': 'pronunciation', 'icon': Icons.mic, 'label': 'PRONUNCIATION & ACCENT'},
  ];

  /// Simple 3-question progressive quiz (A2 -> B1 -> B2)
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'Choose the correct sentence (A2):',
      'options': [
        'She don\'t like coffee.',
        'She doesn\'t like coffee.',
        'She not like coffee.',
        'She isn\'t like coffee.',
      ],
      'correct': 'She doesn\'t like coffee.',
    },
    {
      'question': 'What does "I\'m exhausted" mean (B1)?',
      'options': [
        'Estoy emocionado.',
        'Estoy enojado.',
        'Estoy muy cansado.',
        'Estoy confundido.',
      ],
      'correct': 'Estoy muy cansado.',
    },
    {
      'question': 'Choose the correct connector (B2): "___ the rain, we went for a walk."',
      'options': ['Although', 'Despite', 'However', 'Because'],
      'correct': 'Despite',
    },
  ];

  // ── Level computation ───────────────────────────────────────────────────────

  /// Computes the final CEFR level based on quiz score.
  String _computeLevel() {
    final score = _quizScore;
    if (score == 0) return 'A1';
    if (score == 1) return 'A2';
    if (score == 2) return 'B1';
    return 'B2';
  }

  int get _quizScore => _quizAnswers.entries.where((e) {
        final q = _quizQuestions[e.key];
        return e.value == q['correct'];
      }).length;


  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _next() {
    // Validation
    if (_currentStep == 0 && _selectedGoal.isEmpty) {
      _showError('PLEASE CHOOSE YOUR OBJECTIVE.');
      return;
    }
    if (_currentStep == 1 && _selectedObstacle.isEmpty) {
      _showError('PLEASE CHOOSE YOUR OBSTACLE.');
      return;
    }
    if (_currentStep == 2 && _quizAnswers.length < _quizQuestions.length) {
      _showError('COMPLETE ALL CHALLENGES TO CONTINUE.');
      return;
    }

    if (_currentStep == 3) {
      _saveAndContinue();
      return;
    }

    setState(() => _currentStep++);
    _fadeCtrl
      ..reset()
      ..forward();
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _prev() {
    if (_currentStep == 0) return;
    setState(() => _currentStep--);
    _fadeCtrl
      ..reset()
      ..forward();
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.crimsonRed,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          side: BorderSide(color: AppColors.bossRed, width: 1.0),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider);
      final finalLevel = _computeLevel();
      if (user != null) {
        await ref.read(placementRepositoryProvider).savePlacementResult(
              userId: user.id,
              cefrLevel: finalLevel,
              learningGoal: _selectedGoal,
              mainDifficulty: _selectedObstacle,
              quizScore: _quizScore,
            );
      }
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('ERROR SAVING LICENSE. CONTINUING ANYWAY.');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.go('/home');
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.onboardingStep2,
        child: Stack(
          children: [
            // Background Glow Orbs matching onboarding
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
                    _buildHeader(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStepGoal(),
                          _buildStepObstacle(),
                          _buildStepQuiz(),
                          _buildStepResult(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBottomNav(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header matching onboarding progress indicator ──────────────────────────

  Widget _buildHeader() {
    final stepTitles = [
      'CHOOSE YOUR TARGET GATE',
      'CHOOSE YOUR OBSTACLE',
      'CALIBRATING COMPREHENSION',
      'HUNTER LEVEL ACQUIRED',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0 && _currentStep < 3)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: _prev,
              )
            else
              const SizedBox(width: 48),
            // Segmented Progress Bar (4 steps)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.runeViolet
                             : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 24),
            Text(
              '${_currentStep + 9}/12', // Continuation of 8 onboarding screens
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _fadeAnim,
          child: Text(
            stepTitles[_currentStep],
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }


  // ── Step 1: Goal ────────────────────────────────────────────────────────────

  Widget _buildStepGoal() {
    return _buildOptionGrid(
      items: _goals,
      selected: _selectedGoal,
      onSelect: (id) => setState(() => _selectedGoal = id),
    );
  }

  // ── Step 2: Obstacle ────────────────────────────────────────────────────────

  Widget _buildStepObstacle() {
    return _buildOptionGrid(
      items: _obstacles,
      selected: _selectedObstacle,
      onSelect: (id) => setState(() => _selectedObstacle = id),
    );
  }

  // ── Step 3: Quiz ────────────────────────────────────────────────────────────

  Widget _buildStepQuiz() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Text(
          'ANSWER THESE 3 QUICK CHALLENGES:',
          style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 12, letterSpacing: 0.5),
        ),
        const SizedBox(height: 20),
        ...List.generate(_quizQuestions.length, (qi) {
          final q = _quizQuestions[qi];
          final options = q['options'] as List<String>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${qi + 1}. ${q['question']}',
                style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...options.map((opt) {
                final selected = _quizAnswers[qi] == opt;
                return GestureDetector(
                  onTap: () => setState(() => _quizAnswers[qi] = opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: selected
                          ? AppColors.runeViolet.withValues(alpha: 0.18)
                          : AppColors.surfaceContainerLow.withValues(alpha: 0.08),
                      border: Border.all(
                        color: selected
                            ? AppColors.runeViolet
                            : Colors.white.withValues(alpha: 0.07),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  // ── Step 5: Result ──────────────────────────────────────────────────────────

  Widget _buildStepResult() {
    final finalLevel = _computeLevel();
    final studyPlan = _buildStudyPlan(finalLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Level badge
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: AppColors.manaCyan, width: 2.0),
              gradient: const LinearGradient(
                colors: [
                  AppColors.runeViolet,
                  AppColors.manaCyan,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.manaCyan.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                finalLevel,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            finalLevel == 'A1' ? 'Beginner (A1)' :
            finalLevel == 'A2' ? 'Elementary (A2)' :
            finalLevel == 'B1' ? 'Intermediate (B1)' : 'Upper Intermediate (B2)',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
          ),

          const SizedBox(height: 8),
          Text(
            'Score: $_quizScore / ${_quizQuestions.length} Correct',
            style: GoogleFonts.jetBrainsMono(
              color: _quizScore >= 2
                  ? AppColors.manaCyan
                  : AppColors.runeViolet,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR STUDY PLAN',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ...studyPlan.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✦ ',
                            style: TextStyle(
                                color: AppColors.manaCyan, fontSize: 12)),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isSaving)
            const CircularProgressIndicator()
          else
            Text(
              'UPON CONTINUING, THE AI TUTOR WILL CALIBRATE TO YOUR LEVEL ($finalLevel).',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 10),
            ),
        ],
      ),
    );
  }

  List<String> _buildStudyPlan(String level) {
    const plans = {
      'A1': [
        'Start with basic everyday dungeon vocabulary.',
        'Simple introduction raids and greeting templates.',
        '10 minutes of guided daily practice sessions.',
        'Learn specific English phonemes and sound mechanics.',
      ],
      'A2': [
        'Useful commands and phrases for common situations.',
        'Practice with rapid question & short-response tasks.',
        'Grammar structure: present simple and continuous gates.',
        'Simulated roleplay gates (shops, gate registry).',
      ],
      'B1': [
        'Engage in conversations on tasks, dungeons and work.',
        'Past tense and present perfect context trials.',
        'Thematic vocab: tech, business, and daily raids.',
        'Address and repair common pronunciation obstacles.',
      ],
      'B2': [
        'Fluid debates and dynamic opinion allocation.',
        'Advanced idiom modifiers and colloquial expressions.',
        'Professional communications and command room briefs.',
        'Neutral accent training and cadence modulation.',
      ],
    };
    return plans[level] ?? plans['B1']!;
  }

  // ── Option Grid (shared by steps 1 & 2) ────────────────────────────────────

  Widget _buildOptionGrid({
    required List<Map<String, dynamic>> items,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selected == item['id'];
        return GestureDetector(
          onTap: () => onSelect(item['id']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isSelected
                  ? AppColors.runeViolet.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerLow.withValues(alpha: 0.1),
              border: Border.all(
                color: isSelected
                    ? AppColors.runeViolet
                    : Colors.white.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 28,
                  color: isSelected ? Colors.white : AppColors.manaCyan,
                ),
                const SizedBox(height: 8),
                Text(
                  item['label']!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Navigation ───────────────────────────────────────────────────────

  Widget _buildBottomNav(ThemeData theme) {
    final isLastStep = _currentStep == _totalSteps - 1;
    return ElevatedButton(
      onPressed: _isSaving ? null : _next,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.runeViolet,
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
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            )
          : Text(
              isLastStep ? 'ENTER DUNGEON' : 'CONTINUE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
    );
  }
}
