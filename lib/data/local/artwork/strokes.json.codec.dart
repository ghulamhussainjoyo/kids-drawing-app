import 'dart:convert';
import 'dart:ui';

import 'package:kids_drawing_flutter/types/brush.config.dart';
import 'package:kids_drawing_flutter/types/brush.type.dart';
import 'package:kids_drawing_flutter/types/drawing.stroke.dart';
import 'package:kids_drawing_flutter/types/paint.color.dart';

class StrokesJsonCodec {
  String emptyDocument(double artworkSize) {
    return jsonEncode({
      'schemaVersion': 1,
      'artworkSize': artworkSize,
      'strokes': <Map<String, dynamic>>[],
    });
  }

  String encode({
    required double artworkSize,
    required List<DrawingStroke> strokes,
  }) {
    final payload = <Map<String, dynamic>>[];
    for (final stroke in strokes) {
      final points = <List<double>>[];
      for (final point in stroke.points) {
        points.add([point.dx, point.dy]);
      }
      payload.add({
        'id': stroke.id,
        'toolId': stroke.brush.type.name,
        'regionId': stroke.regionId,
        'seed': stroke.seed,
        'brush': {
          'size': stroke.brush.size,
          'type': stroke.brush.type.name,
          'color': stroke.brush.paintColor.color.toARGB32(),
          'colorId': stroke.brush.paintColor.id,
        },
        'params': <String, dynamic>{},
        'points': points,
      });
    }
    return jsonEncode({
      'schemaVersion': 1,
      'artworkSize': artworkSize,
      'strokes': payload,
    });
  }

  List<DrawingStroke> decode(String json) {
    if (json.trim().isEmpty) {
      return [];
    }
    final map = jsonDecode(json) as Map<String, dynamic>;
    final rawStrokes = map['strokes'] as List<dynamic>? ?? const [];
    final strokes = <DrawingStroke>[];
    for (final raw in rawStrokes) {
      final stroke = raw as Map<String, dynamic>;
      final brushMap = stroke['brush'] as Map<String, dynamic>? ?? const {};
      final typeName = brushMap['type'] as String? ?? 'pencil';
      final colorValue = brushMap['color'] as int? ?? 0xFFF44336;
      final colorId = brushMap['colorId'] as String? ?? 'color';
      final pointsRaw = stroke['points'] as List<dynamic>? ?? const [];
      final points = <Offset>[];
      for (final pointRaw in pointsRaw) {
        final pair = pointRaw as List<dynamic>;
        points.add(
          Offset((pair[0] as num).toDouble(), (pair[1] as num).toDouble()),
        );
      }
      strokes.add(
        DrawingStroke(
          id: stroke['id'] as int? ?? strokes.length + 1,
          regionId: stroke['regionId'] as String? ?? '',
          seed: stroke['seed'] as int? ?? 0,
          brush: BrushConfig(
            size: (brushMap['size'] as num?)?.toDouble() ?? 32,
            type: _brushType(typeName),
            paintColor: PaintColor(
              id: colorId,
              color: Color(colorValue),
            ),
          ),
          points: points,
        ),
      );
    }
    return strokes;
  }

  BrushType _brushType(String name) {
    for (final type in BrushType.values) {
      if (type.name == name) {
        return type;
      }
    }
    return BrushType.pencil;
  }
}
