import 'dart:math' as math;
import 'dart:ui';

import 'notch.side.dart';

/// Converts the screen size into Figma-frame units and the page slot.
///
/// Backgrounds run edge to edge. The notch sits in the middle of a landscape
/// edge, so on the left only the badge and slider (the middle band) keep
/// clear of it while the corner buttons stay put; on the right the whole tool
/// column moves inward. Controls never shrink below [minControlSize] so
/// they stay comfortable for small fingers on phones. The page hugs the done
/// and settings buttons; any extra width opens up between the left controls
/// and the page.
class DrawingWorkspaceLayout {
  DrawingWorkspaceLayout(
    Size size, {
    required NotchSide notchSide,
    required double notchInset,
  })  : unit = size.height / 924,
        _size = size,
        leftInset = notchSide == NotchSide.left ? notchInset : 0,
        rightInset = notchSide == NotchSide.right ? notchInset : 0;

  static const double minControlSize = 48;
  static const double minBadgeSize = 60;

  /// Keeps the first and last list items clear of the rounded screen corners.
  static const double listEndPadding = 24;

  final Size _size;
  final double unit;
  final double leftInset;
  final double rightInset;

  double get edgeMargin => 33 * unit;
  double get controlSize => math.max(104 * unit, minControlSize);
  double get controlGap => math.max(29 * unit, 12);
  double get badgeSize => math.max(132 * unit, minBadgeSize);
  Size get sliderSize => Size(130, 348) * (controlSize / 104);

  double get leftColumnLeft => edgeMargin;
  double get _buttonPairWidth => 2 * controlSize + controlGap;

  /// Center of the badge and slider, from the column's left edge. They sit in
  /// the middle of the back/palette pair, moving right only to clear a notch.
  double get _stackWidth => math.max(badgeSize, sliderSize.width);

  double get toolStackCenter => math.max(
        _buttonPairWidth / 2,
        leftInset - leftColumnLeft + _stackWidth / 2,
      );

  double get leftColumnWidth =>
      math.max(_buttonPairWidth, toolStackCenter + _stackWidth / 2);

  double get tileSize => math.max(104 * unit, minControlSize);
  double get tileItemExtent => tileSize * 142 / 104;

  double get railWidth => 262 * unit;
  double get toolColumnWidth => tileSize + 51 * unit + rightInset;
  double get drawingAreaWidth => _size.width - railWidth - toolColumnWidth;

  /// Gap kept between the page and the done/settings buttons beside it.
  double get _pageButtonGap => 24;

  /// The page keeps [edgeMargin] clear of the left controls. On the right it
  /// reserves only the room the done and settings buttons need, so the page
  /// sits beside those buttons instead of being pushed into the left tools.
  double get _leftReserve => leftColumnLeft + leftColumnWidth + edgeMargin;
  double get _rightReserve => _pageButtonGap + controlSize + edgeMargin;

  double get pageControlsLeft => pageRect.right + _pageButtonGap;

  Rect get pageRect {
    final maxSide = math.min(_size.height - 2 * edgeMargin, 857 * unit);
    final available = drawingAreaWidth - _leftReserve - _rightReserve;
    final side = math.min(maxSide, math.max(0.0, available));
    final left = math.max(
      _leftReserve,
      drawingAreaWidth - _rightReserve - side,
    );
    final top = (_size.height - side) / 2;
    return Rect.fromLTWH(left, top, side, side);
  }
}
