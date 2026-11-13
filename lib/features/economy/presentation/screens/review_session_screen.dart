import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/economy_providers.dart';

/// Un ejercicio de repaso derivado de una corrección real de la sesión (#375).
class ReviewItem {
  const ReviewItem({
    required this.original,
    required this.corrected,
    required this.explanation,
    required this.errorType,
  });

  final String original;
  final String corrected;
  final String explanation;
  final String errorType;

  static ReviewItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final original = raw['original']?.toString() ?? '';
    final corrected = raw['corrected']?.toString() ?? '';
    if (original.isEmpty || corrected.isEmpty) return null;
    return ReviewItem(
      original: original,
      corrected: corrected,
      explanation: raw['explanation']?.toString() ?? '',
      errorType: raw['error_type']?.toString() ?? 'grammar',
    );
  }
}

/// Respuesta de `open_review_pergamino`.
class ReviewPergaminoResult {
  const ReviewPergaminoResult({
    required this.success,
    required this.reason,
    required this.remaining,
    required this.items,
  });

  final bool success;
  final String? reason;
  final int remaining;
  final List<ReviewItem> items;

  /// `null` si la respuesta no tiene forma válida (red caída, RPC ausente…).
  static ReviewPergaminoResult? parse(Object? raw) {
    if (raw is! Map) return null;
    final list = raw['items'];
    final items = <ReviewItem>[];
    if (list is List) {
      for (final entry in list) {
        final item = ReviewItem.fromJson(entry);
        if (item != null) items.add(item);
      }
    }
    return ReviewPergaminoResult(
      success: raw['success'] == true,
      reason: raw['reason']?.toString(),
      remaining: (raw['remaining'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }
}

/// Pantalla de repaso: muestra la frase original y revela la corrección.
class ReviewSessionScreen extends ConsumerStatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  ReviewPergaminoResult? _result;
  bool _loading = true;
  int _index = 0;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(economyRepositoryProvider);
    final raw = await repo.openReviewPergamino();
    if (!mounted) return;
    setState(() {
      _result = ReviewPergaminoResult.parse(raw);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.onSurface,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        l10n.review_title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    if (_result != null && _result!.items.isNotEmpty)
                      Text(
                        '${_index + 1} / ${_result!.items.length}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppColors.manaCyan,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.manaCyan),
      );
    }

    final result = _result;
    if (result == null) {
      return _message(l10n.review_error);
    }
    if (!result.success) {
      return result.reason == 'no_pergaminos'
          ? _message(l10n.review_no_pergaminos)
          : _message(l10n.review_empty);
    }

    if (_index >= result.items.length) {
      return _message(l10n.review_done);
    }

    final item = result.items[_index];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.errorType.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.royalGold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.original,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurface,
                  ),
                ),
                if (_revealed) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.corrected,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emeraldGreen,
                    ),
                  ),
                  if (item.explanation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.explanation,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.manaCyan,
                foregroundColor: AppColors.voidBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () {
                setState(() {
                  if (!_revealed) {
                    _revealed = true;
                  } else {
                    _revealed = false;
                    _index++;
                  }
                });
              },
              child: Text(
                _revealed ? l10n.review_next : l10n.review_reveal,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.voidBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }

  Widget _message(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
