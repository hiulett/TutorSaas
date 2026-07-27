import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/status_window_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String fallbackName = user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? (user != null ? 'Estudiante ${user.id.substring(0, 5)}' : 'Estudiante');

    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? {};
    final displayName = profile['display_name'] as String? ?? fallbackName;
    final avatarUrl = profile['avatar_url'] as String? ?? 'https://api.dicebear.com/7.x/bottts-neutral/svg?seed=$displayName';

    final progressAsync = ref.watch(userProgressProvider);
    final progress = progressAsync.value ?? {
      'xp': 2450,
      'streak': 7,
      'level_code': 'B1',
      'level': 'Intermedio',
      'language': 'Inglés',
      'language_emoji': '🇺🇸',
    };
    final int xp = progress['xp'] as int;
    final int streak = progress['streak'] as int;
    final String cefrCode = progress['level_code'] as String;
    final String languageEmoji = progress['language_emoji'] as String;
    final String languageName = progress['language'] as String;

    final weeklyPracticeAsync = ref.watch(weeklyPracticeProvider);
    final learnedVocabularyAsync = ref.watch(learnedVocabularyProvider);

    return Scaffold(
      body: Stack(
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
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
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
                color: AppColors.tertiaryTeal.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('📊', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'PANEL DE ESTADO',
                            style: GoogleFonts.orbitron(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          context.push('/settings');
                        },
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cyberpunk profile head card
                        GestureDetector(
                          onTap: () => context.push('/profile-edit'),
                          child: GlassCard(
                            blur: 20,
                            opacity: 0.04,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(avatarUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              displayName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Aprendiendo $languageName $languageEmoji',
                                        style: const TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Prominent Status Window Button
                        ElevatedButton(
                          onPressed: () => StatusWindowModal.show(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primaryPurple.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📊', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                'VENTANA DE ESTADO DEL CAZADOR',
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: GlassCard(
                                blur: 20,
                                opacity: 0.04,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.star_rounded, color: AppColors.primaryPurpleDim, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$xp',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('XP Total', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassCard(
                                blur: 20,
                                opacity: 0.04,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$streak',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Racha activa', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GlassCard(
                                blur: 20,
                                opacity: 0.04,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.psychology_rounded, color: AppColors.tertiaryTeal, size: 24),
                                    const SizedBox(height: 8),
                                    Text(
                                      cefrCode,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Nivel CEFR', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Weekly Practice Chart
                        const Text(
                          'Minutos de Práctica Semanal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        weeklyPracticeAsync.when(
                          data: (practiceList) => GlassCard(
                            blur: 20,
                            opacity: 0.04,
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              height: 150,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: practiceList.map((data) {
                                  final height = 100 * (data['heightFactor'] as double);

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${data['minutes']}m',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 14,
                                        height: height,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.primaryPurple, AppColors.secondaryBlue],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data['day'] as String,
                                        style: const TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          loading: () => const GlassCard(
                            blur: 20,
                            opacity: 0.04,
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                          ),
                          error: (e, s) => const GlassCard(
                            blur: 20,
                            opacity: 0.04,
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Error al cargar datos de práctica',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ),


                        // Vocabulary learned
                        learnedVocabularyAsync.when(
                          data: (vocabularyList) {
                            final displayList = vocabularyList.take(4).toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Vocabulario Aprendido',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _showAllVocabularyDialog(context, vocabularyList),
                                      child: const Text('VER TODO', style: TextStyle(color: AppColors.primaryPurpleDim, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (displayList.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Text(
                                      'Aún no has aprendido vocabulario en las conversaciones.',
                                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  ...displayList.map((vocab) => Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: GlassCard(
                                          blur: 20,
                                          opacity: 0.04,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    vocab['word'] as String? ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    vocab['translation'] as String? ?? '',
                                                    style: TextStyle(
                                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  vocab['category'] as String? ?? '',
                                                  style: const TextStyle(
                                                    color: AppColors.onSurfaceVariant,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                              ],
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                          ),
                          error: (e, s) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: Text('Error al cargar vocabulario', style: TextStyle(color: Colors.white70))),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom navigation bar matching dashboard
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GlassCard(
                blur: 30.0,
                opacity: 0.08,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.explore_rounded,
                      label: 'Explorar',
                      isActive: false,
                      onTap: () => context.go('/home'),
                    ),
                    _buildNavItem(
                      icon: Icons.school_rounded,
                      label: 'Aprender',
                      isActive: false,
                      onTap: () {},
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      isActive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryPurple : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.primaryPurple : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllVocabularyDialog(BuildContext context, List<Map<String, dynamic>> vocabularyList) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Vocabulario Aprendido',
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: vocabularyList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('No hay vocabulario para mostrar', style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: vocabularyList.length,
                    itemBuilder: (context, index) {
                      final vocab = vocabularyList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          blur: 20,
                          opacity: 0.04,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vocab['word'] as String? ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    vocab['translation'] as String? ?? '',
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  vocab['category'] as String? ?? '',
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: AppColors.primaryPurpleDim)),
            ),
          ],
        );
      },
    );
  }
}
