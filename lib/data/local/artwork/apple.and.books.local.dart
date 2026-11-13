import 'dart:ui';

import '../../../types/coloring.artwork.dart';
import '../../../types/drawing.region.dart';

/// Apple on two stacked books, authored in a 1000 x 1000 space.
class AppleAndBooksArtwork {
  const AppleAndBooksArtwork();

  ColoringArtwork build() {
    final appleBody = Path()
      ..moveTo(500, 195)
      ..cubicTo(545, 150, 650, 140, 700, 195)
      ..cubicTo(750, 250, 745, 380, 690, 440)
      ..cubicTo(655, 478, 600, 490, 560, 478)
      ..cubicTo(535, 470, 515, 465, 500, 472)
      ..cubicTo(485, 465, 465, 470, 440, 478)
      ..cubicTo(400, 490, 345, 478, 310, 440)
      ..cubicTo(255, 380, 250, 250, 300, 195)
      ..cubicTo(350, 140, 455, 150, 500, 195)
      ..close();

    final stem = Path()
      ..moveTo(490, 205)
      ..lineTo(476, 112)
      ..quadraticBezierTo(478, 90, 497, 90)
      ..quadraticBezierTo(514, 91, 513, 110)
      ..lineTo(518, 205)
      ..close();

    final leaf = Path()
      ..moveTo(516, 165)
      ..cubicTo(540, 105, 612, 78, 684, 94)
      ..cubicTo(658, 156, 592, 186, 516, 165)
      ..close();

    final topCover = Path()
      ..moveTo(235, 505)
      ..lineTo(330, 455)
      ..lineTo(790, 470)
      ..lineTo(705, 525)
      ..close();

    final topSpine = Path()
      ..moveTo(235, 505)
      ..cubicTo(195, 530, 195, 595, 235, 620)
      ..lineTo(300, 622)
      ..cubicTo(270, 600, 270, 535, 300, 508)
      ..close();

    final topPages = Path()
      ..moveTo(300, 508)
      ..lineTo(705, 525)
      ..lineTo(705, 632)
      ..lineTo(300, 622)
      ..cubicTo(270, 600, 270, 535, 300, 508)
      ..close();

    final bottomSpine = Path()
      ..moveTo(228, 622)
      ..cubicTo(188, 647, 188, 717, 228, 742)
      ..lineTo(298, 744)
      ..cubicTo(266, 722, 266, 650, 298, 624)
      ..close();

    final bottomPages = Path()
      ..moveTo(298, 624)
      ..lineTo(718, 636)
      ..lineTo(718, 756)
      ..lineTo(298, 744)
      ..cubicTo(266, 722, 266, 650, 298, 624)
      ..close();

    final bookmark = Path()
      ..moveTo(455, 652)
      ..lineTo(502, 653)
      ..lineTo(502, 792)
      ..lineTo(478, 770)
      ..lineTo(455, 792)
      ..close();

    final raw = <_RawRegion>[
      _RawRegion('apple_body', 'Apple', appleBody),
      _RawRegion('apple_stem', 'Stem', stem),
      _RawRegion('apple_leaf', 'Leaf', leaf),
      _RawRegion('bookmark', 'Bookmark', bookmark),
      _RawRegion('top_book_cover', 'Top book cover', topCover),
      _RawRegion('top_book_spine', 'Top book spine', topSpine),
      _RawRegion('top_book_pages', 'Top book pages', topPages),
      _RawRegion('bottom_book_spine', 'Bottom book spine', bottomSpine),
      _RawRegion('bottom_book_pages', 'Bottom book pages', bottomPages),
    ];

    final regions = <DrawingRegion>[];
    Path? inFront;
    for (final region in raw) {
      final visible = inFront == null
          ? region.shape
          : Path.combine(PathOperation.difference, region.shape, inFront);
      regions.add(
        DrawingRegion(id: region.id, name: region.name, path: visible),
      );
      inFront = inFront == null
          ? region.shape
          : Path.combine(PathOperation.union, inFront, region.shape);
    }

    final details = <Path>[
      Path()
        ..moveTo(318, 318)
        ..quadraticBezierTo(316, 258, 360, 222),
      Path()
        ..moveTo(534, 158)
        ..quadraticBezierTo(600, 132, 660, 104),
      Path()
        ..moveTo(318, 552)
        ..lineTo(688, 566),
      Path()
        ..moveTo(318, 584)
        ..lineTo(688, 598),
      Path()
        ..moveTo(314, 672)
        ..lineTo(444, 676),
      Path()
        ..moveTo(514, 678)
        ..lineTo(702, 684),
      Path()
        ..moveTo(314, 706)
        ..lineTo(444, 710),
      Path()
        ..moveTo(514, 712)
        ..lineTo(702, 718),
    ];

    return ColoringArtwork(
      id: 'apple_and_books',
      size: 1000,
      regions: regions,
      detailLines: details,
      outlineWidth: 14,
    );
  }
}

class _RawRegion {
  const _RawRegion(this.id, this.name, this.shape);

  final String id;
  final String name;
  final Path shape;
}
