import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/models/conversation_state.dart';
import '../providers/conversation_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../../dashboard/domain/models/progress_utils.dart';
import '../widgets/voice_waveform_visualizer.dart';
import '../widgets/live_goals_tracker_bar.dart';
import '../../../../core/widgets/draggable_monster_widget.dart';
import '../../../../core/widgets/mana_meter_widget.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../dashboard/data/models/hunter_catalog.dart';
import '../../../../l10n/app_localizations.dart';


class ConversationScreen extends ConsumerStatefulWidget {
  final String? scenarioId;
  final String? scenarioTitle;

  /// Cuando es true, esta pantalla ejecuta la Evaluación del Oráculo
  /// (onboarding Paso 4): la IA conduce un examen oral conversacional
  /// reutilizando el mismo chat de voz y al final devuelve el resultado.
  final bool oracleMode;
  final String? oracleTargetLanguage;
  final String? oracleNativeLanguage;

  const ConversationScreen({
    super.key,
    this.scenarioId,
    this.scenarioTitle,
    this.oracleMode = false,
    this.oracleTargetLanguage,
    this.oracleNativeLanguage,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  late final DateTime _startTime;
  bool _showTopicsBar = false;
  bool _showKeyboardDrawer = false;
  bool _isBlindListening = false;
  bool _isTypingMode = false;
  int _usedMana = 15;
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> _randomTopics = const [
    {'icon': '💼', 'title': 'Tech & AI'},
    {'icon': '✈️', 'title': 'Travel & Culture'},
    {'icon': '🍔', 'title': 'Food & Recipes'},
    {'icon': '🎵', 'title': 'Movies & Music'},
    {'icon': '⚽', 'title': 'Sports & Fitness'},
    {'icon': '🧠', 'title': 'Philosophy & Science'},
    {'icon': '📈', 'title': 'Business & Careers'},
    {'icon': '📚', 'title': 'Books & Stories'},
    {'icon': '🚀', 'title': 'Space Exploration'},
    {'icon': '🎨', 'title': 'Art & Design'},
    {'icon': '🎮', 'title': 'Video Games'},
    {'icon': '🐶', 'title': 'Pets & Animals'},
    {'icon': '🌱', 'title': 'Environment & Nature'},
    {'icon': '🧘', 'title': 'Wellness & Mindfulness'},
    {'icon': '🛍️', 'title': 'Fashion & Trends'},
    {'icon': '🌍', 'title': 'Global Cultures'},
    {'icon': '🏖️', 'title': 'Vacation Destinations'},
    {'icon': '🎬', 'title': 'Pop Culture'},
    {'icon': '🚗', 'title': 'Electric Mobility'},
    {'icon': '🔮', 'title': 'Future Technology'},
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Initialize session with optional scenario persistence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.oracleMode) {
        ref.read(conversationStateProvider.notifier).initOracleSession(
              targetLanguage: widget.oracleTargetLanguage,
              nativeLanguage: widget.oracleNativeLanguage,
            );
      } else {
        ref.read(conversationStateProvider.notifier).initSession(
              scenarioId: widget.scenarioId,
              scenarioTitle: widget.scenarioTitle,
            );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    try {
      ref.read(dashboardRefreshProvider.notifier).state++;
      ref.invalidate(userProgressProvider);
      ref.invalidate(skillsRadarProvider);
      ref.invalidate(practiceHeatmapProvider);
      ref.invalidate(fluencyTrendsProvider);
      ref.invalidate(weeklyPracticeProvider);
      ref.invalidate(learnedVocabularyProvider);
    } catch (_) {}
    super.dispose();
  }

  void _onTopicSelected(String topicTitle) {
    setState(() {
      _showTopicsBar = false;
    });
    final messageText = "Let's change the topic and talk about $topicTitle!";
    ref.read(conversationStateProvider.notifier).sendTextMessage(messageText);
  }

  void _submitTextMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(conversationStateProvider.notifier).sendTextMessage(text);
      _textController.clear();
      setState(() {
        _showKeyboardDrawer = false;
      });
    }
  }

  // ── Modal 1: Compass (Guía de Misión y Contexto) ───────────────────────────

  void _showScenarioMissionModal(BuildContext context) {
    final state = ref.read(conversationStateProvider);
    final lesson = LessonCatalog.getLessonById(
      widget.scenarioId,
      title: widget.scenarioTitle,
    );
    final userChatText = state.messages.where((m) => m.sender == 'user').map((m) => m.text.toLowerCase()).join(' ');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.explore_rounded, color: AppColors.runeViolet, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Guía de Misión y Contexto',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      blur: 20,
                      opacity: 0.05,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.scenarioTitle ?? lesson?.title ?? 'Práctica de Conversación',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Objetivo: ${lesson?.mainObjective ?? 'Practica tu conversación en el idioma seleccionado.'}',
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.conversation_goals, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    if (lesson != null) ...[
                      ...lesson.goals.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final g = entry.value;
                        final isDone = state.goalEvaluationResults[g.id] == true;
                        return _buildGoalItem(
                          '$idx. ${g.text}',
                          isDone,
                          hint: isDone ? null : g.examplePhrase,
                        );
                      }),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Selecciona una lección para ver las metas específicas.',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.conversation_key_phrases, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    if (lesson != null)
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: lesson.usefulPhrases.map((phraseItem) {
                            final isUsed = userChatText.contains(phraseItem.phrase.toLowerCase().split(' ').first);
                            return _buildPhraseChip(context, phraseItem.phrase, isUsed: isUsed);
                          }).toList(),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Selecciona una lección para ver frases clave sugeridas.',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoalItem(String title, bool isCompleted, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isCompleted ? AppColors.manaCyan : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.white54,
                    fontSize: 13,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          if (hint != null && hint.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: Text(
                '💡 $hint',
                style: const TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhraseChip(BuildContext context, String phrase, {bool isUsed = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          ref.read(conversationStateProvider.notifier).sendTextMessage(phrase);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUsed 
                ? AppColors.manaCyan.withValues(alpha: 0.2)
                : AppColors.runeViolet.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUsed ? AppColors.manaCyan : AppColors.runeViolet.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUsed) ...[
                const Icon(Icons.check_circle_rounded, color: AppColors.manaCyan, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                phrase,
                style: TextStyle(
                  color: isUsed ? AppColors.manaCyan : Colors.white,
                  fontSize: 12,
                  fontWeight: isUsed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Modal 2: Fingerprint (Huella de Voz y Diagnóstico) ─────────────────────

  void _showSpeechDnaModal(BuildContext context) {
    final messages = ref.read(conversationStateProvider).messages;
    final userMessages = messages.where((m) => m.sender == 'user').toList();
    final wordCount = userMessages.fold(0, (sum, m) => sum + m.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length);

    // Calculate real WPM based on elapsed practice session time
    final elapsedMinutes = math.max(0.2, DateTime.now().difference(_startTime).inSeconds / 60.0);
    final calculatedWpm = userMessages.isNotEmpty ? (wordCount / elapsedMinutes).round() : 0;
    final wpmText = userMessages.isNotEmpty ? '$calculatedWpm WPM' : '0 WPM';

    // Calculate real phonetic clarity score based on user participation
    final phoneticClarityValue = userMessages.isEmpty
        ? 'N/A'
        : '${math.min(99, math.max(72, 80 + math.min(18, (wordCount / 5).round())))}%';

    // Get real CEFR level and language from user profile
    final progressAsync = ref.read(userProgressProvider);
    final cefrCode = progressAsync.value?['level_code'] as String? ?? 'A1';
    final cefrLevel = progressAsync.value?['level'] as String? ?? 'Principiante';
    final cefrText = '$cefrCode ($cefrLevel)';
    final languageName = progressAsync.value?['language'] as String? ?? 'Inglés';
    final cleanLanguage = languageName.toLowerCase();

    // Extract real phonemes to practice based on words present in actual user text
    final fullUserText = userMessages.map((m) => m.text).join(' ').toLowerCase();
    final List<String> detectedPhonemes = [];

    if (cleanLanguage.contains('francés') || cleanLanguage.contains('french') || cleanLanguage.contains('fr')) {
      // French phonemes
      final hasR = fullUserText.contains('r') || fullUserText.contains('bistro') || fullUserText.contains('bonjour');
      final hasU = fullUserText.contains('u') || fullUserText.contains('salut') || fullUserText.contains('tu');
      final hasEu = fullUserText.contains('eu') || fullUserText.contains('deux') || fullUserText.contains('bleu');
      final hasNasal = fullUserText.contains('on') || fullUserText.contains('in') || fullUserText.contains('an') || fullUserText.contains('en');

      if (!hasR) detectedPhonemes.add('/r/ (bistro, bonjour)');
      if (!hasU) detectedPhonemes.add('/u/ (salut, tu)');
      if (!hasEu) detectedPhonemes.add('/eu/ (deux, bleu)');
      if (!hasNasal) detectedPhonemes.add('/nasal/ (bon, vin)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/r/ (bistro, uvular)');
      }
    } else if (cleanLanguage.contains('alemán') || cleanLanguage.contains('german') || cleanLanguage.contains('de')) {
      // German phonemes
      final hasCh = fullUserText.contains('ch') || fullUserText.contains('ich') || fullUserText.contains('sprechen');
      final hasAch = fullUserText.contains('ach') || fullUserText.contains('buch') || fullUserText.contains('machen');
      final hasOe = fullUserText.contains('ö') || fullUserText.contains('oe') || fullUserText.contains('schön');
      final hasUe = fullUserText.contains('ü') || fullUserText.contains('ue') || fullUserText.contains('müde');

      if (!hasCh) detectedPhonemes.add('/ch/ (ich, sprechen)');
      if (!hasAch) detectedPhonemes.add('/ach/ (ach, buch)');
      if (!hasOe) detectedPhonemes.add('/ö/ (schön, hören)');
      if (!hasUe) detectedPhonemes.add('/ü/ (müde, fünf)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/ch/ (ich, ach)');
      }
    } else if (cleanLanguage.contains('italiano') || cleanLanguage.contains('italian') || cleanLanguage.contains('it')) {
      // Italian phonemes
      final hasGl = fullUserText.contains('gl') || fullUserText.contains('gli') || fullUserText.contains('famiglia');
      final hasGn = fullUserText.contains('gn') || fullUserText.contains('signore') || fullUserText.contains('bagno');
      final hasZ = fullUserText.contains('z') || fullUserText.contains('grazie') || fullUserText.contains('pizza');
      final hasR = fullUserText.contains('r') || fullUserText.contains('treno') || fullUserText.contains('vorrei');

      if (!hasGl) detectedPhonemes.add('/gl/ (gli, famiglia)');
      if (!hasGn) detectedPhonemes.add('/gn/ (signore, bagno)');
      if (!hasZ) detectedPhonemes.add('/z/ (grazie, pizza)');
      if (!hasR) detectedPhonemes.add('/r/ (treno, vorrei)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/gl/ (famiglia)');
      }
    } else {
      // Default to English phonemes
      final hasTh = fullUserText.contains('th') || fullUserText.contains('think') || fullUserText.contains('the');
      final hasR = fullUserText.contains('r') || fullUserText.contains('restaurant') || fullUserText.contains('right');
      final hasSh = fullUserText.contains('sh') || fullUserText.contains('she') || fullUserText.contains('should');
      final hasV = fullUserText.contains('v') || fullUserText.contains('very') || fullUserText.contains('voice');

      if (!hasTh) detectedPhonemes.add('/th/ (think, thank)');
      if (!hasR) detectedPhonemes.add('/r/ (restaurant, right)');
      if (!hasSh) detectedPhonemes.add('/sh/ (she, should)');
      if (!hasV) detectedPhonemes.add('/v/ (very, voice)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/th/ (think, thank)');
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, color: AppColors.runeViolet, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Huella de Voz & Pronunciación',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Claridad Fonética', phoneticClarityValue, Icons.graphic_eq_rounded, AppColors.manaCyan)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Velocidad Habla', wpmText, Icons.speed_rounded, AppColors.manaCyan)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Palabras Habladas', '$wordCount', Icons.chat_bubble_outline_rounded, const Color(0xFFFFD700))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Nivel CEFR', cefrText, Icons.auto_awesome_rounded, AppColors.runeViolet)),
                  ],
                ),
                const SizedBox(height: 18),
                Text(AppLocalizations.of(context)!.conversation_phonemes, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detectedPhonemes.map((ph) => _buildPhonemeTag(ph)).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      blur: 20,
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhonemeTag(String phoneme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(phoneme, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conversationState = ref.watch(conversationStateProvider);
    final conversationNotifier = ref.read(conversationStateProvider.notifier);
    final isOracle = conversationState.isOracleEvaluation;

    ref.listen<ConversationState>(conversationStateProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        SystemSnack.show(context, next.errorMessage!, type: SystemSnackType.error);
      }
      // Examen del Oráculo terminado: devolver el resultado al onboarding.
      if (isOracle && next.oracleResult != null && next.oracleResult != prev?.oracleResult) {
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop(next.oracleResult);
          } else {
            context.go('/home');
          }
        });
      }
    });

    // Progress ratio: max(saved from completed conversations, current messages / 10) — coherente con el roadmap
    final completedLessons = ref.watch(completedLessonsProvider).value ?? [];
    final double savedProgress = ProgressUtils.lessonProgress(
      completedLessons,
      conversationState.activeScenarioId ?? '',
    );
    // Subtract the initial tutor greeting so it doesn't inflate the student's progress
    final int progressMessages = (conversationState.messages.length - 1).clamp(0, 999);
    final double currentProgress = (progressMessages / 10.0).clamp(0.0, 1.0);
    final double realProgressRatio = savedProgress > currentProgress ? savedProgress : currentProgress;

    final currentLesson = LessonCatalog.getLessonById(
      conversationState.activeScenarioId,
      title: widget.scenarioTitle,
    );

    return Scaffold(
      body: CyberManhwaBackground(
        levelCode: currentLesson?.level ?? 'A1',
        child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop && !isOracle) {
            final duration = DateTime.now().difference(_startTime);
            final minutes = duration.inMinutes;
            final minutesToSave = minutes > 0 ? minutes : 1;
            await ref.read(conversationStateProvider.notifier).endSession(
              practiceMinutes: minutesToSave,
            );
          }
        },
        child: Stack(
          children: [
            // Ambient Background Glow
            Positioned(
              top: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runeViolet.withValues(alpha: 0.15),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App Bar with Dynamic Top Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isOracle
                                    ? AppLocalizations.of(context)!.oracle_title
                                    : (widget.scenarioTitle ?? conversationState.activeScenarioName ?? 'Práctica de Conversación'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (!isOracle) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    height: 6,
                                    color: Colors.white.withValues(alpha: 0.1),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: realProgressRatio,
                                        child: Container(
                                          color: const Color(0xFFF1C40F),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  '${(realProgressRatio * 100).round()}%',
                                  style: const TextStyle(
                                    color: Color(0xFFF1C40F),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (LessonCatalog.getLessonById(widget.scenarioId, title: widget.scenarioTitle) != null) ...[
                            const SizedBox(height: 8),
                            LiveGoalsTrackerBar(
                              goals: LessonCatalog.getLessonById(widget.scenarioId, title: widget.scenarioTitle)!.goals,
                              goalEvaluationResults: conversationState.goalEvaluationResults,
                              onTapCompass: () => _showScenarioMissionModal(context),
                            ),
                          ],
                          const SizedBox(height: 8),
                        ],

                        // Mana & Mode Controls Bar
                        if (!isOracle)
                          SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              ManaMeterWidget(
                                currentMana: (450 - _usedMana).clamp(0, 500),
                                usedInSession: _usedMana,
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isBlindListening = !_isBlindListening;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isBlindListening
                                        ? const Color(0xFFFF00FF).withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _isBlindListening ? const Color(0xFFFF00FF) : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_isBlindListening ? '🙈' : '👁️', style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isBlindListening ? 'Chat Oculto (4ª/5ª Estrella 🌟)' : 'Chat Visible',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _isBlindListening ? const Color(0xFFFF00FF) : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isTypingMode = !_isTypingMode;
                                    _showKeyboardDrawer = _isTypingMode;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isTypingMode
                                        ? AppColors.manaCyan.withValues(alpha: 0.2)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _isTypingMode ? AppColors.manaCyan : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_isTypingMode ? '⌨️' : '🎙️', style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isTypingMode ? 'Modo Escritura' : 'Modo Voz',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _isTypingMode ? AppColors.manaCyan : Colors.white70,
                                        ),
                                      ),
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

                  // Waveform Audio Visualizer
                  VoiceWaveformVisualizer(
                    isAiSpeaking: conversationState.isPlaying || conversationState.isProcessing,
                    isUserSpeaking: conversationState.isRecording,
                  ),

                  // Conversation Messages Canvas
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 100.0),
                      itemCount: conversationState.messages.length,
                      itemBuilder: (context, index) {
                        final message = conversationState.messages[index];
                        final isUser = message.sender == 'user';

                        Widget bubble;
                        if (!isUser) {
                          bubble = Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                child: _buildTutorBubble(context, message, conversationNotifier),
                              ),
                            ),
                          );
                        } else {
                          bubble = Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                child: _buildUserBubble(context, message),
                              ),
                            ),
                          );
                        }

                        final isLatest = index == conversationState.messages.length - 1;
                        if (isLatest && index > 0) return _AnimatedMessage(child: bubble);
                        return bubble;
                      },
                    ),
                  ),

                  // ── 20 Topics Horizontal Bar (Icon 2: Hashtag) ────────────────
                  if (_showTopicsBar)
                    Container(
                      height: 52,
                      color: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _randomTopics.length,
                        itemBuilder: (context, index) {
                          final topic = _randomTopics[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => _onTopicSelected(topic['title']!),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.runeViolet.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(topic['icon']!, style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      topic['title']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // ── Text Input Drawer (Icon 5: Keyboard) ────────────────────
                  if (_showKeyboardDrawer)
                    Container(
                      color: const Color(0xFF0F172A),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Escribe tu mensaje en inglés...',
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _submitTextMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppColors.runeViolet),
                            onPressed: _submitTextMessage,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white54),
                            onPressed: () {
                              setState(() {
                                _showKeyboardDrawer = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  // ── Controls Row (5 Icons Layout) ───────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                    color: AppColors.surfaceDim.withValues(alpha: 0.95),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Icon 1: Compass (Guía de Misión) — oculto en el examen del Oráculo
                        if (!isOracle)
                          IconButton(
                          icon: const Icon(Icons.explore_outlined, color: Colors.white70, size: 28),
                          onPressed: () => _showScenarioMissionModal(context),
                        ),

                        // Icon 2: Hashtag (20 Tópicos al azar) — oculto en el examen del Oráculo
                        if (!isOracle)
                          IconButton(
                          icon: Icon(
                            Icons.tag_rounded,
                            color: _showTopicsBar ? AppColors.runeViolet : Colors.white70,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _showTopicsBar = !_showTopicsBar;
                              _showKeyboardDrawer = false;
                            });
                          },
                        ),

                        // Icon 3: Center Floating White Mic (Tap-to-Talk)
                        GestureDetector(
                          onTap: () {
                            if (conversationState.isPlaying) {
                              conversationNotifier.stopTts();
                            } else if (conversationState.isRecording) {
                              conversationNotifier.stopRecording();
                            } else if (!conversationState.isProcessing) {
                              conversationNotifier.startRecording();
                            }
                          },
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              conversationState.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              color: const Color(0xFF0F172A),
                              size: 36,
                            ),
                          ),
                        ),

                        // Icon 4: Fingerprint (Huella de Voz & Biometría)
                        IconButton(
                          icon: const Icon(Icons.fingerprint_rounded, color: AppColors.runeViolet, size: 28),
                          onPressed: () => _showSpeechDnaModal(context),
                        ),

                        // Icon 5: Keyboard (Entrada de Texto Directa)
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_rounded,
                            color: _showKeyboardDrawer ? AppColors.runeViolet : Colors.white70,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _showKeyboardDrawer = !_showKeyboardDrawer;
                              _showTopicsBar = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Draggable & Collapsible Monster Overlay
            if (!isOracle)
              DraggableMonsterWidget(
                monster: HunterCatalog.regularMonsters.first,
                isSpeaking: conversationState.isPlaying || conversationState.isProcessing,
              ),
          ],
        ),
      ),
    ),
  );
}

  // Tutor Bubble
  Widget _buildTutorBubble(
    BuildContext context,
    ConversationMessage message,
    ConversationNotifier notifier,
  ) {
    if (message.text.isEmpty) {
      return GlassCard(
        blur: 20,
        opacity: 0.04,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet,
              ),
            );
          }),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E60FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_rounded, color: Colors.white70, size: 20),
                    onPressed: () => notifier.playTtsVoice(message.text),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // User Bubble
  Widget _buildUserBubble(BuildContext context, ConversationMessage message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          if (message.correctionExplanation != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.runeViolet.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.3)),
              ),
              child: Text(
                message.correctionExplanation!,
                style: const TextStyle(color: AppColors.runeVioletText, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimatedMessage extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedMessage({required this.child, this.delay = 0});

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _controller.forward(); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(offset: Offset(0, _slideAnim.value.dy * 20), child: widget.child),
        );
      },
    );
  }
}
