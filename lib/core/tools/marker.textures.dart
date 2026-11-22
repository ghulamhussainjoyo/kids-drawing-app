import 'dart:ui' as ui;

import 'texture.canvas.dart';

/// Round, solid tips that fade to clear over their outer [softEdge] part of
/// the radius: a thin fade gives a crisp marker edge, a wide one a feathered
/// watercolor edge. No streaks, no paper grain.
class MarkerTextures {
  MarkerTextures({required double softEdge})
    : tips = buildTips(softEdge: softEdge);

  final ui.Image tips;

  void dispose() {
    tips.dispose();
  }

  static const int tipVariants = 3;
  static const double tipPixels = 64;

  static ui.Image buildTips({required double softEdge}) {
    const size = tipPixels;
    const radius = size / 2;
    return TextureCanvas.render(size * tipVariants, size, (canvas) {
      for (var variant = 0; variant < tipVariants; variant++) {
        final center = ui.Offset(variant * size + radius, radius);
        canvas.drawCircle(center, radius, _tipPaint(center, radius, softEdge));
      }
    });
  }

  /// Fully opaque up to the soft edge, then fades to clear at the rim.
  static ui.Paint _tipPaint(ui.Offset center, double radius, double softEdge) {
    return ui.Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        const [
          ui.Color(0xFFFFFFFF),
          ui.Color(0xFFFFFFFF),
          ui.Color(0x00FFFFFF),
        ],
        [0, 1 - softEdge, 1],
      );
  }
}
