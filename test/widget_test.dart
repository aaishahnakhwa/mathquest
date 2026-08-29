import 'package:flutter_test/flutter_test.dart';
import 'package:math_quest/main.dart';

void main() {
  testWidgets('Math Quest app initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MathQuestApp());
    expect(find.byType(MathQuestApp), findsOneWidget);
  });
}
