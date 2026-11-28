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

  /// What the voice says when this stick is picked. Most names already read
  /// well out loud, so this is only set where [name] does not.
  final String? voice;

  Color get color => colors.first;

  /// The line to speak: `sky-blue` says "sky blue".
  String get spokenName => voice ?? name.replaceAll('-', ' ');

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
    this.voice,
  }) : colors = colors ?? [color];
}
