import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/core/ai/sse_chat_decoder.dart';

/// Contrato del stream SSE del chat (P-18 / #103).
void main() {
  group('SseChatDecoder', () {
    test('extrae el delta de contenido', () {
      final decoder = SseChatDecoder();
      final chunk = decoder.addLine(
        'data: {"choices":[{"delta":{"content":"Hello"},"finish_reason":null}]}',
      );

      expect(chunk, 'Hello');
      expect(decoder.isDone, isFalse);
    });

    test('ignora lineas vacias y que no son data:', () {
      final decoder = SseChatDecoder();
      expect(decoder.addLine(''), '');
      expect(decoder.addLine(': keep-alive'), '');
      expect(decoder.addLine('event: message'), '');
    });

    test('el chunk de usage (choices vacio) no rompe ni aporta texto', () {
      final decoder = SseChatDecoder();
      final chunk = decoder.addLine(
        'data: {"choices":[],"usage":{"prompt_tokens":10,"completion_tokens":5}}',
      );

      expect(chunk, '');
      expect(decoder.isDone, isFalse);
    });

    test('[DONE] cierra el stream y lo siguiente se ignora', () {
      final decoder = SseChatDecoder();
      expect(decoder.addLine('data: [DONE]'), '');
      expect(decoder.isDone, isTrue);
      expect(
        decoder.addLine('data: {"choices":[{"delta":{"content":"late"}}]}'),
        '',
      );
    });

    test('JSON invalido se ignora sin lanzar', () {
      final decoder = SseChatDecoder();
      expect(decoder.addLine('data: {"choices":['), '');
      expect(decoder.addLine('data: not-json'), '');
      expect(decoder.isDone, isFalse);
    });

    test('delta sin content o con content no string devuelve vacio', () {
      final decoder = SseChatDecoder();
      expect(decoder.addLine('data: {"choices":[{"delta":{}}]}'), '');
      expect(
        decoder.addLine('data: {"choices":[{"delta":{"content":42}}]}'),
        '',
      );
    });

    test('acumula varios chunks en orden', () {
      final decoder = SseChatDecoder();
      final buffer = StringBuffer()
        ..write(
          decoder.addLine('data: {"choices":[{"delta":{"content":"Hello"}}]}'),
        )
        ..write(
          decoder.addLine(
            'data: {"choices":[{"delta":{"content":", brave"}}]}',
          ),
        )
        ..write(
          decoder.addLine('data: {"choices":[{"delta":{"content":"!"}}]}'),
        );

      expect(buffer.toString(), 'Hello, brave!');
    });
  });
}
