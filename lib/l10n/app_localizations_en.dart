// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Dungeon of English';

  @override
  String get login_title => 'Welcome back, Hunter';

  @override
  String get login_subtitle => 'Sign in to continue your journey.';

  @override
  String get register_prompt => 'New Hunter? Create account';

  @override
  String get login_prompt => 'Already a Hunter? Log in';

  @override
  String get welcome_title => '[SYSTEM MESSAGE: AWAKENING HUNTER CORE...]';

  @override
  String get welcome_subtitle => 'Learn by Speaking';

  @override
  String get welcome_desc =>
      'Your personal AI language tutor, available 24/7 for natural conversation.';

  @override
  String get welcome_warning =>
      'Warning: Unregistered Hunters will be designated Rank E';

  @override
  String get login => 'LOG IN';

  @override
  String get register => 'CREATE ACCOUNT';

  @override
  String get continue_google => 'CONTINUE WITH GOOGLE';

  @override
  String get login_google => 'LOG IN WITH GOOGLE';

  @override
  String get register_google => 'REGISTER WITH GOOGLE';

  @override
  String get back => 'Back';

  @override
  String get skip => 'SKIP';

  @override
  String get sign_in => 'Sign In';

  @override
  String get sign_in_desc =>
      'Sign in with your Google account to continue with your language classes.';

  @override
  String get create_account => 'Create Account';

  @override
  String get create_account_desc =>
      'Register with Google to personalize your AI language tutor and track progress.';

  @override
  String get email_label => 'Email';

  @override
  String get password_label => 'Password';

  @override
  String get email_required => 'Enter your email';

  @override
  String get password_required => 'Enter your password';

  @override
  String get email_invalid => 'Enter a valid email';

  @override
  String get password_short => 'Password must be at least 6 characters';

  @override
  String get login_email => 'LOG IN WITH EMAIL';

  @override
  String get register_email => 'CREATE ACCOUNT WITH EMAIL';

  @override
  String get login_email_error => 'Error signing in with email.';

  @override
  String get register_email_error => 'Error creating the account.';

  @override
  String get email_already_registered =>
      'This email is already registered. Log in instead.';

  @override
  String get login_success => 'Login successful. Entering the realm...';

  @override
  String get register_success => 'Account created. Entering the realm...';

  @override
  String get login_email_hint => 'your@email.com';

  @override
  String get forgot_password => 'FORGOT PASSWORD?';

  @override
  String get reset_password_title => 'RECOVER PASSWORD';

  @override
  String get reset_password_desc =>
      'Enter your email and we will send you a link to recover your password.';

  @override
  String get reset_password_send => 'SEND RECOVERY LINK';

  @override
  String get reset_password_sent =>
      'Recovery link sent. Check your email inbox.';

  @override
  String get reset_password_error =>
      'Error sending the recovery link. Check the email and try again.';

  @override
  String get reset_password_email_empty =>
      'Enter your email to recover your password.';

  @override
  String get sync_progress => 'SYNC CEFR LANGUAGE...';

  @override
  String get dashboard_title => 'SYSTEM STATUS';

  @override
  String get dashboard_offline =>
      'No connection. Showing your last saved progress.';

  @override
  String dashboard_offline_age(int minutes) {
    return 'No connection. Last progress $minutes min ago.';
  }

  @override
  String get dungeons => 'DUNGEONS';

  @override
  String get guild => 'GUILD';

  @override
  String get status => 'STATUS';

  @override
  String get config => 'CONFIG';

  @override
  String get player => 'PLAYER';

  @override
  String get mp => 'MP';

  @override
  String get days_clear => 'DAYS CLEAR';

  @override
  String get urgent_quest => 'URGENT QUEST';

  @override
  String get enter_gateway => 'ENTER GATEWAY BATTLE';

  @override
  String get active_quests => 'ACTIVE QUESTS';

  @override
  String get daily => 'DAILY';

  @override
  String get weekly => 'WEEKLY';

  @override
  String get speak_words => 'Speak 50 words in a session';

  @override
  String get keep_streak => 'Keep your streak alive';

  @override
  String get clear_vocab => 'Clear 1 Vocabulary Dungeon';

  @override
  String get chat_rooms => 'Voice Chat Rooms';

  @override
  String get chat_rooms_desc =>
      'Group practice with AI moderation in real time';

  @override
  String get settings => 'Settings';

  @override
  String get language_level => 'Language and Level';

  @override
  String get tutorial_system => 'Tutorial and System';

  @override
  String get ai_preferences => 'AI Preferences';

  @override
  String get reminders => 'Reminders';

  @override
  String get account => 'Account';

  @override
  String get target_language => 'Target Language';

  @override
  String get active_cefr => 'Active CEFR Level';

  @override
  String get review_tutorial => 'Review Tutorial';

  @override
  String get review_tutorial_desc => 'View the complete onboarding again';

  @override
  String get tutorial_dialog_title => 'Review Tutorial';

  @override
  String get tutorial_dialog_content =>
      'The tutorial will be marked as pending. Return to home to be redirected.';

  @override
  String get cancel => 'Cancel';

  @override
  String get tutorial_pending => 'Tutorial marked as pending. Go to home.';

  @override
  String get correction_level => 'AI Correction Level';

  @override
  String get tutor_personality => 'Tutor Personality';

  @override
  String get correction_style => 'Correction Style';

  @override
  String get daily_goal => 'Daily Goal';

  @override
  String get save_settings => 'Save Settings';

  @override
  String get settings_save_error => 'Could not save settings.';

  @override
  String get settings_delete_error => 'Could not delete the account.';

  @override
  String get settings_app_language => 'APP LANGUAGE';

  @override
  String get saved => 'Settings and Onboarding saved successfully';

  @override
  String get error_saving => 'Error saving settings';

  @override
  String get logout => 'Log Out';

  @override
  String get select_language => 'Select Target Language';

  @override
  String get select_cefr => 'Select Your CEFR Level';

  @override
  String get fluency => 'FLUENCY';

  @override
  String get latency => 'LATENCY';

  @override
  String get pipeline_perf => 'Pipeline performance';

  @override
  String get score => 'Score';

  @override
  String get achievements => 'Achievements & Stats';

  @override
  String get vocabulary_learned => 'Vocabulary Learned';

  @override
  String get weekly_practice => 'Weekly Practice (Voice Minutes)';

  @override
  String get view_all => 'VIEW ALL';

  @override
  String get srs_review => 'SRS Review';

  @override
  String get fluency_evolution => 'Fluency & Latency Evolution';

  @override
  String get wpm => 'WPM';

  @override
  String get radar_title => 'Holographic Skills Radar';

  @override
  String get heatmap_title => 'Practice Consistency (4 Weeks)';

  @override
  String get weeks_ago => '4 weeks ago';

  @override
  String get today => 'Today';

  @override
  String get profile => 'Profile';

  @override
  String get edit_profile => 'Edit Profile';

  @override
  String get status_window => 'MONARCH STATUS WINDOW';

  @override
  String get status_window_desc =>
      'View 11-attribute matrix, equipped titles and power radar';

  @override
  String get xp_points => 'XP Points';

  @override
  String get active_streak => 'Active Streak';

  @override
  String get active_level => 'Active Level';

  @override
  String get days => 'Days';

  @override
  String get voice_chat => 'Voice Chat';

  @override
  String get speak_now => 'SPEAK NOW';

  @override
  String get hold_speak => 'Hold Core to Speak';

  @override
  String get boss_hp => 'Boss HP';

  @override
  String get system_analysis => '[SYSTEM ANALYSIS COMPLETE]';

  @override
  String get explain_rule => 'Explain Rule';

  @override
  String get provide_example => 'Provide Example';

  @override
  String get retry_battle => 'Retry Battle';

  @override
  String get type_command => 'Type command or log entry...';

  @override
  String get lesson_preview => 'Lesson Objectives and Goals';

  @override
  String get communication_goals => 'Communication Goals';

  @override
  String get recommended_phrases => 'Recommended Phrases';

  @override
  String get understood => 'Understood';

  @override
  String get start_voice_lesson => 'Start Voice Lesson Now';

  @override
  String get objectives => 'Objectives';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get master => 'Master';

  @override
  String get min_day => 'min / day';

  @override
  String get onboarding_lang => 'AWAKENING LANGUAGE';

  @override
  String get onboarding_country => 'HUNTER REGISTRY';

  @override
  String get onboarding_target => 'TARGET LANGUAGE';

  @override
  String get onboarding_cefr => 'GATE SELECTION';

  @override
  String get onboarding_goal => 'MISSION COMMITMENT';

  @override
  String get onboarding_interests => 'SKILL TREE';

  @override
  String get onboarding_correction => 'TACTICAL APPROACH';

  @override
  String get onboarding_obstacle => 'BOSS IDENTIFICATION';

  @override
  String get btn_continue => 'Continue';

  @override
  String get onboarding_start_eval => 'START EVALUATION';

  @override
  String get register_confirm_email =>
      'Check your inbox and confirm your account to continue.';

  @override
  String get resend_confirmation => 'RESEND';

  @override
  String get login_email_not_confirmed =>
      'Your email is not confirmed yet. Check your inbox or request a new link.';

  @override
  String get complete_onboarding => 'Complete Onboarding';

  @override
  String get exam_timer => 'Time Remaining';

  @override
  String get exam_pass => 'PASS';

  @override
  String get exam_fail => 'FAIL';

  @override
  String get new_rank => 'New Rank Unlocked';

  @override
  String get dungeon => 'Dungeon';

  @override
  String get quest => 'Quest';

  @override
  String get boss => 'Boss';

  @override
  String get hunter => 'Hunter';

  @override
  String get rank => 'RANK';

  @override
  String get mission => 'Mission';

  @override
  String get log_entry => 'Log Entry';

  @override
  String get system_log => 'System Log';

  @override
  String get data_stream => 'Data Stream';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get first_steps => 'First Steps';

  @override
  String get first_steps_desc =>
      'Complete your first conversation to earn your starting gear';

  @override
  String get fire_streak => 'Fire Streak';

  @override
  String get fire_streak_desc => 'Maintain a 7-day practice streak';

  @override
  String get fluent_speaker => 'Fluent Speaker';

  @override
  String get fluent_speaker_desc => 'Speak 100 words in a single session';

  @override
  String get goals_completed_desc => 'All main objectives cleared';

  @override
  String get guild_hall => 'GUILD HALL';

  @override
  String get live_coop => 'Live Co-Op Raid Rooms';

  @override
  String get initialize_room => 'Create Table';

  @override
  String get enter_raid => 'Enter Raid';

  @override
  String get hunters_active => 'Hunters Active';

  @override
  String get live_voice => 'Live Voice';

  @override
  String get barrier_active => 'Barrier Active';

  @override
  String get no_vocab => 'No vocabulary learned yet. Start a conversation!';

  @override
  String get vocab_detail => 'Vocabulary Detail';

  @override
  String get vocab_added => 'Vocabulary added';

  @override
  String xp_earned(Object amount) {
    return '+$amount XP';
  }

  @override
  String streak_days(Object count) {
    return '$count Day Streak';
  }

  @override
  String conversations_remaining(Object count) {
    return '$count conversations remaining';
  }

  @override
  String get character_name => 'HUNTER NAME';

  @override
  String get character_name_hint => 'Your adventurer name...';

  @override
  String get character_avatar => 'AVATAR';

  @override
  String get character_class => 'CLASS';

  @override
  String get oracle_title => 'THE GUILD ORACLE';

  @override
  String get oracle_assessment => 'Assessment in progress...';

  @override
  String get oracle_respond => 'Respond to the Oracle...';

  @override
  String get oracle_result => 'Assessment Complete';

  @override
  String get oracle_strengths => 'STRENGTHS';

  @override
  String get oracle_weaknesses => 'AREAS FOR IMPROVEMENT';

  @override
  String get oracle_continue => 'RECEIVE HUNTER LICENSE';

  @override
  String get nucleo_title => 'THE ARCANE CORE IS DEPLETED';

  @override
  String nucleo_desc(Object count) {
    return 'The Oracle has responded $count times today. It needs to recharge with the morning light.';
  }

  @override
  String get nucleo_rest => 'Rest until tomorrow — the Core will recharge';

  @override
  String get mod_ai => '🤖 AI Moderation';

  @override
  String get mod_creator => '👑 Creator Moderation';

  @override
  String get mod_assigned => '🎯 Assigned Moderation';

  @override
  String get mod_table_new => 'New Guild Table';

  @override
  String get mod_table_name => 'Table name';

  @override
  String get mod_description => 'Description (optional)';

  @override
  String get mod_category => 'Category';

  @override
  String get mod_type => 'MODERATION TYPE';

  @override
  String get mod_create => 'Create Table';

  @override
  String get mod_cancel => 'Cancel';

  @override
  String get mod_ai_desc => 'AI Tutor moderates automatically';

  @override
  String get mod_creator_desc => 'You moderate. Manage speakers and turns';

  @override
  String get mod_assigned_desc =>
      'Another user will be the moderator. Enter their email:';

  @override
  String get room_live => 'LIVE';

  @override
  String get room_mic => 'Microphone';

  @override
  String get room_leave => 'Leave';

  @override
  String get room_chat => 'Chat';

  @override
  String get room_audience => 'Audience';

  @override
  String get room_hand => 'Request to Speak';

  @override
  String get room_hand_raised => 'Requested';

  @override
  String room_claim_slot(Object slot) {
    return 'Claim Slot $slot';
  }

  @override
  String room_spectators(Object count) {
    return 'Spectators ($count)';
  }

  @override
  String get room_ai_moderating => 'AI Moderating';

  @override
  String get room_moderating => 'Moderating';

  @override
  String room_slot(Object slot) {
    return 'Slot $slot';
  }

  @override
  String get conversation_title => 'Voice Room';

  @override
  String get conversation_input_hint => 'Type in English...';

  @override
  String get conversation_mission_guide => 'MISSION GUIDE';

  @override
  String get conversation_voice_mode => 'Voice Mode';

  @override
  String get conversation_text_mode => 'Text Mode';

  @override
  String get conversation_speech_dna => 'Voice Fingerprint';

  @override
  String get conversation_replay => 'REPLAY';

  @override
  String get guild_master => 'GUILD MASTER';

  @override
  String get guild_online => 'ONLINE';

  @override
  String get guild_quest_daily => 'DAILY QUEST';

  @override
  String get guild_quest_speak => 'Speak 10 minutes in a voice room';

  @override
  String get guild_tables => 'GUILD TABLES';

  @override
  String get guild_create => 'Create';

  @override
  String get guild_join => 'Join';

  @override
  String get guild_enter => 'Enter';

  @override
  String get guild_no_rooms => 'No active rooms in this category.';

  @override
  String get status_panel => 'HUNTER STATUS PANEL';

  @override
  String get status_attributes => 'MONARCH ATTRIBUTES (11)';

  @override
  String get status_titles => 'LEGENDARY TITLES';

  @override
  String get status_equip => 'Equip';

  @override
  String get status_equipped => '✓';

  @override
  String get status_combat => 'COMBAT ATTRIBUTES';

  @override
  String get status_achievements => 'RARE ACHIEVEMENTS';

  @override
  String get hud_xp_total => 'TOTAL XP';

  @override
  String get hud_vocabulary => 'VOCABULARY';

  @override
  String get hud_level => 'LEVEL';

  @override
  String get hud_streak => 'STREAK';

  @override
  String get error_mic_permission =>
      'Microphone permission denied. Please enable it in settings.';

  @override
  String get error_listening => 'Listening to your voice...';

  @override
  String get error_short_audio =>
      'The recording was too short or empty. Speak again.';

  @override
  String get error_no_speech =>
      'No speech detected. Try speaking closer to the microphone.';

  @override
  String get error_recording => 'Could not create recording.';

  @override
  String get error_processing => 'Error processing the response. Try again.';

  @override
  String error_groq_connection(Object code) {
    return 'Connection error with STT ($code). Check your internet or API Key.';
  }

  @override
  String get error_nucleo => 'THE ARCANE CORE IS DEPLETED';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get no_results => 'No results found.';

  @override
  String get see_all => 'See All';

  @override
  String get learn_more => 'Learn More';

  @override
  String get get_started => 'Get Started';

  @override
  String get register_new_hunter => 'REGISTER NEW HUNTER';

  @override
  String get onboarding_select_native_warn =>
      'Select your native language to continue.';

  @override
  String get onboarding_select_target_warn =>
      'Select the language you want to learn.';

  @override
  String get onboarding_switch_interface_lang =>
      'Switch App Interface Language';

  @override
  String onboarding_switch_interface_desc(String lang) {
    return 'Change the app menus and buttons to $lang instead of English.';
  }

  @override
  String get onboarding_country_title => 'COUNTRY OF ORIGIN';

  @override
  String get onboarding_country_desc =>
      'Tell us where you are from to adapt pronunciation and expressions.';

  @override
  String get onboarding_country_search_hint => 'Search country...';

  @override
  String get onboarding_country_no_results => 'No countries found.';

  @override
  String get onboarding_oracle_classification => 'THE ORACLE WILL CLASSIFY YOU';

  @override
  String get onboarding_oracle_classification_desc =>
      'The Oracle will analyze your language proficiency through a conversation to determine your starting rank.';

  @override
  String get onboarding_voice_evaluation => 'VOICE CONVERSATIONAL EVALUATION';

  @override
  String get onboarding_voice_evaluation_desc =>
      'Speak to the Oracle and you will be evaluated on pronunciation, vocabulary, grammar, comprehension, and fluency. The result will define your starting rank.';

  @override
  String get onboarding_start_evaluation => 'START EVALUATION';

  @override
  String get onboarding_evaluation_optional =>
      'The evaluation is optional: if you skip it, you will start at the initial rank (A1).';

  @override
  String get welcome_hunter_prefix => 'WELCOME,';

  @override
  String get welcome_hunter_suffix => 'HUNTER!';

  @override
  String get adventure_begins => 'Your adventure begins now.';

  @override
  String get enter_realm => 'ENTER THE REALM';

  @override
  String get character_creation_title => 'CREATE YOUR CHARACTER';

  @override
  String get character_creation_desc =>
      'Before starting your adventure, we need to know who you are.';

  @override
  String get character_creation_continue => 'THE ORACLE AWAITS YOU';

  @override
  String get character_name_optional =>
      'Optional — your account name will be used if empty.';

  @override
  String get character_class_unavailable =>
      'Classes unavailable. Try again later.';

  @override
  String get character_difficulty_label => 'Difficulty';

  @override
  String get character_combat_label => 'Combat';

  @override
  String get character_affinity_label => 'Affinity';

  @override
  String get character_abilities_label => 'ABILITIES';

  @override
  String get character_stat_attack => 'Attack';

  @override
  String get character_stat_defense => 'Defense';

  @override
  String get character_stat_magic => 'Magic';

  @override
  String get character_stat_speed => 'Speed';

  @override
  String get character_stat_support => 'Support';

  @override
  String get character_stat_survival => 'Survival';

  @override
  String get class_warrior_name => 'Berserker';

  @override
  String get class_warrior_desc =>
      'Outspoken and brave. You speak first and think later. Ideal for overcoming the fear of speaking.';

  @override
  String get class_warrior_arch =>
      'Extroverted, speaks first — overcoming fear';

  @override
  String get class_mage_name => 'Arcane Mage';

  @override
  String get class_mage_desc =>
      'Analytical and precise. You observe and structure before speaking. Ideal for perfecting grammar.';

  @override
  String get class_mage_arch =>
      'Analytical, structures before speaking — grammar';

  @override
  String get class_assassin_name => 'Assassin';

  @override
  String get class_assassin_desc =>
      'Tactical observer. You aim for precision and stealthy efficiency. Ideal for high-accuracy vocabulary.';

  @override
  String get class_assassin_arch => 'Tactical observer — precision vocabulary';

  @override
  String get class_knight_name => 'Knight';

  @override
  String get class_knight_desc =>
      'Constant and methodical. You stand firm in your routines. Ideal for building streaks and consistency.';

  @override
  String get class_knight_arch =>
      'Constant and methodical — consistency & streaks';

  @override
  String get class_archer_name => 'Archer';

  @override
  String get class_archer_desc =>
      'Agile and quick. You learn on the go within context. Ideal for mastering useful expressions.';

  @override
  String get class_archer_arch =>
      'Agile, context-driven learner — daily expressions';

  @override
  String get class_summoner_name => 'Summoner';

  @override
  String get class_summoner_desc =>
      'Creative and associative. You connect concepts and conjure ideas. Ideal for idiomatic phrases.';

  @override
  String get class_summoner_arch =>
      'Creative, associative thinker — idioms & phrasing';

  @override
  String get class_paladin_name => 'Paladin';

  @override
  String get class_paladin_desc =>
      'Goal-driven protector. Guided by clear duties. Ideal for formal and structured conversations.';

  @override
  String get class_paladin_arch => 'Goal-driven learner — formal conversation';

  @override
  String get class_necromancer_name => 'Necromancer';

  @override
  String get class_necromancer_desc =>
      'Etymological explorer. You resurrect the roots of the language. Ideal for Latin roots and word origins.';

  @override
  String get class_necromancer_arch =>
      'Curious about etymology — Latin roots & history';

  @override
  String get onboarding_lang_desc =>
      'We will personalize your learning journey according to your native language.';

  @override
  String get onboarding_native_lang => 'Native Language';

  @override
  String get onboarding_target_desc =>
      'Select the language you want to master.';

  @override
  String get onb_validate_native => 'Select your native language to continue.';

  @override
  String get onb_validate_target => 'Select the language you want to learn.';

  @override
  String get login_google_error => 'Error signing in with Google.';

  @override
  String get register_google_error => 'Error registering with Google.';

  @override
  String get oracle_no_voice =>
      'No voice detected. Speak closer to the microphone or use the keyboard.';

  @override
  String get oracle_listening => 'LISTENING... RELEASE TO SEND';

  @override
  String get oracle_processing => 'PROCESSING WITH GROQ AI...';

  @override
  String get oracle_skip => 'SKIP QUESTION';

  @override
  String get oracle_complete => 'COMPLETE ASSESSMENT';

  @override
  String get room_no_messages => 'No messages in this chamber yet.';

  @override
  String room_error(String err) {
    return 'Room error: $err';
  }

  @override
  String get room_hunt_lang => 'Hunting Language:';

  @override
  String get room_xp_points => 'Experience Points:';

  @override
  String get room_type_ai => 'AI TRAINING';

  @override
  String get room_type_mentorship => 'MENTORSHIP (RESONANCE)';

  @override
  String get room_type_event => 'SPECIAL EVENT';

  @override
  String get room_cancel => 'CANCEL';

  @override
  String room_create_error(String err) {
    return 'Error creating room: $err';
  }

  @override
  String get room_initialize => 'INITIALIZE';

  @override
  String room_prestige(String level) {
    return 'PRESTIGE $level';
  }

  @override
  String get mission_accept => 'ACCEPT';

  @override
  String get mission_none => 'NO ACTIVE MISSIONS';

  @override
  String get mission_generate => 'GENERATE MISSIONS';

  @override
  String get mission_claim => 'CLAIM';

  @override
  String get srs_close => 'CLOSE';

  @override
  String get srs_hard => 'HARD';

  @override
  String get srs_review_title => 'DAILY REVIEW';

  @override
  String srs_review_due(int count) {
    return '$count words waiting for review';
  }

  @override
  String get npc_remembers_failure => 'THE NPC REMEMBERS YOUR LAST ATTEMPT';

  @override
  String get npc_remembers_partial => 'THE NPC REMEMBERS YOU ALMOST MADE IT';

  @override
  String get srs_review_cta => 'REVIEW';

  @override
  String srs_retention(int percent, int mastered) {
    return '$percent% recalled after 7 days · $mastered mastered';
  }

  @override
  String get srs_normal => 'NORMAL';

  @override
  String get srs_easy => 'EASY';

  @override
  String get nucleo_recharge => 'RECHARGE +5';

  @override
  String get nucleo_premium => 'GO PREMIUM';

  @override
  String get nucleo_unlimited => 'Unlimited Invocations — Elite Hunter';

  @override
  String get paywall_success =>
      'Thank you for subscribing! Premium benefits unlocked.';

  @override
  String paywall_failure(String err) {
    return 'Purchase failure: $err';
  }

  @override
  String get paywall_restored => 'Purchases successfully restored.';

  @override
  String get paywall_nothing_to_restore => 'There are no purchases to restore.';

  @override
  String get lessons_voice_rooms => 'Voice Rooms';

  @override
  String get lessons_view_goals => 'View Goals';

  @override
  String get exam_mute => 'MUTE';

  @override
  String get exam_conclude => 'CONCLUDE RAID';

  @override
  String get exam_return => 'RETURN TO SANCTUARY';

  @override
  String get progress_xp_points => 'XP Points';

  @override
  String get progress_active_streak => 'Active Streak';

  @override
  String get progress_active_level => 'Active Level';

  @override
  String get progress_active_rank => 'Guild Rank';

  @override
  String get radar_fluency => 'Fluency';

  @override
  String get radar_vocab => 'Vocabulary';

  @override
  String get radar_phonetics => 'Phonetics';

  @override
  String get radar_grammar => 'Grammar';

  @override
  String get radar_comprehension => 'Comprehension';

  @override
  String get radar_naturalness => 'Naturalness';

  @override
  String get progress_srs_review => 'SRS Review';

  @override
  String get progress_see_all => 'VIEW ALL';

  @override
  String get inventory_load_error => 'Could not load inventory';

  @override
  String get inventory_empty => 'EMPTY INVENTORY';

  @override
  String get inventory_visit_shop => 'VISIT THE SHOP →';

  @override
  String get inventory_equipped => 'EQUIPPED';

  @override
  String get conversation_goals => 'Scenario Goals:';

  @override
  String get conversation_key_phrases => 'Suggested Key Phrases:';

  @override
  String get conversation_phonemes => 'Phonemes to practice:';

  @override
  String get hero_got_it => 'Got it';

  @override
  String get hero_cefr_label => 'CEFR';

  @override
  String get hero_class_label => 'Class';

  @override
  String get hero_member_since => 'Member since';

  @override
  String get summary_view_vocab => 'VIEW VOCABULARY';

  @override
  String get summary_vocab_title => 'SESSION VOCABULARY';

  @override
  String get summary_vocab_empty => 'No words saved from this session yet.';

  @override
  String get summary_vocab_saved => 'Vocabulary saved to your profile.';

  @override
  String get summary_done => 'DONE';

  @override
  String get collections_load_error => 'Could not load collections';

  @override
  String get profile_total_xp => 'Total XP';

  @override
  String get profile_streak => 'Active streak';

  @override
  String get profile_cefr_level => 'CEFR Level';

  @override
  String get profile_vocab_error => 'Error loading vocabulary';

  @override
  String get profile_vocab_empty =>
      'You haven\'t learned vocabulary in conversations yet.';

  @override
  String get profile_close => 'Close';

  @override
  String get battlepass_load_error => 'Could not load Battle Pass';

  @override
  String get profile_edit_camera => 'CAMERA';

  @override
  String get profile_edit_gallery => 'GALLERY';

  @override
  String get chart_4weeks => '4 weeks ago';

  @override
  String get chart_today => 'Today';

  @override
  String get chart_latency => 'Latency (s)';

  @override
  String get aura_title => 'AURA';

  @override
  String get aura_locked => 'AURA LOCKED';

  @override
  String get aura_locked_desc =>
      'Complete the Basic Stage (PRE-A1 + A1 + A2) to awaken your power.';

  @override
  String get aura_awakened => 'AURA USER';

  @override
  String get aura_basic_stage => 'BASIC STAGE';

  @override
  String get aura_power => 'POWER';

  @override
  String get aura_tier_latente => 'LATENT';

  @override
  String get aura_tier_revelada => 'REVEALED';

  @override
  String get aura_tier_abierta => 'OPEN';

  @override
  String get aura_tier_dominante => 'DOMINANT';

  @override
  String get aura_tier_abisal => 'ABYSSAL';

  @override
  String get aura_awakening_banner_title => 'THE SYSTEM HAS SPOKEN';

  @override
  String get aura_awakening_banner_desc =>
      'You have awakened as an Aura User. Your power will grow with your skills.';

  @override
  String get ok => 'OK';

  @override
  String get shop => 'SHOP';

  @override
  String get map => 'MAP';

  @override
  String get claimed => 'CLAIMED';

  @override
  String get notifications => 'Notifications';

  @override
  String get missions => 'Missions';

  @override
  String get oracle => 'ORACLE';

  @override
  String get pro_badge => 'PRO';

  @override
  String get go_pro => 'GO PRO';

  @override
  String get logout_confirm_title => 'LOG OUT?';

  @override
  String get logout_confirm_desc =>
      'Your progress is saved. You will need to log in again to continue.';

  @override
  String get splash_system_hud => 'SYSTEM HUD · AWAKENING';

  @override
  String splash_connecting(int pct) {
    return '$pct% · CONNECTING TO THE GREAT REALM';
  }

  @override
  String get connecting_realm => 'CONNECTING TO THE GREAT REALM...';

  @override
  String get system_hunter_connected => 'HUNTER SYSTEM — CONNECTED';

  @override
  String cefr_level(String code) {
    return 'CEFR $code';
  }

  @override
  String level_up_banner(int level) {
    return '¡LEVEL UP! $level';
  }

  @override
  String title_earned_banner(String title) {
    return '🏅 TITLE EARNED: $title';
  }

  @override
  String get mana_label => 'MANA';

  @override
  String get mana_available => 'mana available';

  @override
  String get mana_daily_available => 'mana available today';

  @override
  String get guardian_title => 'MANA SANCTUARY';

  @override
  String get guardian_sealed => 'Sealed';

  @override
  String get guardian_cry => 'YOUR MANA IS DEPLETED.\nTHE SANCTUARY AWAITS.';

  @override
  String get guardian_desc =>
      'Every AI action costs mana. Recover it with your plan, potions, or an elixir/gem from your bag.';

  @override
  String get guardian_get_mana => 'GET MANA';

  @override
  String get guardian_get_mana_desc => 'MORE MANA PER MONTH BY ESTATE';

  @override
  String get guardian_equip_item => 'EQUIP ELIXIR / GEM';

  @override
  String get guardian_equip_item_desc => 'Equip a mana item from your bag';

  @override
  String get guardian_go_back => 'Return to the Guild';

  @override
  String mana_balance(int remaining, int total) {
    return '$remaining / $total mana';
  }

  @override
  String plus_mana(int count) {
    return '+$count mana';
  }

  @override
  String purchase_confirm_question(String name, String price) {
    return 'Acquire \"$name\" for $price?';
  }

  @override
  String get mana_tooltip =>
      'MANA: energy for every AI action (Oracle, dungeons, chats). Acquired with your plan and potions/gems; expires with the cycle.';

  @override
  String mana_expires(String date) {
    return 'expires $date';
  }

  @override
  String get aura_locked_tooltip =>
      'BASIC STAGE: complete the PRE-A1, A1 and A2 mission objectives to awaken your Aura.';

  @override
  String get aura_awakened_tooltip =>
      'AURA: uncapped merit. Keep accumulating with every evaluated session.';

  @override
  String aura_xp(int xp) {
    return 'AURA XP $xp';
  }

  @override
  String aura_next_rank(int pct) {
    return '$pct% to next rank';
  }

  @override
  String get aura_rank_mismatch => '⚠ RANK INCONSISTENT WITH CEFR';

  @override
  String get daily_reward_title => 'DAILY REWARD';

  @override
  String daily_reward_streak(int streak) {
    return 'CURRENT STREAK: $streak DAYS';
  }

  @override
  String daily_reward_gems(int gems) {
    return '$gems GEMS';
  }

  @override
  String get daily_reward_by_streak => 'BY STREAK';

  @override
  String daily_reward_parchments(int count) {
    return '+$count SCROLLS';
  }

  @override
  String get daily_reward_cap => 'DAILY CAP';

  @override
  String get daily_reward_keep_streak =>
      'KEEP YOUR STREAK: AT 7 DAYS YOU EARN 50 GEMS AND 5 SCROLLS';

  @override
  String get daily_reward_at_14 => 'AT 14 DAYS: 100 GEMS AND 8 SCROLLS';

  @override
  String get daily_reward_at_30 => 'AT 30 DAYS: 300 GEMS AND 15 SCROLLS';

  @override
  String get daily_reward_max_streak => 'MAX STREAK REACHED!';

  @override
  String get claiming => 'CLAIMING...';

  @override
  String get daily_reward_claimed_today => 'DAILY REWARD CLAIMED TODAY';

  @override
  String get daily_reward_claim => 'CLAIM REWARD';

  @override
  String get no_mana => 'NO MANA';

  @override
  String mana_exhausted_desc(String renew) {
    return 'Every AI action costs mana. Your balance ran out.\n\nMana is acquired with your plan or potions/gems.\n$renew';
  }

  @override
  String mana_renews_on(String date) {
    return 'Your cycle renews on $date.';
  }

  @override
  String get more_mana_monthly => 'MORE MONTHLY MANA BY RANK';

  @override
  String get wait_plan_renewal => 'Wait for my plan renewal';

  @override
  String get hunter_collections => 'HUNTER COLLECTIONS';

  @override
  String get no_trophies => 'NO TROPHIES RECORDED';

  @override
  String get confirm_purchase => 'CONFIRM PURCHASE';

  @override
  String get buy => 'BUY';

  @override
  String get cosmetic_purchased => 'COSMETIC ACQUIRED! 🪙';

  @override
  String get gold_insufficient => 'INSUFFICIENT GOLD OR ALREADY OWNED ❌';

  @override
  String get cosmetic_title => 'TITLE';

  @override
  String get cosmetic_frame => 'FRAME';

  @override
  String get cosmetic_aura => 'AURA';

  @override
  String get cosmetic_pet => 'COMPANION';

  @override
  String get cosmetic_emote => 'EMOTE';

  @override
  String get cosmetic_theme => 'THEME';

  @override
  String get arcane_shop => 'ARCANE SHOP';

  @override
  String get gold_shop_tab => 'GOLD SHOP';

  @override
  String get redeem => 'REDEEM';

  @override
  String get my_items => 'MY ITEMS';

  @override
  String get mana_potions_title => 'MANA POTIONS';

  @override
  String get mana_potions_desc =>
      'Mana is the energy of every AI action. It is acquired with real money: your rank includes a monthly allowance and potions extend it.';

  @override
  String get mana_gems_packs_title => 'MANA GEM PACKS';

  @override
  String get gold_shop_unavailable =>
      'The Gold Shop is not available yet.\nPlease try again in a moment.';

  @override
  String get owned => 'OWNED';

  @override
  String price_gold(String price) {
    return '$price GOLD';
  }

  @override
  String price_gems(String price) {
    return '$price GEMS';
  }

  @override
  String craft_cost(String cost) {
    return '$cost FRAGMENTS';
  }

  @override
  String get craft_action => 'CRAFT';

  @override
  String get craft_success => 'COSMETIC CRAFTED!';

  @override
  String get shop_tab_gems => 'GEMS';

  @override
  String get shop_tab_gold => 'GOLD';

  @override
  String get shop_tab_fragments => 'FRAGMENTS';

  @override
  String get shop_tab_empty => 'No items in this currency yet.';

  @override
  String get shop_level_locked => 'HUNTER LEVEL TOO LOW';

  @override
  String shop_next_unlock(String name, int level) {
    return 'NEXT UNLOCK: $name · LV. $level';
  }

  @override
  String shop_plan_required_body(String plan) {
    return 'This item is exclusive to the $plan plan.';
  }

  @override
  String get gems_insufficient => 'INSUFFICIENT GEMS';

  @override
  String get purchase_failed => 'PURCHASE FAILED';

  @override
  String level_label(String level) {
    return 'LV. $level';
  }

  @override
  String level_rewards_pending(int count) {
    return '$count LEVEL REWARDS';
  }

  @override
  String level_rewards_banner_hint(String level) {
    return 'LEVEL $level REACHED · CLAIM YOUR GOLD';
  }

  @override
  String level_rewards_claim(int count) {
    return 'CLAIM $count';
  }

  @override
  String level_rewards_claimed_ok(int count) {
    return '$count LEVEL REWARDS CLAIMED!';
  }

  @override
  String get level_rewards_none => 'NO REWARDS TO CLAIM';

  @override
  String get streak_freeze_title => 'STREAK FREEZE';

  @override
  String get streak_freeze_desc => 'Protects one missed day. Max 3.';

  @override
  String get streak_freeze_cap => 'MAX FREEZES REACHED';

  @override
  String get streak_freeze_max => 'MAXED';

  @override
  String get streak_freeze_bought => 'STREAK FREEZE ACQUIRED!';

  @override
  String get fragments_insufficient => 'INSUFFICIENT FRAGMENTS ❌';

  @override
  String get redeem_error => 'EXCHANGE ERROR ❌';

  @override
  String get fragments_exchange_title => 'FRAGMENT EXCHANGE';

  @override
  String get fragments_exchange_desc =>
      'FRAGMENTS ARE THE EXCHANGE CURRENCY. CHOOSE WISELY, HUNTER.';

  @override
  String battle_reward_claimed_tier(int tier) {
    return 'TIER $tier REWARD CLAIMED';
  }

  @override
  String get not_available => 'NOT AVAILABLE';

  @override
  String get battle_pass => 'BATTLE PASS';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free_tier => 'FREE';

  @override
  String battle_level(int level) {
    return 'LEVEL $level';
  }

  @override
  String get battle_progress_label => 'Battle Pass progress: ';

  @override
  String get rewards => 'REWARDS';

  @override
  String reward_claimed_tier(int tier) {
    return 'Reward level $tier claimed';
  }

  @override
  String reward_unlocked_tier(int tier) {
    return 'Reward level $tier unlocked';
  }

  @override
  String reward_locked_tier(int tier) {
    return 'Reward level $tier locked, unlock at level $tier';
  }

  @override
  String battle_tier(int tier) {
    return 'TIER $tier';
  }

  @override
  String get reward_unlocked => 'Reward unlocked';

  @override
  String unlock_at_level(int tier) {
    return 'Unlock at level $tier';
  }

  @override
  String battle_claim_reward(int tier) {
    return 'Claim level $tier reward';
  }

  @override
  String get equipment_updated => 'EQUIPMENT UPDATED';

  @override
  String get inventory => 'INVENTORY';

  @override
  String get unequip => 'UNEQUIP';

  @override
  String get equip => 'EQUIP';

  @override
  String get chat_category_all => 'All';

  @override
  String get chat_cat_general => 'General';

  @override
  String get chat_cat_travel => 'Travel';

  @override
  String get chat_cat_business => 'Business';

  @override
  String get chat_cat_technology => 'Technology';

  @override
  String get chat_cat_art => 'Art';

  @override
  String get chat_cat_cooking => 'Cooking';

  @override
  String get chat_rank_status => 'RANK STATUS';

  @override
  String get chat_hunter_details => 'HUNTER DETAILS';

  @override
  String chat_rank_level(String code) {
    return 'RANK $code';
  }

  @override
  String get chat_establish_table => 'ESTABLISH GUILD TABLE';

  @override
  String get chat_create_room => 'CREATE NEW CHAT ROOM';

  @override
  String get chat_table_title => 'GUILD TABLE TITLE';

  @override
  String get chat_category_path => 'CATEGORY PATH';

  @override
  String get chat_table_type => 'TABLE TYPE';

  @override
  String get chat_missions => 'MISSIONS';

  @override
  String get chat_guild_pass => 'GUILD PASS';

  @override
  String get chat_rank => 'RANK';

  @override
  String get chat_collections => 'COLLECTIONS';

  @override
  String get chat_music_on => 'MUSIC ON';

  @override
  String get chat_music => 'MUSIC';

  @override
  String get chat_status_full => 'FULL';

  @override
  String get chat_status_nearly_full => 'NEARLY FULL';

  @override
  String get chat_status_occupied => 'OCCUPIED';

  @override
  String get chat_status_space => 'SPACE';

  @override
  String get chat_type_mentorship => 'MENTORSHIP';

  @override
  String get chat_type_ai => 'AI';

  @override
  String get chat_type_event => 'EVENT';

  @override
  String chat_rank_line(String rank, String cefr) {
    return 'RANK: $rank · $cefr';
  }

  @override
  String get chat_free => 'FREE';

  @override
  String get chat_rank_silver => 'SILVER';

  @override
  String get chat_rank_gold => 'GOLD';

  @override
  String get chat_rank_iron => 'IRON';

  @override
  String get voice_seat_to_speak => 'SIT DOWN TO SPEAK';

  @override
  String voice_seated_in(String seat) {
    return 'YOU SAT IN SEAT $seat';
  }

  @override
  String get voice_seat_assigned => 'SEAT ASSIGNED. Welcome!';

  @override
  String get voice_seats_full_queue => 'SEATS FULL: YOU ENTER THE QUEUE';

  @override
  String get voice_seat_freed => 'SEAT FREED. STANDING';

  @override
  String get voice_standing => 'HUNTER STANDING UP';

  @override
  String get voice_not_moderator => 'YOU ARE NOT THE MODERATOR OF THIS TABLE';

  @override
  String get voice_chamber_chat => 'CHAMBER TEXT CHAT';

  @override
  String get voice_free_mission => 'FREE MISSION';

  @override
  String get voice_guild_chamber => 'GUILD VOICE CHAMBER';

  @override
  String get voice_moderated => 'Guild voice room';

  @override
  String get voice_leave => 'Leave the room';

  @override
  String get voice_demo_banner =>
      'GUILD AUDIO: DEMO — hunters connected live. Voice practice is 1:1.';

  @override
  String get voice_demo_banner_alt => 'AUDIO DEMO — TAP FOR DETAILS';

  @override
  String get voice_room_mission => 'ROOM MISSION';

  @override
  String get voice_resonance => 'RESONANCE';

  @override
  String get voice_your_seat => 'YOUR SEAT';

  @override
  String voice_seat_number(String slot) {
    return 'SEAT $slot';
  }

  @override
  String get voice_tap_to_sit => 'TAP TO SIT';

  @override
  String get voice_you => 'YOU';

  @override
  String voice_hunter_slot(String slot) {
    return 'HUNTER $slot';
  }

  @override
  String get voice_speaking => 'SPEAKING';

  @override
  String get voice_seated => 'SEATED';

  @override
  String voice_standing_count(int count) {
    return 'STANDING ($count/8)';
  }

  @override
  String get voice_you_standing => 'You (standing)';

  @override
  String get voice_standing_hunter => 'Standing hunter';

  @override
  String voice_chat_title(int count) {
    return 'Chamber Text Chat ($count)';
  }

  @override
  String get voice_mic_on => 'MIC ON';

  @override
  String get voice_mic_off => 'MIC OFF';

  @override
  String get voice_stand_up => 'STAND UP';

  @override
  String voice_in_queue(int pos) {
    return 'IN QUEUE #$pos';
  }

  @override
  String get voice_seat => 'SEAT';

  @override
  String get voice_exit => 'EXIT';

  @override
  String get guild_rec_beginner =>
      'I recommend the Apprentice Tavern: the perfect table for novice hunters.';

  @override
  String get guild_rec_intermediate =>
      'The Tactics Round Table awaits: debates and intermediate fluency.';

  @override
  String get guild_rec_master =>
      'The Supreme Council of High Hunters is your place: master-level eloquence.';

  @override
  String get guild_rec_default =>
      'Choose a table and start your conversation raid.';

  @override
  String get guild_table_beginner => 'Apprentice';

  @override
  String get guild_table_tactics => 'Tactics';

  @override
  String get guild_table_council => 'Council';

  @override
  String guild_rank_level(String cefr) {
    return 'RANK $cefr';
  }

  @override
  String get guild_follow_suggestion => 'FOLLOW MY SUGGESTION —>';

  @override
  String guild_ask_master(String cefr) {
    return 'Ask the Master (Level $cefr):';
  }

  @override
  String get guild_ask_hint =>
      'Ask me which table to practice, which mission to take or how to improve your rank.';

  @override
  String get guild_input_hint => 'Write your question...';

  @override
  String get guild_meditating => 'The Table Master is meditating... Try again.';

  @override
  String get mission_board_title => 'MISSION BOARD';

  @override
  String mission_board_player_rank(String playerRank) {
    return 'ADVENTURER · RANK $playerRank';
  }

  @override
  String get mission_completed_active => '✓ COMPLETED';

  @override
  String get mission_completed => 'COMPLETED';

  @override
  String get mission_filter_all => 'ALL';

  @override
  String get mission_filter_daily => 'DAILY';

  @override
  String get mission_filter_weekly => 'WEEKLY';

  @override
  String get mission_filter_collaborative => 'COLLABORATIVE';

  @override
  String get mission_filter_rarity_all => 'RARITY: ALL';

  @override
  String get mission_search_hint => 'Search mission by name...';

  @override
  String get mission_board_empty_filtered =>
      'No guild missions match these filters.';

  @override
  String mission_view_more(int count) {
    return 'VIEW MORE MISSIONS ($count remaining)';
  }

  @override
  String get mission_completed_empty =>
      'You haven\'t completed any guild missions yet.';

  @override
  String get mission_login_required => 'Log in to accept missions.';

  @override
  String mission_insufficient_rank(String rank) {
    return '🔒 INSUFFICIENT RANK: you need rank $rank.';
  }

  @override
  String mission_accept_success(String title) {
    return '✅ Mission accepted: $title';
  }

  @override
  String get mission_accept_failed =>
      'Could not accept (quota full or insufficient rank).';

  @override
  String get mission_high_rank_title => 'HIGH RANK MISSION';

  @override
  String mission_high_rank_confirm(String title, String rank) {
    return 'Are you sure you want to undertake \"$title\" (rank $rank)? It is an elite guild mission.';
  }

  @override
  String mission_reward_earned(int xp, int gems) {
    return '+$xp XP  ·  +$gems 💎';
  }

  @override
  String get mission_claim_failed => 'Could not claim the reward.';

  @override
  String get mission_npc_collaborative => 'Table Master · Guild';

  @override
  String get mission_npc_vocabulary => 'Guild Librarian';

  @override
  String get mission_npc_writing => 'Royal Scribe';

  @override
  String get mission_npc_argumentation => 'Debate Consul';

  @override
  String get mission_npc_default => 'Table Master';

  @override
  String get mission_difficulty_unknown => 'Unknown';

  @override
  String mission_difficulty_label(String rank) {
    return 'Rank $rank';
  }

  @override
  String get mission_time_daily => '~10-15 min';

  @override
  String get mission_time_weekly => '~45-60 min';

  @override
  String get mission_time_collaborative => '~30 min';

  @override
  String get mission_time_default => '~20 min';

  @override
  String get mission_load_error => 'Could not load the mission.';

  @override
  String get mission_not_found => 'Mission not found.';

  @override
  String get mission_detail_title => 'MISSION DETAIL';

  @override
  String mission_rarity_type_label(String rarity, String type) {
    return '$rarity · $type';
  }

  @override
  String get mission_section_description => 'DESCRIPTION';

  @override
  String get mission_npc_label => 'NPC';

  @override
  String get mission_stat_level => 'LEVEL';

  @override
  String get mission_stat_xp => 'XP';

  @override
  String get mission_stat_gold => 'GOLD';

  @override
  String get mission_stat_time => 'TIME';

  @override
  String get mission_stat_objective => 'OBJECTIVE';

  @override
  String get mission_section_objectives => 'OBJECTIVES';

  @override
  String mission_objectives_goal(int target, String objectiveType) {
    return 'Complete $target of $objectiveType.';
  }

  @override
  String get mission_claiming => 'CLAIMING...';

  @override
  String get mission_in_progress_chat => 'IN PROGRESS · GO TO CHAT';

  @override
  String get mission_reject => 'REJECT';

  @override
  String mission_rank_required(String rank) {
    return 'RANK $rank REQUIRED';
  }

  @override
  String get mission_rarity_common => 'COMMON';

  @override
  String get mission_rarity_uncommon => 'UNCOMMON';

  @override
  String get mission_rarity_rare => 'RARE';

  @override
  String get mission_rarity_epic => 'EPIC';

  @override
  String get mission_rarity_legendary => 'LEGENDARY';

  @override
  String get mission_rarity_guild => 'GUILD SPECIAL';

  @override
  String get mission_status_available => 'AVAILABLE';

  @override
  String get mission_status_accepted => 'ACCEPTED';

  @override
  String get mission_status_in_progress => 'IN PROGRESS';

  @override
  String get mission_status_completed => 'COMPLETED';

  @override
  String get mission_status_repeatable => 'REPEATABLE';

  @override
  String get mission_status_blocked => 'BLOCKED';

  @override
  String get mission_status_recommended => 'RECOMMENDED';

  @override
  String get mission_status_special => 'SPECIAL';

  @override
  String get session_title => 'Summary';

  @override
  String get summary_reward_gold => 'GOLD';

  @override
  String get summary_reward_fragments => 'FRAGMENTS';

  @override
  String get summary_reward_pending =>
      'We couldn\'t confirm your reward. Your progress is saved; it will refresh on the next load.';

  @override
  String get session_completed => 'SESSION COMPLETED';

  @override
  String get session_good_job => 'Great job!';

  @override
  String session_words_spoken(int count) {
    return 'You spoke $count words with good pacing.';
  }

  @override
  String get summary_remedial_title => 'REINFORCEMENT';

  @override
  String get summary_remedial_generated =>
      'We built a lesson from your recurring mistakes and the goals you missed.';

  @override
  String get summary_remedial_reused => 'Your reinforcement lesson is ready.';

  @override
  String get summary_remedial_play => 'PRACTICE MY WEAKNESSES';

  @override
  String get summary_remedial_no_evidence =>
      'No reinforcement lesson yet: we need your recorded mistakes or a missed goal to aim it.';

  @override
  String get summary_remedial_insufficient_mana =>
      'You don\'t have enough mana for a reinforcement lesson. It will be available once your balance renews.';

  @override
  String get summary_remedial_failed =>
      'We couldn\'t create the reinforcement lesson. Your mana was refunded.';

  @override
  String summary_remedial_cost(int cost) {
    return 'Cost: $cost mana';
  }

  @override
  String get summary_remedial_retry => 'TRY AGAIN';

  @override
  String get session_ready => 'Practice ready to start.';

  @override
  String get session_excellent_performance => 'Excellent performance!';

  @override
  String get session_ready_first => 'Ready for your first session!';

  @override
  String get session_duration => 'DURATION';

  @override
  String get session_words => 'WORDS';

  @override
  String get session_accuracy => 'ACCURACY (EST.)';

  @override
  String get session_fluency => 'Fluency (est.)';

  @override
  String get session_pronunciation => 'Pronunciation';

  @override
  String get session_feedback => 'Feedback';

  @override
  String get session_no_errors =>
      'No grammar or phonetics errors were recorded.';

  @override
  String get session_talk_tutor => 'Talk with the AI tutor to get feedback.';

  @override
  String get session_performance => 'Performance';

  @override
  String get session_excellent => 'Excellent';

  @override
  String get session_correction => 'Correction';

  @override
  String get session_grammar => 'Grammar';

  @override
  String get session_bonus => 'Session Bonus';

  @override
  String get session_maintained => 'Maintained';

  @override
  String get summary_learned_title => 'WHAT YOU LEARNED';

  @override
  String get summary_learned_words => 'NEW AND REVIEWED WORDS';

  @override
  String get summary_learned_word_new => 'NEW';

  @override
  String get summary_learned_word_review => 'REVIEW';

  @override
  String get summary_learned_no_words =>
      'No vocabulary was recorded in this session yet.';

  @override
  String get summary_learned_corrections => 'CORRECTIONS';

  @override
  String get summary_learned_no_corrections =>
      'No corrections: you communicated clearly this time.';

  @override
  String get summary_learned_focus => 'RECOMMENDED FOCUS';

  @override
  String get summary_learned_no_focus =>
      'Not enough data for a recommendation yet.';

  @override
  String get summary_learned_loading => 'Loading your session data...';

  @override
  String get summary_learned_error =>
      'We couldn\'t load what you learned. Check your connection and try again.';

  @override
  String summary_learned_minutes_value(int count) {
    return '$count min';
  }

  @override
  String get summary_goals => 'GOALS';

  @override
  String get summary_turns => 'TURNS';

  @override
  String summary_turns_value(int count) {
    return '$count turns';
  }

  @override
  String get summary_reward_loading => 'Confirming your reward...';

  @override
  String get summary_reward_error =>
      'We couldn\'t confirm your reward. Check your connection and try again.';

  @override
  String get summary_retry => 'TRY AGAIN';

  @override
  String get summary_review_words => 'REVIEW WORDS';

  @override
  String get profile_status_panel => 'STATUS PANEL';

  @override
  String get profile_hunter_window => 'HUNTER STATUS WINDOW';

  @override
  String profile_learning(String language, String emoji) {
    return 'Learning $language $emoji';
  }

  @override
  String get profile_weekly_minutes => 'Weekly Practice Minutes';

  @override
  String get profile_vocab_learned => 'Vocabulary Learned';

  @override
  String get profile_explore => 'Explore';

  @override
  String get profile_learn => 'Learn';

  @override
  String get profile_title => 'Profile';

  @override
  String get quest_daily_title => 'Daily Quests';

  @override
  String quest_claimed(int xp) {
    return 'Reward claimed! +$xp XP';
  }

  @override
  String get quest_empty => 'No active daily quests right now.';

  @override
  String get quest_speak_10min => 'Speak 10 minutes of voice';

  @override
  String get quest_desc_session => 'Complete a fluid conversational session';

  @override
  String get quest_learn_5_words => 'Learn 5 new words';

  @override
  String get quest_desc_vocab => 'Accumulate vocabulary in your calls';

  @override
  String get quest_85_pronunciation => 'Achieve >85% in Pronunciation';

  @override
  String get quest_desc_pronunciation => 'Pass a voice-print test';

  @override
  String get missions_title => 'Missions';

  @override
  String get missions_tab_daily => 'Daily';

  @override
  String get missions_tab_weekly => 'Weekly';

  @override
  String get missions_spotlight => 'MISSION OF THE DAY';

  @override
  String get missions_see_all => 'SEE ALL';

  @override
  String get missions_reset_hint => 'Automatic renewal: 00:05 UTC';

  @override
  String get missions_empty_daily =>
      'No daily missions yet. New ones arrive every day at 00:05 UTC.';

  @override
  String get missions_empty_weekly =>
      'No weekly missions yet. They are assigned with the daily 00:05 UTC cycle.';

  @override
  String get missions_unavailable => 'Unavailable';

  @override
  String get missions_unavailable_hint =>
      'This mission cannot be completed with the current tracking.';

  @override
  String missions_claim_xp(int xp) {
    return 'Claim +$xp XP';
  }

  @override
  String missions_claim_success(int xp, int gems) {
    return 'Reward claimed: +$xp XP · +$gems gems';
  }

  @override
  String get missions_claim_already => 'You already claimed this reward.';

  @override
  String get missions_claim_error =>
      'We couldn\'t claim the reward. Check your connection and try again.';

  @override
  String get missions_load_error =>
      'We couldn\'t load your missions. Tap to retry.';

  @override
  String get missions_retry => 'RETRY';

  @override
  String get missions_unit_minutes => 'min';

  @override
  String get missions_unit_turns => 'turns';

  @override
  String get missions_unit_words => 'words';

  @override
  String get missions_unit_sessions => 'sessions';

  @override
  String get league_level_title => 'Level League';

  @override
  String get league_you => 'You (Student)';

  @override
  String league_ranking(String league) {
    return 'Ranking $league';
  }

  @override
  String league_top5(String level) {
    return 'Top 5 · Level $level';
  }

  @override
  String get recommended_title => 'Smart Discovery Hub';

  @override
  String get recommended_desc =>
      'Personalized lessons based on your level, interests and onboarding goals';

  @override
  String get recommended_search_hint => 'Search lesson, role or topic...';

  @override
  String get recommended_cat_all => 'All';

  @override
  String get recommended_cat_tech => 'Technology';

  @override
  String get recommended_cat_business => 'Business';

  @override
  String get recommended_cat_travel => 'Travel';

  @override
  String get recommended_cat_social => 'Social';

  @override
  String get recommended_cat_food => 'Food';

  @override
  String get recommended_all_levels => 'All Levels';

  @override
  String recommended_level(String lvl) {
    return 'Level $lvl';
  }

  @override
  String recommended_catalog(int count) {
    return 'Personalized Catalog ($count)';
  }

  @override
  String recommended_suggested_level(String cefr) {
    return 'Suggested level: $cefr';
  }

  @override
  String get recommended_hero_match =>
      '100% match with your Career goal and interest in Technology';

  @override
  String recommended_filter(String cefr) {
    return 'Filter: $cefr';
  }

  @override
  String get recommended_empty => 'No lessons found with the selected filters.';

  @override
  String recommended_lesson_level(String level) {
    return 'LEVEL $level';
  }

  @override
  String get recommended_locked_hint =>
      'Complete the previous lesson in your path to unlock.';

  @override
  String get recommended_blocked => 'Locked';

  @override
  String get recommended_review => 'Review';

  @override
  String get recommended_speak => 'Speak';

  @override
  String get path_roadmap_title => 'DUNGEON MAP';

  @override
  String get path_stage_empty => 'No lessons recorded for this stage yet.';

  @override
  String get profile_edit_photo_ok => 'PHOTO UPLOADED SUCCESSFULLY';

  @override
  String get profile_edit_choose_photo => 'CHOOSE CUSTOM PHOTO PATH';

  @override
  String get profile_edit_license_registry => 'HUNTER LICENSE REGISTRY';

  @override
  String get profile_edit_hunter_name => 'HUNTER NAME';

  @override
  String profile_edit_class_path(String path) {
    return 'CLASS PATH: $path';
  }

  @override
  String get profile_edit_select_class => 'SELECT CLASS PATH';

  @override
  String get profile_edit_stat_allocation => 'STAT POINTS ALLOCATION';

  @override
  String profile_edit_stat_pool(int points) {
    return 'POOL: $points PT';
  }

  @override
  String get profile_edit_full_name => 'HUNTER FULL NAME';

  @override
  String get profile_edit_name_empty => 'NAME CANNOT BE EMPTY';

  @override
  String get profile_edit_memoir => 'MEMOIR / OBJECTIVES';

  @override
  String get profile_edit_license_updated =>
      'LICENSE REGISTRY UPDATED SUCCESSFULLY';

  @override
  String get profile_edit_save => 'SAVE LICENSE REGISTRY';

  @override
  String get profile_edit_class_warrior => 'WARRIOR';

  @override
  String get profile_edit_class_warrior_desc =>
      'Physical strength & high defense';

  @override
  String get profile_edit_class_mage => 'MAGE';

  @override
  String get profile_edit_class_mage_desc =>
      'Spell casting & mana manipulation';

  @override
  String get profile_edit_class_assassin => 'ASSASSIN';

  @override
  String get profile_edit_class_assassin_desc =>
      'Stealth, speed & critical strikes';

  @override
  String get profile_edit_class_necromancer => 'NECROMANCER';

  @override
  String get profile_edit_class_necromancer_desc =>
      'Summoning the dead & dark magic';

  @override
  String get profile_edit_class_priest => 'PRIEST';

  @override
  String get profile_edit_class_priest_desc => 'Healing, buffing & holy light';

  @override
  String get profile_edit_stat_str_desc => 'Strength & muscle power';

  @override
  String get profile_edit_stat_int_desc => 'Spellcasting & parsing speed';

  @override
  String get profile_edit_stat_dex_desc => 'Agility & response rhythm';

  @override
  String get profile_edit_stat_luk_desc => 'Critical correction avoidance';

  @override
  String get convo_mission_guide => 'Mission Guide and Context';

  @override
  String get convo_practice_title => 'Conversation Practice';

  @override
  String convo_objective(String objective) {
    return 'Objective: $objective';
  }

  @override
  String get convo_select_goals => 'Select a lesson to see specific goals.';

  @override
  String get convo_select_phrases =>
      'Select a lesson to see suggested key phrases.';

  @override
  String get convo_voice_print => 'Voice Print & Pronunciation';

  @override
  String get convo_phonetic_clarity => 'Phonetic Clarity';

  @override
  String get convo_speech_speed => 'Speech Speed';

  @override
  String get convo_words_spoken => 'Words Spoken';

  @override
  String get convo_cefr_level => 'CEFR Level';

  @override
  String get convo_hidden_chat => 'Hidden Chat (4th/5th Star)';

  @override
  String get convo_visible_chat => 'Visible Chat';

  @override
  String get convo_write_mode => 'Write Mode';

  @override
  String get convo_voice_mode => 'Voice Mode';

  @override
  String get convo_input_hint => 'Write your message in English...';

  @override
  String get convo_continue => 'CONTINUE';

  @override
  String get convo_oracle_evaluating =>
      'THE ORACLE IS EVALUATING YOUR CONVERSATION...';

  @override
  String get convo_analyzing_level => 'Analyzing your communication level...';

  @override
  String get convo_status_listening => 'Listening…';

  @override
  String get convo_status_thinking => 'Thinking…';

  @override
  String get convo_status_speaking => 'The tutor is speaking';

  @override
  String get convo_stop_tutor => 'Stop';

  @override
  String get convo_tts_title => 'Tutor voice';

  @override
  String get convo_tts_speed => 'Speed';

  @override
  String get convo_tts_voice => 'Voice';

  @override
  String get convo_tts_default_voice => 'System voice';

  @override
  String get convo_tts_no_voices =>
      'No English voices found. Install one in Android Settings > Languages.';

  @override
  String get convo_mic_denied_title => 'Microphone blocked';

  @override
  String get convo_mic_denied_body =>
      'Dungeon of English needs the microphone to hear you. Turn it on in Android settings, then come back.';

  @override
  String get convo_mic_open_settings => 'Open settings';

  @override
  String get convo_mic_retry => 'Try again';

  @override
  String get convo_mic_manual_hint =>
      'Open Settings > Apps > Dungeon of English > Permissions > Microphone.';

  @override
  String get convo_help_title => 'I need help';

  @override
  String get convo_help_hint => 'Tap a phrase to send it as your answer.';

  @override
  String get convo_help_empty =>
      'This scenario has no help phrases yet. Write your answer or change the topic.';

  @override
  String get settings_system_config => 'SYSTEM CONFIG';

  @override
  String get settings_target_cefr => 'TARGET LANGUAGE & CEFR LEVEL';

  @override
  String get settings_language => 'LANGUAGE';

  @override
  String get settings_ai_parameters => 'AI TUTOR PARAMETERS';

  @override
  String get settings_audio_comms => 'AUDIO & COMMUNICATIONS';

  @override
  String get settings_account => 'ACCOUNT';

  @override
  String get settings_export_data => 'EXPORT MY DATA';

  @override
  String get settings_export_copied => 'Your data was copied to the clipboard.';

  @override
  String get settings_delete_account => 'DELETE MY ACCOUNT';

  @override
  String get settings_delete_confirm_title => 'Delete your account?';

  @override
  String get settings_delete_confirm_body =>
      'This permanently deletes your account and progress. This cannot be undone.';

  @override
  String get settings_aligned => 'CONFIGURATION ALIGNED SUCCESSFULLY';

  @override
  String get settings_save => 'SAVE CONFIGURATION';

  @override
  String get settings_target_language => 'TARGET LANGUAGE';

  @override
  String get settings_cefr_practice => 'CEFR PRACTICE LEVEL';

  @override
  String get settings_logout_dungeon => 'LOG OUT OF DUNGEON';

  @override
  String get settings_select_path => 'SELECT TARGET PATH';

  @override
  String get settings_select_cefr => 'SELECT CEFR LEVEL PATH';

  @override
  String get settings_correction_scope => 'AI CORRECTION SCOPE';

  @override
  String get settings_tutor_personality => 'TUTOR PERSONALITY';

  @override
  String get settings_correction_cadence => 'CORRECTION CADENCE';

  @override
  String get settings_quest_focus => 'DAILY QUEST FOCUS';

  @override
  String get settings_sfx_channels => 'AUDIO SFX CHANNELS';

  @override
  String get settings_alerts => 'DAILY ALERT EMISSIONS';

  @override
  String get settings_alert_time => 'ALERTS DISPATCH TIME';

  @override
  String get settings_select_correction => 'SELECT CORRECTION LEVEL';

  @override
  String get settings_select_personality => 'SELECT TUTOR PERSONALITY';

  @override
  String get settings_select_cadence => 'SELECT CORRECTION CADENCE';

  @override
  String get settings_select_quest => 'SELECT DAILY QUEST FOCUS';

  @override
  String get settings_follow_device => 'USE DEVICE LANGUAGE';

  @override
  String get settings_force_onboarding => 'Force Continuous Onboarding';

  @override
  String get settings_dev_desc =>
      'Developer mode. It does not block the app: it only affects onboarding when there is no profile yet. Use \"Reset history\" to test it again.';

  @override
  String get settings_profile_deleted =>
      'Hunter profile deleted. Restarting...';

  @override
  String get settings_reset_onboarding => 'RESET ONBOARDING HISTORY';

  @override
  String onboarding_device_lang(String lang) {
    return 'We detected that your device uses $lang. The app will be shown in that language.';
  }

  @override
  String get privacy_title => 'PRIVACY';

  @override
  String get privacy_body =>
      'To correct your conversation, the app sends the AI your transcribed audio, your CEFR level and your native language. Your email, name and photo are not sent. You can export or delete your data from Settings. We also keep aggregated usage metrics (progress, retention and errors) with no conversation text and no personal data.';

  @override
  String get privacy_accept => 'GOT IT';

  @override
  String get onboarding_privacy_link => 'PRIVACY';

  @override
  String get onboarding_beginner => 'I AM AN ABSOLUTE BEGINNER (PRE-A1)';

  @override
  String get onboarding_beginner_desc =>
      'I cannot form sentences yet: only loose words and minimal vocabulary. You will start in Fundamentals without an exam.';

  @override
  String get hunter_equip_title => 'EQUIP TITLE';

  @override
  String get hunter_skill_titles => 'SKILL TITLES';

  @override
  String hunter_cefr_xp(String code, int xp) {
    return 'CEFR $code · $xp XP';
  }

  @override
  String get hunter_equipped_title => 'EQUIPPED TITLE';

  @override
  String get hunter_equip => 'EQUIP';

  @override
  String get hunter_fluency_analysis => 'FLUENCY ANALYSIS';

  @override
  String get hunter_holographic_radar => 'HOLOGRAPHIC RADAR';

  @override
  String get hunter_practice_consistency => 'PRACTICE CONSISTENCY';

  @override
  String hunter_points_pool(int points) {
    return 'AVAILABLE POINTS: $points';
  }

  @override
  String get hunter_str => 'STR (STRENGTH)';

  @override
  String get hunter_luk => 'LUK (LUCK)';

  @override
  String get hunter_distribute_points => 'DISTRIBUTE POINTS';

  @override
  String get hunter_no_title => 'NO TITLE';

  @override
  String get hunter_max_level => 'MAX LEVEL REACHED';

  @override
  String get dungeon_choose_portal => 'CHOOSE A PORTAL ACCORDING TO YOUR RANK';

  @override
  String dungeon_current_portal(String level) {
    return 'CURRENT PORTAL — LEVEL $level';
  }

  @override
  String dungeon_level(Object level) {
    return 'LEVEL $level';
  }

  @override
  String get progress_edit_profile => 'Edit Profile';

  @override
  String get progress_hunter_status => 'Hunter Status';

  @override
  String progress_streak_hint(int streak, String days) {
    return 'Practice today to keep your $streak day streak $days';
  }

  @override
  String get progress_practice => 'PRACTICE';

  @override
  String get settings_haptics => 'VIBRATION';

  @override
  String get settings_haptics_desc => 'Vibrate on goal complete and level up';

  @override
  String get settings_sounds => 'SOUNDS';

  @override
  String get settings_sounds_desc => 'System sound on celebrations';

  @override
  String get welcome_back_title => 'WELCOME BACK';

  @override
  String welcome_back_days(int days) {
    return '$days days away';
  }

  @override
  String welcome_back_lesson(String lesson) {
    return 'You left off at $lesson';
  }

  @override
  String welcome_back_goals(int count) {
    return '$count goals to go';
  }

  @override
  String get welcome_back_completed =>
      'You finished it. Replay it or pick the next one.';

  @override
  String get welcome_back_streak_reset => 'Let\'s start a new streak today.';

  @override
  String get welcome_back_continue => 'CONTINUE';

  @override
  String get welcome_back_later => 'Not now';

  @override
  String get radar_estimated_tooltip => 'Estimate based on your conversation';

  @override
  String get radar_estimated_note => 'Estimate based on your conversation';

  @override
  String get radar_pronunciation_unmeasured =>
      'Pronunciation: no real measurement yet';

  @override
  String get band_low => 'Low';

  @override
  String get band_medium => 'Medium';

  @override
  String get band_high => 'High';

  @override
  String mana_cost_per_turn(int cost) {
    return '$cost/turn';
  }

  @override
  String mana_low_warning(int count) {
    return '$count turns left today';
  }

  @override
  String get mana_empty_warning => 'No mana for the next turn';

  @override
  String get guardian_alternative_title => 'WHILE YOU WAIT';

  @override
  String guardian_refill_in(int hours, int minutes) {
    return 'Refills in $hours h $minutes min';
  }

  @override
  String guardian_refill_at(String date) {
    return 'Renews on $date';
  }

  @override
  String get guardian_review_vocab => 'Review vocabulary (free)';

  @override
  String guardian_low_cost_chat(int cost) {
    return 'Text chat ($cost mana)';
  }

  @override
  String get guardian_no_due_words => 'No words due for review right now.';

  @override
  String get daily_goal_title => 'DAILY GOAL';

  @override
  String daily_goal_minutes(int done, int goal) {
    return '$done / $goal min';
  }

  @override
  String daily_goal_remaining(int minutes) {
    return '$minutes min to go';
  }

  @override
  String get daily_goal_done => 'Goal complete';

  @override
  String daily_goal_streak(int days) {
    return '${days}d streak';
  }

  @override
  String get daily_goal_celebrate => 'DAILY GOAL COMPLETE!';

  @override
  String get evidence_title => 'LEARNING EVIDENCE';

  @override
  String get evidence_disclaimer => 'Evidence, not a grade.';

  @override
  String get evidence_retention => '7-day retention';

  @override
  String get evidence_progress => 'Comparable progress';

  @override
  String get evidence_transfer => 'Transfer';

  @override
  String get evidence_no_data => 'No data yet';

  @override
  String get evidence_needs_weeks => 'You need 4 weeks';

  @override
  String evidence_progress_value(int first, int last) {
    return '$first → $last missions/week';
  }

  @override
  String evidence_transfer_value(int types) {
    return '$types mission types';
  }

  @override
  String get progress_streak_at_risk => 'STREAK AT RISK!';

  @override
  String get progress_hunter_desc =>
      'View the 11-attribute matrix, equipped titles and power radar';

  @override
  String get progress_weekly_voice => 'Weekly Practice (Voice Minutes)';

  @override
  String progress_vocab_learned(int count) {
    return 'Vocabulary Learned ($count)';
  }

  @override
  String get progress_vocab_empty =>
      'You haven\'t accumulated vocabulary in voice calls yet.';

  @override
  String get progress_vocab_section => 'Vocabulary';

  @override
  String get progress_hunter_attributes => 'HUNTER ATTRIBUTES';

  @override
  String get progress_xp_rank => 'XP Rank';

  @override
  String get settings_opt_sfx_desc =>
      'Combat, mana charges, and level calibration sfx';

  @override
  String get settings_opt_strict_title => 'STRICT ACTION';

  @override
  String get settings_opt_strict_desc =>
      'AI will only correct critical structural breaks.';

  @override
  String get settings_opt_compact_title => 'COMPACT FEEDBACK';

  @override
  String get settings_opt_compact_desc =>
      'Quick corrections with single line annotations.';

  @override
  String get settings_opt_moderate_title => 'MODERATE EXPLANATION';

  @override
  String get settings_opt_moderate_desc =>
      'Balanced corrections with 1 to 3 detail sentences.';

  @override
  String get settings_opt_detailed_title => 'DETAILED BREAKDOWN';

  @override
  String get settings_opt_detailed_desc =>
      'In-depth grammar blueprints with contextual examples.';

  @override
  String get settings_opt_oracle_title => 'ORACLE MASTER MODE';

  @override
  String get settings_opt_oracle_desc =>
      'Complete analysis of error blueprints.';

  @override
  String get settings_opt_companion_title => 'COMPANION RATE';

  @override
  String get settings_opt_companion_desc =>
      'Patient, warm, and highly supportive responses.';

  @override
  String get settings_opt_commander_title => 'COMMANDER BRIEF';

  @override
  String get settings_opt_commander_desc =>
      'Formal, highly structured, and structured corrections.';

  @override
  String get settings_opt_boss_title => 'BOSS CALIBER CHALLENGE';

  @override
  String get settings_opt_boss_desc =>
      'High-level vocabulary demands and strict responses.';

  @override
  String get settings_opt_strict_style_title => 'STRICT ACTION';

  @override
  String get settings_opt_strict_style_desc =>
      'Interrupts and repairs errors instantly.';

  @override
  String get settings_opt_balanced_title => 'BALANCED COMPASS';

  @override
  String get settings_opt_balanced_desc =>
      'Maintains dialogue speed with structured correction feedback.';

  @override
  String get settings_opt_immersive_title => 'IMMERSIVE RAIDS';

  @override
  String get settings_opt_immersive_desc =>
      'Keeps speaking flow; repairs only terminal breaks.';

  @override
  String get settings_opt_casual_title => 'CASUAL RUN (10 MIN)';

  @override
  String get settings_opt_casual_desc => 'Quick entry practice daily.';

  @override
  String get settings_opt_regular_title => 'REGULAR RAID (15 MIN)';

  @override
  String get settings_opt_regular_desc => 'Solid learning rate path.';

  @override
  String get settings_opt_serious_title => 'SERIOUS CAMPAIGN (30 MIN)';

  @override
  String get settings_opt_serious_desc =>
      'Acquire fluent skill markers rapidly.';

  @override
  String get settings_opt_overload_title => 'OVERLOAD OVERCLOCK (60 MIN)';

  @override
  String get settings_opt_overload_desc => 'Complete immersion overdrive.';

  @override
  String get hunter_title_orco_caverna_f => 'Cave Orc Writing';

  @override
  String get hunter_title_orco_caverna_f_desc =>
      'First steps making mistakes with courage.';

  @override
  String get hunter_title_escriba_novato_e => 'Novice Scribe';

  @override
  String get hunter_title_escriba_novato_e_desc => '50% clean sentences.';

  @override
  String get hunter_title_escriba_ciudad_d => 'City Scribe';

  @override
  String get hunter_title_escriba_ciudad_d_desc => '65% grammar accuracy.';

  @override
  String get hunter_title_escriba_imperial_c => 'Imperial Library Scribe';

  @override
  String get hunter_title_escriba_imperial_c_desc => '75% grammar accuracy.';

  @override
  String get hunter_title_pluma_erudito_b => 'Royal Scholar Quill';

  @override
  String get hunter_title_pluma_erudito_b_desc => '85% grammar accuracy.';

  @override
  String get hunter_title_pluma_archimago_a => 'Archmage Arcanist Quill';

  @override
  String get hunter_title_pluma_archimago_a_desc => '92% grammar accuracy.';

  @override
  String get hunter_title_pluma_celestial_s => 'Celestial Quill of the Sage';

  @override
  String get hunter_title_pluma_celestial_s_desc => '97% grammar accuracy.';

  @override
  String get hunter_title_monarca_sintaxis_ss => 'Monarch of Sacred Syntax';

  @override
  String get hunter_title_monarca_sintaxis_ss_desc => '99% grammar accuracy.';

  @override
  String get hunter_title_creador_abismo_sss => 'Creator of Abyssal Languages';

  @override
  String get hunter_title_creador_abismo_sss_desc =>
      '100% flawless grammar accuracy.';

  @override
  String get hunter_title_murcielago_ciego_f => 'Blind Bat';

  @override
  String get hunter_title_murcielago_ciego_f_desc =>
      'Initial listens with text chat.';

  @override
  String get hunter_title_oido_halcon_novato_d => 'Novice Hawk Hearing';

  @override
  String get hunter_title_oido_halcon_novato_d_desc =>
      '2 lessons without chat.';

  @override
  String get hunter_title_oido_halcon_abismo_c => 'Abyss Hawk Hearing';

  @override
  String get hunter_title_oido_halcon_abismo_c_desc =>
      '4 blind-cleared lessons.';

  @override
  String get hunter_title_sonar_monarca_sombras_s =>
      'Absolute Sonar of the Shadow Monarch';

  @override
  String get hunter_title_sonar_monarca_sombras_s_desc =>
      '16 blind-cleared lessons.';

  @override
  String get hunter_title_oidor_susurros_sss =>
      'Hearer of the Universe Whispers';

  @override
  String get hunter_title_oidor_susurros_sss_desc =>
      'Over 30 blind-cleared lessons.';

  @override
  String get hunter_title_monarca_impecable_5star =>
      'Immaculate Monarch of Perfection';

  @override
  String get hunter_title_monarca_impecable_5star_desc =>
      'Awarded for achieving the 5th Mythic Star (0 blind errors).';

  @override
  String get skill_fluidez_1 => 'Word Apprentice';

  @override
  String get skill_fluidez_1_desc =>
      'You begin to express yourself with continuity.';

  @override
  String get skill_fluidez_2 => 'The Swift Courier';

  @override
  String get skill_fluidez_2_desc =>
      'You speak with notable rhythm and fluency.';

  @override
  String get skill_fluidez_3 => 'Herald of the Gale';

  @override
  String get skill_fluidez_3_desc => 'Your speech flows effortlessly.';

  @override
  String get skill_fluidez_4 => 'Spokesperson of the Gods';

  @override
  String get skill_fluidez_4_desc => 'Almost divine fluency when conversing.';

  @override
  String get skill_fonetica_1 => 'Voice Apprentice';

  @override
  String get skill_fonetica_1_desc => 'Your pronunciation is becoming clear.';

  @override
  String get skill_fonetica_2 => 'Echo of the Coliseum';

  @override
  String get skill_fonetica_2_desc =>
      'You pronounce with remarkable precision.';

  @override
  String get skill_fonetica_3 => 'Crystal Choir';

  @override
  String get skill_fonetica_3_desc => 'Your phonetics are clean and bright.';

  @override
  String get skill_fonetica_4 => 'Celestial Tuner';

  @override
  String get skill_fonetica_4_desc => 'Phonetic clarity from another plane.';

  @override
  String get skill_lexico_1 => 'Word Gatherer';

  @override
  String get skill_lexico_1_desc => 'You add your first mastered words.';

  @override
  String get skill_lexico_2 => 'Village Librarian';

  @override
  String get skill_lexico_2_desc => 'Your vocabulary grows solidly.';

  @override
  String get skill_lexico_3 => 'Abyss Scribe';

  @override
  String get skill_lexico_3_desc => 'You master an extensive vocabulary.';

  @override
  String get skill_lexico_4 => 'Eternal Lexicographer';

  @override
  String get skill_lexico_4_desc => 'Your lexicon knows no bounds.';

  @override
  String get skill_precision_1 => 'Rules Apprentice';

  @override
  String get skill_precision_1_desc => 'Simple structures are already solid.';

  @override
  String get skill_precision_2 => 'Rune Apprentice';

  @override
  String get skill_precision_2_desc => 'Your grammar gains consistency.';

  @override
  String get skill_precision_3 => 'Coliseum Grammarian';

  @override
  String get skill_precision_3_desc => 'You build sentences with mastery.';

  @override
  String get skill_precision_4 => 'Syntax Forger';

  @override
  String get skill_precision_4_desc =>
      'Your grammatical precision is legendary.';

  @override
  String get skill_constancia_1 => 'Steady Apprentice';

  @override
  String get skill_constancia_1_desc => 'Three consecutive days of practice.';

  @override
  String get skill_constancia_2 => 'Fire Guardian';

  @override
  String get skill_constancia_2_desc => 'One uninterrupted week.';

  @override
  String get skill_constancia_3 => 'Dawn Sentinel';

  @override
  String get skill_constancia_3_desc => 'A month of iron consistency.';

  @override
  String get skill_constancia_4 => 'Streak Legend';

  @override
  String get skill_constancia_4_desc =>
      'A hundred days of absolute dedication.';

  @override
  String get skill_carisma_1 => 'Guild Novice';

  @override
  String get skill_carisma_1_desc => 'You navigate conversations with ease.';

  @override
  String get skill_carisma_2 => 'Soul of the Tavern';

  @override
  String get skill_carisma_2_desc => 'You connect naturally with others.';

  @override
  String get skill_carisma_3 => 'Realm Ambassador';

  @override
  String get skill_carisma_3_desc => 'You lead the conversation smoothly.';

  @override
  String get skill_carisma_4 => 'Lesser Oracle';

  @override
  String get skill_carisma_4_desc =>
      'Your conversational charisma is out of this world.';

  @override
  String get paywall_upgrade_title => 'UPGRADE TO PREMIUM';

  @override
  String get paywall_upgrade_subtitle =>
      'Your estate defines your monthly mana and prestige ceiling. Effort (Aura) decides your title.';

  @override
  String get paywall_f_monthly => 'MENSUAL';

  @override
  String get paywall_f_annual => 'ANUAL';

  @override
  String get paywall_subscribe => 'SUBSCRIBE NOW';

  @override
  String get paywall_restore => 'RESTORE';

  @override
  String get paywall_legal =>
      'Cancel anytime via App Store / Play Store. Terms and Conditions apply.';

  @override
  String get paywall_err_checkout => 'Could not open the checkout.';

  @override
  String get paywall_feature_mana =>
      'Realtime Mana consumption & voice metrics tracker';

  @override
  String get paywall_feature_titles =>
      'Unlock the 63 Rank Titles Inventory (from F to SSS Rank)';

  @override
  String get paywall_feature_rooms =>
      '24/7 access to the Grand Discussion Hall voice rooms';

  @override
  String get paywall_feature_modes =>
      'Tactical selector between Voice Mode and Writing Mode';

  @override
  String get paywall_feature_missions =>
      'Premium missions & weekly raid rewards';

  @override
  String get paywall_active_title => 'YOUR CURRENT PLAN';

  @override
  String get paywall_active_subtitle =>
      'You already have Premium. Manage or change your plan here.';

  @override
  String get paywall_load_error => 'Could not load the plans.';

  @override
  String get paywall_no_packages =>
      'No plans available for this billing cycle.';

  @override
  String get paywall_nothing_restored => 'No purchases to restore.';

  @override
  String get paywall_current_plan => 'CURRENT PLAN';

  @override
  String get paywall_manage_subscription => 'MANAGE SUBSCRIPTION';

  @override
  String get paywall_plans_title => 'CHOOSE YOUR ESTATE';

  @override
  String get paywall_per_month => '/month';

  @override
  String paywall_plan_mana(String amount) {
    return '$amount mana/month';
  }

  @override
  String paywall_plan_report_weeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks of report history',
      one: '1 week of report history',
    );
    return '$_temp0';
  }

  @override
  String paywall_plan_exclusives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exclusive cosmetics',
      one: '1 exclusive cosmetic',
    );
    return '$_temp0';
  }

  @override
  String paywall_trial_then(int days, String price) {
    return '$days days free, then $price/month';
  }

  @override
  String get mana_inventory_title => 'MANA INVENTORY';

  @override
  String get mana_inventory_empty => 'No elixirs or gems in your bag yet.';

  @override
  String get mana_gem_label => 'GEM';

  @override
  String get mana_elixir_label => 'ELIXIR';

  @override
  String mana_expiry_countdown(Object hours, Object minutes) {
    return 'Expires in ${hours}h ${minutes}m';
  }

  @override
  String get mana_item_equipped => 'Mana item equipped';

  @override
  String get mana_equip => 'EQUIP';

  @override
  String get summary_next_lesson => 'NEXT LESSON';

  @override
  String get oracle_challenge_title => 'ORACLE EVALUATION';

  @override
  String get oracle_challenge_ready =>
      'The Oracle awaits you. Challenge available!';

  @override
  String oracle_challenge_progress(Object percent) {
    return 'Complete 80% to challenge the Oracle ($percent%)';
  }

  @override
  String get onboarding_english_only =>
      'You will learn English. You can change the interface language in Settings.';

  @override
  String corrections_chip_label(int count) {
    return 'FIX $count';
  }

  @override
  String get corrections_you_wrote => 'You wrote';

  @override
  String get corrections_suggested => 'Better';

  @override
  String get my_errors_title => 'MY ERRORS';

  @override
  String get my_errors_short => 'ERRORS';

  @override
  String get my_errors_subtitle =>
      'Grouped by type and recurrence. Recurrent mistakes feed your reinforcement missions.';

  @override
  String get my_errors_empty =>
      'No errors recorded yet. Finish a lesson and your corrections will appear here.';

  @override
  String get my_errors_error =>
      'We could not load your errors. Check your connection and retry.';

  @override
  String get my_errors_retry => 'RETRY';

  @override
  String my_errors_times(int count) {
    return '${count}x';
  }

  @override
  String get my_errors_recurring_badge => 'RECURRING';

  @override
  String get correction_type_grammar => 'Grammar';

  @override
  String get correction_type_vocabulary => 'Vocabulary';

  @override
  String get correction_type_word_choice => 'Word choice';

  @override
  String get correction_type_pronunciation_hint => 'Pronunciation';

  @override
  String get correction_type_typo_stt => 'Transcription';

  @override
  String get notif_settings_title => 'DAILY REMINDER';

  @override
  String get notif_settings_desc =>
      'One reminder a day, at the time you choose. Never at night.';

  @override
  String get notif_time_label => 'REMINDER TIME';

  @override
  String get notif_days_label => 'ACTIVE DAYS';

  @override
  String get notif_quiet_hours =>
      'Quiet hours are 22:00-08:00, so the reminder moved to 08:00.';

  @override
  String notif_time_updated(String time) {
    return 'Reminder set for $time.';
  }

  @override
  String get widget_streak_label => 'STREAK';

  @override
  String get widget_minutes_label => 'TODAY';

  @override
  String get widget_minutes_unit => 'min';

  @override
  String get widget_practice => 'PRACTICE';

  @override
  String get widget_empty_title => 'Open the app to start';

  @override
  String get widget_empty_body =>
      'Your streak and today\'s minutes appear here once you open the app.';

  @override
  String get notif_permission_denied =>
      'Notifications are blocked. Allow them in Android settings > Apps > Dungeon of English > Notifications.';

  @override
  String get notif_permission_open_settings => 'OPEN ANDROID SETTINGS';

  @override
  String get notif_prompt_title => 'DON\'T LOSE YOUR STREAK';

  @override
  String get notif_prompt_body =>
      'Turn on one daily reminder and we will nudge you at the time you choose. You can change it or turn it off in Settings.';

  @override
  String get notif_prompt_accept => 'TURN IT ON';

  @override
  String get mini_conv_badge => '60-SECOND TRIAL';

  @override
  String get mini_conv_title => 'Order a coffee';

  @override
  String get mini_conv_subtitle =>
      'Talk to Mira, the innkeeper. One or two answers, no exam and no mana spent.';

  @override
  String mini_conv_turn_counter(int current, int total) {
    return 'Reply $current of $total';
  }

  @override
  String get mini_conv_your_turn => 'YOUR TURN';

  @override
  String get mini_conv_input_hint => 'Type your answer in English...';

  @override
  String get mini_conv_send => 'SEND';

  @override
  String get mini_conv_record => 'ANSWER WITH YOUR VOICE';

  @override
  String get mini_conv_recording => 'RECORDING... TAP TO STOP';

  @override
  String get mini_conv_transcribing => 'TRANSCRIBING...';

  @override
  String get mini_conv_skip => 'SKIP FOR NOW';

  @override
  String get mini_conv_mic_denied =>
      'We could not use the microphone. You can still type your answer.';

  @override
  String get mini_conv_voice_empty =>
      'We did not hear any speech. Try again or type your answer.';

  @override
  String get mini_conv_voice_failed =>
      'We could not transcribe your audio. Try again or type your answer.';

  @override
  String get mini_conv_unlocked_label => 'PHRASE UNLOCKED';

  @override
  String get mini_conv_unlocked_translation =>
      'A flat white to take away, please.';

  @override
  String get mini_conv_cta => 'START MY ADVENTURE';

  @override
  String get mini_conv_unavailable_title => 'MIRA IS NOT AVAILABLE';

  @override
  String get mini_conv_unavailable_body =>
      'Your adventure starts anyway. Nothing was charged: this trial is on us.';

  @override
  String get mini_conv_continue => 'CONTINUE';

  @override
  String get notif_prompt_later => 'NOT NOW';

  @override
  String get notif_enabled_ok => 'Daily reminder armed.';

  @override
  String get notif_save_error =>
      'Could not save the reminder. Check your connection and try again.';

  @override
  String get notif_reminder_title => 'Your streak awaits';

  @override
  String get notif_reminder_body =>
      'A short raid today keeps the streak alive. Your tutor is ready.';

  @override
  String get boss_exam_title => 'DUNGEON BOSS: THE ORACLE';

  @override
  String get boss_exam_state_ready => 'The boss awaits. Challenge available!';

  @override
  String get boss_exam_state_locked =>
      'Meet the requirements to challenge the boss.';

  @override
  String boss_exam_state_locked_progress(int percent) {
    return 'Complete 80% of the level lessons ($percent%)';
  }

  @override
  String boss_exam_state_cooldown(String time) {
    return 'The boss rests until $time.';
  }

  @override
  String get boss_req_level => 'Assigned level';

  @override
  String get boss_req_practice => 'Practice: goals, streak or minutes';

  @override
  String get boss_req_cooldown => 'Cooldown between attempts';

  @override
  String get boss_hud_title => 'BOSS: THE ORACLE';

  @override
  String boss_hud_turns(int current, int max) {
    return 'TURN $current/$max';
  }

  @override
  String get boss_result_victory => 'BOSS DEFEATED';

  @override
  String get boss_result_defeat => 'THE BOSS HOLDS';

  @override
  String get boss_result_initial => 'LEVEL ASSIGNED';

  @override
  String get boss_result_missing => 'No result available.';

  @override
  String boss_result_level_up(String from, String to) {
    return '$from to $to';
  }

  @override
  String boss_result_level_assigned(String level) {
    return 'Your level: $level';
  }

  @override
  String boss_result_level_kept(String level) {
    return 'You keep $level';
  }

  @override
  String get boss_result_forced =>
      'The exam reached its limit and was scored with the answers given.';

  @override
  String get boss_result_rubric => 'RUBRIC (6 DIMENSIONS)';

  @override
  String boss_result_average(int value, int threshold) {
    return 'avg $value/100 - pass $threshold';
  }

  @override
  String get boss_result_no_scores =>
      'The Oracle could not score the rubric in this attempt.';

  @override
  String get boss_result_reason_title => 'WHY NOT YET';

  @override
  String get boss_result_reason_rubric =>
      'You were close: the average or one dimension is below the pass threshold.';

  @override
  String get boss_result_reason_no_improvement =>
      'Your level is solid, but not yet above your current band.';

  @override
  String get boss_result_reason_unavailable =>
      'The Oracle could not score the rubric, so the level is kept.';

  @override
  String boss_result_retry_at(String time) {
    return 'Next attempt: $time';
  }

  @override
  String get boss_result_focus_title => 'WHAT TO REINFORCE';

  @override
  String get boss_result_reinforce => 'PRACTISE REINFORCEMENT LESSONS';

  @override
  String get boss_result_home => 'BACK TO THE PATH';

  @override
  String get boss_dim_listening => 'Listening';

  @override
  String get boss_dim_fluency => 'Fluency';

  @override
  String get boss_dim_grammar => 'Grammar';

  @override
  String get boss_dim_vocabulary => 'Vocabulary';

  @override
  String get boss_dim_pronunciation => 'Pronunciation';

  @override
  String get boss_dim_naturalness => 'Naturalness';

  @override
  String get weekly_title => 'WEEKLY REPORT';

  @override
  String get weekly_subtitle =>
      'Data calculated on the server. A week without activity says so instead of showing zeros.';

  @override
  String get weekly_empty => 'No recorded activity this week.';

  @override
  String get weekly_empty_hint =>
      'Practise a conversation or a lesson and your report fills in.';

  @override
  String get weekly_new_words => 'New words';

  @override
  String get weekly_words_reviewed => 'Words reviewed';

  @override
  String get weekly_words_mastered => 'Words mastered';

  @override
  String get weekly_corrections => 'Errors corrected';

  @override
  String get weekly_top_error => 'Most frequent error';

  @override
  String get weekly_lessons => 'Lessons passed';

  @override
  String get weekly_minutes => 'Minutes';

  @override
  String get weekly_practice_days => 'Days practised';

  @override
  String get weekly_per_day => 'Average per practice day';

  @override
  String get weekly_level => 'Estimated level';

  @override
  String get weekly_level_unknown => 'Not assessed yet';

  @override
  String get weekly_this_week => 'This week';

  @override
  String get weekly_previous_week => 'Previous week';

  @override
  String get weekly_next_week => 'Next week';

  @override
  String weekly_range(String start, String end) {
    return '$start to $end';
  }

  @override
  String get weekly_error => 'We could not load your weekly report.';

  @override
  String get weekly_retry => 'RETRY';

  @override
  String get weekly_open => 'VIEW REPORT';

  @override
  String weekly_history_locked(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Your plan keeps $weeks weeks of history.',
      one: 'Your plan keeps 1 week of history.',
    );
    return '$_temp0';
  }

  @override
  String get weekly_history_upgrade =>
      'Upgrade your plan to open previous weeks.';

  @override
  String get checkpoint_title => 'LEVEL CHECK';

  @override
  String checkpoint_body(int count) {
    return 'You completed $count lessons since your last challenge with the Oracle.';
  }

  @override
  String get checkpoint_action => 'CHALLENGE THE ORACLE';

  @override
  String checkpoint_remaining(int count) {
    return '$count lessons to the next level check';
  }

  @override
  String boss_exam_not_enough(int min) {
    return 'The Oracle needs at least $min answers to judge the exam. This attempt does not count.';
  }

  @override
  String boss_exam_cooldown(String time) {
    return 'The boss does not accept another challenge until $time.';
  }

  @override
  String get listening_path_title => 'LISTENING';

  @override
  String listening_path_next(String title) {
    return 'Next: $title';
  }

  @override
  String listening_path_progress(int done, int total) {
    return '$done/$total passed';
  }

  @override
  String get listening_empty => 'No listening exercises for this level yet.';

  @override
  String get listening_play => 'PLAY DIALOGUE';

  @override
  String get listening_stop => 'STOP';

  @override
  String get listening_play_again => 'LISTEN AGAIN';

  @override
  String get listening_transcript_show => 'SHOW TRANSCRIPT';

  @override
  String get listening_transcript_hide => 'HIDE TRANSCRIPT';

  @override
  String listening_question_counter(int current, int total) {
    return 'QUESTION $current OF $total';
  }

  @override
  String get listening_next => 'NEXT';

  @override
  String get listening_previous => 'BACK';

  @override
  String get listening_submit => 'CHECK ANSWERS';

  @override
  String get listening_submitting => 'CHECKING...';

  @override
  String get listening_result_passed => 'EXERCISE PASSED';

  @override
  String get listening_result_failed => 'NOT YET';

  @override
  String listening_result_score(int score, int total) {
    return '$score of $total correct';
  }

  @override
  String listening_result_missions(int count) {
    return '+$count mission progress';
  }

  @override
  String listening_result_practice(int minutes) {
    return '$minutes min of practice registered';
  }

  @override
  String get listening_result_retry => 'REPEAT';

  @override
  String get listening_back_path => 'BACK TO THE PATH';

  @override
  String get listening_error_load =>
      'We could not load this exercise. Check your connection and try again.';

  @override
  String get listening_retry_send => 'RETRY SEND';

  @override
  String listening_explanation(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get path_recommended => 'RECOMMENDED';

  @override
  String get path_recommended_interest => 'Based on your interests';

  @override
  String get path_recommended_error => 'Reinforces your mistakes';

  @override
  String get path_recommended_review => 'Review of what you learned';

  @override
  String get path_recommended_next => 'Next step';
}
