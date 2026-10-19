import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../missions/presentation/providers/mission_providers.dart';
import '../../../../l10n/app_localizations.dart';

class SrsFlashcardModal extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> vocabularyItems;

  const SrsFlashcardModal({
    super.key,
    required this.vocabularyItems,
  });

  static Future<void> show(BuildContext context, List<Map<String, dynamic>> items) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (context) => SrsFlashcardModal(vocabularyItems: items),
    );
  }

  @override
  ConsumerState<SrsFlashcardModal> createState() => _SrsFlashcardModalState();
}

class _SrsFlashcardModalState extends ConsumerState<SrsFlashcardModal> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _reviewedCount = 0;

  void _evaluateWord(double difficultyScore) async {
    if (_currentIndex < widget.vocabularyItems.length) {
      final currentItem = widget.vocabularyItems[_currentIndex];
      final vocabId = currentItem['vocabulary_id'] as String? ?? currentItem['id'] as String?;
      final user = ref.read(currentUserProvider);

      if (user != null && vocabId != null) {
        try {
          await ref.read(dashboardRepositoryProvider).updateVocabularySrsScore(
                user.id,
                vocabId,
                difficultyScore,
              );
        } catch (_) {}

        // Issue #5: cada palabra repasada cuenta para las misiones de
        // `vocab_words`.
        unawaited(ref
            .read(missionRepositoryProvider)
            .advanceMissions('vocab_words'));
      }
    }

    if (mounted) {
      setState(() {
        _reviewedCount++;
        if (_currentIndex < widget.vocabularyItems.length - 1) {
          _currentIndex++;
          _isFlipped = false;
        } else {
          _currentIndex = widget.vocabularyItems.length;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = widget.vocabularyItems.length;
    final isFinished = _currentIndex >= total || total == 0;

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPACED REPETITION REVIEW (SRS)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
              if (!isFinished)
                Text(
                  '${_currentIndex + 1}/$total',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.manaCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (isFinished)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.triumphGold, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'REVIEW WAVE CONQUERED!',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Successfully completed $_reviewedCount reviews. Next cycle in 24 hours.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.runeViolet,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                      child: Text(l10n.srs_close, style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFlipped = !_isFlipped;
                  });
                },
                child: GlassCard(
                  // Issue #58: el detector interno bloquea el tap del padre.
                  onTap: () {
                    setState(() {
                      _isFlipped = !_isFlipped;
                    });
                  },
                  blur: 30,
                  opacity: AppColors.glassOpacity,
                  border: Border.all(
                    color: AppColors.runeViolet.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isFlipped
                          ? Column(
                              key: const ValueKey('back'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.vocabularyItems[_currentIndex]['translation'] as String? ?? '',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.manaCyan,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'PATH: ${(widget.vocabularyItems[_currentIndex]['category'] ?? 'Vocabularies').toUpperCase()}',
                                  style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface.withValues(alpha: 0.7), fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                              ],
                            )
                          : Column(
                              key: const ValueKey('front'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.vocabularyItems[_currentIndex]['word'] as String? ?? '',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.touch_app_rounded, color: AppColors.onSurfaceVariant, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'TAP CARD TO REVEAL',
                                      style: GoogleFonts.jetBrainsMono(color: AppColors.onSurfaceVariant, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_isFlipped)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      // Issue #24: HARD es el único que debe contar como lapso.
                      // Antes NORMAL (2.5) también caía en `q < 3.0` y reiniciaba
                      // el intervalo, así que repasar bien no hacía progresar.
                      onPressed: () => _evaluateWord(2.0),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                      child: Text(l10n.srs_hard, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _evaluateWord(3.0),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.royalGold,
                        side: const BorderSide(color: AppColors.royalGold),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                      child: Text(l10n.srs_normal, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _evaluateWord(5.0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.easyGreen,
                        foregroundColor: AppColors.onSurface,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                      child: Text(l10n.srs_easy, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
