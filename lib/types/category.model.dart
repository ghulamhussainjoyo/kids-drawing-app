import 'dart:ui';

import 'brush.type.dart';

class CategoryModel {
  final String name;

  /// Icon art. Null when the icon is drawn in code.
  final String? image;
  final double size;
  final double imageSize;
  final Color mutedColor;
  final Color activeColor;

  /// Brush that strokes from this category are painted with.
  final BrushType brushType;

  const CategoryModel({
    required this.name,
    required this.size,
    required this.imageSize,
    required this.mutedColor,
    required this.activeColor,
    this.image,
    this.brushType = BrushType.pencil,
  });
}
