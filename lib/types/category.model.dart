import 'dart:ui';

import 'package:kids_drawing_flutter/types/brush.type.dart';

class CategoryModel {
  final String name;
  final String image;
  final double size;
  final double imageSize;
  final Color mutedColor;
  final Color activeColor;

  /// Paint engine used by this category's tools.
  final BrushType brushType;

  /// Shows the tools in a 2-column grid instead of the stick list.
  final bool grid;

  /// Puts each grid item on a rounded tile.
  final bool tiled;

  const CategoryModel({
    required this.name,
    required this.image,
    required this.size,
    required this.imageSize,
    required this.mutedColor,
    required this.activeColor,
    required this.brushType,
    this.grid = false,
    this.tiled = false,
  });
}
