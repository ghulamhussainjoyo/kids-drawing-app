import 'package:flutter/cupertino.dart';

/// Central typography tokens. Prefer these over inline `fontFamily` strings.
abstract final class AppTypography {
  static const String family = 'Nunito';

  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// Primary UI copy — Nunito SemiBold (600).
  static TextStyle semiBoldStyle({
    double fontSize = 14,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontWeight: semiBold,
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Primary UI headings / emphasis — Nunito Bold (700).
  static TextStyle boldStyle({
    double fontSize = 16,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontWeight: bold,
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Dynamic numbers / percentages — platform system font + tabular figures.
  static TextStyle numericStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: null,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
      height: height,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
