import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Crayons. Colors are sampled from each image.
class CrayonTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'rainbow',
        imageSize: 48,
        color: const Color(0xFFFE840E),
        colors: const [
          Color(0xFFFE840E),
          Color(0xFFFEC10E),
          Color(0xFF93CD3A),
          Color(0xFF32C78B),
          Color(0xFF26B7E9),
          Color(0xFF3563FB),
        ],
        image: 'assets/stationary/crayon/crayon_rainbow.png',
      ),
      StationaryModel(
        id: '2',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFD31C3A),
        image: 'assets/stationary/crayon/crayon_red.png',
      ),
      StationaryModel(
        id: '3',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFF47E06),
        image: 'assets/stationary/crayon/crayon_orange.png',
      ),
      StationaryModel(
        id: '4',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFF1C406),
        image: 'assets/stationary/crayon/crayon_yellow.png',
      ),
      StationaryModel(
        id: '5',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF24A43D),
        image: 'assets/stationary/crayon/crayon_green.png',
      ),
      StationaryModel(
        id: '6',
        name: 'sky-blue',
        imageSize: 48,
        color: const Color(0xFF38B2E4),
        image: 'assets/stationary/crayon/crayon_sky-blue.png',
      ),
      StationaryModel(
        id: '7',
        name: 'blue',
        imageSize: 48,
        color: const Color(0xFF1B68D8),
        image: 'assets/stationary/crayon/crayon_blue.png',
      ),
      StationaryModel(
        id: '8',
        name: 'violet',
        imageSize: 48,
        color: const Color(0xFF9C44D6),
        image: 'assets/stationary/crayon/crayon_violet.png',
      ),
      StationaryModel(
        id: '9',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF7C45B0),
        image: 'assets/stationary/crayon/crayon_purple.png',
      ),
      StationaryModel(
        id: '10',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFEF419F),
        image: 'assets/stationary/crayon/crayon_pink.png',
      ),
      StationaryModel(
        id: '11',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF804725),
        image: 'assets/stationary/crayon/crayon_brown.png',
      ),
      StationaryModel(
        id: '12',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF323437),
        image: 'assets/stationary/crayon/crayon_black.png',
      ),
      StationaryModel(
        id: '13',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFEEEDE6),
        image: 'assets/stationary/crayon/crayon_white.png',
      ),
    ];
    return tools;
  }
}
