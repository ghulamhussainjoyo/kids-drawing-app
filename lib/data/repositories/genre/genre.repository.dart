import 'dart:ui';

import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

class GenreRepository {
  List<GenreModel> getGenreList() {
    return const [
      GenreModel(
        id: 'coloring-arts',
        name: 'View My Coloring Arts',
        image: 'assets/gallery/coloring-arts.png',
        titleFillColors: [Color(0xFF2EC4C6)],
        titleOutlineColor: Color(0xFF0B3D3A),
      ),
      GenreModel(
        id: 'school',
        name: 'School',
        image: 'assets/gallery/school.png',
        // TODO: replace with design hex
        titleFillColors: [Color(0xFF000000)],
        titleOutlineColor: Color(0xFF000000),
      ),
      GenreModel(
        id: 'animals',
        name: 'Animals',
        image: 'assets/gallery/animals.png',
        // TODO: replace with design hex
        titleFillColors: [Color(0xFF000000)],
        titleOutlineColor: Color(0xFF000000),
      ),
      GenreModel(
        id: 'music',
        name: 'Music',
        image: 'assets/gallery/music.png',
        // TODO: replace with design hex
        titleFillColors: [Color(0xFF000000)],
        titleOutlineColor: Color(0xFF000000),
      ),
      GenreModel(
        id: 'transport',
        name: 'Transport',
        image: 'assets/gallery/transport.png',
        titleFillColors: [Color(0xFFFFE566), Color(0xFFF0A020)],
        titleOutlineColor: Color(0xFF5C3A1E),
      ),
      GenreModel(
        id: 'seasons',
        name: 'Seasons',
        image: 'assets/gallery/seasons.png',
        // TODO: replace with design hex
        titleFillColors: [Color(0xFF000000)],
        titleOutlineColor: Color(0xFF000000),
      ),
      GenreModel(
        id: 'princes',
        name: 'Princes',
        image: 'assets/gallery/princes.png',
        // TODO: replace with design hex
        titleFillColors: [Color(0xFF000000)],
        titleOutlineColor: Color(0xFF000000),
      ),
      GenreModel(
        id: 'fruit-garden',
        name: 'Fruit Garden',
        image: 'assets/gallery/fruit- garden.png',
        titleFillColors: [
          Color(0xFFFF8A3D),
          Color(0xFFFFD23F),
          Color(0xFF5FCF6B),
          Color(0xFF4B8BFF),
          Color(0xFF9B5DE5),
        ],
        titleOutlineColor: Color(0xFF1A1A2E),
      ),
    ];
  }
}
