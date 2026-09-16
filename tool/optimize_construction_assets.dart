import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as image;

void main() {
  const maxDimension = 768;
  final assetDirectory = Directory('assets/images');
  final constructionAsset = RegExp(
    r'^world[123]_level\d+_(?:stage[0-3]|complete)\.png$',
  );
  var originalBytes = 0;
  var optimizedBytes = 0;
  var count = 0;

  for (final entity in assetDirectory.listSync()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!constructionAsset.hasMatch(name)) continue;

    final sourceBytes = entity.readAsBytesSync();
    final source = image.decodePng(sourceBytes);
    if (source == null) throw StateError('Could not decode ${entity.path}');
    final scale = math.min(
      1.0,
      maxDimension / math.max(source.width, source.height),
    );
    final resized = scale < 1
        ? image.copyResize(
            source,
            width: (source.width * scale).round(),
            height: (source.height * scale).round(),
            interpolation: image.Interpolation.cubic,
          )
        : source;
    final outputBytes = image.encodePng(resized, level: 9);
    entity.writeAsBytesSync(outputBytes, flush: true);
    originalBytes += sourceBytes.length;
    optimizedBytes += outputBytes.length;
    count++;
  }

  final savedPercent = originalBytes == 0
      ? 0
      : ((originalBytes - optimizedBytes) * 100 / originalBytes).round();
  stdout.writeln(
    'Optimized $count assets: $originalBytes -> $optimizedBytes bytes '
    '($savedPercent% smaller).',
  );
}
