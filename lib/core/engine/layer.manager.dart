import 'dart:ui';

import '../../data/models/coloring.artwork.dart';
import '../../data/models/drawing.stroke.dart';
import '../tools/drawing.tool.dart';
import 'region.engine.dart';
import 'stroke.dabber.dart';
import 'stroke.renderer.dart';

/// Composites the page back to front: paper, paint, outlines.
///
/// Committed paint lives in one raster image, so a frame costs the same
/// however many strokes came before. A committed stroke is drawn onto that
/// image once; undo and redo rebuild it from the stroke list once.
class LayerManager {
  LayerManager({required this.regionEngine})
      : strokeRenderer = StrokeRenderer();

  final RegionEngine regionEngine;
  final StrokeRenderer strokeRenderer;

  /// Committed paint resolution for the whole page.
  static const int paintImagePixels = 2048;

  Image? _paintImage;
  int _paintRevision = -1;
  List<int> _bakedStrokeIds = const [];
  Picture? _outlineCache;

  ColoringArtwork get artwork => regionEngine.artwork;

  /// [activeDabber] holds the dabs of [active] when it is drawn
  /// incrementally. It may also be the finished dabber of the stroke just
  /// committed, which is then baked without a replay.
  void paint(
    Canvas canvas, {
    required List<DrawingStroke> committed,
    required int revision,
    required DrawingTool tool,
    DrawingStroke? active,
    StrokeDabber? activeDabber,
  }) {
    final bounds = Rect.fromLTWH(0, 0, artwork.size, artwork.size);
    canvas.drawRect(bounds, Paint()..color = const Color(0xFFFFFFFF));

    if (revision != _paintRevision) {
      _syncPaint(committed, active == null ? activeDabber : null, tool);
      _paintRevision = revision;
    }
    final image = _paintImage;
    if (image != null) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        bounds,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }

    if (active != null) {
      _paintStroke(
        canvas,
        active,
        activeDabber ?? tool.replay(active),
        tool,
      );
    }

    canvas.drawPicture(_outlineCache ??= _recordOutlines());
  }

  void dispose() {
    _paintImage?.dispose();
    _outlineCache?.dispose();
  }

  void _paintStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    DrawingTool tool,
  ) {
    final region = regionEngine.regionById(stroke.regionId);
    if (region == null) return;
    strokeRenderer.paint(canvas, dabber, region.path, tool);
  }

  /// Brings the paint image up to [committed]: bakes only the newest stroke
  /// when it was appended, otherwise replays the whole list.
  void _syncPaint(
    List<DrawingStroke> committed,
    StrokeDabber? justCommitted,
    DrawingTool tool,
  ) {
    final ids = [for (final s in committed) s.id];
    final appendedOne =
        ids.length == _bakedStrokeIds.length + 1 && _startsWith(ids, _bakedStrokeIds);
    if (appendedOne && _paintImage != null) {
      final stroke = committed.last;
      final dabber = justCommitted != null && justCommitted.seed == stroke.seed
          ? justCommitted
          : tool.replay(stroke);
      _redrawPaint((canvas) {
        _drawPaintImage(canvas);
        _paintStroke(canvas, stroke, dabber, tool);
      });
    } else {
      _redrawPaint((canvas) {
        for (final stroke in committed) {
          _paintStroke(canvas, stroke, tool.replay(stroke), tool);
        }
      });
    }
    _bakedStrokeIds = ids;
  }

  void _redrawPaint(void Function(Canvas canvas) draw) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(paintImagePixels / artwork.size);
    draw(canvas);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(paintImagePixels, paintImagePixels);
    picture.dispose();
    _paintImage?.dispose();
    _paintImage = image;
  }

  /// Copies the current paint image pixel for pixel into an artwork-space
  /// canvas scaled to [paintImagePixels].
  void _drawPaintImage(Canvas canvas) {
    final image = _paintImage;
    if (image == null) return;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, artwork.size, artwork.size),
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  static bool _startsWith(List<int> list, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (list[i] != prefix[i]) return false;
    }
    return true;
  }

  Picture _recordOutlines() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final outline = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = artwork.outlineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    for (final region in artwork.regions.reversed) {
      canvas.drawPath(region.path, outline);
    }
    outline.strokeWidth = artwork.detailWidth;
    for (final line in artwork.detailLines) {
      canvas.drawPath(line, outline);
    }
    return recorder.endRecording();
  }
}
