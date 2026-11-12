import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tutorsaas/core/utils/player_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorsaas/core/utils/error_tracker.dart';
import '../../../../core/platform/app_settings_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/help_phrase.dart';
import '../../domain/models/conversation_message.dart';
import '../../domain/models/ai_stream_exception.dart';
import '../../domain/models/conversation_state.dart';
import '../providers/conversation_providers.dart';
import '../providers/help_phrases_provider.dart';
import '../widgets/conversation_status_bar.dart';
import '../widgets/conversation_mic_button.dart';
import '../widgets/help_phrases_sheet.dart';
import '../widgets/mic_permission_card.dart';
import '../widgets/tts_settings_sheet.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../dashboard/data/models/lesson_catalog.dart';
import '../../../dashboard/domain/models/mission_progress_service.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../widgets/voice_waveform_visualizer.dart';
import '../widgets/conversation_scene_header.dart';
import '../widgets/corrections_codex_panel.dart';
import '../../../../core/widgets/draggable_monster_widget.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../dashboard/data/models/hunter_catalog.dart';
import '../../../economy/presentation/screens/dungeon_guardian_screen.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../economy/presentation/widgets/oracle_mana_bar.dart';
import '../../../corrections/presentation/providers/corrections_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../boss_exam/domain/models/boss_exam_outcome.dart';
import '../../../boss_exam/presentation/widgets/boss_exam_health_bar.dart';
import '../../../../core/analytics/analytics_taxonomy.dart';
import '../../../../core/services/retention_analytics.dart';
import '../../../../l10n/app_localizations.dart';

/// #322: ancho reservado al medidor de maná dentro de la fila de modos.
/// Estaba en 120 px y con escala de fuente 1.1 la línea `16380 / 17000` no
/// cabía: se salía del `SizedBox` y caía sobre los chips de modo.
const double _kConversationManaBarWidth = 150;

/// #322: margen izquierdo explícito de la fila de maná. Sustituye al
/// `Padding(horizontal: 8)` que envolvía al `SizedBox`.
const double _kConversationManaRowLeftInset = 8;

/// #322: separación explícita entre el medidor de maná y el primer chip de
/// modo (antes: padding 8 + `SizedBox(width: 8)` = 16). Evita que el texto del
/// maná invada el chip de "Chat Visible".
const double _kConversationManaBarGap = 16;

/// #322: reserva vertical que el monstruo flotante deja bajo el safe-area
/// superior para no montarse sobre la cabecera. Con la barra de objetivos
/// ya fuera de esta pantalla, lo que hay que despejar es:
/// - 8: padding superior del bloque de cabecera (`Padding` vertical 8).
/// - 40: fila del botón de voz (`IconButton` compacto: 48 - 8 de densidad).
/// - 178: `ConversationSceneHeader` (~176 documentados + 2 del borde del
///   `GlassCard`).
/// - 53: fila de maná + chips (`OracleManaBar` compacto:
///   13 + 4 + 5 + 4 + 13 + 2 + 12).
///   => 279, borde inferior de los chips de modo.
/// - 5: amplitud del flotado del pill (`sin(_floatController) * 5`).
/// - 12: holgura para que el borde del pill no roce los chips.
///   => 296.
///
/// La barra de estado NO se suma aquí: `DraggableMonsterWidget` ya añade
/// `MediaQuery.padding.top` en `_headerBottomY`, así que incluirla la contaría
/// dos veces. Es una reserva estática: si la cabecera gana filas, hay que
/// subirla.
const double _kConversationMonsterTopClearance = 296;

class ConversationScreen extends ConsumerStatefulWidget {
  final String? scenarioId;
  final String? scenarioTitle;

  /// Cuando es true, esta pantalla ejecuta la Evaluación del Oráculo
  /// (onboarding Paso 4): la IA conduce un examen oral conversacional
  /// reutilizando el mismo chat de voz y al final devuelve el resultado.
  final bool oracleMode;
  final String? oracleTargetLanguage;
  final String? oracleNativeLanguage;

  /// P-31 (#116): el examen es el "jefe de mazmorra" (promoción de nivel).
  /// Solo afecta a la capa visual y a la pantalla de resultado; el nivel lo
  /// decide el servidor.
  final bool oraclePromotion;

  const ConversationScreen({
    super.key,
    this.scenarioId,
    this.scenarioTitle,
    this.oracleMode = false,
    this.oracleTargetLanguage,
    this.oracleNativeLanguage,
    this.oraclePromotion = false,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  late final DateTime _startTime;
  ProviderContainer? _container;
  bool _showTopicsBar = false;
  bool _showKeyboardDrawer = false;
  bool _isBlindListening = false;
  bool _isTypingMode = false;
  final TextEditingController _textController = TextEditingController();
  // Auto-scroll de la conversación: baja hasta el último mensaje al avanzar.
  final ScrollController _chatScrollController = ScrollController();

  /// Cierre centralizado de la sesión: terminarla por CUALQUIER salida
  /// (pop, back, go, dispose) persiste el progreso una sola vez (idempotente).
  ///
  /// - [showSummary]: muestra `/summary` (solo en salida normal con interacción).
  /// - [navigate]: si es false, solo persiste (dispose) sin navegar.
  Future<void> _handleExit({
    required bool isOracle,
    bool showSummary = true,
    bool navigate = true,
  }) async {
    // Detener TTS siempre (antes del dispose, para no narrar en otra pantalla).
    ref.read(conversationStateProvider.notifier).stopTts(suppress: true);

    // Oráculo: solo pop con el resultado (no registra sesión normal).
    if (isOracle) return;

    // Solo hay registro/summary si hubo interacción real (al menos un turno).
    final latest = ref.read(conversationStateProvider);
    final hasUserTurns = latest.messages.any((m) => m.sender == 'user');
    if (!hasUserTurns) return;

    final duration = DateTime.now().difference(_startTime);
    final minutes = duration.inMinutes;
    final minutesToSave = minutes > 0 ? minutes : 1;
    // Idempotente: endSession solo persiste la primera vez (flag en el notifier).
    final sessionResult = await ref
        .read(conversationStateProvider.notifier)
        .endSession(practiceMinutes: minutesToSave);
    ref.read(sessionResultProvider.notifier).confirm(sessionResult);

    // Refresco del dashboard al salir (aqui `ref` sigue siendo valido; en
    // dispose() modificarlo lanzaba listeners ya destruidos).
    ref.read(dashboardRefreshProvider.notifier).state++;
    ref.invalidate(userProgressProvider);
    ref.invalidate(skillsRadarProvider);
    ref.invalidate(practiceHeatmapProvider);
    ref.invalidate(fluencyTrendsProvider);
    ref.invalidate(weeklyPracticeProvider);
    ref.invalidate(learnedVocabularyProvider);

    if (!navigate || !mounted) return;
    if (showSummary) {
      final router = GoRouter.of(context);
      try {
        router.push('/summary');
      } catch (e, st) {
        ErrorTracker.logSilent(
          'lib/features/conversation/presentation/screens/conversation_screen.dart:101',
          e,
          stackTrace: st,
        );
      }
    }
  }

  /// #332: los temas usan `IconData` de Material en lugar de emoji. Los
  /// literales viejos eran emoji que llegaban ya corruptos (UTF-8 leído
  /// como Latin-1) y, aun cuando llegaran bien, el emoji depende de la
  /// fuente del dispositivo.
  final List<({IconData icon, String title})> _randomTopics = const [
    (icon: Icons.memory_rounded, title: 'Tech & AI'),
    (icon: Icons.flight_takeoff_rounded, title: 'Travel & Culture'),
    (icon: Icons.restaurant_rounded, title: 'Food & Recipes'),
    (icon: Icons.music_video_rounded, title: 'Movies & Music'),
    (icon: Icons.sports_soccer_rounded, title: 'Sports & Fitness'),
    (icon: Icons.psychology_rounded, title: 'Philosophy & Science'),
    (icon: Icons.trending_up_rounded, title: 'Business & Careers'),
    (icon: Icons.menu_book_rounded, title: 'Books & Stories'),
    (icon: Icons.rocket_launch_rounded, title: 'Space Exploration'),
    (icon: Icons.palette_rounded, title: 'Art & Design'),
    (icon: Icons.sports_esports_rounded, title: 'Video Games'),
    (icon: Icons.pets_rounded, title: 'Pets & Animals'),
    (icon: Icons.eco_rounded, title: 'Environment & Nature'),
    (icon: Icons.self_improvement_rounded, title: 'Wellness & Mindfulness'),
    (icon: Icons.shopping_bag_rounded, title: 'Fashion & Trends'),
    (icon: Icons.public_rounded, title: 'Global Cultures'),
    (icon: Icons.beach_access_rounded, title: 'Vacation Destinations'),
    (icon: Icons.theaters_rounded, title: 'Pop Culture'),
    (icon: Icons.directions_car_rounded, title: 'Electric Mobility'),
    (icon: Icons.auto_awesome_rounded, title: 'Future Technology'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se captura con el arbol vivo: dentro de dispose() `ref` ya no es valido.
    _container ??= ProviderScope.containerOf(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Initialize session with optional scenario persistence
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.oracleMode) {
        ref
            .read(conversationStateProvider.notifier)
            .initOracleSession(
              targetLanguage: widget.oracleTargetLanguage,
              nativeLanguage: widget.oracleNativeLanguage,
              promotion: widget.oraclePromotion,
            );
      } else {
        // Guardián de la Mazmorra: sin maná no se puede entrar a una
        // lección/mazmorra. Espera a que el estado de maná cargue (hasta ~6s)
        // y, si no hay energía, bloquea el acceso en lugar de iniciar la sesión.
        Map<String, dynamic>? manaState;
        try {
          manaState = ref.read(manaStateProvider).value;
          if (manaState == null) {
            await ref
                .read(manaStateProvider.notifier)
                .load()
                .timeout(const Duration(seconds: 6));
            manaState = ref.read(manaStateProvider).value;
          }
        } catch (e, st) {
          ErrorTracker.logSilent(
            'lib/features/conversation/presentation/screens/conversation_screen.dart:151',
            e,
            stackTrace: st,
          );
        }
        if (manaState != null) {
          final isFree = manaState['is_free'] as bool? ?? true;
          final dailyRemaining =
              (manaState['daily_remaining'] as num?)?.toInt() ?? 0;
          final remaining = (manaState['remaining'] as num?)?.toInt() ?? 0;
          // Coste mínimo para al menos UN turno de mazmorra (ai_action_costs:
          // dungeon_turn = 12). Si el maná no alcanza ni para eso, se bloquea.
          const int minTurnCost = 12;
          final available = isFree ? dailyRemaining : remaining;
          final blocked = available < minTurnCost;
          if (blocked) {
            if (mounted) {
              context.pushReplacement('/dungeon-guardian');
            }
            return;
          }
        }
        ref
            .read(conversationStateProvider.notifier)
            .initSession(
              scenarioId: widget.scenarioId,
              scenarioTitle: widget.scenarioTitle,
            );
      }
    });
  }

  @override
  void dispose() {
    // Detener cualquier narración TTS en curso (p.ej. la del Oráculo) al salir
    // de la pantalla, para que no siga sonando en dashboard/otras páginas.
    // `suppress` además impide que un turno de la IA que termine después de la
    // salida dispare una nueva narración.
    try {
      _container?.read(conversationStateProvider.notifier).stopTts(suppress: true);
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/conversation/presentation/screens/conversation_screen.dart:184',
        e,
        stackTrace: st,
      );
    }
    // Red de seguridad: si la sesión NO se cerró por ninguna vía previa
    // (app muerta, kill de widget, salida por go), persiste el progreso aquí.
    // Idempotente: endSession solo guarda la primera vez (flag en el notifier).
    try {
      final notifier = _container?.read(conversationStateProvider.notifier);
      final isOracleEval =
          _container?.read(conversationStateProvider).isOracleEvaluation ?? false;
      if (!isOracleEval) {
        unawaited(notifier?.endSession() ?? Future<void>.value());
      }
    } catch (e, st) {
      ErrorTracker.logSilent(
        'lib/features/conversation/presentation/screens/conversation_screen.dart:194',
        e,
        stackTrace: st,
      );
    }
    _textController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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

  // ── P-34 (#119): experiencia de conversación ───────────────────────────────

  /// Analítica best-effort (nunca bloquea ni lanza).
  void _track(String event, {Map<String, dynamic>? properties}) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      unawaited(
        RetentionAnalytics.instance.track(
          user.id,
          event,
          properties: properties,
        ),
      );
    } catch (e) {
      debugPrint('Analytics ($event) no disponible: $e');
    }
  }

  /// P-34e: abre los ajustes de permisos de Android.
  Future<void> _openMicAppSettings() async {
    final l10n = AppLocalizations.of(context);
    final opened = await ref
        .read(appSettingsLauncherProvider)
        .openAppPermissionSettings();
    _track(AnalyticsEvent.micSettingsOpened, properties: {'opened': opened});
    if (!opened && mounted) {
      SystemSnack.show(
        context,
        l10n?.convo_mic_manual_hint ??
            'Abre Ajustes > Apps > Dungeon of English > Permisos > Micrófono.',
        type: SystemSnackType.error,
      );
    }
  }

  void _retryMicPermission() {
    ref.read(conversationStateProvider.notifier).startRecording();
  }

  /// P-34c: hoja con velocidad y voz del tutor (persistidas en user_settings).
  Future<void> _showTtsSettingsSheet() async {
    final voices = await ref
        .read(conversationStateProvider.notifier)
        .loadAvailableVoices();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final state = sheetRef.watch(conversationStateProvider);
            return TtsSettingsSheet(
              speed: state.ttsSpeed,
              voiceId: state.tutorVoiceId,
              voices: voices,
              title: l10n?.convo_tts_title ?? 'Voz del tutor',
              speedLabel: l10n?.convo_tts_speed ?? 'Velocidad',
              voiceLabel: l10n?.convo_tts_voice ?? 'Voz',
              defaultVoiceLabel:
                  l10n?.convo_tts_default_voice ?? 'Voz del sistema',
              noVoicesMessage:
                  l10n?.convo_tts_no_voices ??
                  'No se encontraron voces en inglés instaladas. Instala una en Ajustes de Android > Idiomas.',
              onSpeedChanged: (value) {
                unawaited(
                  sheetRef
                      .read(conversationStateProvider.notifier)
                      .setTtsSpeed(value),
                );
              },
              onVoiceChanged: (value) {
                unawaited(
                  sheetRef
                      .read(conversationStateProvider.notifier)
                      .setTutorVoice(value),
                );
              },
            );
          },
        );
      },
    );
  }

  /// P-34b: "Necesito ayuda" con hasta 3 frases reales del escenario.
  Future<void> _showHelpPhrases() async {
    final scenarioId = ref.read(conversationStateProvider).activeScenarioId;
    final l10n = AppLocalizations.of(context);
    unawaited(_trackHelpPhrasesShown(scenarioId));
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final asyncPhrases = sheetRef.watch(
              helpPhrasesProvider(scenarioId),
            );
            return HelpPhrasesSheet(
              title: l10n?.convo_help_title ?? 'Necesito ayuda',
              hint:
                  l10n?.convo_help_hint ??
                  'Toca una frase para enviarla como tu respuesta.',
              emptyMessage:
                  l10n?.convo_help_empty ??
                  'Este escenario todavía no tiene frases de ayuda. Escribe tu respuesta o cambia de tema.',
              phrases: asyncPhrases.value ?? const <HelpPhrase>[],
              loading: asyncPhrases.isLoading,
              onUsePhrase: (phrase) {
                Navigator.of(sheetContext).pop();
                _track(
                  AnalyticsEvent.helpPhraseUsed,
                  properties: {
                    'origin': phrase.origin.name,
                    'phrase_id': phrase.id,
                  },
                );
                ref
                    .read(conversationStateProvider.notifier)
                    .sendTextMessage(phrase.text);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _trackHelpPhrasesShown(String? scenarioId) async {
    try {
      final phrases = await ref.read(helpPhrasesProvider(scenarioId).future);
      _track(
        AnalyticsEvent.helpPhrasesShown,
        properties: {'count': phrases.length, 'scenario_id': scenarioId ?? ''},
      );
    } catch (e) {
      debugPrint('No se pudo registrar help_phrases_shown: $e');
    }
  }

  // ── Modal 1: Compass (Guía de Misión y Contexto) ───────────────────────────

  void _showScenarioMissionModal(BuildContext context) {
    final state = ref.read(conversationStateProvider);
    final lesson = LessonCatalog.getLessonById(
      widget.scenarioId,
      title: widget.scenarioTitle,
    );
    final userChatText = state.messages
        .where((m) => m.sender == 'user')
        .map((m) => m.text.toLowerCase())
        .join(' ');

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
                color: AppColors.surfaceDim,
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
                        const Icon(
                          Icons.explore_rounded,
                          color: AppColors.runeViolet,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)?.convo_mission_guide ??
                              'Guía de Misión y Contexto',
                          style: GoogleFonts.spaceGrotesk(
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
                            widget.scenarioTitle ??
                                lesson?.title ??
                                (AppLocalizations.of(
                                      context,
                                    )?.convo_practice_title ??
                                    'Práctica de Conversación'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context)?.convo_objective(
                                  lesson?.mainObjective ??
                                      'Practica tu conversación en el idioma seleccionado.',
                                ) ??
                                'Objetivo: ${lesson?.mainObjective ?? 'Practica tu conversación en el idioma seleccionado.'}',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.conversation_goals,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (lesson != null) ...[
                      ...lesson.goals.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final g = entry.value;
                        final isDone =
                            state.goalEvaluationResults[g.id] == true;
                        return _buildGoalItem(
                          '$idx. ${g.text}',
                          isDone,
                          hint: isDone ? null : g.examplePhrase,
                        );
                      }),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          AppLocalizations.of(context)?.convo_select_goals ??
                              'Selecciona una lección para ver las metas específicas.',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.conversation_key_phrases,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (lesson != null)
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: lesson.usefulPhrases.map((phraseItem) {
                            final isUsed = userChatText.contains(
                              phraseItem.phrase.toLowerCase().split(' ').first,
                            );
                            return _buildPhraseChip(
                              context,
                              phraseItem.phrase,
                              isUsed: isUsed,
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          AppLocalizations.of(context)?.convo_select_phrases ??
                              'Selecciona una lección para ver frases clave sugeridas.',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
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
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
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
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.white38,
                    size: 11,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      hint,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhraseChip(
    BuildContext context,
    String phrase, {
    bool isUsed = false,
  }) {
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
              color: isUsed
                  ? AppColors.manaCyan
                  : AppColors.runeViolet.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUsed) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.manaCyan,
                  size: 14,
                ),
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
    final wordCount = userMessages.fold(
      0,
      (sum, m) =>
          sum +
          m.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
    );

    // Calculate real WPM based on elapsed practice session time
    final elapsedMinutes = math.max(
      0.2,
      DateTime.now().difference(_startTime).inSeconds / 60.0,
    );
    final calculatedWpm = userMessages.isNotEmpty
        ? (wordCount / elapsedMinutes).round()
        : 0;
    final wpmText = userMessages.isNotEmpty ? '$calculatedWpm WPM' : '0 WPM';

    // Calculate real phonetic clarity score based on user participation
    final phoneticClarityValue = userMessages.isEmpty
        ? 'N/A'
        : '${math.min(99, math.max(72, 80 + math.min(18, (wordCount / 5).round())))}%';

    // Get real rank (F→SSS) and language from user profile
    final progressAsync = ref.read(userProgressProvider);
    final cefrCode = progressAsync.value?['level_code'] as String? ?? 'A1';
    final gameRank =
        (progressAsync.value?['game_rank'] as String?)?.isNotEmpty == true
        ? (progressAsync.value?['game_rank'] as String)
        : CefrRank.gameRankFromCefr(cefrCode);
    final cefrLevel =
        progressAsync.value?['level'] as String? ?? 'Principiante';
    final cefrText = '$gameRank ($cefrLevel)';
    final languageName =
        progressAsync.value?['language'] as String? ?? 'Inglés';
    final cleanLanguage = languageName.toLowerCase();

    // Extract real phonemes to practice based on words present in actual user text
    final fullUserText = userMessages
        .map((m) => m.text)
        .join(' ')
        .toLowerCase();
    final List<String> detectedPhonemes = [];

    if (cleanLanguage.contains('francés') ||
        cleanLanguage.contains('french') ||
        cleanLanguage.contains('fr')) {
      // French phonemes
      final hasR =
          fullUserText.contains('r') ||
          fullUserText.contains('bistro') ||
          fullUserText.contains('bonjour');
      final hasU =
          fullUserText.contains('u') ||
          fullUserText.contains('salut') ||
          fullUserText.contains('tu');
      final hasEu =
          fullUserText.contains('eu') ||
          fullUserText.contains('deux') ||
          fullUserText.contains('bleu');
      final hasNasal =
          fullUserText.contains('on') ||
          fullUserText.contains('in') ||
          fullUserText.contains('an') ||
          fullUserText.contains('en');

      if (!hasR) detectedPhonemes.add('/r/ (bistro, bonjour)');
      if (!hasU) detectedPhonemes.add('/u/ (salut, tu)');
      if (!hasEu) detectedPhonemes.add('/eu/ (deux, bleu)');
      if (!hasNasal) detectedPhonemes.add('/nasal/ (bon, vin)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/r/ (bistro, uvular)');
      }
    } else if (cleanLanguage.contains('alemán') ||
        cleanLanguage.contains('german') ||
        cleanLanguage.contains('de')) {
      // German phonemes
      final hasCh =
          fullUserText.contains('ch') ||
          fullUserText.contains('ich') ||
          fullUserText.contains('sprechen');
      final hasAch =
          fullUserText.contains('ach') ||
          fullUserText.contains('buch') ||
          fullUserText.contains('machen');
      final hasOe =
          fullUserText.contains('ö') ||
          fullUserText.contains('oe') ||
          fullUserText.contains('schön');
      final hasUe =
          fullUserText.contains('ü') ||
          fullUserText.contains('ue') ||
          fullUserText.contains('müde');

      if (!hasCh) detectedPhonemes.add('/ch/ (ich, sprechen)');
      if (!hasAch) detectedPhonemes.add('/ach/ (ach, buch)');
      if (!hasOe) detectedPhonemes.add('/ö/ (schön, hören)');
      if (!hasUe) detectedPhonemes.add('/ü/ (müde, fünf)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/ch/ (ich, ach)');
      }
    } else if (cleanLanguage.contains('italiano') ||
        cleanLanguage.contains('italian') ||
        cleanLanguage.contains('it')) {
      // Italian phonemes
      final hasGl =
          fullUserText.contains('gl') ||
          fullUserText.contains('gli') ||
          fullUserText.contains('famiglia');
      final hasGn =
          fullUserText.contains('gn') ||
          fullUserText.contains('signore') ||
          fullUserText.contains('bagno');
      final hasZ =
          fullUserText.contains('z') ||
          fullUserText.contains('grazie') ||
          fullUserText.contains('pizza');
      final hasR =
          fullUserText.contains('r') ||
          fullUserText.contains('treno') ||
          fullUserText.contains('vorrei');

      if (!hasGl) detectedPhonemes.add('/gl/ (gli, famiglia)');
      if (!hasGn) detectedPhonemes.add('/gn/ (signore, bagno)');
      if (!hasZ) detectedPhonemes.add('/z/ (grazie, pizza)');
      if (!hasR) detectedPhonemes.add('/r/ (treno, vorrei)');
      if (detectedPhonemes.isEmpty) {
        detectedPhonemes.add('/gl/ (famiglia)');
      }
    } else {
      // Default to English phonemes
      final hasTh =
          fullUserText.contains('th') ||
          fullUserText.contains('think') ||
          fullUserText.contains('the');
      final hasR =
          fullUserText.contains('r') ||
          fullUserText.contains('restaurant') ||
          fullUserText.contains('right');
      final hasSh =
          fullUserText.contains('sh') ||
          fullUserText.contains('she') ||
          fullUserText.contains('should');
      final hasV =
          fullUserText.contains('v') ||
          fullUserText.contains('very') ||
          fullUserText.contains('voice');

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
            color: AppColors.surfaceDim,
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
                    const Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.runeViolet,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.convo_voice_print ??
                            'Huella de Voz & Pronunciación',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        AppLocalizations.of(context)?.convo_phonetic_clarity ??
                            'Claridad Fonética',
                        phoneticClarityValue,
                        Icons.graphic_eq_rounded,
                        AppColors.manaCyan,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        AppLocalizations.of(context)?.convo_speech_speed ??
                            'Velocidad Habla',
                        wpmText,
                        Icons.speed_rounded,
                        AppColors.manaCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        AppLocalizations.of(context)?.convo_words_spoken ??
                            'Palabras Habladas',
                        '$wordCount',
                        Icons.chat_bubble_outline_rounded,
                        const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        AppLocalizations.of(context)?.convo_cefr_level ??
                            'Nivel CEFR',
                        cefrText,
                        Icons.auto_awesome_rounded,
                        AppColors.runeViolet,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context)!.conversation_phonemes,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detectedPhonemes
                      .map((ph) => _buildPhonemeTag(ph))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.2,
                  ),
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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
      child: Text(
        phoneme,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final conversationState = ref.watch(conversationStateProvider);
    final conversationNotifier = ref.read(conversationStateProvider.notifier);
    final convError = ref.watch(conversationErrorProvider);
    final isOracle = conversationState.isOracleEvaluation;
    // P-34f (#198): modo del micrófono persistido en `user_settings`.
    final holdToTalk = ref.watch(micModeHoldToTalkProvider);

    ref.listen<ConversationState>(conversationStateProvider, (prev, next) {
      // Maná agotado → abrir el Guardián de la Mazmorra (compra/espera/equipar)
      // en vez de un snack.
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        // P-26: se decide por el tipo de error, no por el texto del mensaje.
        final isManaDepleted =
            ref.read(conversationErrorProvider)?.kind == AiErrorKind.quota;
        if (isManaDepleted) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DungeonGuardianScreen(),
              ),
            );
          }
        } else {
          SystemSnack.show(
            context,
            next.errorMessage!,
            type: SystemSnackType.error,
          );
        }
      }
      // Examen del Oráculo terminado: mostrar botón para continuar
      // (ya no hacemos pop automático; el usuario decide cuándo salir).
      if (isOracle && next.oracleFinished && !(prev?.oracleFinished ?? false)) {
        // Nada automático: la UI muestra el botón "CONTINUAR".
      }
      // Auto-scroll: al llegar un nuevo mensaje (o crecer el streaming),
      // baja la conversación hasta el final para ver la última respuesta.
      final prevLen = prev?.messages.length ?? 0;
      final nextLen = next.messages.length;
      final lastChanged =
          nextLen > 0 &&
          prevLen == nextLen &&
          (prev?.messages.isNotEmpty ?? false) &&
          prev!.messages.last.text != next.messages.last.text &&
          next.messages.last.sender != 'user';
      if (prevLen < nextLen || lastChanged) {
        _scrollChatToBottom();
      }
    });

    // Scroll inicial al último mensaje (reanudar conversación / entrar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollChatToBottom();
    });

    // Progress ratio: objetivos completados (estado en memoria, persistido en
    // user_scenario_goals en el mismo turno) / objetivos totales del catálogo.
    // Fuente única de verdad: MissionProgressService (ver Docs/MissionProgressAudit).
    final currentLesson = LessonCatalog.getLessonById(
      conversationState.activeScenarioId,
      title: widget.scenarioTitle,
    );
    final double realProgressRatio = MissionProgressService.lessonProgress(
      completedGoals: MissionProgressService.countCompletedGoals(
        conversationState.goalEvaluationResults,
      ),
      totalGoals: currentLesson?.goals.length ?? 0,
    );

    // #339: contador del CODIGO en el boton inferior.
    final sessionCorrections = ref.watch(sessionCorrectionsProvider);

    return Scaffold(
      body: CyberManhwaBackground(
        levelCode: currentLesson?.level ?? 'A1',
        child: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) return;
            // Salida normal (back/gesto): cerrar sesión y mostrar resumen.
            await _handleExit(
              isOracle: isOracle,
              showSummary: true,
              navigate: true,
            );
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                    // #339/#322: con el teclado abierto, la cabecera epica se oculta
                    // para que el campo y la barra inferior no desborden.
                    if (!_showKeyboardDrawer) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          key: const Key('conversation-app-voice-settings'),
                          tooltip: l10n?.convo_tts_title ?? 'Voz del tutor',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: _showTtsSettingsSheet,
                        ),
                      ],
                    ),
                    // #339: cabecera de escena epica: el NPC como personaje.
                    ConversationSceneHeader(
                      title: isOracle
                          ? (l10n?.oracle_title ?? 'Oraculo')
                          : (widget.scenarioTitle ??
                                conversationState.activeScenarioName ??
                                'Practica de Conversacion'),
                      level: currentLesson?.level ?? 'A1',
                      npcName: (currentLesson?.assistantRole ?? 'TUTOR')
                          .toUpperCase(),
                      progress: realProgressRatio,
                      completedGoals: conversationState.goalEvaluationResults
                          .values
                          .where((v) => v)
                          .length,
                      totalGoals: currentLesson?.goals.length ?? 0,
                      onExit: () async {
                        await _handleExit(
                          isOracle: isOracle,
                          showSummary: true,
                          navigate: false,
                        );
                        if (context.mounted) {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        }
                      },
                    ),
                    ],
                          if (isOracle && widget.oraclePromotion) ...[
                            const SizedBox(height: 6),
                            BossExamHealthBar(
                              turns: conversationState.messages
                                  .where((m) => m.sender == 'user')
                                  .length,
                            ),
                          ],

                          // Mana & Mode Controls Bar
                          if (!isOracle)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  // #322: ancho y márgenes explícitos; dentro
                                  // de un scroll horizontal no hay ancho finito,
                                  // así que nunca `Expanded` aquí.
                                  const SizedBox(
                                    width: _kConversationManaRowLeftInset,
                                  ),
                                  SizedBox(
                                    width: _kConversationManaBarWidth,
                                    // P-26: el medidor muestra el coste del próximo
                                    // turno de esta sesión (mazmorra 12 / chat 8).
                                    child: OracleManaBar(
                                      showLabel: true,
                                      compact: true,
                                      costPerTurn:
                                          conversationState.activeScenarioId !=
                                              null
                                          ? 12
                                          : 8,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: _kConversationManaBarGap,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isBlindListening = !_isBlindListening;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isBlindListening
                                            ? AppColors.runeViolet.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _isBlindListening
                                              ? AppColors.runeViolet
                                              : Colors.white24,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isBlindListening
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 12,
                                            color: _isBlindListening
                                                ? AppColors.runeViolet
                                                : Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _isBlindListening
                                                ? (AppLocalizations.of(
                                                        context,
                                                      )?.convo_hidden_chat ??
                                                      'Chat Oculto (4ª/5ª Estrella)')
                                                : (AppLocalizations.of(
                                                        context,
                                                      )?.convo_visible_chat ??
                                                      'Chat Visible'),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _isBlindListening
                                                  ? AppColors.runeViolet
                                                  : Colors.white70,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isTypingMode
                                            ? AppColors.manaCyan.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _isTypingMode
                                              ? AppColors.manaCyan
                                              : Colors.white24,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isTypingMode
                                                ? Icons.keyboard_rounded
                                                : Icons.mic_rounded,
                                            size: 12,
                                            color: _isTypingMode
                                                ? AppColors.manaCyan
                                                : Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _isTypingMode
                                                ? (AppLocalizations.of(
                                                        context,
                                                      )?.convo_write_mode ??
                                                      'Modo Escritura')
                                                : (AppLocalizations.of(
                                                        context,
                                                      )?.convo_voice_mode ??
                                                      'Modo Voz'),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _isTypingMode
                                                  ? AppColors.manaCyan
                                                  : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // P-34b (#119): "Necesito ayuda" con frases
                                  // reales del escenario (solo fuera del Oráculo).
                                  InkWell(
                                    key: const Key('conversation-help'),
                                    onTap: _showHelpPhrases,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.royalGold.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.royalGold.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.lightbulb_outline_rounded,
                                            color: AppColors.royalGold,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n?.convo_help_title ??
                                                'Necesito ayuda',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.royalGold,
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
                      isAiSpeaking:
                          conversationState.isPlaying ||
                          conversationState.isProcessing,
                      isUserSpeaking: conversationState.isRecording,
                    ),

                    // Issue #76: el mundo recuerda el intento anterior.
                    Builder(
                      builder: (context) {
                        final scenarioId = conversationState.activeScenarioId;
                        if (scenarioId == null) return const SizedBox.shrink();
                        final progress = ref
                            .watch(scenarioProgressProvider(scenarioId))
                            .value;
                        if (progress == null) return const SizedBox.shrink();
                        final attempts =
                            (progress['attempts'] as num?)?.toInt() ?? 1;
                        final outcome = progress['last_outcome'] as String?;
                        if (attempts < 2 || outcome == 'success') {
                          return const SizedBox.shrink();
                        }
                        final l = AppLocalizations.of(context);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.history_rounded,
                                size: 14,
                                color: AppColors.guildAmber,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  outcome == 'partial'
                                      ? (l?.npc_remembers_partial ??
                                            'EL NPC RECUERDA QUE CASI LO LOGRAS')
                                      : (l?.npc_remembers_failure ??
                                            'EL NPC RECUERDA TU ÚLTIMO INTENTO'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: AppColors.guildAmber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Conversation Messages Canvas
                    Expanded(
                      child: ListView.builder(
                        controller: _chatScrollController,
                        padding: const EdgeInsets.fromLTRB(
                          20.0,
                          16.0,
                          20.0,
                          100.0,
                        ),
                        itemCount: conversationState.messages.length,
                        itemBuilder: (context, index) {
                          final message = conversationState.messages[index];
                          final isUser = message.sender == 'user';

                          Widget bubble;
                          if (!isUser) {
                            final bubbleContent = ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              child: _buildTutorBubble(
                                context,
                                message,
                                conversationNotifier,
                              ),
                            );
                            // El tutor (Oráculo) muestra su avatar junto a cada mensaje
                            // en todas las conversaciones (misiones y evaluación).
                            bubble = Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        'assets/images/avatars/oracle_01.webp',
                                        width: 42,
                                        height: 42,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: bubbleContent),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            final bubbleContent = ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.78,
                              ),
                              child: _buildUserBubble(context, message),
                            );
                            // El aventurero muestra su avatar (clase del jugador)
                            // junto a cada mensaje, espejo del avatar del tutor.
                            final heroProfile = ref
                                .watch(userProfileProvider)
                                .value;
                            final heroClass = playerClassOf(heroProfile);
                            bubble = Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: bubbleContent),
                                    const SizedBox(width: 10),
                                    RpgAvatar(
                                      avatarUrl: playerAvatarUrlOf(heroProfile),
                                      hunterClass: heroClass,
                                      initials: 'HÉROE',
                                      size: 42,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final isLatest =
                              index == conversationState.messages.length - 1;
                          if (isLatest && index > 0)
                            return _AnimatedMessage(child: bubble);
                          return bubble;
                        },
                      ),
                    ),

                    // ── 20 Topics Horizontal Bar (Icon 2: Hashtag) ────────────────
                    if (convError != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.errorRed.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.errorRed,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                convError.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (convError.canRetry)
                              TextButton(
                                onPressed: () =>
                                    conversationNotifier.retryLastTurn(),
                                child: const Text('Reintentar'),
                              ),
                            TextButton(
                              onPressed: () {
                                ref
                                        .read(
                                          conversationErrorProvider.notifier,
                                        )
                                        .state =
                                    null;
                                setState(() => _showKeyboardDrawer = true);
                              },
                              child: const Text('Escribir'),
                            ),
                          ],
                        ),
                      ),

                    if (_showTopicsBar)
                      Container(
                        height: 52,
                        color: AppColors.surfaceDim,
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
                                onTap: () => _onTopicSelected(topic.title),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.runeViolet.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.runeViolet.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        topic.icon,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        topic.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                        color: AppColors.surfaceDim,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )?.convo_input_hint ??
                                      'Escribe tu mensaje en inglés...',
                                  hintStyle: const TextStyle(
                                    color: Colors.white38,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.08,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
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
                              icon: const Icon(
                                Icons.send_rounded,
                                color: AppColors.runeViolet,
                              ),
                              onPressed: _submitTextMessage,
                            ),
                            IconButton(
                              tooltip: 'Cerrar',
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white54,
                              ),
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
                    // ── P-34e (#119): permiso de micrófono denegado ─────────
                    if (conversationState.micPermissionDenied)
                      MicPermissionCard(
                        title:
                            l10n?.convo_mic_denied_title ??
                            'Micrófono bloqueado',
                        body:
                            l10n?.convo_mic_denied_body ??
                            'Dungeon of English necesita el micrófono para escucharte. Actívalo en los ajustes de Android y vuelve a intentarlo.',
                        openSettingsLabel:
                            l10n?.convo_mic_open_settings ?? 'Abrir ajustes',
                        retryLabel: l10n?.convo_mic_retry ?? 'Reintentar',
                        onOpenSettings: _openMicAppSettings,
                        onRetry: _retryMicPermission,
                      ),

                    // ── P-34a/c/g (#119): estado, stop y velocidad del TTS ──
                    ConversationStatusBar(
                      isRecording: conversationState.isRecording,
                      isProcessing: conversationState.isProcessing,
                      isPlaying: conversationState.isPlaying,
                      ttsSpeed: conversationState.ttsSpeed,
                      listeningLabel:
                          l10n?.convo_status_listening ?? 'Escuchando…',
                      thinkingLabel: l10n?.convo_status_thinking ?? 'Pensando…',
                      speakingLabel:
                          l10n?.convo_status_speaking ??
                          'El tutor está hablando',
                      stopLabel: l10n?.convo_stop_tutor ?? 'Detener',
                      voiceSettingsTooltip:
                          l10n?.convo_tts_title ?? 'Voz del tutor',
                      onStopTts: conversationNotifier.pauseTts,
                      onOpenVoiceSettings: _showTtsSettingsSheet,
                      onSpeedChanged: conversationNotifier.setTtsSpeed,
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        16.0,
                        16.0,
                        24.0,
                      ),
                      color: AppColors.surfaceDim.withValues(alpha: 0.95),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Icon 1: Compass (Guía de Misión) — oculto en el examen del Oráculo
                          if (!isOracle)
                            IconButton(
                              tooltip: 'Objetivos de la misión',
                              icon: const Icon(
                                Icons.explore_outlined,
                                color: Colors.white70,
                                size: 28,
                              ),
                              onPressed: () =>
                                  _showScenarioMissionModal(context),
                            ),

                          // Icon 2: Hashtag (20 Tópicos al azar) — oculto en el examen del Oráculo
                          if (!isOracle)
                            IconButton(
                              tooltip: 'Temas sugeridos',
                              icon: Icon(
                                Icons.tag_rounded,
                                color: _showTopicsBar
                                    ? AppColors.runeViolet
                                    : Colors.white70,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showTopicsBar = !_showTopicsBar;
                                  _showKeyboardDrawer = false;
                                });
                              },
                            ),

                          // #339: acceso al CODIGO DE ERRORES de la sesion.
                          IconButton(
                            tooltip: 'Codigo de errores',
                            key: const Key('conversation-codex-button'),
                            icon: Icon(
                              Icons.auto_stories_rounded,
                              color: sessionCorrections.isEmpty
                                  ? Colors.white70
                                  : AppColors.royalGold,
                              size: 28,
                            ),
                            onPressed: () => _showCorrectionsCodex(context),
                          ),

                          // Icon 3: Mic (Tap-to-Talk) — o botón CONTINUAR al terminar el Oráculo
                          if (isOracle && conversationState.oracleFinished)
                            GestureDetector(
                              onTap: () async {
                                // Cierra el TTS/sesión Oráculo (no registra normal).
                                await _handleExit(
                                  isOracle: true,
                                  showSummary: false,
                                  navigate: false,
                                );
                                final navigator = Navigator.of(context);
                                final rawResult =
                                    conversationState.oracleResult;
                                // P-31 (#116): en el jefe de mazmorra el
                                // resultado se explica en su propia pantalla
                                // (rúbrica, motivo y reintento).
                                if (rawResult != null &&
                                    rawResult['mode'] == 'boss') {
                                  final outcome = BossExamOutcome.fromMap(
                                    rawResult,
                                  );
                                  if (context.mounted) {
                                    context.push(
                                      '/boss-result',
                                      extra: outcome,
                                    );
                                  }
                                  return;
                                }
                                if (navigator.canPop()) {
                                  navigator.pop(rawResult);
                                } else {
                                  context.go('/home');
                                }
                              },
                              child: Container(
                                width: 120,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: AppColors.royalGold,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.royalGold
                                          .withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: AppColors.voidBg,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )?.convo_continue ??
                                          'CONTINUAR',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.voidBg,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // P-34f (#198): tap-to-toggle (por defecto) o
                            // mantener para hablar, según `user_settings`.
                            ConversationMicButton(
                              holdToTalk: holdToTalk,
                              isRecording: conversationState.isRecording,
                              isProcessing: conversationState.isProcessing,
                              isPlaying: conversationState.isPlaying,
                              semanticsLabel:
                                  l10n?.convo_mic_label ?? 'Micrófono',
                              // UX-13 (#252): el hint dice con palabras qué
                              // hace el botón, porque el gesto no se deduce.
                              semanticsHint: holdToTalk
                                  ? (l10n?.convo_mic_hint_hold ??
                                        'Mantén pulsado para grabar y toca dos veces para detener y enviar.')
                                  : (l10n?.convo_mic_hint_toggle ??
                                        'Toca dos veces para empezar o detener la grabación.'),
                              onTap: () {
                                if (conversationState.isPlaying) {
                                  conversationNotifier.stopTts();
                                } else if (conversationState.isRecording) {
                                  conversationNotifier.stopRecording();
                                } else if (!conversationState.isProcessing) {
                                  conversationNotifier.startRecording();
                                }
                              },
                              onHoldStart: () => unawaited(
                                conversationNotifier.startHoldRecording(),
                              ),
                              onHoldEnd: (heldFor) => unawaited(
                                conversationNotifier.endHoldRecording(heldFor),
                              ),
                              onHoldTooShort: (heldFor) => unawaited(
                                conversationNotifier.discardHoldRecording(
                                  tooShort: true,
                                  heldFor: heldFor,
                                  message: l10n?.convo_hold_too_short,
                                ),
                              ),
                              onHoldCancel: () => unawaited(
                                conversationNotifier.discardHoldRecording(
                                  tooShort: false,
                                ),
                              ),
                            ),

                          // Icon 4: Fingerprint (Huella de Voz & Biometría)
                          IconButton(
                            tooltip: 'Huella de voz',
                            icon: const Icon(
                              Icons.fingerprint_rounded,
                              color: AppColors.runeViolet,
                              size: 28,
                            ),
                            onPressed: () => _showSpeechDnaModal(context),
                          ),

                          // P-34b (#119): "Necesito ayuda" vive en la barra de
                          // modos (con scroll), para no saturar esta fila.

                          // Icon 5: Keyboard (Entrada de Texto Directa)
                          IconButton(
                            icon: Icon(
                              Icons.keyboard_rounded,
                              color: _showKeyboardDrawer
                                  ? AppColors.runeViolet
                                  : Colors.white70,
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

              // Overlay: el Oráculo está evaluando la conversación
              if (isOracle && conversationState.oracleEvaluating)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColors.voidBg.withValues(alpha: 0.82),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              color: AppColors.royalGold,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )?.convo_oracle_evaluating ??
                                'EL ORÁCULO ESTÁ EVALUANDO TU CONVERSACIÓN...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(
                                  context,
                                )?.convo_analyzing_level ??
                                'Analizando tu nivel de comunicación...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Floating Draggable & Collapsible Monster Overlay
              if (!isOracle)
                DraggableMonsterWidget(
                  monster: HunterCatalog.regularMonsters.first,
                  // #322: arranca por debajo de la cabecera y el arrastre no
                  // puede volver a meterlo en ella.
                  headerClearance: _kConversationMonsterTopClearance,
                  isSpeaking:
                      conversationState.isPlaying ||
                      conversationState.isProcessing,
                  avatarAsset: 'assets/images/avatars/oracle_01.webp',
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
          // #329: la pantalla usa una sola superficie. La burbuja del tutor
          // deja el azul plano #1E60FF y pasa a superficie con borde cian,
          // radio 4 en las cuatro esquinas. Se sigue distinguiendo de la del
          // alumno: borde cian (la del alumno lo lleva blanco al 8 %), texto
          // claro y va a la izquierda junto al avatar del tutor.
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.manaCyan.withValues(alpha: 0.25),
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
                    icon: const Icon(
                      Icons.replay_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
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

  /// #339: abre el CODIGO DE ERRORES con las correcciones de la sesion.
  Future<void> _showCorrectionsCodex(BuildContext context) async {
    final corrections = ref.read(sessionCorrectionsProvider);
    final level = ref.read(correctionLevelProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.62,
        maxChildSize: 0.92,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: 24),
          child: CorrectionsCodexPanel(corrections: corrections, level: level),
        ),
      ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMessage extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedMessage({required this.child}) : delay = 0;

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value.dy * 20),
            child: widget.child,
          ),
        );
      },
    );
  }
}
