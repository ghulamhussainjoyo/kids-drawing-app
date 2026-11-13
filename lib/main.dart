import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:provider/provider.dart';

import 'core/ui/theme/app.theme.dart';
import 'app/splash/splash.screen.dart';
import 'state/drawing/drawing.view-model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawingViewModel()),
        ChangeNotifierProvider(create: (_) => GalleryViewModel()),
        ChangeNotifierProvider(create: (_) => GenreViewModel()),
      ],
      child: const AppWidget(),
    ),
  );
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
