import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:tutorsaas/features/dashboard/presentation/widgets/charts/skills_radar_chart.dart';

void main() {
  testWidgets('la leyenda lista los cinco ejes y no desborda a 312 dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(312 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          skillsRadarProvider.overrideWith(
            (ref) async => <String, double>{
              'fluency': 70,
              'vocab': 85,
              'grammar': 55,
              'comprehension': 80,
              'naturalness': 40,
            },
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SkillsRadarChart(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // #309: las etiquetas ya no las dibuja el gráfico; viven en la leyenda.
    for (final label in [
      'Fluidez',
      'Vocabulario',
      'Gramática',
      'Comprensión',
      'Naturalidad',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'falta $label');
    }

    // Y la banda de cada eje se muestra junto al nombre.
    expect(find.text('Alto'), findsWidgets);
    expect(find.text('Medio'), findsWidgets);

    expect(tester.takeException(), isNull);
  });
}
