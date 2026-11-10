import 'package:flutter/cupertino.dart';

import '../core/ui/theme/app.theme.dart';
import '../features/splash/splash.screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppWidget());
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

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
