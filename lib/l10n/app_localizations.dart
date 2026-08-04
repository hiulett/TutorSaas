import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Dungeon of English'**
  String get app_name;

  /// No description provided for @welcome_title.
  ///
  /// In en, this message translates to:
  /// **'[SYSTEM MESSAGE: AWAKENING HUNTER CORE...]'**
  String get welcome_title;

  /// No description provided for @welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn by Speaking'**
  String get welcome_subtitle;

  /// No description provided for @welcome_desc.
  ///
  /// In en, this message translates to:
  /// **'Your personal AI language tutor, available 24/7 for natural conversation.'**
  String get welcome_desc;

  /// No description provided for @welcome_warning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Unregistered Hunters will be designated Rank E'**
  String get welcome_warning;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get register;

  /// No description provided for @continue_google.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE WITH GOOGLE'**
  String get continue_google;

  /// No description provided for @login_google.
  ///
  /// In en, this message translates to:
  /// **'LOG IN WITH GOOGLE'**
  String get login_google;

  /// No description provided for @register_google.
  ///
  /// In en, this message translates to:
  /// **'REGISTER WITH GOOGLE'**
  String get register_google;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @sign_in_desc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Google account to continue with your language classes.'**
  String get sign_in_desc;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account;

  /// No description provided for @create_account_desc.
  ///
  /// In en, this message translates to:
  /// **'Register with Google to personalize your AI language tutor and track progress.'**
  String get create_account_desc;

  /// No description provided for @sync_progress.
  ///
  /// In en, this message translates to:
  /// **'SYNC CEFR LANGUAGE...'**
  String get sync_progress;

  /// No description provided for @dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM STATUS'**
  String get dashboard_title;

  /// No description provided for @dungeons.
  ///
  /// In en, this message translates to:
  /// **'DUNGEONS'**
  String get dungeons;

  /// No description provided for @guild.
  ///
  /// In en, this message translates to:
  /// **'GUILD'**
  String get guild;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get status;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'CONFIG'**
  String get config;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get player;

  /// No description provided for @mp.
  ///
  /// In en, this message translates to:
  /// **'MP'**
  String get mp;

  /// No description provided for @days_clear.
  ///
  /// In en, this message translates to:
  /// **'DAYS CLEAR'**
  String get days_clear;

  /// No description provided for @urgent_quest.
  ///
  /// In en, this message translates to:
  /// **'URGENT QUEST'**
  String get urgent_quest;

  /// No description provided for @enter_gateway.
  ///
  /// In en, this message translates to:
  /// **'ENTER GATEWAY BATTLE'**
  String get enter_gateway;

  /// No description provided for @active_quests.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE QUESTS'**
  String get active_quests;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get weekly;

  /// No description provided for @speak_words.
  ///
  /// In en, this message translates to:
  /// **'Speak 50 words in a session'**
  String get speak_words;

  /// No description provided for @keep_streak.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive'**
  String get keep_streak;

  /// No description provided for @clear_vocab.
  ///
  /// In en, this message translates to:
  /// **'Clear 1 Vocabulary Dungeon'**
  String get clear_vocab;

  /// No description provided for @chat_rooms.
  ///
  /// In en, this message translates to:
  /// **'Voice Chat Rooms'**
  String get chat_rooms;

  /// No description provided for @chat_rooms_desc.
  ///
  /// In en, this message translates to:
  /// **'Group practice with AI moderation in real time'**
  String get chat_rooms_desc;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language_level.
  ///
  /// In en, this message translates to:
  /// **'Language and Level'**
  String get language_level;

  /// No description provided for @tutorial_system.
  ///
  /// In en, this message translates to:
  /// **'Tutorial and System'**
  String get tutorial_system;

  /// No description provided for @ai_preferences.
  ///
  /// In en, this message translates to:
  /// **'AI Preferences'**
  String get ai_preferences;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @target_language.
  ///
  /// In en, this message translates to:
  /// **'Target Language'**
  String get target_language;

  /// No description provided for @active_cefr.
  ///
  /// In en, this message translates to:
  /// **'Active CEFR Level'**
  String get active_cefr;

  /// No description provided for @review_tutorial.
  ///
  /// In en, this message translates to:
  /// **'Review Tutorial'**
  String get review_tutorial;

  /// No description provided for @review_tutorial_desc.
  ///
  /// In en, this message translates to:
  /// **'View the complete onboarding again'**
  String get review_tutorial_desc;

  /// No description provided for @tutorial_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Review Tutorial'**
  String get tutorial_dialog_title;

  /// No description provided for @tutorial_dialog_content.
  ///
  /// In en, this message translates to:
  /// **'The tutorial will be marked as pending. Return to home to be redirected.'**
  String get tutorial_dialog_content;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @tutorial_pending.
  ///
  /// In en, this message translates to:
  /// **'Tutorial marked as pending. Go to home.'**
  String get tutorial_pending;

  /// No description provided for @correction_level.
  ///
  /// In en, this message translates to:
  /// **'AI Correction Level'**
  String get correction_level;

  /// No description provided for @tutor_personality.
  ///
  /// In en, this message translates to:
  /// **'Tutor Personality'**
  String get tutor_personality;

  /// No description provided for @correction_style.
  ///
  /// In en, this message translates to:
  /// **'Correction Style'**
  String get correction_style;

  /// No description provided for @daily_goal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get daily_goal;

  /// No description provided for @save_settings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get save_settings;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Settings and Onboarding saved successfully'**
  String get saved;

  /// No description provided for @error_saving.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get error_saving;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Target Language'**
  String get select_language;

  /// No description provided for @select_cefr.
  ///
  /// In en, this message translates to:
  /// **'Select Your CEFR Level'**
  String get select_cefr;

  /// No description provided for @fluency.
  ///
  /// In en, this message translates to:
  /// **'FLUENCY'**
  String get fluency;

  /// No description provided for @latency.
  ///
  /// In en, this message translates to:
  /// **'LATENCY'**
  String get latency;

  /// No description provided for @pipeline_perf.
  ///
  /// In en, this message translates to:
  /// **'Pipeline performance'**
  String get pipeline_perf;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements & Stats'**
  String get achievements;

  /// No description provided for @vocabulary_learned.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Learned'**
  String get vocabulary_learned;

  /// No description provided for @weekly_practice.
  ///
  /// In en, this message translates to:
  /// **'Weekly Practice (Voice Minutes)'**
  String get weekly_practice;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get view_all;

  /// No description provided for @srs_review.
  ///
  /// In en, this message translates to:
  /// **'SRS Review'**
  String get srs_review;

  /// No description provided for @fluency_evolution.
  ///
  /// In en, this message translates to:
  /// **'Fluency & Latency Evolution'**
  String get fluency_evolution;

  /// No description provided for @wpm.
  ///
  /// In en, this message translates to:
  /// **'WPM'**
  String get wpm;

  /// No description provided for @radar_title.
  ///
  /// In en, this message translates to:
  /// **'5-D Skills Radar'**
  String get radar_title;

  /// No description provided for @heatmap_title.
  ///
  /// In en, this message translates to:
  /// **'Practice Consistency (4 Weeks)'**
  String get heatmap_title;

  /// No description provided for @weeks_ago.
  ///
  /// In en, this message translates to:
  /// **'4 weeks ago'**
  String get weeks_ago;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @status_window.
  ///
  /// In en, this message translates to:
  /// **'MONARCH STATUS WINDOW'**
  String get status_window;

  /// No description provided for @status_window_desc.
  ///
  /// In en, this message translates to:
  /// **'View 11-attribute matrix, equipped titles and power radar'**
  String get status_window_desc;

  /// No description provided for @xp_points.
  ///
  /// In en, this message translates to:
  /// **'XP Points'**
  String get xp_points;

  /// No description provided for @active_streak.
  ///
  /// In en, this message translates to:
  /// **'Active Streak'**
  String get active_streak;

  /// No description provided for @active_level.
  ///
  /// In en, this message translates to:
  /// **'Active Level'**
  String get active_level;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @voice_chat.
  ///
  /// In en, this message translates to:
  /// **'Voice Chat'**
  String get voice_chat;

  /// No description provided for @speak_now.
  ///
  /// In en, this message translates to:
  /// **'SPEAK NOW'**
  String get speak_now;

  /// No description provided for @hold_speak.
  ///
  /// In en, this message translates to:
  /// **'Hold Core to Speak'**
  String get hold_speak;

  /// No description provided for @boss_hp.
  ///
  /// In en, this message translates to:
  /// **'Boss HP'**
  String get boss_hp;

  /// No description provided for @system_analysis.
  ///
  /// In en, this message translates to:
  /// **'[SYSTEM ANALYSIS COMPLETE]'**
  String get system_analysis;

  /// No description provided for @explain_rule.
  ///
  /// In en, this message translates to:
  /// **'Explain Rule'**
  String get explain_rule;

  /// No description provided for @provide_example.
  ///
  /// In en, this message translates to:
  /// **'Provide Example'**
  String get provide_example;

  /// No description provided for @retry_battle.
  ///
  /// In en, this message translates to:
  /// **'Retry Battle'**
  String get retry_battle;

  /// No description provided for @type_command.
  ///
  /// In en, this message translates to:
  /// **'Type command or log entry...'**
  String get type_command;

  /// No description provided for @lesson_preview.
  ///
  /// In en, this message translates to:
  /// **'Lesson Objectives and Goals'**
  String get lesson_preview;

  /// No description provided for @communication_goals.
  ///
  /// In en, this message translates to:
  /// **'Communication Goals'**
  String get communication_goals;

  /// No description provided for @recommended_phrases.
  ///
  /// In en, this message translates to:
  /// **'Recommended Phrases'**
  String get recommended_phrases;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @start_voice_lesson.
  ///
  /// In en, this message translates to:
  /// **'Start Voice Lesson Now'**
  String get start_voice_lesson;

  /// No description provided for @objectives.
  ///
  /// In en, this message translates to:
  /// **'Objectives'**
  String get objectives;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @master.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// No description provided for @min_day.
  ///
  /// In en, this message translates to:
  /// **'min / day'**
  String get min_day;

  /// No description provided for @onboarding_lang.
  ///
  /// In en, this message translates to:
  /// **'AWAKENING LANGUAGE'**
  String get onboarding_lang;

  /// No description provided for @onboarding_country.
  ///
  /// In en, this message translates to:
  /// **'HUNTER REGISTRY'**
  String get onboarding_country;

  /// No description provided for @onboarding_target.
  ///
  /// In en, this message translates to:
  /// **'TARGET LANGUAGE'**
  String get onboarding_target;

  /// No description provided for @onboarding_cefr.
  ///
  /// In en, this message translates to:
  /// **'GATE SELECTION'**
  String get onboarding_cefr;

  /// No description provided for @onboarding_goal.
  ///
  /// In en, this message translates to:
  /// **'MISSION COMMITMENT'**
  String get onboarding_goal;

  /// No description provided for @onboarding_interests.
  ///
  /// In en, this message translates to:
  /// **'SKILL TREE'**
  String get onboarding_interests;

  /// No description provided for @onboarding_correction.
  ///
  /// In en, this message translates to:
  /// **'TACTICAL APPROACH'**
  String get onboarding_correction;

  /// No description provided for @onboarding_obstacle.
  ///
  /// In en, this message translates to:
  /// **'BOSS IDENTIFICATION'**
  String get onboarding_obstacle;

  /// No description provided for @btn_continue.
  ///
  /// In en, this message translates to:
  /// **'btn_continue'**
  String get btn_continue;

  /// No description provided for @complete_onboarding.
  ///
  /// In en, this message translates to:
  /// **'Complete Onboarding'**
  String get complete_onboarding;

  /// No description provided for @exam_timer.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get exam_timer;

  /// No description provided for @exam_pass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get exam_pass;

  /// No description provided for @exam_fail.
  ///
  /// In en, this message translates to:
  /// **'FAIL'**
  String get exam_fail;

  /// No description provided for @new_rank.
  ///
  /// In en, this message translates to:
  /// **'New Rank Unlocked'**
  String get new_rank;

  /// No description provided for @dungeon.
  ///
  /// In en, this message translates to:
  /// **'Dungeon'**
  String get dungeon;

  /// No description provided for @quest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get quest;

  /// No description provided for @boss.
  ///
  /// In en, this message translates to:
  /// **'Boss'**
  String get boss;

  /// No description provided for @hunter.
  ///
  /// In en, this message translates to:
  /// **'Hunter'**
  String get hunter;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get rank;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @log_entry.
  ///
  /// In en, this message translates to:
  /// **'Log Entry'**
  String get log_entry;

  /// No description provided for @system_log.
  ///
  /// In en, this message translates to:
  /// **'System Log'**
  String get system_log;

  /// No description provided for @data_stream.
  ///
  /// In en, this message translates to:
  /// **'Data Stream'**
  String get data_stream;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @first_steps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get first_steps;

  /// No description provided for @first_steps_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first conversation to earn your starting gear'**
  String get first_steps_desc;

  /// No description provided for @fire_streak.
  ///
  /// In en, this message translates to:
  /// **'Fire Streak'**
  String get fire_streak;

  /// No description provided for @fire_streak_desc.
  ///
  /// In en, this message translates to:
  /// **'Maintain a 7-day practice streak'**
  String get fire_streak_desc;

  /// No description provided for @fluent_speaker.
  ///
  /// In en, this message translates to:
  /// **'Fluent Speaker'**
  String get fluent_speaker;

  /// No description provided for @fluent_speaker_desc.
  ///
  /// In en, this message translates to:
  /// **'Speak 100 words in a single session'**
  String get fluent_speaker_desc;

  /// No description provided for @goals_completed_desc.
  ///
  /// In en, this message translates to:
  /// **'All main objectives cleared'**
  String get goals_completed_desc;

  /// No description provided for @guild_hall.
  ///
  /// In en, this message translates to:
  /// **'GUILD HALL'**
  String get guild_hall;

  /// No description provided for @live_coop.
  ///
  /// In en, this message translates to:
  /// **'Live Co-Op Raid Rooms'**
  String get live_coop;

  /// No description provided for @initialize_room.
  ///
  /// In en, this message translates to:
  /// **'Initialize Room'**
  String get initialize_room;

  /// No description provided for @enter_raid.
  ///
  /// In en, this message translates to:
  /// **'Enter Raid'**
  String get enter_raid;

  /// No description provided for @hunters_active.
  ///
  /// In en, this message translates to:
  /// **'Hunters Active'**
  String get hunters_active;

  /// No description provided for @live_voice.
  ///
  /// In en, this message translates to:
  /// **'Live Voice'**
  String get live_voice;

  /// No description provided for @barrier_active.
  ///
  /// In en, this message translates to:
  /// **'Barrier Active'**
  String get barrier_active;

  /// No description provided for @no_vocab.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary learned yet. Start a conversation!'**
  String get no_vocab;

  /// No description provided for @vocab_detail.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Detail'**
  String get vocab_detail;

  /// No description provided for @vocab_added.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary added'**
  String get vocab_added;

  /// No description provided for @xp_earned.
  ///
  /// In en, this message translates to:
  /// **'+{amount} XP'**
  String xp_earned(Object amount);

  /// No description provided for @streak_days.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String streak_days(Object count);

  /// No description provided for @conversations_remaining.
  ///
  /// In en, this message translates to:
  /// **'{count} conversations remaining'**
  String conversations_remaining(Object count);

  /// No description provided for @character_name.
  ///
  /// In en, this message translates to:
  /// **'HUNTER NAME'**
  String get character_name;

  /// No description provided for @character_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Your adventurer name...'**
  String get character_name_hint;

  /// No description provided for @character_avatar.
  ///
  /// In en, this message translates to:
  /// **'AVATAR'**
  String get character_avatar;

  /// No description provided for @character_class.
  ///
  /// In en, this message translates to:
  /// **'CLASS'**
  String get character_class;

  /// No description provided for @oracle_title.
  ///
  /// In en, this message translates to:
  /// **'THE GUILD ORACLE'**
  String get oracle_title;

  /// No description provided for @oracle_assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment in progress...'**
  String get oracle_assessment;

  /// No description provided for @oracle_respond.
  ///
  /// In en, this message translates to:
  /// **'Respond to the Oracle...'**
  String get oracle_respond;

  /// No description provided for @oracle_result.
  ///
  /// In en, this message translates to:
  /// **'Assessment Complete'**
  String get oracle_result;

  /// No description provided for @oracle_strengths.
  ///
  /// In en, this message translates to:
  /// **'STRENGTHS'**
  String get oracle_strengths;

  /// No description provided for @oracle_weaknesses.
  ///
  /// In en, this message translates to:
  /// **'AREAS FOR IMPROVEMENT'**
  String get oracle_weaknesses;

  /// No description provided for @oracle_continue.
  ///
  /// In en, this message translates to:
  /// **'RECEIVE HUNTER LICENSE'**
  String get oracle_continue;

  /// No description provided for @nucleo_title.
  ///
  /// In en, this message translates to:
  /// **'THE ARCANE CORE IS DEPLETED'**
  String get nucleo_title;

  /// No description provided for @nucleo_desc.
  ///
  /// In en, this message translates to:
  /// **'The Oracle has responded {count} times today. It needs to recharge with the morning light.'**
  String nucleo_desc(Object count);

  /// No description provided for @nucleo_recharge.
  ///
  /// In en, this message translates to:
  /// **'RECHARGE +5'**
  String get nucleo_recharge;

  /// No description provided for @nucleo_premium.
  ///
  /// In en, this message translates to:
  /// **'GO PREMIUM'**
  String get nucleo_premium;

  /// No description provided for @nucleo_rest.
  ///
  /// In en, this message translates to:
  /// **'Rest until tomorrow — the Core will recharge'**
  String get nucleo_rest;

  /// No description provided for @mod_ai.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI Moderation'**
  String get mod_ai;

  /// No description provided for @mod_creator.
  ///
  /// In en, this message translates to:
  /// **'👑 Creator Moderation'**
  String get mod_creator;

  /// No description provided for @mod_assigned.
  ///
  /// In en, this message translates to:
  /// **'🎯 Assigned Moderation'**
  String get mod_assigned;

  /// No description provided for @mod_table_new.
  ///
  /// In en, this message translates to:
  /// **'New Guild Table'**
  String get mod_table_new;

  /// No description provided for @mod_table_name.
  ///
  /// In en, this message translates to:
  /// **'Table name'**
  String get mod_table_name;

  /// No description provided for @mod_description.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get mod_description;

  /// No description provided for @mod_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get mod_category;

  /// No description provided for @mod_type.
  ///
  /// In en, this message translates to:
  /// **'MODERATION TYPE'**
  String get mod_type;

  /// No description provided for @mod_create.
  ///
  /// In en, this message translates to:
  /// **'Create Table'**
  String get mod_create;

  /// No description provided for @mod_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mod_cancel;

  /// No description provided for @mod_ai_desc.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor moderates automatically'**
  String get mod_ai_desc;

  /// No description provided for @mod_creator_desc.
  ///
  /// In en, this message translates to:
  /// **'You moderate. Manage speakers and turns'**
  String get mod_creator_desc;

  /// No description provided for @mod_assigned_desc.
  ///
  /// In en, this message translates to:
  /// **'Another user will be the moderator. Enter their email:'**
  String get mod_assigned_desc;

  /// No description provided for @room_live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get room_live;

  /// No description provided for @room_mic.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get room_mic;

  /// No description provided for @room_leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get room_leave;

  /// No description provided for @room_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get room_chat;

  /// No description provided for @room_audience.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get room_audience;

  /// No description provided for @room_hand.
  ///
  /// In en, this message translates to:
  /// **'Request to Speak'**
  String get room_hand;

  /// No description provided for @room_hand_raised.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get room_hand_raised;

  /// No description provided for @room_claim_slot.
  ///
  /// In en, this message translates to:
  /// **'Claim Slot {slot}'**
  String room_claim_slot(Object slot);

  /// No description provided for @room_spectators.
  ///
  /// In en, this message translates to:
  /// **'Spectators ({count})'**
  String room_spectators(Object count);

  /// No description provided for @room_ai_moderating.
  ///
  /// In en, this message translates to:
  /// **'AI Moderating'**
  String get room_ai_moderating;

  /// No description provided for @room_moderating.
  ///
  /// In en, this message translates to:
  /// **'Moderating'**
  String get room_moderating;

  /// No description provided for @room_slot.
  ///
  /// In en, this message translates to:
  /// **'Slot {slot}'**
  String room_slot(Object slot);

  /// No description provided for @conversation_title.
  ///
  /// In en, this message translates to:
  /// **'Voice Room'**
  String get conversation_title;

  /// No description provided for @conversation_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Type in English...'**
  String get conversation_input_hint;

  /// No description provided for @conversation_mission_guide.
  ///
  /// In en, this message translates to:
  /// **'MISSION GUIDE'**
  String get conversation_mission_guide;

  /// No description provided for @conversation_voice_mode.
  ///
  /// In en, this message translates to:
  /// **'Voice Mode'**
  String get conversation_voice_mode;

  /// No description provided for @conversation_text_mode.
  ///
  /// In en, this message translates to:
  /// **'Text Mode'**
  String get conversation_text_mode;

  /// No description provided for @conversation_speech_dna.
  ///
  /// In en, this message translates to:
  /// **'Voice Fingerprint'**
  String get conversation_speech_dna;

  /// No description provided for @conversation_replay.
  ///
  /// In en, this message translates to:
  /// **'REPLAY'**
  String get conversation_replay;

  /// No description provided for @guild_master.
  ///
  /// In en, this message translates to:
  /// **'★ GUILD MASTER'**
  String get guild_master;

  /// No description provided for @guild_online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get guild_online;

  /// No description provided for @guild_quest_daily.
  ///
  /// In en, this message translates to:
  /// **'DAILY QUEST'**
  String get guild_quest_daily;

  /// No description provided for @guild_quest_speak.
  ///
  /// In en, this message translates to:
  /// **'Speak 10 minutes in a voice room'**
  String get guild_quest_speak;

  /// No description provided for @guild_tables.
  ///
  /// In en, this message translates to:
  /// **'GUILD TABLES'**
  String get guild_tables;

  /// No description provided for @guild_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get guild_create;

  /// No description provided for @guild_join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get guild_join;

  /// No description provided for @guild_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get guild_enter;

  /// No description provided for @guild_no_rooms.
  ///
  /// In en, this message translates to:
  /// **'No active rooms in this category.'**
  String get guild_no_rooms;

  /// No description provided for @status_panel.
  ///
  /// In en, this message translates to:
  /// **'HUNTER STATUS PANEL'**
  String get status_panel;

  /// No description provided for @status_attributes.
  ///
  /// In en, this message translates to:
  /// **'MONARCH ATTRIBUTES (11)'**
  String get status_attributes;

  /// No description provided for @status_titles.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY TITLES'**
  String get status_titles;

  /// No description provided for @status_equip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get status_equip;

  /// No description provided for @status_equipped.
  ///
  /// In en, this message translates to:
  /// **'✓'**
  String get status_equipped;

  /// No description provided for @status_combat.
  ///
  /// In en, this message translates to:
  /// **'COMBAT ATTRIBUTES'**
  String get status_combat;

  /// No description provided for @status_achievements.
  ///
  /// In en, this message translates to:
  /// **'RARE ACHIEVEMENTS'**
  String get status_achievements;

  /// No description provided for @hud_xp_total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL XP'**
  String get hud_xp_total;

  /// No description provided for @hud_vocabulary.
  ///
  /// In en, this message translates to:
  /// **'VOCABULARY'**
  String get hud_vocabulary;

  /// No description provided for @hud_level.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get hud_level;

  /// No description provided for @hud_streak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get hud_streak;

  /// No description provided for @error_mic_permission.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied. Please enable it in settings.'**
  String get error_mic_permission;

  /// No description provided for @error_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening to your voice...'**
  String get error_listening;

  /// No description provided for @error_short_audio.
  ///
  /// In en, this message translates to:
  /// **'The recording was too short or empty. Speak again.'**
  String get error_short_audio;

  /// No description provided for @error_no_speech.
  ///
  /// In en, this message translates to:
  /// **'No speech detected. Try speaking closer to the microphone.'**
  String get error_no_speech;

  /// No description provided for @error_recording.
  ///
  /// In en, this message translates to:
  /// **'Could not create recording.'**
  String get error_recording;

  /// No description provided for @error_processing.
  ///
  /// In en, this message translates to:
  /// **'Error processing the response. Try again.'**
  String get error_processing;

  /// No description provided for @error_groq_connection.
  ///
  /// In en, this message translates to:
  /// **'Connection error with STT ({code}). Check your internet or API Key.'**
  String error_groq_connection(Object code);

  /// No description provided for @error_nucleo.
  ///
  /// In en, this message translates to:
  /// **'THE ARCANE CORE IS DEPLETED'**
  String get error_nucleo;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get no_results;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// No description provided for @learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learn_more;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @register_new_hunter.
  ///
  /// In en, this message translates to:
  /// **'REGISTER NEW HUNTER'**
  String get register_new_hunter;

  /// No description provided for @onboarding_select_native_warn.
  ///
  /// In en, this message translates to:
  /// **'Select your native language to continue.'**
  String get onboarding_select_native_warn;

  /// No description provided for @onboarding_select_target_warn.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to learn.'**
  String get onboarding_select_target_warn;

  /// No description provided for @onboarding_switch_interface_lang.
  ///
  /// In en, this message translates to:
  /// **'Switch App Interface Language'**
  String get onboarding_switch_interface_lang;

  /// No description provided for @onboarding_switch_interface_desc.
  ///
  /// In en, this message translates to:
  /// **'Change the app menus and buttons to {lang} instead of English.'**
  String onboarding_switch_interface_desc(String lang);

  /// No description provided for @onboarding_country_title.
  ///
  /// In en, this message translates to:
  /// **'COUNTRY OF ORIGIN'**
  String get onboarding_country_title;

  /// No description provided for @onboarding_country_desc.
  ///
  /// In en, this message translates to:
  /// **'Tell us where you are from to adapt pronunciation and expressions.'**
  String get onboarding_country_desc;

  /// No description provided for @onboarding_country_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get onboarding_country_search_hint;

  /// No description provided for @onboarding_country_no_results.
  ///
  /// In en, this message translates to:
  /// **'No countries found.'**
  String get onboarding_country_no_results;

  /// No description provided for @onboarding_oracle_classification.
  ///
  /// In en, this message translates to:
  /// **'THE ORACLE WILL CLASSIFY YOU'**
  String get onboarding_oracle_classification;

  /// No description provided for @onboarding_oracle_classification_desc.
  ///
  /// In en, this message translates to:
  /// **'The Oracle will analyze your language proficiency through a conversation to determine your starting rank.'**
  String get onboarding_oracle_classification_desc;

  /// No description provided for @onboarding_voice_evaluation.
  ///
  /// In en, this message translates to:
  /// **'VOICE CONVERSATIONAL EVALUATION'**
  String get onboarding_voice_evaluation;

  /// No description provided for @onboarding_voice_evaluation_desc.
  ///
  /// In en, this message translates to:
  /// **'Speak to the Oracle and you will be evaluated on pronunciation, vocabulary, grammar, comprehension, and fluency. The result will define your starting rank.'**
  String get onboarding_voice_evaluation_desc;

  /// No description provided for @onboarding_start_evaluation.
  ///
  /// In en, this message translates to:
  /// **'START EVALUATION'**
  String get onboarding_start_evaluation;

  /// No description provided for @onboarding_evaluation_optional.
  ///
  /// In en, this message translates to:
  /// **'The evaluation is optional: if you skip it, you will start at the initial rank (A1).'**
  String get onboarding_evaluation_optional;

  /// No description provided for @welcome_hunter_prefix.
  ///
  /// In en, this message translates to:
  /// **'WELCOME,'**
  String get welcome_hunter_prefix;

  /// No description provided for @welcome_hunter_suffix.
  ///
  /// In en, this message translates to:
  /// **'HUNTER!'**
  String get welcome_hunter_suffix;

  /// No description provided for @adventure_begins.
  ///
  /// In en, this message translates to:
  /// **'Your adventure begins now.'**
  String get adventure_begins;

  /// No description provided for @enter_realm.
  ///
  /// In en, this message translates to:
  /// **'ENTER THE REALM'**
  String get enter_realm;

  /// No description provided for @character_creation_title.
  ///
  /// In en, this message translates to:
  /// **'CREATE YOUR CHARACTER'**
  String get character_creation_title;

  /// No description provided for @character_creation_desc.
  ///
  /// In en, this message translates to:
  /// **'Before starting your adventure, we need to know who you are.'**
  String get character_creation_desc;

  /// No description provided for @character_creation_continue.
  ///
  /// In en, this message translates to:
  /// **'THE ORACLE AWAITS YOU'**
  String get character_creation_continue;

  /// No description provided for @character_name_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional — your account name will be used if empty.'**
  String get character_name_optional;

  /// No description provided for @character_class_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Classes unavailable. Try again later.'**
  String get character_class_unavailable;

  /// No description provided for @character_difficulty_label.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get character_difficulty_label;

  /// No description provided for @character_combat_label.
  ///
  /// In en, this message translates to:
  /// **'Combat'**
  String get character_combat_label;

  /// No description provided for @character_affinity_label.
  ///
  /// In en, this message translates to:
  /// **'Affinity'**
  String get character_affinity_label;

  /// No description provided for @character_abilities_label.
  ///
  /// In en, this message translates to:
  /// **'ABILITIES'**
  String get character_abilities_label;

  /// No description provided for @character_stat_attack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get character_stat_attack;

  /// No description provided for @character_stat_defense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get character_stat_defense;

  /// No description provided for @character_stat_magic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get character_stat_magic;

  /// No description provided for @character_stat_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get character_stat_speed;

  /// No description provided for @character_stat_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get character_stat_support;

  /// No description provided for @character_stat_survival.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get character_stat_survival;

  /// No description provided for @class_warrior_name.
  ///
  /// In en, this message translates to:
  /// **'Berserker'**
  String get class_warrior_name;

  /// No description provided for @class_warrior_desc.
  ///
  /// In en, this message translates to:
  /// **'Outspoken and brave. You speak first and think later. Ideal for overcoming the fear of speaking.'**
  String get class_warrior_desc;

  /// No description provided for @class_warrior_arch.
  ///
  /// In en, this message translates to:
  /// **'Extroverted, speaks first — overcoming fear'**
  String get class_warrior_arch;

  /// No description provided for @class_mage_name.
  ///
  /// In en, this message translates to:
  /// **'Arcane Mage'**
  String get class_mage_name;

  /// No description provided for @class_mage_desc.
  ///
  /// In en, this message translates to:
  /// **'Analytical and precise. You observe and structure before speaking. Ideal for perfecting grammar.'**
  String get class_mage_desc;

  /// No description provided for @class_mage_arch.
  ///
  /// In en, this message translates to:
  /// **'Analytical, structures before speaking — grammar'**
  String get class_mage_arch;

  /// No description provided for @class_assassin_name.
  ///
  /// In en, this message translates to:
  /// **'Assassin'**
  String get class_assassin_name;

  /// No description provided for @class_assassin_desc.
  ///
  /// In en, this message translates to:
  /// **'Tactical observer. You aim for precision and stealthy efficiency. Ideal for high-accuracy vocabulary.'**
  String get class_assassin_desc;

  /// No description provided for @class_assassin_arch.
  ///
  /// In en, this message translates to:
  /// **'Tactical observer — precision vocabulary'**
  String get class_assassin_arch;

  /// No description provided for @class_knight_name.
  ///
  /// In en, this message translates to:
  /// **'Knight'**
  String get class_knight_name;

  /// No description provided for @class_knight_desc.
  ///
  /// In en, this message translates to:
  /// **'Constant and methodical. You stand firm in your routines. Ideal for building streaks and consistency.'**
  String get class_knight_desc;

  /// No description provided for @class_knight_arch.
  ///
  /// In en, this message translates to:
  /// **'Constant and methodical — consistency & streaks'**
  String get class_knight_arch;

  /// No description provided for @class_archer_name.
  ///
  /// In en, this message translates to:
  /// **'Archer'**
  String get class_archer_name;

  /// No description provided for @class_archer_desc.
  ///
  /// In en, this message translates to:
  /// **'Agile and quick. You learn on the go within context. Ideal for mastering useful expressions.'**
  String get class_archer_desc;

  /// No description provided for @class_archer_arch.
  ///
  /// In en, this message translates to:
  /// **'Agile, context-driven learner — daily expressions'**
  String get class_archer_arch;

  /// No description provided for @class_summoner_name.
  ///
  /// In en, this message translates to:
  /// **'Summoner'**
  String get class_summoner_name;

  /// No description provided for @class_summoner_desc.
  ///
  /// In en, this message translates to:
  /// **'Creative and associative. You connect concepts and conjure ideas. Ideal for idiomatic phrases.'**
  String get class_summoner_desc;

  /// No description provided for @class_summoner_arch.
  ///
  /// In en, this message translates to:
  /// **'Creative, associative thinker — idioms & phrasing'**
  String get class_summoner_arch;

  /// No description provided for @class_paladin_name.
  ///
  /// In en, this message translates to:
  /// **'Paladin'**
  String get class_paladin_name;

  /// No description provided for @class_paladin_desc.
  ///
  /// In en, this message translates to:
  /// **'Goal-driven protector. Guided by clear duties. Ideal for formal and structured conversations.'**
  String get class_paladin_desc;

  /// No description provided for @class_paladin_arch.
  ///
  /// In en, this message translates to:
  /// **'Goal-driven learner — formal conversation'**
  String get class_paladin_arch;

  /// No description provided for @class_necromancer_name.
  ///
  /// In en, this message translates to:
  /// **'Necromancer'**
  String get class_necromancer_name;

  /// No description provided for @class_necromancer_desc.
  ///
  /// In en, this message translates to:
  /// **'Etymological explorer. You resurrect the roots of the language. Ideal for Latin roots and word origins.'**
  String get class_necromancer_desc;

  /// No description provided for @class_necromancer_arch.
  ///
  /// In en, this message translates to:
  /// **'Curious about etymology — Latin roots & history'**
  String get class_necromancer_arch;

  /// No description provided for @onboarding_lang_desc.
  ///
  /// In en, this message translates to:
  /// **'We will personalize your learning journey according to your native language.'**
  String get onboarding_lang_desc;

  /// No description provided for @onboarding_native_lang.
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get onboarding_native_lang;

  /// No description provided for @onboarding_target_desc.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to master.'**
  String get onboarding_target_desc;

  /// No description provided for @onb_validate_native.
  ///
  /// In en, this message translates to:
  /// **'Select your native language to continue.'**
  String get onb_validate_native;

  /// No description provided for @onb_validate_target.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to learn.'**
  String get onb_validate_target;

  /// No description provided for @login_google_error.
  ///
  /// In en, this message translates to:
  /// **'Error signing in with Google.'**
  String get login_google_error;

  /// No description provided for @register_google_error.
  ///
  /// In en, this message translates to:
  /// **'Error registering with Google.'**
  String get register_google_error;

  /// No description provided for @oracle_no_voice.
  ///
  /// In en, this message translates to:
  /// **'No voice detected. Speak closer to the microphone or use the keyboard.'**
  String get oracle_no_voice;

  /// No description provided for @oracle_listening.
  ///
  /// In en, this message translates to:
  /// **'LISTENING... RELEASE TO SEND'**
  String get oracle_listening;

  /// No description provided for @oracle_processing.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING WITH GROQ AI...'**
  String get oracle_processing;

  /// No description provided for @oracle_skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP QUESTION'**
  String get oracle_skip;

  /// No description provided for @oracle_complete.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE ASSESSMENT'**
  String get oracle_complete;

  /// No description provided for @room_no_messages.
  ///
  /// In en, this message translates to:
  /// **'No messages in this chamber yet.'**
  String get room_no_messages;

  /// No description provided for @room_error.
  ///
  /// In en, this message translates to:
  /// **'Room error: {err}'**
  String room_error(String err);

  /// No description provided for @room_hunt_lang.
  ///
  /// In en, this message translates to:
  /// **'Hunting Language:'**
  String get room_hunt_lang;

  /// No description provided for @room_xp_points.
  ///
  /// In en, this message translates to:
  /// **'Experience Points:'**
  String get room_xp_points;

  /// No description provided for @room_type_ai.
  ///
  /// In en, this message translates to:
  /// **'AI TRAINING'**
  String get room_type_ai;

  /// No description provided for @room_type_mentorship.
  ///
  /// In en, this message translates to:
  /// **'MENTORSHIP (RESONANCE)'**
  String get room_type_mentorship;

  /// No description provided for @room_type_event.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL EVENT'**
  String get room_type_event;

  /// No description provided for @room_cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get room_cancel;

  /// No description provided for @room_create_error.
  ///
  /// In en, this message translates to:
  /// **'Error creating room: {err}'**
  String room_create_error(String err);

  /// No description provided for @room_initialize.
  ///
  /// In en, this message translates to:
  /// **'INITIALIZE'**
  String get room_initialize;

  /// No description provided for @room_prestige.
  ///
  /// In en, this message translates to:
  /// **'PRESTIGE {level}'**
  String room_prestige(String level);

  /// No description provided for @mission_accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get mission_accept;

  /// No description provided for @mission_none.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE MISSIONS'**
  String get mission_none;

  /// No description provided for @mission_generate.
  ///
  /// In en, this message translates to:
  /// **'GENERATE MISSIONS'**
  String get mission_generate;

  /// No description provided for @mission_claim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get mission_claim;

  /// No description provided for @srs_close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get srs_close;

  /// No description provided for @srs_hard.
  ///
  /// In en, this message translates to:
  /// **'HARD'**
  String get srs_hard;

  /// No description provided for @srs_normal.
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get srs_normal;

  /// No description provided for @srs_easy.
  ///
  /// In en, this message translates to:
  /// **'EASY'**
  String get srs_easy;

  /// No description provided for @nucleo_unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Invocations — Elite Hunter'**
  String get nucleo_unlimited;

  /// No description provided for @paywall_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you for subscribing! Premium benefits unlocked.'**
  String get paywall_success;

  /// No description provided for @paywall_failure.
  ///
  /// In en, this message translates to:
  /// **'Purchase failure: {err}'**
  String paywall_failure(String err);

  /// No description provided for @paywall_restored.
  ///
  /// In en, this message translates to:
  /// **'Purchases successfully restored.'**
  String get paywall_restored;

  /// No description provided for @lessons_voice_rooms.
  ///
  /// In en, this message translates to:
  /// **'Voice Rooms'**
  String get lessons_voice_rooms;

  /// No description provided for @lessons_view_goals.
  ///
  /// In en, this message translates to:
  /// **'View Goals'**
  String get lessons_view_goals;

  /// No description provided for @exam_mute.
  ///
  /// In en, this message translates to:
  /// **'MUTE'**
  String get exam_mute;

  /// No description provided for @exam_conclude.
  ///
  /// In en, this message translates to:
  /// **'CONCLUDE RAID'**
  String get exam_conclude;

  /// No description provided for @exam_return.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO SANCTUARY'**
  String get exam_return;

  /// No description provided for @progress_xp_points.
  ///
  /// In en, this message translates to:
  /// **'XP Points'**
  String get progress_xp_points;

  /// No description provided for @progress_active_streak.
  ///
  /// In en, this message translates to:
  /// **'Active Streak'**
  String get progress_active_streak;

  /// No description provided for @progress_active_level.
  ///
  /// In en, this message translates to:
  /// **'Active Level'**
  String get progress_active_level;

  /// No description provided for @progress_srs_review.
  ///
  /// In en, this message translates to:
  /// **'SRS Review'**
  String get progress_srs_review;

  /// No description provided for @progress_see_all.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get progress_see_all;

  /// No description provided for @inventory_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load inventory'**
  String get inventory_load_error;

  /// No description provided for @inventory_empty.
  ///
  /// In en, this message translates to:
  /// **'EMPTY INVENTORY'**
  String get inventory_empty;

  /// No description provided for @inventory_visit_shop.
  ///
  /// In en, this message translates to:
  /// **'VISIT THE SHOP →'**
  String get inventory_visit_shop;

  /// No description provided for @inventory_equipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get inventory_equipped;

  /// No description provided for @conversation_goals.
  ///
  /// In en, this message translates to:
  /// **'Scenario Goals:'**
  String get conversation_goals;

  /// No description provided for @conversation_key_phrases.
  ///
  /// In en, this message translates to:
  /// **'Suggested Key Phrases:'**
  String get conversation_key_phrases;

  /// No description provided for @conversation_phonemes.
  ///
  /// In en, this message translates to:
  /// **'Phonemes to practice:'**
  String get conversation_phonemes;

  /// No description provided for @hero_got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get hero_got_it;

  /// No description provided for @summary_view_vocab.
  ///
  /// In en, this message translates to:
  /// **'VIEW VOCABULARY'**
  String get summary_view_vocab;

  /// No description provided for @summary_vocab_saved.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary saved to your profile.'**
  String get summary_vocab_saved;

  /// No description provided for @summary_done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get summary_done;

  /// No description provided for @collections_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load collections'**
  String get collections_load_error;

  /// No description provided for @profile_total_xp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get profile_total_xp;

  /// No description provided for @profile_streak.
  ///
  /// In en, this message translates to:
  /// **'Active streak'**
  String get profile_streak;

  /// No description provided for @profile_cefr_level.
  ///
  /// In en, this message translates to:
  /// **'CEFR Level'**
  String get profile_cefr_level;

  /// No description provided for @profile_vocab_error.
  ///
  /// In en, this message translates to:
  /// **'Error loading vocabulary'**
  String get profile_vocab_error;

  /// No description provided for @profile_vocab_empty.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary to show'**
  String get profile_vocab_empty;

  /// No description provided for @profile_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profile_close;

  /// No description provided for @battlepass_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load Battle Pass'**
  String get battlepass_load_error;

  /// No description provided for @profile_edit_camera.
  ///
  /// In en, this message translates to:
  /// **'CAMERA'**
  String get profile_edit_camera;

  /// No description provided for @profile_edit_gallery.
  ///
  /// In en, this message translates to:
  /// **'GALLERY'**
  String get profile_edit_gallery;

  /// No description provided for @chart_4weeks.
  ///
  /// In en, this message translates to:
  /// **'4 weeks ago'**
  String get chart_4weeks;

  /// No description provided for @chart_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chart_today;

  /// No description provided for @chart_latency.
  ///
  /// In en, this message translates to:
  /// **'Latency (s)'**
  String get chart_latency;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
