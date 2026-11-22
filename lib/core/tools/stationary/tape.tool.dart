import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Washi tapes. Each paints the tape's main color.
class TapeTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'bears',
        imageSize: 48,
        color: const Color(0xFFAB8EE6),
        image: 'assets/stationary/tape/tape_bears.png',
        texture: 'assets/stationary/tape/patterns/tile_bears.png',
      ),
      StationaryModel(
        id: '2',
        name: 'bunnies',
        imageSize: 48,
        color: const Color(0xFF6CC28D),
        image: 'assets/stationary/tape/tape_bunnies.png',
        texture: 'assets/stationary/tape/patterns/tile_bunnies.png',
      ),
      StationaryModel(
        id: '3',
        name: 'cats',
        imageSize: 48,
        color: const Color(0xFFFFCC4D),
        image: 'assets/stationary/tape/tape_cats.png',
        texture: 'assets/stationary/tape/patterns/tile_cats.png',
      ),
      StationaryModel(
        id: '4',
        name: 'chicks',
        imageSize: 48,
        color: const Color(0xFF73C6F5),
        image: 'assets/stationary/tape/tape_chicks.png',
        texture: 'assets/stationary/tape/patterns/tile_chicks.png',
      ),
      StationaryModel(
        id: '5',
        name: 'dogs',
        imageSize: 48,
        color: const Color(0xFF4EC3DC),
        image: 'assets/stationary/tape/tape_dogs.png',
        texture: 'assets/stationary/tape/patterns/tile_dogs.png',
      ),
      StationaryModel(
        id: '6',
        name: 'leopard',
        imageSize: 48,
        color: const Color(0xFFF5C463),
        image: 'assets/stationary/tape/tape_leopard.png',
        texture: 'assets/stationary/tape/patterns/tile_leopard.png',
      ),
      StationaryModel(
        id: '7',
        name: 'pandas',
        imageSize: 48,
        color: const Color(0xFFFF8C75),
        image: 'assets/stationary/tape/tape_pandas.png',
        texture: 'assets/stationary/tape/patterns/tile_pandas.png',
      ),
      StationaryModel(
        id: '8',
        name: 'paws',
        imageSize: 48,
        color: const Color(0xFFA991E6),
        image: 'assets/stationary/tape/tape_paws.png',
        texture: 'assets/stationary/tape/patterns/tile_paws.png',
      ),
      StationaryModel(
        id: '9',
        name: 'penguins',
        imageSize: 48,
        color: const Color(0xFFFFB84D),
        image: 'assets/stationary/tape/tape_penguins.png',
        texture: 'assets/stationary/tape/patterns/tile_penguins.png',
      ),
      StationaryModel(
        id: '10',
        name: 'rainbow',
        imageSize: 48,
        color: const Color(0xFF73C6F5),
        image: 'assets/stationary/tape/tape_rainbow.png',
        texture: 'assets/stationary/tape/patterns/tile_rainbow.png',
      ),
      StationaryModel(
        id: '11',
        name: 'zebra',
        imageSize: 48,
        color: const Color(0xFF8C8A80),
        image: 'assets/stationary/tape/tape_zebra.png',
        texture: 'assets/stationary/tape/patterns/tile_zebra.png',
      ),
    ];
    return tools;
  }
}
