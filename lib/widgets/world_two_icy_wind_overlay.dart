import 'dart:math' as math;

import 'package:flutter/material.dart';

@immutable
class IcySnowParticle {
  const IcySnowParticle({
    required this.x,
    required this.phase,
    required this.periodSeconds,
    required this.sway,
    required this.radius,
  });

  final double x;
  final double phase;
  final double periodSeconds;
  final double sway;
  final double radius;
}

/// A restrained World 2 wind pass that always stays behind the level controls.
class WorldTwoIcyWindOverlay extends StatelessWidget {
  const WorldTwoIcyWindOverlay({
    required this.animation,
    required this.mapWidth,
    required this.mapHeight,
    super.key,
  });

  static const assetPath = 'assets/images/world_2_icy_wind.png';
  static const sourceSize = Size(1774, 887);
  static const cycleSeconds = 22.0;

  static const particles = <IcySnowParticle>[
    IcySnowParticle(
      x: 0.09,
      phase: 0.04,
      periodSeconds: 12.0,
      sway: 0.025,
      radius: 0.0030,
    ),
    IcySnowParticle(
      x: 0.18,
      phase: 0.55,
      periodSeconds: 15.0,
      sway: 0.018,
      radius: 0.0022,
    ),
    IcySnowParticle(
      x: 0.29,
      phase: 0.30,
      periodSeconds: 13.5,
      sway: 0.022,
      radius: 0.0027,
    ),
    IcySnowParticle(
      x: 0.39,
      phase: 0.78,
      periodSeconds: 17.0,
      sway: 0.015,
      radius: 0.0020,
    ),
    IcySnowParticle(
      x: 0.50,
      phase: 0.16,
      periodSeconds: 14.0,
      sway: 0.028,
      radius: 0.0025,
    ),
    IcySnowParticle(
      x: 0.61,
      phase: 0.67,
      periodSeconds: 16.0,
      sway: 0.020,
      radius: 0.0030,
    ),
    IcySnowParticle(
      x: 0.72,
      phase: 0.39,
      periodSeconds: 12.5,
      sway: 0.024,
      radius: 0.0021,
    ),
    IcySnowParticle(
      x: 0.83,
      phase: 0.88,
      periodSeconds: 18.0,
      sway: 0.017,
      radius: 0.0026,
    ),
    IcySnowParticle(
      x: 0.92,
      phase: 0.47,
      periodSeconds: 14.5,
      sway: 0.021,
      radius: 0.0022,
    ),
  ];

  final AnimationController animation;
  final double mapWidth;
  final double mapHeight;

  @visibleForTesting
  static double loopProgress(Duration elapsed, double periodSeconds) {
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final progress = seconds / periodSeconds;
    return progress - progress.floor();
  }

  @visibleForTesting
  static double windOpacity(double progress) {
    final edgeFade = math.sin(progress.clamp(0.0, 1.0) * math.pi);
    final variation =
        0.12 + (((math.sin((progress * math.pi * 4) + 0.7) + 1) / 2) * 0.05);
    return edgeFade * variation;
  }

  @visibleForTesting
  static Offset windPosition(
    double progress,
    double mapWidth,
    double mapHeight,
    double windWidth,
  ) {
    final eased = Curves.easeInOutSine.transform(progress.clamp(0.0, 1.0));
    return Offset(
      -windWidth + (eased * (mapWidth + windWidth)),
      mapHeight * (0.455 + (math.sin(progress * math.pi * 2) * 0.009)),
    );
  }

  @visibleForTesting
  static double particleOpacity(double progress) =>
      math.sin(progress.clamp(0.0, 1.0) * math.pi) * 0.24;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.expand();
    }

    return IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final elapsed = animation.lastElapsedDuration ?? Duration.zero;
              final progress = loopProgress(elapsed, cycleSeconds);
              final windWidth = mapWidth * 0.68;
              final windHeight =
                  windWidth * sourceSize.height / sourceSize.width;
              final position = windPosition(
                progress,
                mapWidth,
                mapHeight,
                windWidth,
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _IcySnowPainter(elapsed: elapsed)),
                  Positioned(
                    key: const ValueKey('world-two-icy-wind'),
                    left: position.dx,
                    top: position.dy,
                    width: windWidth,
                    height: windHeight,
                    child: Opacity(
                      opacity: windOpacity(progress),
                      child: child,
                    ),
                  ),
                ],
              );
            },
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _IcySnowPainter extends CustomPainter {
  const _IcySnowPainter({required this.elapsed});

  final Duration elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    for (
      var index = 0;
      index < WorldTwoIcyWindOverlay.particles.length;
      index++
    ) {
      final particle = WorldTwoIcyWindOverlay.particles[index];
      final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
      final rawProgress = (seconds / particle.periodSeconds) + particle.phase;
      final progress = rawProgress - rawProgress.floor();
      final sway =
          math.sin((progress * math.pi * 2) + (index * 0.83)) * particle.sway;
      final center = Offset(
        size.width * (particle.x + sway + (progress * 0.035)),
        size.height * (-0.03 + (progress * 1.06)),
      );
      final paint = Paint()
        ..color = const Color(0xFFE7F5FF)
            .withValues(alpha: WorldTwoIcyWindOverlay.particleOpacity(progress))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          size.width * particle.radius * 0.65,
        );
      canvas.drawCircle(center, size.width * particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IcySnowPainter oldDelegate) =>
      oldDelegate.elapsed != elapsed;
}
