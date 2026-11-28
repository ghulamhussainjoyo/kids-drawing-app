import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Washi tapes. Each paints the tape's main color.
class TapeTools {
  List<StationaryModel> getLists() {
    List<StationaryModel> tools = [
      StationaryModel(
        id: '1',
        name: 'bears',
        voice: 'Bear tape',
        imageSize: 48,
        color: const Color(0xFFAB8EE6),
        image: 'assets/stationary/tape/tape_bears.png',
        texture: 'assets/stationary/tape/patterns/tile_bears.png',
      ),
      StationaryModel(
        id: '2',
        name: 'bunnies',
        voice: 'Bunny tape',
        imageSize: 48,
        color: const Color(0xFF6CC28D),
        image: 'assets/stationary/tape/tape_bunnies.png',
        texture: 'assets/stationary/tape/patterns/tile_bunnies.png',
      ),
      StationaryModel(
        id: '3',
        name: 'cats',
        voice: 'Cat tape',
        imageSize: 48,
        color: const Color(0xFFFFCC4D),
        image: 'assets/stationary/tape/tape_cats.png',
        texture: 'assets/stationary/tape/patterns/tile_cats.png',
      ),
      StationaryModel(
        id: '4',
        name: 'chicks',
        voice: 'Chick tape',
        imageSize: 48,
        color: const Color(0xFF73C6F5),
        image: 'assets/stationary/tape/tape_chicks.png',
        texture: 'assets/stationary/tape/patterns/tile_chicks.png',
      ),
      StationaryModel(
        id: '5',
        name: 'dogs',
        voice: 'Dog tape',
        imageSize: 48,
        color: const Color(0xFF4EC3DC),
        image: 'assets/stationary/tape/tape_dogs.png',
        texture: 'assets/stationary/tape/patterns/tile_dogs.png',
      ),
      StationaryModel(
        id: '6',
        name: 'leopard',
        voice: 'Leopard tape',
        imageSize: 48,
        color: const Color(0xFFF5C463),
        image: 'assets/stationary/tape/tape_leopard.png',
        texture: 'assets/stationary/tape/patterns/tile_leopard.png',
      ),
      StationaryModel(
        id: '7',
        name: 'pandas',
        voice: 'Panda tape',
        imageSize: 48,
        color: const Color(0xFFFF8C75),
        image: 'assets/stationary/tape/tape_pandas.png',
        texture: 'assets/stationary/tape/patterns/tile_pandas.png',
      ),
      StationaryModel(
        id: '8',
        name: 'paws',
        voice: 'Paw tape',
        imageSize: 48,
        color: const Color(0xFFA991E6),
        image: 'assets/stationary/tape/tape_paws.png',
        texture: 'assets/stationary/tape/patterns/tile_paws.png',
      ),
      StationaryModel(
        id: '9',
        name: 'penguins',
        voice: 'Penguin tape',
        imageSize: 48,
        color: const Color(0xFFFFB84D),
        image: 'assets/stationary/tape/tape_penguins.png',
        texture: 'assets/stationary/tape/patterns/tile_penguins.png',
      ),
      StationaryModel(
        id: '10',
        name: 'rainbow',
        voice: 'Rainbow tape',
        imageSize: 48,
        color: const Color(0xFF73C6F5),
        image: 'assets/stationary/tape/tape_rainbow.png',
        texture: 'assets/stationary/tape/patterns/tile_rainbow.png',
      ),
      StationaryModel(
        id: '11',
        name: 'zebra',
        voice: 'Zebra tape',
        imageSize: 48,
        color: const Color(0xFF8C8A80),
        image: 'assets/stationary/tape/tape_zebra.png',
        texture: 'assets/stationary/tape/patterns/tile_zebra.png',
      ),
    ];
    return tools;
  }
}
