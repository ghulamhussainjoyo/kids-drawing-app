import 'package:flutter/widgets.dart';

extension ResponsiveX on BuildContext {
  /// Design isi width pe banta hua maana gaya hai (iPhone 14 = 390)
  static const double _baseShortestSide = 390;

  /// Phone pe proportional, tablet pe zyada bada nahi hota
  double get scaleFactor {
    final factor = MediaQuery.sizeOf(this).shortestSide / _baseShortestSide;
    return factor.clamp(0.8, 1.5);
  }

  /// context.rs(48) -> is device ke hisab se scaled size
  double rs(double designSize) => designSize * scaleFactor;
}
