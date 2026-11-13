import 'dart:ui';

import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

class GenreRepository {
  List<GenreModel> getGenreList() {
    return const [
      GenreModel(
        id: 'coloring-arts',
        name: 'View My Coloring Arts',
        image: 'assets/gallery/coloring-arts.png',
        // Cyan sky / crayon
        titleFillColors: [Color(0xFF2EC4C6)],
        titleOutlineColor: Color(0xFF0B3D3A),
      ),
      GenreModel(
        id: 'school',
        name: 'School',
        image: 'assets/gallery/school.png',
        // Blue book
        titleFillColors: [Color(0xFF3B82F6)],
        titleOutlineColor: Color(0xFF0F172A),
      ),
      GenreModel(
        id: 'animals',
        name: 'Animals',
        image: 'assets/gallery/animals.png',
        // Grass → sky (not warm yellow like transport)
        titleFillColors: [Color(0xFF5FCF6B), Color(0xFF4FC3F7)],
        titleOutlineColor: Color(0xFF14352A),
      ),
      GenreModel(
        id: 'music',
        name: 'Music',
        image: 'assets/gallery/music.png',
        // Guitar gold → note purple
        titleFillColors: [Color(0xFFFFD54F), Color(0xFF7C3AED)],
        titleOutlineColor: Color(0xFF2E1065),
      ),
      GenreModel(
        id: 'transport',
        name: 'Transport',
        image: 'assets/gallery/transport.png',
        // Bus yellow → sun orange
        titleFillColors: [Color(0xFFFFE566), Color(0xFFF0A020)],
        titleOutlineColor: Color(0xFF5C3A1E),
      ),
      GenreModel(
        id: 'seasons',
        name: 'Seasons',
        image: 'assets/gallery/seasons.png',
        // Ice → blossom → leaf → berry
        titleFillColors: [
          Color(0xFF81D4FA),
          Color(0xFFF8BBD0),
          Color(0xFF81C784),
          Color(0xFFEF5350),
        ],
        titleOutlineColor: Color(0xFF1A237E),
      ),
      GenreModel(
        id: 'princes',
        name: 'Princesses',
        image: 'assets/gallery/princes.png',
        // Castle rose
        titleFillColors: [Color(0xFFFF4D94)],
        titleOutlineColor: Color(0xFF5B0E3D),
      ),
      GenreModel(
        id: 'fruit-garden',
        name: 'Fruit Garden',
        image: 'assets/gallery/fruit- garden.png',
        // Fruit rainbow
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
