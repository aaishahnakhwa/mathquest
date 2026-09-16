import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class SnowDepthLayer {
  const SnowDepthLayer({
    required this.scale,
    required this.periodSeconds,
    required this.phase,
    required this.opacity,
    required this.windAmplitude,
  });

  final double scale;
  final double periodSeconds;
  final double phase;
  final double opacity;
  final double windAmplitude;
}

/// Two softly tiled snow planes for depth without obscuring World 2 controls.
class WorldTwoSnowOverlay extends StatefulWidget {
  const WorldTwoSnowOverlay({required this.animation, super.key});

  static const assetPath = 'assets/images/world_2_snow_overlay.png';
  static const sourceSize = Size(1024, 1536);

  static const depthLayers = <SnowDepthLayer>[
    SnowDepthLayer(
      scale: 0.72,
      periodSeconds: 32,
      phase: 0.18,
      opacity: 0.065,
      windAmplitude: 0.014,
    ),
    SnowDepthLayer(
      scale: 1.12,
      periodSeconds: 21,
      phase: 0.63,
      opacity: 0.085,
      windAmplitude: 0.022,
    ),
  ];

  final AnimationController animation;

  @visibleForTesting
  static double loopProgress(
    Duration elapsed,
    double periodSeconds, {
    double phase = 0,
  }) {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final progress = (seconds / periodSeconds) + phase;
    return progress - progress.floor();
  }

  @visibleForTesting
  static double verticalOffset(double progress, double tileHeight) =>
      progress.clamp(0.0, 1.0) * tileHeight;

  @visibleForTesting
  static double horizontalDrift(
    double progress,
    double mapWidth,
    double amplitude,
  ) => math.sin(progress.clamp(0.0, 1.0) * math.pi * 2) * mapWidth * amplitude;

  @override
  State<WorldTwoSnowOverlay> createState() => _WorldTwoSnowOverlayState();
}

class _WorldTwoSnowOverlayState extends State<WorldTwoSnowOverlay> {
  ui.Image? _texture;

  @override
  void initState() {
    super.initState();
    _loadTexture();
  }

  Future<void> _loadTexture() async {
    final data = await rootBundle.load(WorldTwoSnowOverlay.assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _texture = frame.image);
  }

  @override
  void dispose() {
    _texture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texture = _texture;
    if (texture == null || MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.expand();
    }

    return IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: RepaintBoundary(
            child: CustomPaint(
              key: const ValueKey('world-two-falling-snow'),
              painter: _WorldTwoSnowPainter(
                texture: texture,
                animation: widget.animation,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldTwoSnowPainter extends CustomPainter {
  _WorldTwoSnowPainter({required this.texture, required this.animation})
    : super(repaint: animation);

  final ui.Image texture;
  final AnimationController animation;

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = animation.lastElapsedDuration ?? Duration.zero;
    for (final layer in WorldTwoSnowOverlay.depthLayers) {
      _paintDepthLayer(canvas, size, elapsed, layer);
    }
  }

  void _paintDepthLayer(
    Canvas canvas,
    Size size,
    Duration elapsed,
    SnowDepthLayer layer,
  ) {
    final progress = WorldTwoSnowOverlay.loopProgress(
      elapsed,
      layer.periodSeconds,
      phase: layer.phase,
    );
    final tileWidth = size.width * layer.scale;
    final tileHeight =
        tileWidth *
        WorldTwoSnowOverlay.sourceSize.height /
        WorldTwoSnowOverlay.sourceSize.width;
    final fall = WorldTwoSnowOverlay.verticalOffset(progress, tileHeight);
    final wind = WorldTwoSnowOverlay.horizontalDrift(
      progress,
      size.width,
      layer.windAmplitude,
    );
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Colors.white.withValues(alpha: layer.opacity);
    final source = Rect.fromLTWH(
      0,
      0,
      WorldTwoSnowOverlay.sourceSize.width,
      WorldTwoSnowOverlay.sourceSize.height,
    );

    for (var y = fall - tileHeight; y < size.height; y += tileHeight) {
      for (var x = wind - tileWidth; x < size.width; x += tileWidth) {
        canvas.drawImageRect(
          texture,
          source,
          Rect.fromLTWH(x, y, tileWidth, tileHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorldTwoSnowPainter oldDelegate) =>
      oldDelegate.texture != texture;
}
