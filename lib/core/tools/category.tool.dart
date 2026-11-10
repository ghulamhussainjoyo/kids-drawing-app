import 'dart:ui';

import 'package:kids_drawing_flutter/core/type/category.model.dart';

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
        image: 'assets/brushes/paintbrush.png',
        size: 48,
        imageSize: 56,
        mutedColor: Color(0xFF7BD2D2),
        activeColor: Color(0xFF5EC8C8),
      ),
      CategoryModel(
        name: 'marker',
        image: 'assets/brushes/paintbrush.png',
        size: 48,
        imageSize: 56,
        mutedColor: Color(0xFFFFAB2E),
        activeColor: Color(0xFFFF9800),
      ),
      CategoryModel(
        size: 48,
        name: 'brush',
        imageSize: 56,
        image: 'assets/brushes/paintbrush.png',
        mutedColor: Color(0xFF9359E6),
        activeColor: Color(0xFF7B35E0),
      ),
    ];
    return stationaryCategory;
  }
}
