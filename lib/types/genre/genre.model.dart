import 'dart:ui';

class GenreModel {
  final String id;
  final String name;
  final String image;
  final List<Color> titleFillColors;
  final Color titleOutlineColor;

  const GenreModel({
    required this.id,
    required this.name,
    required this.image,
    required this.titleFillColors,
    required this.titleOutlineColor,
  });
}
