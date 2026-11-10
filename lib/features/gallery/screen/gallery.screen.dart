import 'package:flutter/cupertino.dart';

import '../widgets/gallery.grid.dart';

class GalleryScreen extends StatefulWidget {
  final String category;

  const GalleryScreen({super.key, required this.category});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int categoryIndex = 0;
  late final ScrollController controller;

  final categoryColor = const {
    'food': Color(0xFFE8A87C),
    'music': Color(0xFF8B7CB8),
    'school': Color(0xFF7EC8E3),
    'animals': Color(0xFF7CB88B),
  };

  List<String> get categoryNames => getGalleryList().keys.toList();

  Map<String, List<String>> getGalleryList() {
    final gallery = {
      'animals': [
        'lion',
        'zebra',
        'giraffe',
        'elephant',
        'monkey',
        'panda',
        'snake',
        'tiger',
        'bear',
        'fox',
        'wolf',
        'rabbit',
        'cat',
        'dog',
      ],
      'school': [
        'book',
        'ruler',
        'pencil',
        'crayons',
        'scissors',
        'desk',
        'pouch',
        'bag',
        'stars',
      ],
    };
    return gallery;
  }

  double categoryWidth(String name) {
    return groupWidth(getGalleryList()[name]!);
  }

  double groupWidth(List<String> titles) {
    final height = MediaQuery.sizeOf(context).height;
    const padding = 48.0;
    final cellSize = (height - padding) / 2;
    final columns = (titles.length / 2).ceil();
    return padding + columns * cellSize;
  }

  double get cellSize {
    const padding = 48.0;
    final height = MediaQuery.sizeOf(context).height;
    return (height - padding) / 2;
  }

  void onScroll() {
    setState(() {});
  }

  double offsetForCategory(String category) {
    var offset = 0.0;
    for (final name in categoryNames) {
      if (name == category) {
        return offset;
      }
      offset = offset + categoryWidth(name);
    }
    return 0;
  }

  Color backgroundAtCenter() {
    final names = categoryNames;
    if (!controller.hasClients) {
      return categoryColor[names.first]!;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    var x = controller.offset + screenWidth / 2;
    var index = 0;
    while (index < names.length - 1) {
      final width = categoryWidth(names[index]);
      if (x < width) {
        break;
      }
      x = x - width;
      index = index + 1;
    }

    final color = categoryColor[names[index]]!;
    if (index == names.length - 1) {
      return color;
    }

    final width = categoryWidth(names[index]);
    var fadeStart = width - screenWidth;
    if (fadeStart < 0) {
      fadeStart = 0;
    }
    if (x < fadeStart) {
      return color;
    }
    final blend = ((x - fadeStart) / (width - fadeStart)).clamp(0.0, 1.0);
    return Color.lerp(color, categoryColor[names[index + 1]], blend)!;
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.jumpTo(offsetForCategory(widget.category));
    });
  }

  @override
  Widget build(BuildContext context) {
    final names = categoryNames;
    return CupertinoPageScaffold(
      backgroundColor: backgroundAtCenter(),
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          return SizedBox(
            width: categoryWidth(name),
            child: GalleryGrid(titles: getGalleryList()[name]!),
          );
        },
      ),
    );
  }
}
