import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/services/audio_sfx_service.dart';
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
  bool _soundEffectsEnabled = true;
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
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
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
                color: AppColors.secondaryBlue.withValues(alpha: 0.08),
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
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
                        'Ajustes',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
                      const _SectionHeader(title: '🌐 Idioma y Nivel de Aprendizaje'),
                      const SizedBox(height: 12),
                      _buildLanguageTile(context),
                      const SizedBox(height: 12),
                      _buildCefrLevelTile(context),
                      const SizedBox(height: 24),

                      const _SectionHeader(title: '🤖 Preferencia de IA y Tutor'),
                      const SizedBox(height: 12),
                      _buildCorrectionLevelTile(context, currentSettings.correctionLevel),
                      const SizedBox(height: 12),
                      _buildTutorPersonalityTile(context, currentSettings.tutorPersonality),
                      const SizedBox(height: 12),
                      _buildCorrectionStyleTile(context, currentSettings.correctionStyle),
                      const SizedBox(height: 12),
                      _buildDailyGoalTile(context, currentSettings.dailyGoalMinutes),
                      const SizedBox(height: 24),

                      const _SectionHeader(title: '🔔 Recordatorios'),
                      const SizedBox(height: 12),
                      _buildNotificationTiles(context, currentSettings),
                      const SizedBox(height: 24),

                      const _SectionHeader(title: '🚪 Cuenta'),
                      const SizedBox(height: 12),
                      _buildLogoutTile(context),
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
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
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
                                        const SnackBar(
                                          content: Text('Ajustes e Onboarding guardados correctamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al guardar ajustes: $e'),
                                          backgroundColor: AppColors.errorRed,
                                        ),
                                      );
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
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Guardar Ajustes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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
      'en': 'Inglés 🇺🇸',
      'fr': 'Francés 🇫🇷',
      'de': 'Alemán 🇩🇪',
      'it': 'Italiano 🇮🇹',
    };

    return GlassCard(
      blur: 20,
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showLanguageBottomSheet(context),
        child: Row(
          children: [
            const Icon(Icons.language_rounded, color: AppColors.tertiaryTeal, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Idioma Objetivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    langNames[_selectedTargetLanguage] ?? 'Inglés 🇺🇸',
                    style: TextStyle(
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
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showCefrBottomSheet(context),
        child: Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.tertiaryTeal, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nivel CEFR Activo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nivel $_selectedCefrLevel',
                    style: TextStyle(
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
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () async {
          await ref.read(authRepositoryProvider).signOut();
          if (context.mounted) {
            context.go('/');
          }
        },
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.errorRed),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecciona Idioma Objetivo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                _buildOption(
                  title: 'Inglés 🇺🇸',
                  description: 'Aprende inglés conversacional e intensivo.',
                  isActive: _selectedTargetLanguage == 'en',
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'en');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'Francés 🇫🇷',
                  description: 'Aprende francés conversacional.',
                  isActive: _selectedTargetLanguage == 'fr',
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'fr');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'Alemán 🇩🇪',
                  description: 'Aprende alemán estructurado.',
                  isActive: _selectedTargetLanguage == 'de',
                  onTap: () {
                    setState(() => _selectedTargetLanguage = 'de');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'Italiano 🇮🇹',
                  description: 'Aprende italiano fluido.',
                  isActive: _selectedTargetLanguage == 'it',
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
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecciona tu Nivel CEFR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
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
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedColor: AppColors.primaryPurple,
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
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showCorrectionLevelBottomSheet(context, currentLevel),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primaryPurpleDim, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nivel de Corrección de IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCorrectionLevelName(currentLevel),
                    style: TextStyle(
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
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showTutorPersonalityBottomSheet(context, currentPersonality),
        child: Row(
          children: [
            const Icon(Icons.face_rounded, color: AppColors.primaryPurpleDim, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personalidad del Tutor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPersonalityName(currentPersonality),
                    style: TextStyle(
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
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showCorrectionStyleBottomSheet(context, currentStyle),
        child: Row(
          children: [
            const Icon(Icons.spellcheck_rounded, color: AppColors.primaryPurpleDim, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estilo de Corrección',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStyleName(currentStyle),
                    style: TextStyle(
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
      opacity: 0.04,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => _showDailyGoalBottomSheet(context, currentGoal),
        child: Row(
          children: [
            const Icon(Icons.outlined_flag_rounded, color: AppColors.primaryPurpleDim, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meta Diaria',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentGoal minutos al día',
                    style: TextStyle(
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
      opacity: 0.04,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up_rounded, color: AppColors.tertiaryTeal, size: 24),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Efectos de Sonido Épicos (SFX)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sonidos de batallas, maná y subida de nivel',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isSfxOn,
                activeThumbColor: AppColors.tertiaryTeal,
                onChanged: (val) {
                  ref.read(sfxEnabledProvider.notifier).setSfxEnabled(val);
                },
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: AppColors.primaryPurpleDim, size: 24),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Recordatorios Diarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                activeThumbColor: AppColors.primaryPurpleDim,
                onChanged: (val) {
                  setState(() {
                    _localSettings = currentSettings.copyWith(notificationsEnabled: val);
                  });
                },
              ),
            ],
          ),
          if (enabled) ...[
            const Divider(color: Colors.white12, height: 24),
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
                  const Expanded(
                    child: Text(
                      'Hora del recordatorio',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  Text(
                    time.substring(0, 5),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nivel de Corrección',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildOption(
                    title: 'Solo errores importantes',
                    description: 'La IA únicamente corregirá errores graves.',
                    isActive: currentLevel == 'important_only',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'important_only');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Corrección corta',
                    description: 'Corrección y una explicación de una sola línea.',
                    isActive: currentLevel == 'short',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'short');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Corrección moderada',
                    description: 'Explicación corta de 1 a 3 frases.',
                    isActive: currentLevel == 'moderate',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'moderate');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Corrección detallada',
                    description: 'Explicación completa con gramática y ejemplos.',
                    isActive: currentLevel == 'detailed',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionLevel: 'detailed');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Modo profesor',
                    description: 'Clase completa sobre el error cometido.',
                    isActive: currentLevel == 'teacher',
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
          ),
        );
      },
    );
  }

  void _showTutorPersonalityBottomSheet(BuildContext context, String currentPersonality) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Personalidad del Tutor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildOption(
                    title: 'Amigable y paciente 😊',
                    description: 'Cálido y motivador en cada respuesta.',
                    isActive: currentPersonality == 'friendly',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(tutorPersonality: 'friendly');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Profesional e instructivo 🤵',
                    description: 'Explicaciones claras y enfoque estructurado.',
                    isActive: currentPersonality == 'professional',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(tutorPersonality: 'professional');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Desafiante y exigente 🏆',
                    description: 'Te empujará a usar mejor vocabulario.',
                    isActive: currentPersonality == 'challenging',
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
          ),
        );
      },
    );
  }

  void _showCorrectionStyleBottomSheet(BuildContext context, String currentStyle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Estilo de Corrección',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildOption(
                    title: 'Estricto 🎯',
                    description: 'Corrige cada detalle gramatical al instante.',
                    isActive: currentStyle == 'strict',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionStyle: 'strict');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Balanceado ⚖️',
                    description: 'Equilibrio entre fluidez y corrección.',
                    isActive: currentStyle == 'balanced',
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(correctionStyle: 'balanced');
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Conversacional 🗣️',
                    description: 'Solo interrumpe ante errores graves.',
                    isActive: currentStyle == 'conversational',
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
          ),
        );
      },
    );
  }

  void _showDailyGoalBottomSheet(BuildContext context, int currentGoal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Meta Diaria de Práctica',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildOption(
                    title: 'Casual',
                    description: '10 minutos al día.',
                    isActive: currentGoal == 10,
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 10);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Regular',
                    description: '15 minutos al día.',
                    isActive: currentGoal == 15,
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 15);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Serio',
                    description: '30 minutos al día.',
                    isActive: currentGoal == 30,
                    onTap: () {
                      setState(() {
                        _localSettings = (_localSettings ?? UserSettings.initial()).copyWith(dailyGoalMinutes: 30);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOption(
                    title: 'Intensivo',
                    description: '60 minutos al día.',
                    isActive: currentGoal == 60,
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
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required String title,
    required String description,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryPurple.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
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
                color: AppColors.primaryPurpleDim,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // --- Names mappings ---
  String _getCorrectionLevelName(String level) {
    switch (level) {
      case 'important_only':
        return 'Solo errores importantes';
      case 'short':
        return 'Corrección corta';
      case 'moderate':
        return 'Corrección moderada';
      case 'detailed':
        return 'Corrección detallada';
      case 'teacher':
        return 'Modo profesor';
      default:
        return 'Corrección corta';
    }
  }

  String _getPersonalityName(String personality) {
    switch (personality) {
      case 'friendly':
        return 'Amigable y paciente';
      case 'professional':
        return 'Profesional e instructivo';
      case 'challenging':
        return 'Desafiante y exigente';
      default:
        return 'Amigable y paciente';
    }
  }

  String _getStyleName(String style) {
    switch (style) {
      case 'strict':
        return 'Estricto';
      case 'balanced':
        return 'Balanceado';
      case 'conversational':
        return 'Conversacional';
      default:
        return 'Balanceado';
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
