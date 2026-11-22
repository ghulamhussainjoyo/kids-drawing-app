import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Spray cans. Colors are sampled from each image.
class SprayTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'rainbow',
        imageSize: 48,
        color: const Color(0xFFFFA003),
        colors: const [
          Color(0xFFFFA003),
          Color(0xFFF6D40E),
          Color(0xFF4BC950),
          Color(0xFF24C8C0),
          Color(0xFF288AF5),
          Color(0xFF5648F3),
        ],
        image: 'assets/stationary/spray/spray_rainbow.png',
      ),
      StationaryModel(
        id: '2',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFD31735),
        image: 'assets/stationary/spray/spray_red.png',
      ),
      StationaryModel(
        id: '3',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFF57C00),
        image: 'assets/stationary/spray/spray_orange.png',
      ),
      StationaryModel(
        id: '4',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFF2C400),
        image: 'assets/stationary/spray/spray_yellow.png',
      ),
      StationaryModel(
        id: '5',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF1FA338),
        image: 'assets/stationary/spray/spray_green.png',
      ),
      StationaryModel(
        id: '6',
        name: 'sky-blue',
        imageSize: 48,
        color: const Color(0xFF33B1E4),
        image: 'assets/stationary/spray/spray_sky-blue.png',
      ),
      StationaryModel(
        id: '7',
        name: 'blue',
        imageSize: 48,
        color: const Color(0xFF1565D8),
        image: 'assets/stationary/spray/spray_blue.png',
      ),
      StationaryModel(
        id: '8',
        name: 'violet',
        imageSize: 48,
        color: const Color(0xFF9B3FD6),
        image: 'assets/stationary/spray/spray_violet.png',
      ),
      StationaryModel(
        id: '9',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF7A41AF),
        image: 'assets/stationary/spray/spray_purple.png',
      ),
      StationaryModel(
        id: '10',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFF03C9E),
        image: 'assets/stationary/spray/spray_pink.png',
      ),
      StationaryModel(
        id: '11',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF7E4320),
        image: 'assets/stationary/spray/spray_brown.png',
      ),
      StationaryModel(
        id: '12',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF2D2F32),
        image: 'assets/stationary/spray/spray_black.png',
      ),
      StationaryModel(
        id: '13',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFEFEEE6),
        image: 'assets/stationary/spray/spray_white.png',
      ),
    ];
    return tools;
  }
}
