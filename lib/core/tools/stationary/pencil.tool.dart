import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Color pencils. Colors are sampled from each image.
class PencilTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'rainbow',
        imageSize: 48,
        color: const Color(0xFFFF6B1F),
        colors: const [
          Color(0xFFFF6B1F),
          Color(0xFFFFB906),
          Color(0xFF94CE36),
          Color(0xFF2AC89F),
          Color(0xFF269CF1),
          Color(0xFF544BF5),
        ],
        image: 'assets/stationary/pencil/pencil_rainbow.png',
      ),
      StationaryModel(
        id: '2',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFD31735),
        image: 'assets/stationary/pencil/pencil_red.png',
      ),
      StationaryModel(
        id: '3',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFF57C00),
        image: 'assets/stationary/pencil/pencil_orange.png',
      ),
      StationaryModel(
        id: '4',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFF2C400),
        image: 'assets/stationary/pencil/pencil_yellow.png',
      ),
      StationaryModel(
        id: '5',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF1FA338),
        image: 'assets/stationary/pencil/pencil_green.png',
      ),
      StationaryModel(
        id: '6',
        name: 'sky-blue',
        imageSize: 48,
        color: const Color(0xFF33B1E4),
        image: 'assets/stationary/pencil/pencil_sky-blue.png',
      ),
      StationaryModel(
        id: '7',
        name: 'blue',
        imageSize: 48,
        color: const Color(0xFF1565D8),
        image: 'assets/stationary/pencil/pencil_blue.png',
      ),
      StationaryModel(
        id: '8',
        name: 'violet',
        imageSize: 48,
        color: const Color(0xFF9B3FD6),
        image: 'assets/stationary/pencil/pencil_violet.png',
      ),
      StationaryModel(
        id: '9',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF7A41AF),
        image: 'assets/stationary/pencil/pencil_purple.png',
      ),
      StationaryModel(
        id: '10',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFF03C9E),
        image: 'assets/stationary/pencil/pencil_pink.png',
      ),
      StationaryModel(
        id: '11',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF7E4320),
        image: 'assets/stationary/pencil/pencil_brown.png',
      ),
      StationaryModel(
        id: '12',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF2D2F32),
        image: 'assets/stationary/pencil/pencil_black.png',
      ),
      StationaryModel(
        id: '13',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFEFEEE6),
        image: 'assets/stationary/pencil/pencil_white.png',
      ),
    ];
    return tools;
  }
}
