import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'glitter.textures.dart';
import 'texture.library.dart';

/// Pattern tape: an opaque band filled with a repeating tile (rainbows,
/// paws…). The tile is fixed to the page, so neighbouring strokes continue
/// the same grid.
class PatternTool extends DrawingTool {
  PatternTool(this._library) : _tip = GlitterTextures.buildTip();

  final TextureLibrary _library;
  final ui.Image _tip;

  static const DabTip patternTip = DabTip(
    pixels: GlitterTextures.tipPixels,
    variants: 1,
    spacing: 0.08,
    alpha: 1,
    tipScale: 1,
    tapDabs: 1,
  );

  /// Side of one pattern tile on the page, in artwork units.
  static const double tileUnits = 144;

  @override
  BrushType get type => BrushType.pattern;

  @override
  DabTip get tip => patternTip;

  /// Lays the band down in the tape's color, then replaces it with the tile
  /// wherever the band is (srcIn).
  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    final bounds = dabber.bounds!;
    canvas.saveLayer(bounds, ui.Paint());
    stampDabs(canvas, _tip, dabber);
    _fillWithPattern(canvas, bounds, _library.image(dabber.texture));
    canvas.restore();
  }

  @override
  void dispose() => _tip.dispose();

  void _fillWithPattern(ui.Canvas canvas, ui.Rect bounds, ui.Image? tile) {
    if (tile == null) return;
    final paint = tiledPaint(
      tile,
      shift: ui.Offset.zero,
      pixelsPerUnit: tile.width / tileUnits,
      quality: ui.FilterQuality.medium,
    )..blendMode = ui.BlendMode.srcIn;
    canvas.drawRect(bounds, paint);
  }
}
