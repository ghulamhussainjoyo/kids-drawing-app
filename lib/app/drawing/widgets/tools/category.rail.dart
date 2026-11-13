import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/rounded.button.dart';

class CategoryRail extends StatelessWidget {
  final String selectedCategory;
  final List<CategoryModel> categories;
  final ValueChanged<String> onCategoryTap;

  const CategoryRail({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      clipBehavior: Clip.none,
      itemCount: categories.length,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = category.name == selectedCategory;
        final fill = selected ? category.activeColor : category.mutedColor;

        return Align(
          alignment: Alignment.centerRight,
          child: Transform.scale(
            scale: selected ? 1.08 : 1.0,
            child: RoundedButton(
              size: category.size,
              imageSize: category.imageSize,
              backgroundColor: fill,
              onPressed: () => onCategoryTap(category.name),
              image: Image.asset(category.image),
            ),
          ),
        );
      },
    );
  }
}
