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

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Hunter'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your journey.'**
  String get login_subtitle;

  /// No description provided for @register_prompt.
  ///
  /// In en, this message translates to:
  /// **'New Hunter? Create account'**
  String get register_prompt;

  /// No description provided for @login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Already a Hunter? Log in'**
  String get login_prompt;

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

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get email_required;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get password_required;

  /// No description provided for @email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get email_invalid;

  /// No description provided for @password_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_short;

  /// No description provided for @login_email.
  ///
  /// In en, this message translates to:
  /// **'LOG IN WITH EMAIL'**
  String get login_email;

  /// No description provided for @register_email.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT WITH EMAIL'**
  String get register_email;

  /// No description provided for @login_email_error.
  ///
  /// In en, this message translates to:
  /// **'Error signing in with email.'**
  String get login_email_error;

  /// No description provided for @register_email_error.
  ///
  /// In en, this message translates to:
  /// **'Error creating the account.'**
  String get register_email_error;

  /// No description provided for @email_already_registered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Log in instead.'**
  String get email_already_registered;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful. Entering the realm...'**
  String get login_success;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Account created. Entering the realm...'**
  String get register_success;

  /// No description provided for @login_email_hint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get login_email_hint;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'FORGOT PASSWORD?'**
  String get forgot_password;

  /// No description provided for @reset_password_title.
  ///
  /// In en, this message translates to:
  /// **'RECOVER PASSWORD'**
  String get reset_password_title;

  /// No description provided for @reset_password_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a link to recover your password.'**
  String get reset_password_desc;

  /// No description provided for @reset_password_send.
  ///
  /// In en, this message translates to:
  /// **'SEND RECOVERY LINK'**
  String get reset_password_send;

  /// No description provided for @reset_password_sent.
  ///
  /// In en, this message translates to:
  /// **'Recovery link sent. Check your email inbox.'**
  String get reset_password_sent;

  /// No description provided for @reset_password_error.
  ///
  /// In en, this message translates to:
  /// **'Error sending the recovery link. Check the email and try again.'**
  String get reset_password_error;

  /// No description provided for @reset_password_email_empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to recover your password.'**
  String get reset_password_email_empty;

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

  /// No description provided for @dashboard_offline.
  ///
  /// In en, this message translates to:
  /// **'No connection. Showing your last saved progress.'**
  String get dashboard_offline;

  /// No description provided for @dashboard_offline_age.
  ///
  /// In en, this message translates to:
  /// **'No connection. Last progress {minutes} min ago.'**
  String dashboard_offline_age(int minutes);

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

  /// No description provided for @settings_save_error.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings.'**
  String get settings_save_error;

  /// No description provided for @settings_delete_error.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account.'**
  String get settings_delete_error;

  /// No description provided for @settings_app_language.
  ///
  /// In en, this message translates to:
  /// **'APP LANGUAGE'**
  String get settings_app_language;

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
  /// **'Holographic Skills Radar'**
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
  /// **'Continue'**
  String get btn_continue;

  /// No description provided for @onboarding_start_eval.
  ///
  /// In en, this message translates to:
  /// **'START EVALUATION'**
  String get onboarding_start_eval;

  /// No description provided for @register_confirm_email.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and confirm your account to continue.'**
  String get register_confirm_email;

  /// No description provided for @resend_confirmation.
  ///
  /// In en, this message translates to:
  /// **'RESEND'**
  String get resend_confirmation;

  /// No description provided for @login_email_not_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email is not confirmed yet. Check your inbox or request a new link.'**
  String get login_email_not_confirmed;

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
  /// **'Create Table'**
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
  /// **'GUILD MASTER'**
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

  /// No description provided for @srs_review_title.
  ///
  /// In en, this message translates to:
  /// **'DAILY REVIEW'**
  String get srs_review_title;

  /// No description provided for @srs_review_due.
  ///
  /// In en, this message translates to:
  /// **'{count} words waiting for review'**
  String srs_review_due(int count);

  /// No description provided for @npc_remembers_failure.
  ///
  /// In en, this message translates to:
  /// **'THE NPC REMEMBERS YOUR LAST ATTEMPT'**
  String get npc_remembers_failure;

  /// No description provided for @npc_remembers_partial.
  ///
  /// In en, this message translates to:
  /// **'THE NPC REMEMBERS YOU ALMOST MADE IT'**
  String get npc_remembers_partial;

  /// No description provided for @srs_review_cta.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get srs_review_cta;

  /// No description provided for @srs_retention.
  ///
  /// In en, this message translates to:
  /// **'{percent}% recalled after 7 days · {mastered} mastered'**
  String srs_retention(int percent, int mastered);

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

  /// No description provided for @paywall_nothing_to_restore.
  ///
  /// In en, this message translates to:
  /// **'There are no purchases to restore.'**
  String get paywall_nothing_to_restore;

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

  /// No description provided for @progress_active_rank.
  ///
  /// In en, this message translates to:
  /// **'Guild Rank'**
  String get progress_active_rank;

  /// No description provided for @radar_fluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency'**
  String get radar_fluency;

  /// No description provided for @radar_vocab.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get radar_vocab;

  /// No description provided for @radar_phonetics.
  ///
  /// In en, this message translates to:
  /// **'Phonetics'**
  String get radar_phonetics;

  /// No description provided for @radar_grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get radar_grammar;

  /// No description provided for @radar_comprehension.
  ///
  /// In en, this message translates to:
  /// **'Comprehension'**
  String get radar_comprehension;

  /// No description provided for @radar_naturalness.
  ///
  /// In en, this message translates to:
  /// **'Naturalness'**
  String get radar_naturalness;

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

  /// No description provided for @hero_cefr_label.
  ///
  /// In en, this message translates to:
  /// **'CEFR'**
  String get hero_cefr_label;

  /// No description provided for @hero_class_label.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get hero_class_label;

  /// No description provided for @hero_member_since.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get hero_member_since;

  /// No description provided for @summary_view_vocab.
  ///
  /// In en, this message translates to:
  /// **'VIEW VOCABULARY'**
  String get summary_view_vocab;

  /// No description provided for @summary_vocab_title.
  ///
  /// In en, this message translates to:
  /// **'SESSION VOCABULARY'**
  String get summary_vocab_title;

  /// No description provided for @summary_vocab_empty.
  ///
  /// In en, this message translates to:
  /// **'No words saved from this session yet.'**
  String get summary_vocab_empty;

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
  /// **'You haven\'t learned vocabulary in conversations yet.'**
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

  /// No description provided for @aura_title.
  ///
  /// In en, this message translates to:
  /// **'AURA'**
  String get aura_title;

  /// No description provided for @aura_locked.
  ///
  /// In en, this message translates to:
  /// **'AURA LOCKED'**
  String get aura_locked;

  /// No description provided for @aura_locked_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete the Basic Stage (PRE-A1 + A1 + A2) to awaken your power.'**
  String get aura_locked_desc;

  /// No description provided for @aura_awakened.
  ///
  /// In en, this message translates to:
  /// **'AURA USER'**
  String get aura_awakened;

  /// No description provided for @aura_basic_stage.
  ///
  /// In en, this message translates to:
  /// **'BASIC STAGE'**
  String get aura_basic_stage;

  /// No description provided for @aura_power.
  ///
  /// In en, this message translates to:
  /// **'POWER'**
  String get aura_power;

  /// No description provided for @aura_tier_latente.
  ///
  /// In en, this message translates to:
  /// **'LATENT'**
  String get aura_tier_latente;

  /// No description provided for @aura_tier_revelada.
  ///
  /// In en, this message translates to:
  /// **'REVEALED'**
  String get aura_tier_revelada;

  /// No description provided for @aura_tier_abierta.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get aura_tier_abierta;

  /// No description provided for @aura_tier_dominante.
  ///
  /// In en, this message translates to:
  /// **'DOMINANT'**
  String get aura_tier_dominante;

  /// No description provided for @aura_tier_abisal.
  ///
  /// In en, this message translates to:
  /// **'ABYSSAL'**
  String get aura_tier_abisal;

  /// No description provided for @aura_awakening_banner_title.
  ///
  /// In en, this message translates to:
  /// **'THE SYSTEM HAS SPOKEN'**
  String get aura_awakening_banner_title;

  /// No description provided for @aura_awakening_banner_desc.
  ///
  /// In en, this message translates to:
  /// **'You have awakened as an Aura User. Your power will grow with your skills.'**
  String get aura_awakening_banner_desc;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get shop;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get map;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'CLAIMED'**
  String get claimed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @missions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missions;

  /// No description provided for @oracle.
  ///
  /// In en, this message translates to:
  /// **'ORACLE'**
  String get oracle;

  /// No description provided for @pro_badge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get pro_badge;

  /// No description provided for @go_pro.
  ///
  /// In en, this message translates to:
  /// **'GO PRO'**
  String get go_pro;

  /// No description provided for @logout_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT?'**
  String get logout_confirm_title;

  /// No description provided for @logout_confirm_desc.
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved. You will need to log in again to continue.'**
  String get logout_confirm_desc;

  /// No description provided for @splash_system_hud.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM HUD · AWAKENING'**
  String get splash_system_hud;

  /// No description provided for @splash_connecting.
  ///
  /// In en, this message translates to:
  /// **'{pct}% · CONNECTING TO THE GREAT REALM'**
  String splash_connecting(int pct);

  /// No description provided for @connecting_realm.
  ///
  /// In en, this message translates to:
  /// **'CONNECTING TO THE GREAT REALM...'**
  String get connecting_realm;

  /// No description provided for @system_hunter_connected.
  ///
  /// In en, this message translates to:
  /// **'HUNTER SYSTEM — CONNECTED'**
  String get system_hunter_connected;

  /// No description provided for @cefr_level.
  ///
  /// In en, this message translates to:
  /// **'CEFR {code}'**
  String cefr_level(String code);

  /// No description provided for @level_up_banner.
  ///
  /// In en, this message translates to:
  /// **'¡LEVEL UP! {level}'**
  String level_up_banner(int level);

  /// No description provided for @title_earned_banner.
  ///
  /// In en, this message translates to:
  /// **'🏅 TITLE EARNED: {title}'**
  String title_earned_banner(String title);

  /// No description provided for @mana_label.
  ///
  /// In en, this message translates to:
  /// **'MANA'**
  String get mana_label;

  /// No description provided for @mana_available.
  ///
  /// In en, this message translates to:
  /// **'mana available'**
  String get mana_available;

  /// No description provided for @mana_daily_available.
  ///
  /// In en, this message translates to:
  /// **'mana available today'**
  String get mana_daily_available;

  /// No description provided for @guardian_title.
  ///
  /// In en, this message translates to:
  /// **'MANA SANCTUARY'**
  String get guardian_title;

  /// No description provided for @guardian_sealed.
  ///
  /// In en, this message translates to:
  /// **'Sealed'**
  String get guardian_sealed;

  /// No description provided for @guardian_cry.
  ///
  /// In en, this message translates to:
  /// **'YOUR MANA IS DEPLETED.\nTHE SANCTUARY AWAITS.'**
  String get guardian_cry;

  /// No description provided for @guardian_desc.
  ///
  /// In en, this message translates to:
  /// **'Every AI action costs mana. Recover it with your plan, potions, or an elixir/gem from your bag.'**
  String get guardian_desc;

  /// No description provided for @guardian_get_mana.
  ///
  /// In en, this message translates to:
  /// **'GET MANA'**
  String get guardian_get_mana;

  /// No description provided for @guardian_get_mana_desc.
  ///
  /// In en, this message translates to:
  /// **'MORE MANA PER MONTH BY ESTATE'**
  String get guardian_get_mana_desc;

  /// No description provided for @guardian_equip_item.
  ///
  /// In en, this message translates to:
  /// **'EQUIP ELIXIR / GEM'**
  String get guardian_equip_item;

  /// No description provided for @guardian_equip_item_desc.
  ///
  /// In en, this message translates to:
  /// **'Equip a mana item from your bag'**
  String get guardian_equip_item_desc;

  /// No description provided for @guardian_go_back.
  ///
  /// In en, this message translates to:
  /// **'Return to the Guild'**
  String get guardian_go_back;

  /// No description provided for @mana_balance.
  ///
  /// In en, this message translates to:
  /// **'{remaining} / {total} mana'**
  String mana_balance(int remaining, int total);

  /// No description provided for @plus_mana.
  ///
  /// In en, this message translates to:
  /// **'+{count} mana'**
  String plus_mana(int count);

  /// No description provided for @purchase_confirm_question.
  ///
  /// In en, this message translates to:
  /// **'Acquire \"{name}\" for {price}?'**
  String purchase_confirm_question(String name, String price);

  /// No description provided for @mana_tooltip.
  ///
  /// In en, this message translates to:
  /// **'MANA: energy for every AI action (Oracle, dungeons, chats). Acquired with your plan and potions/gems; expires with the cycle.'**
  String get mana_tooltip;

  /// No description provided for @mana_expires.
  ///
  /// In en, this message translates to:
  /// **'expires {date}'**
  String mana_expires(String date);

  /// No description provided for @aura_locked_tooltip.
  ///
  /// In en, this message translates to:
  /// **'BASIC STAGE: complete the PRE-A1, A1 and A2 mission objectives to awaken your Aura.'**
  String get aura_locked_tooltip;

  /// No description provided for @aura_awakened_tooltip.
  ///
  /// In en, this message translates to:
  /// **'AURA: uncapped merit. Keep accumulating with every evaluated session.'**
  String get aura_awakened_tooltip;

  /// No description provided for @aura_xp.
  ///
  /// In en, this message translates to:
  /// **'AURA XP {xp}'**
  String aura_xp(int xp);

  /// No description provided for @aura_next_rank.
  ///
  /// In en, this message translates to:
  /// **'{pct}% to next rank'**
  String aura_next_rank(int pct);

  /// No description provided for @aura_rank_mismatch.
  ///
  /// In en, this message translates to:
  /// **'⚠ RANK INCONSISTENT WITH CEFR'**
  String get aura_rank_mismatch;

  /// No description provided for @daily_reward_title.
  ///
  /// In en, this message translates to:
  /// **'DAILY REWARD'**
  String get daily_reward_title;

  /// No description provided for @daily_reward_streak.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STREAK: {streak} DAYS'**
  String daily_reward_streak(int streak);

  /// No description provided for @daily_reward_gems.
  ///
  /// In en, this message translates to:
  /// **'{gems} GEMS'**
  String daily_reward_gems(int gems);

  /// No description provided for @daily_reward_by_streak.
  ///
  /// In en, this message translates to:
  /// **'BY STREAK'**
  String get daily_reward_by_streak;

  /// No description provided for @daily_reward_parchments.
  ///
  /// In en, this message translates to:
  /// **'+{count} SCROLLS'**
  String daily_reward_parchments(int count);

  /// No description provided for @daily_reward_cap.
  ///
  /// In en, this message translates to:
  /// **'DAILY CAP'**
  String get daily_reward_cap;

  /// No description provided for @daily_reward_keep_streak.
  ///
  /// In en, this message translates to:
  /// **'KEEP YOUR STREAK: AT 7 DAYS YOU EARN 50 GEMS AND 5 SCROLLS'**
  String get daily_reward_keep_streak;

  /// No description provided for @daily_reward_at_14.
  ///
  /// In en, this message translates to:
  /// **'AT 14 DAYS: 100 GEMS AND 8 SCROLLS'**
  String get daily_reward_at_14;

  /// No description provided for @daily_reward_at_30.
  ///
  /// In en, this message translates to:
  /// **'AT 30 DAYS: 300 GEMS AND 15 SCROLLS'**
  String get daily_reward_at_30;

  /// No description provided for @daily_reward_max_streak.
  ///
  /// In en, this message translates to:
  /// **'MAX STREAK REACHED!'**
  String get daily_reward_max_streak;

  /// No description provided for @claiming.
  ///
  /// In en, this message translates to:
  /// **'CLAIMING...'**
  String get claiming;

  /// No description provided for @daily_reward_claimed_today.
  ///
  /// In en, this message translates to:
  /// **'DAILY REWARD CLAIMED TODAY'**
  String get daily_reward_claimed_today;

  /// No description provided for @daily_reward_claim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM REWARD'**
  String get daily_reward_claim;

  /// No description provided for @no_mana.
  ///
  /// In en, this message translates to:
  /// **'NO MANA'**
  String get no_mana;

  /// No description provided for @mana_exhausted_desc.
  ///
  /// In en, this message translates to:
  /// **'Every AI action costs mana. Your balance ran out.\n\nMana is acquired with your plan or potions/gems.\n{renew}'**
  String mana_exhausted_desc(String renew);

  /// No description provided for @mana_renews_on.
  ///
  /// In en, this message translates to:
  /// **'Your cycle renews on {date}.'**
  String mana_renews_on(String date);

  /// No description provided for @more_mana_monthly.
  ///
  /// In en, this message translates to:
  /// **'MORE MONTHLY MANA BY RANK'**
  String get more_mana_monthly;

  /// No description provided for @wait_plan_renewal.
  ///
  /// In en, this message translates to:
  /// **'Wait for my plan renewal'**
  String get wait_plan_renewal;

  /// No description provided for @hunter_collections.
  ///
  /// In en, this message translates to:
  /// **'HUNTER COLLECTIONS'**
  String get hunter_collections;

  /// No description provided for @no_trophies.
  ///
  /// In en, this message translates to:
  /// **'NO TROPHIES RECORDED'**
  String get no_trophies;

  /// No description provided for @confirm_purchase.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PURCHASE'**
  String get confirm_purchase;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @cosmetic_purchased.
  ///
  /// In en, this message translates to:
  /// **'COSMETIC ACQUIRED! 🪙'**
  String get cosmetic_purchased;

  /// No description provided for @gold_insufficient.
  ///
  /// In en, this message translates to:
  /// **'INSUFFICIENT GOLD OR ALREADY OWNED ❌'**
  String get gold_insufficient;

  /// No description provided for @cosmetic_title.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get cosmetic_title;

  /// No description provided for @cosmetic_frame.
  ///
  /// In en, this message translates to:
  /// **'FRAME'**
  String get cosmetic_frame;

  /// No description provided for @cosmetic_aura.
  ///
  /// In en, this message translates to:
  /// **'AURA'**
  String get cosmetic_aura;

  /// No description provided for @cosmetic_pet.
  ///
  /// In en, this message translates to:
  /// **'COMPANION'**
  String get cosmetic_pet;

  /// No description provided for @cosmetic_emote.
  ///
  /// In en, this message translates to:
  /// **'EMOTE'**
  String get cosmetic_emote;

  /// No description provided for @cosmetic_theme.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get cosmetic_theme;

  /// No description provided for @arcane_shop.
  ///
  /// In en, this message translates to:
  /// **'ARCANE SHOP'**
  String get arcane_shop;

  /// No description provided for @gold_shop_tab.
  ///
  /// In en, this message translates to:
  /// **'GOLD SHOP'**
  String get gold_shop_tab;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'REDEEM'**
  String get redeem;

  /// No description provided for @my_items.
  ///
  /// In en, this message translates to:
  /// **'MY ITEMS'**
  String get my_items;

  /// No description provided for @mana_potions_title.
  ///
  /// In en, this message translates to:
  /// **'MANA POTIONS'**
  String get mana_potions_title;

  /// No description provided for @mana_potions_desc.
  ///
  /// In en, this message translates to:
  /// **'Mana is the energy of every AI action. It is acquired with real money: your rank includes a monthly allowance and potions extend it.'**
  String get mana_potions_desc;

  /// No description provided for @mana_gems_packs_title.
  ///
  /// In en, this message translates to:
  /// **'MANA GEM PACKS'**
  String get mana_gems_packs_title;

  /// No description provided for @gold_shop_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The Gold Shop is not available yet.\nPlease try again in a moment.'**
  String get gold_shop_unavailable;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'OWNED'**
  String get owned;

  /// No description provided for @price_gold.
  ///
  /// In en, this message translates to:
  /// **'{price} GOLD'**
  String price_gold(String price);

  /// No description provided for @fragments_insufficient.
  ///
  /// In en, this message translates to:
  /// **'INSUFFICIENT FRAGMENTS ❌'**
  String get fragments_insufficient;

  /// No description provided for @redeem_error.
  ///
  /// In en, this message translates to:
  /// **'EXCHANGE ERROR ❌'**
  String get redeem_error;

  /// No description provided for @fragments_exchange_title.
  ///
  /// In en, this message translates to:
  /// **'FRAGMENT EXCHANGE'**
  String get fragments_exchange_title;

  /// No description provided for @fragments_exchange_desc.
  ///
  /// In en, this message translates to:
  /// **'FRAGMENTS ARE THE EXCHANGE CURRENCY. CHOOSE WISELY, HUNTER.'**
  String get fragments_exchange_desc;

  /// No description provided for @battle_reward_claimed_tier.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier} REWARD CLAIMED'**
  String battle_reward_claimed_tier(int tier);

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'NOT AVAILABLE'**
  String get not_available;

  /// No description provided for @battle_pass.
  ///
  /// In en, this message translates to:
  /// **'BATTLE PASS'**
  String get battle_pass;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @free_tier.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free_tier;

  /// No description provided for @battle_level.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String battle_level(int level);

  /// No description provided for @battle_progress_label.
  ///
  /// In en, this message translates to:
  /// **'Battle Pass progress: '**
  String get battle_progress_label;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'REWARDS'**
  String get rewards;

  /// No description provided for @reward_claimed_tier.
  ///
  /// In en, this message translates to:
  /// **'Reward level {tier} claimed'**
  String reward_claimed_tier(int tier);

  /// No description provided for @reward_unlocked_tier.
  ///
  /// In en, this message translates to:
  /// **'Reward level {tier} unlocked'**
  String reward_unlocked_tier(int tier);

  /// No description provided for @reward_locked_tier.
  ///
  /// In en, this message translates to:
  /// **'Reward level {tier} locked, unlock at level {tier}'**
  String reward_locked_tier(int tier);

  /// No description provided for @battle_tier.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier}'**
  String battle_tier(int tier);

  /// No description provided for @reward_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Reward unlocked'**
  String get reward_unlocked;

  /// No description provided for @unlock_at_level.
  ///
  /// In en, this message translates to:
  /// **'Unlock at level {tier}'**
  String unlock_at_level(int tier);

  /// No description provided for @battle_claim_reward.
  ///
  /// In en, this message translates to:
  /// **'Claim level {tier} reward'**
  String battle_claim_reward(int tier);

  /// No description provided for @equipment_updated.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT UPDATED'**
  String get equipment_updated;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY'**
  String get inventory;

  /// No description provided for @unequip.
  ///
  /// In en, this message translates to:
  /// **'UNEQUIP'**
  String get unequip;

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get equip;

  /// No description provided for @chat_category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chat_category_all;

  /// No description provided for @chat_cat_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get chat_cat_general;

  /// No description provided for @chat_cat_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get chat_cat_travel;

  /// No description provided for @chat_cat_business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get chat_cat_business;

  /// No description provided for @chat_cat_technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get chat_cat_technology;

  /// No description provided for @chat_cat_art.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get chat_cat_art;

  /// No description provided for @chat_cat_cooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get chat_cat_cooking;

  /// No description provided for @chat_rank_status.
  ///
  /// In en, this message translates to:
  /// **'RANK STATUS'**
  String get chat_rank_status;

  /// No description provided for @chat_hunter_details.
  ///
  /// In en, this message translates to:
  /// **'HUNTER DETAILS'**
  String get chat_hunter_details;

  /// No description provided for @chat_rank_level.
  ///
  /// In en, this message translates to:
  /// **'RANK {code}'**
  String chat_rank_level(String code);

  /// No description provided for @chat_establish_table.
  ///
  /// In en, this message translates to:
  /// **'ESTABLISH GUILD TABLE'**
  String get chat_establish_table;

  /// No description provided for @chat_create_room.
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW CHAT ROOM'**
  String get chat_create_room;

  /// No description provided for @chat_table_title.
  ///
  /// In en, this message translates to:
  /// **'GUILD TABLE TITLE'**
  String get chat_table_title;

  /// No description provided for @chat_category_path.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY PATH'**
  String get chat_category_path;

  /// No description provided for @chat_table_type.
  ///
  /// In en, this message translates to:
  /// **'TABLE TYPE'**
  String get chat_table_type;

  /// No description provided for @chat_missions.
  ///
  /// In en, this message translates to:
  /// **'MISSIONS'**
  String get chat_missions;

  /// No description provided for @chat_guild_pass.
  ///
  /// In en, this message translates to:
  /// **'GUILD PASS'**
  String get chat_guild_pass;

  /// No description provided for @chat_rank.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get chat_rank;

  /// No description provided for @chat_collections.
  ///
  /// In en, this message translates to:
  /// **'COLLECTIONS'**
  String get chat_collections;

  /// No description provided for @chat_music_on.
  ///
  /// In en, this message translates to:
  /// **'MUSIC ON'**
  String get chat_music_on;

  /// No description provided for @chat_music.
  ///
  /// In en, this message translates to:
  /// **'MUSIC'**
  String get chat_music;

  /// No description provided for @chat_status_full.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get chat_status_full;

  /// No description provided for @chat_status_nearly_full.
  ///
  /// In en, this message translates to:
  /// **'NEARLY FULL'**
  String get chat_status_nearly_full;

  /// No description provided for @chat_status_occupied.
  ///
  /// In en, this message translates to:
  /// **'OCCUPIED'**
  String get chat_status_occupied;

  /// No description provided for @chat_status_space.
  ///
  /// In en, this message translates to:
  /// **'SPACE'**
  String get chat_status_space;

  /// No description provided for @chat_type_mentorship.
  ///
  /// In en, this message translates to:
  /// **'MENTORSHIP'**
  String get chat_type_mentorship;

  /// No description provided for @chat_type_ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get chat_type_ai;

  /// No description provided for @chat_type_event.
  ///
  /// In en, this message translates to:
  /// **'EVENT'**
  String get chat_type_event;

  /// No description provided for @chat_rank_line.
  ///
  /// In en, this message translates to:
  /// **'RANK: {rank} · {cefr}'**
  String chat_rank_line(String rank, String cefr);

  /// No description provided for @chat_free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get chat_free;

  /// No description provided for @chat_rank_silver.
  ///
  /// In en, this message translates to:
  /// **'SILVER'**
  String get chat_rank_silver;

  /// No description provided for @chat_rank_gold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get chat_rank_gold;

  /// No description provided for @chat_rank_iron.
  ///
  /// In en, this message translates to:
  /// **'IRON'**
  String get chat_rank_iron;

  /// No description provided for @voice_seat_to_speak.
  ///
  /// In en, this message translates to:
  /// **'SIT DOWN TO SPEAK'**
  String get voice_seat_to_speak;

  /// No description provided for @voice_seated_in.
  ///
  /// In en, this message translates to:
  /// **'YOU SAT IN SEAT {seat}'**
  String voice_seated_in(String seat);

  /// No description provided for @voice_seat_assigned.
  ///
  /// In en, this message translates to:
  /// **'SEAT ASSIGNED. Welcome!'**
  String get voice_seat_assigned;

  /// No description provided for @voice_seats_full_queue.
  ///
  /// In en, this message translates to:
  /// **'SEATS FULL: YOU ENTER THE QUEUE'**
  String get voice_seats_full_queue;

  /// No description provided for @voice_seat_freed.
  ///
  /// In en, this message translates to:
  /// **'SEAT FREED. STANDING'**
  String get voice_seat_freed;

  /// No description provided for @voice_standing.
  ///
  /// In en, this message translates to:
  /// **'HUNTER STANDING UP'**
  String get voice_standing;

  /// No description provided for @voice_not_moderator.
  ///
  /// In en, this message translates to:
  /// **'YOU ARE NOT THE MODERATOR OF THIS TABLE'**
  String get voice_not_moderator;

  /// No description provided for @voice_chamber_chat.
  ///
  /// In en, this message translates to:
  /// **'CHAMBER TEXT CHAT'**
  String get voice_chamber_chat;

  /// No description provided for @voice_free_mission.
  ///
  /// In en, this message translates to:
  /// **'FREE MISSION'**
  String get voice_free_mission;

  /// No description provided for @voice_guild_chamber.
  ///
  /// In en, this message translates to:
  /// **'GUILD VOICE CHAMBER'**
  String get voice_guild_chamber;

  /// No description provided for @voice_moderated.
  ///
  /// In en, this message translates to:
  /// **'Guild voice room'**
  String get voice_moderated;

  /// No description provided for @voice_leave.
  ///
  /// In en, this message translates to:
  /// **'Leave the room'**
  String get voice_leave;

  /// No description provided for @voice_demo_banner.
  ///
  /// In en, this message translates to:
  /// **'GUILD AUDIO: DEMO — hunters connected live. Voice practice is 1:1.'**
  String get voice_demo_banner;

  /// No description provided for @voice_demo_banner_alt.
  ///
  /// In en, this message translates to:
  /// **'AUDIO DEMO — TAP FOR DETAILS'**
  String get voice_demo_banner_alt;

  /// No description provided for @voice_room_mission.
  ///
  /// In en, this message translates to:
  /// **'ROOM MISSION'**
  String get voice_room_mission;

  /// No description provided for @voice_resonance.
  ///
  /// In en, this message translates to:
  /// **'RESONANCE'**
  String get voice_resonance;

  /// No description provided for @voice_your_seat.
  ///
  /// In en, this message translates to:
  /// **'YOUR SEAT'**
  String get voice_your_seat;

  /// No description provided for @voice_seat_number.
  ///
  /// In en, this message translates to:
  /// **'SEAT {slot}'**
  String voice_seat_number(String slot);

  /// No description provided for @voice_tap_to_sit.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SIT'**
  String get voice_tap_to_sit;

  /// No description provided for @voice_you.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get voice_you;

  /// No description provided for @voice_hunter_slot.
  ///
  /// In en, this message translates to:
  /// **'HUNTER {slot}'**
  String voice_hunter_slot(String slot);

  /// No description provided for @voice_speaking.
  ///
  /// In en, this message translates to:
  /// **'SPEAKING'**
  String get voice_speaking;

  /// No description provided for @voice_seated.
  ///
  /// In en, this message translates to:
  /// **'SEATED'**
  String get voice_seated;

  /// No description provided for @voice_standing_count.
  ///
  /// In en, this message translates to:
  /// **'STANDING ({count}/8)'**
  String voice_standing_count(int count);

  /// No description provided for @voice_you_standing.
  ///
  /// In en, this message translates to:
  /// **'You (standing)'**
  String get voice_you_standing;

  /// No description provided for @voice_standing_hunter.
  ///
  /// In en, this message translates to:
  /// **'Standing hunter'**
  String get voice_standing_hunter;

  /// No description provided for @voice_chat_title.
  ///
  /// In en, this message translates to:
  /// **'Chamber Text Chat ({count})'**
  String voice_chat_title(int count);

  /// No description provided for @voice_mic_on.
  ///
  /// In en, this message translates to:
  /// **'MIC ON'**
  String get voice_mic_on;

  /// No description provided for @voice_mic_off.
  ///
  /// In en, this message translates to:
  /// **'MIC OFF'**
  String get voice_mic_off;

  /// No description provided for @voice_stand_up.
  ///
  /// In en, this message translates to:
  /// **'STAND UP'**
  String get voice_stand_up;

  /// No description provided for @voice_in_queue.
  ///
  /// In en, this message translates to:
  /// **'IN QUEUE #{pos}'**
  String voice_in_queue(int pos);

  /// No description provided for @voice_seat.
  ///
  /// In en, this message translates to:
  /// **'SEAT'**
  String get voice_seat;

  /// No description provided for @voice_exit.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get voice_exit;

  /// No description provided for @guild_rec_beginner.
  ///
  /// In en, this message translates to:
  /// **'I recommend the Apprentice Tavern: the perfect table for novice hunters.'**
  String get guild_rec_beginner;

  /// No description provided for @guild_rec_intermediate.
  ///
  /// In en, this message translates to:
  /// **'The Tactics Round Table awaits: debates and intermediate fluency.'**
  String get guild_rec_intermediate;

  /// No description provided for @guild_rec_master.
  ///
  /// In en, this message translates to:
  /// **'The Supreme Council of High Hunters is your place: master-level eloquence.'**
  String get guild_rec_master;

  /// No description provided for @guild_rec_default.
  ///
  /// In en, this message translates to:
  /// **'Choose a table and start your conversation raid.'**
  String get guild_rec_default;

  /// No description provided for @guild_table_beginner.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get guild_table_beginner;

  /// No description provided for @guild_table_tactics.
  ///
  /// In en, this message translates to:
  /// **'Tactics'**
  String get guild_table_tactics;

  /// No description provided for @guild_table_council.
  ///
  /// In en, this message translates to:
  /// **'Council'**
  String get guild_table_council;

  /// No description provided for @guild_rank_level.
  ///
  /// In en, this message translates to:
  /// **'RANK {cefr}'**
  String guild_rank_level(String cefr);

  /// No description provided for @guild_follow_suggestion.
  ///
  /// In en, this message translates to:
  /// **'FOLLOW MY SUGGESTION —>'**
  String get guild_follow_suggestion;

  /// No description provided for @guild_ask_master.
  ///
  /// In en, this message translates to:
  /// **'Ask the Master (Level {cefr}):'**
  String guild_ask_master(String cefr);

  /// No description provided for @guild_ask_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask me which table to practice, which mission to take or how to improve your rank.'**
  String get guild_ask_hint;

  /// No description provided for @guild_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your question...'**
  String get guild_input_hint;

  /// No description provided for @guild_meditating.
  ///
  /// In en, this message translates to:
  /// **'The Table Master is meditating... Try again.'**
  String get guild_meditating;

  /// No description provided for @mission_board_title.
  ///
  /// In en, this message translates to:
  /// **'MISSION BOARD'**
  String get mission_board_title;

  /// No description provided for @mission_board_player_rank.
  ///
  /// In en, this message translates to:
  /// **'ADVENTURER · RANK {playerRank}'**
  String mission_board_player_rank(String playerRank);

  /// No description provided for @mission_completed_active.
  ///
  /// In en, this message translates to:
  /// **'✓ COMPLETED'**
  String get mission_completed_active;

  /// No description provided for @mission_completed.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get mission_completed;

  /// No description provided for @mission_filter_all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get mission_filter_all;

  /// No description provided for @mission_filter_daily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get mission_filter_daily;

  /// No description provided for @mission_filter_weekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get mission_filter_weekly;

  /// No description provided for @mission_filter_collaborative.
  ///
  /// In en, this message translates to:
  /// **'COLLABORATIVE'**
  String get mission_filter_collaborative;

  /// No description provided for @mission_filter_rarity_all.
  ///
  /// In en, this message translates to:
  /// **'RARITY: ALL'**
  String get mission_filter_rarity_all;

  /// No description provided for @mission_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search mission by name...'**
  String get mission_search_hint;

  /// No description provided for @mission_board_empty_filtered.
  ///
  /// In en, this message translates to:
  /// **'No guild missions match these filters.'**
  String get mission_board_empty_filtered;

  /// No description provided for @mission_view_more.
  ///
  /// In en, this message translates to:
  /// **'VIEW MORE MISSIONS ({count} remaining)'**
  String mission_view_more(int count);

  /// No description provided for @mission_completed_empty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed any guild missions yet.'**
  String get mission_completed_empty;

  /// No description provided for @mission_login_required.
  ///
  /// In en, this message translates to:
  /// **'Log in to accept missions.'**
  String get mission_login_required;

  /// No description provided for @mission_insufficient_rank.
  ///
  /// In en, this message translates to:
  /// **'🔒 INSUFFICIENT RANK: you need rank {rank}.'**
  String mission_insufficient_rank(String rank);

  /// No description provided for @mission_accept_success.
  ///
  /// In en, this message translates to:
  /// **'✅ Mission accepted: {title}'**
  String mission_accept_success(String title);

  /// No description provided for @mission_accept_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not accept (quota full or insufficient rank).'**
  String get mission_accept_failed;

  /// No description provided for @mission_high_rank_title.
  ///
  /// In en, this message translates to:
  /// **'HIGH RANK MISSION'**
  String get mission_high_rank_title;

  /// No description provided for @mission_high_rank_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to undertake \"{title}\" (rank {rank})? It is an elite guild mission.'**
  String mission_high_rank_confirm(String title, String rank);

  /// No description provided for @mission_reward_earned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP  ·  +{gems} 💎'**
  String mission_reward_earned(int xp, int gems);

  /// No description provided for @mission_claim_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not claim the reward.'**
  String get mission_claim_failed;

  /// No description provided for @mission_npc_collaborative.
  ///
  /// In en, this message translates to:
  /// **'Table Master · Guild'**
  String get mission_npc_collaborative;

  /// No description provided for @mission_npc_vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Guild Librarian'**
  String get mission_npc_vocabulary;

  /// No description provided for @mission_npc_writing.
  ///
  /// In en, this message translates to:
  /// **'Royal Scribe'**
  String get mission_npc_writing;

  /// No description provided for @mission_npc_argumentation.
  ///
  /// In en, this message translates to:
  /// **'Debate Consul'**
  String get mission_npc_argumentation;

  /// No description provided for @mission_npc_default.
  ///
  /// In en, this message translates to:
  /// **'Table Master'**
  String get mission_npc_default;

  /// No description provided for @mission_difficulty_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get mission_difficulty_unknown;

  /// No description provided for @mission_difficulty_label.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String mission_difficulty_label(String rank);

  /// No description provided for @mission_time_daily.
  ///
  /// In en, this message translates to:
  /// **'~10-15 min'**
  String get mission_time_daily;

  /// No description provided for @mission_time_weekly.
  ///
  /// In en, this message translates to:
  /// **'~45-60 min'**
  String get mission_time_weekly;

  /// No description provided for @mission_time_collaborative.
  ///
  /// In en, this message translates to:
  /// **'~30 min'**
  String get mission_time_collaborative;

  /// No description provided for @mission_time_default.
  ///
  /// In en, this message translates to:
  /// **'~20 min'**
  String get mission_time_default;

  /// No description provided for @mission_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load the mission.'**
  String get mission_load_error;

  /// No description provided for @mission_not_found.
  ///
  /// In en, this message translates to:
  /// **'Mission not found.'**
  String get mission_not_found;

  /// No description provided for @mission_detail_title.
  ///
  /// In en, this message translates to:
  /// **'MISSION DETAIL'**
  String get mission_detail_title;

  /// No description provided for @mission_rarity_type_label.
  ///
  /// In en, this message translates to:
  /// **'{rarity} · {type}'**
  String mission_rarity_type_label(String rarity, String type);

  /// No description provided for @mission_section_description.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get mission_section_description;

  /// No description provided for @mission_npc_label.
  ///
  /// In en, this message translates to:
  /// **'NPC'**
  String get mission_npc_label;

  /// No description provided for @mission_stat_level.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get mission_stat_level;

  /// No description provided for @mission_stat_xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get mission_stat_xp;

  /// No description provided for @mission_stat_gold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get mission_stat_gold;

  /// No description provided for @mission_stat_time.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get mission_stat_time;

  /// No description provided for @mission_stat_objective.
  ///
  /// In en, this message translates to:
  /// **'OBJECTIVE'**
  String get mission_stat_objective;

  /// No description provided for @mission_section_objectives.
  ///
  /// In en, this message translates to:
  /// **'OBJECTIVES'**
  String get mission_section_objectives;

  /// No description provided for @mission_objectives_goal.
  ///
  /// In en, this message translates to:
  /// **'Complete {target} of {objectiveType}.'**
  String mission_objectives_goal(int target, String objectiveType);

  /// No description provided for @mission_claiming.
  ///
  /// In en, this message translates to:
  /// **'CLAIMING...'**
  String get mission_claiming;

  /// No description provided for @mission_in_progress_chat.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS · GO TO CHAT'**
  String get mission_in_progress_chat;

  /// No description provided for @mission_reject.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get mission_reject;

  /// No description provided for @mission_rank_required.
  ///
  /// In en, this message translates to:
  /// **'RANK {rank} REQUIRED'**
  String mission_rank_required(String rank);

  /// No description provided for @mission_rarity_common.
  ///
  /// In en, this message translates to:
  /// **'COMMON'**
  String get mission_rarity_common;

  /// No description provided for @mission_rarity_uncommon.
  ///
  /// In en, this message translates to:
  /// **'UNCOMMON'**
  String get mission_rarity_uncommon;

  /// No description provided for @mission_rarity_rare.
  ///
  /// In en, this message translates to:
  /// **'RARE'**
  String get mission_rarity_rare;

  /// No description provided for @mission_rarity_epic.
  ///
  /// In en, this message translates to:
  /// **'EPIC'**
  String get mission_rarity_epic;

  /// No description provided for @mission_rarity_legendary.
  ///
  /// In en, this message translates to:
  /// **'LEGENDARY'**
  String get mission_rarity_legendary;

  /// No description provided for @mission_rarity_guild.
  ///
  /// In en, this message translates to:
  /// **'GUILD SPECIAL'**
  String get mission_rarity_guild;

  /// No description provided for @mission_status_available.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get mission_status_available;

  /// No description provided for @mission_status_accepted.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get mission_status_accepted;

  /// No description provided for @mission_status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get mission_status_in_progress;

  /// No description provided for @mission_status_completed.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get mission_status_completed;

  /// No description provided for @mission_status_repeatable.
  ///
  /// In en, this message translates to:
  /// **'REPEATABLE'**
  String get mission_status_repeatable;

  /// No description provided for @mission_status_blocked.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED'**
  String get mission_status_blocked;

  /// No description provided for @mission_status_recommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get mission_status_recommended;

  /// No description provided for @mission_status_special.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL'**
  String get mission_status_special;

  /// Title of the post-session summary screen
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get session_title;

  /// No description provided for @summary_reward_gold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get summary_reward_gold;

  /// No description provided for @summary_reward_fragments.
  ///
  /// In en, this message translates to:
  /// **'FRAGMENTS'**
  String get summary_reward_fragments;

  /// No description provided for @summary_reward_pending.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your reward. Your progress is saved; it will refresh on the next load.'**
  String get summary_reward_pending;

  /// No description provided for @session_completed.
  ///
  /// In en, this message translates to:
  /// **'SESSION COMPLETED'**
  String get session_completed;

  /// No description provided for @session_good_job.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get session_good_job;

  /// No description provided for @session_words_spoken.
  ///
  /// In en, this message translates to:
  /// **'You spoke {count} words with good pacing.'**
  String session_words_spoken(int count);

  /// No description provided for @summary_remedial_title.
  ///
  /// In en, this message translates to:
  /// **'REINFORCEMENT'**
  String get summary_remedial_title;

  /// No description provided for @summary_remedial_generated.
  ///
  /// In en, this message translates to:
  /// **'We built a lesson from your recurring mistakes and the goals you missed.'**
  String get summary_remedial_generated;

  /// No description provided for @summary_remedial_reused.
  ///
  /// In en, this message translates to:
  /// **'Your reinforcement lesson is ready.'**
  String get summary_remedial_reused;

  /// No description provided for @summary_remedial_play.
  ///
  /// In en, this message translates to:
  /// **'PRACTICE MY WEAKNESSES'**
  String get summary_remedial_play;

  /// No description provided for @summary_remedial_no_evidence.
  ///
  /// In en, this message translates to:
  /// **'No reinforcement lesson yet: we need your recorded mistakes or a missed goal to aim it.'**
  String get summary_remedial_no_evidence;

  /// No description provided for @summary_remedial_insufficient_mana.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough mana for a reinforcement lesson. It will be available once your balance renews.'**
  String get summary_remedial_insufficient_mana;

  /// No description provided for @summary_remedial_failed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create the reinforcement lesson. Your mana was refunded.'**
  String get summary_remedial_failed;

  /// No description provided for @summary_remedial_cost.
  ///
  /// In en, this message translates to:
  /// **'Cost: {cost} mana'**
  String summary_remedial_cost(int cost);

  /// No description provided for @summary_remedial_retry.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get summary_remedial_retry;

  /// No description provided for @session_ready.
  ///
  /// In en, this message translates to:
  /// **'Practice ready to start.'**
  String get session_ready;

  /// No description provided for @session_excellent_performance.
  ///
  /// In en, this message translates to:
  /// **'Excellent performance!'**
  String get session_excellent_performance;

  /// No description provided for @session_ready_first.
  ///
  /// In en, this message translates to:
  /// **'Ready for your first session!'**
  String get session_ready_first;

  /// No description provided for @session_duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get session_duration;

  /// No description provided for @session_words.
  ///
  /// In en, this message translates to:
  /// **'WORDS'**
  String get session_words;

  /// No description provided for @session_accuracy.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY (EST.)'**
  String get session_accuracy;

  /// No description provided for @session_fluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency (est.)'**
  String get session_fluency;

  /// No description provided for @session_pronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get session_pronunciation;

  /// No description provided for @session_feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get session_feedback;

  /// No description provided for @session_no_errors.
  ///
  /// In en, this message translates to:
  /// **'No grammar or phonetics errors were recorded.'**
  String get session_no_errors;

  /// No description provided for @session_talk_tutor.
  ///
  /// In en, this message translates to:
  /// **'Talk with the AI tutor to get feedback.'**
  String get session_talk_tutor;

  /// No description provided for @session_performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get session_performance;

  /// No description provided for @session_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get session_excellent;

  /// No description provided for @session_correction.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get session_correction;

  /// No description provided for @session_grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get session_grammar;

  /// No description provided for @session_bonus.
  ///
  /// In en, this message translates to:
  /// **'Session Bonus'**
  String get session_bonus;

  /// No description provided for @session_maintained.
  ///
  /// In en, this message translates to:
  /// **'Maintained'**
  String get session_maintained;

  /// Section title of the post-session summary (issue #113)
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU LEARNED'**
  String get summary_learned_title;

  /// No description provided for @summary_learned_words.
  ///
  /// In en, this message translates to:
  /// **'NEW AND REVIEWED WORDS'**
  String get summary_learned_words;

  /// No description provided for @summary_learned_word_new.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get summary_learned_word_new;

  /// No description provided for @summary_learned_word_review.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get summary_learned_word_review;

  /// No description provided for @summary_learned_no_words.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary was recorded in this session yet.'**
  String get summary_learned_no_words;

  /// No description provided for @summary_learned_corrections.
  ///
  /// In en, this message translates to:
  /// **'CORRECTIONS'**
  String get summary_learned_corrections;

  /// No description provided for @summary_learned_no_corrections.
  ///
  /// In en, this message translates to:
  /// **'No corrections: you communicated clearly this time.'**
  String get summary_learned_no_corrections;

  /// No description provided for @summary_learned_focus.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED FOCUS'**
  String get summary_learned_focus;

  /// No description provided for @summary_learned_no_focus.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for a recommendation yet.'**
  String get summary_learned_no_focus;

  /// No description provided for @summary_learned_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your session data...'**
  String get summary_learned_loading;

  /// No description provided for @summary_learned_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load what you learned. Check your connection and try again.'**
  String get summary_learned_error;

  /// No description provided for @summary_learned_minutes_value.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String summary_learned_minutes_value(int count);

  /// No description provided for @summary_goals.
  ///
  /// In en, this message translates to:
  /// **'GOALS'**
  String get summary_goals;

  /// No description provided for @summary_turns.
  ///
  /// In en, this message translates to:
  /// **'TURNS'**
  String get summary_turns;

  /// No description provided for @summary_turns_value.
  ///
  /// In en, this message translates to:
  /// **'{count} turns'**
  String summary_turns_value(int count);

  /// No description provided for @summary_reward_loading.
  ///
  /// In en, this message translates to:
  /// **'Confirming your reward...'**
  String get summary_reward_loading;

  /// No description provided for @summary_reward_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm your reward. Check your connection and try again.'**
  String get summary_reward_error;

  /// No description provided for @summary_retry.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get summary_retry;

  /// No description provided for @summary_review_words.
  ///
  /// In en, this message translates to:
  /// **'REVIEW WORDS'**
  String get summary_review_words;

  /// No description provided for @profile_status_panel.
  ///
  /// In en, this message translates to:
  /// **'STATUS PANEL'**
  String get profile_status_panel;

  /// No description provided for @profile_hunter_window.
  ///
  /// In en, this message translates to:
  /// **'HUNTER STATUS WINDOW'**
  String get profile_hunter_window;

  /// No description provided for @profile_learning.
  ///
  /// In en, this message translates to:
  /// **'Learning {language} {emoji}'**
  String profile_learning(String language, String emoji);

  /// No description provided for @profile_weekly_minutes.
  ///
  /// In en, this message translates to:
  /// **'Weekly Practice Minutes'**
  String get profile_weekly_minutes;

  /// No description provided for @profile_vocab_learned.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Learned'**
  String get profile_vocab_learned;

  /// No description provided for @profile_explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get profile_explore;

  /// No description provided for @profile_learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get profile_learn;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @quest_daily_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Quests'**
  String get quest_daily_title;

  /// No description provided for @quest_claimed.
  ///
  /// In en, this message translates to:
  /// **'Reward claimed! +{xp} XP'**
  String quest_claimed(int xp);

  /// No description provided for @quest_empty.
  ///
  /// In en, this message translates to:
  /// **'No active daily quests right now.'**
  String get quest_empty;

  /// No description provided for @quest_speak_10min.
  ///
  /// In en, this message translates to:
  /// **'Speak 10 minutes of voice'**
  String get quest_speak_10min;

  /// No description provided for @quest_desc_session.
  ///
  /// In en, this message translates to:
  /// **'Complete a fluid conversational session'**
  String get quest_desc_session;

  /// No description provided for @quest_learn_5_words.
  ///
  /// In en, this message translates to:
  /// **'Learn 5 new words'**
  String get quest_learn_5_words;

  /// No description provided for @quest_desc_vocab.
  ///
  /// In en, this message translates to:
  /// **'Accumulate vocabulary in your calls'**
  String get quest_desc_vocab;

  /// No description provided for @quest_85_pronunciation.
  ///
  /// In en, this message translates to:
  /// **'Achieve >85% in Pronunciation'**
  String get quest_85_pronunciation;

  /// No description provided for @quest_desc_pronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pass a voice-print test'**
  String get quest_desc_pronunciation;

  /// No description provided for @missions_title.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missions_title;

  /// No description provided for @missions_tab_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get missions_tab_daily;

  /// No description provided for @missions_tab_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get missions_tab_weekly;

  /// No description provided for @missions_spotlight.
  ///
  /// In en, this message translates to:
  /// **'MISSION OF THE DAY'**
  String get missions_spotlight;

  /// No description provided for @missions_see_all.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL'**
  String get missions_see_all;

  /// No description provided for @missions_reset_hint.
  ///
  /// In en, this message translates to:
  /// **'Automatic renewal: 00:05 UTC'**
  String get missions_reset_hint;

  /// No description provided for @missions_empty_daily.
  ///
  /// In en, this message translates to:
  /// **'No daily missions yet. New ones arrive every day at 00:05 UTC.'**
  String get missions_empty_daily;

  /// No description provided for @missions_empty_weekly.
  ///
  /// In en, this message translates to:
  /// **'No weekly missions yet. They are assigned with the daily 00:05 UTC cycle.'**
  String get missions_empty_weekly;

  /// No description provided for @missions_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get missions_unavailable;

  /// No description provided for @missions_unavailable_hint.
  ///
  /// In en, this message translates to:
  /// **'This mission cannot be completed with the current tracking.'**
  String get missions_unavailable_hint;

  /// No description provided for @missions_claim_xp.
  ///
  /// In en, this message translates to:
  /// **'Claim +{xp} XP'**
  String missions_claim_xp(int xp);

  /// No description provided for @missions_claim_success.
  ///
  /// In en, this message translates to:
  /// **'Reward claimed: +{xp} XP · +{gems} gems'**
  String missions_claim_success(int xp, int gems);

  /// No description provided for @missions_claim_already.
  ///
  /// In en, this message translates to:
  /// **'You already claimed this reward.'**
  String get missions_claim_already;

  /// No description provided for @missions_claim_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t claim the reward. Check your connection and try again.'**
  String get missions_claim_error;

  /// No description provided for @missions_load_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your missions. Tap to retry.'**
  String get missions_load_error;

  /// No description provided for @missions_retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get missions_retry;

  /// No description provided for @missions_unit_minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get missions_unit_minutes;

  /// No description provided for @missions_unit_turns.
  ///
  /// In en, this message translates to:
  /// **'turns'**
  String get missions_unit_turns;

  /// No description provided for @missions_unit_words.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get missions_unit_words;

  /// No description provided for @missions_unit_sessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get missions_unit_sessions;

  /// No description provided for @league_level_title.
  ///
  /// In en, this message translates to:
  /// **'Level League'**
  String get league_level_title;

  /// No description provided for @league_you.
  ///
  /// In en, this message translates to:
  /// **'You (Student)'**
  String get league_you;

  /// No description provided for @league_ranking.
  ///
  /// In en, this message translates to:
  /// **'Ranking {league}'**
  String league_ranking(String league);

  /// No description provided for @league_top5.
  ///
  /// In en, this message translates to:
  /// **'Top 5 · Level {level}'**
  String league_top5(String level);

  /// No description provided for @recommended_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Discovery Hub'**
  String get recommended_title;

  /// No description provided for @recommended_desc.
  ///
  /// In en, this message translates to:
  /// **'Personalized lessons based on your level, interests and onboarding goals'**
  String get recommended_desc;

  /// No description provided for @recommended_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search lesson, role or topic...'**
  String get recommended_search_hint;

  /// No description provided for @recommended_cat_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recommended_cat_all;

  /// No description provided for @recommended_cat_tech.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get recommended_cat_tech;

  /// No description provided for @recommended_cat_business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get recommended_cat_business;

  /// No description provided for @recommended_cat_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get recommended_cat_travel;

  /// No description provided for @recommended_cat_social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get recommended_cat_social;

  /// No description provided for @recommended_cat_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get recommended_cat_food;

  /// No description provided for @recommended_all_levels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get recommended_all_levels;

  /// No description provided for @recommended_level.
  ///
  /// In en, this message translates to:
  /// **'Level {lvl}'**
  String recommended_level(String lvl);

  /// No description provided for @recommended_catalog.
  ///
  /// In en, this message translates to:
  /// **'Personalized Catalog ({count})'**
  String recommended_catalog(int count);

  /// No description provided for @recommended_suggested_level.
  ///
  /// In en, this message translates to:
  /// **'Suggested level: {cefr}'**
  String recommended_suggested_level(String cefr);

  /// No description provided for @recommended_hero_match.
  ///
  /// In en, this message translates to:
  /// **'100% match with your Career goal and interest in Technology'**
  String get recommended_hero_match;

  /// No description provided for @recommended_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter: {cefr}'**
  String recommended_filter(String cefr);

  /// No description provided for @recommended_empty.
  ///
  /// In en, this message translates to:
  /// **'No lessons found with the selected filters.'**
  String get recommended_empty;

  /// No description provided for @recommended_lesson_level.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String recommended_lesson_level(String level);

  /// No description provided for @recommended_locked_hint.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous lesson in your path to unlock.'**
  String get recommended_locked_hint;

  /// No description provided for @recommended_blocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get recommended_blocked;

  /// No description provided for @recommended_review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get recommended_review;

  /// No description provided for @recommended_speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get recommended_speak;

  /// No description provided for @path_roadmap_title.
  ///
  /// In en, this message translates to:
  /// **'DUNGEON MAP'**
  String get path_roadmap_title;

  /// No description provided for @path_stage_empty.
  ///
  /// In en, this message translates to:
  /// **'No lessons recorded for this stage yet.'**
  String get path_stage_empty;

  /// No description provided for @profile_edit_photo_ok.
  ///
  /// In en, this message translates to:
  /// **'PHOTO UPLOADED SUCCESSFULLY'**
  String get profile_edit_photo_ok;

  /// No description provided for @profile_edit_choose_photo.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE CUSTOM PHOTO PATH'**
  String get profile_edit_choose_photo;

  /// No description provided for @profile_edit_license_registry.
  ///
  /// In en, this message translates to:
  /// **'HUNTER LICENSE REGISTRY'**
  String get profile_edit_license_registry;

  /// No description provided for @profile_edit_hunter_name.
  ///
  /// In en, this message translates to:
  /// **'HUNTER NAME'**
  String get profile_edit_hunter_name;

  /// No description provided for @profile_edit_class_path.
  ///
  /// In en, this message translates to:
  /// **'CLASS PATH: {path}'**
  String profile_edit_class_path(String path);

  /// No description provided for @profile_edit_select_class.
  ///
  /// In en, this message translates to:
  /// **'SELECT CLASS PATH'**
  String get profile_edit_select_class;

  /// No description provided for @profile_edit_stat_allocation.
  ///
  /// In en, this message translates to:
  /// **'STAT POINTS ALLOCATION'**
  String get profile_edit_stat_allocation;

  /// No description provided for @profile_edit_stat_pool.
  ///
  /// In en, this message translates to:
  /// **'POOL: {points} PT'**
  String profile_edit_stat_pool(int points);

  /// No description provided for @profile_edit_full_name.
  ///
  /// In en, this message translates to:
  /// **'HUNTER FULL NAME'**
  String get profile_edit_full_name;

  /// No description provided for @profile_edit_name_empty.
  ///
  /// In en, this message translates to:
  /// **'NAME CANNOT BE EMPTY'**
  String get profile_edit_name_empty;

  /// No description provided for @profile_edit_memoir.
  ///
  /// In en, this message translates to:
  /// **'MEMOIR / OBJECTIVES'**
  String get profile_edit_memoir;

  /// No description provided for @profile_edit_license_updated.
  ///
  /// In en, this message translates to:
  /// **'LICENSE REGISTRY UPDATED SUCCESSFULLY'**
  String get profile_edit_license_updated;

  /// No description provided for @profile_edit_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE LICENSE REGISTRY'**
  String get profile_edit_save;

  /// No description provided for @profile_edit_class_warrior.
  ///
  /// In en, this message translates to:
  /// **'WARRIOR'**
  String get profile_edit_class_warrior;

  /// No description provided for @profile_edit_class_warrior_desc.
  ///
  /// In en, this message translates to:
  /// **'Physical strength & high defense'**
  String get profile_edit_class_warrior_desc;

  /// No description provided for @profile_edit_class_mage.
  ///
  /// In en, this message translates to:
  /// **'MAGE'**
  String get profile_edit_class_mage;

  /// No description provided for @profile_edit_class_mage_desc.
  ///
  /// In en, this message translates to:
  /// **'Spell casting & mana manipulation'**
  String get profile_edit_class_mage_desc;

  /// No description provided for @profile_edit_class_assassin.
  ///
  /// In en, this message translates to:
  /// **'ASSASSIN'**
  String get profile_edit_class_assassin;

  /// No description provided for @profile_edit_class_assassin_desc.
  ///
  /// In en, this message translates to:
  /// **'Stealth, speed & critical strikes'**
  String get profile_edit_class_assassin_desc;

  /// No description provided for @profile_edit_class_necromancer.
  ///
  /// In en, this message translates to:
  /// **'NECROMANCER'**
  String get profile_edit_class_necromancer;

  /// No description provided for @profile_edit_class_necromancer_desc.
  ///
  /// In en, this message translates to:
  /// **'Summoning the dead & dark magic'**
  String get profile_edit_class_necromancer_desc;

  /// No description provided for @profile_edit_class_priest.
  ///
  /// In en, this message translates to:
  /// **'PRIEST'**
  String get profile_edit_class_priest;

  /// No description provided for @profile_edit_class_priest_desc.
  ///
  /// In en, this message translates to:
  /// **'Healing, buffing & holy light'**
  String get profile_edit_class_priest_desc;

  /// No description provided for @profile_edit_stat_str_desc.
  ///
  /// In en, this message translates to:
  /// **'Strength & muscle power'**
  String get profile_edit_stat_str_desc;

  /// No description provided for @profile_edit_stat_int_desc.
  ///
  /// In en, this message translates to:
  /// **'Spellcasting & parsing speed'**
  String get profile_edit_stat_int_desc;

  /// No description provided for @profile_edit_stat_dex_desc.
  ///
  /// In en, this message translates to:
  /// **'Agility & response rhythm'**
  String get profile_edit_stat_dex_desc;

  /// No description provided for @profile_edit_stat_luk_desc.
  ///
  /// In en, this message translates to:
  /// **'Critical correction avoidance'**
  String get profile_edit_stat_luk_desc;

  /// No description provided for @convo_mission_guide.
  ///
  /// In en, this message translates to:
  /// **'Mission Guide and Context'**
  String get convo_mission_guide;

  /// No description provided for @convo_practice_title.
  ///
  /// In en, this message translates to:
  /// **'Conversation Practice'**
  String get convo_practice_title;

  /// No description provided for @convo_objective.
  ///
  /// In en, this message translates to:
  /// **'Objective: {objective}'**
  String convo_objective(String objective);

  /// No description provided for @convo_select_goals.
  ///
  /// In en, this message translates to:
  /// **'Select a lesson to see specific goals.'**
  String get convo_select_goals;

  /// No description provided for @convo_select_phrases.
  ///
  /// In en, this message translates to:
  /// **'Select a lesson to see suggested key phrases.'**
  String get convo_select_phrases;

  /// No description provided for @convo_voice_print.
  ///
  /// In en, this message translates to:
  /// **'Voice Print & Pronunciation'**
  String get convo_voice_print;

  /// No description provided for @convo_phonetic_clarity.
  ///
  /// In en, this message translates to:
  /// **'Phonetic Clarity'**
  String get convo_phonetic_clarity;

  /// No description provided for @convo_speech_speed.
  ///
  /// In en, this message translates to:
  /// **'Speech Speed'**
  String get convo_speech_speed;

  /// No description provided for @convo_words_spoken.
  ///
  /// In en, this message translates to:
  /// **'Words Spoken'**
  String get convo_words_spoken;

  /// No description provided for @convo_cefr_level.
  ///
  /// In en, this message translates to:
  /// **'CEFR Level'**
  String get convo_cefr_level;

  /// No description provided for @convo_hidden_chat.
  ///
  /// In en, this message translates to:
  /// **'Hidden Chat (4th/5th Star)'**
  String get convo_hidden_chat;

  /// No description provided for @convo_visible_chat.
  ///
  /// In en, this message translates to:
  /// **'Visible Chat'**
  String get convo_visible_chat;

  /// No description provided for @convo_write_mode.
  ///
  /// In en, this message translates to:
  /// **'Write Mode'**
  String get convo_write_mode;

  /// No description provided for @convo_voice_mode.
  ///
  /// In en, this message translates to:
  /// **'Voice Mode'**
  String get convo_voice_mode;

  /// No description provided for @convo_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your message in English...'**
  String get convo_input_hint;

  /// No description provided for @convo_continue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get convo_continue;

  /// No description provided for @convo_oracle_evaluating.
  ///
  /// In en, this message translates to:
  /// **'THE ORACLE IS EVALUATING YOUR CONVERSATION...'**
  String get convo_oracle_evaluating;

  /// No description provided for @convo_analyzing_level.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your communication level...'**
  String get convo_analyzing_level;

  /// No description provided for @convo_status_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get convo_status_listening;

  /// No description provided for @convo_status_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get convo_status_thinking;

  /// No description provided for @convo_status_speaking.
  ///
  /// In en, this message translates to:
  /// **'The tutor is speaking'**
  String get convo_status_speaking;

  /// No description provided for @convo_stop_tutor.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get convo_stop_tutor;

  /// No description provided for @convo_tts_title.
  ///
  /// In en, this message translates to:
  /// **'Tutor voice'**
  String get convo_tts_title;

  /// No description provided for @convo_tts_speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get convo_tts_speed;

  /// No description provided for @convo_tts_voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get convo_tts_voice;

  /// No description provided for @convo_tts_default_voice.
  ///
  /// In en, this message translates to:
  /// **'System voice'**
  String get convo_tts_default_voice;

  /// No description provided for @convo_tts_no_voices.
  ///
  /// In en, this message translates to:
  /// **'No English voices found. Install one in Android Settings > Languages.'**
  String get convo_tts_no_voices;

  /// No description provided for @convo_mic_denied_title.
  ///
  /// In en, this message translates to:
  /// **'Microphone blocked'**
  String get convo_mic_denied_title;

  /// No description provided for @convo_mic_denied_body.
  ///
  /// In en, this message translates to:
  /// **'Dungeon of English needs the microphone to hear you. Turn it on in Android settings, then come back.'**
  String get convo_mic_denied_body;

  /// No description provided for @convo_mic_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get convo_mic_open_settings;

  /// No description provided for @convo_mic_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get convo_mic_retry;

  /// No description provided for @convo_mic_manual_hint.
  ///
  /// In en, this message translates to:
  /// **'Open Settings > Apps > Dungeon of English > Permissions > Microphone.'**
  String get convo_mic_manual_hint;

  /// No description provided for @convo_help_title.
  ///
  /// In en, this message translates to:
  /// **'I need help'**
  String get convo_help_title;

  /// No description provided for @convo_help_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap a phrase to send it as your answer.'**
  String get convo_help_hint;

  /// No description provided for @convo_help_empty.
  ///
  /// In en, this message translates to:
  /// **'This scenario has no help phrases yet. Write your answer or change the topic.'**
  String get convo_help_empty;

  /// No description provided for @settings_system_config.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM CONFIG'**
  String get settings_system_config;

  /// No description provided for @settings_target_cefr.
  ///
  /// In en, this message translates to:
  /// **'TARGET LANGUAGE & CEFR LEVEL'**
  String get settings_target_cefr;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settings_language;

  /// No description provided for @settings_ai_parameters.
  ///
  /// In en, this message translates to:
  /// **'AI TUTOR PARAMETERS'**
  String get settings_ai_parameters;

  /// No description provided for @settings_audio_comms.
  ///
  /// In en, this message translates to:
  /// **'AUDIO & COMMUNICATIONS'**
  String get settings_audio_comms;

  /// No description provided for @settings_account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get settings_account;

  /// No description provided for @settings_export_data.
  ///
  /// In en, this message translates to:
  /// **'EXPORT MY DATA'**
  String get settings_export_data;

  /// No description provided for @settings_export_copied.
  ///
  /// In en, this message translates to:
  /// **'Your data was copied to the clipboard.'**
  String get settings_export_copied;

  /// No description provided for @settings_delete_account.
  ///
  /// In en, this message translates to:
  /// **'DELETE MY ACCOUNT'**
  String get settings_delete_account;

  /// No description provided for @settings_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settings_delete_confirm_title;

  /// No description provided for @settings_delete_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and progress. This cannot be undone.'**
  String get settings_delete_confirm_body;

  /// No description provided for @settings_aligned.
  ///
  /// In en, this message translates to:
  /// **'CONFIGURATION ALIGNED SUCCESSFULLY'**
  String get settings_aligned;

  /// No description provided for @settings_save.
  ///
  /// In en, this message translates to:
  /// **'SAVE CONFIGURATION'**
  String get settings_save;

  /// No description provided for @settings_target_language.
  ///
  /// In en, this message translates to:
  /// **'TARGET LANGUAGE'**
  String get settings_target_language;

  /// No description provided for @settings_cefr_practice.
  ///
  /// In en, this message translates to:
  /// **'CEFR PRACTICE LEVEL'**
  String get settings_cefr_practice;

  /// No description provided for @settings_logout_dungeon.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT OF DUNGEON'**
  String get settings_logout_dungeon;

  /// No description provided for @settings_select_path.
  ///
  /// In en, this message translates to:
  /// **'SELECT TARGET PATH'**
  String get settings_select_path;

  /// No description provided for @settings_select_cefr.
  ///
  /// In en, this message translates to:
  /// **'SELECT CEFR LEVEL PATH'**
  String get settings_select_cefr;

  /// No description provided for @settings_correction_scope.
  ///
  /// In en, this message translates to:
  /// **'AI CORRECTION SCOPE'**
  String get settings_correction_scope;

  /// No description provided for @settings_tutor_personality.
  ///
  /// In en, this message translates to:
  /// **'TUTOR PERSONALITY'**
  String get settings_tutor_personality;

  /// No description provided for @settings_correction_cadence.
  ///
  /// In en, this message translates to:
  /// **'CORRECTION CADENCE'**
  String get settings_correction_cadence;

  /// No description provided for @settings_quest_focus.
  ///
  /// In en, this message translates to:
  /// **'DAILY QUEST FOCUS'**
  String get settings_quest_focus;

  /// No description provided for @settings_sfx_channels.
  ///
  /// In en, this message translates to:
  /// **'AUDIO SFX CHANNELS'**
  String get settings_sfx_channels;

  /// No description provided for @settings_alerts.
  ///
  /// In en, this message translates to:
  /// **'DAILY ALERT EMISSIONS'**
  String get settings_alerts;

  /// No description provided for @settings_alert_time.
  ///
  /// In en, this message translates to:
  /// **'ALERTS DISPATCH TIME'**
  String get settings_alert_time;

  /// No description provided for @settings_select_correction.
  ///
  /// In en, this message translates to:
  /// **'SELECT CORRECTION LEVEL'**
  String get settings_select_correction;

  /// No description provided for @settings_select_personality.
  ///
  /// In en, this message translates to:
  /// **'SELECT TUTOR PERSONALITY'**
  String get settings_select_personality;

  /// No description provided for @settings_select_cadence.
  ///
  /// In en, this message translates to:
  /// **'SELECT CORRECTION CADENCE'**
  String get settings_select_cadence;

  /// No description provided for @settings_select_quest.
  ///
  /// In en, this message translates to:
  /// **'SELECT DAILY QUEST FOCUS'**
  String get settings_select_quest;

  /// No description provided for @settings_follow_device.
  ///
  /// In en, this message translates to:
  /// **'USE DEVICE LANGUAGE'**
  String get settings_follow_device;

  /// No description provided for @settings_force_onboarding.
  ///
  /// In en, this message translates to:
  /// **'Force Continuous Onboarding'**
  String get settings_force_onboarding;

  /// No description provided for @settings_dev_desc.
  ///
  /// In en, this message translates to:
  /// **'Developer mode. It does not block the app: it only affects onboarding when there is no profile yet. Use \"Reset history\" to test it again.'**
  String get settings_dev_desc;

  /// No description provided for @settings_profile_deleted.
  ///
  /// In en, this message translates to:
  /// **'Hunter profile deleted. Restarting...'**
  String get settings_profile_deleted;

  /// No description provided for @settings_reset_onboarding.
  ///
  /// In en, this message translates to:
  /// **'RESET ONBOARDING HISTORY'**
  String get settings_reset_onboarding;

  /// No description provided for @onboarding_device_lang.
  ///
  /// In en, this message translates to:
  /// **'We detected that your device uses {lang}. The app will be shown in that language.'**
  String onboarding_device_lang(String lang);

  /// No description provided for @privacy_title.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get privacy_title;

  /// No description provided for @privacy_body.
  ///
  /// In en, this message translates to:
  /// **'To correct your conversation, the app sends the AI your transcribed audio, your CEFR level and your native language. Your email, name and photo are not sent. You can export or delete your data from Settings.'**
  String get privacy_body;

  /// No description provided for @privacy_accept.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get privacy_accept;

  /// No description provided for @onboarding_privacy_link.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get onboarding_privacy_link;

  /// No description provided for @onboarding_beginner.
  ///
  /// In en, this message translates to:
  /// **'I AM AN ABSOLUTE BEGINNER (PRE-A1)'**
  String get onboarding_beginner;

  /// No description provided for @onboarding_beginner_desc.
  ///
  /// In en, this message translates to:
  /// **'I cannot form sentences yet: only loose words and minimal vocabulary. You will start in Fundamentals without an exam.'**
  String get onboarding_beginner_desc;

  /// No description provided for @hunter_equip_title.
  ///
  /// In en, this message translates to:
  /// **'EQUIP TITLE'**
  String get hunter_equip_title;

  /// No description provided for @hunter_skill_titles.
  ///
  /// In en, this message translates to:
  /// **'SKILL TITLES'**
  String get hunter_skill_titles;

  /// No description provided for @hunter_cefr_xp.
  ///
  /// In en, this message translates to:
  /// **'CEFR {code} · {xp} XP'**
  String hunter_cefr_xp(String code, int xp);

  /// No description provided for @hunter_equipped_title.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED TITLE'**
  String get hunter_equipped_title;

  /// No description provided for @hunter_equip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get hunter_equip;

  /// No description provided for @hunter_fluency_analysis.
  ///
  /// In en, this message translates to:
  /// **'FLUENCY ANALYSIS'**
  String get hunter_fluency_analysis;

  /// No description provided for @hunter_holographic_radar.
  ///
  /// In en, this message translates to:
  /// **'HOLOGRAPHIC RADAR'**
  String get hunter_holographic_radar;

  /// No description provided for @hunter_practice_consistency.
  ///
  /// In en, this message translates to:
  /// **'PRACTICE CONSISTENCY'**
  String get hunter_practice_consistency;

  /// No description provided for @hunter_points_pool.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE POINTS: {points}'**
  String hunter_points_pool(int points);

  /// No description provided for @hunter_str.
  ///
  /// In en, this message translates to:
  /// **'STR (STRENGTH)'**
  String get hunter_str;

  /// No description provided for @hunter_luk.
  ///
  /// In en, this message translates to:
  /// **'LUK (LUCK)'**
  String get hunter_luk;

  /// No description provided for @hunter_distribute_points.
  ///
  /// In en, this message translates to:
  /// **'DISTRIBUTE POINTS'**
  String get hunter_distribute_points;

  /// No description provided for @hunter_no_title.
  ///
  /// In en, this message translates to:
  /// **'NO TITLE'**
  String get hunter_no_title;

  /// No description provided for @hunter_max_level.
  ///
  /// In en, this message translates to:
  /// **'MAX LEVEL REACHED'**
  String get hunter_max_level;

  /// No description provided for @dungeon_choose_portal.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE A PORTAL ACCORDING TO YOUR RANK'**
  String get dungeon_choose_portal;

  /// No description provided for @dungeon_current_portal.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PORTAL — LEVEL {level}'**
  String dungeon_current_portal(String level);

  /// No description provided for @dungeon_level.
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String dungeon_level(Object level);

  /// No description provided for @progress_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get progress_edit_profile;

  /// No description provided for @progress_hunter_status.
  ///
  /// In en, this message translates to:
  /// **'Hunter Status'**
  String get progress_hunter_status;

  /// No description provided for @progress_streak_hint.
  ///
  /// In en, this message translates to:
  /// **'Practice today to keep your {streak} day streak {days}'**
  String progress_streak_hint(int streak, String days);

  /// No description provided for @progress_practice.
  ///
  /// In en, this message translates to:
  /// **'PRACTICE'**
  String get progress_practice;

  /// No description provided for @settings_haptics.
  ///
  /// In en, this message translates to:
  /// **'VIBRATION'**
  String get settings_haptics;

  /// No description provided for @settings_haptics_desc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on goal complete and level up'**
  String get settings_haptics_desc;

  /// No description provided for @settings_sounds.
  ///
  /// In en, this message translates to:
  /// **'SOUNDS'**
  String get settings_sounds;

  /// No description provided for @settings_sounds_desc.
  ///
  /// In en, this message translates to:
  /// **'System sound on celebrations'**
  String get settings_sounds_desc;

  /// No description provided for @welcome_back_title.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcome_back_title;

  /// No description provided for @welcome_back_days.
  ///
  /// In en, this message translates to:
  /// **'{days} days away'**
  String welcome_back_days(int days);

  /// No description provided for @welcome_back_lesson.
  ///
  /// In en, this message translates to:
  /// **'You left off at {lesson}'**
  String welcome_back_lesson(String lesson);

  /// No description provided for @welcome_back_goals.
  ///
  /// In en, this message translates to:
  /// **'{count} goals to go'**
  String welcome_back_goals(int count);

  /// No description provided for @welcome_back_completed.
  ///
  /// In en, this message translates to:
  /// **'You finished it. Replay it or pick the next one.'**
  String get welcome_back_completed;

  /// No description provided for @welcome_back_streak_reset.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start a new streak today.'**
  String get welcome_back_streak_reset;

  /// No description provided for @welcome_back_continue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get welcome_back_continue;

  /// No description provided for @welcome_back_later.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get welcome_back_later;

  /// No description provided for @radar_estimated_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Estimate based on your conversation'**
  String get radar_estimated_tooltip;

  /// No description provided for @radar_estimated_note.
  ///
  /// In en, this message translates to:
  /// **'Estimate based on your conversation'**
  String get radar_estimated_note;

  /// No description provided for @radar_pronunciation_unmeasured.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation: no real measurement yet'**
  String get radar_pronunciation_unmeasured;

  /// No description provided for @band_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get band_low;

  /// No description provided for @band_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get band_medium;

  /// No description provided for @band_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get band_high;

  /// No description provided for @mana_cost_per_turn.
  ///
  /// In en, this message translates to:
  /// **'{cost}/turn'**
  String mana_cost_per_turn(int cost);

  /// No description provided for @mana_low_warning.
  ///
  /// In en, this message translates to:
  /// **'{count} turns left today'**
  String mana_low_warning(int count);

  /// No description provided for @mana_empty_warning.
  ///
  /// In en, this message translates to:
  /// **'No mana for the next turn'**
  String get mana_empty_warning;

  /// No description provided for @guardian_alternative_title.
  ///
  /// In en, this message translates to:
  /// **'WHILE YOU WAIT'**
  String get guardian_alternative_title;

  /// No description provided for @guardian_refill_in.
  ///
  /// In en, this message translates to:
  /// **'Refills in {hours} h {minutes} min'**
  String guardian_refill_in(int hours, int minutes);

  /// No description provided for @guardian_refill_at.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String guardian_refill_at(String date);

  /// No description provided for @guardian_review_vocab.
  ///
  /// In en, this message translates to:
  /// **'Review vocabulary (free)'**
  String get guardian_review_vocab;

  /// No description provided for @guardian_low_cost_chat.
  ///
  /// In en, this message translates to:
  /// **'Text chat ({cost} mana)'**
  String guardian_low_cost_chat(int cost);

  /// No description provided for @guardian_no_due_words.
  ///
  /// In en, this message translates to:
  /// **'No words due for review right now.'**
  String get guardian_no_due_words;

  /// No description provided for @daily_goal_title.
  ///
  /// In en, this message translates to:
  /// **'DAILY GOAL'**
  String get daily_goal_title;

  /// No description provided for @daily_goal_minutes.
  ///
  /// In en, this message translates to:
  /// **'{done} / {goal} min'**
  String daily_goal_minutes(int done, int goal);

  /// No description provided for @daily_goal_remaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min to go'**
  String daily_goal_remaining(int minutes);

  /// No description provided for @daily_goal_done.
  ///
  /// In en, this message translates to:
  /// **'Goal complete'**
  String get daily_goal_done;

  /// No description provided for @daily_goal_streak.
  ///
  /// In en, this message translates to:
  /// **'{days}d streak'**
  String daily_goal_streak(int days);

  /// No description provided for @daily_goal_celebrate.
  ///
  /// In en, this message translates to:
  /// **'DAILY GOAL COMPLETE!'**
  String get daily_goal_celebrate;

  /// No description provided for @evidence_title.
  ///
  /// In en, this message translates to:
  /// **'LEARNING EVIDENCE'**
  String get evidence_title;

  /// No description provided for @evidence_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Evidence, not a grade.'**
  String get evidence_disclaimer;

  /// No description provided for @evidence_retention.
  ///
  /// In en, this message translates to:
  /// **'7-day retention'**
  String get evidence_retention;

  /// No description provided for @evidence_progress.
  ///
  /// In en, this message translates to:
  /// **'Comparable progress'**
  String get evidence_progress;

  /// No description provided for @evidence_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get evidence_transfer;

  /// No description provided for @evidence_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get evidence_no_data;

  /// No description provided for @evidence_needs_weeks.
  ///
  /// In en, this message translates to:
  /// **'You need 4 weeks'**
  String get evidence_needs_weeks;

  /// No description provided for @evidence_progress_value.
  ///
  /// In en, this message translates to:
  /// **'{first} → {last} missions/week'**
  String evidence_progress_value(int first, int last);

  /// No description provided for @evidence_transfer_value.
  ///
  /// In en, this message translates to:
  /// **'{types} mission types'**
  String evidence_transfer_value(int types);

  /// No description provided for @progress_streak_at_risk.
  ///
  /// In en, this message translates to:
  /// **'STREAK AT RISK!'**
  String get progress_streak_at_risk;

  /// No description provided for @progress_hunter_desc.
  ///
  /// In en, this message translates to:
  /// **'View the 11-attribute matrix, equipped titles and power radar'**
  String get progress_hunter_desc;

  /// No description provided for @progress_weekly_voice.
  ///
  /// In en, this message translates to:
  /// **'Weekly Practice (Voice Minutes)'**
  String get progress_weekly_voice;

  /// No description provided for @progress_vocab_learned.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Learned ({count})'**
  String progress_vocab_learned(int count);

  /// No description provided for @progress_vocab_empty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t accumulated vocabulary in voice calls yet.'**
  String get progress_vocab_empty;

  /// No description provided for @progress_vocab_section.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get progress_vocab_section;

  /// No description provided for @progress_hunter_attributes.
  ///
  /// In en, this message translates to:
  /// **'HUNTER ATTRIBUTES'**
  String get progress_hunter_attributes;

  /// No description provided for @progress_xp_rank.
  ///
  /// In en, this message translates to:
  /// **'XP Rank'**
  String get progress_xp_rank;

  /// No description provided for @settings_opt_sfx_desc.
  ///
  /// In en, this message translates to:
  /// **'Combat, mana charges, and level calibration sfx'**
  String get settings_opt_sfx_desc;

  /// No description provided for @settings_opt_strict_title.
  ///
  /// In en, this message translates to:
  /// **'STRICT ACTION'**
  String get settings_opt_strict_title;

  /// No description provided for @settings_opt_strict_desc.
  ///
  /// In en, this message translates to:
  /// **'AI will only correct critical structural breaks.'**
  String get settings_opt_strict_desc;

  /// No description provided for @settings_opt_compact_title.
  ///
  /// In en, this message translates to:
  /// **'COMPACT FEEDBACK'**
  String get settings_opt_compact_title;

  /// No description provided for @settings_opt_compact_desc.
  ///
  /// In en, this message translates to:
  /// **'Quick corrections with single line annotations.'**
  String get settings_opt_compact_desc;

  /// No description provided for @settings_opt_moderate_title.
  ///
  /// In en, this message translates to:
  /// **'MODERATE EXPLANATION'**
  String get settings_opt_moderate_title;

  /// No description provided for @settings_opt_moderate_desc.
  ///
  /// In en, this message translates to:
  /// **'Balanced corrections with 1 to 3 detail sentences.'**
  String get settings_opt_moderate_desc;

  /// No description provided for @settings_opt_detailed_title.
  ///
  /// In en, this message translates to:
  /// **'DETAILED BREAKDOWN'**
  String get settings_opt_detailed_title;

  /// No description provided for @settings_opt_detailed_desc.
  ///
  /// In en, this message translates to:
  /// **'In-depth grammar blueprints with contextual examples.'**
  String get settings_opt_detailed_desc;

  /// No description provided for @settings_opt_oracle_title.
  ///
  /// In en, this message translates to:
  /// **'ORACLE MASTER MODE'**
  String get settings_opt_oracle_title;

  /// No description provided for @settings_opt_oracle_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete analysis of error blueprints.'**
  String get settings_opt_oracle_desc;

  /// No description provided for @settings_opt_companion_title.
  ///
  /// In en, this message translates to:
  /// **'COMPANION RATE'**
  String get settings_opt_companion_title;

  /// No description provided for @settings_opt_companion_desc.
  ///
  /// In en, this message translates to:
  /// **'Patient, warm, and highly supportive responses.'**
  String get settings_opt_companion_desc;

  /// No description provided for @settings_opt_commander_title.
  ///
  /// In en, this message translates to:
  /// **'COMMANDER BRIEF'**
  String get settings_opt_commander_title;

  /// No description provided for @settings_opt_commander_desc.
  ///
  /// In en, this message translates to:
  /// **'Formal, highly structured, and structured corrections.'**
  String get settings_opt_commander_desc;

  /// No description provided for @settings_opt_boss_title.
  ///
  /// In en, this message translates to:
  /// **'BOSS CALIBER CHALLENGE'**
  String get settings_opt_boss_title;

  /// No description provided for @settings_opt_boss_desc.
  ///
  /// In en, this message translates to:
  /// **'High-level vocabulary demands and strict responses.'**
  String get settings_opt_boss_desc;

  /// No description provided for @settings_opt_strict_style_title.
  ///
  /// In en, this message translates to:
  /// **'STRICT ACTION'**
  String get settings_opt_strict_style_title;

  /// No description provided for @settings_opt_strict_style_desc.
  ///
  /// In en, this message translates to:
  /// **'Interrupts and repairs errors instantly.'**
  String get settings_opt_strict_style_desc;

  /// No description provided for @settings_opt_balanced_title.
  ///
  /// In en, this message translates to:
  /// **'BALANCED COMPASS'**
  String get settings_opt_balanced_title;

  /// No description provided for @settings_opt_balanced_desc.
  ///
  /// In en, this message translates to:
  /// **'Maintains dialogue speed with structured correction feedback.'**
  String get settings_opt_balanced_desc;

  /// No description provided for @settings_opt_immersive_title.
  ///
  /// In en, this message translates to:
  /// **'IMMERSIVE RAIDS'**
  String get settings_opt_immersive_title;

  /// No description provided for @settings_opt_immersive_desc.
  ///
  /// In en, this message translates to:
  /// **'Keeps speaking flow; repairs only terminal breaks.'**
  String get settings_opt_immersive_desc;

  /// No description provided for @settings_opt_casual_title.
  ///
  /// In en, this message translates to:
  /// **'CASUAL RUN (10 MIN)'**
  String get settings_opt_casual_title;

  /// No description provided for @settings_opt_casual_desc.
  ///
  /// In en, this message translates to:
  /// **'Quick entry practice daily.'**
  String get settings_opt_casual_desc;

  /// No description provided for @settings_opt_regular_title.
  ///
  /// In en, this message translates to:
  /// **'REGULAR RAID (15 MIN)'**
  String get settings_opt_regular_title;

  /// No description provided for @settings_opt_regular_desc.
  ///
  /// In en, this message translates to:
  /// **'Solid learning rate path.'**
  String get settings_opt_regular_desc;

  /// No description provided for @settings_opt_serious_title.
  ///
  /// In en, this message translates to:
  /// **'SERIOUS CAMPAIGN (30 MIN)'**
  String get settings_opt_serious_title;

  /// No description provided for @settings_opt_serious_desc.
  ///
  /// In en, this message translates to:
  /// **'Acquire fluent skill markers rapidly.'**
  String get settings_opt_serious_desc;

  /// No description provided for @settings_opt_overload_title.
  ///
  /// In en, this message translates to:
  /// **'OVERLOAD OVERCLOCK (60 MIN)'**
  String get settings_opt_overload_title;

  /// No description provided for @settings_opt_overload_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete immersion overdrive.'**
  String get settings_opt_overload_desc;

  /// No description provided for @hunter_title_orco_caverna_f.
  ///
  /// In en, this message translates to:
  /// **'Cave Orc Writing'**
  String get hunter_title_orco_caverna_f;

  /// No description provided for @hunter_title_orco_caverna_f_desc.
  ///
  /// In en, this message translates to:
  /// **'First steps making mistakes with courage.'**
  String get hunter_title_orco_caverna_f_desc;

  /// No description provided for @hunter_title_escriba_novato_e.
  ///
  /// In en, this message translates to:
  /// **'Novice Scribe'**
  String get hunter_title_escriba_novato_e;

  /// No description provided for @hunter_title_escriba_novato_e_desc.
  ///
  /// In en, this message translates to:
  /// **'50% clean sentences.'**
  String get hunter_title_escriba_novato_e_desc;

  /// No description provided for @hunter_title_escriba_ciudad_d.
  ///
  /// In en, this message translates to:
  /// **'City Scribe'**
  String get hunter_title_escriba_ciudad_d;

  /// No description provided for @hunter_title_escriba_ciudad_d_desc.
  ///
  /// In en, this message translates to:
  /// **'65% grammar accuracy.'**
  String get hunter_title_escriba_ciudad_d_desc;

  /// No description provided for @hunter_title_escriba_imperial_c.
  ///
  /// In en, this message translates to:
  /// **'Imperial Library Scribe'**
  String get hunter_title_escriba_imperial_c;

  /// No description provided for @hunter_title_escriba_imperial_c_desc.
  ///
  /// In en, this message translates to:
  /// **'75% grammar accuracy.'**
  String get hunter_title_escriba_imperial_c_desc;

  /// No description provided for @hunter_title_pluma_erudito_b.
  ///
  /// In en, this message translates to:
  /// **'Royal Scholar Quill'**
  String get hunter_title_pluma_erudito_b;

  /// No description provided for @hunter_title_pluma_erudito_b_desc.
  ///
  /// In en, this message translates to:
  /// **'85% grammar accuracy.'**
  String get hunter_title_pluma_erudito_b_desc;

  /// No description provided for @hunter_title_pluma_archimago_a.
  ///
  /// In en, this message translates to:
  /// **'Archmage Arcanist Quill'**
  String get hunter_title_pluma_archimago_a;

  /// No description provided for @hunter_title_pluma_archimago_a_desc.
  ///
  /// In en, this message translates to:
  /// **'92% grammar accuracy.'**
  String get hunter_title_pluma_archimago_a_desc;

  /// No description provided for @hunter_title_pluma_celestial_s.
  ///
  /// In en, this message translates to:
  /// **'Celestial Quill of the Sage'**
  String get hunter_title_pluma_celestial_s;

  /// No description provided for @hunter_title_pluma_celestial_s_desc.
  ///
  /// In en, this message translates to:
  /// **'97% grammar accuracy.'**
  String get hunter_title_pluma_celestial_s_desc;

  /// No description provided for @hunter_title_monarca_sintaxis_ss.
  ///
  /// In en, this message translates to:
  /// **'Monarch of Sacred Syntax'**
  String get hunter_title_monarca_sintaxis_ss;

  /// No description provided for @hunter_title_monarca_sintaxis_ss_desc.
  ///
  /// In en, this message translates to:
  /// **'99% grammar accuracy.'**
  String get hunter_title_monarca_sintaxis_ss_desc;

  /// No description provided for @hunter_title_creador_abismo_sss.
  ///
  /// In en, this message translates to:
  /// **'Creator of Abyssal Languages'**
  String get hunter_title_creador_abismo_sss;

  /// No description provided for @hunter_title_creador_abismo_sss_desc.
  ///
  /// In en, this message translates to:
  /// **'100% flawless grammar accuracy.'**
  String get hunter_title_creador_abismo_sss_desc;

  /// No description provided for @hunter_title_murcielago_ciego_f.
  ///
  /// In en, this message translates to:
  /// **'Blind Bat'**
  String get hunter_title_murcielago_ciego_f;

  /// No description provided for @hunter_title_murcielago_ciego_f_desc.
  ///
  /// In en, this message translates to:
  /// **'Initial listens with text chat.'**
  String get hunter_title_murcielago_ciego_f_desc;

  /// No description provided for @hunter_title_oido_halcon_novato_d.
  ///
  /// In en, this message translates to:
  /// **'Novice Hawk Hearing'**
  String get hunter_title_oido_halcon_novato_d;

  /// No description provided for @hunter_title_oido_halcon_novato_d_desc.
  ///
  /// In en, this message translates to:
  /// **'2 lessons without chat.'**
  String get hunter_title_oido_halcon_novato_d_desc;

  /// No description provided for @hunter_title_oido_halcon_abismo_c.
  ///
  /// In en, this message translates to:
  /// **'Abyss Hawk Hearing'**
  String get hunter_title_oido_halcon_abismo_c;

  /// No description provided for @hunter_title_oido_halcon_abismo_c_desc.
  ///
  /// In en, this message translates to:
  /// **'4 blind-cleared lessons.'**
  String get hunter_title_oido_halcon_abismo_c_desc;

  /// No description provided for @hunter_title_sonar_monarca_sombras_s.
  ///
  /// In en, this message translates to:
  /// **'Absolute Sonar of the Shadow Monarch'**
  String get hunter_title_sonar_monarca_sombras_s;

  /// No description provided for @hunter_title_sonar_monarca_sombras_s_desc.
  ///
  /// In en, this message translates to:
  /// **'16 blind-cleared lessons.'**
  String get hunter_title_sonar_monarca_sombras_s_desc;

  /// No description provided for @hunter_title_oidor_susurros_sss.
  ///
  /// In en, this message translates to:
  /// **'Hearer of the Universe Whispers'**
  String get hunter_title_oidor_susurros_sss;

  /// No description provided for @hunter_title_oidor_susurros_sss_desc.
  ///
  /// In en, this message translates to:
  /// **'Over 30 blind-cleared lessons.'**
  String get hunter_title_oidor_susurros_sss_desc;

  /// No description provided for @hunter_title_monarca_impecable_5star.
  ///
  /// In en, this message translates to:
  /// **'Immaculate Monarch of Perfection'**
  String get hunter_title_monarca_impecable_5star;

  /// No description provided for @hunter_title_monarca_impecable_5star_desc.
  ///
  /// In en, this message translates to:
  /// **'Awarded for achieving the 5th Mythic Star (0 blind errors).'**
  String get hunter_title_monarca_impecable_5star_desc;

  /// No description provided for @skill_fluidez_1.
  ///
  /// In en, this message translates to:
  /// **'Word Apprentice'**
  String get skill_fluidez_1;

  /// No description provided for @skill_fluidez_1_desc.
  ///
  /// In en, this message translates to:
  /// **'You begin to express yourself with continuity.'**
  String get skill_fluidez_1_desc;

  /// No description provided for @skill_fluidez_2.
  ///
  /// In en, this message translates to:
  /// **'The Swift Courier'**
  String get skill_fluidez_2;

  /// No description provided for @skill_fluidez_2_desc.
  ///
  /// In en, this message translates to:
  /// **'You speak with notable rhythm and fluency.'**
  String get skill_fluidez_2_desc;

  /// No description provided for @skill_fluidez_3.
  ///
  /// In en, this message translates to:
  /// **'Herald of the Gale'**
  String get skill_fluidez_3;

  /// No description provided for @skill_fluidez_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Your speech flows effortlessly.'**
  String get skill_fluidez_3_desc;

  /// No description provided for @skill_fluidez_4.
  ///
  /// In en, this message translates to:
  /// **'Spokesperson of the Gods'**
  String get skill_fluidez_4;

  /// No description provided for @skill_fluidez_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Almost divine fluency when conversing.'**
  String get skill_fluidez_4_desc;

  /// No description provided for @skill_fonetica_1.
  ///
  /// In en, this message translates to:
  /// **'Voice Apprentice'**
  String get skill_fonetica_1;

  /// No description provided for @skill_fonetica_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Your pronunciation is becoming clear.'**
  String get skill_fonetica_1_desc;

  /// No description provided for @skill_fonetica_2.
  ///
  /// In en, this message translates to:
  /// **'Echo of the Coliseum'**
  String get skill_fonetica_2;

  /// No description provided for @skill_fonetica_2_desc.
  ///
  /// In en, this message translates to:
  /// **'You pronounce with remarkable precision.'**
  String get skill_fonetica_2_desc;

  /// No description provided for @skill_fonetica_3.
  ///
  /// In en, this message translates to:
  /// **'Crystal Choir'**
  String get skill_fonetica_3;

  /// No description provided for @skill_fonetica_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Your phonetics are clean and bright.'**
  String get skill_fonetica_3_desc;

  /// No description provided for @skill_fonetica_4.
  ///
  /// In en, this message translates to:
  /// **'Celestial Tuner'**
  String get skill_fonetica_4;

  /// No description provided for @skill_fonetica_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Phonetic clarity from another plane.'**
  String get skill_fonetica_4_desc;

  /// No description provided for @skill_lexico_1.
  ///
  /// In en, this message translates to:
  /// **'Word Gatherer'**
  String get skill_lexico_1;

  /// No description provided for @skill_lexico_1_desc.
  ///
  /// In en, this message translates to:
  /// **'You add your first mastered words.'**
  String get skill_lexico_1_desc;

  /// No description provided for @skill_lexico_2.
  ///
  /// In en, this message translates to:
  /// **'Village Librarian'**
  String get skill_lexico_2;

  /// No description provided for @skill_lexico_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Your vocabulary grows solidly.'**
  String get skill_lexico_2_desc;

  /// No description provided for @skill_lexico_3.
  ///
  /// In en, this message translates to:
  /// **'Abyss Scribe'**
  String get skill_lexico_3;

  /// No description provided for @skill_lexico_3_desc.
  ///
  /// In en, this message translates to:
  /// **'You master an extensive vocabulary.'**
  String get skill_lexico_3_desc;

  /// No description provided for @skill_lexico_4.
  ///
  /// In en, this message translates to:
  /// **'Eternal Lexicographer'**
  String get skill_lexico_4;

  /// No description provided for @skill_lexico_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Your lexicon knows no bounds.'**
  String get skill_lexico_4_desc;

  /// No description provided for @skill_precision_1.
  ///
  /// In en, this message translates to:
  /// **'Rules Apprentice'**
  String get skill_precision_1;

  /// No description provided for @skill_precision_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Simple structures are already solid.'**
  String get skill_precision_1_desc;

  /// No description provided for @skill_precision_2.
  ///
  /// In en, this message translates to:
  /// **'Rune Apprentice'**
  String get skill_precision_2;

  /// No description provided for @skill_precision_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Your grammar gains consistency.'**
  String get skill_precision_2_desc;

  /// No description provided for @skill_precision_3.
  ///
  /// In en, this message translates to:
  /// **'Coliseum Grammarian'**
  String get skill_precision_3;

  /// No description provided for @skill_precision_3_desc.
  ///
  /// In en, this message translates to:
  /// **'You build sentences with mastery.'**
  String get skill_precision_3_desc;

  /// No description provided for @skill_precision_4.
  ///
  /// In en, this message translates to:
  /// **'Syntax Forger'**
  String get skill_precision_4;

  /// No description provided for @skill_precision_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Your grammatical precision is legendary.'**
  String get skill_precision_4_desc;

  /// No description provided for @skill_constancia_1.
  ///
  /// In en, this message translates to:
  /// **'Steady Apprentice'**
  String get skill_constancia_1;

  /// No description provided for @skill_constancia_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Three consecutive days of practice.'**
  String get skill_constancia_1_desc;

  /// No description provided for @skill_constancia_2.
  ///
  /// In en, this message translates to:
  /// **'Fire Guardian'**
  String get skill_constancia_2;

  /// No description provided for @skill_constancia_2_desc.
  ///
  /// In en, this message translates to:
  /// **'One uninterrupted week.'**
  String get skill_constancia_2_desc;

  /// No description provided for @skill_constancia_3.
  ///
  /// In en, this message translates to:
  /// **'Dawn Sentinel'**
  String get skill_constancia_3;

  /// No description provided for @skill_constancia_3_desc.
  ///
  /// In en, this message translates to:
  /// **'A month of iron consistency.'**
  String get skill_constancia_3_desc;

  /// No description provided for @skill_constancia_4.
  ///
  /// In en, this message translates to:
  /// **'Streak Legend'**
  String get skill_constancia_4;

  /// No description provided for @skill_constancia_4_desc.
  ///
  /// In en, this message translates to:
  /// **'A hundred days of absolute dedication.'**
  String get skill_constancia_4_desc;

  /// No description provided for @skill_carisma_1.
  ///
  /// In en, this message translates to:
  /// **'Guild Novice'**
  String get skill_carisma_1;

  /// No description provided for @skill_carisma_1_desc.
  ///
  /// In en, this message translates to:
  /// **'You navigate conversations with ease.'**
  String get skill_carisma_1_desc;

  /// No description provided for @skill_carisma_2.
  ///
  /// In en, this message translates to:
  /// **'Soul of the Tavern'**
  String get skill_carisma_2;

  /// No description provided for @skill_carisma_2_desc.
  ///
  /// In en, this message translates to:
  /// **'You connect naturally with others.'**
  String get skill_carisma_2_desc;

  /// No description provided for @skill_carisma_3.
  ///
  /// In en, this message translates to:
  /// **'Realm Ambassador'**
  String get skill_carisma_3;

  /// No description provided for @skill_carisma_3_desc.
  ///
  /// In en, this message translates to:
  /// **'You lead the conversation smoothly.'**
  String get skill_carisma_3_desc;

  /// No description provided for @skill_carisma_4.
  ///
  /// In en, this message translates to:
  /// **'Lesser Oracle'**
  String get skill_carisma_4;

  /// No description provided for @skill_carisma_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Your conversational charisma is out of this world.'**
  String get skill_carisma_4_desc;

  /// No description provided for @paywall_upgrade_title.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE TO PREMIUM'**
  String get paywall_upgrade_title;

  /// No description provided for @paywall_upgrade_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your estate defines your monthly mana and prestige ceiling. Effort (Aura) decides your title.'**
  String get paywall_upgrade_subtitle;

  /// No description provided for @paywall_f_monthly.
  ///
  /// In en, this message translates to:
  /// **'MENSUAL'**
  String get paywall_f_monthly;

  /// No description provided for @paywall_f_annual.
  ///
  /// In en, this message translates to:
  /// **'ANUAL'**
  String get paywall_f_annual;

  /// No description provided for @paywall_subscribe.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIBE NOW'**
  String get paywall_subscribe;

  /// No description provided for @paywall_restore.
  ///
  /// In en, this message translates to:
  /// **'RESTORE'**
  String get paywall_restore;

  /// No description provided for @paywall_legal.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime via App Store / Play Store. Terms and Conditions apply.'**
  String get paywall_legal;

  /// No description provided for @paywall_err_checkout.
  ///
  /// In en, this message translates to:
  /// **'Could not open the checkout.'**
  String get paywall_err_checkout;

  /// No description provided for @paywall_feature_mana.
  ///
  /// In en, this message translates to:
  /// **'Realtime Mana consumption & voice metrics tracker'**
  String get paywall_feature_mana;

  /// No description provided for @paywall_feature_titles.
  ///
  /// In en, this message translates to:
  /// **'Unlock the 63 Rank Titles Inventory (from F to SSS Rank)'**
  String get paywall_feature_titles;

  /// No description provided for @paywall_feature_rooms.
  ///
  /// In en, this message translates to:
  /// **'24/7 access to the Grand Discussion Hall voice rooms'**
  String get paywall_feature_rooms;

  /// No description provided for @paywall_feature_modes.
  ///
  /// In en, this message translates to:
  /// **'Tactical selector between Voice Mode and Writing Mode'**
  String get paywall_feature_modes;

  /// No description provided for @paywall_feature_missions.
  ///
  /// In en, this message translates to:
  /// **'Premium missions & weekly raid rewards'**
  String get paywall_feature_missions;

  /// No description provided for @paywall_active_title.
  ///
  /// In en, this message translates to:
  /// **'YOUR CURRENT PLAN'**
  String get paywall_active_title;

  /// No description provided for @paywall_active_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You already have Premium. Manage or change your plan here.'**
  String get paywall_active_subtitle;

  /// No description provided for @paywall_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load the plans.'**
  String get paywall_load_error;

  /// No description provided for @paywall_no_packages.
  ///
  /// In en, this message translates to:
  /// **'No plans available for this billing cycle.'**
  String get paywall_no_packages;

  /// No description provided for @paywall_nothing_restored.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore.'**
  String get paywall_nothing_restored;

  /// No description provided for @paywall_current_plan.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PLAN'**
  String get paywall_current_plan;

  /// No description provided for @paywall_manage_subscription.
  ///
  /// In en, this message translates to:
  /// **'MANAGE SUBSCRIPTION'**
  String get paywall_manage_subscription;

  /// No description provided for @mana_inventory_title.
  ///
  /// In en, this message translates to:
  /// **'MANA INVENTORY'**
  String get mana_inventory_title;

  /// No description provided for @mana_inventory_empty.
  ///
  /// In en, this message translates to:
  /// **'No elixirs or gems in your bag yet.'**
  String get mana_inventory_empty;

  /// No description provided for @mana_gem_label.
  ///
  /// In en, this message translates to:
  /// **'GEM'**
  String get mana_gem_label;

  /// No description provided for @mana_elixir_label.
  ///
  /// In en, this message translates to:
  /// **'ELIXIR'**
  String get mana_elixir_label;

  /// No description provided for @mana_expiry_countdown.
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours}h {minutes}m'**
  String mana_expiry_countdown(Object hours, Object minutes);

  /// No description provided for @mana_item_equipped.
  ///
  /// In en, this message translates to:
  /// **'Mana item equipped'**
  String get mana_item_equipped;

  /// No description provided for @mana_equip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get mana_equip;

  /// No description provided for @summary_next_lesson.
  ///
  /// In en, this message translates to:
  /// **'NEXT LESSON'**
  String get summary_next_lesson;

  /// No description provided for @oracle_challenge_title.
  ///
  /// In en, this message translates to:
  /// **'ORACLE EVALUATION'**
  String get oracle_challenge_title;

  /// No description provided for @oracle_challenge_ready.
  ///
  /// In en, this message translates to:
  /// **'The Oracle awaits you. Challenge available!'**
  String get oracle_challenge_ready;

  /// No description provided for @oracle_challenge_progress.
  ///
  /// In en, this message translates to:
  /// **'Complete 80% to challenge the Oracle ({percent}%)'**
  String oracle_challenge_progress(Object percent);

  /// No description provided for @onboarding_english_only.
  ///
  /// In en, this message translates to:
  /// **'You will learn English. You can change the interface language in Settings.'**
  String get onboarding_english_only;

  /// No description provided for @corrections_chip_label.
  ///
  /// In en, this message translates to:
  /// **'FIX {count}'**
  String corrections_chip_label(int count);

  /// No description provided for @corrections_you_wrote.
  ///
  /// In en, this message translates to:
  /// **'You wrote'**
  String get corrections_you_wrote;

  /// No description provided for @corrections_suggested.
  ///
  /// In en, this message translates to:
  /// **'Better'**
  String get corrections_suggested;

  /// No description provided for @my_errors_title.
  ///
  /// In en, this message translates to:
  /// **'MY ERRORS'**
  String get my_errors_title;

  /// No description provided for @my_errors_short.
  ///
  /// In en, this message translates to:
  /// **'ERRORS'**
  String get my_errors_short;

  /// No description provided for @my_errors_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Grouped by type and recurrence. Recurrent mistakes feed your reinforcement missions.'**
  String get my_errors_subtitle;

  /// No description provided for @my_errors_empty.
  ///
  /// In en, this message translates to:
  /// **'No errors recorded yet. Finish a lesson and your corrections will appear here.'**
  String get my_errors_empty;

  /// No description provided for @my_errors_error.
  ///
  /// In en, this message translates to:
  /// **'We could not load your errors. Check your connection and retry.'**
  String get my_errors_error;

  /// No description provided for @my_errors_retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get my_errors_retry;

  /// No description provided for @my_errors_times.
  ///
  /// In en, this message translates to:
  /// **'{count}x'**
  String my_errors_times(int count);

  /// No description provided for @my_errors_recurring_badge.
  ///
  /// In en, this message translates to:
  /// **'RECURRING'**
  String get my_errors_recurring_badge;

  /// No description provided for @correction_type_grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get correction_type_grammar;

  /// No description provided for @correction_type_vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get correction_type_vocabulary;

  /// No description provided for @correction_type_word_choice.
  ///
  /// In en, this message translates to:
  /// **'Word choice'**
  String get correction_type_word_choice;

  /// No description provided for @correction_type_pronunciation_hint.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get correction_type_pronunciation_hint;

  /// No description provided for @correction_type_typo_stt.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get correction_type_typo_stt;

  /// No description provided for @notif_settings_title.
  ///
  /// In en, this message translates to:
  /// **'DAILY REMINDER'**
  String get notif_settings_title;

  /// No description provided for @notif_settings_desc.
  ///
  /// In en, this message translates to:
  /// **'One reminder a day, at the time you choose. Never at night.'**
  String get notif_settings_desc;

  /// No description provided for @notif_time_label.
  ///
  /// In en, this message translates to:
  /// **'REMINDER TIME'**
  String get notif_time_label;

  /// No description provided for @notif_days_label.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE DAYS'**
  String get notif_days_label;

  /// No description provided for @notif_quiet_hours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours are 22:00-08:00, so the reminder moved to 08:00.'**
  String get notif_quiet_hours;

  /// No description provided for @notif_time_updated.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time}.'**
  String notif_time_updated(String time);

  /// No description provided for @notif_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Allow them in Android settings > Apps > Dungeon of English > Notifications.'**
  String get notif_permission_denied;

  /// No description provided for @notif_permission_open_settings.
  ///
  /// In en, this message translates to:
  /// **'OPEN ANDROID SETTINGS'**
  String get notif_permission_open_settings;

  /// No description provided for @notif_prompt_title.
  ///
  /// In en, this message translates to:
  /// **'DON\'T LOSE YOUR STREAK'**
  String get notif_prompt_title;

  /// No description provided for @notif_prompt_body.
  ///
  /// In en, this message translates to:
  /// **'Turn on one daily reminder and we will nudge you at the time you choose. You can change it or turn it off in Settings.'**
  String get notif_prompt_body;

  /// No description provided for @notif_prompt_accept.
  ///
  /// In en, this message translates to:
  /// **'TURN IT ON'**
  String get notif_prompt_accept;

  /// No description provided for @notif_prompt_later.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notif_prompt_later;

  /// No description provided for @notif_enabled_ok.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder armed.'**
  String get notif_enabled_ok;

  /// No description provided for @notif_save_error.
  ///
  /// In en, this message translates to:
  /// **'Could not save the reminder. Check your connection and try again.'**
  String get notif_save_error;

  /// No description provided for @notif_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'Your streak awaits'**
  String get notif_reminder_title;

  /// No description provided for @notif_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'A short raid today keeps the streak alive. Your tutor is ready.'**
  String get notif_reminder_body;

  /// No description provided for @boss_exam_title.
  ///
  /// In en, this message translates to:
  /// **'DUNGEON BOSS: THE ORACLE'**
  String get boss_exam_title;

  /// No description provided for @boss_exam_state_ready.
  ///
  /// In en, this message translates to:
  /// **'The boss awaits. Challenge available!'**
  String get boss_exam_state_ready;

  /// No description provided for @boss_exam_state_locked.
  ///
  /// In en, this message translates to:
  /// **'Meet the requirements to challenge the boss.'**
  String get boss_exam_state_locked;

  /// No description provided for @boss_exam_state_locked_progress.
  ///
  /// In en, this message translates to:
  /// **'Complete 80% of the level lessons ({percent}%)'**
  String boss_exam_state_locked_progress(int percent);

  /// No description provided for @boss_exam_state_cooldown.
  ///
  /// In en, this message translates to:
  /// **'The boss rests until {time}.'**
  String boss_exam_state_cooldown(String time);

  /// No description provided for @boss_req_level.
  ///
  /// In en, this message translates to:
  /// **'Assigned level'**
  String get boss_req_level;

  /// No description provided for @boss_req_practice.
  ///
  /// In en, this message translates to:
  /// **'Practice: goals, streak or minutes'**
  String get boss_req_practice;

  /// No description provided for @boss_req_cooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown between attempts'**
  String get boss_req_cooldown;

  /// No description provided for @boss_hud_title.
  ///
  /// In en, this message translates to:
  /// **'BOSS: THE ORACLE'**
  String get boss_hud_title;

  /// No description provided for @boss_hud_turns.
  ///
  /// In en, this message translates to:
  /// **'TURN {current}/{max}'**
  String boss_hud_turns(int current, int max);

  /// No description provided for @boss_result_victory.
  ///
  /// In en, this message translates to:
  /// **'BOSS DEFEATED'**
  String get boss_result_victory;

  /// No description provided for @boss_result_defeat.
  ///
  /// In en, this message translates to:
  /// **'THE BOSS HOLDS'**
  String get boss_result_defeat;

  /// No description provided for @boss_result_initial.
  ///
  /// In en, this message translates to:
  /// **'LEVEL ASSIGNED'**
  String get boss_result_initial;

  /// No description provided for @boss_result_missing.
  ///
  /// In en, this message translates to:
  /// **'No result available.'**
  String get boss_result_missing;

  /// No description provided for @boss_result_level_up.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String boss_result_level_up(String from, String to);

  /// No description provided for @boss_result_level_assigned.
  ///
  /// In en, this message translates to:
  /// **'Your level: {level}'**
  String boss_result_level_assigned(String level);

  /// No description provided for @boss_result_level_kept.
  ///
  /// In en, this message translates to:
  /// **'You keep {level}'**
  String boss_result_level_kept(String level);

  /// No description provided for @boss_result_forced.
  ///
  /// In en, this message translates to:
  /// **'The exam reached its limit and was scored with the answers given.'**
  String get boss_result_forced;

  /// No description provided for @boss_result_rubric.
  ///
  /// In en, this message translates to:
  /// **'RUBRIC (6 DIMENSIONS)'**
  String get boss_result_rubric;

  /// No description provided for @boss_result_average.
  ///
  /// In en, this message translates to:
  /// **'avg {value}/100 - pass {threshold}'**
  String boss_result_average(int value, int threshold);

  /// No description provided for @boss_result_no_scores.
  ///
  /// In en, this message translates to:
  /// **'The Oracle could not score the rubric in this attempt.'**
  String get boss_result_no_scores;

  /// No description provided for @boss_result_reason_title.
  ///
  /// In en, this message translates to:
  /// **'WHY NOT YET'**
  String get boss_result_reason_title;

  /// No description provided for @boss_result_reason_rubric.
  ///
  /// In en, this message translates to:
  /// **'You were close: the average or one dimension is below the pass threshold.'**
  String get boss_result_reason_rubric;

  /// No description provided for @boss_result_reason_no_improvement.
  ///
  /// In en, this message translates to:
  /// **'Your level is solid, but not yet above your current band.'**
  String get boss_result_reason_no_improvement;

  /// No description provided for @boss_result_reason_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The Oracle could not score the rubric, so the level is kept.'**
  String get boss_result_reason_unavailable;

  /// No description provided for @boss_result_retry_at.
  ///
  /// In en, this message translates to:
  /// **'Next attempt: {time}'**
  String boss_result_retry_at(String time);

  /// No description provided for @boss_result_focus_title.
  ///
  /// In en, this message translates to:
  /// **'WHAT TO REINFORCE'**
  String get boss_result_focus_title;

  /// No description provided for @boss_result_reinforce.
  ///
  /// In en, this message translates to:
  /// **'PRACTISE REINFORCEMENT LESSONS'**
  String get boss_result_reinforce;

  /// No description provided for @boss_result_home.
  ///
  /// In en, this message translates to:
  /// **'BACK TO THE PATH'**
  String get boss_result_home;

  /// No description provided for @boss_dim_listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get boss_dim_listening;

  /// No description provided for @boss_dim_fluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency'**
  String get boss_dim_fluency;

  /// No description provided for @boss_dim_grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get boss_dim_grammar;

  /// No description provided for @boss_dim_vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get boss_dim_vocabulary;

  /// No description provided for @boss_dim_pronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get boss_dim_pronunciation;

  /// No description provided for @boss_dim_naturalness.
  ///
  /// In en, this message translates to:
  /// **'Naturalness'**
  String get boss_dim_naturalness;

  /// No description provided for @boss_exam_not_enough.
  ///
  /// In en, this message translates to:
  /// **'The Oracle needs at least {min} answers to judge the exam. This attempt does not count.'**
  String boss_exam_not_enough(int min);

  /// No description provided for @boss_exam_cooldown.
  ///
  /// In en, this message translates to:
  /// **'The boss does not accept another challenge until {time}.'**
  String boss_exam_cooldown(String time);
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
