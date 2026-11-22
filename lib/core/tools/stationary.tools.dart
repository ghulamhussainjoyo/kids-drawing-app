import 'package:kids_drawing_flutter/core/tools/brush.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/bucket.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/crayon.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/glitter.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/marker.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/pattern.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/spray.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/sticker.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/texture.library.dart';
import 'package:kids_drawing_flutter/core/tools/watercolor.drawing.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/brush.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/category.tool.stationary.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/color.balls.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/crayon.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/glitter.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/letters.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/marker.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/pencil.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/spray.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/tape.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/watercolor.tool.dart';
import 'package:kids_drawing_flutter/types/brush.type.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Stationary catalogs per category, plus the long-lived paint engines that
/// draw with them.
class StationaryTools {
  final _categoryTools = CategoryTools();
  final String selectedCategory = 'pencil';

  /// Pattern tiles and sticker images the engines paint with.
  final textures = TextureLibrary();

  /// Paint engines, created the first time a stroke needs one.
  final Map<BrushType, DrawingTool> _engines = {};

  late final Map<BrushType, DrawingTool Function()> _newEngine = {
    BrushType.pencil: PencilTool.new,
    BrushType.marker: MarkerTool.new,
    BrushType.glitter: GlitterTool.new,
    BrushType.crayon: CrayonTool.new,
    BrushType.paintbrush: BrushTool.new,
    BrushType.watercolor: WatercolorTool.new,
    BrushType.spray: SprayTool.new,
    BrushType.bucket: BucketTool.new,
    BrushType.pattern: () => PatternTool(textures),
    BrushType.sticker: () => StickerTool(textures),
  };

  Map<String, List<StationaryModel>> getToolsCategory() {
    final lists = {
      'pencil': PencilTools().getLists(),
      'marker': MarkerTools().getLists(),
      'glitter': GlitterTools().getLists(),
      'brush': BrushTools().getLists(),
      'crayon': CrayonTools().getLists(),
      'spray': SprayTools().getLists(),
      'watercolor': WatercolorTools().getLists(),
      'color-balls': ColorBallTools().getLists(),
      'tape': TapeTools().getLists(),
      'letters': LetterTools().getLists(),
    };
    return lists;
  }

  List<StationaryModel> getToolsByCategory(String key) {
    final currentTools = getToolsCategory();
    return currentTools[key] ?? [];
  }

  List<CategoryModel> getCategoryList() {
    return _categoryTools.getCategoryList();
  }

  CategoryModel getCategory(String name) {
    return _categoryTools.getCategory(name);
  }

  String getCategoryImage(String name) {
    return _categoryTools.getCategoryImage(name);
  }

  /// Paint engine for a stroke's brush type. Types without their own engine
  /// yet paint as pencil.
  DrawingTool toolFor(BrushType type) {
    return _engines.putIfAbsent(type, () {
      final create = _newEngine[type] ?? _newEngine[BrushType.pencil]!;
      return create();
    });
  }

  /// Loads the image a tool paints with, before its first stroke.
  Future<void> preload(String? texture) => textures.load(texture);

  DrawingTool toolForCategory(String name) {
    return toolFor(getCategory(name).brushType);
  }

  void dispose() {
    for (final engine in _engines.values) {
      engine.dispose();
    }
    textures.dispose();
  }
}
