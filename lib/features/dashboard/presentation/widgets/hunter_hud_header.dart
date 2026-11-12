import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/floating_reward.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../economy/presentation/widgets/oracle_mana_bar.dart';
import '../providers/dashboard_providers.dart';
import '../../data/models/hunter_catalog.dart';
import '../../data/models/hunter_skill_titles.dart';
import '../../domain/models/aura_system.dart';
import '../../domain/models/hunter_level.dart';

/// HUD central del dashboard (paridad con PlantillaHtml/hunter_control_center_dashboard).
/// Muestra: avatar + nombre + tÃ­tulo, mana gem, barra de manÃ¡ del OrÃ¡culo y
/// notificaciones de misiones/racha. Reutiliza widgets core (GlassCard,
/// RpgAvatar) y tipografÃ­a estÃ¡ndar.
class HunterHudHeader extends ConsumerStatefulWidget {
  const HunterHudHeader({super.key});

  @override
  ConsumerState<HunterHudHeader> createState() => _HunterHudHeaderState();
}

class _HunterHudHeaderState extends ConsumerState<HunterHudHeader> {
  static const int _xpPerLevel = HunterLevel.xpPerLevel;
  int _lastLevel = 0;
  bool _awakeningBannerShown = false;

  /// Banner del Sistema la primera vez que el cazador despierta el Aura.
  Future<void> _maybeShowAwakeningBanner() async {
    if (_awakeningBannerShown) return;
    final user = ref.read(currentUserProvider);
    final prefs = await SharedPreferences.getInstance();
    final key = 'aura_awakening_seen_${user?.id ?? ''}';
    if (prefs.getBool(key) ?? false) return;
    await prefs.setBool(key, true);
    _awakeningBannerShown = true;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppColors.statusWindowBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: AppColors.manaCyan, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.manaCyan, size: 42),
                const SizedBox(height: 12),
                Text(
                  l10n.aura_awakening_banner_title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.aura_awakening_banner_desc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.manaCyan,
                    foregroundColor: AppColors.voidBg,
                  ),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(userProgressProvider).value ?? {};

    // Despertar del Aura: banner del Sistema la primera vez (persistido por user).
    ref.listen<AsyncValue<AuraSnapshot>>(auraStateProvider, (prev, next) {
      final wasAwakened = prev?.value?.isAwakened ?? false;
      final isAwakened = next.value?.isAwakened ?? false;
      if (isAwakened && !wasAwakened) {
        _maybeShowAwakeningBanner();
      }
    });

    // TÃ­tulos de habilidad reciÃ©n ganados â†’ banner "TÃTULO GANADO" (una vez).
    ref.listen<List<SkillTitle>>(newEarnedTitlesProvider, (prev, next) {
      if (next.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final t in next) {
          final color = switch (t.rarity) {
            'legendary' => AppColors.royalGold,
            'epic' => AppColors.runeViolet,
            'rare' => AppColors.manaCyan,
            _ => AppColors.onSurfaceVariant,
          };
          FloatingReward.show(
            context,
            l10n?.title_earned_banner(t.name.toUpperCase()) ??
                'ðŸ… TÃTULO GANADO: ${t.name.toUpperCase()}',
            icon: Icons.military_tech_rounded,
            color: color,
          );
        }
        ref.read(newEarnedTitlesProvider.notifier).state = const [];
      });
    });

    final int xp = progress['xp'] as int? ?? 0;
    final String languageEmoji = progress['language_emoji'] as String? ?? 'ðŸ‡ºðŸ‡¸';

    // ManÃ¡ (FASE B): Ãºnica moneda de energÃ­a. Saldo = asignaciÃ³n del plan
    // + comprado âˆ’ usado. Se adquiere con dinero; nunca se gana jugando.

    final String equippedTitleCode =
        progress['equipped_title_code'] as String? ?? 'oido_halcon_abismo_c';
    final activeTitle = HunterCatalog.titles.firstWhere(
      (t) => t.code == equippedTitleCode,
      orElse: () => HunterCatalog.titles.first,
    );

    // TÃ­tulo de habilidad: el de mayor tier ganado gana; si no hay ninguno,
    // se muestra el tÃ­tulo legacy equipado (fallback).
    final skillTitle = ref.watch(activeSkillTitleProvider);
    final String headerTitle = skillTitle?.localizedName(l10n) ?? activeTitle.localizedName(l10n);

    // Mana gem: energÃ­a de prÃ¡ctica diaria (invocaciones restantes).

    // DetecciÃ³n de subida de nivel (AN-E): muestra recompensa flotante.
    final currentLevel = xp ~/ _xpPerLevel;
    if (currentLevel > _lastLevel && _lastLevel >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FloatingReward.show(
            context,
            l10n?.level_up_banner(currentLevel) ?? 'Â¡SUBIDA DE NIVEL! $currentLevel',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.royalGold,
          );
        }
      });
    }
    _lastLevel = currentLevel;

    return GlassCard(
      borderColor: AppColors.manaCyan.withValues(alpha: 0.35),
      showRunicCorners: true,
      runicColor: AppColors.manaCyan,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${headerTitle.toUpperCase()} Â· $languageEmoji',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.royalGold,
            ),
          ),
          const SizedBox(height: 14),
          // Barra de manÃ¡ del OrÃ¡culo (Ãºnica representaciÃ³n del manÃ¡).
          const OracleManaBar(showLabel: true),
          const SizedBox(height: 4),
          Row(
            children: [
              // Grupo izquierdo flexible: chips + racha con elipsis.
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.royalGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'RACHA ${progress['streak'] ?? 0}D',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Issue #28: el XP ahora tiene nivel visible.
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.manaCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Nv. ${HunterLevel.levelFor(xp)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.manaCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.system_hunter_connected ?? 'SISTEMA DE CAZADOR â€” CONECTADO',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              letterSpacing: 2,
              color: AppColors.manaCyan.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
