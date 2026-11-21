import 'package:flutter/widgets.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/tools/glitter.art.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';

/// A category's icon: its image when it has one, otherwise drawn in code.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.fit});

  final CategoryModel category;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final image = category.image;
    if (image != null) return Image.asset(image, fit: fit);
    return const GlitterBottleIcon();
  }
}
