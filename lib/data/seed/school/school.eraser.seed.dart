import 'package:kids_drawing_flutter/data/seed/artwork.seed.entry.dart';

class SchoolEraserSeed {
  const SchoolEraserSeed();

  ArtworkSeedEntry get entry => const ArtworkSeedEntry(
    artworkKey: 'eraser',
    genre: 'school',
    title: 'Eraser',
    isPremium: true,
    templateJson: _templateJson,
  );

  static const _templateJson = '''
{
  "id": "eraser",
  "name": "Eraser",
  "genre": "school",
  "difficulty": "easy",
  "viewBox": "0 0 512 512",
  "background": "#FFFFFF",
  "regions": [
    {
      "id": "eraser_left",
      "path": "M133 175 H285 V337 H133 Q105 337 105 309 V203 Q105 175 133 175 Z",
      "fill": "#FFFFFF",
      "colorable": true
    },
    {
      "id": "eraser_right",
      "path": "M285 175 H379 Q407 175 407 203 V309 Q407 337 379 337 H285 Z",
      "fill": "#FFFFFF",
      "colorable": true
    }
  ],
  "lines": [
    {
      "id": "eraser_division",
      "path": "M285 177 L285 335"
    }
  ],
  "outline": {
    "color": "#000000",
    "strokeWidth": 9,
    "lineCap": "round",
    "lineJoin": "round"
  }
}
''';
}
