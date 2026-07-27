import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';


class SrsFlashcardModal extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> vocabularyItems;

  const SrsFlashcardModal({
    super.key,
    required this.vocabularyItems,
  });

  static void show(BuildContext context, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repaso Espaciado (SRS)',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!isFinished)
                Text(
                  '${_currentIndex + 1}/$total',
                  style: const TextStyle(
                    color: AppColors.tertiaryTeal,
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
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      '¡Repaso Completado!',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Has repasado $_reviewedCount palabras con éxito. Próximo repaso en 24 horas.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cerrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  blur: 30,
                  opacity: 0.1,
                  border: Border.all(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4),
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
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tertiaryTeal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Categoría: ${widget.vocabularyItems[_currentIndex]['category'] ?? 'Vocabulario'}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            )
                          : Column(
                              key: const ValueKey('front'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.vocabularyItems[_currentIndex]['word'] as String? ?? '',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.touch_app_rounded, color: AppColors.onSurfaceVariant, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Toca para revelar traducción',
                                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
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
                      onPressed: () => _evaluateWord(1.0),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        side: const BorderSide(color: AppColors.errorRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Difícil 😅', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _evaluateWord(2.5),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amberAccent,
                        side: const BorderSide(color: Colors.amberAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Normal ⚖️', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _evaluateWord(5.0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Fácil 😊', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
