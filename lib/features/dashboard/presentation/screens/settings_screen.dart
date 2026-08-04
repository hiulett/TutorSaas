import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../core/services/audio_sfx_service.dart';
import '../../../../core/i18n/language_settings.dart';
import '../../domain/models/user_settings.dart';
import '../providers/dashboard_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  UserSettings? _localSettings;
  bool _isSaving = false;
  String _selectedTargetLanguage = 'en';
  String _selectedCefrLevel = 'B1';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remoteSettings = ref.watch(userSettingsProvider);

    // Initialize local copy from remote settings once they are ready
    _localSettings ??= remoteSettings;

    final currentSettings = _localSettings ?? remoteSettings;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberManhwaBackground(
        child: Stack(
          children: [
            // Glowing Background Orbs
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.runeViolet.withValues(alpha: 0.1),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manaCyan.withValues(alpha: 0.08),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SYSTEM CONFIG',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings List
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      children: [
                        const _SectionHeader(title: 'TARGET LANGUAGE & CEFR LEVEL'),
                        const SizedBox(height: 12),
                        _buildLanguageTile(context),
                        const SizedBox(height: 12),
                        _buildCefrLevelTile(context),
                        const SizedBox(height: 24),

                        const _SectionHeader(title: 'LANGUAGE'),
                        const SizedBox(height: 12),
                        _buildDeviceLanguageTile(context),
                        const SizedBox(height: 12),
                        _buildInterfaceLanguageTile(context),
                        const SizedBox(height: 24),

                        const _SectionHeader(title: 'AI TUTOR PARAMETERS'),
                        const SizedBox(height: 12),
                        _buildCorrectionLevelTile(context, currentSettings.correctionLevel),
                        const SizedBox(height: 12),
                        _buildTutorPersonalityTile(context, currentSettings.tutorPersonality),
                        const SizedBox(height: 12),
                        _buildCorrectionStyleTile(context, currentSettings.correctionStyle),
                        const SizedBox(height: 12),
                        _buildDailyGoalTile(context, currentSettings.dailyGoalMinutes),
                        const SizedBox(height: 24),

                        const _SectionHeader(title: 'AUDIO & COMMUNICATIONS'),
                        const SizedBox(height: 12),
                        _buildNotificationTiles(context, currentSettings),
                        const SizedBox(height: 24),

                        const _SectionHeader(title: 'ACCOUNT'),
                        const SizedBox(height: 12),
                        _buildLogoutTile(context),
                        const SizedBox(height: 24),

                        const _SectionHeader(title: 'DEVELOPER TOOLS'),
                        const SizedBox(height: 12),
                        _buildDevToolsTile(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Save Changes Button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  setState(() {
                                    _isSaving = true;
                                  });
                                  try {
                                    await ref
                                        .read(userSettingsProvider.notifier)
                                        .updateAllSettings(currentSettings);

                                    final user = ref.read(currentUserProvider);
                                    if (user != null) {
                                      await ref.read(onboardingRepositoryProvider).saveOnboardingData(
                                            userId: user.id,
                                            targetLanguageCode: _selectedTargetLanguage,
                                            nativeLanguageCode: 'es',
                                            cefrLevelCode: _selectedCefrLevel,
                                            dailyGoalMinutes: currentSettings.dailyGoalMinutes,
                                            interests: currentSettings.interests,
                                            motivation: 'career',
                                            correctionStyle: currentSettings.correctionStyle,
                                            tutorPersonality: currentSettings.tutorPersonality,
                                          );
                                    }

                                    ref.invalidate(recommendedLessonsProvider);
                                    ref.invalidate(userProgressProvider);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'CONFIGURATION ALIGNED SUCCESSFULLY',
                                            style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: AppColors.emeraldGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      SystemSnack.show(context, 'ERROR SAVING CONFIG: $e', type: SystemSnackType.error);
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSaving = false;
                                      });
                                    }
                                  }
                                },
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
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.onSurface,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'SAVE CONFIGURATION',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                    fontSize: 16,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Language Selection Tile ---
  Widget _buildLanguageTile(BuildContext context) {
    final Map<String, String> langNames = {
      'en': 'ENGLISH (EN)',
      'fr': 'FRENCH (FR)',
      'de': 'GERMAN (DE)',
      'it': 'ITALIAN (IT)',
    };

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showLanguageBottomSheet(context),
        child: Row(
          children: [
            const Icon(Icons.language_rounded, color: AppColors.manaCyan, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET LANGUAGE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    langNames[_selectedTargetLanguage] ?? 'ENGLISH (EN)',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- CEFR Level Selection Tile ---
  Widget _buildCefrLevelTile(BuildContext context) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showCefrBottomSheet(context),
        child: Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.manaCyan, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CEFR PRACTICE LEVEL',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LEVEL $_selectedCefrLevel',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- Logout Tile ---
  Widget _buildLogoutTile(BuildContext context) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () async {
          await ref.read(authRepositoryProvider).signOut();
          if (context.mounted) {
            context.go('/');
          }
        },
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'LOG OUT OF DUNGEON',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.errorRed),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT TARGET PATH',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 16),
                _buildOption(
                  title: 'ENGLISH (EN)',
                  description: 'Engage in intense conversation and vocabulary modules.',
                  isActive: _selectedTargetLanguage == 'en',
                  icon: Icons.language_rounded,
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'en');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'FRENCH (FR)',
                  description: 'Engage in conversational French modules.',
                  isActive: _selectedTargetLanguage == 'fr',
                  icon: Icons.language_rounded,
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'fr');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'GERMAN (DE)',
                  description: 'Engage in structured German trials.',
                  isActive: _selectedTargetLanguage == 'de',
                  icon: Icons.language_rounded,
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'de');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'ITALIAN (IT)',
                  description: 'Engage in fluent Italian practice.',
                  isActive: _selectedTargetLanguage == 'it',
                  icon: Icons.language_rounded,
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'it');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCefrBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT CEFR LEVEL PATH',
                  style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((lvl) {
                    final isSel = _selectedCefrLevel == lvl;
                    return ChoiceChip(
                      selected: isSel,
                      onSelected: (_) {
                        setState(() => _selectedCefrLevel = lvl);
                        Navigator.pop(context);
                      },
                      label: Text(lvl),
                      labelStyle: GoogleFonts.jetBrainsMono(
                        color: isSel ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                      selectedColor: AppColors.runeViolet,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- AI Correction Level Tile ---
  Widget _buildCorrectionLevelTile(BuildContext context, String currentLevel) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showCorrectionLevelBottomSheet(context, currentLevel),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.runeViolet, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI CORRECTION SCOPE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCorrectionLevelName(currentLevel).toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- Tutor Personality Tile ---
  Widget _buildTutorPersonalityTile(BuildContext context, String currentPersonality) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showTutorPersonalityBottomSheet(context, currentPersonality),
        child: Row(
          children: [
            const Icon(Icons.face_rounded, color: AppColors.runeViolet, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TUTOR PERSONALITY',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPersonalityName(currentPersonality).toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- Correction Style Tile ---
  Widget _buildCorrectionStyleTile(BuildContext context, String currentStyle) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showCorrectionStyleBottomSheet(context, currentStyle),
        child: Row(
          children: [
            const Icon(Icons.spellcheck_rounded, color: AppColors.runeViolet, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CORRECTION CADENCE',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStyleName(currentStyle).toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- Daily Goal Tile ---
  Widget _buildDailyGoalTile(BuildContext context, int currentGoal) {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showDailyGoalBottomSheet(context, currentGoal),
        child: Row(
          children: [
            const Icon(Icons.outlined_flag_rounded, color: AppColors.runeViolet, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY QUEST FOCUS',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentGoal MINUTES DAILY',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- Notification Tiles ---
  Widget _buildNotificationTiles(BuildContext context, UserSettings currentSettings) {
    final enabled = currentSettings.notificationsEnabled;
    final time = currentSettings.notificationTime;
    final isSfxOn = ref.watch(sfxEnabledProvider);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: AppColors.manaCyan, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AUDIO SFX CHANNELS',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Combat, mana charges, and level calibration sfx',
                      style: GoogleFonts.inter(color: AppColors.onSurface.withValues(alpha: 0.54), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isSfxOn,
                activeColor: AppColors.manaCyan,
                activeTrackColor: AppColors.manaCyan.withValues(alpha: 0.2),
                inactiveThumbColor: AppColors.onSurface.withValues(alpha: 0.6),
                inactiveTrackColor: AppColors.onSurface.withValues(alpha: 0.12),
                onChanged: (val) {
                  ref.read(sfxEnabledProvider.notifier).setSfxEnabled(val);
                },
              ),
            ],
          ),
          Divider(color: AppColors.onSurface.withValues(alpha: 0.12), height: 24),
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: AppColors.runeViolet, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'DAILY ALERT EMISSIONS',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                activeColor: AppColors.runeViolet,
                activeTrackColor: AppColors.runeViolet.withValues(alpha: 0.2),
                inactiveThumbColor: AppColors.onSurface.withValues(alpha: 0.6),
                inactiveTrackColor: AppColors.onSurface.withValues(alpha: 0.12),
                onChanged: (val) {
                  setState(() {
                    _localSettings = currentSettings.copyWith(notificationsEnabled: val);
                  });
                },
              ),
            ],
          ),
          if (enabled) ...[
            Divider(color: AppColors.onSurface.withValues(alpha: 0.12), height: 24),
            InkWell(
              onTap: () async {
                final parts = time.split(':');
                final initialTime = TimeOfDay(
                  hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 20 : 20,
                  minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
                );
                final picked = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );
                if (picked != null) {
                  final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
                  setState(() {
                    _localSettings = currentSettings.copyWith(notificationTime: formattedTime);
                  });
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'ALERTS DISPATCH TIME',
                      style: GoogleFonts.inter(color: AppColors.onSurface.withValues(alpha: 0.7), fontSize: 14),
                    ),
                  ),
                  Text(
                    time.substring(0, 5),
                    style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Bottom Sheet Helpers ---
  void _showCorrectionLevelBottomSheet(BuildContext context, String currentLevel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SELECT CORRECTION LEVEL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOption(
                  title: 'IMPORTANT MISTAKES ONLY',
                  description: 'AI will only correct critical structural breaks.',
                  isActive: currentLevel == 'important_only',
                  icon: Icons.tune_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'important_only');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'COMPACT FEEDBACK',
                  description: 'Quick corrections with single line annotations.',
                  isActive: currentLevel == 'short',
                  icon: Icons.tune_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'short');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'MODERATE EXPLANATION',
                  description: 'Balanced corrections with 1 to 3 detail sentences.',
                  isActive: currentLevel == 'moderate',
                  icon: Icons.tune_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'moderate');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'DETAILED BREAKDOWN',
                  description: 'In-depth grammar blueprints with contextual examples.',
                  isActive: currentLevel == 'detailed',
                  icon: Icons.tune_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'detailed');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'ORACLE MASTER MODE',
                  description: 'Complete analysis of error blueprints.',
                  isActive: currentLevel == 'teacher',
                  icon: Icons.tune_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'teacher');
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTutorPersonalityBottomSheet(BuildContext context, String currentPersonality) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SELECT TUTOR PERSONALITY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOption(
                  title: 'COMPANION RATE',
                  description: 'Patient, warm, and highly supportive responses.',
                  isActive: currentPersonality == 'friendly',
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(tutorPersonality: 'friendly');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'COMMANDER BRIEF',
                  description: 'Formal, highly structured, and structured corrections.',
                  isActive: currentPersonality == 'professional',
                  icon: Icons.business_center_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(tutorPersonality: 'professional');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'BOSS CALIBER CHALLENGE',
                  description: 'High-level vocabulary demands and strict responses.',
                  isActive: currentPersonality == 'challenging',
                  icon: Icons.campaign_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(tutorPersonality: 'challenging');
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCorrectionStyleBottomSheet(BuildContext context, String currentStyle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SELECT CORRECTION CADENCE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOption(
                  title: 'STRICT ACTION',
                  description: 'Interrupts and repairs errors instantly.',
                  isActive: currentStyle == 'strict',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionStyle: 'strict');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'BALANCED COMPASS',
                  description: 'Maintains dialogue speed with structured correction feedback.',
                  isActive: currentStyle == 'balanced',
                  icon: Icons.balance_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionStyle: 'balanced');
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'IMMERSIVE RAIDS',
                  description: 'Keeps speaking flow; repairs only terminal breaks.',
                  isActive: currentStyle == 'conversational',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionStyle: 'conversational');
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDailyGoalBottomSheet(BuildContext context, int currentGoal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SELECT DAILY QUEST FOCUS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOption(
                  title: 'CASUAL RUN (10 MIN)',
                  description: 'Quick entry practice daily.',
                  isActive: currentGoal == 10,
                  icon: Icons.fitness_center_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 10);
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'REGULAR RAID (15 MIN)',
                  description: 'Solid learning rate path.',
                  isActive: currentGoal == 15,
                  icon: Icons.timer_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 15);
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'SERIOUS CAMPAIGN (30 MIN)',
                  description: 'Acquire fluent skill markers rapidly.',
                  isActive: currentGoal == 30,
                  icon: Icons.speed_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 30);
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'OVERLOAD OVERCLOCK (60 MIN)',
                  description: 'Complete immersion overdrive.',
                  isActive: currentGoal == 60,
                  icon: Icons.bolt_rounded,
                  onTap: () {
                    setState(() {
                      _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 60);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required String title,
    required String description,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.runeViolet.withValues(alpha: 0.1) : AppColors.onSurface.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: isActive ? AppColors.runeViolet : AppColors.onSurface.withValues(alpha: 0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? AppColors.runeViolet : AppColors.onSurfaceVariant, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.runeViolet,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceLanguageTile(BuildContext context) {
    final langSettings = ref.watch(userLanguageProvider);
    final deviceLang = ref.watch(deviceLocaleProvider);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.phonelink_setup_rounded, color: AppColors.manaCyan, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'USAR IDIOMA DEL DISPOSITIVO',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Detectado: ${deviceLang.toUpperCase()}',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: langSettings.followDeviceLanguage,
            activeThumbColor: AppColors.manaCyan,
            onChanged: (val) {
              ref.read(userLanguageProvider.notifier).setFollowDeviceLanguage(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterfaceLanguageTile(BuildContext context) {
    final langSettings = ref.watch(userLanguageProvider);
    const Map<String, String> langNames = {
      'en': 'ENGLISH (EN)',
      'es': 'SPANISH (ES)',
      'pt': 'PORTUGUESE (PT)',
    };

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: langSettings.followDeviceLanguage
            ? null
            : () => _showInterfaceLanguageBottomSheet(context),
        child: Row(
          children: [
            const Icon(Icons.language_rounded, color: AppColors.runeViolet, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IDIOMA DE LA APLICACIÓN',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    langNames[langSettings.uiLanguage] ?? langSettings.uiLanguage.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      color: langSettings.followDeviceLanguage ? AppColors.onSurfaceVariant : AppColors.manaCyan,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              langSettings.followDeviceLanguage ? Icons.lock_rounded : Icons.keyboard_arrow_down_rounded,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showInterfaceLanguageBottomSheet(BuildContext context) {
    const Map<String, String> langNames = {
      'en': 'ENGLISH',
      'es': 'ESPAÑOL',
      'pt': 'PORTUGUÊS',
    };
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        side: BorderSide(color: AppColors.runeViolet, width: 1.5),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'IDIOMA DE LA APLICACIÓN',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              ...langNames.entries.map((e) {
                return ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.manaCyan),
                  title: Text(e.value, style: const TextStyle(color: AppColors.onSurface)),
                  trailing: ref.watch(userLanguageProvider).uiLanguage == e.key
                      ? const Icon(Icons.check_rounded, color: AppColors.emeraldGreen)
                      : null,
                  onTap: () {
                    ref.read(userLanguageProvider.notifier).setUiLanguage(e.key);
                    Navigator.pop(sheetContext);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDevToolsTile(BuildContext context) {
    final devAlwaysShow = ref.watch(devAlwaysShowOnboardingProvider);

    return GlassCard(
      blur: 15,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forzar Onboarding Continuo',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Salta el inicio directo a la home y redirige a la pantalla de onboarding para testing.',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: devAlwaysShow,
                activeColor: AppColors.manaCyan,
                activeTrackColor: AppColors.manaCyan.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.onSurfaceVariant,
                inactiveTrackColor: AppColors.onSurface.withValues(alpha: 0.1),
                onChanged: (val) async {
                  await ref.read(devAlwaysShowOnboardingProvider.notifier).toggle(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.deepSlate),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final goRouter = GoRouter.of(context);
                final supabase = ref.read(supabaseClientProvider);
                final user = ref.read(currentUserProvider);
                if (user != null) {
                  try {
                    await supabase.from('user_language_profiles').delete().eq('user_id', user.id);
                    ref.invalidate(currentUserProvider);
                    ref.invalidate(userSettingsProvider);
                    SystemSnack.show(context, 'Perfil de cazador eliminado. Reiniciando...', type: SystemSnackType.info);
                    goRouter.go('/');
                  } catch (e) {
                    SystemSnack.show(context, 'Error al reiniciar: $e', type: SystemSnackType.error);
                  }
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'REINICIAR HISTORIAL DE ONBOARDING',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimsonRed,
                foregroundColor: AppColors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Names mappings ---
  String _getCorrectionLevelName(String level) {
    switch (level) {
      case 'important_only':
        return 'Important Errors Only';
      case 'short':
        return 'Compact Feedback';
      case 'moderate':
        return 'Moderate Explanation';
      case 'detailed':
        return 'Detailed Breakdown';
      case 'teacher':
        return 'Oracle Master Mode';
      default:
        return 'Compact Feedback';
    }
  }

  String _getPersonalityName(String personality) {
    switch (personality) {
      case 'friendly':
        return 'Companion Rate';
      case 'professional':
        return 'Commander Brief';
      case 'challenging':
        return 'Boss Caliber Challenge';
      default:
        return 'Companion Rate';
    }
  }

  String _getStyleName(String style) {
    switch (style) {
      case 'strict':
        return 'Strict Action';
      case 'balanced':
        return 'Balanced Compass';
      case 'conversational':
        return 'Immersive Raids';
      default:
        return 'Balanced Compass';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppColors.manaCyan,
        letterSpacing: 1.0,
      ),
    );
  }
}
