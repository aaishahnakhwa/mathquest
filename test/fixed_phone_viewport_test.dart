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

  for (final device in <({Size size, EdgeInsets padding, EdgeInsets gestures})>[
    (
      size: const Size(390, 844),
      padding: const EdgeInsets.only(top: 47, bottom: 34),
      gestures: const EdgeInsets.only(bottom: 34),
    ),
    (
      size: const Size(844, 390),
      padding: const EdgeInsets.only(left: 47, right: 47, bottom: 21),
      gestures: const EdgeInsets.only(left: 47, right: 47, bottom: 21),
    ),
    (
      size: const Size(360, 780),
      padding: const EdgeInsets.only(top: 24),
      gestures: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
    ),
  ]) {
    testWidgets('Safe insets constrain content on ${device.size}', (
      tester,
    ) async {
      tester.view.physicalSize = device.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const safeCanvasKey = ValueKey('safe-canvas');
      late MediaQueryData safeMedia;

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: device.size,
            padding: device.padding,
            viewPadding: device.padding,
            systemGestureInsets: device.gestures,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FixedPhoneViewport(
              child: Builder(
                builder: (context) {
                  safeMedia = MediaQuery.of(context);
                  return const ColoredBox(
                    key: safeCanvasKey,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
        ),
      );

      final viewportWidth = device.size.width < FixedPhoneViewport.maxWidth
          ? device.size.width
          : FixedPhoneViewport.maxWidth;
      final left = device.padding.left > device.gestures.left
          ? device.padding.left
          : device.gestures.left;
      final right = device.padding.right > device.gestures.right
          ? device.padding.right
          : device.gestures.right;
      final bottom = device.padding.bottom > device.gestures.bottom
          ? device.padding.bottom
          : device.gestures.bottom;
      final expectedSize = Size(
        viewportWidth - left - right,
        device.size.height - device.padding.top - bottom,
      );
      expect(safeMedia.size, expectedSize);
      expect(safeMedia.padding, EdgeInsets.zero);
      expect(safeMedia.systemGestureInsets, EdgeInsets.zero);
      expect(tester.getSize(find.byKey(safeCanvasKey)), expectedSize);

      final safeBox = tester.renderObject<RenderBox>(find.byKey(safeCanvasKey));
      final topLeft = safeBox.localToGlobal(Offset.zero);
      expect(
        topLeft.dx,
        closeTo((device.size.width - viewportWidth) / 2 + left, 0.001),
      );
      expect(topLeft.dy, closeTo(device.padding.top, 0.001));
      expect(tester.takeException(), isNull);
    });
  }
}
