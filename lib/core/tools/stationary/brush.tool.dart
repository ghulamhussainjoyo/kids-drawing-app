import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Paint brushes. Colors are sampled from each image.
class BrushTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'rainbow',
        imageSize: 48,
        color: const Color(0xFFFF8F05),
        colors: const [
          Color(0xFFFF8F05),
          Color(0xFFFFCF3A),
          Color(0xFFB0D02B),
          Color(0xFF33C763),
          Color(0xFF25C8B8),
          Color(0xFF259EED),
        ],
        image: 'assets/stationary/brush/brush_rainbow.png',
      ),
      StationaryModel(
        id: '2',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFD8332B),
        image: 'assets/stationary/brush/brush_red.png',
      ),
      StationaryModel(
        id: '3',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFF08A24),
        image: 'assets/stationary/brush/brush_orange.png',
      ),
      StationaryModel(
        id: '4',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFF9D71C),
        image: 'assets/stationary/brush/brush_yellow.png',
      ),
      StationaryModel(
        id: '5',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF3FA34D),
        image: 'assets/stationary/brush/brush_green.png',
      ),
      StationaryModel(
        id: '6',
        name: 'sky-blue',
        imageSize: 48,
        color: const Color(0xFF33B1E4),
        image: 'assets/stationary/brush/brush_sky-blue.png',
      ),
      StationaryModel(
        id: '7',
        name: 'blue',
        imageSize: 48,
        color: const Color(0xFF1F55D8),
        image: 'assets/stationary/brush/brush_blue.png',
      ),
      StationaryModel(
        id: '8',
        name: 'violet',
        imageSize: 48,
        color: const Color(0xFF9B3FD6),
        image: 'assets/stationary/brush/brush_violet.png',
      ),
      StationaryModel(
        id: '9',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF6A2A9C),
        image: 'assets/stationary/brush/brush_purple.png',
      ),
      StationaryModel(
        id: '10',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFF27AA8),
        image: 'assets/stationary/brush/brush_pink.png',
      ),
      StationaryModel(
        id: '11',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF7A4A30),
        image: 'assets/stationary/brush/brush_brown.png',
      ),
      StationaryModel(
        id: '12',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF222326),
        image: 'assets/stationary/brush/brush_black.png',
      ),
      StationaryModel(
        id: '13',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFF4F3EE),
        image: 'assets/stationary/brush/brush_white.png',
      ),
    ];
    return tools;
  }
}
