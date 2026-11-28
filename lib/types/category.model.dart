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

  /// What the voice can say when this category is picked. One is chosen at
  /// random, so a child who picks the pencil twenty times hears variety.
  final List<String> voice;

  /// Clip in `assets/sounds/draw/` played while a stroke is drawn.
  final String drawSound;

  /// Whether [drawSound] loops for the length of the stroke. One-tap tools
  /// (bucket fill, stickers) get a single sound instead.
  final bool loopSound;

  const CategoryModel({
    required this.name,
    required this.image,
    required this.size,
    required this.imageSize,
    required this.mutedColor,
    required this.activeColor,
    required this.brushType,
    required this.voice,
    required this.drawSound,
    this.loopSound = true,
    this.grid = false,
    this.tiled = false,
  });
}
