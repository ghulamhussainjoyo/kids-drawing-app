import 'package:flutter/widgets.dart';

abstract class StationaryModel {
  final String id;
  final String name;
  final double? size;

  final String image;
  final double imageSize;

  /// Paint colors. One entry paints solid, more blend along the stroke.
  final List<Color> colors;

  Color get color => colors.first;

  const StationaryModel({
    required this.id,
    required this.name,
    required this.size,
    required this.image,
    required this.imageSize,
    required this.colors,
  });
}
