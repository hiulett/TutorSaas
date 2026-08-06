import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/hunter_class_data.dart';
import '../providers/hunter_classes_providers.dart';
import 'class_stats_radar.dart';

class CharacterCreationData {
  final String name;
  final String playerClass;
  final int avatarIndex;

  const CharacterCreationData({
    this.name = '',
    required this.playerClass,
    this.avatarIndex = 0,
  });
}

class CharacterCreationWizard extends ConsumerStatefulWidget {
  final Function(CharacterCreationData) onComplete;

  const CharacterCreationWizard({super.key, required this.onComplete});

  @override
  ConsumerState<CharacterCreationWizard> createState() => _CharacterCreationWizardState();
}

class _CharacterCreationWizardState extends ConsumerState<CharacterCreationWizard> {
  final PageController _carouselController = PageController(viewportFraction: 0.72);
  String _selectedClass = 'warrior';
  int _currentIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, List<HunterClassData> classes) {
    setState(() {
      _currentIndex = index;
      if (index < classes.length) {
        _selectedClass = classes[index].id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final classesAsync = ref.watch(hunterClassesProvider);
    final classes = classesAsync.value ?? const <HunterClassData>[];
    final selected = classes.isEmpty
        ? null
        : classes.firstWhere(
            (c) => c.id == _selectedClass,
            orElse: () => classes.first,
          );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (una línea)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    l10n.character_creation_title,
                    maxLines: 1,
                    style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.medievalAgedGoldLight, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    l10n.character_creation_desc,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.medievalTextDim, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // CARRUSEL de avatares grandes
          if (classesAsync.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.medievalAgedGold, strokeWidth: 2.5),
              ),
            )
          else if (classes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(l10n.character_class_unavailable, style: AppTypography.bodyMuted(context)),
              ),
            )
          else ...[
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _carouselController,
                itemCount: classes.length,
                onPageChanged: (i) => _onPageChanged(i, classes),
                itemBuilder: (context, index) {
                  final cls = classes[index];
                  final isSelected = _selectedClass == cls.id;
                  final color = cls.color;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedScale(
                      scale: isSelected ? 1.0 : 0.86,
                      duration: const Duration(milliseconds: 220),
                      child: GestureDetector(
                        onTap: () {
                          _carouselController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                          );
                          setState(() => _selectedClass = cls.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: AppColors.medievalIron.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected ? AppColors.medievalAgedGold : AppColors.medievalStone,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.medievalAgedGold.withValues(alpha: 0.3), blurRadius: 14)]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Avatar art (fondo #0B0E16, centrado)
                                Positioned.fill(
                                  child: Image.asset(
                                    cls.imageUrl,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.medievalBg,
                                      child: Icon(cls.icon, color: color, size: 56),
                                    ),
                                  ),
                                ),
                                // Nombre + rol
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, AppColors.medievalBg.withValues(alpha: 0.9)],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          cls.nameFor(locale),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.subtitle(context).copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? AppColors.medievalAgedGoldLight : AppColors.medievalText,
                                          ),
                                        ),
                                        Text(
                                          cls.roleFor(locale).toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.jetBrainsMono(fontSize: 9, letterSpacing: 0.8, color: AppColors.medievalTextDim),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.medievalAgedGold,
                                        boxShadow: [BoxShadow(color: AppColors.medievalAgedGold.withValues(alpha: 0.7), blurRadius: 8)],
                                      ),
                                      child: const Icon(Icons.check_rounded, color: AppColors.medievalBg, size: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Dots
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(classes.length, (i) {
                  final isActive = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive ? AppColors.medievalAgedGold : AppColors.medievalStone,
                    ),
                  );
                }),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // FICHA RPG amplia (radar)
          if (selected != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _ClassSheet(
                  key: ValueKey(selected.id),
                  cls: selected,
                  locale: locale,
                  l10n: l10n,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Botón continuar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: RunicButton(
                label: l10n.character_creation_continue,
                icon: Icons.auto_awesome_rounded,
                onPressed: () => widget.onComplete(CharacterCreationData(
                      playerClass: selected?.id ?? 'warrior',
                      avatarIndex: _currentIndex,
                    )),
                isBusy: false,
                backgroundColor: AppColors.medievalAgedGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ficha oficial del gremio con radar (amplia hacia los lados, centrada).
class _ClassSheet extends StatelessWidget {
  final HunterClassData cls;
  final String locale;
  final AppLocalizations l10n;

  const _ClassSheet({super.key, required this.cls, required this.locale, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final color = cls.color;
    final abilities = cls.abilitiesFor(locale);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.medievalBg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.medievalAgedGold.withValues(alpha: 0.4), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: clase · rol · rarity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.nameFor(locale),
                        style: AppTypography.subtitle(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.medievalAgedGoldLight,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        cls.roleFor(locale),
                        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.medievalTextDim, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                _RarityChip(rarity: cls.rarity, color: color),
              ],
            ),
            const SizedBox(height: 8),

            // RADAR (amplio)
            ClassStatsRadar(cls: cls, l10n: l10n),
            // Separación amplia: evita que el título inferior del radar
            // (velocidad) se superponga con la descripción.
            const SizedBox(height: 30),

            // Descripción
            if (cls.descriptionFor(locale).isNotEmpty)
              Text(
                cls.descriptionFor(locale),
                style: AppTypography.body(context).copyWith(fontSize: 11, height: 1.35, color: AppColors.medievalText),
              ),
            const SizedBox(height: 8),

            // Especialidad (combate) + afinidad
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (cls.combatTypeFor(locale).isNotEmpty)
                  _MetaChip(label: l10n.character_combat_label, value: cls.combatTypeFor(locale), color: color),
                if (cls.affinityFor(locale).isNotEmpty)
                  _MetaChip(label: l10n.character_affinity_label, value: cls.affinityFor(locale), color: color),
              ],
            ),

            // Habilidades
            if (abilities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.character_abilities_label,
                style: AppTypography.tiny(context).copyWith(fontWeight: FontWeight.bold, color: AppColors.medievalTextDim, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: abilities.map((a) => _AbilityChip(text: a, color: color)).toList(),
              ),
            ],

            // Estilo de juego
            if (cls.playstyleFor(locale).isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.play_circle_outline_rounded, size: 14, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cls.playstyleFor(locale),
                      style: AppTypography.tiny(context).copyWith(fontSize: 10, height: 1.3, color: AppColors.medievalTextDim),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final String rarity;
  final Color color;

  const _RarityChip({required this.rarity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.medievalAgedGold.withValues(alpha: 0.4)),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.medievalAgedGoldLight, letterSpacing: 0.6),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetaChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.medievalIron.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.medievalStone),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.medievalText),
      ),
    );
  }
}

class _AbilityChip extends StatelessWidget {
  final String text;
  final Color color;

  const _AbilityChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.medievalStone),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 9, color: AppColors.medievalText)),
    );
  }
}
