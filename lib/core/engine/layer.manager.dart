import 'dart:ui';

import '../../types/brush.type.dart';
import '../../types/coloring.artwork.dart';
import '../../types/drawing.stroke.dart';
import '../tools/drawing.tool.dart';
import 'region.engine.dart';
import 'stroke.dabber.dart';
import 'stroke.renderer.dart';

/// Composites the page back to front: paper, paint, outlines.
///
/// Committed paint lives in one raster image, so a frame costs the same
/// however many strokes came before. A committed stroke is drawn onto that
/// image once; undo and redo rebuild it from the stroke list once.
///
/// A second, smaller image masks where glitter is still visible (later
/// non-glitter strokes cut it away), so glitter can shimmer live on top of
/// the baked paint.
class LayerManager {
  LayerManager({required this.regionEngine})
    : strokeRenderer = StrokeRenderer();

  final RegionEngine regionEngine;
  final StrokeRenderer strokeRenderer;

  /// Committed paint resolution for the whole page.
  static const int paintImagePixels = 2048;

  /// Glitter mask resolution; it only gates glints, so it can be coarser.
  static const int glitterMaskPixels = 1024;

  static final Paint _maskAdd = Paint()
    ..colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn);
  static final Paint _maskCut = Paint()..blendMode = BlendMode.dstOut;

  Image? _paintImage;
  Image? _glitterMask;
  int _paintRevision = -1;
  List<int> _bakedStrokeIds = const [];
  Picture? _outlineCache;

  ColoringArtwork get artwork => regionEngine.artwork;

  /// [activeDabber] holds the dabs of [active] when it is drawn
  /// incrementally. It may also be the finished dabber of the stroke just
  /// committed, which is then baked without a replay.
  ///
  /// With [shimmerSeconds], visible glitter twinkles; leave it null for still
  /// output such as thumbnails and exports.
  void paint(
    Canvas canvas, {
    required List<DrawingStroke> committed,
    required int revision,
    required DrawingTool Function(BrushType type) toolFor,
    DrawingStroke? active,
    StrokeDabber? activeDabber,
    double? shimmerSeconds,
  }) {
    final bounds = Rect.fromLTWH(0, 0, artwork.size, artwork.size);
    canvas.drawRect(bounds, Paint()..color = const Color(0xFFFFFFFF));

    if (revision != _paintRevision) {
      _syncPaint(committed, active == null ? activeDabber : null, toolFor);
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

    StrokeDabber? liveDabber;
    if (active != null) {
      final tool = toolFor(active.brush.type);
      liveDabber = activeDabber ?? tool.replay(active);
      _paintStroke(canvas, active, liveDabber, toolFor);
    }

    final mask = _glitterMask;
    final drawingGlitter = active != null && _isGlitter(active);
    if (shimmerSeconds != null && (mask != null || drawingGlitter)) {
      // Glints cover committed glitter plus the stroke being drawn, so glitter
      // shimmers from the moment it is laid down.
      toolFor(BrushType.glitter).paintShimmer(
        canvas,
        bounds: bounds,
        seconds: shimmerSeconds,
        coverage: (canvas) {
          _drawImage(canvas, mask, FilterQuality.low);
          if (active != null && liveDabber != null) {
            _maskStroke(canvas, active, liveDabber, toolFor);
          }
        },
      );
    }

    canvas.drawPicture(_outlineCache ??= _recordOutlines());
  }

  /// Whether any committed glitter is visible, i.e. whether shimmer has
  /// anything to draw.
  bool get hasGlitter => _glitterMask != null;

  void dispose() {
    _paintImage?.dispose();
    _glitterMask?.dispose();
    _outlineCache?.dispose();
  }

  void _paintStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    DrawingTool Function(BrushType type) toolFor,
  ) {
    final tool = toolFor(stroke.brush.type);
    if (stroke.regionId == DrawingStroke.freeRegionId) {
      final size = artwork.size;
      final pagePath = Path()..addRect(Rect.fromLTWH(0, 0, size, size));
      strokeRenderer.paint(canvas, dabber, pagePath, tool);
      return;
    }
    final region = regionEngine.regionById(stroke.regionId);
    if (region == null) {
      return;
    }
    strokeRenderer.paint(canvas, dabber, region.path, tool);
  }

  /// Brings the paint image and glitter mask up to [committed]: bakes only
  /// the newest stroke when it was appended, otherwise replays the whole list.
  void _syncPaint(
    List<DrawingStroke> committed,
    StrokeDabber? justCommitted,
    DrawingTool Function(BrushType type) toolFor,
  ) {
    final ids = [for (final s in committed) s.id];
    final appendedOne =
        ids.length == _bakedStrokeIds.length + 1 &&
        _startsWith(ids, _bakedStrokeIds);
    if (appendedOne && _paintImage != null) {
      final stroke = committed.last;
      final dabber = justCommitted != null && justCommitted.seed == stroke.seed
          ? justCommitted
          : toolFor(stroke.brush.type).replay(stroke);
      final oldPaint = _paintImage;
      _paintImage = _bake(paintImagePixels, (canvas) {
        _drawImage(canvas, oldPaint);
        _paintStroke(canvas, stroke, dabber, toolFor);
      });
      oldPaint?.dispose();
      final oldMask = _glitterMask;
      if (oldMask != null || _isGlitter(stroke)) {
        _glitterMask = _bake(glitterMaskPixels, (canvas) {
          _drawImage(canvas, oldMask);
          _maskStroke(canvas, stroke, dabber, toolFor);
        });
        oldMask?.dispose();
      }
    } else {
      final dabbers = [
        for (final stroke in committed)
          toolFor(stroke.brush.type).replay(stroke),
      ];
      _paintImage?.dispose();
      _paintImage = _bake(paintImagePixels, (canvas) {
        for (var i = 0; i < committed.length; i++) {
          _paintStroke(canvas, committed[i], dabbers[i], toolFor);
        }
      });
      _glitterMask?.dispose();
      _glitterMask = null;
      final firstGlitter = committed.indexWhere(_isGlitter);
      if (firstGlitter >= 0) {
        _glitterMask = _bake(glitterMaskPixels, (canvas) {
          for (var i = firstGlitter; i < committed.length; i++) {
            _maskStroke(canvas, committed[i], dabbers[i], toolFor);
          }
        });
      }
    }
    _bakedStrokeIds = ids;
  }

  /// Glitter strokes add to the mask; any other stroke cuts away what it
  /// covers, since it hides the glitter beneath it.
  void _maskStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    DrawingTool Function(BrushType type) toolFor,
  ) {
    canvas.saveLayer(null, _isGlitter(stroke) ? _maskAdd : _maskCut);
    _paintStroke(canvas, stroke, dabber, toolFor);
    canvas.restore();
  }

  static bool _isGlitter(DrawingStroke stroke) =>
      stroke.brush.type == BrushType.glitter;

  /// Renders [draw], in artwork coordinates, into a square image of [pixels].
  Image _bake(int pixels, void Function(Canvas canvas) draw) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixels / artwork.size);
    draw(canvas);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(pixels, pixels);
    picture.dispose();
    return image;
  }

  /// Copies a baked [image] back onto an artwork-space canvas.
  void _drawImage(
    Canvas canvas,
    Image? image, [
    FilterQuality quality = FilterQuality.none,
  ]) {
    if (image == null) return;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, artwork.size, artwork.size),
      Paint()..filterQuality = quality,
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
