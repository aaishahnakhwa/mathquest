import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ButterflyFlightArea {
  lowerRightMeadow,
  upperLeftWaterside,
  lowerLeftGrove,
}

/// A small, non-interactive wildlife layer for the illustrated world map.
class AmbientButterfly extends StatefulWidget {
  const AmbientButterfly({
    required this.id,
    required this.animation,
    required this.mapWidth,
    required this.mapHeight,
    this.frames = orangeFrameAssets,
    this.flightArea = ButterflyFlightArea.lowerRightMeadow,
    this.wingPhaseOffset = 0,
    this.sizeFactor = 0.07,
    this.initialRouteVariant = 0,
    super.key,
  });

  static const framesPerSecond = 10;

  static const orangeFrameAssets = <String>[
    'assets/images/butterfly_orange_0.png',
    'assets/images/butterfly_orange_1.png',
    'assets/images/butterfly_orange_2.png',
    'assets/images/butterfly_orange_3.png',
    'assets/images/butterfly_orange_4.png',
    'assets/images/butterfly_orange_5.png',
    'assets/images/butterfly_orange_6.png',
    'assets/images/butterfly_orange_7.png',
  ];

  static const yellowFrameAssets = <String>[
    'assets/images/butterfly_yellow_0.png',
    'assets/images/butterfly_yellow_1.png',
    'assets/images/butterfly_yellow_2.png',
    'assets/images/butterfly_yellow_3.png',
    'assets/images/butterfly_yellow_4.png',
    'assets/images/butterfly_yellow_5.png',
    'assets/images/butterfly_yellow_6.png',
    'assets/images/butterfly_yellow_7.png',
  ];

  static const blueFrameAssets = <String>[
    'assets/images/butterfly_blue_0.png',
    'assets/images/butterfly_blue_1.png',
    'assets/images/butterfly_blue_2.png',
    'assets/images/butterfly_blue_3.png',
    'assets/images/butterfly_blue_4.png',
    'assets/images/butterfly_blue_5.png',
    'assets/images/butterfly_blue_6.png',
    'assets/images/butterfly_blue_7.png',
  ];

  static const _flapSequence = <int>[0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1];

  final String id;
  final Animation<double> animation;
  final double mapWidth;
  final double mapHeight;
  final List<String> frames;
  final ButterflyFlightArea flightArea;
  final double wingPhaseOffset;
  final double sizeFactor;
  final int initialRouteVariant;

  @visibleForTesting
  static int frameIndexForProgress(double progress) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    const animationSeconds = 6;
    final frameTick =
        (normalizedProgress * animationSeconds * framesPerSecond + 1e-9)
            .floor();
    return _flapSequence[frameTick % _flapSequence.length];
  }

  @visibleForTesting
  static Offset positionForProgress(
    double progress,
    double mapWidth,
    double mapHeight, {
    ButterflyFlightArea area = ButterflyFlightArea.lowerRightMeadow,
    int routeVariant = 0,
  }) {
    final angle = progress.clamp(0.0, 1.0) * math.pi * 2;
    final variant = routeVariant % 3;
    final routeScale = switch (variant) {
      1 => 0.82,
      2 => 1.12,
      _ => 1.0,
    };
    final secondaryDirection = variant == 1 ? -1.0 : 1.0;
    final (centerX, centerY, xDrift, yDrift) = switch (area) {
      ButterflyFlightArea.lowerRightMeadow => (0.765, 0.855, 0.030, 0.010),
      ButterflyFlightArea.upperLeftWaterside => (0.130, 0.355, 0.028, 0.010),
      ButterflyFlightArea.lowerLeftGrove => (0.115, 0.620, 0.026, 0.009),
    };
    final normalizedX =
        centerX +
        (math.sin(angle) * xDrift * routeScale) +
        (math.sin(angle * 2) * xDrift * 0.28 * secondaryDirection);
    final normalizedY =
        centerY +
        ((1 - math.cos(angle)) * yDrift * routeScale) +
        (math.sin(angle * 2) * yDrift * 0.35 * secondaryDirection);
    return Offset(mapWidth * normalizedX, mapHeight * normalizedY);
  }

  @override
  State<AmbientButterfly> createState() => _AmbientButterflyState();
}

class _AmbientButterflyState extends State<AmbientButterfly> {
  var _framesPrecached = false;
  late int _routeVariant;

  @override
  void initState() {
    super.initState();
    _routeVariant = widget.initialRouteVariant % 3;
    widget.animation.addStatusListener(_handleStatus);
  }

  @override
  void didUpdateWidget(covariant AmbientButterfly oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_handleStatus);
      widget.animation.addStatusListener(_handleStatus);
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {
        _routeVariant = (_routeVariant + 1) % 3;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_framesPrecached) return;
    _framesPrecached = true;
    for (final asset in widget.frames) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: widget.animation,
        builder: (context, child) {
          final progress = widget.animation.value;
          final wingProgress = (progress + widget.wingPhaseOffset) % 1.0;
          final position = AmbientButterfly.positionForProgress(
            progress,
            widget.mapWidth,
            widget.mapHeight,
            area: widget.flightArea,
            routeVariant: _routeVariant,
          );
          final frameIndex = AmbientButterfly.frameIndexForProgress(
            wingProgress,
          );
          final size = widget.mapWidth * widget.sizeFactor;
          final angle = math.sin(progress * math.pi * 2) * 0.055;

          return Stack(
            children: [
              Positioned(
                key: ValueKey('ambient-butterfly-${widget.id}'),
                left: position.dx - (size / 2),
                top: position.dy - (size / 2),
                width: size,
                height: size,
                child: Transform.rotate(
                  angle: angle,
                  child: Image.asset(
                    widget.frames[frameIndex],
                    key: ValueKey('${widget.id}-$frameIndex'),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
