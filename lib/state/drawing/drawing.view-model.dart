import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../core/engine/layer.manager.dart';
import '../../core/engine/region.engine.dart';
import '../../core/engine/stroke.dabber.dart';
import '../../core/tools/drawing.tool.dart';
import '../../core/tools/pencil.drawing.tool.dart';
import '../../core/tools/stationary.tools.dart';
import '../../data/local/artwork/artwork.thumbnail.baker.dart';
import '../../data/local/floor/artwork.entity.dart';
import '../../data/repositories/artwork/catalog.repository.dart';
import '../../types/brush.config.dart';
import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../../types/paint.color.dart';
import '../../types/tools/stationary.model.dart';

/// Drawing session state: active brush, committed strokes and history.
class DrawingViewModel extends ChangeNotifier {
  final CatalogRepository catalogRepository;
  late ArtworkThumbnailBaker thumbnailBaker;
  final StationaryTools stationaryTools = StationaryTools();

  DrawingViewModel({required this.catalogRepository}) {
    thumbnailBaker = ArtworkThumbnailBaker();
  }

  double density = 0.45;
  String? selectedArtworkId;
  ArtworkEntity? openRow;
  StationaryModel? selectedTool;
  LayerManager? layerManager;
  RegionEngine? regionEngine;
  String selectedCategory = 'pencil';
  DrawingTool drawingTool = PencilTool();

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
  Timer? _saveTimer;

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

  Future<void> selectArtwork(String artworkKey) async {
    selectedArtworkId = artworkKey;
    await openSelectedArtwork();
    notifyListeners();
  }

  Future<void> openSelectedArtwork() async {
    final artworkKey = selectedArtworkId;
    if (artworkKey == null) {
      return;
    }
    cancelStroke();
    _saveTimer?.cancel();
    if (hasOpenedArtwork) {
      strokesList.clear();
      redoStack.clear();
      revisionValue++;
      completedStroke = false;
      layerManager?.dispose();
    }

    final row = await catalogRepository.getByKey(artworkKey);
    if (row == null) {
      throw StateError('Artwork not found: $artworkKey');
    }
    openRow = row;
    final page = catalogRepository.loadTemplate(row);
    final restored = catalogRepository.loadStrokes(row);
    regionEngine = RegionEngine(page);
    layerManager = LayerManager(regionEngine: regionEngine!);
    strokesList.addAll(restored);
    nextStrokeId = _nextIdAfter(restored);
    revisionValue++;
    hasOpenedArtwork = true;
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

  bool beginStroke(Offset point, {double pickRadius = 0}) {
    final engine = regionEngine;
    if (engine == null) return false;
    active = null;
    activeDabberField = null;
    final region = engine.regionAt(point, pickRadius: pickRadius);
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
    _scheduleSave();
    return current;
  }

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
    _scheduleSave();
  }

  void redo() {
    if (!canRedo) return;
    strokesList.add(redoStack.removeLast());
    revisionValue++;
    notifyListeners();
    _scheduleSave();
  }

  void clearAll() {
    cancelStroke();
    if (strokesList.isEmpty && redoStack.isEmpty) return;
    strokesList.clear();
    redoStack.clear();
    revisionValue++;
    completedStroke = false;
    notifyListeners();
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(saveProgress(bakeThumbnail: false));
    });
  }

  /// Flushes strokes and bakes a gallery thumbnail. Call on back / pause.
  Future<void> flushSave() async {
    _saveTimer?.cancel();
    await saveProgress(bakeThumbnail: true);
  }

  Future<void> saveProgress({required bool bakeThumbnail}) async {
    final row = openRow;
    final manager = layerManager;
    if (row == null || manager == null) {
      return;
    }
    String? thumbPath = row.thumbnailPath;
    if (bakeThumbnail) {
      thumbPath = await thumbnailBaker.bake(
        layerManager: manager,
        strokes: List<DrawingStroke>.from(strokesList),
        revision: revisionValue,
        tool: drawingTool,
        genre: row.genre,
        artworkKey: row.artworkKey,
      );
    }
    await catalogRepository.saveProgress(
      row: row,
      strokes: List<DrawingStroke>.from(strokesList),
      artworkSize: manager.artwork.size,
      thumbnailPath: thumbPath,
    );
    final refreshed = await catalogRepository.getByKey(row.artworkKey);
    if (refreshed != null) {
      openRow = refreshed;
    }
  }

  int _nextIdAfter(List<DrawingStroke> strokes) {
    var maxId = 0;
    for (final stroke in strokes) {
      if (stroke.id > maxId) {
        maxId = stroke.id;
      }
    }
    return maxId + 1;
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
    _saveTimer?.cancel();
    layerManager?.dispose();
    drawingTool.dispose();
    activeStrokeTicks.dispose();
    super.dispose();
  }
}
