import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/onboarding/domain/models/cefr_rank.dart';
import '../constants/api_constants.dart';

/// Evaluador de clasificación por IA del onboarding (el "Oráculo").
///
/// Analiza las transcripciones de la conversación del Oracle y devuelve una
/// evaluación CEFR (A1-C2) más el rango del juego (E, D, C, B, A, S, SS, SSS).
/// Usa la Edge Function `llm-proxy` (DeepSeek en el servidor), autenticada con
/// el JWT de sesión. Si la respuesta no es JSON válido o no contiene
/// `cefr_level`, hace fallback a la heurística de palabras promedio.
class PlacementAiEvaluator {
  PlacementAiEvaluator._();

  static const String _model = 'deepseek-v4-flash';

  static const List<String> _scoreKeys = [
    'listening',
    'speaking',
    'pronunciation',
    'vocabulary',
    'grammar',
    'sentence_structure',
    'confidence',
    'fluency',
    'response_time',
    'naturalness',
  ];

  /// Evalúa las respuestas del usuario durante el onboarding.
  ///
  /// [dio] permite reutilizar el cliente HTTP compartido del chat (misma
  /// autenticación que el resto de la app). Si es nulo, se crea una instancia
  /// propia. Las claves de DeepSeek viven en el servidor (llm-proxy).
  ///
  /// Retorna un mapa con las claves: `cefr_level`, `game_rank`, `scores`
  /// (pronunciation/vocabulary/grammar/comprehension/fluency 0-100),
  /// `strengths`, `weaknesses`, `explanation` y `recommended_focus`.
  static Future<Map<String, dynamic>> evaluatePlacement(
    List<String> userResponses, {
    Dio? dio,
  }) async {
    final transcript = _buildTranscript(userResponses);
    final systemPrompt = _buildSystemPrompt();
    final client = dio ?? Dio();
    final token = _authToken();

    try {
      final response = await client.post(
        '${ApiConstants.llmProxyBaseUrl}/chat',
        data: {
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': transcript},
          ],
          'stream': false,
          'temperature': 0.3,
          'max_tokens': 600,
        },
        options: Options(
          headers: {
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final choices = response.data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final content =
              choices[0]?['message']?['content'] as String? ?? '';
          final parsed = _parseJsonDefensive(content);
          if (parsed != null && parsed['cefr_level'] != null) {
            debugPrint('Placement AI raw response parsed OK');
            return _normalizeResult(parsed, userResponses);
          }
          debugPrint(
            'Placement AI response not valid or missing cefr_level -> fallback',
          );
        }
      } else {
        debugPrint('Placement AI unexpected status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('=== PLACEMENT AI ERROR ===');
      debugPrint('Error: $e');
      if (e is DioException) {
        debugPrint('Dio status: ${e.response?.statusCode}');
        debugPrint('Dio body: ${e.response?.data}');
      }
      debugPrint('===========================');
    }

    return _heuristicFallback(userResponses);
  }

  /// Construye el prompt del sistema con la personalidad del Oráculo.
  static String _buildSystemPrompt() {
    return '''
You are the Oracle of the Guild, an ancient and wise being that has judged thousands of adventurers in the Kingdom of the Word. You speak in a mystical, wise tone but evaluate objectively.

A young hunter has just arrived in the realm and spoken with you. Your task is to classify their spoken English from the conversation transcripts provided.

Assign:
1. A CEFR level (PRE-A1, A1, A2, B1, B2, C1 or C2). PRE-A1 is for speakers who can only manage isolated words (hello, yes/no, numbers, basic colors) with minimal vocabulary and no sentences.
2. A game rank from the scale: F, E, D, C, B, A, S, SS, SSS (F is lowest, SSS is highest). PRE-A1 maps to F, A1 maps to E.
3. Scores from 0 to 100 for ALL of these dimensions:
   - listening (how well they understood the questions)
   - speaking (overall speaking ability)
   - pronunciation (clarity and intelligibility)
   - vocabulary (range, precision, appropriateness)
   - grammar (correctness of structures, tenses, agreement)
   - sentence_structure (variety and complexity of sentences)
   - confidence (willingness to answer, hesitation)
   - fluency (flow, pace, no long pauses)
   - response_time (how quickly they responded)
   - naturalness (how natural the language sounds, not memorized)
4. Short lists of strengths and weaknesses.
5. A brief explanation of your judgment.
6. A recommended focus area (one short phrase) the student should work on next.

Evaluation rules:
- Be objective and strict but encouraging.
- Weigh difficult/expanded answers more than one-word replies.
- If the transcript contains mostly isolated words (one-word answers, minimal vocabulary, no sentences), assign PRE-A1/F rather than A1.
- If a transcript looks like STT noise or empty, do not penalize harshly; note it.
- Comprehension is judged by how relevant each answer is to the question asked.
- Cap: C2/SSS only for truly outstanding, complex, natural English.

Return ONLY a valid JSON object with EXACTLY these keys (no markdown, no code fences, no extra text):
{
  "cefr_level": "B1",
  "game_rank": "C",
  "scores": {"listening": 72, "speaking": 68, "pronunciation": 70, "vocabulary": 65, "grammar": 60, "sentence_structure": 62, "confidence": 78, "fluency": 66, "response_time": 75, "naturalness": 64},
  "strengths": ["clear basic sentences", "good comprehension"],
  "weaknesses": ["limited vocabulary range", "frequent tense mistakes"],
  "explanation": "Short paragraph justifying the assigned level.",
  "recommended_focus": "Past tenses and extended answers"
}
''';
  }

  /// Construye el mensaje del usuario con las transcripciones.
  static String _buildTranscript(List<String> userResponses) {
    if (userResponses.isEmpty) {
      return 'The student did not provide any spoken responses.';
    }
    final numbered = userResponses.asMap().entries
        .map((e) => 'Response ${e.key + 1}: "${e.value}"')
        .join('\n');
    return 'Student conversation transcripts:\n$numbered';
  }

  /// Convierte la respuesta JSON de DeepSeek en un mapa normalizado.
  static Map<String, dynamic> _normalizeResult(
    Map<String, dynamic> parsed,
    List<String> userResponses,
  ) {
    final cefr = _normalizeCefr(parsed['cefr_level']?.toString() ?? '');
    final rawRank = parsed['game_rank']?.toString() ?? '';

    return {
      'cefr_level': cefr,
      'game_rank': rawRank.trim().isEmpty
          ? CefrRank.gameRankFromCefr(cefr)
          : rawRank.trim().toUpperCase(),
      'scores': _normalizeScores(parsed['scores']),
      'strengths': _normalizeStringList(parsed['strengths']),
      'weaknesses': _normalizeStringList(parsed['weaknesses']),
      'explanation': parsed['explanation']?.toString() ?? '',
      'recommended_focus': parsed['recommended_focus']?.toString() ?? '',
    };
  }

  /// Normaliza los puntajes (0-100) a enteros.
  static Map<String, int> _normalizeScores(dynamic rawScores) {
    final Map<String, int> result = {};
    if (rawScores is Map) {
      for (final key in _scoreKeys) {
        final value = rawScores[key];
        if (value is num) {
          result[key] = value.round().clamp(0, 100);
        }
      }
    }
    return result;
  }

  static List<String> _normalizeStringList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _normalizeCefr(String cefr) {
    final normalized = cefr.trim().toUpperCase();
    if (['PRE-A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'].contains(normalized)) {
      return normalized;
    }
    if (normalized == 'A0' || normalized == 'PREA1' || normalized == 'PRE_A1') {
      return 'PRE-A1';
    }
    return 'A1';
  }

  /// Intenta extraer y decodificar el JSON de la respuesta, tolerando
  /// texto envolvente (markdown, explicaciones) y JSON malformado.
  static Map<String, dynamic>? _parseJsonDefensive(String content) {
    if (content.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      debugPrint('Placement AI: direct jsonDecode failed, trying extraction');
    }
    try {
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start != -1 && end > start) {
        final candidate = content.substring(start, end + 1);
        final decoded = jsonDecode(candidate);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {
      debugPrint('Placement AI: JSON extraction failed too');
    }
    return null;
  }

  /// Heurística de respaldo: clasifica por palabras promedio por respuesta,
  /// replicando el umbral del Oracle (A1<6, A2 6-11, B1 12-19, B2 20-31,
  /// C1>=32).
  static Map<String, dynamic> _heuristicFallback(List<String> userResponses) {
    String cefr = 'A1';
    if (userResponses.isNotEmpty) {
      int wordCount(String text) => text
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .length;

      final totalWords =
          userResponses.fold<int>(0, (sum, a) => sum + wordCount(a));
      final avg = totalWords / userResponses.length;

      if (avg >= 32) {
        cefr = 'C1';
      } else if (avg >= 20) {
        cefr = 'B2';
      } else if (avg >= 12) {
        cefr = 'B1';
      } else if (avg >= 6) {
        cefr = 'A2';
      } else {
        cefr = 'A1';
      }
    }

    debugPrint('Placement AI heuristic fallback -> $cefr');
    return {
      'cefr_level': cefr,
      'game_rank': CefrRank.gameRankFromCefr(cefr),
      'scores': const <String, int>{},
      'strengths': const <String>[],
      'weaknesses': const <String>[],
      'explanation':
          'Evaluación estimada por heurística (palabras promedio por respuesta) '
          'porque el Oráculo no pudo responder con un JSON válido.',
      'recommended_focus': 'Mantener conversación y ampliar las respuestas',
    };
  }

  /// Token JWT de sesión para autenticar contra el llm-proxy.
  static String _authToken() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session?.accessToken ?? '';
    } catch (_) {
      return '';
    }
  }
}
