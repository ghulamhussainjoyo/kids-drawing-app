import 'dart:ui';

import 'package:kids_drawing_flutter/data/models/tools/pencil.model.dart';
import 'package:kids_drawing_flutter/data/models/tools/stationary.model.dart';

class MarkerTools {
  List<StationaryModel> getLists() {
    List<PencilModel> tools = [
      PencilModel(
        id: '1',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFF44336),
        image: 'assets/marker/red-marker.png',
      ),
      PencilModel(
        id: '2',
        name: 'green',
        imageSize: 48,
        color: const Color(0xFF00FF00),
        image: 'assets/marker/green-marker.png',
      ),
      PencilModel(
        id: '3',
        name: 'brown',
        imageSize: 48,
        color: const Color(0xFF795548),
        image: 'assets/marker/brown-marker.png',
      ),
      PencilModel(
        id: '4',
        imageSize: 48,
        name: 'grey',
        color: const Color(0xFF808080),
        image: 'assets/marker/grey-marker.png',
      ),
      PencilModel(
        id: '5',
        name: 'orange',
        imageSize: 48,
        color: const Color(0xFFFFA500),
        image: 'assets/marker/orange-marker.png',
      ),
      PencilModel(
        id: '6',
        name: 'pink',
        imageSize: 48,
        color: const Color(0xFFFFC0CB),
        image: 'assets/marker/pink-marker.png',
      ),
      PencilModel(
        id: '7',
        name: 'purple',
        imageSize: 48,
        color: const Color(0xFF800080),
        image: 'assets/marker/purple-marker.png',
      ),
      PencilModel(
        id: '8',
        name: 'red',
        imageSize: 48,
        color: const Color(0xFFF44336),
        image: 'assets/marker/red-marker.png',
      ),
      PencilModel(
        id: '9',
        name: 'sky blue',
        imageSize: 48,
        color: const Color(0xFF00BFFF),
        image: 'assets/marker/sky-blue-marker.png',
      ),
      PencilModel(
        id: '10',
        name: 'white',
        imageSize: 48,
        color: const Color(0xFFFFFFFF),
        image: 'assets/marker/white-marker.png',
      ),
      PencilModel(
        id: '11',
        name: 'yellow',
        imageSize: 48,
        color: const Color(0xFFFFD700),
        image: 'assets/marker/yellow-marker.png',
      ),
    ];
    return tools;
  }
}
