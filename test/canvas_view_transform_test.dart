import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/engine/canvas.engine.dart';

void main() {
  const fitted = CanvasViewTransform(
    pageRect: Rect.fromLTWH(200, 20, 500, 500),
    artworkSize: 1000,
  );

  test('screen and artwork coordinates round-trip at any zoom', () {
    final zoomed = fitted.zoomedAround(
      newZoom: 2.5,
      anchorArtwork: const Offset(500, 320),
      focalScreen: const Offset(400, 200),
    );
    for (final view in [fitted, zoomed]) {
      const artwork = Offset(612.5, 287.25);
      final back = view.toArtwork(view.toScreen(artwork));
      expect(back.dx, closeTo(artwork.dx, 1e-9));
      expect(back.dy, closeTo(artwork.dy, 1e-9));
    }
  });

  test('pinch keeps the artwork point under the fingers', () {
    final zoomed = fitted.zoomedAround(
      newZoom: 3,
      anchorArtwork: const Offset(500, 320),
      focalScreen: const Offset(430, 260),
    );
    final under = zoomed.toArtwork(const Offset(430, 260));
    expect(under.dx, closeTo(500, 1e-9));
    expect(under.dy, closeTo(320, 1e-9));
    expect(zoomed.zoom, 3);
  });

  test('nearly zoomed out settles back to the fitted page', () {
    final almost = fitted.zoomedAround(
      newZoom: 1.05,
      anchorArtwork: const Offset(500, 500),
      focalScreen: const Offset(470, 290),
    );
    expect(almost.settled().isFitted, isTrue);
  });

  test('zoomed page stays covering its slot after settling', () {
    final zoomed = fitted.zoomedAround(
      newZoom: 2,
      anchorArtwork: const Offset(0, 0),
      focalScreen: const Offset(900, 900),
    );
    final settled = zoomed.settled();
    expect(settled.zoom, 2);
    expect(settled.translation.dx, inInclusiveRange(-500, 0));
    expect(settled.translation.dy, inInclusiveRange(-500, 0));
  });
}
