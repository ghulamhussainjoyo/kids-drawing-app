import 'package:flutter/cupertino.dart';

import 'app.colors.dart';

abstract final class AppTheme {
  static CupertinoThemeData data() {
    return const CupertinoThemeData(
      primaryColor: AppColors.purple,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pageBackground,
    );
  }
}
