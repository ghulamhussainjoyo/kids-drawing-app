import 'package:flutter/widgets.dart';

@immutable
class ToolsPanelMetrics {
  final double buttonSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double gap;
  final double imageSize;
  final double greenWidth;
  final double inset;
  final double slide;
  final double stickWidth;
  final double stickHeight;
  final double stickGap;

  final double contentWidth;

  final double notchInset;

  final double railWidth;
  final double totalWidth;

  const ToolsPanelMetrics._({
    required this.buttonSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.gap,
    required this.imageSize,
    required this.greenWidth,
    required this.inset,
    required this.slide,
    required this.stickWidth,
    required this.stickHeight,
    required this.stickGap,
    required this.contentWidth,
    required this.notchInset,
    required this.railWidth,
    required this.totalWidth,
  });

  factory ToolsPanelMetrics.of(
    BuildContext context, {
    required double notchInset,
  }) {
    // Sab kuch shortestSide se: same device pe rotate karne se size nahi badalta
    final shortest = MediaQuery.sizeOf(context).shortestSide;

    const buttonFactor = 0.12;
    const verticalFactor = 0.5;
    const gapFactor = 0.25;
    const stickAspect = 4.5;
    const insetFactor = 0.08;
    const slideFactor = 0.14;
    const greenFactor = 0.28;
    const imageFactor = 56 / 48;
    const stickGapFactor = 0.16;
    const tuckExtraFactor = 0.15;
    const horizontalFactor = 0.25;

    final buttonSize = shortest * buttonFactor;
    final horizontalPadding = buttonSize * horizontalFactor;
    final greenWidth = shortest * greenFactor;
    final inset = greenWidth * insetFactor;
    final slide = greenWidth * slideFactor;
    final tuck = slide + greenWidth * tuckExtraFactor;
    final stickWidth = greenWidth - inset + tuck;
    final stickHeight = stickWidth / stickAspect;
    final contentWidth = buttonSize + horizontalPadding * 2;
    final railWidth = contentWidth + notchInset;

    return ToolsPanelMetrics._(
      buttonSize: buttonSize,
      horizontalPadding: horizontalPadding,
      verticalPadding: buttonSize * verticalFactor,
      gap: buttonSize * gapFactor,
      imageSize: buttonSize * imageFactor,
      greenWidth: greenWidth,
      inset: inset,
      slide: slide,
      stickWidth: stickWidth,
      stickHeight: stickHeight,
      stickGap: stickHeight * stickGapFactor,
      contentWidth: contentWidth,
      notchInset: notchInset,
      railWidth: railWidth,
      totalWidth: greenWidth + railWidth,
    );
  }
}
