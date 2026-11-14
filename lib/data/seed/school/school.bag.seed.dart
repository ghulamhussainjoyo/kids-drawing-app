import 'package:kids_drawing_flutter/data/seed/artwork.seed.entry.dart';

class SchoolBagSeed {
  const SchoolBagSeed();

  ArtworkSeedEntry get entry => const ArtworkSeedEntry(
    artworkKey: 'school_bag',
    genre: 'school',
    title: 'School Bag',
    isPremium: false,
    templateJson: _templateJson,
  );

  static const _templateJson = '''
{
  "id": "school_bag",
  "name": "School Bag",
  "genre": "school",
  "difficulty": "easy",
  "viewBox": "0 0 512 512",
  "background": "#FFFFFF",
  "regions": [
    {
      "id": "left_strap",
      "path": "M155 145 C105 145 88 190 82 250 L75 355 C72 390 95 414 130 420 L155 370 Z",
      "fill": "#FFFFFF"
    },
    {
      "id": "right_strap",
      "path": "M357 145 C407 145 424 190 430 250 L437 355 C440 390 417 414 382 420 L357 370 Z",
      "fill": "#FFFFFF"
    },
    {
      "id": "handle",
      "path": "M210 125 L210 95 C210 55 235 40 256 40 C277 40 302 55 302 95 L302 125 L280 125 L280 96 C280 78 268 68 256 68 C244 68 232 78 232 96 L232 125 Z",
      "fill": "#FFFFFF"
    },
    {
      "id": "bag_body",
      "path": "M145 145 Q145 125 175 125 L337 125 Q367 125 367 155 L385 410 Q388 450 350 450 L162 450 Q124 450 127 410 Z",
      "fill": "#FFFFFF"
    },
    {
      "id": "front_pocket",
      "path": "M165 285 Q165 260 195 260 L317 260 Q347 260 347 285 L355 390 Q355 415 325 415 L187 415 Q157 415 157 390 Z",
      "fill": "#FFFFFF"
    },
    {
      "id": "star",
      "path": "M256 155 L275 190 L315 196 L286 224 L293 264 L256 245 L219 264 L226 224 L197 196 L237 190 Z",
      "fill": "#FFFFFF"
    },
    {
      "id": "zipper",
      "path": "M170 305 L342 305",
      "fill": "none",
      "colorable": false
    },
    {
      "id": "zipper_pull",
      "path": "M190 305 L200 305 L200 350 Q200 365 195 365 Q190 365 190 350 Z",
      "fill": "#FFFFFF"
    }
  ],
  "outline": {
    "color": "#000000",
    "strokeWidth": 7,
    "lineCap": "round",
    "lineJoin": "round"
  }
}
''';
}
