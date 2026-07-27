import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TextDiffUtils {
  /// Compares original and corrected text and returns a list of TextSpans
  /// highlighting the differences.
  static List<InlineSpan> getDiffSpans(String? original, String corrected) {
    if (original == null || original.isEmpty || original == corrected) {
      return [TextSpan(text: corrected)];
    }

    final List<InlineSpan> spans = [];
    final originalWords = original.split(' ');
    final correctedWords = corrected.split(' ');

    // Simple word-by-word comparison for the demo/MVP
    // In a production app, use a more sophisticated diff algorithm (like Myers)
    int i = 0;
    while (i < originalWords.length || i < correctedWords.length) {
      if (i < originalWords.length && i < correctedWords.length) {
        if (originalWords[i].toLowerCase() == correctedWords[i].toLowerCase()) {
          spans.add(TextSpan(text: '${correctedWords[i]} '));
        } else {
          // Difference found
          spans.add(
            TextSpan(
              text: '${originalWords[i]} ',
              style: const TextStyle(
                color: Colors.redAccent,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
          spans.add(
            TextSpan(
              text: '${correctedWords[i]} ',
              style: const TextStyle(
                color: AppColors.tertiaryTealDim,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      } else if (i < originalWords.length) {
        // Extra words in original
        spans.add(
          TextSpan(
            text: '${originalWords[i]} ',
            style: const TextStyle(
              color: Colors.redAccent,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        );
      } else if (i < correctedWords.length) {
        // Extra words in corrected
        spans.add(
          TextSpan(
            text: '${correctedWords[i]} ',
            style: const TextStyle(
              color: AppColors.tertiaryTealDim,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      i++;
    }

    return spans;
  }
}
