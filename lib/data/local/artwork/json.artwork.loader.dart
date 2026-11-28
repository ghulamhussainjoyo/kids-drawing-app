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
    final vb = _parseViewBox(viewBox);
    final size = vb.width > vb.height ? vb.width : vb.height;
    final offset = Offset(-vb.left, -vb.top);
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
      var path = pathParser.parse(pathData);
      if (offset != Offset.zero) {
        path = _offsetPath(path, offset);
      }
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
      var path = pathParser.parse(pathData);
      if (offset != Offset.zero) {
        path = _offsetPath(path, offset);
      }
      detailLines.add(path);
    }

    final lineworkPaths = <Path>[];
    final linework = map['linework'];
    if (linework is Map<String, dynamic>) {
      final pathData = linework['path'] as String? ?? '';
      if (pathData.isNotEmpty) {
        var path = pathParser.parse(pathData);
        if (offset != Offset.zero) {
          path = _offsetPath(path, offset);
        }
        final fillRule = linework['fillRule'] as String?;
        if (fillRule == 'evenodd') {
          path.fillType = PathFillType.evenOdd;
        }
        lineworkPaths.add(path);
      }
    }

    return ColoringArtwork(
      id: id,
      size: size,
      regions: regions,
      detailLines: detailLines,
      lineworkPaths: lineworkPaths,
      outlineWidth: outlineWidth,
    );
  }

  Rect _parseViewBox(String viewBox) {
    final parts = viewBox.trim().split(RegExp(r'\s+'));
    if (parts.length < 4) {
      return const Rect.fromLTWH(0, 0, 512, 512);
    }
    final x = double.tryParse(parts[0]) ?? 0;
    final y = double.tryParse(parts[1]) ?? 0;
    final w = double.tryParse(parts[2]) ?? 512;
    final h = double.tryParse(parts[3]) ?? 512;
    return Rect.fromLTWH(x, y, w, h);
  }

  static Path _offsetPath(Path source, Offset offset) {
    final shifted = Path();
    shifted.addPath(source, offset);
    return shifted;
  }
}
