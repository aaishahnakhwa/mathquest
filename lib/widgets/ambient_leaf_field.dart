import 'dart:math' as math;

import 'package:flutter/material.dart';

@immutable
class LeafDriftSpec {
  const LeafDriftSpec({
    required this.assets,
    required this.phaseOffset,
    required this.startX,
    required this.endX,
    required this.sway,
    required this.sizeFactor,
    required this.rotationTurns,
    required this.windPhase,
  });

  final List<String> assets;
  final double phaseOffset;
  final double startX;
  final double endX;
  final double sway;
  final double sizeFactor;
  final double rotationTurns;
  final double windPhase;
}

/// Sparse drifting leaves that share the map's existing animation ticker.
class AmbientLeafField extends StatefulWidget {
  const AmbientLeafField({
    required this.animation,
    required this.mapWidth,
    required this.mapHeight,
    super.key,
  });

  static const cycleSeconds = 18.0;
  static const leafSpecs = <LeafDriftSpec>[
    LeafDriftSpec(
      assets: ['assets/images/leaf_green_1.png'],
      phaseOffset: 0.02,
      startX: 0.035,
      endX: 0.085,
      sway: 0.020,
      sizeFactor: 0.034,
      rotationTurns: 0.62,
      windPhase: 0.2,
    ),
    LeafDriftSpec(
      assets: ['assets/images/leaf_green_2.png'],
      phaseOffset: 0.35,
      startX: 0.965,
      endX: 0.915,
      sway: 0.018,
      sizeFactor: 0.029,
      rotationTurns: -0.54,
      windPhase: 1.4,
    ),
    LeafDriftSpec(
      assets: [
        'assets/images/leaf_yellow_1.png',
        'assets/images/leaf_orange_1.png',
      ],
      phaseOffset: 0.68,
      startX: 0.025,
      endX: 0.075,
      sway: 0.016,
      sizeFactor: 0.031,
      rotationTurns: 0.48,
      windPhase: 2.6,
    ),
  ];

  final AnimationController animation;
  final double mapWidth;
  final double mapHeight;

  @visibleForTesting
  static ({double progress, int cycle}) lifecycleAt(
    Duration elapsed,
    double phaseOffset,
  ) {
    final totalProgress =
        (elapsed.inMicroseconds / Duration.microsecondsPerSecond) /
            cycleSeconds +
        phaseOffset;
    final cycle = totalProgress.floor();
    return (progress: totalProgress - cycle, cycle: cycle);
  }

  @visibleForTesting
  static double opacityForProgress(double progress) {
    if (progress < 0 || progress >= 0.88) return 0;
    final fadeIn = (progress / 0.06).clamp(0.0, 1.0);
    final fadeOut = ((0.88 - progress) / 0.06).clamp(0.0, 1.0);
    return math.min(fadeIn, fadeOut);
  }

  @visibleForTesting
  static Offset positionForProgress(
    LeafDriftSpec spec,
    double progress,
    double mapWidth,
    double mapHeight,
    int cycle,
  ) {
    final easedProgress = Curves.easeInOutSine.transform(
      progress.clamp(0.0, 1.0),
    );
    final variant = cycle % 3;
    final variantScale = switch (variant) {
      1 => 0.86,
      2 => 1.12,
      _ => 1.0,
    };
    final direction = variant == 1 ? -1.0 : 1.0;
    final baseX = spec.startX + ((spec.endX - spec.startX) * easedProgress);
    final swayX =
        math.sin((progress * math.pi * 2) + spec.windPhase) *
            spec.sway *
            variantScale +
        math.sin((progress * math.pi * 5) + spec.windPhase) *
            spec.sway *
            0.24 *
            direction;
    final verticalFlutter =
        math.sin((progress * math.pi * 4) + spec.windPhase) * 0.009 +
        math.sin((progress * math.pi * 7) + spec.windPhase) * 0.003;
    final normalizedY = -0.08 + (1.16 * easedProgress) + verticalFlutter;

    return Offset(mapWidth * (baseX + swayX), mapHeight * normalizedY);
  }

  @visibleForTesting
  static String assetForCycle(LeafDriftSpec spec, int cycle) {
    return spec.assets[cycle % spec.assets.length];
  }

  @visibleForTesting
  static double rotationForProgress(LeafDriftSpec spec, double progress) {
    return (progress * math.pi * 2 * spec.rotationTurns) +
        (math.sin(progress * math.pi * 3 + spec.windPhase) * 0.18);
  }

  @override
  State<AmbientLeafField> createState() => _AmbientLeafFieldState();
}

class _AmbientLeafFieldState extends State<AmbientLeafField> {
  var _assetsPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetsPrecached) return;
    _assetsPrecached = true;
    for (final asset in AmbientLeafField.leafSpecs.expand(
      (spec) => spec.assets,
    )) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          final elapsed = widget.animation.lastElapsedDuration ?? Duration.zero;

          return Stack(
            children: List.generate(AmbientLeafField.leafSpecs.length, (index) {
              final spec = AmbientLeafField.leafSpecs[index];
              final lifecycle = AmbientLeafField.lifecycleAt(
                elapsed,
                spec.phaseOffset,
              );
              final progress = lifecycle.progress;
              final position = AmbientLeafField.positionForProgress(
                spec,
                progress,
                widget.mapWidth,
                widget.mapHeight,
                lifecycle.cycle,
              );
              final size = widget.mapWidth * spec.sizeFactor;
              final rotation = AmbientLeafField.rotationForProgress(
                spec,
                progress,
              );

              return Positioned(
                key: ValueKey('ambient-leaf-$index'),
                left: position.dx - (size / 2),
                top: position.dy - (size / 2),
                width: size,
                height: size,
                child: Opacity(
                  opacity: AmbientLeafField.opacityForProgress(progress),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Image.asset(
                      AmbientLeafField.assetForCycle(spec, lifecycle.cycle),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
