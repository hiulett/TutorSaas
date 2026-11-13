import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/economy/presentation/screens/sanctuary_screen.dart';

void main() {
  group('gardenStage (#380)', () {
    test('sin racha o con menos de 3 días es semilla', () {
      expect(gardenStage(0), 'seed');
      expect(gardenStage(2), 'seed');
    });

    test('3 a 6 días es brote', () {
      expect(gardenStage(3), 'sprout');
      expect(gardenStage(6), 'sprout');
    });

    test('7 a 29 días es planta', () {
      expect(gardenStage(7), 'plant');
      expect(gardenStage(29), 'plant');
    });

    test('30 días o más es árbol', () {
      expect(gardenStage(30), 'tree');
      expect(gardenStage(365), 'tree');
    });
  });
}
