import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'pencils.textures.dart';

/// Stamped pencil: streaky tip images along the stroke, then paper grain.
class PencilTool extends DrawingTool {
  PencilTool() : textures = PencilTextures();

  final PencilTextures textures;

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
  DabTip get tip => pencilTip;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    final bounds = dabber.bounds!;
    canvas.saveLayer(bounds, ui.Paint());
    stampDabs(canvas, textures.tips, dabber);
    canvas.drawRect(bounds, _paperGrain(dabber.seed));
    canvas.restore();
  }

  @override
  void dispose() {
    textures.dispose();
  }

  /// Keeps the stroke only where the paper grain is (dstIn), so pits show
  /// through as unpainted specks.
  ui.Paint _paperGrain(int seed) {
    const tile = PencilTextures.paperTile;
    final shift = ui.Offset((seed * 37) % tile, (seed * 91) % tile);
    return tiledPaint(
      textures.paper,
      shift: shift,
      pixelsPerUnit: PencilTextures.paperPixelsPerUnit,
      quality: ui.FilterQuality.medium,
    )..blendMode = ui.BlendMode.dstIn;
  }
}
