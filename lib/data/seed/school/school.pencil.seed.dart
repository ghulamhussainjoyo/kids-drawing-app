import 'package:kids_drawing_flutter/data/seed/artwork.seed.entry.dart';

class SchoolPencilSeed {
  const SchoolPencilSeed();

  ArtworkSeedEntry get entry => const ArtworkSeedEntry(
    artworkKey: 'pencil',
    genre: 'school',
    title: 'Pencil',
    isPremium: false,
    templateJson: _templateJson,
  );

  static const _templateJson = '''
{
  "id": "pencil",
  "name": "Pencil",
  "genre": "school",
  "difficulty": "easy",
  "viewBox": "0 0 512 512",
  "background": "#FFFFFF",
  "regions": [
    {
      "id": "pencil_body",
      "path": "M175 135 L300 135 L300 365 L237.5 455 L175 365 Z",
      "fill": "#FFFFFF",
      "colorable": true
    },
    {
      "id": "eraser",
      "path": "M175 100 L175 75 Q175 55 195 55 L280 55 Q300 55 300 75 L300 100 Z",
      "fill": "#FFFFFF",
      "colorable": true
    },
    {
      "id": "pencil_tip",
      "path": "M175 365 L237.5 455 L300 365 Z",
      "fill": "#FFFFFF",
      "colorable": true
    },
    {
      "id": "graphite",
      "path": "M222 433 L237.5 455 L253 433 Z",
      "fill": "#FFFFFF",
      "colorable": true
    }
  ],
  "lines": [
    {
      "id": "ferrule_line_1",
      "path": "M175 115 L300 115"
    },
    {
      "id": "ferrule_line_2",
      "path": "M175 135 L300 135"
    }
  ],
  "outline": {
    "color": "#000000",
    "strokeWidth": 8,
    "lineCap": "round",
    "lineJoin": "round"
  }
}
''';
}
