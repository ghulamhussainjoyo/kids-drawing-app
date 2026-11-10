import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/engine/layer.manager.dart';
import 'package:kids_drawing_flutter/core/engine/region.engine.dart';
import 'package:kids_drawing_flutter/core/engine/stroke.renderer.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.tool.dart';
import 'package:kids_drawing_flutter/data/models/brush.config.dart';
import 'package:kids_drawing_flutter/data/models/brush.type.dart';
import 'package:kids_drawing_flutter/data/models/drawing.stroke.dart';
import 'package:kids_drawing_flutter/data/models/paint.color.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/artwork.repository.impl.dart';

void main() {
  test('paint never leaves the region where the stroke started', () async {
    final regionEngine = RegionEngine(const ArtworkRepositoryImpl().appleAndBooks());
    final layers = LayerManager(
      regionEngine: regionEngine,
      strokeRenderer: StrokeRenderer(),
    );
    final tool = PencilTool();

    const red = PaintColor(id: 'red', color: Color(0xFFFF0000));
    final strokes = [
      for (var pass = 0; pass < 6; pass++)
        DrawingStroke(
          id: pass,
          regionId: 'apple_body',
          brush: const BrushConfig(type: BrushType.pencil, paintColor: red, size: 60),
          seed: pass,
          points: const [
            Offset(500, 320),
            Offset(620, 140),
            Offset(720, 490),
            Offset(900, 900),
          ],
        ),
    ];

    final recorder = ui.PictureRecorder();
    layers.paint(Canvas(recorder), committed: strokes, revision: 1, tool: tool);
    final image = await recorder.endRecording().toImage(1000, 1000);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;

    Color pixel(int x, int y) {
      final i = (y * 1000 + x) * 4;
      return Color.fromARGB(
        bytes.getUint8(i + 3),
        bytes.getUint8(i),
        bytes.getUint8(i + 1),
        bytes.getUint8(i + 2),
      );
    }

    bool isWhite(Color c) => c == const Color(0xFFFFFFFF);

    for (final point in const [Offset(500, 320), Offset(560, 240), Offset(660, 300)]) {
      final color = pixel(point.dx.toInt(), point.dy.toInt());
      expect(color.r, greaterThan(0.9), reason: 'apple body is painted at $point');
      expect(color.g, lessThan(0.3), reason: 'apple body is painted at $point');
    }
    expect(isWhite(pixel(620, 142)), isTrue, reason: 'leaf stays blank');
    expect(isWhite(pixel(720, 490)), isTrue, reason: 'book cover stays blank');
    expect(isWhite(pixel(850, 850)), isTrue, reason: 'paper stays blank');
    expect(pixel(500, 195), const Color(0xFF111111), reason: 'outline on top');
  });
}
