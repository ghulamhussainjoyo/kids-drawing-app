import 'dart:ui';

class CategoryModel {
  final String name;
  final String image;
  final double size;
  final double imageSize;
  final Color mutedColor;
  final Color activeColor;

  const CategoryModel({
    required this.name,
    required this.image,
    required this.size,
    required this.imageSize,
    required this.mutedColor,
    required this.activeColor,
  });
}
