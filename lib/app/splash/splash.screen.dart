import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../genre/screen/genre.screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  double getSpacing(BuildContext context, double size) {
    return MediaQuery.of(context).size.height * size;
  }

  void openCategory() {
    if (!mounted) return;
    debugPrint('opening category');
    final screenARoute = CupertinoPageRoute(
      builder: (_) => const GenreScreen(),
    );
    Navigator.pushReplacement(context, screenARoute);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), openCategory);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('Splash', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
