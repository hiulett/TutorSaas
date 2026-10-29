import 'package:flutter_test/flutter_test.dart';
import 'package:tutorsaas/features/conversation/domain/models/goal_evaluation_gate.dart';

/// P-41 (#126): no gastar una llamada de IA con respuestas sin señal.
void main() {
  const goals = ['Order a coffee politely', 'Ask about the price'];

  test('una respuesta corta sin palabras de la meta no evalua', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'ok',
        goalTexts: goals,
      ),
      isFalse,
    );
    expect(
      GoalEvaluationGate.shouldEvaluate(lastUserMessage: '', goalTexts: goals),
      isFalse,
    );
  });

  test('cinco palabras ya son señal', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'I would like one coffee please',
        goalTexts: goals,
      ),
      isTrue,
    );
  });

  test('una palabra clave de la meta basta', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'coffee',
        goalTexts: goals,
      ),
      isTrue,
    );
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'price?',
        goalTexts: goals,
      ),
      isTrue,
    );
  });

  test('las keywords cortas del catálogo también activan (P-39)', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'milk',
        goalTexts: const ['Specify preferences'],
        goalKeywords: const ['milk', 'sugar'],
      ),
      isTrue,
    );
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'tea',
        goalTexts: const ['Order a drink'],
        goalKeywords: const ['tea'],
      ),
      isTrue,
    );
  });

  test('una keyword corta no activa por estar dentro de otra palabra', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'this is fine',
        goalTexts: const [],
        goalKeywords: const ['hi'],
      ),
      isFalse,
    );
  });

  test('el plural de una keyword del catálogo activa', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'coffees',
        goalTexts: const [],
        goalKeywords: const ['coffee'],
      ),
      isTrue,
    );
  });

  test('palabras cortas no cuentan como clave', () {
    expect(
      GoalEvaluationGate.keywordsOf('the price of a tea'),
      isNot(contains('the')),
    );
    expect(
      GoalEvaluationGate.keywordsOf('the price of a tea'),
      contains('price'),
    );
  });

  test('acentos y puntuacion no rompen el conteo', () {
    expect(
      GoalEvaluationGate.shouldEvaluate(
        lastUserMessage: 'Quisiera un café con leche, por favor',
        goalTexts: const [],
      ),
      isTrue,
    );
  });
}
