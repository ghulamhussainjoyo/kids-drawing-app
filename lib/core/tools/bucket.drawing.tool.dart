import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../../types/paint.color.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';

/// Paint bucket: one tap fills the whole region under it (or the background)
/// with the color. Multi-color balls fill with a gradient of their colors.
class BucketTool extends DrawingTool {
  /// The bucket stamps nothing; the dabber only records the tap.
  static const DabTip bucketTip = DabTip(
    pixels: 1,
    variants: 1,
    spacing: 1,
    alpha: 1,
    tipScale: 1,
    tapDabs: 1,
  );

  /// Colors sampled from a multi-color palette for the gradient.
  static const int _gradientColors = 6;

  @override
  BrushType get type => BrushType.bucket;

  @override
  DabTip get tip => bucketTip;

  @override
  bool get fillsRegion => true;

  /// The canvas is clipped to the tapped region, so filling the clip bounds
  /// fills exactly that region.
  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.lastPoint == null) return;
    final area = canvas.getLocalClipBounds();
    canvas.drawRect(area, _fillPaint(dabber, area));
  }

  ui.Paint _fillPaint(StrokeDabber dabber, ui.Rect area) {
    final colors = _paletteColors(dabber);
    if (colors.length == 1) return ui.Paint()..color = colors.first;
    return ui.Paint()
      ..shader = ui.Gradient.linear(
        area.topLeft,
        area.bottomRight,
        colors,
        _evenStops(colors.length),
      );
  }

  /// Gradient stops spread evenly from 0 to 1.
  static List<double> _evenStops(int count) {
    return [for (var i = 0; i < count; i++) i / (count - 1)];
  }

  /// The stroke's colors, one per palette step. A solid palette gives one.
  List<ui.Color> _paletteColors(StrokeDabber dabber) {
    final first = dabber.colorAt(0);
    final colors = [first];
    for (var i = 1; i < _gradientColors; i++) {
      colors.add(dabber.colorAt(i * PaintColor.distancePerColor));
    }
    if (_allSame(colors)) return [first];
    return colors;
  }

  static bool _allSame(List<ui.Color> colors) {
    for (final color in colors) {
      if (color != colors.first) return false;
    }
    return true;
  }
}
