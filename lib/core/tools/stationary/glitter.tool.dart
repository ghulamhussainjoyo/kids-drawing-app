import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/glitter.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Glitter tubes. Each paint color is sampled from the glitter in its tube
/// image, so the stroke matches the tube.
class GlitterTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      GlitterModel(
        id: '1',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFF8D0510),
        image: 'assets/stationary/glitter/red.png',
      ),
      GlitterModel(
        id: '2',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF111216),
        image: 'assets/stationary/glitter/black.png',
      ),
      GlitterModel(
        id: '3',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF6C3413),
        image: 'assets/stationary/glitter/brown.png',
      ),
      GlitterModel(
        id: '4',
        imageSize: 48,
        name: 'blue',
        color: const Color(0xFF0176D1),
        image: 'assets/stationary/glitter/blue.png',
      ),
      GlitterModel(
        id: '5',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF038D23),
        image: 'assets/stationary/glitter/green.png',
      ),

      GlitterModel(
        id: '8',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFDF5001),
        image: 'assets/stationary/glitter/orange.png',
      ),
      GlitterModel(
        id: '9',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFE10F93),
        image: 'assets/stationary/glitter/pink.png',
      ),
      GlitterModel(
        id: '10',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF780BB1),
        image: 'assets/stationary/glitter/purple.png',
      ),
      GlitterModel(
        id: '15',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFD9A507),
        image: 'assets/stationary/glitter/yellow.png',
      ),
    ];
    return tools;
  }
}
