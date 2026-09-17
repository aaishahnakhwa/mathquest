import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_quest/widgets/visual_math_helper.dart';

void main() {
  group('VisualMathHelper parsing', () {
    test(
      'parses a complete whole-number operation and calculates its result',
      () {
        final expression = VisualMathHelper.parseExpression(
          questionText: 'What is 24 + 35?',
          topic: 'Addition',
        );

        expect(expression, isNotNull);
        expect(expression!.left, 24);
        expect(expression.right, 35);
        expect(expression.operatorSymbol, '+');
        expect(expression.result, 59);
      },
    );

    test(
      'rejects expressions that the place-value model cannot show exactly',
      () {
        final unsupportedQuestions = <({String text, String topic})>[
          (text: 'What is 48 + 67 + 29?', topic: 'Addition'),
          (text: 'Calculate: 1/2 + 1/4', topic: 'Fractions'),
          (text: 'Solve: x + 7 = 12', topic: 'One-Step Equations'),
          (text: 'Calculate: 6 - 9', topic: 'Integers'),
        ];

        for (final question in unsupportedQuestions) {
          expect(
            VisualMathHelper.parseExpression(
              questionText: question.text,
              topic: question.topic,
            ),
            isNull,
            reason: question.text,
          );
        }
      },
    );
  });

  testWidgets('renders exact hundreds, tens, and ones on a narrow phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: VisualMathHelper(
                questionText: 'What is 143 - 67?',
                topic: 'Subtraction',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('visual-math-helper')), findsOneWidget);
    expect(find.text('143 - 67 = 76'), findsOneWidget);
    expect(find.text('1 100s'), findsOneWidget);
    expect(find.text('4 10s'), findsOneWidget);
    expect(find.text('3 1s'), findsOneWidget);
    expect(find.text('6 10s'), findsOneWidget);
    expect(find.text('7 1s'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not render a misleading fraction visual', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VisualMathHelper(
            questionText: 'Calculate: 1/2 + 1/4',
            topic: 'Fractions',
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('visual-math-helper')), findsNothing);
  });
}
