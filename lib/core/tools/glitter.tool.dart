import 'dart:ui';

import 'package:kids_drawing_flutter/types/tools/pencil.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Glitter glue tubes. Each tube is pure data: its art and the color it
/// paints. Stroke colors are sampled from the glitter in each tube's image.
/// For a multi-color tube, pass `colors` and the stroke blends through them.
class GlitterTools {
  static const String _art = 'assets/stationary/glitter';

  static final List<PencilModel> pens = [
    _tube('purple', const Color(0xFF780BB1)),
    _tube('red', const Color(0xFF8D0510)),
    _tube('orange', const Color(0xFFDF5001)),
    _tube('yellow', const Color(0xFFD9A507)),
    _tube('green', const Color(0xFF038D23)),
    _tube('blue', const Color(0xFF0176D1)),
    _tube('brown', const Color(0xFF6C3413)),
    _tube('black', const Color(0xFF111216)),
    _tube('pink', const Color(0xFFE10F93)),
  ];

  static PencilModel _tube(String name, Color color) => PencilModel(
    id: 'glitter-$name',
    name: name,
    color: color,
    image: '$_art/$name.png',
    imageSize: 48,
  );

  List<StationaryModel> getLists() => pens;
}
