import 'dart:ui';

import 'package:kids_drawing_flutter/types/brush.type.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';

class CategoryTools {
  CategoryModel getCategory(String name) {
    final categories = getCategoryList();
    for (final category in categories) {
      if (category.name == name) {
        return category;
      }
    }
    return categories.first;
  }

  String getCategoryImage(String name) {
    return getCategory(name).image;
  }

  List<CategoryModel> getCategoryList() {
    final List<CategoryModel> stationaryCategory = [
      CategoryModel(
        name: 'pencil',
        image: 'assets/brushes/pencil.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.pencil,
        // light green
        mutedColor: Color(0xFFB2E6E6),
        activeColor: Color(0xFF5EC8C8),
      ),
      CategoryModel(
        name: 'marker',
        image: 'assets/brushes/paintbrush.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.marker,
        // light orange
        mutedColor: Color(0xFFFFE0B2),
        activeColor: Color(0xFFFFAB2E),
      ),
      CategoryModel(
        size: 48,
        name: 'glitter',
        imageSize: 56,
        image: 'assets/brushes/glitter.png',
        brushType: BrushType.glitter,
        // light blue
        mutedColor: Color(0xFFB3E5FC),
        activeColor: Color(0xFF1976D2),
      ),
      CategoryModel(
        name: 'brush',
        image: 'assets/stationary/brush/brush_rainbow.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.paintbrush,
        // light teal
        mutedColor: Color(0xFFB2EBE4),
        activeColor: Color(0xFF26B5A6),
      ),
      CategoryModel(
        name: 'crayon',
        image: 'assets/stationary/crayon/crayon_rainbow.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.crayon,
        // light yellow
        mutedColor: Color(0xFFFFF1B8),
        activeColor: Color(0xFFF2C400),
      ),
      CategoryModel(
        name: 'spray',
        image: 'assets/stationary/spray/spray_rainbow.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.spray,
        // light pink
        mutedColor: Color(0xFFFFD0E8),
        activeColor: Color(0xFFF03C9E),
      ),
      CategoryModel(
        name: 'watercolor',
        image: 'assets/stationary/watercolor/watercolor_rainbow.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.watercolor,
        // light sky blue
        mutedColor: Color(0xFFC8ECFA),
        activeColor: Color(0xFF33B1E4),
      ),
      CategoryModel(
        name: 'color-balls',
        image: 'assets/stationary/color-balls/ball_rainbow.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.bucket,
        grid: true,
        // light purple
        mutedColor: Color(0xFFE3D0F5),
        activeColor: Color(0xFF9B3FD6),
      ),
      CategoryModel(
        name: 'tape',
        image: 'assets/stationary/tape/tape_bears.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.pattern,
        // light lilac
        mutedColor: Color(0xFFE6DDF8),
        activeColor: Color(0xFFAB8EE6),
      ),
      CategoryModel(
        name: 'letters',
        image: 'assets/stationary/letters/letter_A.png',
        size: 48,
        imageSize: 56,
        brushType: BrushType.sticker,
        grid: true,
        tiled: true,
        // light peach
        mutedColor: Color(0xFFFFE0C2),
        activeColor: Color(0xFFFF8A00),
      ),
    ];
    return stationaryCategory;
  }
}
