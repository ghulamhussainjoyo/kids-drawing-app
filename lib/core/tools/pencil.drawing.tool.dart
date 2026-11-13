import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show HSVColor;
import 'package:flutter/rendering.dart' show Matrix4;

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../../types/paint.color.dart';
import '../engine/dab.buffer.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'pencils.textures.dart';

/// Stamped pencil: streaky tip images along the stroke, then paper grain.
class PencilTool extends DrawingTool {
  PencilTool() : textures = PencilTextures();

  final PencilTextures textures;

  static const double rainbowHuePerUnit = 0.9;

  static const DabTip pencilTip = DabTip(
    pixels: PencilTextures.tipPixels,
    variants: PencilTextures.tipVariants,
    spacing: 0.1,
    alpha: 0.3,
    tipScale: 1.2,
    tapDabs: 7,
  );

  @override
  BrushType get type => BrushType.pencil;

  @override
  StrokeDabber createDabber(DrawingStroke stroke) {
    return StrokeDabber(
      tip: pencilTip,
      width: stroke.brush.size,
      seed: stroke.seed,
      colorAt: (distance) {
        return colorAt(stroke.brush.paintColor, stroke.seed, distance);
      },
    );
  }

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    final bounds = dabber.bounds;
    if (bounds == null) return;
    if (dabber.dabs.count + dabber.tail.count == 0) return;
    final atlasPaint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    canvas.saveLayer(bounds, ui.Paint());
    stamp(canvas, dabber.dabs, atlasPaint);
    stamp(canvas, dabber.tail, atlasPaint);
    canvas.drawRect(
      bounds,
      paperGrain(dabber.seed)..blendMode = ui.BlendMode.dstIn,
    );
    canvas.restore();
  }

  @override
  void dispose() {
    textures.dispose();
  }

  void stamp(ui.Canvas canvas, DabBuffer buffer, ui.Paint atlasPaint) {
    if (buffer.count == 0) return;
    canvas.drawRawAtlas(
      textures.tips,
      buffer.transforms,
      buffer.rects,
      buffer.colors,
      ui.BlendMode.modulate,
      null,
      atlasPaint,
    );
  }

  ui.Paint paperGrain(int seed) {
    final tile = PencilTextures.paperTile;
    final shift = ui.Offset((seed * 37) % tile, (seed * 91) % tile);
    final matrix = Matrix4.translationValues(shift.dx, shift.dy, 0)
      ..scaleByDouble(
        1 / PencilTextures.paperPixelsPerUnit,
        1 / PencilTextures.paperPixelsPerUnit,
        1,
        1,
      );
    return ui.Paint()
      ..shader = ui.ImageShader(
        textures.paper,
        ui.TileMode.repeated,
        ui.TileMode.repeated,
        matrix.storage,
        filterQuality: ui.FilterQuality.medium,
      );
  }

  static ui.Color colorAt(PaintColor paintColor, int seed, double distance) {
    if (!paintColor.isRainbow) return paintColor.color;
    final startHue = (seed * 47) % 360.0;
    final hue = (startHue + distance * rainbowHuePerUnit) % 360;
    return HSVColor.fromAHSV(1, hue, 0.8, 0.98).toColor();
  }
}
