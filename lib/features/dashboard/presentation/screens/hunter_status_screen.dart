import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../data/models/hunter_catalog.dart';
import '../widgets/charts/skills_radar_chart.dart';
import '../widgets/charts/fluency_latency_chart.dart';
import '../widgets/charts/practice_heatmap.dart';

class HunterStatusScreen extends ConsumerStatefulWidget {
  const HunterStatusScreen({super.key});

  @override
  ConsumerState<HunterStatusScreen> createState() => _HunterStatusScreenState();
}

class _HunterStatusScreenState extends ConsumerState<HunterStatusScreen> {
  int _str = 5;
  int _int = 5;
  int _dex = 5;
  int _luk = 5;
  int _pointsPool = 10;
  String _equippedTitleCode = 'oido_halcon_abismo_c';
  bool _isSaving = false;
  String _bioText = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final profile = ref.read(userProfileProvider).value;
      final progress = ref.read(userProgressProvider).value;
      if (profile != null) {
        // Stats desde columnas reales (con fallback a los valores base).
        setState(() {
          _str = (profile['str_stat'] as num?)?.toInt() ?? 5;
          _int = (profile['int_stat'] as num?)?.toInt() ?? 5;
          _dex = (profile['dex_stat'] as num?)?.toInt() ?? 5;
          _luk = (profile['luk_stat'] as num?)?.toInt() ?? 5;
          _equippedTitleCode = progress?['equipped_title_code'] as String? ?? 'oido_halcon_abismo_c';
          _bioText = profile['bio'] as String? ?? '';
          final totalUsed = (_str - 5) + (_int - 5) + (_dex - 5) + (_luk - 5);
          _pointsPool = 10 - totalUsed;
          if (_pointsPool < 0) _pointsPool = 0;
        });
      }
    });
  }

  void _parseBio(String rawBio) {
    if (rawBio.startsWith('[Stats|')) {
      try {
        final regex = RegExp(r'^\[Stats\|STR:(\d+)\|INT:(\d+)\|DEX:(\d+)\|LUK:(\d+)\]\s*(.*)$');
        final match = regex.firstMatch(rawBio);
        if (match != null) {
          setState(() {
            _str = int.parse(match.group(1)!);
            _int = int.parse(match.group(2)!);
            _dex = int.parse(match.group(3)!);
            _luk = int.parse(match.group(4)!);
            _bioText = match.group(5)!;
            
            final totalUsed = (_str - 5) + (_int - 5) + (_dex - 5) + (_luk - 5);
            _pointsPool = 10 - totalUsed;
            if (_pointsPool < 0) _pointsPool = 0;
          });
          return;
        }
      } catch (_) {}
    }
    setState(() {
      _bioText = rawBio;
      _str = 5;
      _int = 5;
      _dex = 5;
      _luk = 5;
      _pointsPool = 10;
    });
  }

  String _formatBio() {
    return '[Stats|STR:$_str|INT:$_int|DEX:$_dex|LUK:$_luk] ${_bioText.trim()}';
  }

  Future<void> _saveStats() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider);
      final profile = ref.read(userProfileProvider).value;
      if (user != null && profile != null) {
        await ref.read(dashboardRepositoryProvider).updateUserProfile(
          user.id,
          displayName: profile['display_name'] as String?,
          avatarUrl: profile['avatar_url'] as String?,
          nativeLanguage: profile['native_language'] as String?,
          bio: _bioText.trim().isEmpty ? profile['bio'] as String? : _bioText.trim(),
          strStat: _str,
          intStat: _int,
          dexStat: _dex,
          lukStat: _luk,
          equippedTitleCode: _equippedTitleCode,
        );

        ref.invalidate(userProfileProvider);
        ref.invalidate(userProgressProvider);
        if (mounted) {
          SystemSnack.show(context, 'ESTADÍSTICAS DEL CAZADOR ACTUALIZADAS ⚡', type: SystemSnackType.success);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isSaving = false);
  }

  /// Modal para elegir y equipar un título de la colección del cazador.
  Future<void> _showEquipTitleModal(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'EQUIPAR TÍTULO',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: HunterCatalog.titles.length,
                  separatorBuilder: (context, index) => Divider(color: AppColors.onSurface.withValues(alpha: 0.08), height: 1),
                  itemBuilder: (context, index) {
                    final title = HunterCatalog.titles[index];
                    final isEquipped = title.code == _equippedTitleCode;
                    return ListTile(
                      leading: Text(title.icon, style: const TextStyle(fontSize: 20)),
                      title: Text(
                        title.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: isEquipped ? FontWeight.bold : FontWeight.w500,
                          color: isEquipped ? AppColors.royalGold : AppColors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        title.description,
                        style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                      trailing: isEquipped
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.royalGold, size: 20)
                          : null,
                      onTap: () => Navigator.pop(context, title.code),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _equippedTitleCode && mounted) {
      setState(() => _equippedTitleCode = selected);
      await _saveStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value ?? {};
    final progressAsync = ref.watch(userProgressProvider);
    final progress = progressAsync.value ?? {};

    final displayName = profile['display_name'] as String? ?? 'Hunter';
    final userAvatarUrl = profile['avatar_url'] as String? ?? 'warrior';
    final cefrCode = progress['level_code'] as String? ?? 'A1';
    final xp = progress['xp'] as int? ?? 0;
    final String initials = displayName.trim().isNotEmpty
        ? displayName.trim().substring(0, 1).toUpperCase()
        : 'H';

    final activeTitle = HunterCatalog.titles.firstWhere(
      (t) => t.code == _equippedTitleCode,
      orElse: () => HunterCatalog.titles.first,
    );

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'ESTADO DEL CAZADOR',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar & Title Card (compact)
                      GlassCard(
                        borderColor: AppColors.manaCyan.withValues(alpha: 0.5),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          children: [
                            RpgAvatar(
                              avatarUrl: userAvatarUrl,
                              initials: initials,
                              size: 56,
                              hunterClass: userAvatarUrl,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName.toUpperCase(),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: _Badge(
                                          icon: Icons.military_tech_rounded,
                                          color: AppColors.royalGold,
                                          label: activeTitle.name.toUpperCase(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: _Badge(
                                          icon: Icons.speed_rounded,
                                          color: AppColors.manaCyan,
                                          label: 'CEFR $cefrCode · $xp XP',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Título equipado + botón para equipar
                      GlassCard(
                        borderColor: AppColors.royalGold.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded, color: AppColors.royalGold, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TÍTULO EQUIPADO',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeTitle.name.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.royalGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showEquipTitleModal(context),
                              icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                              label: Text(
                                'EQUIPAR',
                                style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              style: TextButton.styleFrom(foregroundColor: AppColors.manaCyan),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Análisis de Fluidez y Radar (Consolidado)
                      _SectionHeader(
                        icon: Icons.speed_rounded,
                        title: 'ANÁLISIS DE FLUIDEZ',
                      ),
                      const SizedBox(height: 12),
                      const FluencyLatencyChart(),
                      const SizedBox(height: 20),

                      _SectionHeader(
                        icon: Icons.radar_rounded,
                        title: 'RADAR HOLOGRÁFICO',
                      ),
                      const SizedBox(height: 10),
                      const SkillsRadarChart(),
                      const SizedBox(height: 20),

                      _SectionHeader(
                        icon: Icons.calendar_month_rounded,
                        title: 'CONSISTENCIA DE PRÁCTICA',
                      ),
                      const SizedBox(height: 10),
                      const PracticeHeatmap(),
                      const SizedBox(height: 20),

                      // Stat points pool
                      if (_pointsPool > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.royalGold.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.royalGold),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'PUNTOS DISPONIBLES: $_pointsPool',
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                                color: AppColors.royalGold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                      // Attribute Grid
                      Column(
                        children: [
                          _buildStatRow('STR (FUERZA)', _str, (val) => setState(() => _str = val)),
                          _buildStatRow('INT (INTELIGENCIA)', _int, (val) => setState(() => _int = val)),
                          _buildStatRow('DEX (DESTREZA)', _dex, (val) => setState(() => _dex = val)),
                          _buildStatRow('LUK (SUERTE)', _luk, (val) => setState(() => _luk = val)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save Button (micro-interacción AN-D)
                      RunicButton(
                        label: 'DISTRIBUIR PUNTOS',
                        icon: Icons.verified_rounded,
                        backgroundColor: AppColors.manaCyan,
                        foregroundColor: AppColors.voidBg,
                        isBusy: _isSaving,
                        onPressed: _isSaving ? null : _saveStats,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String name, int val, ValueChanged<int> onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface.withValues(alpha: 0.7), fontSize: 13),
                ),
                const SizedBox(height: 6),
                SegmentedBar(
                  value: (val / 20).clamp(0.0, 1.0),
                  segments: 10,
                  height: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: AppColors.onSurface.withValues(alpha: 0.54)),
                onPressed: val > 5 ? () {
                  onChange(val - 1);
                  setState(() => _pointsPool++);
                } : null,
              ),
              AnimatedCounter(
                target: val,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.manaCyan),
                onPressed: _pointsPool > 0 ? () {
                  onChange(val + 1);
                  setState(() => _pointsPool--);
                } : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _Badge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.manaCyan, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
