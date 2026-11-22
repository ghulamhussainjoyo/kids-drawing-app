import 'package:flutter/widgets.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

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
    required this.notchInset, // wapas lagao
    required this.railWidth,
    required this.totalWidth,
  });

  static double _getNotchInset(BuildContext context) {
    final orientation = NativeDeviceOrientationReader.orientation(context);
    final notchOnRight = orientation == NativeDeviceOrientation.landscapeRight;
    return notchOnRight ? MediaQuery.viewPaddingOf(context).right * 0.7 : 0.0;
  }

  factory ToolsPanelMetrics.of(BuildContext context) {
    const buttonFactor = 0.12;
    const verticalFactor = 0.5;
    const gapFactor = 0.25;
    //@DOC: stick ko patla/mota karne ke liye ye value badlo
    const stickAspect = 3.5;
    const insetFactor = 0.08;
    const slideFactor = 0.14;
    const greenFactor = 0.28;
    const imageFactor = 56 / 48;
    const stickGapFactor = 0.16;
    const tuckExtraFactor = 0.15;
    const horizontalFactor = 0.25;

    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final notch = _getNotchInset(context); // ek hi baar

    final buttonSize = shortest * buttonFactor;
    final horizontalPadding = buttonSize * horizontalFactor;
    final greenWidth = shortest * greenFactor;
    final inset = greenWidth * insetFactor;
    final slide = greenWidth * slideFactor;
    final tuck = slide + greenWidth * tuckExtraFactor;
    final stickWidth = greenWidth - inset + tuck;
    final stickHeight = stickWidth / stickAspect;
    final contentWidth = buttonSize + horizontalPadding * 2;
    final railWidth = contentWidth + notch;

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
      notchInset: notch,
      railWidth: railWidth,
      totalWidth: greenWidth + railWidth,
    );
  }
}
