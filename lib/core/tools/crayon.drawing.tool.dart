import 'dart:math';
import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'texture.canvas.dart';

/// Wax crayon: a thick, nearly opaque band with ragged edges, smooth inside.
class CrayonTool extends DrawingTool {
  CrayonTool() : _textures = _CrayonTextures();

  final _CrayonTextures _textures;

  static const DabTip crayonTip = DabTip(
    pixels: _CrayonTextures.tipPixels,
    variants: _CrayonTextures.tipVariants,
    spacing: 0.08,
    alpha: 0.45,
    tipScale: 1.1,
    tapDabs: 6,
  );

  @override
  BrushType get type => BrushType.crayon;

  @override
  DabTip get tip => crayonTip;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    canvas.saveLayer(dabber.bounds!, ui.Paint());
    stampDabs(canvas, _textures.tips, dabber);
    canvas.restore();
  }

  @override
  void dispose() => _textures.dispose();
}

/// Ragged wax tips, built once in code.
class _CrayonTextures {
  _CrayonTextures() : tips = _buildTips();

  final ui.Image tips;

  static const int tipVariants = 4;
  static const double tipPixels = 96;

  static const int _rimBlobs = 140;

  void dispose() => tips.dispose();

  /// Solid discs whose rim is broken up by small blobs, so the stroke edge
  /// looks rubbed on rather than cut.
  static ui.Image _buildTips() {
    final random = Random(31);
    const size = tipPixels;
    return TextureCanvas.render(size * tipVariants, size, (canvas) {
      for (var variant = 0; variant < tipVariants; variant++) {
        final center = ui.Offset(variant * size + size / 2, size / 2);
        canvas.save();
        canvas.clipRect(ui.Rect.fromLTWH(variant * size, 0, size, size));
        canvas.drawCircle(
          center,
          size * 0.36,
          ui.Paint()..color = const ui.Color(0xFFFFFFFF),
        );
        _drawRimBlobs(canvas, center, random);
        canvas.restore();
      }
    });
  }

  static void _drawRimBlobs(ui.Canvas canvas, ui.Offset center, Random random) {
    final blob = ui.Paint();
    for (var i = 0; i < _rimBlobs; i++) {
      final angle = random.nextDouble() * pi * 2;
      final distance = tipPixels * (0.3 + random.nextDouble() * 0.17);
      final point = center + ui.Offset(cos(angle), sin(angle)) * distance;
      blob.color = ui.Color.fromRGBO(
        255,
        255,
        255,
        0.4 + random.nextDouble() * 0.6,
      );
      canvas.drawCircle(
        point,
        tipPixels * (0.02 + random.nextDouble() * 0.05),
        blob,
      );
    }
  }
}
