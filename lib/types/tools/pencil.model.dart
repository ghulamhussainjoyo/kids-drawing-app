import 'dart:ui';

import 'stationary.model.dart';

class PencilModel extends StationaryModel {
  /// A stick that paints [color], or blends along the stroke through
  /// [colors] when given (e.g. a rainbow tube).
  PencilModel({
    super.size,
    required super.id,
    required super.name,
    required Color color,
    required super.image,
    required super.imageSize,
    List<Color>? colors,
  }) : super(colors: colors ?? [color]);
}
