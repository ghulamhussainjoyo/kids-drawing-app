import 'dart:ui';

import '../../types/brush.type.dart';
import '../../types/coloring.artwork.dart';
import '../../types/drawing.stroke.dart';
import '../tools/drawing.tool.dart';
import 'glitter.twinkle.dart';
import 'region.engine.dart';
import 'stroke.dabber.dart';
import 'stroke.renderer.dart';

/// Composites the page back to front: paper, paint, glitter, outlines.
///
/// Committed paint lives in raster images, so a frame costs the same however
/// many strokes came before. A committed stroke is drawn onto its image once;
/// undo and redo rebuild the images from the stroke list once.
///
/// Glitter strokes are baked into their own image so they can twinkle. To keep
/// painting order right, a non-glitter stroke drawn after glitter also erases
/// the glitter under it, so it shows on top of the glitter like it should.
class LayerManager {
  LayerManager({required this.regionEngine, GlitterTwinkle? twinkle})
    : strokeRenderer = StrokeRenderer(),
      twinkle = twinkle ?? GlitterTwinkle();

  final RegionEngine regionEngine;
  final StrokeRenderer strokeRenderer;
  final GlitterTwinkle twinkle;

  /// Committed paint resolution for the whole page.
  static const int paintImagePixels = 2048;

  /// Longest edge for the per-frame active glitter raster.
  static const double activeGlitterRasterMaxEdge = 768;

  Image? _paintImage; // every committed stroke except glitter
  Image? _glitterImage; // committed glitter, null when there is none
  int _paintRevision = -1;
  List<int> _bakedStrokeIds = const [];
  Picture? _outlineCache;

  ColoringArtwork get artwork => regionEngine.artwork;

  /// Whether [committed] has glitter, i.e. whether the page needs a ticker.
  static bool usesGlitter(List<DrawingStroke> committed) =>
      committed.any(_isGlitter);

  static bool _isGlitter(DrawingStroke stroke) =>
      stroke.brush.type == BrushType.glitter;

  /// [activeDabber] holds the dabs of [active] when it is drawn
  /// incrementally. It may also be the finished dabber of the stroke just
  /// committed, which is then baked without a replay.
  ///
  /// [time] is the animation clock in seconds; it only drives the twinkle.
  void paint(
    Canvas canvas, {
    required List<DrawingStroke> committed,
    required int revision,
    required DrawingTool Function(BrushType type) toolFor,
    DrawingStroke? active,
    StrokeDabber? activeDabber,
    double time = 0,
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

    final glitter = _glitterImage;
    if (glitter != null) _drawGlitter(canvas, glitter, bounds, time);

    if (active != null) {
      final activeTool = toolFor(active.brush.type);
      final dabber = activeDabber ?? activeTool.replay(active);
      if (_isGlitter(active)) {
        _paintActiveGlitter(canvas, active, dabber, activeTool, time);
      } else {
        _paintStroke(canvas, active, dabber, activeTool);
      }
    }

    canvas.drawPicture(_outlineCache ??= _recordOutlines());
  }

  void dispose() {
    _paintImage?.dispose();
    _glitterImage?.dispose();
    _outlineCache?.dispose();
    twinkle.dispose();
  }

  void _drawGlitter(Canvas canvas, Image image, Rect dest, double time) {
    final twinkling = twinkle.paintFor(
      image: image,
      seconds: time,
      width: dest.width,
      height: dest.height,
      imagePixels: image.width.toDouble(),
    );
    if (twinkling != null) {
      canvas.drawRect(dest, twinkling);
      return;
    }
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dest,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  void _paintActiveGlitter(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    DrawingTool tool,
    double time,
  ) {
    final bounds = dabber.bounds;
    if (bounds == null) return;
    if (dabber.dabs.count + dabber.tail.count == 0) return;

    final pageScale = paintImagePixels / artwork.size;
    var pixelW = bounds.width * pageScale;
    var pixelH = bounds.height * pageScale;
    var downsample = 1.0;
    final longest = pixelW > pixelH ? pixelW : pixelH;
    if (longest > activeGlitterRasterMaxEdge) {
      downsample = activeGlitterRasterMaxEdge / longest;
      pixelW *= downsample;
      pixelH *= downsample;
    }

    final recorder = PictureRecorder();
    final rasterCanvas = Canvas(recorder);
    final drawScale = pageScale * downsample;
    rasterCanvas.scale(drawScale);
    rasterCanvas.translate(-bounds.left, -bounds.top);
    rasterCanvas.clipRect(
      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
    );
    _paintStroke(rasterCanvas, stroke, dabber, tool);

    final picture = recorder.endRecording();
    final w = pixelW.ceil().clamp(1, paintImagePixels);
    final h = pixelH.ceil().clamp(1, paintImagePixels);
    final image = picture.toImageSync(w, h);
    picture.dispose();

    _drawGlitter(canvas, image, bounds, time);
    image.dispose();
  }

  void _paintStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    DrawingTool tool,
  ) {
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

  /// Removes the pixels [stroke] covers from the layer being drawn, by
  /// compositing it with dstOut.
  void _eraseStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    DrawingTool tool,
  ) {
    final bounds = dabber.bounds;
    if (bounds == null) return;
    canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.dstOut);
    _paintStroke(canvas, stroke, dabber, tool);
    canvas.restore();
  }

  /// Brings the images up to [committed]: bakes only the newest stroke when it
  /// was appended, otherwise replays the whole list.
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
      final tool = toolFor(stroke.brush.type);
      final dabber = justCommitted != null && justCommitted.seed == stroke.seed
          ? justCommitted
          : tool.replay(stroke);
      if (_isGlitter(stroke)) {
        _glitterImage = _bake(
          _glitterImage,
          (canvas) => _paintStroke(canvas, stroke, dabber, tool),
        );
      } else {
        _paintImage = _bake(
          _paintImage,
          (canvas) => _paintStroke(canvas, stroke, dabber, tool),
        );
        if (_glitterImage != null) {
          _glitterImage = _bake(
            _glitterImage,
            (canvas) => _eraseStroke(canvas, stroke, dabber, tool),
          );
        }
      }
    } else {
      _rebuild(committed, toolFor);
    }
    _bakedStrokeIds = ids;
  }

  void _rebuild(
    List<DrawingStroke> committed,
    DrawingTool Function(BrushType type) toolFor,
  ) {
    final tools = [for (final s in committed) toolFor(s.brush.type)];
    final dabbers = [
      for (var i = 0; i < committed.length; i++) tools[i].replay(committed[i]),
    ];

    final oldPaint = _paintImage;
    _paintImage = _bake(null, (canvas) {
      for (var i = 0; i < committed.length; i++) {
        if (_isGlitter(committed[i])) continue;
        _paintStroke(canvas, committed[i], dabbers[i], tools[i]);
      }
    });
    oldPaint?.dispose();

    final firstGlitter = committed.indexWhere(_isGlitter);
    final oldGlitter = _glitterImage;
    _glitterImage = firstGlitter < 0
        ? null
        : _bake(null, (canvas) {
            for (var i = firstGlitter; i < committed.length; i++) {
              if (_isGlitter(committed[i])) {
                _paintStroke(canvas, committed[i], dabbers[i], tools[i]);
              } else {
                _eraseStroke(canvas, committed[i], dabbers[i], tools[i]);
              }
            }
          });
    oldGlitter?.dispose();
  }

  /// Draws [previous] (if any) and then [draw] into a new page-sized image,
  /// and disposes [previous].
  Image _bake(Image? previous, void Function(Canvas canvas) draw) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(paintImagePixels / artwork.size);
    if (previous != null) _drawImage(canvas, previous);
    draw(canvas);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(paintImagePixels, paintImagePixels);
    picture.dispose();
    previous?.dispose();
    return image;
  }

  /// Copies [image] pixel for pixel into an artwork-space canvas scaled to
  /// [paintImagePixels].
  void _drawImage(Canvas canvas, Image image) {
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
