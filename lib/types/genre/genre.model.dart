import 'dart:io';

import 'package:flutter/widgets.dart';

class GenreModel {
  final String id;
  final String name;
  final String? assetImage;
  final String? fileImage;
  final List<Color> titleFillColors;
  final Color titleOutlineColor;
  final List<String> voice;
  final List<String> ambience;

  const GenreModel({
    required this.id,
    required this.name,
    this.assetImage,
    this.fileImage,
    required this.titleFillColors,
    required this.titleOutlineColor,
    required this.voice,
    required this.ambience,
  });

  ImageProvider get imageProvider {
    if (fileImage != null && File(fileImage!).existsSync()) {
      return FileImage(File(fileImage!));
    }
    if (assetImage != null) return AssetImage(assetImage!);
    return const AssetImage('assets/gallery/coloring-arts.png');
  }
}
