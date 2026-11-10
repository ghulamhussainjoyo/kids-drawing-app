import 'dart:math' as math;
import 'dart:ui';

/// Maps between screen (widget-local) coordinates and artwork coordinates.
///
/// screen = translation + zoom * fitScale * artwork, where [fitScale] makes
/// the artwork fill [pageRect] at zoom 1. Strokes are stored in artwork
/// coordinates, so zooming and panning never change saved points.
class CanvasViewTransform {
  const CanvasViewTransform({
    required this.pageRect,
    required this.artworkSize,
    this.zoom = 1,
    Offset? translation,
  }) : translation = translation ?? Offset.zero;

  /// Where the page sits at zoom 1, in widget-local coordinates.
  final Rect pageRect;
  final double artworkSize;
  final double zoom;

  /// Offset of the zoomed page from [pageRect.topLeft].
  final Offset translation;

  static const double minZoom = 1;
  static const double maxZoom = 4;

  /// Below this zoom at gesture end, the page snaps back to fit.
  static const double snapToFitZoom = 1.08;

  double get fitScale => pageRect.width / artworkSize;
  double get scale => zoom * fitScale;
  Offset get origin => pageRect.topLeft + translation;

  bool get isFitted => zoom == 1 && translation == Offset.zero;

  Offset toArtwork(Offset screen) => (screen - origin) / scale;
  Offset toScreen(Offset artwork) => origin + artwork * scale;

  void apply(Canvas canvas) {
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
  }

  CanvasViewTransform fitted() =>
      CanvasViewTransform(pageRect: pageRect, artworkSize: artworkSize);

  CanvasViewTransform withPageRect(Rect rect) => CanvasViewTransform(
        pageRect: rect,
        artworkSize: artworkSize,
        zoom: zoom,
        translation: translation * (rect.width / pageRect.width),
      );

  /// Zooms so the artwork point that was under [anchorArtwork] lands at
  /// [focalScreen].
  CanvasViewTransform zoomedAround({
    required double newZoom,
    required Offset anchorArtwork,
    required Offset focalScreen,
  }) {
    final z = newZoom.clamp(minZoom * 0.8, maxZoom);
    final newOrigin = focalScreen - anchorArtwork * (z * fitScale);
    return CanvasViewTransform(
      pageRect: pageRect,
      artworkSize: artworkSize,
      zoom: z,
      translation: newOrigin - pageRect.topLeft,
    );
  }

  /// Where the view should settle after a gesture: fitted when nearly
  /// zoomed out, otherwise clamped so the page still covers its slot.
  CanvasViewTransform settled() {
    if (zoom < snapToFitZoom) return fitted();
    final z = math.min(zoom, maxZoom);
    final pageSize = pageRect.width * z;
    final minShift = pageRect.width - pageSize;
    return CanvasViewTransform(
      pageRect: pageRect,
      artworkSize: artworkSize,
      zoom: z,
      translation: Offset(
        translation.dx.clamp(minShift, 0),
        translation.dy.clamp(minShift, 0),
      ),
    );
  }

  static CanvasViewTransform lerp(
    CanvasViewTransform a,
    CanvasViewTransform b,
    double t,
  ) {
    return CanvasViewTransform(
      pageRect: b.pageRect,
      artworkSize: b.artworkSize,
      zoom: lerpDouble(a.zoom, b.zoom, t)!,
      translation: Offset.lerp(a.translation, b.translation, t)!,
    );
  }
}
