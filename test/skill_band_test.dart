import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/domain/models/skill_band.dart';

/// P-35 (#120): el radar muestra bandas, no porcentajes con precisión falsa.
void main() {
  test('sin datos no inventa un nivel', () {
    expect(SkillBand.fromScore(null), SkillBand.unknown);
    expect(SkillBand.fromScore(0), SkillBand.unknown);
    expect(SkillBand.fromScore(-5), SkillBand.unknown);
    expect(SkillBand.fromScore(double.nan), SkillBand.unknown);
  });

  test('umbrales bajo / medio / alto', () {
    expect(SkillBand.fromScore(1), SkillBand.low);
    expect(SkillBand.fromScore(39.9), SkillBand.low);
    expect(SkillBand.fromScore(40), SkillBand.medium);
    expect(SkillBand.fromScore(69.9), SkillBand.medium);
    expect(SkillBand.fromScore(70), SkillBand.high);
    expect(SkillBand.fromScore(100), SkillBand.high);
  });

  test('acepta int y num del json', () {
    expect(SkillBand.fromScore(72), SkillBand.high);
    expect(SkillBand.fromScore(55.5), SkillBand.medium);
  });
}
