import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'texture.library.dart';

/// Sticker: places the stroke's image where the finger is. Dragging moves it
/// until the finger lifts. Stickers sit above the outlines.
class StickerTool extends DrawingTool {
  StickerTool(this._library);

  final TextureLibrary _library;

  /// A sticker stamps nothing along the path; only its last point matters.
  static const DabTip stickerTip = DabTip(
    pixels: 1,
    variants: 1,
    spacing: 1,
    alpha: 1,
    tipScale: 1,
    tapDabs: 1,
  );

  /// Sticker side as a multiple of the brush size, so the size slider works.
  static const double sizeScale = 4.5;

  @override
  BrushType get type => BrushType.sticker;

  @override
  DabTip get tip => stickerTip;

  @override
  bool get paintsOverOutlines => true;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    final image = _library.image(dabber.texture);
    if (image == null) return;
    final point = dabber.lastPoint;
    if (point == null) return;
    final side = dabber.width * sizeScale;
    final target = ui.Rect.fromCenter(center: point, width: side, height: side);
    final source = ui.Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(
      image,
      source,
      target,
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
  }
}
