import 'dart:ui';

import 'package:kids_drawing_flutter/types/category.model.dart';

class CategoryTools {
  String getCategoryImage(String name) {
    final categories = getCategoryList();
    for (final category in categories) {
      if (category.name == name) {
        return category.image;
      }
    }
    return categories.first.image;
  }

  List<CategoryModel> getCategoryList() {
    final List<CategoryModel> stationaryCategory = [
      CategoryModel(
        name: 'pencil',
        image: 'assets/brushes/pencil.png',
        size: 48,
        imageSize: 56,
        // light green
        mutedColor: Color(0xFFB2E6E6),
        activeColor: Color(0xFF5EC8C8),
      ),
      CategoryModel(
        name: 'marker',
        image: 'assets/brushes/paintbrush.png',
        size: 48,
        imageSize: 56,
        // light orange
        mutedColor: Color(0xFFFFE0B2),
        activeColor: Color(0xFFFFAB2E),
      ),
      CategoryModel(
        size: 48,
        name: 'glitter',
        imageSize: 56,
        image: 'assets/brushes/glitter.png',
        // image has blue color what should be mutedColor and activeColor? cursor?
        // light blue
        mutedColor: Color(0xFFB3E5FC),
        activeColor: Color(0xFF1976D2),
      ),
    ];
    return stationaryCategory;
  }
}
