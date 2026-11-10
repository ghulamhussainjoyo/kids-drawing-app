/// Shape of the brush tip images the dabs point into.
class DabTip {
  const DabTip({
    required this.pixels,
    required this.variants,
    required this.spacing,
    required this.alpha,
    required this.tipScale,
    required this.tapDabs,
  });

  /// Side of one square tip variant in the atlas image.
  final double pixels;
  final int variants;

  /// Dab spacing as a fraction of the stroke width.
  final double spacing;
  final double alpha;

  /// Tip diameter relative to the stroke width.
  final double tipScale;

  /// Dabs stamped on the spot for a tap that never moves.
  final int tapDabs;
}
