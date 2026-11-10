import 'package:flutter/material.dart';

import '../../../data/models/paint.color.dart';

abstract final class PencilColors {
  static const List<PaintColor> all = [
    PaintColor(id: 'rainbow', color: Color(0xFFFF4D4D), isRainbow: true),
    PaintColor(id: 'blue', color: Color(0xFF2F6FDB)),
    PaintColor(id: 'green', color: Color(0xFF3DB54A)),
    PaintColor(id: 'red', color: Color(0xFFE02A2A)),
    PaintColor(id: 'orange', color: Color(0xFFF7922A)),
    PaintColor(id: 'yellow', color: Color(0xFFF9DC3C)),
    PaintColor(id: 'purple', color: Color(0xFF7B2FB8)),
    PaintColor(id: 'pink', color: Color(0xFFF57AB5)),
    PaintColor(id: 'brown', color: Color(0xFF7A4A2A)),
    PaintColor(id: 'black', color: Color(0xFF2B2B2B)),
  ];

  static PaintColor get yellow => all.firstWhere((color) => color.id == 'yellow');
}
