import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Color balls, shown in a grid. Colors are sampled from each image.
class ColorBallTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'rainbow',
        imageSize: 48,
        color: const Color(0xFFFF8F0A),
        colors: const [
          Color(0xFFFF8F0A),
          Color(0xFFFFDA21),
          Color(0xFF44CC69),
          Color(0xFF24CAE8),
          Color(0xFF3A63FC),
          Color(0xFF8F3CD7),
        ],
        image: 'assets/stationary/color-balls/ball_rainbow.png',
      ),
      StationaryModel(
        id: '2',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFFF95B8),
        image: 'assets/stationary/color-balls/ball_pink.png',
      ),
      StationaryModel(
        id: '3',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF813AAC),
        image: 'assets/stationary/color-balls/ball_purple.png',
      ),
      StationaryModel(
        id: '4',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFE33B35),
        image: 'assets/stationary/color-balls/ball_red.png',
      ),
      StationaryModel(
        id: '5',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFFF900D),
        image: 'assets/stationary/color-balls/ball_orange.png',
      ),
      StationaryModel(
        id: '6',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFFFDB45),
        image: 'assets/stationary/color-balls/ball_yellow.png',
      ),
      StationaryModel(
        id: '7',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF47AE53),
        image: 'assets/stationary/color-balls/ball_green.png',
      ),
      StationaryModel(
        id: '8',
        name: 'blue',
        imageSize: 48,
        color: const Color(0xFF2D60D8),
        image: 'assets/stationary/color-balls/ball_blue.png',
      ),
      StationaryModel(
        id: '9',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF865943),
        image: 'assets/stationary/color-balls/ball_brown.png',
      ),
      StationaryModel(
        id: '10',
        name: 'black',
        imageSize: 48,
        color: const Color(0xFF313236),
        image: 'assets/stationary/color-balls/ball_black.png',
      ),
      StationaryModel(
        id: '11',
        name: 'sky-blue',
        imageSize: 48,
        color: const Color(0xFF3DB5E5),
        image: 'assets/stationary/color-balls/ball_sky-blue.png',
      ),
      StationaryModel(
        id: '12',
        name: 'violet',
        imageSize: 48,
        color: const Color(0xFFA049D8),
        image: 'assets/stationary/color-balls/ball_violet.png',
      ),
      StationaryModel(
        id: '13',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFF5F4EF),
        image: 'assets/stationary/color-balls/ball_white.png',
      ),
      StationaryModel(
        id: '14',
        name: 'pastel-rainbow',
        imageSize: 48,
        color: const Color(0xFFE6F5BC),
        colors: const [
          Color(0xFFE6F5BC),
          Color(0xFFD0F8CC),
          Color(0xFFC5EDE1),
          Color(0xFFB8D7EA),
        ],
        image: 'assets/stationary/color-balls/ball_pastel-rainbow.png',
      ),
      StationaryModel(
        id: '15',
        name: 'vivid-rainbow',
        imageSize: 48,
        color: const Color(0xFFFFE40A),
        colors: const [
          Color(0xFFFFE40A),
          Color(0xFFCDEB3A),
          Color(0xFF7EE475),
          Color(0xFF4BD2A7),
          Color(0xFF39B2D9),
          Color(0xFF4992F5),
          Color(0xFF6A75E0),
        ],
        image: 'assets/stationary/color-balls/ball_vivid-rainbow.png',
      ),
      StationaryModel(
        id: '16',
        name: 'sunset',
        imageSize: 48,
        color: const Color(0xFFEF3B69),
        colors: const [
          Color(0xFFEF3B69),
          Color(0xFFFE536D),
          Color(0xFFFF5449),
          Color(0xFFF06840),
        ],
        image: 'assets/stationary/color-balls/ball_sunset.png',
      ),
      StationaryModel(
        id: '17',
        name: 'ocean',
        imageSize: 48,
        color: const Color(0xFF317DEF),
        colors: const [
          Color(0xFF317DEF),
          Color(0xFF4799FE),
          Color(0xFF5BAEFC),
        ],
        image: 'assets/stationary/color-balls/ball_ocean.png',
      ),
      StationaryModel(
        id: '18',
        name: 'galaxy',
        imageSize: 48,
        color: const Color(0xFF452B86),
        colors: const [
          Color(0xFF452B86),
          Color(0xFF5F42A5),
          Color(0xFF6848B1),
        ],
        image: 'assets/stationary/color-balls/ball_galaxy.png',
      ),
      StationaryModel(
        id: '19',
        name: 'pearl',
        imageSize: 48,
        color: const Color(0xFFD8D7F6),
        image: 'assets/stationary/color-balls/ball_pearl.png',
      ),
      StationaryModel(
        id: '20',
        name: 'candy',
        imageSize: 48,
        color: const Color(0xFFFF92BC),
        colors: const [
          Color(0xFFFF92BC),
          Color(0xFFFFA9CA),
          Color(0xFFF0ABB2),
        ],
        image: 'assets/stationary/color-balls/ball_candy.png',
      ),
    ];
    return tools;
  }
}
