import 'package:kids_drawing_flutter/core/tools/category.tool.dart';
import 'package:kids_drawing_flutter/core/tools/marker.tool.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.tool.dart';
import 'package:kids_drawing_flutter/core/type/category.model.dart';
import 'package:kids_drawing_flutter/data/models/tools/stationary.model.dart';

class StationaryTools {
  final _pencilTools = PencilTools();
  final _markerTools = MarkerTools();
  final _categoryTools = CategoryTools();
  final String selectedCategory = 'pencil';

  Map<String, List<StationaryModel>> getToolsCategory() {
    final lists = {
      'pencil': _pencilTools.getLists(),
      'marker': _markerTools.getLists(),
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

  String getCategoryImage(String name) {
    return _categoryTools.getCategoryImage(name);
  }
}
