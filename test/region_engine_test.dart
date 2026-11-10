import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/engine/region.engine.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/artwork.repository.impl.dart';

void main() {
  final engine = RegionEngine(const ArtworkRepositoryImpl().appleAndBooks());

  String? regionAt(double x, double y) => engine.regionAt(Offset(x, y))?.id;

  test('resolves each separate part of the apple page', () {
    expect(regionAt(500, 320), 'apple_body');
    expect(regionAt(620, 142), 'apple_leaf');
    expect(regionAt(496, 140), 'apple_stem');
    expect(regionAt(720, 490), 'top_book_cover');
    expect(regionAt(478, 700), 'bookmark');
    expect(regionAt(600, 698), 'bottom_book_pages');
    expect(regionAt(213, 680), 'bottom_book_spine');
  });

  test('the apple is in front of the top book cover', () {
    expect(regionAt(450, 466), 'apple_body');
  });

  String? pickAt(double x, double y, double radius) =>
      engine.regionAt(Offset(x, y), pickRadius: radius)?.id;

  test('a touch just inside an edge picks that part', () {
    expect(regionAt(483, 150), 'apple_stem');
  });

  test('a touch on an outline picks the nearest part within the radius', () {
    expect(pickAt(478, 150, 30), 'apple_stem');
    expect(pickAt(255, 310, 30), 'apple_body');
    expect(pickAt(695, 92, 20), 'apple_leaf');
  });

  test('blank paper beyond the radius paints nothing', () {
    expect(pickAt(100, 100, 61), isNull);
    expect(pickAt(900, 900, 61), isNull);
    expect(regionAt(255, 310), isNull);
  });

  test('detail lines belong to the region they sit in', () {
    expect(regionAt(318, 318), 'apple_body');
    expect(regionAt(600, 131), 'apple_leaf');
    expect(regionAt(380, 674), 'bottom_book_pages');
    expect(regionAt(600, 716), 'bottom_book_pages');
  });

  test('clip paths exclude regions in front', () {
    final cover = engine.regionById('top_book_cover')!;
    expect(cover.path.contains(const Offset(450, 466)), isFalse);
    expect(cover.path.contains(const Offset(720, 490)), isTrue);
  });
}
