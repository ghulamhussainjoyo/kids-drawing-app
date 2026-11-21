import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/glitter.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

class GlitterTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      GlitterModel(
        id: '1',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFF44336),
        image: 'assets/stationary/glitter/red.png',
      ),
      GlitterModel(
        id: '2',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF000000),
        image: 'assets/stationary/glitter/black.png',
      ),
      GlitterModel(
        id: '3',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF795548),
        image: 'assets/stationary/glitter/brown.png',
      ),
      GlitterModel(
        id: '4',
        imageSize: 48,
        name: 'blue',
        color: const Color(0xFF2196F3),
        image: 'assets/stationary/glitter/blue.png',
      ),
      GlitterModel(
        id: '5',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF4CAF50),
        image: 'assets/stationary/glitter/green.png',
      ),

      GlitterModel(
        id: '8',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFFF9800),
        image: 'assets/stationary/glitter/orange.png',
      ),
      GlitterModel(
        id: '9',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFEC407A),
        image: 'assets/stationary/glitter/pink.png',
      ),
      GlitterModel(
        id: '10',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF9C27B0),
        image: 'assets/stationary/glitter/purple.png',
      ),
      GlitterModel(
        id: '15',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFF9DC3C),
        image: 'assets/stationary/glitter/yellow.png',
      ),
    ];
    return tools;
  }
}
