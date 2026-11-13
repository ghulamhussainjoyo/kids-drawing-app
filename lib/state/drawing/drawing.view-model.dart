import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../core/engine/layer.manager.dart';
import '../../core/engine/region.engine.dart';
import '../../core/engine/stroke.dabber.dart';
import '../../core/tools/drawing.tool.dart';
import '../../core/tools/pencil.drawing.tool.dart';
import '../../core/tools/stationary.tools.dart';
import '../../types/brush.config.dart';
import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../../types/paint.color.dart';
import '../../types/tools/stationary.model.dart';
import '../../data/repositories/artwork/artwork.repository.dart';
import '../../data/repositories/artwork/artwork.repository.impl.dart';

/// Drawing session state: active brush, committed strokes and history.
///
/// Listeners are notified for UI-level changes (tool, color, history). The
/// in-progress stroke is reported separately through [activeStrokeTicks] so
/// pointer moves repaint the canvas without rebuilding widgets.
class DrawingViewModel extends ChangeNotifier {
  DrawingViewModel() {
    openSelectedArtwork();
  }

  final StationaryTools stationaryTools = StationaryTools();
  final ArtworkRepository artworkRepository = const ArtworkRepositoryImpl();
  double density = 0.45;
  String? selectedArtworkId;
  StationaryModel? selectedTool;
  //@Doc: Layer manager
  late LayerManager layerManager;
  late RegionEngine regionEngine;
  //@Doc: Selected category
  String selectedCategory = 'pencil';
  DrawingTool drawingTool = PencilTool();

  /// Samples closer than this (artwork units) to the previous one are dropped.
  static const double minBrushSize = 12;
  static const double maxBrushSize = 56;
  static const double minSampleDistance = 1.5;

  final List<DrawingStroke> strokesList = [];
  final List<DrawingStroke> redoStack = [];
  final ValueNotifier<int> activeStrokeTicks = ValueNotifier<int>(0);

  final paintColor = PaintColor(id: 'red', color: Color(0xFFF44336));

  late BrushConfig brushConfig = BrushConfig(
    size: 32,
    type: BrushType.pencil,
    paintColor: paintColor,
  );

  DrawingStroke? active;
  StrokeDabber? activeDabberField;
  int revisionValue = 0;
  int nextStrokeId = 1;
  bool completedStroke = false;
  bool hasOpenedArtwork = false;

  int get revision => revisionValue;
  BrushConfig get brush => brushConfig;
  DrawingTool get tool => drawingTool;
  bool get canRedo => redoStack.isNotEmpty;
  DrawingStroke? get activeStroke => active;
  bool get canUndo => strokesList.isNotEmpty;
  bool get hasCompletedStroke => completedStroke;
  StrokeDabber? get activeDabber => activeDabberField;
  List<DrawingStroke> get strokes => UnmodifiableListView(strokesList);
  String get categoryImage {
    return stationaryTools.getCategoryImage(selectedCategory);
  }

  void openSelectedArtwork() {
    if (hasOpenedArtwork) {
      cancelStroke();
      strokesList.clear();
      redoStack.clear();
      revisionValue++;
      completedStroke = false;
      layerManager.dispose();
    }
    final page = artworkRepository.appleAndBooks();
    regionEngine = RegionEngine(page);
    layerManager = LayerManager(regionEngine: regionEngine);
    hasOpenedArtwork = true;
  }

  void selectArtwork(String id) {
    selectedArtworkId = id;
    openSelectedArtwork();
    notifyListeners();
  }

  void selectTool(StationaryModel tool) {
    selectedTool = tool;
    brushConfig = brushConfig.copyWith(
      paintColor: PaintColor(id: tool.id, color: tool.color),
    );
    notifyListeners();
  }

  void selectCategory(String name) {
    if (name == selectedCategory) return;
    final previous = stationaryTools.getToolsByCategory(selectedCategory);
    final next = stationaryTools.getToolsByCategory(name);
    selectedCategory = name;
    if (!_sameToolIds(previous, next)) {
      selectedTool = null;
    }
    notifyListeners();
  }

  void setDensity(double value) {
    density = value;
    setBrushSize(minBrushSize + value * (maxBrushSize - minBrushSize));
  }

  void selectColor(PaintColor paintColor) {
    if (paintColor.id == brushConfig.paintColor.id) return;
    brushConfig = brushConfig.copyWith(paintColor: paintColor);
    notifyListeners();
  }

  void setBrushSize(double size) {
    if (size == brushConfig.size) return;
    brushConfig = brushConfig.copyWith(size: size);
  }

  /// Starts a stroke at [point] (artwork coordinates). A touch on an outline
  /// or beside the art picks the nearest region within [pickRadius]. Returns
  /// false, and paints nothing, when no region is that close.
  bool beginStroke(Offset point, {double pickRadius = 0}) {
    active = null;
    activeDabberField = null;
    final region = regionEngine.regionAt(point, pickRadius: pickRadius);
    if (region == null) return false;
    final stroke = DrawingStroke(
      id: nextStrokeId,
      regionId: region.id,
      brush: brushConfig,
      seed: nextStrokeId,
      points: [point],
    );
    active = stroke;
    activeDabberField = drawingTool.createDabber(stroke)
      ..addPoint(point)
      ..updateTail();
    nextStrokeId++;
    activeStrokeTicks.value++;
    return true;
  }

  /// Adds a sample. Samples too close to the last stored one are not kept,
  /// but the drawn stroke still reaches them.
  void extendStroke(Offset point) {
    final current = active;
    if (current == null) return;
    if ((point - current.points.last).distance >= minSampleDistance) {
      current.points.add(point);
      activeDabberField?.addPoint(point);
    }
    activeDabberField?.updateTail(point);
    activeStrokeTicks.value++;
  }

  /// Commits the active stroke as one undo step and returns it.
  DrawingStroke? endStroke() {
    final current = active;
    if (current == null) return null;
    active = null;
    activeDabberField?.finish();
    strokesList.add(current);
    redoStack.clear();
    revisionValue++;
    completedStroke = true;
    activeStrokeTicks.value++;
    notifyListeners();
    return current;
  }

  /// Drops the active stroke without touching history.
  void cancelStroke() {
    if (active == null) return;
    active = null;
    activeDabberField = null;
    activeStrokeTicks.value++;
  }

  void undo() {
    if (!canUndo) return;
    redoStack.add(strokesList.removeLast());
    revisionValue++;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    strokesList.add(redoStack.removeLast());
    revisionValue++;
    notifyListeners();
  }

  void clearAll() {
    cancelStroke();
    if (strokesList.isEmpty && redoStack.isEmpty) return;
    strokesList.clear();
    redoStack.clear();
    revisionValue++;
    completedStroke = false;
    notifyListeners();
  }

  bool _sameToolIds(
    List<StationaryModel> previous,
    List<StationaryModel> next,
  ) {
    if (previous.length != next.length) return false;
    for (var index = 0; index < previous.length; index++) {
      if (previous[index].id != next[index].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    layerManager.dispose();
    drawingTool.dispose();
    activeStrokeTicks.dispose();
    super.dispose();
  }
}
