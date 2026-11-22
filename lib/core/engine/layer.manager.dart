import 'dart:ui';

import '../../types/brush.type.dart';
import '../../types/coloring.artwork.dart';
import '../../types/drawing.stroke.dart';
import '../tools/drawing.tool.dart';
import 'region.engine.dart';
import 'stroke.dabber.dart';
import 'stroke.renderer.dart';

/// Picks the paint engine for a stroke's brush.
typedef ToolFor = DrawingTool Function(BrushType type);

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

  static const Color _paper = Color(0xFFFFFFFF);
  static const Color _outline = Color(0xFF111111);

  static final Paint _maskAdd = Paint()
    ..colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn);
  static final Paint _maskCut = Paint()..blendMode = BlendMode.dstOut;

  Image? _paintImage;
  Image? _glitterMask;
  int _paintRevision = -1;
  List<int> _bakedStrokeIds = const [];
  Picture? _outlineCache;

  ColoringArtwork get artwork => regionEngine.artwork;

  Rect get _pageRect => Rect.fromLTWH(0, 0, artwork.size, artwork.size);

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
    required ToolFor toolFor,
    DrawingStroke? active,
    StrokeDabber? activeDabber,
    double? shimmerSeconds,
  }) {
    final justCommitted = _committedDabber(active, activeDabber);
    _syncIfChanged(committed, revision, justCommitted, toolFor);
    _paintPaper(canvas);
    _drawImage(canvas, _paintImage, quality: FilterQuality.medium);
    final liveDabber = _paintActive(canvas, active, activeDabber, toolFor);
    _paintShimmerIfNeeded(canvas, shimmerSeconds, active, liveDabber, toolFor);
    _paintOutlines(canvas);
    _paintOverOutlines(canvas, committed, active, liveDabber, toolFor);
  }

  void dispose() {
    _paintImage?.dispose();
    _glitterMask?.dispose();
    _outlineCache?.dispose();
  }

  // ---------------------------------------------------------------------------
  // Frame painting
  // ---------------------------------------------------------------------------

  void _paintPaper(Canvas canvas) {
    canvas.drawRect(_pageRect, Paint()..color = _paper);
  }

  /// Paints the stroke being drawn and returns its dabber, or null when no
  /// stroke is active.
  StrokeDabber? _paintActive(
    Canvas canvas,
    DrawingStroke? active,
    StrokeDabber? activeDabber,
    ToolFor toolFor,
  ) {
    if (active == null) return null;
    final dabber = activeDabber ?? _replay(active, toolFor);
    _paintStroke(canvas, active, dabber, toolFor);
    return dabber;
  }

  /// Whether any glitter is on the page, committed or being drawn.
  bool _hasGlitterToShimmer(DrawingStroke? active) {
    if (_glitterMask != null) return true;
    return _isGlitter(active);
  }

  /// Glints over committed glitter plus the stroke being drawn, so glitter
  /// shimmers from the moment it is laid down. Skipped for still output
  /// ([seconds] is null) and pages without glitter.
  void _paintShimmerIfNeeded(
    Canvas canvas,
    double? seconds,
    DrawingStroke? active,
    StrokeDabber? liveDabber,
    ToolFor toolFor,
  ) {
    if (seconds == null) return;
    if (!_hasGlitterToShimmer(active)) return;
    toolFor(BrushType.glitter).paintShimmer(
      canvas,
      bounds: _pageRect,
      seconds: seconds,
      coverage: (canvas) {
        _drawShimmerCoverage(canvas, active, liveDabber, toolFor);
      },
    );
  }

  void _drawShimmerCoverage(
    Canvas canvas,
    DrawingStroke? active,
    StrokeDabber? liveDabber,
    ToolFor toolFor,
  ) {
    _drawImage(canvas, _glitterMask, quality: FilterQuality.low);
    if (active == null) return;
    if (liveDabber == null) return;
    _maskStroke(canvas, active, liveDabber, toolFor);
  }

  void _paintOutlines(Canvas canvas) {
    canvas.drawPicture(_outlineCache ??= _recordOutlines());
  }

  /// Stickers sit above everything, outlines included. They are few and
  /// cheap, so they are drawn from the stroke list every frame instead of
  /// being baked.
  void _paintOverOutlines(
    Canvas canvas,
    List<DrawingStroke> committed,
    DrawingStroke? active,
    StrokeDabber? liveDabber,
    ToolFor toolFor,
  ) {
    for (final stroke in committed) {
      if (!_paintsOverOutlines(stroke, toolFor)) continue;
      toolFor(stroke.brush.type).paint(canvas, _replay(stroke, toolFor));
    }
    if (active == null) return;
    if (liveDabber == null) return;
    if (!_paintsOverOutlines(active, toolFor)) return;
    toolFor(active.brush.type).paint(canvas, liveDabber);
  }

  // ---------------------------------------------------------------------------
  // Baking committed strokes
  // ---------------------------------------------------------------------------

  /// The dabber of the stroke that was just committed, which can be baked
  /// as is. While a stroke is still active there is none.
  StrokeDabber? _committedDabber(
    DrawingStroke? active,
    StrokeDabber? activeDabber,
  ) {
    if (active != null) return null;
    return activeDabber;
  }

  void _syncIfChanged(
    List<DrawingStroke> committed,
    int revision,
    StrokeDabber? justCommitted,
    ToolFor toolFor,
  ) {
    if (revision == _paintRevision) return;
    _syncPaint(committed, justCommitted, toolFor);
    _paintRevision = revision;
  }

  /// Bakes only the newest stroke when it was appended, otherwise replays
  /// the whole list.
  void _syncPaint(
    List<DrawingStroke> committed,
    StrokeDabber? justCommitted,
    ToolFor toolFor,
  ) {
    final ids = [for (final stroke in committed) stroke.id];
    if (_onlyAppendedOne(ids)) {
      _bakeNewestStroke(committed.last, justCommitted, toolFor);
    } else {
      _rebuildAll(committed, toolFor);
    }
    _bakedStrokeIds = ids;
  }

  bool _onlyAppendedOne(List<int> ids) {
    if (_paintImage == null) return false;
    if (ids.length != _bakedStrokeIds.length + 1) return false;
    return _startsWith(ids, _bakedStrokeIds);
  }

  void _bakeNewestStroke(
    DrawingStroke stroke,
    StrokeDabber? justCommitted,
    ToolFor toolFor,
  ) {
    if (_paintsOverOutlines(stroke, toolFor)) return;
    final dabber = _dabberFor(stroke, justCommitted, toolFor);
    _addToPaintImage(stroke, dabber, toolFor);
    if (_maskNeedsUpdate(stroke)) {
      _addToGlitterMask(stroke, dabber, toolFor);
    }
  }

  /// Reuses the dabber laid out while drawing when it belongs to [stroke].
  StrokeDabber _dabberFor(
    DrawingStroke stroke,
    StrokeDabber? justCommitted,
    ToolFor toolFor,
  ) {
    if (justCommitted == null) return _replay(stroke, toolFor);
    if (justCommitted.seed != stroke.seed) return _replay(stroke, toolFor);
    return justCommitted;
  }

  void _addToPaintImage(
    DrawingStroke stroke,
    StrokeDabber dabber,
    ToolFor toolFor,
  ) {
    final previous = _paintImage;
    _paintImage = _bake(paintImagePixels, (canvas) {
      _drawImage(canvas, previous);
      _paintStroke(canvas, stroke, dabber, toolFor);
    });
    previous?.dispose();
  }

  void _addToGlitterMask(
    DrawingStroke stroke,
    StrokeDabber dabber,
    ToolFor toolFor,
  ) {
    final previous = _glitterMask;
    _glitterMask = _bake(glitterMaskPixels, (canvas) {
      _drawImage(canvas, previous);
      _maskStroke(canvas, stroke, dabber, toolFor);
    });
    previous?.dispose();
  }

  /// The mask changes when glitter is added, or when anything is painted
  /// over glitter that is already there.
  bool _maskNeedsUpdate(DrawingStroke stroke) {
    if (_glitterMask != null) return true;
    return _isGlitter(stroke);
  }

  void _rebuildAll(List<DrawingStroke> committed, ToolFor toolFor) {
    final dabbers = [for (final stroke in committed) _replay(stroke, toolFor)];
    _replacePaintImage(_bakeAll(committed, dabbers, toolFor));
    _replaceGlitterMask(_bakeGlitterMask(committed, dabbers, toolFor));
  }

  Image _bakeAll(
    List<DrawingStroke> committed,
    List<StrokeDabber> dabbers,
    ToolFor toolFor,
  ) {
    return _bake(paintImagePixels, (canvas) {
      for (var i = 0; i < committed.length; i++) {
        _paintStroke(canvas, committed[i], dabbers[i], toolFor);
      }
    });
  }

  /// Glitter mask for [committed], or null when the page has no glitter.
  /// Strokes before the first glitter stroke cannot hide any, so they are
  /// skipped.
  Image? _bakeGlitterMask(
    List<DrawingStroke> committed,
    List<StrokeDabber> dabbers,
    ToolFor toolFor,
  ) {
    final firstGlitter = committed.indexWhere(_isGlitter);
    if (firstGlitter < 0) return null;
    return _bake(glitterMaskPixels, (canvas) {
      for (var i = firstGlitter; i < committed.length; i++) {
        _maskStroke(canvas, committed[i], dabbers[i], toolFor);
      }
    });
  }

  void _replacePaintImage(Image image) {
    _paintImage?.dispose();
    _paintImage = image;
  }

  void _replaceGlitterMask(Image? mask) {
    _glitterMask?.dispose();
    _glitterMask = mask;
  }

  // ---------------------------------------------------------------------------
  // Strokes
  // ---------------------------------------------------------------------------

  void _paintStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    ToolFor toolFor,
  ) {
    if (_paintsOverOutlines(stroke, toolFor)) return;
    final clip = _clipFor(stroke);
    if (clip == null) return;
    strokeRenderer.paint(canvas, dabber, clip, toolFor(stroke.brush.type));
  }

  /// The area a stroke may paint: its region, or the whole page when it was
  /// drawn with clipping off. Null when its region no longer exists.
  Path? _clipFor(DrawingStroke stroke) {
    if (stroke.regionId == DrawingStroke.freeRegionId) {
      return Path()..addRect(_pageRect);
    }
    return regionEngine.regionById(stroke.regionId)?.path;
  }

  /// Glitter strokes add to the mask; any other stroke cuts away what it
  /// covers, since it hides the glitter beneath it.
  void _maskStroke(
    Canvas canvas,
    DrawingStroke stroke,
    StrokeDabber dabber,
    ToolFor toolFor,
  ) {
    canvas.saveLayer(
      _layerBoundsFor(stroke, dabber, toolFor),
      _maskPaintFor(stroke),
    );
    _paintStroke(canvas, stroke, dabber, toolFor);
    canvas.restore();
  }

  /// Area a stroke can touch: its dabs, or its whole region for tools that
  /// fill one.
  Rect? _layerBoundsFor(
    DrawingStroke stroke,
    StrokeDabber dabber,
    ToolFor toolFor,
  ) {
    if (!toolFor(stroke.brush.type).fillsRegion) return dabber.bounds;
    return _clipFor(stroke)?.getBounds();
  }

  static bool _paintsOverOutlines(DrawingStroke stroke, ToolFor toolFor) {
    return toolFor(stroke.brush.type).paintsOverOutlines;
  }

  Paint _maskPaintFor(DrawingStroke stroke) {
    if (_isGlitter(stroke)) return _maskAdd;
    return _maskCut;
  }

  StrokeDabber _replay(DrawingStroke stroke, ToolFor toolFor) {
    return toolFor(stroke.brush.type).replay(stroke);
  }

  static bool _isGlitter(DrawingStroke? stroke) {
    if (stroke == null) return false;
    return stroke.brush.type == BrushType.glitter;
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

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

  /// Draws a baked [image] over the whole page.
  void _drawImage(
    Canvas canvas,
    Image? image, {
    FilterQuality quality = FilterQuality.none,
  }) {
    if (image == null) return;
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(
      image,
      source,
      _pageRect,
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
      ..color = _outline
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
