import 'dart:ui';

import 'stationary.model.dart';

class GlitterModel extends StationaryModel {
  /// A glitter tube that paints [color], or blends along the stroke through
  /// [colors] when given (e.g. a rainbow tube).
  GlitterModel({
    super.size,
    required super.id,
    required super.name,
    required Color color,
    required super.image,
    required super.imageSize,
    List<Color>? colors,
  }) : super(colors: colors ?? [color]);
}
