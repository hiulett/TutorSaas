import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/chat_rooms/presentation/widgets/guild_master_floating_banner.dart';

/// Regresión de #62: el Maestre de Mesa añadía una burbuja por cada chunk del
/// stream porque `_streaming` (String) se comparaba con el booleano `true`.
void main() {
  group('applyGuildMasterChunk', () {
    test('tres chunks producen una sola burbuja con el texto acumulado', () {
      final history = <Map<String, String>>[
        {'role': 'user', 'content': 'Dame un consejo'},
      ];

      applyGuildMasterChunk(history, 'Hello');
      applyGuildMasterChunk(history, 'Hello, brave');
      applyGuildMasterChunk(history, 'Hello, brave adventurer!');

      expect(history, hasLength(2), reason: 'usuario + una sola respuesta');
      expect(history.last['role'], 'assistant');
      expect(history.last['content'], 'Hello, brave adventurer!');
      expect(history.last['_streaming'], 'true');
    });

    test('un segundo turno crea una burbuja nueva', () {
      final history = <Map<String, String>>[
        {'role': 'user', 'content': 'Primera'},
      ];

      applyGuildMasterChunk(history, 'Uno');
      history.last.remove('_streaming'); // fin del turno
      history.add({'role': 'user', 'content': 'Segunda'});
      applyGuildMasterChunk(history, 'Dos');

      expect(history, hasLength(4)); // user, assistant, user, assistant
      expect(history[1]['content'], 'Uno');
      expect(history[3]['content'], 'Dos');
    });

    test('no confunde una respuesta cerrada con una en curso', () {
      final history = <Map<String, String>>[
        {'role': 'assistant', 'content': 'Cerrada'},
      ];

      applyGuildMasterChunk(history, 'Nueva');

      expect(history, hasLength(2));
      expect(history.last['content'], 'Nueva');
      expect(history.last['_streaming'], 'true');
    });
  });
}
