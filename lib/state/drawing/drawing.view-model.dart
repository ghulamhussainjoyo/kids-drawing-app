import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../core/engine/region.engine.dart';
import '../../core/engine/stroke.dabber.dart';
import '../../core/tools/drawing.tool.dart';
import '../../data/models/brush.config.dart';
import '../../data/models/brush.type.dart';
import '../../data/models/drawing.stroke.dart';
import '../../data/models/paint.color.dart';
import '../../data/repositories/artwork/artwork.repository.dart';

/// Drawing session state: active brush, committed strokes and history.
///
/// Listeners are notified for UI-level changes (tool, color, history). The
/// in-progress stroke is reported separately through [activeStrokeTicks] so
/// pointer moves repaint the canvas without rebuilding widgets.
class DrawingViewModel extends ChangeNotifier {
  DrawingViewModel({
    required this.artworkRepository,
    required this.regionEngine,
    required this.tool,
    required BrushConfig initialBrush,
  }) : _brush = initialBrush;

  final ArtworkRepository artworkRepository;
  final RegionEngine regionEngine;
  final DrawingTool tool;

  /// Samples closer than this (artwork units) to the previous one are dropped.
  static const double _minSampleDistance = 1.5;

  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _redoStack = [];
  final ValueNotifier<int> activeStrokeTicks = ValueNotifier<int>(0);

  BrushConfig _brush;
  DrawingStroke? _active;
  StrokeDabber? _activeDabber;
  int _revision = 0;
  int _nextStrokeId = 1;
  bool _hasCompletedStroke = false;

  BrushConfig get brush => _brush;
  List<DrawingStroke> get strokes => UnmodifiableListView(_strokes);
  DrawingStroke? get activeStroke => _active;

  /// Dabs of the active stroke, or of the stroke just committed until the
  /// next one starts, so the layer manager can bake it without a replay.
  StrokeDabber? get activeDabber => _activeDabber;

  /// Changes whenever the committed stroke list changes.
  int get revision => _revision;

  bool get canUndo => _strokes.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Sticky once the first stroke is committed; drives the done check.
  bool get hasCompletedStroke => _hasCompletedStroke;

  bool isToolSupported(BrushType type) => type == tool.type;

  void selectTool(BrushType type) {
    if (!isToolSupported(type) || type == _brush.type) return;
    _brush = _brush.copyWith(type: type);
    notifyListeners();
  }

  void selectColor(PaintColor paintColor) {
    if (paintColor.id == _brush.paintColor.id) return;
    _brush = _brush.copyWith(paintColor: paintColor);
    notifyListeners();
  }

  /// Starts a stroke at [point] (artwork coordinates). A touch on an outline
  /// or beside the art picks the nearest region within [pickRadius]. Returns
  /// false, and paints nothing, when no region is that close.
  bool beginStroke(Offset point, {double pickRadius = 0}) {
    _active = null;
    _activeDabber = null;
    final region = regionEngine.regionAt(point, pickRadius: pickRadius);
    if (region == null) return false;
    final stroke = DrawingStroke(
      id: _nextStrokeId,
      regionId: region.id,
      brush: _brush,
      seed: _nextStrokeId,
      points: [point],
    );
    _active = stroke;
    _activeDabber = tool.createDabber(stroke)
      ..addPoint(point)
      ..updateTail();
    _nextStrokeId++;
    activeStrokeTicks.value++;
    return true;
  }

  /// Adds a sample. Samples too close to the last stored one are not kept,
  /// but the drawn stroke still reaches them.
  void extendStroke(Offset point) {
    final active = _active;
    if (active == null) return;
    if ((point - active.points.last).distance >= _minSampleDistance) {
      active.points.add(point);
      _activeDabber?.addPoint(point);
    }
    _activeDabber?.updateTail(point);
    activeStrokeTicks.value++;
  }

  /// Commits the active stroke as one undo step and returns it.
  DrawingStroke? endStroke() {
    final active = _active;
    if (active == null) return null;
    _active = null;
    _activeDabber?.finish();
    _strokes.add(active);
    _redoStack.clear();
    _revision++;
    _hasCompletedStroke = true;
    activeStrokeTicks.value++;
    notifyListeners();
    return active;
  }

  /// Drops the active stroke without touching history.
  void cancelStroke() {
    if (_active == null) return;
    _active = null;
    _activeDabber = null;
    activeStrokeTicks.value++;
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(_strokes.removeLast());
    _revision++;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _strokes.add(_redoStack.removeLast());
    _revision++;
    notifyListeners();
  }

  @override
  void dispose() {
    activeStrokeTicks.dispose();
    super.dispose();
  }
}
