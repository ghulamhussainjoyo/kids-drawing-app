import 'package:flutter/cupertino.dart';

import '../core/ui/theme/app.theme.dart';
import '../features/splash/splash.screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Kids Drawing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data(),
      home: const SplashScreen(),
    );
  }
}
