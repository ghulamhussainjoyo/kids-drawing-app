import 'dart:ui';

class StationaryModel {
  final String id;
  final String name;
  final double? size;

  final String image;
  final double imageSize;

  final List<Color> colors;

  /// Image asset the tool paints with: a pattern tile or a sticker.
  final String? texture;

  Color get color => colors.first;

  /// Paints [color], or blends through [colors] when given.
  StationaryModel({
    required this.id,
    required this.name,
    this.size,
    required this.image,
    required this.imageSize,
    required Color color,
    List<Color>? colors,
    this.texture,
  }) : colors = colors ?? [color];
}
