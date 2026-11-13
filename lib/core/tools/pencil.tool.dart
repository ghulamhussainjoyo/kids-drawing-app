import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/pencil.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

class PencilTools {
  List<StationaryModel> getLists() {
    List<PencilModel> tools = [
      PencilModel(
        id: '1',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFF44336),
        image: 'assets/pencil/red.png',
      ),
      PencilModel(
        id: '2',
        name: 'blue',
        imageSize: 48,
        color: const Color(0xFF2196F3),
        image: 'assets/pencil/black.png',
      ),
      PencilModel(
        id: '3',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF795548),
        image: 'assets/pencil/brown.png',
      ),
      PencilModel(
        id: '4',
        imageSize: 48,
        name: 'dark-blue',
        color: const Color(0xFF1565C0),
        image: 'assets/pencil/dark-blue.png',
      ),
      PencilModel(
        id: '5',
        name: 'dark-green',
        imageSize: 48,
        color: const Color(0xFF2E7D32),
        image: 'assets/pencil/dark-green.png',
      ),
      PencilModel(
        id: '6',
        name: 'grey',
        imageSize: 48,
        color: const Color(0xFF9E9E9E),
        image: 'assets/pencil/grey.png',
      ),
      PencilModel(
        id: '7',
        name: 'light-brown',
        imageSize: 48,
        color: const Color(0xFFBCAAA4),
        image: 'assets/pencil/light-brown.png',
      ),
      PencilModel(
        id: '8',
        name: 'peach',
        imageSize: 48,
        color: const Color(0xFFFFCCBC),
        image: 'assets/pencil/peach.png',
      ),
      PencilModel(
        id: '9',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFEC407A),
        image: 'assets/pencil/pink.png',
      ),
      PencilModel(
        id: '10',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF9C27B0),
        image: 'assets/pencil/purple.png',
      ),
      PencilModel(
        id: '11',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFF44336),
        image: 'assets/pencil/red.png',
      ),
      PencilModel(
        id: '12',
        name: 'sky-blue',
        imageSize: 48,
        color: const Color(0xFF4FC3F7),
        image: 'assets/pencil/sky-blue.png',
      ),
      PencilModel(
        id: '13',
        name: 'violet',
        imageSize: 48,
        color: const Color(0xFF7E57C2),
        image: 'assets/pencil/violet.png',
      ),
      PencilModel(
        id: '14',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFFFFFFF),
        image: 'assets/pencil/white.png',
      ),
      PencilModel(
        id: '15',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFF9DC3C),
        image: 'assets/pencil/yellow.png',
      ),
    ];
    return tools;
  }
}
