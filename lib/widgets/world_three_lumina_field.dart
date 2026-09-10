import 'dart:math' as math;

import 'package:flutter/material.dart';

@immutable
class LuminaFlightSpec {
  const LuminaFlightSpec({
    required this.phaseOffset,
    required this.centerX,
    required this.centerY,
    required this.travelX,
    required this.travelY,
    required this.sizeFactor,
    required this.flightPhase,
    required this.glowPhase,
    required this.animationPhase,
  });

  final double phaseOffset;
  final double centerX;
  final double centerY;
  final double travelX;
  final double travelY;
  final double sizeFactor;
  final double flightPhase;
  final double glowPhase;
  final double animationPhase;
}

/// A World 3-only layer for sparse golden lumina-moths.
class WorldThreeLuminaField extends StatefulWidget {
  const WorldThreeLuminaField({
    required this.animation,
    required this.mapWidth,
    required this.mapHeight,
    super.key,
  });

  static const framesPerSecond = 10;
  static const cycleSeconds = 20.0;
  static const glowPeriodSeconds = 4.8;

  static const frameAssets = <String>[
    'assets/images/lumina_moth_0.png',
    'assets/images/lumina_moth_1.png',
    'assets/images/lumina_moth_2.png',
    'assets/images/lumina_moth_3.png',
    'assets/images/lumina_moth_4.png',
    'assets/images/lumina_moth_5.png',
    'assets/images/lumina_moth_6.png',
    'assets/images/lumina_moth_7.png',
    'assets/images/lumina_moth_8.png',
  ];

  static const _flapSequence = <int>[
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    7,
    6,
    5,
    4,
    3,
    2,
    1,
  ];

  static const flightSpecs = <LuminaFlightSpec>[
    LuminaFlightSpec(
      phaseOffset: 0.03,
      centerX: 0.155,
      centerY: 0.475,
      travelX: 0.040,
      travelY: 0.024,
      sizeFactor: 0.062,
      flightPhase: 0.4,
      glowPhase: 0.2,
      animationPhase: 0.0,
    ),
    LuminaFlightSpec(
      phaseOffset: 0.50,
      centerX: 0.900,
      centerY: 0.245,
      travelX: 0.032,
      travelY: 0.020,
      sizeFactor: 0.053,
      flightPhase: 1.7,
      glowPhase: 2.4,
      animationPhase: 0.43,
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
  static double lifecycleOpacity(double progress) {
    if (progress < 0 || progress >= 0.78) return 0;
    final fadeIn = (progress / 0.08).clamp(0.0, 1.0);
    final fadeOut = ((0.78 - progress) / 0.08).clamp(0.0, 1.0);
    return math.min(fadeIn, fadeOut);
  }

  @visibleForTesting
  static int frameIndexAt(Duration elapsed, double animationPhase) {
    final elapsedSeconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final tick =
        (elapsedSeconds * framesPerSecond +
                (animationPhase * _flapSequence.length))
            .floor();
    return _flapSequence[tick % _flapSequence.length];
  }

  @visibleForTesting
  static double glowOpacityAt(Duration elapsed, double phase) {
    final elapsedSeconds =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final wave =
        (math.sin(
              ((elapsedSeconds / glowPeriodSeconds) * math.pi * 2) + phase,
            ) +
            1) /
        2;
    return 0.84 + (wave * 0.10);
  }

  @visibleForTesting
  static Offset positionForProgress(
    LuminaFlightSpec spec,
    double progress,
    double mapWidth,
    double mapHeight,
    int cycle,
  ) {
    final eased = Curves.easeInOutSine.transform(progress.clamp(0.0, 1.0));
    final variant = cycle % 3;
    final variantScale = switch (variant) {
      1 => 0.86,
      2 => 1.10,
      _ => 1.0,
    };
    final direction = variant == 1 ? -1.0 : 1.0;
    final x =
        spec.centerX +
        (((eased * 2) - 1) * spec.travelX * direction) +
        (math.sin((progress * math.pi * 2) + spec.flightPhase) *
            spec.travelX *
            0.42 *
            variantScale) +
        (math.sin((progress * math.pi * 5) + spec.flightPhase) *
            spec.travelX *
            0.12);
    final y =
        spec.centerY +
        (math.sin((progress * math.pi * 2) + spec.flightPhase) *
            spec.travelY *
            variantScale) +
        (math.sin((progress * math.pi * 4) + spec.flightPhase) *
            spec.travelY *
            0.35);
    return Offset(mapWidth * x, mapHeight * y);
  }

  @override
  State<WorldThreeLuminaField> createState() => _WorldThreeLuminaFieldState();
}

class _WorldThreeLuminaFieldState extends State<WorldThreeLuminaField> {
  var _framesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_framesPrecached) return;
    _framesPrecached = true;
    for (final asset in WorldThreeLuminaField.frameAssets) {
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
            children: List.generate(WorldThreeLuminaField.flightSpecs.length, (
              index,
            ) {
              final spec = WorldThreeLuminaField.flightSpecs[index];
              final lifecycle = WorldThreeLuminaField.lifecycleAt(
                elapsed,
                spec.phaseOffset,
              );
              final position = WorldThreeLuminaField.positionForProgress(
                spec,
                lifecycle.progress,
                widget.mapWidth,
                widget.mapHeight,
                lifecycle.cycle,
              );
              final glowOpacity = WorldThreeLuminaField.glowOpacityAt(
                elapsed,
                spec.glowPhase,
              );
              final pulseScale = 0.985 + ((glowOpacity - 0.84) * 0.30);
              final size = widget.mapWidth * spec.sizeFactor;
              final tilt =
                  math.sin(
                    (lifecycle.progress * math.pi * 2) + spec.flightPhase,
                  ) *
                  0.07;

              return Positioned(
                key: ValueKey('world-three-lumina-$index'),
                left: position.dx - (size / 2),
                top: position.dy - (size / 2),
                width: size,
                height: size,
                child: Opacity(
                  opacity:
                      WorldThreeLuminaField.lifecycleOpacity(
                        lifecycle.progress,
                      ) *
                      glowOpacity,
                  child: Transform.rotate(
                    angle: tilt,
                    child: Transform.scale(
                      scale: pulseScale,
                      child: Image.asset(
                        WorldThreeLuminaField
                            .frameAssets[WorldThreeLuminaField.frameIndexAt(
                          elapsed,
                          spec.animationPhase,
                        )],
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.high,
                      ),
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
