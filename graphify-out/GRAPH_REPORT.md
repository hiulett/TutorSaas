# Graph Report - TutorSaas  (2026-07-24)

## Corpus Check
- 169 files · ~1,569,371 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1292 nodes · 1833 edges · 93 communities (87 shown, 6 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- System Architecture & Business Context
- Implementation Plan & Repair Strategy
- Voice Chat Architecture & Latency
- Database Schema & Tables
- Database Repair & CEFR Seeding
- Frontend Routing & Lesson Repair
- Data Model & UI Corrections
- Internationalization & Onboarding
- Web Admin Tooling & Linting
- Dashboard UI & Fallback Repairs
- Flutter App Core Setup
- Graphify Knowledge Graph Rules
- Graphify Workflow Specification
- iOS Launch Assets
- Web Admin App Component
- Web Admin GlassCard Component
- Web Admin Navbar Component
- Web Admin Sidebar Component
- Web Admin User Detail Modal
- Web Admin Overview Page
- Web Admin AI Settings
- Web Admin CEFR Manager
- Web Admin Lesson Manager
- Web Admin Subscriptions Manager
- Web Admin Biometrics Manager
- conversation_state.dart
- placement_result.dart
- AppDelegate
- conversation_message.dart
- profile_edit_screen.dart
- conversation_repository.dart
- ../../../../core/theme/app_colors.dart
- dashboard_providers.dart
- paywall_screen.dart
- router.dart
- _OnboardingScreenState
- onboarding_repository_impl.dart
- package:flutter/material.dart
- voice_room_screen.dart
- package:google_fonts/google_fonts.dart
- session_summary_screen.dart
- chat_rooms_repository_impl.dart
- api_constants.dart
- currentUserProvider
- chat_rooms_repository.dart
- manifest.json
- main.dart
- subscription_providers.dart
- build
- ../../../auth/presentation/providers/auth_providers.dart
- ConsumerState
- ConsumerWidget
- chat_rooms_screen.dart
- build
- subscription_repository_impl.dart
- _MicPulseButtonState
- Route /home
- subscription_repository.dart
- supabase
- @JsonSerializable
- MainActivity
- @JsonKey
- StatelessWidget
- package:flutter_riverpod/flutter_riverpod.dart
- ai_pick_hero_card.dart
- package:flutter/foundation.dart
- StatelessWidget
- currentUserProvider
- @freezed
- draggable_monster_widget.dart
- level_exam_screen.dart
- status_window_modal.dart
- audio_sfx_service.dart
- Route /home
- user_settings.dart
- package:google_fonts/google_fonts.dart
- main.dart
- voice_waveform_visualizer.dart
- State
- StateNotifier
- chat_rooms_repository.dart
- ai_pick_hero_card.dart
- ../../../auth/presentation/providers/auth_providers.dart
- ConsumerStatefulWidget
- subscription_repository.dart
- overflow_test.dart
- app.dart
- _MicPulseButtonState

## God Nodes (most connected - your core abstractions)
1. `currentUserProvider` - 27 edges
2. `build` - 19 edges
3. `Plan de Implementación — Corrección de Inconsistencias` - 14 edges
4. `react` - 13 edges
5. `DashboardScreen` - 11 edges
6. `conversationStateProvider` - 10 edges
7. `userProgressProvider` - 9 edges
8. `build` - 9 edges
9. `sfxEnabledProvider` - 8 edges
10. `chatRoomsRepositoryProvider` - 8 edges

## Surprising Connections (you probably didn't know these)
- `build` --references--> `currentUserProvider`  [EXTRACTED]
  lib/features/onboarding/presentation/screens/welcome_screen.dart → lib/features/auth/presentation/providers/auth_providers.dart
- `_buildNotificationTiles` --references--> `sfxEnabledProvider`  [EXTRACTED]
  lib/features/dashboard/presentation/screens/settings_screen.dart → lib/core/services/audio_sfx_service.dart
- `_SettingsScreenState` --references--> `sfxEnabledProvider`  [EXTRACTED]
  lib/features/dashboard/presentation/screens/settings_screen.dart → lib/core/services/audio_sfx_service.dart
- `_SettingsScreenState` --references--> `authRepositoryProvider`  [EXTRACTED]
  lib/features/dashboard/presentation/screens/settings_screen.dart → lib/features/auth/presentation/providers/auth_providers.dart
- `_buildCurrentView` --references--> `authRepositoryProvider`  [EXTRACTED]
  lib/features/onboarding/presentation/screens/welcome_screen.dart → lib/features/auth/presentation/providers/auth_providers.dart

## Import Cycles
- None detected.

## Communities (93 total, 6 thin omitted)

### Community 0 - "System Architecture & Business Context"
Cohesion: 0.07
Nodes (27): 10. SEGURIDAD Y CONFIGURACIÓN, 11. MATRIZ DE RIESGOS TÉCNICOS Y DEUDA TÉCNICA, 12. GUÍA PARA FUTURAS IA Y PROMPT CONTEXT EXPORT, 1. RESUMEN EJECUTIVO, 1. `users`, 2. DESCRIPCIÓN GENERAL DEL NEGOCIO, 2. `user_language_profiles`, 3. `conversations` (+19 more)

### Community 1 - "Implementation Plan & Repair Strategy"
Cohesion: 0.05
Nodes (39): Convenciones, FASE 1: Reparación de Base de Datos (Ejecutar primero), FASE 2: Reparación de Código Frontend (Crítico), FASE 3: Reparación del Motor de Recomendaciones, FASE 4: Correcciones del Dashboard (Fallback y UI), FASE 5: Correcciones del Modelo de Datos, FASE 6: Correcciones de Internacionalización, FASE 7: Corrección de Nivel de Corrección (+31 more)

### Community 2 - "Voice Chat Architecture & Latency"
Cohesion: 0.18
Nodes (10): 1. Causa Raíz del Corte de Audio en la Implementación Anterior, 2. Nueva Arquitectura: Grabación Raw + Groq Cloud Whisper STT, 3. Alternativas STT Evaluadas, 4. Configuración de Llaves de API, A. Groq Cloud API (Implementación Actual), Arquitectura de Voz y Alternativas STT para TutorSaas, B. Self-Hosted `faster-whisper` (100% Gratuito), C. On-Device Whisper (`whisper_flutter_plus` / `sherpa_onnx`) (+2 more)

### Community 3 - "Database Schema & Tables"
Cohesion: 0.27
Nodes (9): isRegisteringProvider, build, _buildCurrentView, createState, _redirectUser, _viewMode, WelcomeScreen, _WelcomeScreenState (+1 more)

### Community 4 - "Database Repair & CEFR Seeding"
Cohesion: 0.17
Nodes (11): dart:isolate, double get, Duration, duration, LatencyBenchmark, LatencyMetric, milliseconds, runPipelineBenchmark (+3 more)

### Community 5 - "Frontend Routing & Lesson Repair"
Cohesion: 0.08
Nodes (25): ../../../../core/services/audio_sfx_service.dart, _buildCefrLevelTile, _buildCorrectionLevelTile, _buildCorrectionStyleTile, _buildDailyGoalTile, _buildLanguageTile, _buildOption, _buildTutorPersonalityTile (+17 more)

### Community 6 - "Data Model & UI Corrections"
Cohesion: 0.06
Nodes (33): Animation, build, _buildBottomNav, _buildHeader, _buildOptionGrid, _buildStepGoal, _buildStepObstacle, _buildStepQuiz (+25 more)

### Community 7 - "Internationalization & Onboarding"
Cohesion: 0.05
Nodes (39): build, _buildCorrectionStylePage, _buildGoalPage, _buildInterestsPage, _buildLevelPage, _buildNativeLanguageAndCountryPage, _buildPaywallScreenPage, _buildPlacementObstaclePage (+31 more)

### Community 8 - "Web Admin Tooling & Linting"
Cohesion: 0.50
Nodes (3): Expanding the Oxlint configuration, React Compiler, React + Vite

### Community 9 - "Dashboard UI & Fallback Repairs"
Cohesion: 0.06
Nodes (34): assistantRole, catalog, category, copyWith, description, difficulty, dynamicCatalogCache, examplePhrase (+26 more)

### Community 14 - "Web Admin App Component"
Cohesion: 0.09
Nodes (24): oxc, react, warn, plugins, rules, react/only-export-components, react/rules-of-hooks, $schema (+16 more)

### Community 15 - "Web Admin GlassCard Component"
Cohesion: 0.06
Nodes (35): ../../data/repositories/conversation_repository_impl.dart, FlutterTts, activeConversationIdProvider, activeScenarioIdProvider, _asyncSaveAndAnalyzeSession, _audioRecorder, conversationDioProvider, _conversationId (+27 more)

### Community 16 - "Web Admin Navbar Component"
Cohesion: 0.11
Nodes (17): ../../domain/repositories/dashboard_repository.dart, getCorrectionLevel, _getLanguageCodeFromId, getLearnedVocabulary, getRecommendedLessons, getUserAchievements, getUserProgress, getUserSettings (+9 more)

### Community 17 - "Web Admin Sidebar Component"
Cohesion: 0.07
Nodes (29): lucide-react, oxlint, react, react-dom, @supabase/supabase-js, @types/react, @types/react-dom, vite (+21 more)

### Community 18 - "Web Admin User Detail Modal"
Cohesion: 0.07
Nodes (32): ../../../../core/widgets/draggable_monster_widget.dart, ../../domain/models/conversation_state.dart, conversationStateProvider, _buildGoalItem, _buildMetricCard, _buildPhonemeTag, _buildPhraseChip, _buildTutorBubble (+24 more)

### Community 19 - "Web Admin Overview Page"
Cohesion: 0.08
Nodes (25): accentColor, _buildNavItem, _controller, createState, description, dispose, icon, initState (+17 more)

### Community 20 - "Web Admin AI Settings"
Cohesion: 0.08
Nodes (23): IconData, int?, accentGreen, activeUserLevel, build, completedLessonsHistory, createState, didUpdateWidget (+15 more)

### Community 21 - "Web Admin CEFR Manager"
Cohesion: 0.09
Nodes (22): dart:convert, Dio, ../../domain/repositories/conversation_repository.dart, analyzeAndSaveSessionProgress, _client, _dio, evaluateGoals, evaluation (+14 more)

### Community 22 - "Web Admin Lesson Manager"
Cohesion: 0.10
Nodes (20): Achievement, bool get, description, emoji, hashCode, id, isUnlocked, operator (+12 more)

### Community 23 - "Web Admin Subscriptions Manager"
Cohesion: 0.10
Nodes (21): hashCode, levelCode, levelName, operator, _privateConstructorUsedError, streak, targetLanguageCode, targetLanguageEmoji (+13 more)

### Community 24 - "Web Admin Biometrics Manager"
Cohesion: 0.09
Nodes (21): AppColors, background, errorRed, errorRedDim, onBackground, onSurface, onSurfaceVariant, outline (+13 more)

### Community 25 - "conversation_state.dart"
Cohesion: 0.11
Nodes (17): _, activeScenarioId, activeScenarioName, currentTranscribingText, errorMessage, goalEvaluationResults, hashCode, isPlaying (+9 more)

### Community 26 - "placement_result.dart"
Cohesion: 0.10
Nodes (20): cefrLevel, completedAt, hashCode, learningGoal, levelDescription, levelName, mainDifficulty, operator (+12 more)

### Community 27 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate (+6 more)

### Community 28 - "conversation_message.dart"
Cohesion: 0.12
Nodes (15): audioUrl, correctionExplanation, hashCode, operator, originalText, _privateConstructorUsedError, sender, text (+7 more)

### Community 29 - "profile_edit_screen.dart"
Cohesion: 0.13
Nodes (14): FormState, _avatarPresets, _bioController, createState, _currentAvatarUrl, dispose, _formKey, initState (+6 more)

### Community 30 - "conversation_repository.dart"
Cohesion: 0.12
Nodes (16): ../../domain/models/conversation_message.dart, ConversationRepositoryImpl, analyzeAndSaveSessionProgress, ConversationRepository, evaluateGoals, generateTtsAudio, getOrCreateConversation, getTutorResponseStream (+8 more)

### Community 31 - "../../../../core/theme/app_colors.dart"
Cohesion: 0.17
Nodes (11): Border?, EdgeInsetsGeometry?, blur, border, borderRadius, build, child, opacity (+3 more)

### Community 32 - "dashboard_providers.dart"
Cohesion: 0.12
Nodes (15): ../../data/repositories/dashboard_repository_impl.dart, ../../domain/models/user_settings.dart, correctionLevelProvider, _loadSettings, practiceHeatmapProvider, read, repo, _repository (+7 more)

### Community 33 - "paywall_screen.dart"
Cohesion: 0.22
Nodes (8): ../../../../core/widgets/cyber_manhwa_background.dart, createState, _features, initState, _isPurchasing, _plans, _selectedPlan, ../providers/subscription_providers.dart

### Community 34 - "router.dart"
Cohesion: 0.13
Nodes (14): ../features/chat_rooms/presentation/screens/chat_rooms_screen.dart, ../features/chat_rooms/presentation/screens/voice_room_screen.dart, ../features/conversation/presentation/screens/conversation_screen.dart, ../features/conversation/presentation/screens/level_exam_screen.dart, ../features/dashboard/presentation/screens/dashboard_screen.dart, ../features/dashboard/presentation/screens/profile_edit_screen.dart, ../features/dashboard/presentation/screens/profile_screen.dart, ../features/dashboard/presentation/screens/session_summary_screen.dart (+6 more)

### Community 35 - "_OnboardingScreenState"
Cohesion: 0.17
Nodes (11): ../../../../core/theme/app_colors.dart, ../../../../core/widgets/glass_card.dart, build, createState, _quests, streakDays, activeLeague, build (+3 more)

### Community 36 - "onboarding_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/onboarding_repository.dart, _getCefrName, _getCefrOrder, _getLanguageEmoji, _getLanguageName, _getNativeLanguageName, saveOnboardingData, _supabaseClient

### Community 37 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (12): Color, getDiffSpans, TextDiffUtils, build, error, build, currentMana, ManaMeterWidget (+4 more)

### Community 38 - "voice_room_screen.dart"
Cohesion: 0.11
Nodes (17): ../../../../core/widgets/mana_meter_widget.dart, _aiTips, _buildAiModeratorCard, _chatScrollController, createState, _currentTipIndex, dispose, _isHandRaised (+9 more)

### Community 39 - "package:google_fonts/google_fonts.dart"
Cohesion: 0.06
Nodes (37): CustomPainter, AnimatedMagicCirclePainter, bgMode, build, _cameraZoomController, child, color, createState (+29 more)

### Community 40 - "session_summary_screen.dart"
Cohesion: 0.17
Nodes (11): ../../../conversation/presentation/providers/conversation_providers.dart, _buildNavItem, _showAllVocabularyDialog, _buildSummaryCorrectionCard, color, paint, progress, shouldRepaint (+3 more)

### Community 41 - "chat_rooms_repository_impl.dart"
Cohesion: 0.14
Nodes (13): ai_pick_hero_card.dart, lesson_preview_sheet.dart, _calculateMatchScore, _categories, _cefrLevels, createState, dispose, _getIconData (+5 more)

### Community 42 - "api_constants.dart"
Cohesion: 0.18
Nodes (10): ApiConstants, deepseekApiKey, deepseekBaseUrl, groqApiKey, groqSttUrl, sttUrl, supabaseAnonKey, supabaseUrl (+2 more)

### Community 43 - "currentUserProvider"
Cohesion: 0.22
Nodes (10): ../../data/repositories/chat_rooms_repository_impl.dart, ../../domain/repositories/chat_rooms_repository.dart, chatRoomMessagesProvider, chatRoomParticipantsProvider, client, read, build, initState (+2 more)

### Community 44 - "chat_rooms_repository.dart"
Cohesion: 0.12
Nodes (15): DashboardRepositoryImpl, DashboardRepository, getCorrectionLevel, getLearnedVocabulary, getRecommendedLessons, getUserAchievements, getUserProgress, getUserSettings (+7 more)

### Community 45 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 46 - "main.dart"
Cohesion: 0.20
Nodes (9): dart:io, authStateChanges, getCurrentUser, signInAnonymously, signInWithApple, signInWithGoogle, signOut, _supabaseClient (+1 more)

### Community 47 - "subscription_providers.dart"
Cohesion: 0.22
Nodes (8): ../../data/repositories/subscription_repository_impl.dart, _checkStatus, repo, _repository, setPremium, supabaseClient, user, _userId

### Community 48 - "build"
Cohesion: 0.21
Nodes (12): ConsumerWidget, fluencyTrendsProvider, learnedVocabularyProvider, skillsRadarProvider, weeklyPracticeProvider, _FluencyLatencyChart, _ProgressTabView, _SkillsRadarChart (+4 more)

### Community 49 - "../../../auth/presentation/providers/auth_providers.dart"
Cohesion: 0.20
Nodes (9): ../../../dashboard/presentation/providers/dashboard_providers.dart, build, createState, _currentIndex, _isFlipped, _reviewedCount, show, SrsFlashcardModal (+1 more)

### Community 50 - "ConsumerState"
Cohesion: 0.20
Nodes (9): AuthRepositoryImpl, AuthRepository, authStateChanges, getCurrentUser, signInAnonymously, signInWithApple, signInWithGoogle, signOut (+1 more)

### Community 51 - "ConsumerWidget"
Cohesion: 0.18
Nodes (10): dart:async, claimSpeakerSlot, createRoom, getRooms, joinRoom, leaveRoom, sendChatMessage, streamMessages (+2 more)

### Community 52 - "chat_rooms_screen.dart"
Cohesion: 0.20
Nodes (11): dart:ui, chatRoomsListProvider, build, _categories, ChatRoomsScreen, _ChatRoomsScreenState, createState, _getCategoryIcon (+3 more)

### Community 53 - "build"
Cohesion: 0.18
Nodes (19): authRepositoryProvider, ConversationScreen, _ConversationScreenState, recommendedLessonsProvider, userAchievementsProvider, userFluencyStatsProvider, userProfileProvider, userProgressProvider (+11 more)

### Community 54 - "subscription_repository_impl.dart"
Cohesion: 0.16
Nodes (12): ../../domain/repositories/subscription_repository.dart, _client, PlacementRepository, PlacementRepositoryImpl, savePlacementResult, getSubscriptionPlans, isUserPremium, purchasePackage (+4 more)

### Community 55 - "_MicPulseButtonState"
Cohesion: 0.22
Nodes (8): accentGreen, build, _buildLessonCard, _buildMiniMetric, completedLessons, createState, _isExpanded, static const Color

### Community 56 - "Route /home"
Cohesion: 0.22
Nodes (8): ../../../dashboard/data/models/lesson_catalog.dart, accentGreen, build, goalEvaluationResults, goals, onTapCompass, List, Map

### Community 57 - "subscription_repository.dart"
Cohesion: 0.22
Nodes (8): AuthState, ../../data/repositories/auth_repository_impl.dart, ../../domain/repositories/auth_repository.dart, authStateAsync, authStateProvider, client, maybeWhen, repo

### Community 58 - "supabase"
Cohesion: 0.29
Nodes (6): mcp, supabase, $schema, enabled, type, url

### Community 59 - "@JsonSerializable"
Cohesion: 0.40
Nodes (5): @JsonSerializable, _, _, _, _

### Community 67 - "StatelessWidget"
Cohesion: 0.17
Nodes (11): ../../data/models/lesson_catalog.dart, LessonData, build, lesson, LessonPreviewSheet, show, build, _getIconData (+3 more)

### Community 68 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.40
Nodes (4): package:flutter_riverpod/flutter_riverpod.dart, package:tutorsaas/app/app.dart, package:tutorsaas/features/auth/presentation/providers/auth_providers.dart, main

### Community 69 - "ai_pick_hero_card.dart"
Cohesion: 0.22
Nodes (18): ConsumerState, currentUserProvider, supabaseClientProvider, dashboardRepositoryProvider, userSettingsProvider, build, _pickImage, _ProfileEditScreenState (+10 more)

### Community 70 - "package:flutter/foundation.dart"
Cohesion: 0.25
Nodes (7): ErrorTracker, init, _initialized, logError, logEvent, package:flutter/foundation.dart, static bool

### Community 71 - "StatelessWidget"
Cohesion: 0.22
Nodes (9): ConfigurationErrorWidget, GlassCard, LiveGoalsTrackerBar, LessonCard, _SectionHeader, LeagueLeaderboardWidget, _RoadmapNodeTile, NextRecommendedLessonHero (+1 more)

### Community 72 - "currentUserProvider"
Cohesion: 0.40
Nodes (5): chatRoomsRepositoryProvider, _showCreateRoomDialog, _claimSlot, _leaveRoom, _sendMessage

### Community 73 - "@freezed"
Cohesion: 0.25
Nodes (8): @freezed, ConversationMessage, ConversationState, ConversationMessage, _ConversationMessage, ConversationState, _ConversationState, ConversationNotifier

### Community 74 - "draggable_monster_widget.dart"
Cohesion: 0.06
Nodes (35): ../../features/dashboard/data/models/hunter_catalog.dart, _breatheController, build, createState, dispose, DraggableMonsterWidget, _DraggableMonsterWidgetState, _floatController (+27 more)

### Community 75 - "level_exam_screen.dart"
Cohesion: 0.13
Nodes (14): ../../../dashboard/data/models/hunter_catalog.dart, createState, dispose, _examScore, _examTimer, _finishExam, _getExamDurationSeconds, initState (+6 more)

### Community 76 - "status_window_modal.dart"
Cohesion: 0.17
Nodes (11): ../../data/models/hunter_catalog.dart, build, _buildAttributeRow, createState, currentRank, _equippedCode, equippedTitleCode, initState (+3 more)

### Community 77 - "audio_sfx_service.dart"
Cohesion: 0.22
Nodes (12): AudioSfxService, _key, _loadPreference, playBossAlarm, playLevelUp, playManaRecharge, playQuestComplete, setSfxEnabled (+4 more)

### Community 78 - "Route /home"
Cohesion: 0.29
Nodes (8): build, build, _fetchPlansFromDb, subscriptionRepositoryProvider, build, _fetchDynamicPlans, _handlePurchase, Route /home

### Community 79 - "user_settings.dart"
Cohesion: 0.15
Nodes (12): copyWith, correctionLevel, correctionStyle, dailyGoalMinutes, fromJson, initial, interests, motivation (+4 more)

### Community 80 - "package:google_fonts/google_fonts.dart"
Cohesion: 0.50
Nodes (3): app_colors.dart, AppTheme, package:google_fonts/google_fonts.dart

### Community 81 - "main.dart"
Cohesion: 0.20
Nodes (9): app/app.dart, core/constants/api_constants.dart, core/utils/error_tracker.dart, core/utils/latency_benchmark.dart, core/widgets/configuration_error_widget.dart, init, initError, main (+1 more)

### Community 82 - "voice_waveform_visualizer.dart"
Cohesion: 0.18
Nodes (11): AnimationController, dart:math, build, _controller, createState, dispose, initState, isAiSpeaking (+3 more)

### Community 83 - "State"
Cohesion: 0.23
Nodes (12): LevelExamScreen, _LevelExamScreenState, CompletedLessonsHistoryList, _CompletedLessonsHistoryListState, DailyQuestsWidget, _DailyQuestsWidgetState, LearningPathRoadmap, _LearningPathRoadmapState (+4 more)

### Community 84 - "StateNotifier"
Cohesion: 0.40
Nodes (5): SfxNotifier, UserSettings, UserSettingsNotifier, PremiumStatusNotifier, StateNotifier

### Community 85 - "chat_rooms_repository.dart"
Cohesion: 0.18
Nodes (10): ChatRoomsRepositoryImpl, ChatRoomsRepository, claimSpeakerSlot, createRoom, getRooms, joinRoom, leaveRoom, sendChatMessage (+2 more)

### Community 86 - "ai_pick_hero_card.dart"
Cohesion: 0.22
Nodes (8): AIPickHeroCard, build, _getIconData, lesson, matchPercentage, matchReason, onTapPreview, VoidCallback

### Community 87 - "../../../auth/presentation/providers/auth_providers.dart"
Cohesion: 0.25
Nodes (6): ../../../auth/presentation/providers/auth_providers.dart, ../../data/repositories/onboarding_repository_impl.dart, OnboardingRepositoryImpl, OnboardingRepository, saveOnboardingData, supabaseClient

### Community 88 - "ConsumerStatefulWidget"
Cohesion: 0.29
Nodes (7): ConsumerStatefulWidget, ProfileEditScreen, SettingsScreen, OnboardingScreen, PlacementTestScreen, PaywallScreen, _PaywallScreenState

### Community 89 - "subscription_repository.dart"
Cohesion: 0.29
Nodes (6): SubscriptionRepositoryImpl, getSubscriptionPlans, isUserPremium, purchasePackage, restorePurchases, SubscriptionRepository

### Community 90 - "overflow_test.dart"
Cohesion: 0.29
Nodes (5): package:flutter_test/flutter_test.dart, package:tutorsaas/core/utils/latency_benchmark.dart, package:tutorsaas/features/dashboard/presentation/widgets/league_leaderboard_widget.dart, main, main

### Community 91 - "app.dart"
Cohesion: 0.40
Nodes (4): core/theme/app_theme.dart, build, TutorSaaSApp, router.dart

### Community 92 - "_MicPulseButtonState"
Cohesion: 0.67
Nodes (3): MicPulseButton, _MicPulseButtonState, SingleTickerProviderStateMixin

## Knowledge Gaps
- **782 isolated node(s):** `XCTest`, `build`, `appRouter`, `ApiConstants`, `supabaseUrl` (+777 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `DashboardRepository` connect `chat_rooms_repository.dart` to `dashboard_providers.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Why does `currentUserProvider` connect `ai_pick_hero_card.dart` to `Database Schema & Tables`, `currentUserProvider`, `currentUserProvider`, `build`, `chat_rooms_screen.dart`, `build`, `subscription_repository.dart`, `profile_edit_screen.dart`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `XCTest`, `build`, `appRouter` to the rest of the system?**
  _782 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `System Architecture & Business Context` be split into smaller, more focused modules?**
  _Cohesion score 0.07142857142857142 - nodes in this community are weakly interconnected._
- **Should `Implementation Plan & Repair Strategy` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Frontend Routing & Lesson Repair` be split into smaller, more focused modules?**
  _Cohesion score 0.07692307692307693 - nodes in this community are weakly interconnected._
- **Should `Data Model & UI Corrections` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._