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
                color: AppColors.crimsonRed,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
          spans.add(
            TextSpan(
              text: '${correctedWords[i]} ',
              style: const TextStyle(
                color: AppColors.manaCyanDim,
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
              color: AppColors.crimsonRed,
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
              color: AppColors.manaCyanDim,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      i++;
    }

    return spans;
  }

  /// Calculates percentage similarity between two strings using Levenshtein distance.
  static double calculateSimilarity(String textA, String textB) {
    final a = textA.toLowerCase().trim();
    final b = textB.toLowerCase().trim();
    if (a == b) return 100.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final dp = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (int i = 0; i <= a.length; i++) dp[i][0] = i;
    for (int j = 0; j <= b.length; j++) dp[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [
            dp[i - 1][j],
            dp[i][j - 1],
            dp[i - 1][j - 1]
          ].reduce((curr, next) => curr < next ? curr : next);
        }
      }
    }
    final maxLen = a.length > b.length ? a.length : b.length;
    return (1.0 - dp[a.length][b.length] / maxLen) * 100.0;
  }
}
