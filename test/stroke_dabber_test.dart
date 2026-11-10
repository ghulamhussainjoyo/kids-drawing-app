import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/engine/stroke.dabber.dart';
import 'package:kids_drawing_flutter/core/engine/stroke.renderer.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.tool.dart';
import 'package:kids_drawing_flutter/data/models/brush.config.dart';
import 'package:kids_drawing_flutter/data/models/brush.type.dart';
import 'package:kids_drawing_flutter/data/models/drawing.stroke.dart';
import 'package:kids_drawing_flutter/data/models/paint.color.dart';

void main() {
  final tool = PencilTool();
  final renderer = StrokeRenderer();
  const orange = PaintColor(id: 'orange', color: Color(0xFFFF8A1F));

  DrawingStroke stroke(List<Offset> points) => DrawingStroke(
        id: 3,
        regionId: 'apple_body',
        brush: const BrushConfig(type: BrushType.pencil, paintColor: orange, size: 36),
        seed: 3,
        points: points,
      );

  final wavy = [
    for (var i = 0; i < 80; i++)
      Offset(40 + i * 3.0, 150 + math.sin(i / 6) * 60),
  ];

  Future<Uint8List> render(StrokeDabber dabber) async {
    final recorder = ui.PictureRecorder();
    renderer.paint(
      Canvas(recorder),
      dabber,
      Path()..addRect(const Rect.fromLTWH(0, 0, 300, 300)),
      tool,
    );
    final image = await recorder.endRecording().toImage(300, 300);
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
  }

  test('a stroke drawn live matches the same stroke replayed', () async {
    final live = tool.createDabber(stroke(wavy));
    for (final point in wavy) {
      live.addPoint(point);
      live.updateTail(point + const Offset(0.4, 0.3));
    }
    live.finish();
    final replayed = tool.replay(stroke(wavy));

    expect(live.dabs.count, replayed.dabs.count);
    expect(live.dabs.transforms, replayed.dabs.transforms);
    expect(live.dabs.colors, replayed.dabs.colors);
    expect(await render(live), await render(replayed));
  });

  test('dabs are spaced evenly along the stroke', () {
    final straight = [for (var i = 0; i <= 20; i++) Offset(50 + i * 10.0, 100)];
    final dabber = tool.replay(stroke(straight));
    // 200 units at 3.6-unit spacing, plus the first dab at the start.
    expect(dabber.dabs.count, 56);
  });

  test('the tail reaches the latest point and is rebuilt, not kept', () {
    final dabber = tool.createDabber(stroke(const [Offset(50, 50)]))
      ..addPoint(const Offset(50, 50))
      ..updateTail(const Offset(90, 50));
    expect(dabber.tail.count, greaterThan(5));
    expect(dabber.dabs.count, 1);
    // Barely moved: only the tap dot cluster, the earlier tail is gone.
    dabber.updateTail(const Offset(52, 50));
    expect(dabber.tail.count, 6);
  });

  test('a tap leaves a dot cluster', () {
    final dabber = tool.replay(stroke(const [Offset(80, 80)]));
    expect(dabber.dabs.count, 7);
  });
}
