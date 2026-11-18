import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';

import 'app.colors.dart';

abstract final class AppTheme {
  static CupertinoThemeData data() {
    return const CupertinoThemeData(
      primaryColor: AppColors.purple,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pageBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.semiBold,
          color: Color(0xFF221A30),
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.bold,
          fontSize: 17,
          color: Color(0xFF221A30),
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.bold,
          fontSize: 34,
          color: Color(0xFF221A30),
        ),
        navActionTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.semiBold,
          color: AppColors.purple,
        ),
        actionTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.semiBold,
          color: AppColors.purple,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.semiBold,
          fontSize: 10,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.semiBold,
          fontSize: 21,
          color: Color(0xFF221A30),
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: AppTypography.family,
          fontWeight: AppTypography.semiBold,
          fontSize: 21,
          color: Color(0xFF221A30),
        ),
      ),
    );
  }
}
