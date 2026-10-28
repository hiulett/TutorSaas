import 'dart:convert';

/// Decodifica el SSE de un `chat/completions` (DeepSeek/OpenAI) linea a linea.
///
/// P-18 (#103): aisla el contrato del stream para poder probarlo sin red ni
/// Dio. El repositorio sigue leyendo hasta `[DONE]` para no perder el chunk
/// final de `usage` (P-14).
class SseChatDecoder {
  bool _done = false;

  /// true cuando ya se leyo `data: [DONE]`.
  bool get isDone => _done;

  /// Procesa una linea y devuelve el delta de contenido ('' si no aporta).
  ///
  /// Ignora lineas vacias, comentarios SSE, JSON invalido y chunks sin
  /// `choices` (p. ej. el chunk de `usage`).
  String addLine(String line) {
    if (_done) return '';
    final trimmed = line.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('data:')) return '';

    final payload = trimmed.substring(5).trim();
    if (payload.isEmpty) return '';
    if (payload == '[DONE]') {
      _done = true;
      return '';
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      // Chunk partido o ruido del proveedor: se ignora.
      return '';
    }

    if (decoded is! Map) return '';
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return '';
    final choice = choices.first;
    if (choice is! Map) return '';
    final delta = choice['delta'];
    if (delta is! Map) return '';
    final content = delta['content'];
    return content is String ? content : '';
  }
}
