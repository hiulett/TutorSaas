import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/presentation/screens/review_session_screen.dart';

void main() {
  group('ReviewPergaminoResult.parse (#375)', () {
    test('parsea un repaso con dos correcciones', () {
      final result = ReviewPergaminoResult.parse({
        'success': true,
        'remaining': 4,
        'items': [
          {
            'original': 'He go to school',
            'corrected': 'He goes to school',
            'explanation': 'Tercera persona',
            'error_type': 'grammar',
          },
          {
            'original': 'I am agree',
            'corrected': 'I agree',
            'explanation': '',
            'error_type': 'vocabulary',
          },
        ],
      });

      expect(result, isNotNull);
      expect(result!.success, isTrue);
      expect(result.remaining, 4);
      expect(result.items, hasLength(2));
      expect(result.items.first.corrected, 'He goes to school');
      expect(result.items.last.errorType, 'vocabulary');
    });

    test('sin correcciones: success false y razón no_corrections', () {
      final result = ReviewPergaminoResult.parse({
        'success': false,
        'reason': 'no_corrections',
        'remaining': 5,
        'items': <Object>[],
      });

      expect(result, isNotNull);
      expect(result!.success, isFalse);
      expect(result.reason, 'no_corrections');
      expect(result.items, isEmpty);
    });

    test('sin pergaminos: razón no_pergaminos', () {
      final result = ReviewPergaminoResult.parse({
        'success': false,
        'reason': 'no_pergaminos',
        'remaining': 0,
        'items': <Object>[],
      });

      expect(result!.reason, 'no_pergaminos');
      expect(result.remaining, 0);
    });

    test('respuesta inválida devuelve null', () {
      expect(ReviewPergaminoResult.parse(null), isNull);
      expect(ReviewPergaminoResult.parse('boom'), isNull);
    });

    test('descarta items sin corrección', () {
      final result = ReviewPergaminoResult.parse({
        'success': true,
        'remaining': 3,
        'items': [
          {'original': 'Hola', 'corrected': ''},
          {'original': '', 'corrected': 'Hi'},
          {'original': 'She don\'t know', 'corrected': "She doesn't know"},
        ],
      });

      expect(result!.items, hasLength(1));
      expect(result.items.single.corrected, "She doesn't know");
    });
  });
}
