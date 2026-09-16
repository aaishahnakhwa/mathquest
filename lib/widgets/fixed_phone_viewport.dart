import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Phones fill the window; larger devices keep every route at mobile width.
class FixedPhoneViewport extends StatelessWidget {
  static const double maxWidth = 480;

  final Widget child;

  const FixedPhoneViewport({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context);
    return ColoredBox(
      color: const Color(0xFF101820),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = Size(
            math.min(constraints.maxWidth, maxWidth),
            constraints.maxHeight,
          );
          final leftInset = math.min(
            math.max(device.padding.left, device.systemGestureInsets.left),
            viewportSize.width,
          );
          final rightInset = math.min(
            math.max(device.padding.right, device.systemGestureInsets.right),
            math.max(0.0, viewportSize.width - leftInset),
          );
          final topInset = math.min(device.padding.top, viewportSize.height);
          final bottomInset = math.min(
            math.max(device.padding.bottom, device.systemGestureInsets.bottom),
            math.max(0.0, viewportSize.height - topInset),
          );
          final safeInsets = EdgeInsets.fromLTRB(
            leftInset,
            topInset,
            rightInset,
            bottomInset,
          );
          final safeSize = Size(
            viewportSize.width - safeInsets.horizontal,
            viewportSize.height - safeInsets.vertical,
          );
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: viewportSize.width,
              height: viewportSize.height,
              child: ClipRect(
                child: Padding(
                  padding: safeInsets,
                  child: MediaQuery(
                    data: device.copyWith(
                      size: safeSize,
                      padding: EdgeInsets.zero,
                      viewPadding: EdgeInsets.zero,
                      systemGestureInsets: EdgeInsets.zero,
                      textScaler: TextScaler.noScaling,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
