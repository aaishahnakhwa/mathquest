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
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: viewportSize.width,
              height: viewportSize.height,
              child: ClipRect(
                child: MediaQuery(
                  data: device.copyWith(
                    size: viewportSize,
                    textScaler: TextScaler.noScaling,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
