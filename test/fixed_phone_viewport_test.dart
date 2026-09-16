import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_quest/widgets/fixed_phone_viewport.dart';

void main() {
  for (final window in [
    const Size(1440, 900),
    const Size(768, 1024),
    const Size(360, 780),
    const Size(435.2, 729.59),
    const Size(844, 390),
  ]) {
    testWidgets('Mobile width stays bounded in a $window window', (
      tester,
    ) async {
      tester.view.physicalSize = window;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const canvasKey = ValueKey('canvas');
      late MediaQueryData phone;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => FixedPhoneViewport(child: child!),
          home: Builder(
            builder: (context) {
              phone = MediaQuery.of(context);
              return const Scaffold(key: canvasKey, body: Text('Phone'));
            },
          ),
        ),
      );
      final expectedSize = Size(
        window.width < 480 ? window.width : 480,
        window.height,
      );
      expect(phone.size, expectedSize);
      expect(phone.textScaler.scale(16), 16);
      expect(tester.getSize(find.byKey(canvasKey)), expectedSize);
      final box = tester.renderObject<RenderBox>(find.byKey(canvasKey));
      final topLeft = box.localToGlobal(Offset.zero);
      final bottomRight = box.localToGlobal(
        Offset(expectedSize.width, expectedSize.height),
      );
      final displayed = bottomRight - topLeft;
      expect(displayed.dx, closeTo(expectedSize.width, 0.001));
      expect(displayed.dy, closeTo(window.height, 0.001));
      expect(topLeft.dx, closeTo((window.width - displayed.dx) / 2, 0.001));
      expect(topLeft.dy, closeTo((window.height - displayed.dy) / 2, 0.001));
      expect(displayed.dx, lessThanOrEqualTo(480.001));
      expect(bottomRight.dx, lessThanOrEqualTo(window.width + 0.001));
      expect(bottomRight.dy, lessThanOrEqualTo(window.height + 0.001));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Navigation and dialogs share mobile width and taps work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Size? routeSize;
    Size? dialogSize;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => FixedPhoneViewport(child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      routeSize = MediaQuery.sizeOf(context);
                      return Scaffold(
                        body: Center(
                          child: TextButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (context) {
                                dialogSize = MediaQuery.sizeOf(context);
                                return const AlertDialog(
                                  content: Text('Dialog'),
                                );
                              },
                            ),
                            child: const Text('Open dialog'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(routeSize, const Size(480, 390));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(dialogSize, const Size(480, 390));
    expect(find.text('Dialog'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
