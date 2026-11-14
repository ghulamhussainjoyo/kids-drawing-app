import 'dart:convert';
import 'dart:ui';

import 'package:kids_drawing_flutter/data/local/artwork/artwork.path.parser.dart';
import 'package:kids_drawing_flutter/types/coloring.artwork.dart';
import 'package:kids_drawing_flutter/types/drawing.region.dart';

/// Builds [ColoringArtwork] from Stage 1 template JSON.
class JsonArtworkLoader {
  final ArtworkPathParser pathParser;

  JsonArtworkLoader({ArtworkPathParser? pathParser})
    : pathParser = pathParser ?? ArtworkPathParser();

  ColoringArtwork load(String templateJson) {
    final map = jsonDecode(templateJson) as Map<String, dynamic>;
    final id = map['id'] as String? ?? 'artwork';
    final viewBox = (map['viewBox'] as String?) ?? '0 0 512 512';
    final size = _sizeFromViewBox(viewBox);
    final outline = map['outline'] as Map<String, dynamic>? ?? const {};
    final outlineWidth = (outline['strokeWidth'] as num?)?.toDouble() ?? 8;

    final rawIds = <String>[];
    final rawPaths = <Path>[];
    final detailLines = <Path>[];
    final regionMaps = map['regions'] as List<dynamic>? ?? const [];
    for (final raw in regionMaps) {
      final region = raw as Map<String, dynamic>;
      final regionId = region['id'] as String? ?? 'region';
      final pathData = region['path'] as String? ?? '';
      final fill = region['fill'] as String? ?? '#FFFFFF';
      final colorable =
          region['colorable'] as bool? ?? fill.toLowerCase() != 'none';
      final path = pathParser.parse(pathData);
      if (!colorable) {
        detailLines.add(path);
        continue;
      }
      rawIds.add(regionId);
      rawPaths.add(path);
    }

    // JSON order is back → front. Each region excludes every region in front.
    final regions = <DrawingRegion>[];
    for (var i = 0; i < rawPaths.length; i++) {
      var path = rawPaths[i];
      for (var j = i + 1; j < rawPaths.length; j++) {
        path = Path.combine(PathOperation.difference, path, rawPaths[j]);
      }
      regions.add(
        DrawingRegion(id: rawIds[i], name: rawIds[i], path: path),
      );
    }

    final lineMaps = map['lines'] as List<dynamic>? ?? const [];
    for (final raw in lineMaps) {
      final line = raw as Map<String, dynamic>;
      final pathData = line['path'] as String? ?? '';
      detailLines.add(pathParser.parse(pathData));
    }

    return ColoringArtwork(
      id: id,
      size: size,
      regions: regions,
      detailLines: detailLines,
      outlineWidth: outlineWidth,
    );
  }

  double _sizeFromViewBox(String viewBox) {
    final parts = viewBox.trim().split(RegExp(r'\s+'));
    if (parts.length < 4) {
      return 512;
    }
    final width = double.tryParse(parts[2]) ?? 512;
    final height = double.tryParse(parts[3]) ?? 512;
    return width > height ? width : height;
  }
}
